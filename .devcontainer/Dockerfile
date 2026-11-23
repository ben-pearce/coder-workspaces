FROM alpine:3.22@sha256:49340b346798875b5592e5d420241f2f9cfba5f47e62ebb1446a1b34734e898f

RUN apk add --no-cache \
  bash \
  ca-certificates \
  git \
  opentofu \
  shellcheck \
  sudo

ARG USERNAME=coder
ARG USER_UID=1000
ARG USER_GID=1000
RUN addgroup -g "${USER_GID}" "${USERNAME}" \
  && adduser -D -u "${USER_UID}" -G "${USERNAME}" "${USERNAME}" \
  && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}" \
  && chmod 0440 "/etc/sudoers.d/${USERNAME}"

USER ${USERNAME}
