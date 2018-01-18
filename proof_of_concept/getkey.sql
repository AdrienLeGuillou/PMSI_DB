-- get pk
SELECT
  tables.name as tname,
  objects.name as kname
from 
  tables
  join keys on tables.id = keys.table_id
  join objects on keys.id = objects.id
where 
  tables.system=false
  and keys.type = 0
  
-- get fk
with fk as(
  SELECT
    tables.name as tname,
    objects.name as fkname,
    keys.rkey as rkey
  from 
    tables
    join keys on tables.id = keys.table_id
    join objects on keys.id = objects.id
  where 
    tables.system=false
    and keys.type = 2
    and tables.name = 'sejour'
)
select 
  fk.tname as tname,
  fk.fkname as fkname,
  tables.name as ptname,
  objects.name as pkname
from 
  fk
  join keys on fk.rkey = keys.id
  join tables on keys.table_id = tables.id
  join objects on keys.id = objects.id
  

select tables.name from tables where tables.system=false ;