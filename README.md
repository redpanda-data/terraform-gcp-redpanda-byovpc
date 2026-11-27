# terraform-gcp-redpanda-byovpc

## Redpanda SQL

Set `enable_redpanda_sql = true` to create the Redpanda SQL service accounts,
the Redpanda SQL storage bucket and their IAM. The Redpanda SQL service
account gets:

- Read/write on the `oxla*` objects in its own bucket, and list on that
  bucket.
- Read access to the whole cloud storage bucket for Iceberg data
  (`storage.objects.get` and `storage.objects.list`), matched by exact
  bucket name.
- Write access to the cloud storage bucket only under the `rpsql_` prefix
  (`storage.objects.create` and `storage.objects.delete`; overwriting an
  object needs both), where Redpanda SQL writes its Iceberg data. The topic
  data the brokers write stays read-only for Redpanda SQL.
- `roles/biglake.editor` and `roles/serviceusage.serviceUsageConsumer`, to
  read and write a BigLake Iceberg REST catalog in the service project.

Upgrading from v1.0.5 adds the Iceberg write role and its binding, and
replaces the BigLake binding: the `roles/biglake.editor` binding is created
before the `roles/biglake.viewer` one is removed, so queries keep working.
Upgrading from v1.0.4 adds the same write role and binding, narrows the
Iceberg storage role to read and replaces the Iceberg and list bindings,
creating the new bindings first; the BigLake binding stays on
`roles/biglake.editor`. No extra step is needed.
