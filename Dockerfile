FROM ghcr.io/openclaw/openclaw:latest

USER root

# Stage config into /seed/ — entrypoint merges into .openclaw at runtime
COPY workspace/ /seed/workspace/
COPY openclaw.json /seed/openclaw.json
COPY entrypoint.sh /seed/entrypoint.sh
COPY merge-config.js /seed/merge-config.js

RUN chmod +x /seed/entrypoint.sh \
    && chown -R node:node /seed

# Entrypoint runs as root to handle volume permissions, then drops to node
EXPOSE 18789

ENTRYPOINT ["/seed/entrypoint.sh"]
