delete from project where prj_id=684;
commit;
update project set year=2020 where prj_id=704;
commit;
select * from prj_milestone where prj_id=704;
update assessment_due='2030-12-31' where prjm_id=938;
rollback ;
update prj_milestone set assessment_due='2030-12-31' where prjm_id=938;
commit;
\d student
update student set active=false where class_id =567;
commit;
update student set active=false where class_id =577;
update student set active=false where class_id =240;
commit;
update student set active=false where class_id =1751;
commit;
update student set active=false where class_id =1033;
commit;
alter table completed add column grp_num integer;
commit;
select * from completed;
select c.*, int(substr(c.grp1,1))from completed c;
rollback ;
select c.*, substr(c.grp1,1)::integer from completed c;
rollback ;
select c.*, substr(c.grp,1,1)::integer from completed c;
select c.*, substr(c.grp,2,1)::integer from completed c;
rollback ;
select c.*, substr(c.grp,2,1)::integer from completed c;
select c.*, substr(c.grp,2,3)::integer from completed c;
update completed set grp_num= substr(grp,2,3)::integer from completed c;
rollback ;
update completed set grp_num= substr(grp,2,3)::integer;
commit;
table completed
;
select prj_tutro natural join completed;
select prj_tutro natural join completed;
rollback ;
select prj_tutor natural join completed;
rollback ;
select * from prj_tutor natural join completed;
select * from prj_tutor natural join completed natural join student where prjm_id=;
select * from prj_tutor  join completed using(grp_num);
rollback ;
select * from prj_tutor  join completed using(grp_num);
select * from prj_tutor  join completed using(grp_num) where prjm_id=1011;
with pg as (select * from prj_tutor join prj_grp using (prjtg_id) join completed using(grp_num) where prjm_id=1011) select * from pg join student using(snummer);
with pg as (select * from prj_tutor join prj_grp using (prjtg_id) join completed using(grp_num) where prjm_id=1011) select * from pg join student using(snummer) where prj_grp< 100;
rollback ;
with pg as (select * from prj_tutor join prj_grp using (prjtg_id) join completed using(grp_num) where prjm_id=1011) select * from pg join student using(snummer) where grp_num  100;
rollback ;
with pg as (select * from prj_tutor join prj_grp using (prjtg_id) join completed using(grp_num) where prjm_id=1011) select * from pg join student using(snummer) where grp_num <  100;
with pg as (select * from prj_tutor join prj_grp using (prjtg_id) join completed using(grp_num) where prjm_id=1011) select s.snummer,s.achternaam,s.roepnaam, pg.* from pg join student using(snummer) where grp_num <  100;
rollback ;
with pg as (select * from prj_tutor join prj_grp using (prjtg_id) join completed using(grp_num) where prjm_id=1011) select s.snummer,s.achternaam,s.roepnaam, pg.* from pg join student s using(snummer) where grp_num <  100;
with pg as (select * from prj_tutor join prj_grp using (prjtg_id) join completed using(grp_num) where prjm_id=1011) select s.snummer,s.achternaam,s.roepnaam, pg.* from pg join student s using(snummer) where grp_num <  100;
with pg as (select * from prj_tutor join prj_grp using (prjtg_id) join completed using(grp_num) where prjm_id=1011) select s.snummer,s.achternaam,s.roepnaam, pg.* from pg join student s using(snummer) where grp_num <  100;
\a
copy * from (with pg as (select * from prj_tutor join prj_grp using (prjtg_id) join completed using(grp_num) where prjm_id=1011) select s.snummer,s.achternaam,s.roepnaam, pg.* from pg join student s using(snummer) where grp_num <  100) csv header to '/tmp/puk.csv';
rollback ;
with pg as (select * from prj_tutor join prj_grp using (prjtg_id) join completed using(grp_num) where prjm_id=1011) select s.snummer,s.achternaam,s.roepnaam, pg.* from pg join student s using(snummer) where grp_num <  100;
\d , 
\t ,
\t
\t
\f ,
with pg as (select * from prj_tutor join prj_grp using (prjtg_id) join completed using(grp_num) where prjm_id=1011) select s.snummer,s.achternaam,s.roepnaam, pg.* from pg join student s using(snummer) where grp_num <  100;
create view prc2_completed_20200706 as with pg as (select * from prj_tutor join prj_grp using (prjtg_id) join completed using(grp_num) where prjm_id=1011) select s.snummer,s.achternaam,s.roepnaam, pg.* from pg join student s using(snummer) where grp_num <  100;
rollback ;
\d completed
rollback ;
\d completed
\d completed
create view prc2_completed_20200706 as with pg as (select * from prj_tutor join prj_grp using (prjtg_id) join completed using(grp_num) where prjm_id=1011) select s.snummer,s.achternaam,s.roepnaam, pg.covered,pg.notcovered,pg.notdone from pg join student s using(snummer) where grp_num <  100;
select * from prc2_completed_20200706;
create table prc2_completed_20200706_t as select * from prc2_completed_20200706 order by achternaam,roepnaam;
commit;
copy prc2_completed_20200706_t to '/tmp/prc2_completed_20200706_t.csv' csv header  ;
select * from student where snumer=879215;
rollback ;
select * from student where snummer=879285;
select * from student where snummer=879285;
\d prc2_2020_grades
update prc2_2020_grades set atype='PRC_I' where atype='A';
update prc2_2020_grades set atype='PRCTI' where atype='T';
update prc2_2020_grades set atype='PRCTP' where atype='P';
commit;
table prc2_2020_grades;
\d repositories
table prc2_2020_grades;
\d prc2_2020_grades
alter table public.prc2_2020_grades alter column grade type numeric;
rollback ;
alter table public.prc2_2020_grades alter column grade type numeric(4,1);
rollback ;
alter table public.prc2_2020_grades alter column grade type numeric(4,1) using grade::numeric;
\d prc2_2020_grades
table prc2_2020_grades;
commit;
grant select on prc2_2020_grades to www-data;
rollback ;
grant select on prc2_2020_grades to wwwrun;
commit;
\d
\d+
\u wwwrun
\d
\d+
\d+ prc2_2020_grades
\dt+ prc2_2020_grades
\z 
grant select,reference on prc2_2020_grades to wwwrun;
rollback ;
grant select,references,usage on prc2_2020_grades to wwwrun;
rollback ;
grant select,references on prc2_2020_grades to wwwrun;
commit;
\h grant
grant select,references on prc2_2020_grades to peerweb;
commit;
\d prc2_2020_grades
table prc2_2020_grades
;
update prc2_2020_grades set atype = PRC2||substr(atype,3,2);
rollback ;
update prc2_2020_grades set atype = 'PRC2'||substr(atype,3,2);
table prc2_2020_grades
;
rollback ;
table prc2_2020_grades
;
update prc2_2020_grades set atype = 'PRC2'||substr(atype,3,2);
table prc2_2020_grades
;
rollback ;
\df substr
\df+ substr
update prc2_2020_grades set atype = 'PRC2'||substr(atype,4,2);
table prc2_2020_grades
;
commit;
update prc2_2020_grades set atype='PRC2PI' where atype='PRC2TP';
commit;
table prc2_2020_grades
;
alter table prc2_2020_grades rename to module_grades_2020;
alter prc2_2020_grades rename column atype to module;
rollback ;
alter table prc2_2020_grades rename to module_grades_2020;
alter table prc2_2020_grades alter column atype rename to module;
rollback ;
alter table prc2_2020_grades rename to module_grades_2020;
commit;
\h alter 
alter table prc2_2020_grades rename  atype  to module;
rollback ;
alter table module_grades_2020 rename  column atype  to module;
commit;
\d module_grades_2020 
commit;
\d module_grades_2020 
alter table public.module_grades_2020  drop column name;
commit;
\d module_grades_2020 
table public.module_grades_2020;
insert into module_grades_2020  (snummer,ass,module,grade) select (snummer,ass,module,grade) from passed2019;
rollback ;
\d module_grades_2020
\d passed2019
alter table public.passed2019 alter column grade type numeric(4,1);
commit;
insert into module_grades_2020  (snummer,ass,module,grade) select (snummer,ass,module,grade) from passed2019;
rollback ;
select (snummer,ass,module,grade) from passed2019;
select snummer,ass,module,grade from passed2019;
insert into module_grades_2020  (snummer,ass,module,grade) select snummer,ass,module,grade from passed2019;
commit;
\d module_grades_2020 
alter table public.module_grades_2020 add constraint snummer_mod_un unique(snummer,module); 
commit;
set search_path =importer ,public;
\d
set search_path =importer;
\d
table blad1;
set search_path =importer;
\d
table sv05_aanmelders
;
\d
\d blad1
\d worksheet 
set search_path =importer ;
\d
\d prospects
truncate prospects ;
commit;
truncate prospects ;
truncate prospects ;
\i new_prostpects.sql 
insert into prospects p select * from new_prospects where snummer not in (select snummer from prospects);
rollback ;
\i new_prostpects.sql 
insert into prospects select * from new_prospects where snummer not in (select snummer from prospects);
rollback ;
\d prospects
truncate public.prospects;
rollback ;
select * from prospects;
truncate public.prospects;
\i new_prostpects.sql 
insert into prospects select * from new_prospects;
rollback ;
\i new_prostpects.sql 
\d prospects
rollback;
\d prospects
truncate prospects;
\d prospects
\i new_prospects.sql 
insert into prospects select * from new_prospects;
\d
rollback ;
\d
set search_path =public;
\d
truncate prospects;
\d
insert into prospects select * from new_prospects;
rollback ;
table prospects;
set search_path =public;
rollback ;
set search_path =public;
\d
\i new_prospects.sql 
rollback ;
\d prospects
table  prospects;
insert into prospects select * from new_prospects ;
\d new_prospects
rollback ;
\d new_prospects
select * from new_prospects ;
insert into prospects select * from new_prospects order by 1;
\d prospects
rollback ;
\d prospects
\d new_prospects 
drop table new_prospects ;
\d prospects
drop table new_prospects;
commit;
drop table new_prospects;
commit;
\d new_prospects 
alter table prospects alter COLUMN cohort type integer;
commit;
insert into prospects select * from new_prospects order by 1;
drop table new_prospects;
commit;
insert into prospects select * from new_prospects order by 1;
comit;
commit;
insert into prospects select * from new_prospects order by 1;
commit;
set search_path =importer;
truncate table sv05_aanmelders ;
commit;
\i sv05_aanmelders.sql
set search_path =importer;
truncate table sv05_aanmelders ;
\i sv05_aanmelders.sql
commit;
\s sv05_aanmelders
\d sv05_aanmelders
\d
set search_path =importer;
\d
truncate table sv05_aanmelders ;
\d
\i sv05_aanmelders.sql
set search_path =importer;
truncate table sv05_aanmelders ;
\i sv05_aanmelders.sql
\d
rollback ;
\d
drop table sv05_aanmelders ;
commit;
set search_path =importer;
\d
select count(1) from sv05_aanmelders;
drop table sv05_20190829;
drop table blad1;
drop table worksheet;
commit;
\i sv05_aanmelders.sql
\d
select snummer from student where opl=112 and cohort=2004;
\o p
select snummer from student where opl=112 and cohort=2004;
\a
\t
\o p
select snummer from student where opl=112 and cohort=2004;
select snummer from student where opl=112 and cohort=2005;
\a
\t
\o p
select snummer from student where opl=112 and cohort=2005;
\d prospect
\d prospects
\d klassen_1_20200824
alter klassen_1_20200824 rename column studnr to snummer;
rollback ;
alter table klassen_1_20200824 rename column studnr to snummer;
\d klassen_1_20200824
commit;
\d prospects
\i update_prospects_for_klass.sql
rollback ;
\d klassen_1_20200824
\d prospect
\d prospects
\i update_prospects_for_klass.sql
rollback ;
\i update_prospects_for_klass.sql
rollback ;
\i update_prospects_for_klass.sql
\i update_prospects_for_klass.sql
commit;
insert into student select * from prospects p where class_id <> 0 and snummer not exists (select 1  from student where snummer=p.snummer);
rollback ;
insert into student select * from prospects p where class_id <> 0 and not exists (select 1  from student where snummer=p.snummer);
\d student 
rollback ;
\d student 
\d prospects
\e
rollback ;
\i update_prospects_for_klass.sql
rollback ;
\i update_prospects_for_klass.sql
\i update_prospects_for_klass.sql
\i insert_prospects_inf1_20200824.sql
\i insert_prospects_inf1_20200824.sql
\i insert_prospects_inf1_20200824.sql
commit;
\d passwd
insert into passwd (userid, capabilities, password) select snummer,4096+2048,'No password' form student where class_id in (1753,1754,1755);
rollback ;
insert into passwd (userid, capabilities, password) select snummer,4096+2048,'No password' from student where class_id in (1753,1754,1755);
commit;
update student set class_id =1753 where snummer in (select snummer from klassen_1_20200824 where class_id=1753);
update student set class_id =1754 where snummer in (select snummer from klassen_1_20200824 where class_id=1754);
update student set class_id =1755 where snummer in (select snummer from klassen_1_20200824 where class_id=1755);
insert into passwd (userid, capabilities, password) select snummer,4096+2048,'No password' from student where class_id in (1753,1754,1755);
rollback ;
insert into passwd (userid, capabilities, password) select snummer,4096+2048,'No password' from student where class_id in (1753,1754,1755) and snummer not in (select userid from passwd);
commit;
update student set slb=874001 where class_id in (1753,1754,1755);
commit;
select * from klassen_1_20200824 where snummer not in (select snummer from prospects);
delete from prj_grp where prjtg_id in (select prjtg_id from prj_tutor where prjm_id=1033);
commit;
\d prc1grps
select snummer,prjtg_id from public.prc1grps;
insert into prj_grp (snummer,prjtg_id) select snummer,prjtg_id from public.prc1grps;
commit;
\d sv05_aanmelders
select opleiding, pasfoto_uploaddatum from sv05_aanmelders where aanmeldingsstatus in ('Ingeschreven');
rollback ;
select opleiding, pasfoto_uploaddatum from sv05_aanmelders where aanmeldingstatus in ('Ingeschreven');
table puk2;
drop table puk;
drop table puk2;
commit;
drop table puk2;
drop table puk2;
commit;
drop table puk;
insert into prj_grp (snummer,prjtg_id) select snummer,10957 from puk2;
commit;
select snummer,11209 from missing_noobs_t ;
select snummer,11209 as prjtg_id  from missing_noobs_t ;
insert into prj_grp select snummer,11209 as prjtg_id  from missing_noobs_t ;
rollback ;
insert into prj_grp (snummer,prjtg_id) select snummer,11209 as prjtg_id  from missing_noobs_t ;
commit;
create view INF1_A as select snummer,achternaam,roepnaam from student where class_id=400;
commit;
create view mooc_wk2 as select snummer, achternaam, roepnaam, part1, part2 from mooc_2020_stats natural join inf1_a;
rollback ;
create view mooc_wk2 as select snummer, achternaam, roepnaam, part01, part02 from mooc_2020_stats natural join inf1_a;
select * from mooc_wk2;
select * from mooc_wk2;
create view INF1_A as select snummer,achternaam,roepnaam from student where class_id=400;
rollback ;
create view INF1_A as select snummer,achternaam,roepnaam from student where class_id=400;
rollback ;
create view mooc_wk2 as select snummer, achternaam, roepnaam, part01, part02 from mooc_2020_stats natural join inf1_a;
commit;
copy (select * from mooc_wk2)  to stdout;
copy (select * from mooc_wk2)  csv header to stdout;
rollback ;
copy (select * from mooc_wk2)  csv header to stdout;
rollback ;
\o put
\a
select * from mooc_wk2;
\s
create view INF1_B as select snummer,achternaam,roepnaam from student where class_id=401;
create view mooc_wk2 as select snummer, achternaam, roepnaam, part01, part02 from  inf1_b left natural join mooc_2020_stats ;
rollback ;
create view mook_b_wk2 as select snummer,achternaam,roepnaam from student where class_id=401;
commit;
create view mooc_b_wk2 as select snummer, achternaam, roepnaam, part01, part02 from  inf1_b left natural join mooc_2020_stats ;
rollback ;
create view mooc_b_wk2 as select snummer, achternaam, roepnaam, part01, part02 from  inf1_b natural left join mooc_2020_stats ;
commit;
select * from  mooc_b_wk2;
\a
\f ','
\u puk
\o puk.csv
select * from  mooc_b_wk2;
create view INF1_C as select snummer,achternaam,roepnaam from student where class_id=1568;
commit;
create view mooc_c_wk2 as select snummer, achternaam, roepnaam, part01, part02 from  inf1_c natural left join mooc_2020_stats ;
select * from mooc_c_wk2mooc_c_wk2;
select * from mooc_c_wk2mooc_c_wk2;ro ;
rollback ;
create view mooc_c_wk2 as select snummer, achternaam, roepnaam, part01, part02 from  inf1_c natural left join mooc_2020_stats ;
commit;
select * from mooc_c_wk2;
\a
\f ','
\o mooc_c_wk2
select * from mooc_c_wk2;
\d
delete from prj_grp where prj_tg_id in (select prjtg_id from prj_tutor where prjm_id=1039);
rollback ;
delete from prj_grp where prjtg_id in (select prjtg_id from prj_tutor where prjm_id=1039);
commit;
\d mooc*
select snummer from mooc_20200916;
select last_name, snummer from mooc_20200916;
select snummer from student where class_id in (400,401,1568) and snummer not in (select snummer from mooc_20200619);
rollback ;
select snummer from student where class_id in (400,401,1568) and snummer not in (select snummer from mooc_20200916);
\d mooc_20200916
select snummer from student s where class_id in (400,401,1568) and  not exists (select s.snummer=snummer from mooc_20200916);
\d
\s
\d missing_noobs_t 
\dv missing_noobs_t 
\dv missing_noobs
\d missing_noobs_t 
select m.snummer,m.last_name, from mooc_20200916 m natural join student s;
rollback ;
select m.snummer,m.last_name,snummer from mooc_20200916 m natural join student s;
create table inmooc as select m.snummer from mooc_20200916 m natural join student s;
commit;
select snummer from student s where class_id in (400,401,1568) and  not exists (select s.snummer=snummer from inmooc);
select snummer from student s where class_id in (400,401,1568) and  not exists (select 1 from inmooc where s.snummer=snummer);
\s
insert into prj_grp (snummer,prjtg_id) select snummer,11209 from student s where class_id in (400,401,1568) and  not exists (select 1 from inmooc where s.snummer=snummer);
commit;
create table inmooc as select m.snummer from mooc_20200916 m natural join student s;
drop table inmooc;
rollback ;
create table inmooc as select m.snummer from mooc_20200916 m natural join student s;
rollback ;
rollback ;
create or replace table inmooc as select m.snummer from mooc_20200916 m natural join student s;
rollback ;
truncate inmooc;
insert into inmooc (snummer) select m.snummer from mooc_20200916 m natural join student s;
commit;
\s
delete from prj_grp where prjtg_id in (select prjtg_id from prj_tutor where prjm_id=1039);
insert into prj_grp (snummer,prjtg_id) select snummer,11209 from student s where class_id in (400,401,1568) and  not exists (select 1 from inmooc where s.snummer=snummer);
commit;
\d mooc*
\d mooc
\d mooc
drop table mooc;
commit;
drop table mooc_20200916 ;
commit;
\d mooc_2020_stats;
\dv mooc_*
\dv+ mooc_*
\d
create table mooc_2020 as select * from mooc_20200923;
commit;
delete from mooc_2020 where snummer not in (select snummer from student where class_id in (400,401,1568));
commit;
select distinct snummer from mooc_2020;
select snummer from mooc_2020 group by snummer having count(1) > 1;
delete from mooc_2020 where snummer isnull;
commit;
select snummer from mooc_2020 group by snummer having count(1) > 1;
\s
select snummer,achternaam,roepnaam, tussenvoegsel, email1, sclass, part01,part02,part03,part04 from mooc_2020 natural join student natural join student_class;
\s puk
\s history.pgsql
