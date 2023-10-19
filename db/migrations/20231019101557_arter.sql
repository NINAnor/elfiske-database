-- migrate:up

create table import_arter (
    "Art_formID" int not null,
    "Art_form" char(255) not null
);

create table arter (
    id int not null primary key,
    navn char(255) not null
);

-- needed for conflict resolution
grant select, insert on import_arter to writer;
grant select, insert on arter to writer;
grant select on arter to web_anon;


create function import_arter() returns trigger language plpgsql
as $$
begin
    insert into arter values(
        new."Art_formID",
        new."Art_form"
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

create trigger import_arter
    before insert on import_arter
    for each row
    execute function import_arter();

-- migrate:down
