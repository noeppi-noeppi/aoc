CREATE TABLE input (
    line_number SERIAL PRIMARY KEY NOT NULL,
    line_text   TEXT NOT NULL
);

COPY input (line_text) FROM '/aocinput.txt';

CREATE TABLE fresh_ranges (range_start BIGINT NOT NULL, range_end BIGINT NOT NULL, PRIMARY KEY (range_start, range_end));

INSERT INTO fresh_ranges(range_start, range_end)
SELECT DISTINCT
    cast((string_to_array(input.line_text,'-'))[1] AS BIGINT),
    cast((string_to_array(input.line_text,'-'))[2] AS BIGINT) + 1
FROM input
    WHERE regexp_count(input.line_text, E'-') > 0;

CREATE TABLE linearize (lin_idx SERIAL PRIMARY KEY NOT NULL, ingredient BIGINT UNIQUE NOT NULL);
CREATE UNIQUE INDEX linearize_index ON linearize USING btree (ingredient);
INSERT INTO linearize(ingredient)
SELECT boundaries.boundary
    FROM (SELECT DISTINCT range_start FROM fresh_ranges
        UNION SELECT DISTINCT range_end FROM fresh_ranges) AS boundaries(boundary)
    ORDER BY boundaries.boundary ASC;

CREATE VIEW lin_ranges(range_start, range_end) AS SELECT lin_start.lin_idx, lin_end.lin_idx
    FROM fresh_ranges
    LEFT JOIN linearize AS lin_start ON fresh_ranges.range_start = lin_start.ingredient
    LEFT JOIN linearize AS lin_end ON fresh_ranges.range_end = lin_end.ingredient;

CREATE TABLE lin_fresh(lin_idx INTEGER PRIMARY KEY NOT NULL);
INSERT INTO lin_fresh(lin_idx)
SELECT DISTINCT generate_series(lin_ranges.range_start, lin_ranges.range_end - 1) FROM lin_ranges;

CREATE TABLE lin_amount(lin_idx INTEGER PRIMARY KEY NOT NULL, amount BIGINT);

INSERT INTO lin_amount(lin_idx, amount)
SELECT max(linearize.lin_idx), 0 FROM linearize;

INSERT INTO lin_amount(lin_idx, amount)
SELECT linearize.lin_idx, successor.ingredient - linearize.ingredient FROM linearize
    INNER JOIN linearize AS successor ON linearize.lin_idx + 1 = successor.lin_idx;

SELECT sum(lin_amount.amount) FROM lin_fresh
    LEFT JOIN lin_amount ON lin_fresh.lin_idx = lin_amount.lin_idx;
