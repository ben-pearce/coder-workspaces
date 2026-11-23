#!/bin/sh
set -e

# Docker-in-Docker setup for Coder workspace containers.
#
# The container may not ship a SysV init script for Docker (Ubuntu 24.04 only
# provides a systemd unit, which does not work inside a container), so the
# daemon is started via `service docker` when possible and launched directly
# otherwise.

start_docker() {
	if docker info > /dev/null 2>&1; then
		echo "Docker daemon already running"
		return 0
	fi

	if [ -f /etc/init.d/docker ]; then
		sudo service docker start
	else
		echo "No init script found, starting dockerd directly"
		sudo sh -c 'nohup dockerd > /tmp/dockerd.log 2>&1 &'
	fi

	# Wait for the daemon to answer before continuing.
	i=0
	while ! docker info > /dev/null 2>&1; do
		i=$((i + 1))
		if [ "$i" -ge 30 ]; then
			echo "Docker daemon failed to start, last log lines:" >&2
			tail -n 50 /tmp/dockerd.log >&2 2>/dev/null || true
			return 1
		fi
		sleep 1
	done
	echo "Docker daemon is ready"
}

# Docker-in-Docker setup for Coder workspace containers using
# host.docker.internal URLs. When Docker runs inside a container, the
# "docker0" bridge interface can interfere with host.docker.internal DNS
# resolution, breaking connectivity to the Coder server.

if [ "${CODER_AGENT_URL#*host.docker.internal}" = "$CODER_AGENT_URL" ]; then
	# External access URL detected, no networking workarounds needed.
	start_docker
	exit 0
fi

# host.docker.internal URL detected. Docker's default bridge network creates
# a "docker0" interface that can shadow the host.docker.internal hostname
# resolution once the inner Docker daemon starts.

# Enable IP forwarding to allow packets to route between the host network and
# the inner Docker networks. Without this, traffic cannot flow properly
# between the different Docker bridge networks.
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
sudo iptables -t nat -A POSTROUTING -j MASQUERADE

# Set up port forwarding to the host Docker gateway (typically 172.17.0.1).
# We resolve host.docker.internal to get the actual IP and create NAT rules
# to forward traffic from nested containers to the host.
host_ip=$(getent hosts host.docker.internal | awk '{print $1}')

echo "Host IP for host.docker.internal: $host_ip"

# Extract the port from CODER_AGENT_URL. The URL format is typically
# http://host.docker.internal:port/.
port="${CODER_AGENT_URL##*:}"
port="${port%%/*}"
case "$port" in
[0-9]*)
	# Specific port found, forward it to the host gateway.
	sudo iptables -t nat -A PREROUTING -p tcp --dport "$port" -j DNAT --to-destination "$host_ip:$port"
	echo "Forwarded port $port to $host_ip"
	;;
*)
	# No specific port or non-numeric port, forward standard web ports.
	sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination "$host_ip:80"
	sudo iptables -t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to-destination "$host_ip:443"
	echo "Forwarded default ports 80/443 to $host_ip"
	;;
esac

# Start Docker service, which creates the "docker0" interface if it doesn't
# exist. We need the interface to extract the second IP address for DNS
# resolution.
start_docker

# Configure DNS resolution so nested containers can reach the Coder server
# through host.docker.internal without extra per-project configuration.

# Wait for the workspace to acquire its Docker bridge IP address. The
# "hostname -I" command returns multiple IPs: the first is typically the host
# Docker bridge (172.17.0.0/16 range) and the second is the workspace Docker
# bridge (172.18.0.0/16). We need the second IP because that's where nested
# containers will be able to reach us.
dns_ip=
while [ -z "$dns_ip" ]; do
	dns_ip=$(hostname -I | awk '{print $2}')
	if [ -z "$dns_ip" ]; then
		echo "Waiting for hostname -I to return a valid second IP address..."
		sleep 1
	fi
done

echo "Using DNS IP: $dns_ip"

# Configure dnsmasq to resolve host.docker.internal to this workspace's IP.
# This ensures nested containers can find the Coder server even when the
# "docker0" interface would normally shadow the hostname resolution.
echo "no-hosts" | sudo tee /etc/dnsmasq.conf
echo "address=/host.docker.internal/$dns_ip" | sudo tee -a /etc/dnsmasq.conf
echo "resolv-file=/etc/resolv.conf" | sudo tee -a /etc/dnsmasq.conf
echo "no-dhcp-interface=" | sudo tee -a /etc/dnsmasq.conf
echo "bind-interfaces" | sudo tee -a /etc/dnsmasq.conf
echo "listen-address=127.0.0.1,$dns_ip" | sudo tee -a /etc/dnsmasq.conf

# dnsmasq ships an init script, but fall back to launching it directly if the
# service wrapper is unavailable.
sudo service dnsmasq restart 2>/dev/null || sudo sh -c 'pkill dnsmasq 2>/dev/null; nohup dnsmasq --conf-file=/etc/dnsmasq.conf > /tmp/dnsmasq.log 2>&1 &'

# Configure Docker daemon to use our custom DNS server. This is the critical
# piece that ensures all nested containers use our dnsmasq server for
# hostname resolution, allowing them to properly resolve host.docker.internal.
echo "{\"dns\": [\"$dns_ip\"]}" | sudo tee /etc/docker/daemon.json

sudo pkill -HUP dockerd 2>/dev/null && echo "Docker daemon reloaded" || {
	sudo pkill dockerd 2>/dev/null || true
	sleep 2
	start_docker
}
