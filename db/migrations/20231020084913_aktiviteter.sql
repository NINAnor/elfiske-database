-- migrate:up

create table aktiviteter (
    id serial primary key,
    feltoperasjonsnr varchar null,
    fagansvarlig_organisasjon varchar null,
    prosjektleder varchar null,
    aktivitet aktivitet default 'elfiske',
    aktivitet_beskrivelse text null,
    redskap varchar null references redskaper(navn),
    livsfaser livsfaser null,
    prosjektnr int null,
    prosjektnanv varchar null,
    feltoperator varchar null,
    kontaktpersoner text null,
    fangstperiodedefinisjoner text null,
    oppdragsgivere text null,
    tilskuddgivere text null,
    merknader text null
);

grant select, insert on aktiviteter to writer;
grant select on aktiviteter to web_anon;
grant usage on sequence aktiviteter_id_seq to writer;

-- migrate:down

drop table aktiviteter;
