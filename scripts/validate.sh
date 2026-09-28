#!/usr/bin/env bash

set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repository_root}"

echo "Validating YAML formatting..."
yamllint .

echo "Running Ansible lint..."
ansible-lint ansible/

echo "Checking the audit playbook syntax..."
ansible-playbook --syntax-check ansible/playbooks/audit.yml

echo "Checking the remediation playbook syntax..."
ansible-playbook --syntax-check ansible/playbooks/remediate.yml

echo "Checking the rollback playbook syntax..."
ansible-playbook --syntax-check ansible/playbooks/rollback.yml

echo "All RHEL hardening validation checks passed."
