-- migrate:up
create function range_solver(text_range text)
returns int
language plpgsql
as $$
begin
    case text_range 
        when '1-33' then return 33; 
        when '34-66' then return 66; 
        when '>66' then return 99; 
        else return 0; 
    end case;
end;
$$;

create function as_norsk_bool(string text)
returns boolean
language plpgsql
as $$
begin
    case lower(string)
        when 'ja' then return true; 
        else return false; 
    end case;
end;
$$;

create function create_aktivitet(data jsonb) 
returns int 
language plpgsql
as $$
declare
    aktivitet_id int;
begin
    insert into aktiviteter(
        feltoperasjonsnr,
        fagansvarlig_organisasjon,
        prosjektleder,
        aktivitet,
        aktivitet_beskrivelse,
        redskap,
        livsfaser,
        prosjektnr,
        prosjektnanv,
        feltoperator,
        kontaktpersoner,
        fangstperiodedefinisjoner,
        oppdragsgivere,
        tilskuddgivere,
        merknader
    ) values (
        data->>'Feltoperasjonsnr',
        data->>'Fagansvarlig organisasjon',
        data->>'Prosjektleder',
        lower(data->>'Aktivitet')::aktivitet,
        data->>'Aktivitetsbeskrivelse',
        lower(data->>'Redskap'),
        lower(data->>'Livsfaser')::livsfaser,
        (data->>'Prosjektnr')::int,
        data->>'Prosjektnavn',
        data->>'Feltoperator',
        data->>'Kontaktpersoner',
        data->>'Fangstperiodedefinisjoner',
        data->>'Oppdragsgivere',
        data->>'Tilskuddsgivere',
        data->>'Merknader'
    ) returning id into aktivitet_id;
    return aktivitet_id;
end;
$$;


create function create_vassdragg(data jsonb) 
returns void
language plpgsql
as $$
begin
    insert into vassdrag(
        id,
        navn
    ) values (
        data->>'Vassdragsnummer hovedvassdrag',
        data->>'Vassdragsnavn'
    ) on conflict do nothing;
    insert into vassdrag(
        id,
        navn,
        hoved_id
    ) values (
        data->>'Vassdragsnummer',
        data->>'Vassdragsnavn',
        data->>'Vassdragsnummer hovedvassdrag'
    ) on conflict do nothing;
end;
$$;

create function create_stasjon(data jsonb) 
returns void
language plpgsql
as $$
declare 
    epsg_description varchar;
    epsg int;
begin
    select concat(upper(data->>'UTM_datum'), '-', upper(data->>'UTM_sone')) into epsg_description;
    case epsg_description
        when 'WGS 84-32V' then
            epsg := 32632;
        else
            raise exception '% not supported', epsg_description;
    end case;
    insert into stasjoner(
        vassdrag,
        loknr,
        lokalitetnavn,
        lokangivelse,
        beskrivelse_lokalitet,
        koordinater,
        artsdannelse,
        anadrom,
        lengde,
        bredde,
        merknader
    ) values (
        data->>'Vassdragsnummer',
        data->>'Loknr',
        data->>'Lokalitetsnavn',
        data->>'Lokangivelse',
        data->>'Beskrivelse_lokalitet',
        ST_SetSRID(
            ST_MakePoint(
                (data->>'Øst')::int,
                (data->>'Nord')::int
            ), 
            epsg
        ), 
        lower(data->>'Allopatrisk_Sympatrisk')::artsdannelse,
        as_norsk_bool(data->>'Anadrom'),
        (data->>'Stasjon_lengde')::int,
        (data->>'Stasjon_bredde')::int,
        data->>'Merknader'
    ) on conflict do nothing;
end;
$$;

create function create_observasjon(data jsonb, aktivitet_id int) 
returns void
language plpgsql
as $$
declare 
    stasjon_id int;
    substrater substrat[];
