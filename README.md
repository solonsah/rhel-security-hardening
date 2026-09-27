# RHEL Security Hardening

[![Ansible Validation](https://github.com/solonsah/rhel-security-hardening/actions/workflows/ansible-validation.yml/badge.svg)](https://github.com/solonsah/rhel-security-hardening/actions/workflows/ansible-validation.yml)

An audit-first Ansible framework for applying selected security controls to Red Hat Enterprise Linux systems with approval gates, validation, backups, and rollback safeguards.

## Project Goals

- Audit existing security settings before remediation
- Apply only explicitly approved controls
- Reduce the risk of administrative lockout
- Back up managed configuration before changing it
- Validate affected services after remediation
- Provide a controlled rollback process
- Demonstrate production-oriented Ansible design

## Supported Platforms

| Platform | Status |
|---|---|
| RHEL 8 | Supported target |
| RHEL 9 | Supported target |
| RHEL 7 | Planned legacy-compatibility testing |
| RHEL 10 | Planned compatibility testing |
| Ubuntu | CI runner only, not a managed target |

The GitHub Actions workflow runs on Ubuntu only to perform YAML linting, Ansible linting, and playbook syntax checks. It does not apply RHEL hardening controls to Ubuntu.

## Security-Control Areas

The framework includes opt-in management for:

- SELinux enforcement and policy configuration
- OpenSSH security settings
- Audit service and focused audit rules
- Firewalld service access
- Password-quality settings

All remediation families are disabled by default.

## Safety Design

Remediation requires explicit confirmation that:

- The change is approved
- Rollback access is available
- SSH-key access works before SSH changes
- The target is a supported RHEL release
- Ansible has effective root privileges
- Each requested control family is individually enabled

The remediation playbook uses `serial: 1` and stops on errors to limit impact.

## Repository Structure

```text
.
├── .github/workflows/
│   └── ansible-validation.yml
├── ansible/
│   ├── playbooks/
│   │   ├── audit.yml
│   │   ├── remediate.yml
│   │   └── rollback.yml
│   └── roles/rhel_hardening/
│       ├── defaults/
│       ├── handlers/
│       ├── tasks/
│       └── templates/
├── docs/
│   ├── operations-runbook.md
│   └── security-controls.md
├── inventory/
│   └── example.ini
├── sample-output/
│   └── README.md
├── scripts/
│   └── validate.sh
├── .ansible-lint
├── .gitattributes
├── .gitignore
├── .yamllint
├── ansible.cfg
└── requirements-dev.txt
```

## Audit Mode

Audit mode gathers relevant security-control status without applying remediation:

```bash
ansible-playbook \
  -i inventory/private/hosts.ini \
  ansible/playbooks/audit.yml
```

Use a private, ignored inventory. Never commit real hostnames, IP addresses, usernames, credentials, or infrastructure details.

## Remediation Mode

Remediation is blocked by default. Use an approved private variables file to confirm the safety gates and enable only the required controls:

```bash
ansible-playbook \
  -i inventory/private/hosts.ini \
  ansible/playbooks/remediate.yml \
  --limit approved_test_host \
  --extra-vars "@inventory/private/remediation.yml"
```

Test first on a disposable non-production RHEL system. Maintain a separate administrative session and confirmed console access during SSH-related changes.

## Backup and Rollback

Managed configuration files are backed up under:

```text
/var/backups/rhel-hardening/
```

Rollback requires explicit approval and the exact timestamped backup directory. It restores only files managed by this framework.

Persistent SELinux configuration can be restored from backup, but runtime SELinux state and other system state may require separate review.

## Local Validation

Install the pinned development dependencies:

```bash
python -m pip install --requirement requirements-dev.txt
```

Run all static checks:

```bash
bash scripts/validate.sh
```

Validation includes:

- YAML formatting
- Ansible linting
- Audit playbook syntax
- Remediation playbook syntax
- Rollback playbook syntax

## CI Validation

GitHub Actions runs the same static validation on supported repository changes.

Passing CI confirms formatting, linting, and syntax. It does not prove that remediation works correctly on a live RHEL system.

Complete operational testing requires disposable RHEL-compatible virtual machines because Ubuntu runners and ordinary containers cannot faithfully validate all systemd, SELinux, auditd, firewalld, SSH-reload, and rollback behavior.

## Important Limitations

- This project is STIG-aligned, not a complete DISA STIG implementation.
- It does not certify a system as compliant.
- Existing firewall services are not automatically removed.
- PAM and Authselect profiles are not automatically rewritten.
- SELinux is not automatically disabled.
- Application compatibility cannot be guaranteed.
- Production use requires organizational review, testing, approvals, backups, and recovery access.

## Documentation

- [Security controls](docs/security-controls.md)
- [Operations runbook](docs/operations-runbook.md)
- [Sample-output guidance](sample-output/README.md)

## License

This project is licensed under the [MIT License](LICENSE).
