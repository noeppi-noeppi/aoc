CREATE TABLE input (
    line_number SERIAL PRIMARY KEY NOT NULL,
    line_text   TEXT NOT NULL
);

COPY input (line_text) FROM '/aocinput.txt';

CREATE VIEW input_entries (entry) AS SELECT * FROM (SELECT regexp_split_to_table(input.line_text, E',') FROM input) AS lines;

CREATE TABLE product_ranges (
    range_start BIGINT,
    range_end   BIGINT
);

INSERT INTO product_ranges(range_start, range_end)
SELECT
    cast((string_to_array(input_entries.entry,'-'))[1] AS BIGINT),
    cast((string_to_array(input_entries.entry,'-'))[2] AS BIGINT)
FROM input_entries;

CREATE TABLE product_ids (id BIGINT);
INSERT INTO product_ids(id)
SELECT generate_series(product_ranges.range_start, product_ranges.range_end) FROM product_ranges;

SELECT sum(product_ids.id) FROM product_ids WHERE regexp_count(cast(product_ids.id AS TEXT), E'^(.*)\\1+$') > 0;
