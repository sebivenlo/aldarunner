begin work;
create or replace view mooc_progress
       as
       select snummer,achternaam,roepnaam, tussenvoegsel,
       email1, sclass,
       part01,part02,part03,part04,
       part05,part06,part07,part08,
       part09,part10,part11,part12,
       part13,part14, total 
       from mooc_2020 natural join student natural join student_class
      order by sclass, achternaam,roepnaam;
commit;
