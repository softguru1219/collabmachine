# Production Database Setup

- within the appropriate Google Cloud Platform project, create a new Cloud SQL Instance
  - Postgres 13
  - 1 vCPU
  - 10GB
  - SSD
  - ✅ automated backups
  - Montreal Data Centre
  - (record the password)
- Under Connections > Networking whitelist the IP's for
  - developers' home networks
  - the production app server
- SSL?
- Under Users, add a user account called `app_server` & record the password
- connect to the administrative database (`postgres`) using PSQL:
`psql postgres://app_server:<pass>@<ip>/postgres`
- `create database <dbname>;`
- On the app server, use rails console to test connection with database server:
```
conn =  PG.connect(
  host: "<host>",
  port: "5432",
  dbname: "postgres",
  user: "app_server",
  password: "<pass>"
)
conn.exec("select datname from pg_database;").to_a
```

## Migration
- shut down production app server
- dump old prod database:
`pg_dump --file="tmp/collab_prod_2021_08_09.sql" --no-privileges --no-owner postgres://<user>:<pass>@oregon-postgres.render.com/<dbname>`
- get rowcounts of old prod database
- connect to new prod database server with `psql`:
`psql postgres://app_server:<pass>@<ip>/<dbname>`
- set stop on error: `\set ON_ERROR_STOP true`
- import the dump: `\i tmp/collab_prod_2021_08_09.sql`
- verify rowcounts of new prod database
- modify database.yml on prod server
- verify that it works in rails console
- restart server

## Get Rowcounts

```
SELECT 'applicants' AS table_name, COUNT(*) AS exact_row_count FROM public.applicants UNION
SELECT 'ar_internal_metadata' AS table_name, COUNT(*) AS exact_row_count FROM public.ar_internal_metadata UNION
SELECT 'estimates' AS table_name, COUNT(*) AS exact_row_count FROM public.estimates UNION
SELECT 'exchanges' AS table_name, COUNT(*) AS exact_row_count FROM public.exchanges UNION
SELECT 'financial_infos' AS table_name, COUNT(*) AS exact_row_count FROM public.financial_infos UNION
SELECT 'friendly_id_slugs' AS table_name, COUNT(*) AS exact_row_count FROM public.friendly_id_slugs UNION
SELECT 'insurance_quotes' AS table_name, COUNT(*) AS exact_row_count FROM public.insurance_quotes UNION
SELECT 'invoice_lines' AS table_name, COUNT(*) AS exact_row_count FROM public.invoice_lines UNION
SELECT 'invoice_parents' AS table_name, COUNT(*) AS exact_row_count FROM public.invoice_parents UNION
SELECT 'invoices' AS table_name, COUNT(*) AS exact_row_count FROM public.invoices UNION
SELECT 'item_taxes' AS table_name, COUNT(*) AS exact_row_count FROM public.item_taxes UNION
SELECT 'machines' AS table_name, COUNT(*) AS exact_row_count FROM public.machines UNION
SELECT 'messages' AS table_name, COUNT(*) AS exact_row_count FROM public.messages UNION
SELECT 'meta_attributes' AS table_name, COUNT(*) AS exact_row_count FROM public.meta_attributes UNION
SELECT 'milestones' AS table_name, COUNT(*) AS exact_row_count FROM public.milestones UNION
SELECT 'missions' AS table_name, COUNT(*) AS exact_row_count FROM public.missions UNION
SELECT 'missions_milestones' AS table_name, COUNT(*) AS exact_row_count FROM public.missions_milestones UNION
SELECT 'people' AS table_name, COUNT(*) AS exact_row_count FROM public.people UNION
SELECT 'products' AS table_name, COUNT(*) AS exact_row_count FROM public.products UNION
SELECT 'profiles' AS table_name, COUNT(*) AS exact_row_count FROM public.profiles UNION
SELECT 'projects' AS table_name, COUNT(*) AS exact_row_count FROM public.projects UNION
SELECT 'redactor_assets' AS table_name, COUNT(*) AS exact_row_count FROM public.redactor_assets UNION
SELECT 'schema_migrations' AS table_name, COUNT(*) AS exact_row_count FROM public.schema_migrations UNION
SELECT 'sessions' AS table_name, COUNT(*) AS exact_row_count FROM public.sessions UNION
SELECT 'shares' AS table_name, COUNT(*) AS exact_row_count FROM public.shares UNION
SELECT 'taggings' AS table_name, COUNT(*) AS exact_row_count FROM public.taggings UNION
SELECT 'tags' AS table_name, COUNT(*) AS exact_row_count FROM public.tags UNION
SELECT 'taxes' AS table_name, COUNT(*) AS exact_row_count FROM public.taxes UNION
SELECT 'trackers' AS table_name, COUNT(*) AS exact_row_count FROM public.trackers UNION
SELECT 'transactions' AS table_name, COUNT(*) AS exact_row_count FROM public.transactions UNION
SELECT 'user_messages' AS table_name, COUNT(*) AS exact_row_count FROM public.user_messages UNION
SELECT 'users' AS table_name, COUNT(*) AS exact_row_count FROM public.users;
```
