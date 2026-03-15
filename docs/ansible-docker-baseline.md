# Docker Baseline Runbook

Operational documentation describing Docker baseline configuration applied using Ansible.

This playbook ensures that infrastructure nodes have a consistent Docker runtime baseline required for containerized services.

---

## Playbook Location

```
playbooks/docker_baseline.yml
```

Run manually:

```
cd ~/infra
ansible-playbook playbooks/docker_baseline.yml
```

---

## Purpose

This playbook prepares infrastructure nodes for container workloads.

It performs the following actions:

- checks whether Docker is already installed
- installs Docker packages if Docker is missing
- ensures the `docker` group exists
- adds the administrative user to the `docker` group
- ensures the Docker service is enabled and running

This allows infrastructure nodes to run containerized services in a consistent way.

---

## Package Installation

If Docker is not already installed, the playbook installs:

```
docker.io
docker-compose-v2
```

The playbook does not overwrite an existing Docker installation if one is already present.

This prevents package conflicts on hosts where Docker was installed from a different repository.

---

## Docker Group

The playbook ensures the following group exists:

```
docker
```

The administrative user is added to this group:

```
admin1
```

This allows `admin1` to run Docker commands without using `sudo` after a new login session.

---

## Docker Service

The playbook ensures the Docker service is enabled and running.

Verify service state:

```
systemctl status docker
```

Expected state:

```
active (running)
```

---

## Verification

Check Docker version:

```
docker –version
```

Check Docker Compose plugin:

```
docker compose version
```

Expected behaviour:

- Docker CLI is available
- Docker Compose plugin is available

---

## User Session Note

After adding `admin1` to the `docker` group, an existing shell session may not immediately reflect new group membership.

To apply group membership:

- reconnect via SSH
- start a new login shell

Verify group membership:

```
id
```

Expected output should include:

```
docker
```

---

## Idempotency

The playbook is idempotent.

Running it multiple times will not reinstall Docker if it is already present and correctly configured.

Example:

```
ansible-playbook playbooks/docker_baseline.yml
```

The playbook will only modify hosts where configuration drift occurred.

---

## Related Playbooks

Baseline configuration:

```
playbooks/common_baseline.yml
```

SSH hardening:

```
playbooks/ssh_hardening.yml
```

Node exporter textfile collector:

```
playbooks/node_exporter_textfile.yml
```

Bootstrap sequence:

```
playbooks/bootstrap.yml
```
