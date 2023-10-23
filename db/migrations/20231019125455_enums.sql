-- migrate:up

CREATE TYPE aktivitet AS enum(
    'elfiske'
);

CREATE TYPE livsfaser AS enum(
    'ungfisk',
    'presmolt',
    'smolt',
    'voksenfisk',
    'gytefisk',
    'fiskesamfunn'
);

CREATE TYPE artsdannelse AS enum(
    'sympatrisk',
    'allopatrisk'
);

CREATE TYPE kvalitativ_vannforing AS enum(
    'lav',
    'middels',
    'høy'
);

CREATE TYPE metode AS enum(
    'kvantitativ',
    'kvalitativ'
);

CREATE TYPE frekvens AS enum(
    'lav',
    'høy'
);

CREATE TYPE havtype AS enum(
    'liten',
    'stor'
);

CREATE TYPE vaerforhold AS enum(
    'sol',
    'overskyet',
    'vind',
    'regn',
    'skiftende'
);

CREATE TYPE sikt_vann AS enum(
    'klart',
    'middels',
    'uklart'
);

CREATE TYPE elveklasse AS enum(
    'grunnområde',
    'glattstrøm',
    'strykt'
);

CREATE TYPE substrat AS enum(
    'silt',
    'grus',
    'stein_1',
    'stein_2',
    'storstein_blokk'
);

CREATE TYPE gjenklogging AS enum(
    'delvis',
    'ingen',
    'helt'
);

CREATE TABLE egnet_gytesubstrat(
    id int primary key,
    verdi varchar
);

INSERT INTO egnet_gytesubstrat(verdi, id) VALUES
    ('ingen', 0),
    ('dårlig', 1),
    ('middels', 2),
    ('bra', 3);

GRANT SELECT, INSERT ON egnet_gytesubstrat TO writer;


CREATE TABLE kantvegetasjon(
    verdi varchar PRIMARY KEY
);

GRANT SELECT, INSERT ON kantvegetasjon TO writer;

GRANT SELECT ON kantvegetasjon TO web_anon;

CREATE TYPE fisketype AS enum(
    'villfisk',
    'kultivert',
    'oppdrett',
    'villfisk_kultivert',
    'oppdrett_kultivert'
);

CREATE TYPE kjonn AS enum(
    'hann',
    'hunn'
);

CREATE TABLE kjonn_stadium(
    id int PRIMARY KEY,
    verdi text unique
);

GRANT SELECT ON kjonn_stadium TO writer;

GRANT SELECT ON kjonn_stadium TO web_anon;

INSERT INTO kjonn_stadium VALUES
    (1, 'gjeldfisk'),
    (2, ''),
    (3, 'gonaden oppsvulmet, nesten halvdelen så lang som bukhulen'),
    (4, 'gonaden fyller 4/5 av bukhulen'),
    (5, 'gonaden fyller bukhulen, ikke løs'),
    (6, 'gytende. gonaden fyller bukhulen, løs'),
    (7, 'utgytt'),
    (8, 'gjeldfisk2'), -- this was modified to be unique
    (9, 'gytefisk'),
    (10, 'utgytt2'), -- this was modified to be unique
    (72, 'gytt tidligere. start av gonadeutvikling'),
    (73, 'gytt tidligere. gonaden oppsvulmet, nesten halvdelen så lang som bukhulen'),
    (74, 'gytt tidligere. gonaden fyller 4/5 av bukhulen'),
    (75, 'gytt tidligere. gonaden fyller bukhulen, ikke løs'),
    (999, 'usikker')
;

CREATE TYPE merketype AS enum(
    'PIT',
    'Floy',
    'Carlin',
    'Lea',
    'Finneklipp',
    'Otolitt'
);

-- migrate:down