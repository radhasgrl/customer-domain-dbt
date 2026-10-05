{# Without this override, dbt concatenates the profile's target schema with the custom
   +schema config (e.g. "DEV_STAGING"). DEV_CUSTOMER_DB.STAGING / .MARTS already exist as
   DCM-managed schemas (Repo 1), so models must land in them literally, not a concatenated
   name. Standard documented dbt pattern: https://docs.getdbt.com/docs/build/custom-schemas #}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
