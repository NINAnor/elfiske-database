-- migrate:up

create table redskaper (
    id int not null primary key,
    navn char(255) not null unique
);

-- needed for conflict resolution
grant select, insert on redskaper to writer;
grant select on redskaper to web_anon;

insert into redskaper(navn, id) values 
('bunngarn', 36),
('dorg', 21),
('drivgarn', 35),
('drivtelling', 101),
('elapparat', 57),
('elfiskebåt', 58),
('felle', 94),
('fisk funnet død', 92),
('fiskemerke funnet uten fisk', 93),
('flytegarn', 32),
('flyteline', 53),
('flåtefiske', 45),
('fotocelleteller', 76),
('fotocelleteller med kamera', 77),
('garn_uspesifisert', 30),
('gibb', 44),
('harpun', 96),
('håv', 55),
('infrarød fotocelleteller', 78),
('infrarød fotocelleteller med kamera', 79),
('kamera', 73),
('kastenot', 43),
('kilenot', 41),
('krokgarn', 31),
('ledningsevneteller', 74),
('ledningsevneteller med kamera', 75),
('line', 52),
('lys og håv', 56),
('makrellgarn', 34),
('mekanisk fisketeller', 71),
('mekanisk fisketeller med kamera', 72),
('nedgangsfelle', 62),
('not_uspesifisert', 40),
('observasjon', 100),
('oppgangsfelle', 61),
('oter', 11),
('predator', 91),
('rotenon', 81),
('ruse', 51),
('settegarn', 33),
('sitjenot_lakseverpe', 42),
('stang og håndsnøre', 1),
('stengsel', 54),
('teine', 50),
('trapp', 95),
('ålehus/ålekiste for nedvandrende ål', 64),
('åleleder for oppvandrende ål', 63);

-- migrate:down
create table redskaper;