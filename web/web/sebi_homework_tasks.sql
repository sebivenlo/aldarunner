begin work;

drop table if exists public.sebi_homework_tasks;
CREATE TABLE public.sebi_homework_tasks (
    sebi_homework_task_id serial primary key,
    prjm_id integer not null,
    grp_num integer not null,
    task text not null,
    tested_at timestamp with time zone not null default now(),
    revision integer not null,
    tests integer not null default 0,
    passed integer not null default 0,
    fails integer not null default 0,
    errs integer not null default 0,
    skips integer not null default 0,
    test_time real not null default 0,
    coverage_percent integer not null default 0,
    unique (grp_num, task)
);


ALTER TABLE public.sebi_homework_tasks OWNER TO hom;

--
-- PostgreSQL database dump complete
--

commit;
