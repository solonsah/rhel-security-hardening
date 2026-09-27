# Operations Runbook

This runbook describes a cautious process for auditing, remediating, validating, and rolling back the RHEL hardening framework.

## Prerequisites

- Ansible control node with the required validation dependencies
- Approved administrative access to the target systems
- Working SSH-key authentication
- Privilege-escalation authorization
- Current system backups or snapshots
- Console or out-of-band recovery access
- Approved maintenance window and change record
- Application-owner approval where required

Never commit production inventories, credentials, private keys, reports, or system-identifying data to this repository.

## 1. Review the Inventory

Copy `inventory/example.ini` to an ignored private inventory and replace the documentation-only values with approved environment information.

Verify connectivity without changing the targets:

```bash
ansible all -i inventory/private/hosts.ini -m ping

Expected result: each authorized host returns SUCCESS.
2. Run Static Validation
bash scripts/validate.sh

Expected result: YAML, Ansible lint, and all playbook syntax checks pass.
3. Run Audit Mode
ansible-playbook \
  -i inventory/private/hosts.ini \
  ansible/playbooks/audit.yml

Audit mode gathers security-control status without applying remediation.
Review the results for:
- Unsupported operating-system versions
- Existing SSH access requirements
- SELinux state
- Audit service status
- Firewall configuration
- Password-policy differences
- Application dependencies that could be affected

4. Prepare Remediation
Before enabling any control:
1. Review the proposed changes.
2. Obtain change approval.
3. Confirm current backups or snapshots.
4. Confirm console or out-of-band access.
5. Confirm working SSH-key access.
6. Test in a disposable non-production RHEL system.
7. Select only the required control families.
Do not enable every control automatically.

5. Run Remediation
Set the approval and control variables through an approved private variables file or command-line extra variables.
Example:
ansible-playbook \
  -i inventory/private/hosts.ini \
  ansible/playbooks/remediate.yml \
  --limit approved_test_host \
  --extra-vars "@inventory/private/remediation.yml"

The remediation playbook processes one host at a time and stops when a host fails.

6. Validate the Result
Confirm:
- Administrative SSH access still works in a separate session.
- sshd -t succeeds.
- Required applications remain healthy.
- SELinux has the approved state.
- auditd is running when managed.
- firewalld is running when managed.
- Approved firewall services remain accessible.
- Password-policy settings match the approved baseline.
- No unexpected errors appear in system or application logs.
Keep the original administrative session open until validation is complete.

7. Roll Back if Required
Identify the exact timestamped backup directory created by the remediation run.

Review its contents before executing rollback. Then provide the approved directory through the rollback playbook’s protected variables.

Rollback must first be tested against the affected non-production host.
After rollback, repeat SSH, service, application, SELinux, audit, firewall, and log validation.

Operational Limitations
- This framework is STIG-aligned but is not a complete STIG implementation.
- It does not certify compliance.
- It does not automatically remove existing firewall services.
- It does not rewrite PAM or Authselect profiles.
- It does not automatically disable SELinux.
- It cannot guarantee application compatibility.
- Static CI validation does not replace testing on disposable RHEL virtual machines.
