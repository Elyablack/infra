# Node Exporter Textfile Collector

Operational documentation describing configuration of the node_exporter textfile collector using Ansible.

This configuration enables custom metrics to be exposed to Prometheus.

---

## Playbook Location

playbooks/node_exporter_textfile.yml

Run manually:

```
cd ~/infra
ansible-playbook playbooks/node_exporter_textfile.yml
```

---

## Purpose

The node_exporter textfile collector allows external scripts to publish custom Prometheus metrics.

In this environment it is used by the backup pipeline to publish the metric:

```
backup_last_success_unixtime
```

This metric is used by Prometheus to detect when backups stop running.

---

## Configuration Applied

The playbook ensures the following directory exists:

```
/var/lib/node_exporter/textfile_collector
```

Permissions:

```
owner: root
mode: 0755
```

Node exporter reads `.prom` files from this directory and exposes them as Prometheus metrics.

---

## Backup Monitoring Integration

The backup pipeline writes the metric file:

```
/var/lib/node_exporter/textfile_collector/backup.prom
```

Example content:

```
backup_last_success_unixtime 1710000000
backup_last_success 1
```

Node exporter automatically exposes these metrics to Prometheus.

---

## Verification

Verify that node exporter exposes the metric:

```
curl -s http://127.0.0.1:9100/metrics | grep backup_last_success
```

Expected output:

```
backup_last_success_unixtime 
backup_last_success 1
```

---

## Prometheus Integration

Prometheus queries the metric:

```
backup_last_success_unixtime
```

Alert rule:

```
time() - backup_last_success_unixtime > 93600
```

If the last successful backup is older than **26 hours**, the alert:

```
BackupMissing
```

is triggered.

---

## Monitoring Flow

```
backup pipeline
│
▼
write metric to textfile collector
│
▼
node_exporter exposes metric
│
▼
Prometheus scrapes metric
│
▼
alert rule evaluates freshness
│
▼
Alertmanager notification
```

---

## Idempotency

The playbook is idempotent.

Running it multiple times will not change system state if the configuration is already applied.

Example:

```
ansible-playbook playbooks/node_exporter_textfile.yml
```

This will only modify hosts where configuration drift occurred.
