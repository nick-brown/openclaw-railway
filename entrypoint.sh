#!/bin/bash
set -euo pipefail

OPENCLAW_HOME="/home/node/.openclaw"
SEED_DIR="/seed"
STATE_DIR="/data/state"

echo "[entrypoint] waiting for volume mount..."
for i in $(seq 1 30); do
  if mountpoint -q "/data" 2>/dev/null || [ -d "/data" ]; then
    echo "[entrypoint] volume detected"
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo "[entrypoint] WARNING: /data not detected after 30s, continuing anyway"
    break
  fi
  sleep 1
done

# Fix volume permissions (Railway mounts as root)
chown -R node:node /data 2>/dev/null || true

echo "[entrypoint] starting state persistence setup"

# 1. Create state directories on the persistent volume
mkdir -p "$STATE_DIR/agents" "$STATE_DIR/credentials" "$STATE_DIR/canvas"
chown -R node:node "$STATE_DIR"

# 2. Remove stale files/dirs that would conflict with symlinks
for dir in agents credentials canvas; do
  if [ -e "$OPENCLAW_HOME/$dir" ] && [ ! -L "$OPENCLAW_HOME/$dir" ]; then
    rm -rf "$OPENCLAW_HOME/$dir"
  fi
done
if [ -e "$OPENCLAW_HOME/openclaw.json" ] && [ ! -L "$OPENCLAW_HOME/openclaw.json" ]; then
  rm -f "$OPENCLAW_HOME/openclaw.json"
fi

# 3. Symlink state directories to the volume
mkdir -p "$OPENCLAW_HOME"
ln -sfn "$STATE_DIR/agents" "$OPENCLAW_HOME/agents"
ln -sfn "$STATE_DIR/credentials" "$OPENCLAW_HOME/credentials"
ln -sfn "$STATE_DIR/canvas" "$OPENCLAW_HOME/canvas"

# 4. Copy workspace from git (git always wins)
rm -rf "$OPENCLAW_HOME/workspace"
cp -r "$SEED_DIR/workspace" "$OPENCLAW_HOME/workspace"

# 5. Config merge
if [ ! -f "$STATE_DIR/openclaw.json.baseline" ]; then
  echo "[entrypoint] first boot — seeding config from git"
  cp "$SEED_DIR/openclaw.json" "$STATE_DIR/openclaw.json"
  cp "$SEED_DIR/openclaw.json" "$STATE_DIR/openclaw.json.baseline"
else
  echo "[entrypoint] subsequent boot — merging config"
  node "$SEED_DIR/merge-config.js" \
    "$SEED_DIR/openclaw.json" \
    "$STATE_DIR/openclaw.json.baseline" \
    "$STATE_DIR/openclaw.json" \
    "$STATE_DIR/openclaw.json"
  cp "$SEED_DIR/openclaw.json" "$STATE_DIR/openclaw.json.baseline"
fi

# 6. Symlink config to the volume
ln -sfn "$STATE_DIR/openclaw.json" "$OPENCLAW_HOME/openclaw.json"

# Ensure .openclaw is owned by node
chown -R node:node "$OPENCLAW_HOME"

echo "[entrypoint] state persistence setup complete"

# 7. Start the gateway as node user
exec su -s /bin/bash node -c "exec openclaw gateway run"
