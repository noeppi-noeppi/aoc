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
    cast(chars.chr AS INTEGER)
FROM input
JOIN LATERAL (SELECT row_number() OVER (), * FROM regexp_split_to_table(input.line_text, '')) AS chars(idx, chr) ON true;

CREATE VIEW bank_power (bank_id, power) AS SELECT batteries.bank_id, max(batteries.joltage * 10 + batteries2.joltage) FROM batteries, batteries AS batteries2
    WHERE batteries.bank_id = batteries2.bank_id AND batteries.position < batteries2.position
    GROUP BY batteries.bank_id;

SELECT sum(bank_power.power) FROM bank_power;
