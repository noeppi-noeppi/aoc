CREATE TABLE input (
    line_number SERIAL PRIMARY KEY NOT NULL,
    line_text   TEXT NOT NULL
);

COPY input (line_text) FROM '/aocinput.txt';

CREATE TABLE fresh_ranges (range_start BIGINT, range_end BIGINT);
CREATE TABLE ingredients (ingredient_id BIGINT);

INSERT INTO fresh_ranges(range_start, range_end)
SELECT
    cast((string_to_array(input.line_text,'-'))[1] AS BIGINT),
    cast((string_to_array(input.line_text,'-'))[2] AS BIGINT)
FROM input
    WHERE regexp_count(input.line_text, E'-') > 0;

INSERT INTO ingredients(ingredient_id)
SELECT
    cast(input.line_text AS BIGINT)
FROM input
    WHERE regexp_count(input.line_text, E'^\\d+$') > 0;

SELECT count(*) FROM ingredients
    WHERE EXISTS (SELECT 1 FROM fresh_ranges
        WHERE fresh_ranges.range_start <= ingredients.ingredient_id
          AND ingredients.ingredient_id <= fresh_ranges.range_end);
