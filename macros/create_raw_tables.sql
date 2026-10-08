{# Ensures the Customer domain's RAW landing table exists before any model needs it,
   called via on-run-start (see dbt_project.yml). Table DDL for RAW is intentionally
   owned HERE, by dbt, not by Repo 1 (DCM) -- see dcm/domains/customer/manifest.yml's
   RAW schema comment in Repo 1 for the other half of this split: Repo 1 still governs
   the RAW schema container and grants (CREATE TABLE privilege, Tier 2/3 roles), but no
   longer defines the table's own structure.

   CREATE TABLE IF NOT EXISTS is intentional and important: this must never clobber
   already-landed data on a routine `dbt build` -- it only creates the table the very
   first time it's missing. Schema evolution (e.g. adding a column) means editing this
   macro and re-running -- Snowflake's IF NOT EXISTS leaves an already-existing table
   untouched even if its column list in this macro changes, so a genuine ADD COLUMN
   needs an explicit ALTER TABLE here too, not just an edit to the CREATE TABLE text. #}
{% macro create_raw_customers_table() %}
  {% set sql %}
    CREATE TABLE IF NOT EXISTS {{ target.database }}.RAW.CUSTOMERS (
      CUSTOMER_ID   NUMBER  COMMENT 'Unique customer identifier',
      CUSTOMER_NAME VARCHAR COMMENT 'Customer display name',
      SIGNUP_CHANNEL  VARCHAR COMMENT 'Acquisition channel the customer signed up through'
    )
    COMMENT = 'Raw landing table for customer records, loaded by the Snowpipe ingestion pipeline (Repo 2) -- created and owned by dbt (Repo 3), not DCM (Repo 1)';
  {% endset %}
  {% do run_query(sql) %}
  {{ log("Ensured " ~ target.database ~ ".RAW.CUSTOMERS exists", info=True) }}
{% endmacro %}
