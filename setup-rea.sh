#!/usr/bin/env bash
# Rebuilds Ade's REA reverse-engineering lab on a fresh Ubuntu 24.04 machine
# (e.g. a new Claude Code cloud session). Run as root from the repo:  bash setup-rea.sh
# Best set as the cloud environment's setup script so it runs before Claude starts;
# if run mid-session instead, restart Claude Code to load the REA MCP server and skill.
set -euo pipefail
LAB=$(cd "$(dirname "$0")" && pwd)

NODE_MAJOR=24
GHIDRA_VERSION=12.1.4
GHIDRA_BUILD=ghidra_12.1.4_PUBLIC_20260921
GHIDRA_DIR=/opt/ghidra_${GHIDRA_VERSION}_PUBLIC
RIZIN_VERSION=0.9.1
TMP=$(mktemp -d)

echo "==> 1/6 System packages (compiler, debugger, objdump, Java 21 for Ghidra)"
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
  binutils gcc gdb file unzip curl python3 openjdk-21-jdk-headless >/dev/null

echo "==> 2/6 Node.js ${NODE_MAJOR}.x (REA runs on Node)"
if ! node --version 2>/dev/null | grep -q "^v${NODE_MAJOR}\."; then
  V=$(curl -s https://nodejs.org/dist/index.json | python3 -c \
    "import json,sys;print(next(r['version'] for r in json.load(sys.stdin) if r['version'].startswith('v${NODE_MAJOR}.')))")
  curl -sL "https://nodejs.org/dist/$V/node-$V-linux-x64.tar.xz" -o "$TMP/node.tar.xz"
  tar -xf "$TMP/node.tar.xz" -C /usr/local --strip-components=1
fi
node --version

echo "==> 3/6 REA"
npm install --global rea-agents >/dev/null
rea --version

echo "==> 4/6 Ghidra ${GHIDRA_VERSION} (free decompiler REA drives)"
if [ ! -d "$GHIDRA_DIR" ]; then
  curl -sL "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_${GHIDRA_VERSION}_build/${GHIDRA_BUILD}.zip" -o "$TMP/ghidra.zip"
  unzip -q "$TMP/ghidra.zip" -d /opt
fi
grep -q GHIDRA_INSTALL_DIR ~/.bashrc || echo "export GHIDRA_INSTALL_DIR=$GHIDRA_DIR" >> ~/.bashrc
export GHIDRA_INSTALL_DIR=$GHIDRA_DIR

echo "==> 5/6 Rizin ${RIZIN_VERSION} (lightweight disassembler)"
if ! command -v rizin >/dev/null; then
  mkdir -p /opt/rizin
  curl -sL "https://github.com/rizinorg/rizin/releases/download/v${RIZIN_VERSION}/rizin-v${RIZIN_VERSION}-static-x86_64.tar.xz" -o "$TMP/rizin.tar.xz"
  tar -xf "$TMP/rizin.tar.xz" -C /opt/rizin
  for b in /opt/rizin/bin/*; do ln -sf "$b" /usr/local/bin/; done
fi

echo "==> 6/6 Connect REA to Claude Code (MCP server + skill), with Ghidra path"
rea setup --client claude_code --yes >/dev/null
python3 - "$GHIDRA_DIR" <<'EOF'
import json, sys
p = '/root/.claude.json'
d = json.load(open(p))
d['mcpServers']['rea'].setdefault('env', {})['GHIDRA_INSTALL_DIR'] = sys.argv[1]
json.dump(d, open(p, 'w'), indent=2)
EOF

echo "==> Building lesson binaries"
(cd "$LAB/01-crackme" && gcc -O0 -o crackme crackme.c && strip -o crackme-stripped crackme)

rm -rf "$TMP"
rea doctor --filter-output healthy
echo "Done. Start a session in this repo and say: 'Start lesson 1'."
