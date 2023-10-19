-- migrate:up

create table import_redskaper (
    "RedskapID" int not null,
    "Redskap" char(255) not null
);

create table redskaper (
    id int not null primary key,
    navn char(255) not null
);

-- needed for conflict resolution
grant select, insert on import_redskaper to writer;
grant select, insert on redskaper to writer;
grant select on redskaper to web_anon;


create function import_redskaper() returns trigger language plpgsql
as $$
begin
    insert into redskaper values(
        new."RedskapID",
        new."Redskap"
    ) on conflict do nothing;
    return null;
exception
    when others then
        raise exception using
            errcode = sqlstate,
            message = sqlerrm,
            detail = new;
end;
$$;

create trigger import_redskaper
    before insert on import_redskaper
    for each row
    execute function import_redskaper();

-- migrate:down
