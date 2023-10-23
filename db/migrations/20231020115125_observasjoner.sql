-- migrate:up

create table observasjoner (
    id serial primary key,
    aktivitet int references aktiviteter(id),
    stasjon int references stasjoner(id),
    dato timestamp null,
    malt_vannforing text null,
    kvalitativ_vannforing kvalitativ_vannforing null,
    metode metode null,
    hele_bredde_avfisket boolean null,
    total_bredde_pa_stedet int null,
    evt_torrfall int null,
    type_apparat varchar null,
    stromstyrke int null,
    frekvens frekvens null,
    havtype havtype null,
    vaerforhold vaerforhold null,
    dyp_maks int null,
    dyp_middels int null,
    vanntemperatur decimal(3,1) null,
    lufttemperatur decimal(3,1) null,
    sikt_vann sikt_vann null,
    elveklasse elveklasse null,
    substrat substrat[] null,
    gjenklogging gjenklogging null,
    egnet_gytesubstrat int null references egnet_gytesubstrat(id),
    dekningsgrad_moser_percent int null,
    dekningsgrad_alger_percent int null,
    kantvegetasjon varchar null references kantvegetasjon(verdi),
    dekningsgrad_overhengende_vegetasjon int null,
    andre_lokale_forhold text null,
    ledningsevne int null,
    ph int null,
    vat_bredde int null,
    merknader text null,
    unique(aktivitet, stasjon, dato)
);

grant select, insert on observasjoner to writer;
grant select on observasjoner to web_anon;
grant usage on sequence observasjoner_id_seq to writer;

-- migrate:down

drop table observasjoner;
