# Migrating Dragonfly Attachments to ActiveStorage

AlchemyCMS 8.0 introduces support for [ActiveStorage](https://guides.rubyonrails.org/active_storage_overview.html), replacing the legacy [Dragonfly](https://markevans.github.io/dragonfly/) file storage for attachments and pictures. This guide explains how to migrate your existing Dragonfly-managed files to ActiveStorage.

## Prerequisites

- **AlchemyCMS 8.0 or newer**
- **Rails 7.1 or newer**
- **Configured ActiveStorage services** (e.g., local, Amazon S3, etc.) in your `config/storage.yml`
- **Back up your database and uploads** before starting the migration!

## 1. Install ActiveStorage

If you haven't already, install ActiveStorage and run its migrations:

```sh
bin/rails active_storage:install
bin/rails db:migrate
```

## 2. Prepare Dragonfly Configuration

Ensure your Dragonfly configuration is still present and points to your existing uploads directory. This is necessary so the migration can access your legacy files.

## 3. Run the Migration Tasks

Alchemy provides rake tasks to automate the migration of pictures and attachments.

### Migrate all files

To migrate all files from Dragonfly to ActiveStorage, run:

```sh
bin/rake alchemy:upgrade:8.0:migrate_to_active_storage["your_service_name"]
```

> [!NOTE]
These tasks enqueue background jobs for each record. Make sure your background job processor (e.g., Sidekiq, DelayedJob) is running.

### a. Migrate just Pictures

To migrate all pictures from Dragonfly to ActiveStorage, run:

```sh
bin/rake alchemy:upgrade:8.0:migrate_pictures_to_active_storage["your_service_name"]
```

### b. Migrate just Attachments

To migrate all attachments from Dragonfly to ActiveStorage, run:

```sh
bin/rake alchemy:upgrade:8.0:migrate_attachments_to_active_storage["your_service_name"]
```

## 4. Custom Migration (Optional)

You can also run the migration programmatically:

```ruby
Alchemy::StorageMigration::ActiveStorageMigration.start!(service_name: "amazon", async: true)
```

> [!NOTE]
> - `service_name`: The ActiveStorage service to use (as defined in `storage.yml`)
> - `async`: Whether to use background jobs (`true` by default)

### Example for migrating only pictures:

```ruby
migration = Alchemy::StorageMigration::ActiveStorageMigration.new
migration.migrate_pictures(service_name: "amazon", async: true)
```

### Example for migrating only attachments:

```ruby
migration = Alchemy::StorageMigration::ActiveStorageMigration.new
migration.migrate_attachments(service_name: "amazon", async: true)
```

## 5. Verify the Migration

After the migration:

- Check that all attachments and pictures have corresponding ActiveStorage blobs and attachments.
- Test file downloads and image rendering in your application.
- Once verified, you may remove the old Dragonfly files if desired.

## Troubleshooting

- **Missing files:** Ensure your `uploads` directory is accessible and contains all legacy files.
- **Background jobs not running:** Start your job processor (e.g., `bundle exec sidekiq`).
- **Migration errors:** Check your logs for details and re-run the migration if needed.

## FAQ

**Q: Can I migrate only pictures or only attachments?**
A: Yes, run only the relevant rake task.

**Q: Can I re-run the migration?**
A: Yes, only files that have not been migrated yet will be migrated.

**Q: Are files deleted from Dragonfly after migration?**
A: No. You must manually remove old files if you wish.

## References

- [ActiveStorage Rails Guide](https://edgeguides.rubyonrails.org/active_storage_overview.html)
- [AlchemyCMS Upgrade Guide](https://guides.alchemy-cms.com/upgrading.html)

---

If you have questions or issues, please ask on [GitHub](https://github.com/orgs/AlchemyCMS/discussions) or join our [Slack](https://join.slack.com/t/alchemy-cms/shared_invite/zt-2ir32b4ph-L3EVS0FiMiWKx7omNNbeyw)
