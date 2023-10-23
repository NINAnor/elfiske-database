-- migrate:up

create table enkeltfisker (
    id serial primary key,
    observasjon int references observasjoner(id),
    elfiskeomgang int null,
    lopenr int null,
    art varchar references arter(navn),
    type fisketype null,
    lengde_total int null,
    lengde_gaffel int null,
    vekt int null,
    kjonn kjonn null,
    kjonn_stadium varchar null references kjonn_stadium(verdi),
    tilordnet_alder_lengde int default 0,
    tilordnet_alder_av text null,
    avlest_alder_skjell int null,
    avlest_alder_otolitt int null,
    alder_avlest_av text null,
    gjenutsatt boolean null,
    merkenr int null,
    merketype merketype null,
    merknader text null,
    unique(lopenr, observasjon)
);

grant select, insert on enkeltfisker to writer;
grant select on enkeltfisker to web_anon;
grant usage on sequence enkeltfisker_id_seq to writer;

-- migrate:down

drop table enkeltfisker;
