
-- @param president id

select * from president p
       join pres_marriage pm on (p.id=pm.pres_id)
       where p.id= cast( ? as integer)

