{%- materialization view_definition, default -%}

  {%- set identifier = model['alias'] -%} 
  {%- set target_relation = api.Relation.create( identifier=identifier, schema=schema, database=database, type='view') -%}
 

  {%- set has_transactional_hooks = (hooks | selectattr('transaction', 'equalto', True) | list | length) > 0 %}
  

  {{ run_hooks(pre_hooks, inside_transaction=False) }}

 

  -- `BEGIN` happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

  -- build model
  
    
    {% call statement('main') -%}
      {{ create_stmt_fromfile(sql) }}
    {%- endcall %} 

  {{ run_hooks(post_hooks, inside_transaction=True) }}    
  
      {{ adapter.commit() }}
  

  {{ run_hooks(post_hooks, inside_transaction=False) }}
   {{ return({'relations': [target_relation]}) }}

{%- endmaterialization -%}
