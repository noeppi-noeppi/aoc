CREATE TABLE input (
    line_number SERIAL PRIMARY KEY NOT NULL,
    line_text   TEXT NOT NULL
);

COPY input (line_text) FROM '/aocinput.txt';

CREATE TABLE batteries (
    bank_id  INTEGER NOT NULL,
    position INTEGER NOT NULL,
    joltage  BIGINT NOT NULL,
    PRIMARY KEY (bank_id, position)
);

INSERT INTO batteries(bank_id, position, joltage)
SELECT
    input.line_number,
    chars.idx,
    cast(chars.chr AS BIGINT)
FROM input
JOIN LATERAL (SELECT row_number() OVER (), * FROM regexp_split_to_table(input.line_text, '')) AS chars(idx, chr) ON true;

CREATE TABLE bank_sizes (
    bank_id INTEGER PRIMARY KEY NOT NULL,
    size    INTEGER NOT NULL
);
INSERT INTO bank_sizes(bank_id, size) SELECT batteries.bank_id, count(batteries.position) FROM batteries GROUP BY batteries.bank_id;

CREATE TABLE sel1 (bank_id INTEGER PRIMARY KEY NOT NULL, position INTEGER NOT NULL, joltage BIGINT NOT NULL);
CREATE TABLE sel2 (bank_id INTEGER PRIMARY KEY NOT NULL, position INTEGER NOT NULL, joltage BIGINT NOT NULL);
CREATE TABLE sel3 (bank_id INTEGER PRIMARY KEY NOT NULL, position INTEGER NOT NULL, joltage BIGINT NOT NULL);
CREATE TABLE sel4 (bank_id INTEGER PRIMARY KEY NOT NULL, position INTEGER NOT NULL, joltage BIGINT NOT NULL);
CREATE TABLE sel5 (bank_id INTEGER PRIMARY KEY NOT NULL, position INTEGER NOT NULL, joltage BIGINT NOT NULL);
CREATE TABLE sel6 (bank_id INTEGER PRIMARY KEY NOT NULL, position INTEGER NOT NULL, joltage BIGINT NOT NULL);
CREATE TABLE sel7 (bank_id INTEGER PRIMARY KEY NOT NULL, position INTEGER NOT NULL, joltage BIGINT NOT NULL);
CREATE TABLE sel8 (bank_id INTEGER PRIMARY KEY NOT NULL, position INTEGER NOT NULL, joltage BIGINT NOT NULL);
CREATE TABLE sel9 (bank_id INTEGER PRIMARY KEY NOT NULL, position INTEGER NOT NULL, joltage BIGINT NOT NULL);
CREATE TABLE sel10 (bank_id INTEGER PRIMARY KEY NOT NULL, position INTEGER NOT NULL, joltage BIGINT NOT NULL);
CREATE TABLE sel11 (bank_id INTEGER PRIMARY KEY NOT NULL, position INTEGER NOT NULL, joltage BIGINT NOT NULL);
CREATE TABLE sel12 (bank_id INTEGER PRIMARY KEY NOT NULL, position INTEGER NOT NULL, joltage BIGINT NOT NULL);

INSERT INTO sel1 (bank_id, position, joltage)
SELECT DISTINCT ON (batteries.bank_id) batteries.bank_id, batteries.position, batteries.joltage
    FROM batteries
    INNER JOIN bank_sizes ON batteries.bank_id = bank_sizes.bank_id
    WHERE batteries.position <= bank_sizes.size - 11
    ORDER BY bank_id ASC, batteries.joltage DESC, batteries.position ASC;

INSERT INTO sel2 (bank_id, position, joltage)
SELECT DISTINCT ON (batteries.bank_id) batteries.bank_id, batteries.position, batteries.joltage
    FROM batteries
    INNER JOIN bank_sizes ON batteries.bank_id = bank_sizes.bank_id
    INNER JOIN sel1 ON batteries.bank_id = sel1.bank_id
    WHERE batteries.position <= bank_sizes.size - 10 AND batteries.position > sel1.position
    ORDER BY bank_id ASC, batteries.joltage DESC, batteries.position ASC;

INSERT INTO sel3 (bank_id, position, joltage)
SELECT DISTINCT ON (batteries.bank_id) batteries.bank_id, batteries.position, batteries.joltage
    FROM batteries
    INNER JOIN bank_sizes ON batteries.bank_id = bank_sizes.bank_id
    INNER JOIN sel2 ON batteries.bank_id = sel2.bank_id
    WHERE batteries.position <= bank_sizes.size - 9 AND batteries.position > sel2.position
    ORDER BY bank_id ASC, batteries.joltage DESC, batteries.position ASC;

INSERT INTO sel4 (bank_id, position, joltage)
SELECT DISTINCT ON (batteries.bank_id) batteries.bank_id, batteries.position, batteries.joltage
    FROM batteries
    INNER JOIN bank_sizes ON batteries.bank_id = bank_sizes.bank_id
    INNER JOIN sel3 ON batteries.bank_id = sel3.bank_id
    WHERE batteries.position <= bank_sizes.size - 8 AND batteries.position > sel3.position
    ORDER BY bank_id ASC, batteries.joltage DESC, batteries.position ASC;

