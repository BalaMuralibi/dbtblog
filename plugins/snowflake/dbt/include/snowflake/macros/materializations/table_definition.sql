{% materialization table_definition, default %}
    {%- set identifier = model['alias'] -%}
    {%- set current_relation = adapter.get_relation(database=database, schema=schema, identifier=identifier) -%}
    {%- set target_relation = api.Relation.create(database=database, schema=schema,identifier=identifier,type='table') -%}
    
-- setup
    {{ run_hooks(pre_hooks, inside_transaction=False) }}

    -- `BEGIN` happens here:
    {{ run_hooks(pre_hooks, inside_transaction=True) }}

    -- build model
    {% if current_relation is none -%}
        -- Create Table from file if not exist        
        
        {%- call statement('main') -%}
            {{ create_stmt_fromfile(sql) }}
        {%- endcall -%}
        -- In case table already exist and columns to be added /dropped
    {%- else -%}
        
        {%- set new_cols = adapter.get_missing_columns(current_relation, target_relation) %}
        {%- set dropped_cols = adapter.get_missing_columns(target_relation ,current_relation) %}

        {% if new_cols|length > 0 -%}
            {%- set new_cols_csv = new_cols | map(attribute="name") | join(', ') -%}
            {{ log("COL_ADDED : " ~ new_cols_csv )}}
            {% call statement('add_cols') %}
                {% for col in new_cols %}
                    alter table {{target_relation}} add column "{{col.name}}" {{col.data_type}};
                {% endfor %}
            {%- endcall %}
        {%- endif %}

        {% if dropped_cols|length > 0 -%}
            
            {%- set dropped_cols_csv = dropped_cols | map(attribute="name") | join(', ') -%}
            {{ log("COLUMNS TO BE DROPPED : " ~ dropped_cols_csv )}}
            {% call statement('drop_cols') %}
                {% for col in dropped_cols %}
                    alter table {{current_relation}} drop column "{{col.name}}";
                {% endfor %}
            {%- endcall %}
        {%- endif %}

        {{ adapter.expand_target_column_types(from_relation=target_relation,to_relation=current_relation) }}
         
    {%- endif %}   

    {{ run_hooks(post_hooks, inside_transaction=True) }}

    -- `COMMIT` happens here
    {{ adapter.commit() }}

    {{ run_hooks(post_hooks, inside_transaction=False) }}

    {{ return({'relations': [target_relation] }) }}

{%- endmaterialization %}
