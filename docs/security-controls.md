# Security Controls

This project provides an audit-first, STIG-aligned hardening framework for supported RHEL systems. It does not claim complete DISA STIG compliance or replace an authorized compliance assessment.

## Supported Platforms

- RHEL 8
- RHEL 9

RHEL 7 and RHEL 10 require separate compatibility testing before being declared supported.

## Implemented Control Areas

### SELinux

- Audits the current enforcement state.
- Manages persistent SELinux mode and policy when explicitly enabled.
- Supports `enforcing` and `permissive`.
- Does not automatically disable SELinux.

### OpenSSH

- Validates the configuration with `sshd -t` before reloading.
- Controls root login, password authentication, X11 forwarding, authentication attempts, and idle-session settings.
- Requires confirmation of working SSH-key access before remediation.
- Creates a backup before changing the configuration.

### Audit Logging

- Installs and enables `auditd`.
- Deploys focused audit rules for identity files, SSH configuration, and SELinux configuration.
- Loads managed rules with `augenrules`.
- Provides a demonstration baseline rather than a complete STIG audit policy.

### Firewall

- Installs and enables `firewalld`.
- Adds only explicitly approved services.
- Records the existing permanent configuration before changes.
- Does not automatically remove existing services because that could interrupt applications.

### Password Policy

- Installs `libpwquality`.
- Manages password minimum length and character-class requirements.
- Backs up the existing configuration.
- Does not rewrite PAM or Authselect profiles automatically.

## Safety Controls

Remediation is blocked unless:

- The operating system and major version are supported.
- The playbook is running with effective root privileges.
- Change approval is confirmed.
- Rollback access is confirmed.
- SSH-key access is confirmed before SSH changes.
- Individual remediation control families are explicitly enabled.

Remediation runs one host at a time and stops on errors to limit operational impact.

## Backup and Rollback

Before managed changes, the role creates timestamped backups under:

```text
/var/backups/rhel-hardening/

The rollback playbook is disabled by default. It requires explicit approval and a specific timestamped backup directory.
Rollback restores only files managed by this framework. Runtime SELinux changes and other system state may require separate review.
Validation
Static validation includes:
- YAML formatting
- Ansible linting
- Audit playbook syntax checking
- Remediation playbook syntax checking
- Rollback playbook syntax checking
Full operational testing should use disposable RHEL-compatible virtual machines because containers and Ubuntu-hosted CI cannot accurately validate every systemd, SELinux, SSH, auditd, and firewalld behavior.
Rollback is intentionally protected from accidental execution.
Only framework-managed files are restored.
SELinux runtime state may need separate recovery.
GitHub Actions performs static validation, not complete RHEL remediation testing.
Real operational validation requires disposable RHEL-compatible VMs.
