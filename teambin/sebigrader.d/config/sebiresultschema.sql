begin work;
create extension if not exists tablefunc;

drop table if exists questions cascade;
drop table if exists scores  cascade;
drop table if exists exam_candidates cascade;
drop table if exists students cascade;


create table questions (
       question_id serial primary key,
       event text not null,
       question_nr integer not null,
       cat char(1) not null,
       test_method text not null,
       comment text,
       weight integer not null default 1,
       unique(event,test_method)
);

create table scores (
       score_id serial primary key,
       -- event text,
       stick_nr integer not null,
       question_id integer not null references questions(question_id) on delete cascade,
       pass_fail char(1) not null,
       score numeric(3,1) not null,
       remark text,
       unique(stick_nr,question_id)
);




create table students (
       snummer integer primary key,      
       achternaam text not null,
       roepnaam text not null,
       sclass text not null,
       voorletters text not null,
       lang text not null,
       prjm_id integer not null,
       alias text not null,
       token text not null,
       cohort integer not null,
       email1 text not null,
       education text not null,
       lo integer not null default 0
       
);

create table exam_candidates(
       candidate_id serial primary key,
       event text not null,
       stick_nr integer not null,
       snummer integer not null references students(snummer)
);

drop view if exists resultview cascade;
create view resultview as
  select snummer,'q'||question_nr as question, coalesce(score,0) as score
  from exam_candidates ec join questions q using (event)
       left join scores using (question_id,stick_nr)
       order by snummer,question_nr;


create or replace function assessment_score_def (myevent text) returns text
as $assessment_score_def$
declare 
th text;
begin
  select array_agg(cat||question_nr||' numeric') into strict th 
  from (select question_nr,cat from questions where event=myevent order by question_nr) qq;
  return 'snummer integer,stick_nr integer,'||regexp_replace(th,'[}"{]','','g');
end;
$assessment_score_def$ language 'plpgsql';

create or replace function assessment_score_query4( myevent text) returns text
as $assessment_score_query4$
declare
  th1 text;
  th2 text;
begin
  th1 := assessment_score_def (myevent);
  
  th2 := '
  crosstab(
  ''
  select snummer, stick_nr, question_nr,coalesce(score,1.0) score
  from exam_candidates ec
  join questions q using (event)
  left join scores sc using(stick_nr,question_id)
  where ec.event='''''||myevent||''''' order by stick_nr,question_nr
  '',

  ''
  select question_nr from questions aqs where aqs.event='''''||myevent||''''' order by question_nr
  ''
  ) as ct('||th1||') ';
  return th2;
end; $assessment_score_query4$ 
language 'plpgsql';


commit;
