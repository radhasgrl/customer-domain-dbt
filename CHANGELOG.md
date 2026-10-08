# Changelog

## [1.0.2](https://github.com/radhasgrl/customer-domain-dbt/compare/v1.0.1...v1.0.2) (2026-10-08)


### Bug Fixes

* **customer:** create RAW.CUSTOMERS table from dbt, not DCM ([#10](https://github.com/radhasgrl/customer-domain-dbt/issues/10)) ([2333acf](https://github.com/radhasgrl/customer-domain-dbt/commit/2333acf7cfadfaeec8fb93f1d016c3e31b77d027))

## [1.0.1](https://github.com/radhasgrl/customer-domain-dbt/compare/v1.0.0...v1.0.1) (2026-10-07)


### Bug Fixes

* **staging:** make source database dynamic via target.database ([#7](https://github.com/radhasgrl/customer-domain-dbt/issues/7)) ([6485979](https://github.com/radhasgrl/customer-domain-dbt/commit/6485979211afa50e5b6752a49cd4eb99ffe30c85))

## 1.0.0 (2026-10-07)


### Features

* **ci:** add PR title lint, release-please, and TEST promotion ([#5](https://github.com/radhasgrl/customer-domain-dbt/issues/5)) ([90be9a5](https://github.com/radhasgrl/customer-domain-dbt/commit/90be9a5a1dc95d6ecd29ed45ff84315296b82fef))
* isolate PR builds into ephemeral schemas, post build summary to PR ([#1](https://github.com/radhasgrl/customer-domain-dbt/issues/1)) ([a4af8b2](https://github.com/radhasgrl/customer-domain-dbt/commit/a4af8b29437b48774415a3c492504d0970920723))
* scaffold customer-domain-dbt (Repo 3 of 3) ([6bc457c](https://github.com/radhasgrl/customer-domain-dbt/commit/6bc457c043ffaf079a9b629c9795f707d7ec6eae))


### Bug Fixes

* dbt-snowflake needs the OIDC token fetched and passed explicitly ([4ba78e4](https://github.com/radhasgrl/customer-domain-dbt/commit/4ba78e486bcbf6afb52978ea6c05021bd3640e19))