INSERT INTO sel5 (bank_id, position, joltage)
SELECT DISTINCT ON (batteries.bank_id) batteries.bank_id, batteries.position, batteries.joltage
    FROM batteries
    INNER JOIN bank_sizes ON batteries.bank_id = bank_sizes.bank_id
    INNER JOIN sel4 ON batteries.bank_id = sel4.bank_id
    WHERE batteries.position <= bank_sizes.size - 7 AND batteries.position > sel4.position
    ORDER BY bank_id ASC, batteries.joltage DESC, batteries.position ASC;

INSERT INTO sel6 (bank_id, position, joltage)
SELECT DISTINCT ON (batteries.bank_id) batteries.bank_id, batteries.position, batteries.joltage
    FROM batteries
    INNER JOIN bank_sizes ON batteries.bank_id = bank_sizes.bank_id
    INNER JOIN sel5 ON batteries.bank_id = sel5.bank_id
    WHERE batteries.position <= bank_sizes.size - 6 AND batteries.position > sel5.position
    ORDER BY bank_id ASC, batteries.joltage DESC, batteries.position ASC;

INSERT INTO sel7 (bank_id, position, joltage)
SELECT DISTINCT ON (batteries.bank_id) batteries.bank_id, batteries.position, batteries.joltage
    FROM batteries
    INNER JOIN bank_sizes ON batteries.bank_id = bank_sizes.bank_id
    INNER JOIN sel6 ON batteries.bank_id = sel6.bank_id
    WHERE batteries.position <= bank_sizes.size - 5 AND batteries.position > sel6.position
    ORDER BY bank_id ASC, batteries.joltage DESC, batteries.position ASC;

INSERT INTO sel8 (bank_id, position, joltage)
SELECT DISTINCT ON (batteries.bank_id) batteries.bank_id, batteries.position, batteries.joltage
    FROM batteries
    INNER JOIN bank_sizes ON batteries.bank_id = bank_sizes.bank_id
    INNER JOIN sel7 ON batteries.bank_id = sel7.bank_id
    WHERE batteries.position <= bank_sizes.size - 4 AND batteries.position > sel7.position
    ORDER BY bank_id ASC, batteries.joltage DESC, batteries.position ASC;

INSERT INTO sel9 (bank_id, position, joltage)
SELECT DISTINCT ON (batteries.bank_id) batteries.bank_id, batteries.position, batteries.joltage
    FROM batteries
    INNER JOIN bank_sizes ON batteries.bank_id = bank_sizes.bank_id
    INNER JOIN sel8 ON batteries.bank_id = sel8.bank_id
    WHERE batteries.position <= bank_sizes.size - 3 AND batteries.position > sel8.position
    ORDER BY bank_id ASC, batteries.joltage DESC, batteries.position ASC;

INSERT INTO sel10 (bank_id, position, joltage)
SELECT DISTINCT ON (batteries.bank_id) batteries.bank_id, batteries.position, batteries.joltage
    FROM batteries
    INNER JOIN bank_sizes ON batteries.bank_id = bank_sizes.bank_id
    INNER JOIN sel9 ON batteries.bank_id = sel9.bank_id
    WHERE batteries.position <= bank_sizes.size - 2 AND batteries.position > sel9.position
    ORDER BY bank_id ASC, batteries.joltage DESC, batteries.position ASC;

INSERT INTO sel11 (bank_id, position, joltage)
SELECT DISTINCT ON (batteries.bank_id) batteries.bank_id, batteries.position, batteries.joltage
    FROM batteries
    INNER JOIN bank_sizes ON batteries.bank_id = bank_sizes.bank_id
    INNER JOIN sel10 ON batteries.bank_id = sel10.bank_id
    WHERE batteries.position <= bank_sizes.size - 1 AND batteries.position > sel10.position
    ORDER BY bank_id ASC, batteries.joltage DESC, batteries.position ASC;

INSERT INTO sel12 (bank_id, position, joltage)
SELECT DISTINCT ON (batteries.bank_id) batteries.bank_id, batteries.position, batteries.joltage
    FROM batteries
    INNER JOIN sel11 ON batteries.bank_id = sel11.bank_id
    WHERE batteries.position > sel11.position
    ORDER BY bank_id ASC, batteries.joltage DESC, batteries.position ASC;

SELECT sum(
               sel1.joltage * 100000000000
             + sel2.joltage * 10000000000
             + sel3.joltage * 1000000000
             + sel4.joltage * 100000000
             + sel5.joltage * 10000000
             + sel6.joltage * 1000000
             + sel7.joltage * 100000
             + sel8.joltage * 10000
             + sel9.joltage * 1000
             + sel10.joltage * 100
             + sel11.joltage * 10
             + sel12.joltage)
    FROM sel1
    INNER JOIN sel2 ON sel1.bank_id = sel2.bank_id
    INNER JOIN sel3 ON sel1.bank_id = sel3.bank_id
    INNER JOIN sel4 ON sel1.bank_id = sel4.bank_id
    INNER JOIN sel5 ON sel1.bank_id = sel5.bank_id
    INNER JOIN sel6 ON sel1.bank_id = sel6.bank_id
    INNER JOIN sel7 ON sel1.bank_id = sel7.bank_id
    INNER JOIN sel8 ON sel1.bank_id = sel8.bank_id
    INNER JOIN sel9 ON sel1.bank_id = sel9.bank_id
    INNER JOIN sel10 ON sel1.bank_id = sel10.bank_id
    INNER JOIN sel11 ON sel1.bank_id = sel11.bank_id
    INNER JOIN sel12 ON sel1.bank_id = sel12.bank_id;
