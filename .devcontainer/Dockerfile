FROM mcr.microsoft.com/devcontainers/base:ubuntu

# install Erlang/Elixir dependencies
#   - build-essentials installs basic developer tools
#   - inotify-tools is required by Phoenix live-reload
#   - libncurses and libncursesw are required to build erlang
#   - libwxgtk and libwxgtk-webview are required to build erlang
#   - openjdk is optional, but required for erlang's jinterface
#   - unixodbc-dev is optional, but required for erlang's odbc application
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
    build-essential \
    inotify-tools \
    libncurses-dev \
    libncursesw5-dev \
    libwxgtk3.2-dev \
    libwxgtk-webview3.2-dev \
    openjdk-17-jdk \
    unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

# Install other developer tools.
RUN apt-get update && apt-get install -y gnupg2 watchman

USER vscode
WORKDIR /home/vscode

# install asdf and verify with md5 checksum
# environment variable can be overridden in devcontainer.json
ENV ASDF_VERSION=0.18.0
RUN set -xe \
    && ARCH=$(dpkg --print-architecture) \
    && URL="https://github.com/asdf-vm/asdf/releases/download/v${ASDF_VERSION}/asdf-v${ASDF_VERSION}-linux-${ARCH}.tar.gz" \
    && curl -fSL -o /tmp/asdf.tar.gz $URL \
    && echo "$(curl -fL ${URL}.md5)  /tmp/asdf.tar.gz" | md5sum -c - \
    && set +xe \
    && sudo tar -xz -C /usr/local/bin/ -f /tmp/asdf.tar.gz \
    && rm /tmp/asdf.tar.gz

# erlang
# environment variable can be overridden in devcontainer.json
ENV ERLANG_VERSION=28.0.2
RUN asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git \
    && asdf install erlang ${ERLANG_VERSION} \
    && asdf set -u erlang ${ERLANG_VERSION} \
    && asdf reshim erlang ${ERLANG_VERSION}

# elixir
# environment variable can be overridden in devcontainer.json
ENV ELIXIR_VERSION=1.18.4-otp-28
RUN asdf plugin add elixir https://github.com/asdf-vm/asdf-elixir.git \
    && asdf install elixir ${ELIXIR_VERSION} \
    && asdf set -u elixir ${ELIXIR_VERSION} \
    && asdf reshim elixir ${ELIXIR_VERSION}

# nodejs
# environment variable can be overridden in devcontainer.json
ENV NODE_VERSION=22.19.0
RUN asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git \
    && asdf install nodejs ${NODE_VERSION} \
    && asdf set -u nodejs ${NODE_VERSION} \
    && asdf reshim nodejs ${NODE_VERSION}

# phoenix
# environment variable can be overridden in devcontainer.json
ENV PHOENIX_VERSION=1.8.1
RUN PATH="$HOME/.asdf/shims:$PATH" \
    && mix local.hex --force \
    && mix local.rebar --force \
    && mix archive.install hex phx_new ${PHOENIX_VERSION} --force

# add asdf shims to PATH and enable asdf bash completions
RUN echo "export PATH=\"$HOME/.asdf/shims:$PATH\"" >> $HOME/.profile \
    && echo ". <(asdf completion bash)" >> $HOME/.bashrc