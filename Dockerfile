# Dockerfile for Livebook with livebook_tools MCP server
FROM elixir:1.18-otp-27

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    inotify-tools \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && mix local.rebar --force

# Clone and build livebook_tools from GitHub
RUN git clone https://github.com/thmsmlr/livebook_tools.git
WORKDIR /app/livebook_tools
RUN mix deps.get && mix escript.build
RUN mix escript.install --force && cp /root/.mix/escripts/livebook_tools /usr/local/bin/

# Install Livebook
RUN mix escript.install hex livebook --force
RUN cp /root/.mix/escripts/livebook /usr/local/bin/

# Create notebooks directory
RUN mkdir -p /data/notebooks

# Set environment variables
ENV LIVEBOOK_HOME=/data/notebooks
ENV LIVEBOOK_PORT=8080
ENV LIVEBOOK_IP=0.0.0.0
ENV LIVEBOOK_NODE=livebook@127.0.0.1
ENV LIVEBOOK_COOKIE=secret
ENV MIX_ENV=prod

WORKDIR /data/notebooks

# Expose ports
EXPOSE 8080

# Start scripts
COPY docker-entrypoint.sh /usr/local/bin/
COPY watch-all.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh /usr/local/bin/watch-all.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["livebook"]
