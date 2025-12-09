CREATE TABLE input (line_number SERIAL PRIMARY KEY NOT NULL, line_text TEXT NOT NULL);
COPY input (line_text) FROM '/aocinput.txt';

CREATE TABLE red_tiles (
    pos_x BIGINT NOT NULL,
    pos_y BIGINT NOT NULL,
    PRIMARY KEY (pos_x, pos_y)
);

INSERT INTO red_tiles(pos_x, pos_y)
SELECT
    cast((string_to_array(input.line_text,','))[1] AS BIGINT),
    cast((string_to_array(input.line_text,','))[2] AS BIGINT)
FROM input;

SELECT max((abs(tiles2.pos_x - tiles1.pos_x) + 1) * (abs(tiles2.pos_y - tiles1.pos_y) + 1)) FROM red_tiles AS tiles1 CROSS JOIN red_tiles AS tiles2;