begin
    select id into stasjon_id from stasjoner as st where st.vassdrag = data->>'Vassdragsnummer' and st.loknr = data->>'Loknr';

    if data->>'Substrat_1' then
        substrater := substrater || lower(data->>'Substrat_1')::substrat;
    end if;

    if data->>'Substrat_2' then
        substrater := substrater || lower(data->>'Substrat_2')::substrat;
    end if;

    insert into kantvegetasjon values (lower(data->>'Kantvegetasjon')) on conflict do nothing;

    insert into observasjoner(
        aktivitet,
        stasjon,
        dato,
        malt_vannforing,
        kvalitativ_vannforing,
        metode,
        hele_bredde_avfisket,
        total_bredde_pa_stedet,
        evt_torrfall,
        type_apparat,
        stromstyrke,
        frekvens,
        havtype,
        vaerforhold,
        dyp_maks,
        dyp_middels,
        vanntemperatur,
        lufttemperatur,
        sikt_vann,
        elveklasse,
        substrat,
        gjenklogging,
        egnet_gytesubstrat,
        dekningsgrad_moser_percent,
        dekningsgrad_alger_percent,
        kantvegetasjon,
        dekningsgrad_overhengende_vegetasjon,
        andre_lokale_forhold,
        ledningsevne,
        ph,
        vat_bredde,
        merknader
    ) values (
        aktivitet_id,
        stasjon_id,
        to_date(data->>'Dato', 'DD.MM.YY')::timestamp,
        data->>'Målt_Vannføring',
        lower(data->>'Kvalitativ_vannføring')::kvalitativ_vannforing,
        lower(data->>'Metode')::metode,
        as_norsk_bool(data->>'Hele_bredde_avfisket'),
        (data->>'Total_bredde_på_stedet')::int,
        (data->>'Evt_tørrfall')::int,
        data->>'Type_apparat',
        (data->>'Strømstyrke')::int,
        lower(data->>'Frekvens')::frekvens,
        lower(data->>'Håvtype')::havtype,
        lower(data->>'Værforhold')::vaerforhold,
        (data->>'Dyp_maks')::int,
        (data->>'Dyp_middels')::int,
        cast(replace(data->>'Vanntemperatur', ',', '.') as decimal(3,1)),
        cast(replace(data->>'Lufttemperatur', ',', '.') as decimal(3,1)),
        lower(data->>'Sikt_vann')::sikt_vann,
        lower(data->>'Elveklasse')::elveklasse,
        substrater,
        lower(data->>'Gjenklogging')::gjenklogging,
        lower(data->>'Egnet gytesubstrat')::int,
        range_solver(data->>'Dekningsgrad % Alger'),
        range_solver(data->>'Dekningsgrad % Moser'),
        lower(data->>'Kantvegetasjon'),
        range_solver(data->>'Dekningsgrad % Overhengende vegetasjon'),
        data->>'Andre_lokale_forhold',
        (data->>'Ledningsevne')::int,
        (data->>'pH')::int,
        (data->>'Våt_bredde')::int,
        data->>'Merknader2'        
    );
end;
$$;

create function create_enkeltfisk(data jsonb, aktivitet_id int) 
returns void
language plpgsql
as $$
declare 
    observasjon_id int;
    stasjon_id int;
begin
    select id into stasjon_id from stasjoner as st where st.vassdrag = data->>'Vassdragsnummer' and st.loknr = data->>'Loknr';
    select id into observasjon_id from observasjoner as ob where ob.aktivitet = aktivitet and ob.stasjon = stasjon_id and ob.dato = to_date(data->>'Dato', 'DD.MM.YY')::timestamp;

    insert into enkeltfisker(
        observasjon,
        elfiskeomgang,
        lopenr,
        art,
        type,
        lengde_total,
        lengde_gaffel,
        vekt,
        kjonn,
        kjonn_stadium,
        tilordnet_alder_lengde,
        tilordnet_alder_av,
        avlest_alder_skjell,
        avlest_alder_otolitt,
        alder_avlest_av,
        gjenutsatt,
        merkenr,
        merketype,
        merknader
    ) values (
        observasjon_id,
        (data->>'Elfiskeomgang')::int,
        (data->>'Lopenr')::int,
        lower(data->>'Art'),
        lower(data->>'Type')::fisketype,
        (data->>'Lengde_total')::int,
        (data->>'Lengde_gaffel')::int,
        (data->>'Vekt')::int,
        lower(data->>'Kjønn')::kjonn,
        lower(data->>'Kjønn_stadium'),
        (data->>'Tilordnet_alder_lengde')::int,
        (data->>'Tilordnet_alder_av'),
        (data->>'Avlest_alder_skjell')::int,
        (data->>'Avlest_alder_otolitt')::int,
        (data->>'Alder_avlest_av'),
        as_norsk_bool(data->>'Gjenutsatt'),
        (data->>'Merkenr')::int,
        (data->>'Merketype')::merketype,        
        data->>'Merknader'        
    );
end;
$$;


create function import_data(data json) 
returns void 
language plpgsql 
as $$
declare
    aktivitet_id int;    
begin
    select create_aktivitet((data->'metadata'->0)::jsonb) into aktivitet_id;
    perform create_vassdragg((data->'metadata'->0)::jsonb);
    perform create_stasjon(value) from jsonb_array_elements((data->'stasjoner')::jsonb) where value->>'Vassdragsnummer' is not null;
    perform create_observasjon(value, aktivitet_id) from jsonb_array_elements((data->'stasjoner')::jsonb) where value->>'Vassdragsnummer' is not null;
    perform create_enkeltfisk(value, aktivitet_id) from jsonb_array_elements((data->'enkeltfisk')::jsonb);
end;
$$;

grant execute on function import_data to writer;
grant execute on function create_aktivitet to writer;
grant execute on function create_vassdragg to writer;
grant execute on function create_stasjon to writer;
grant execute on function create_observasjon to writer;
grant execute on function range_solver to writer;
grant execute on function as_norsk_bool to writer;
grant execute on function create_enkeltfisk to writer;

-- migrate:down

drop function import_data;
drop function create_aktivitet;
drop function create_vassdragg;
drop function create_stasjon;
drop function create_observasjon;
drop function range_solver;
drop function as_norsk_bool;
drop function create_enkeltfisk;
