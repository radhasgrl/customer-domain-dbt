# customer-domain-dbt (Repo 3 of 3)

dbt transformations for the **Customer domain** — the third repo in the 3-repo platform
demo. Reads raw data landed by Repo 2 and builds curated marts on top of the platform
provisioned by Repo 1.

```
Repo 1: infra-snowflake (Terraform + DCM)    → provisions DEV_CUSTOMER_DB, schemas,
                                                warehouses, tiered RBAC, and this repo's
                                                own Snowflake identity (GITHUB_DEV_DBT_SVC)
Repo 2: data-ingestion-raw (Snowpipe)        → loads DEV_CUSTOMER_DB.RAW.CUSTOMERS
Repo 3: customer-domain-dbt (this repo)      → stg_customers -> dim_customers
```

This repo intentionally contains **no DCM/Terraform definitions and no RBAC of its own** —
all Snowflake-side provisioning (database, schemas, warehouses, roles, grants) lives in
Repo 1 (`infra-snowflake`). This repo is dbt-only, by design, to keep the demo narrative
clear: one tool per repo, one repo per responsibility.

## Project layout

```
customer-domain-dbt/
├── dbt_project.yml
├── macros/
│   └── generate_schema_name.sql   # makes +schema literal (STAGING/MARTS), not concatenated
├── models/
│   ├── staging/
│   │   ├── _staging__sources.yml   # declares DEV_CUSTOMER_DB.RAW.CUSTOMERS as a source
│   │   ├── _staging__models.yml
│   │   └── stg_customers.sql
│   └── marts/
│       ├── _marts__models.yml
│       └── dim_customers.sql
└── .github/workflows/dbt-ci.yml   # thin wrapper — calls Repo 1's centrally-maintained
                                   #   dbt-build-reusable.yml, on PR + push to main
```

### Centrally-maintained CI

This repo's `.github/workflows/dbt-ci.yml` contains almost no logic of its own — it's a
thin wrapper that calls `dbt-build-reusable.yml` in Repo 1 (`snowflake-platform-tf`) via
`uses:`, passing only this domain's own values (database, warehouse, role, schema, etc.).
The actual build steps (checkout, dbt-snowflake install, OIDC token fetch, `profiles.yml`
generation, `dbt build`, PR comment, PR-schema cleanup) are maintained centrally in Repo 1
— fixing a bug or adding a step there propagates to this repo (and any future per-domain
dbt repo) automatically, with no PR needed here. See Repo 1's README.md, "Centrally-
maintained CI for Repo 3," for the full rationale.

## Identity and access (provisioned by Repo 1 — nothing to set up here)

| Item | Value | Owned by |
|---|---|---|
| Snowflake user | `GITHUB_DEV_DBT_SVC` | Terraform (Repo 1, `oidc_service_user.tf`) |
| Role | `DEV_CUSTOMER_DBT_SERVICE_PRSN` (Tier 1 persona) | DCM (Repo 1, `dcm/_template/sources/definitions/roles.sql` + `grants.sql`) |
| Effective access | Read `DEV_CUSTOMER_DB.RAW`, read/write `DEV_CUSTOMER_DB.STAGING`, read `DEV_CUSTOMER_DB.SHARED`, `USAGE` on `DEV_CUSTOMER_TRANSFORM_WH` | Via `DEV_CUSTOMER_TRANSFORM_FNCRL` (Tier 2) |
| Auth method | GitHub OIDC workload identity (`authenticator: workload_identity`) — no stored password, key, or token | — |
| GitHub Environment | `DEV-dbt` | This repo |

This user is deliberately **least-privilege**: it has exactly one role
(`DEV_CUSTOMER_DBT_SERVICE_PRSN`) and nothing else — demonstrating the tiered RBAC model
built in Repo 1 end-to-end against a real downstream workload.

Note: `dim_customers` (MARTS) is readable by `DEV_CUSTOMER_READER_FNCRL`
(`DEV_CUSTOMER_DATA_ANALYST_PRSN` / `DEV_CUSTOMER_DATA_CONSUMER_PRSN`), not by the dbt
identity's own role — dbt only needs to *write* MARTS, not read it back as a separate role.

## Running locally

dbt-snowflake's `workload_identity` authenticator is CI-only (it expects a GitHub Actions —
or other supported platform's — OIDC token at runtime). For local runs, use your own
`externalbrowser`-authenticated `~/.dbt/profiles.yml` target against the same
`DEV_CUSTOMER_DB` / `DEV_CUSTOMER_TRANSFORM_WH`, under your own role (e.g. `SYSADMIN` or a role
granted `DEV_CUSTOMER_TRANSFORM_FNCRL`), for example:

```yaml
customer_domain:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: xygpmhm-gq04150
      user: <your Snowflake username>
      authenticator: externalbrowser
      role: SYSADMIN
      warehouse: DEV_CUSTOMER_TRANSFORM_WH
      database: DEV_CUSTOMER_DB
      schema: STAGING
      threads: 2
```

```powershell
pip install dbt-snowflake
dbt debug
dbt build
```

## Demo sequencing

1. Repo 1: `terraform apply` → `snow dcm deploy` provisions `DEV_CUSTOMER_DB` (RAW/STAGING/MARTS/SHARED), tiered RBAC, and this repo's `GITHUB_DEV_DBT_SVC` identity.
2. Repo 2: Snowpipe loads a sample CSV into `DEV_CUSTOMER_DB.RAW.CUSTOMERS`.
3. Repo 3 (this repo): `dbt build` runs `stg_customers` (view, STAGING) then `dim_customers` (table, MARTS), with schema tests (`unique`, `not_null`) on both.
