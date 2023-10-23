-- migrate:up


create table vassdrag (
    id varchar primary key,
    navn varchar null,
    hoved_id varchar null references vassdrag(id)
);

grant select, insert on vassdrag to writer;
grant select on vassdrag to web_anon;

create table stasjoner (
    id serial primary key,
    loknr varchar,
    vassdrag varchar references vassdrag(id),
    lokalitetnavn varchar,
    lokangivelse text null,
    beskrivelse_lokalitet text,
    koordinater geometry(point) null,
    artsdannelse artsdannelse,
    anadrom boolean null,
    lengde int null,
    bredde int null,
    merknader text null,
    UNIQUE (loknr, vassdrag)
);

grant select, insert on stasjoner to writer;
grant select on stasjoner to web_anon;

grant select, usage on stasjoner_id_seq to writer;

-- migrate:down

drop table stasjoner;
drop table vassdrag;
