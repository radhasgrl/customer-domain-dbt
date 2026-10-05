{# Without this override, dbt concatenates the profile's target schema with the custom
   +schema config (e.g. "DEV_STAGING"). DEV_CUSTOMER_DB.STAGING / .MARTS already exist as
   DCM-managed schemas (Repo 1), so models must land in them literally, not a concatenated
   name. Standard documented dbt pattern: https://docs.getdbt.com/docs/build/custom-schemas

   DBT_SCHEMA_SUFFIX (set by .github/workflows/dbt-ci.yml only for pull_request runs, e.g.
   "_PR_42") isolates PR builds into their own schemas (STAGING_PR_42, MARTS_PR_42) instead
   of writing into the real, shared STAGING/MARTS schemas that the push-to-main build and
   every other PR also use. This makes a PR an actual safe preview rather than a build that
   already executed for real against production-equivalent tables. Empty/unset for the
   push-to-main build, which targets the real schemas as intended. #}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set suffix = env_var('DBT_SCHEMA_SUFFIX', '') -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}{{ suffix }}
    {%- else -%}
        {{ (custom_schema_name | trim) ~ suffix }}
    {%- endif -%}
{%- endmacro %}
