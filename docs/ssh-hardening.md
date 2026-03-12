# SSH Hardening Runbook

This runbook describes how SSH hardening is enforced with Ansible.

---

## Scope

The playbook applies SSH hardening to all hosts in the `ssh_hosts` inventory group.

Managed hosts:

- vps
- admin
- lab

---

## Playbook

Path:

```
playbooks/ssh_hardening.yml
```

The playbook installs a dedicated SSH hardening drop-in file:

```
/etc/ssh/sshd_config.d/99-hardening.conf
```

Configured settings:

```
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
KbdInteractiveAuthentication no
ChallengeResponseAuthentication no
PermitEmptyPasswords no
X11Forwarding no
MaxAuthTries 3
```

---

## Safe Execution

Dry run:

```
ansible-playbook playbooks/ssh_hardening.yml --check
```

Apply:

```
ansible-playbook playbooks/ssh_hardening.yml
```

The playbook runs with:

- become: true
- serial: 1

This ensures hosts are processed one by one.

---

## Validation

The playbook validates SSH configuration with:

```
sshd -t
```

If the configuration is valid, the SSH service is reloaded.

---

## Post-Run Verification

Verify effective SSH settings on all hosts:

```
ansible ssh_hosts -b -m shell -a "sshd -T | grep -E 'permitrootlogin|passwordauthentication|pubkeyauthentication|kbdinteractiveauthentication|maxauthtries|x11forwarding'"
```

Expected output:

```
permitrootlogin no
passwordauthentication no
pubkeyauthentication yes
kbdinteractiveauthentication no
x11forwarding no
maxauthtries 3
```

---

## Manual Host Verification

Examples:

```
ssh vps "sudo sshd -T | grep -E 'permitrootlogin|passwordauthentication|pubkeyauthentication'"
ssh admin "sudo sshd -T | grep -E 'permitrootlogin|passwordauthentication|pubkeyauthentication'"
ssh lab "sudo sshd -T | grep -E 'permitrootlogin|passwordauthentication|pubkeyauthentication'"
```

---

## Recovery Notes

If access issues occur:

1.	keep the current SSH session open
2.	validate config manually:

```
sudo sshd -t
```

3.	inspect the drop-in file:

```
sudo cat /etc/ssh/sshd_config.d/99-hardening.conf
```

4.	remove or fix the file if needed
5.	reload SSH:

```
sudo systemctl reload ssh
```

---

## Security Model

Current SSH model:
	•	root login disabled
	•	password authentication disabled
	•	public key authentication enabled
	•	administrative access through admin1 + sudo

This enforces a key-based access model and reduces attack surface.
