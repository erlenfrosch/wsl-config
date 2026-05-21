#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v ansible-playbook &>/dev/null; then
    echo "Installing Ansible..."
    sudo apt-get update -y
    sudo apt-get install -y ansible
fi

ansible-playbook -i "${SCRIPT_DIR}/inventory.ini" "${SCRIPT_DIR}/site.yml" "$@"
