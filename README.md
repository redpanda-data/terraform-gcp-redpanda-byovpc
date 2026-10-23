# terraform-gcp-redpanda-byovpc

## Redpanda SQL

Set `enable_redpanda_sql = true` to create the Redpanda SQL service accounts,
the Redpanda SQL storage bucket and their IAM. The Redpanda SQL service
account gets:

- Read/write on the `oxla*` objects in its own bucket, and list on that
  bucket.
- Read-only access to the cloud storage bucket for Iceberg topic data
  (`storage.objects.get` and `storage.objects.list`), matched by exact
  bucket name. The brokers write the topic data; Redpanda SQL only reads it.
- `roles/biglake.viewer` and `roles/serviceusage.serviceUsageConsumer`, to
  read a BigLake Iceberg REST catalog in the service project.

Upgrading from a version that granted write access replaces the Iceberg and
list bindings and moves BigLake from `roles/biglake.editor` to
`roles/biglake.viewer`. The new bindings are created before the old ones are
removed, so queries keep working and no extra step is needed.
