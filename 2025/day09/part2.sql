CREATE TABLE input (line_number SERIAL PRIMARY KEY NOT NULL, line_text TEXT NOT NULL);
COPY input (line_text) FROM '/aocinput.txt';

CREATE TABLE boundaries (
    idx INTEGER PRIMARY KEY NOT NULL,
    pos_x BIGINT NOT NULL,
    pos_y BIGINT NOT NULL,
    UNIQUE (pos_x, pos_y)
);

INSERT INTO boundaries(idx, pos_x, pos_y)
SELECT
    input.line_number,
    cast((string_to_array(input.line_text,','))[1] AS BIGINT),
    cast((string_to_array(input.line_text,','))[2] AS BIGINT)
FROM input;

CREATE TABLE linearize_x (lin_x SERIAL PRIMARY KEY NOT NULL, pos_x BIGINT UNIQUE NOT NULL);
CREATE UNIQUE INDEX linearize_x_index ON linearize_x USING btree (pos_x);
INSERT INTO linearize_x(pos_x)
SELECT DISTINCT boundaries.pos_x FROM boundaries
    ORDER BY boundaries.pos_x ASC;

CREATE TABLE linearize_y (lin_y SERIAL PRIMARY KEY NOT NULL, pos_y BIGINT UNIQUE NOT NULL);
CREATE UNIQUE INDEX linearize_y_index ON linearize_y USING btree (pos_y);
INSERT INTO linearize_y(pos_y)
SELECT DISTINCT boundaries.pos_y FROM boundaries
    ORDER BY boundaries.pos_y ASC;

CREATE TABLE red_tiles (
    idx INTEGER PRIMARY KEY NOT NULL,
    lin_x INTEGER NOT NULL,
    lin_y INTEGER NOT NULL,
    UNIQUE (lin_x, lin_y)
);

INSERT INTO red_tiles(idx, lin_x, lin_y)
SELECT boundaries.idx, linearize_x.lin_x, linearize_y.lin_y FROM boundaries
    LEFT JOIN linearize_x ON boundaries.pos_x = linearize_x.pos_x
    LEFT JOIN linearize_y ON boundaries.pos_y = linearize_y.pos_y;

CREATE VIEW max_red_tiles(idx, lin_x, lin_y) AS SELECT max(red_tiles.idx), max(red_tiles.lin_x), max(red_tiles.lin_y) FROM red_tiles;

CREATE TABLE xborder (lin_x INTEGER NOT NULL, lin_y INTEGER NOT NULL, PRIMARY KEY (lin_x, lin_y));
CREATE TABLE yborder (lin_x INTEGER NOT NULL, lin_y INTEGER NOT NULL, PRIMARY KEY (lin_x, lin_y));
CREATE TABLE colored_tiles (lin_x INTEGER NOT NULL, lin_y INTEGER NOT NULL, PRIMARY KEY (lin_x, lin_y));
CREATE TABLE white_tiles (lin_x INTEGER NOT NULL, lin_y INTEGER NOT NULL, PRIMARY KEY (lin_x, lin_y));

CREATE INDEX white_tiles_x ON white_tiles USING btree (lin_x);
CREATE INDEX white_tiles_y ON white_tiles USING btree (lin_y);

INSERT INTO xborder(lin_x, lin_y)
SELECT generate_series(least(tiles1.lin_x, tiles2.lin_x), greatest(tiles1.lin_x, tiles2.lin_x) - 1), tiles1.lin_y FROM red_tiles AS tiles1
    CROSS JOIN red_tiles AS tiles2
    LEFT JOIN max_red_tiles ON true
    WHERE (tiles1.idx + 1 = tiles2.idx OR (tiles1.idx = max_red_tiles.idx AND tiles2.idx = 0))
      AND tiles1.lin_y = tiles2.lin_y;

INSERT INTO yborder(lin_x, lin_y)
SELECT tiles1.lin_x, generate_series(least(tiles1.lin_y, tiles2.lin_y), greatest(tiles1.lin_y, tiles2.lin_y) - 1) FROM red_tiles AS tiles1
    CROSS JOIN red_tiles AS tiles2
    LEFT JOIN max_red_tiles ON true
    WHERE (tiles1.idx + 1 = tiles2.idx OR (tiles1.idx = max_red_tiles.idx AND tiles2.idx = 0))
      AND tiles1.lin_x = tiles2.lin_x;

CREATE FUNCTION is_inside(test_x INTEGER, test_y INTEGER) RETURNS BOOLEAN AS $$
DECLARE itr_x INTEGER;
DECLARE itr_y INTEGER;
DECLARE ctr_x INTEGER := 0;
DECLARE ctr_y INTEGER := 0;
BEGIN
    FOR itr_x IN SELECT generate_series(1, test_x) LOOP
        IF EXISTS (SELECT 1 FROM yborder WHERE yborder.lin_x = itr_x AND yborder.lin_y = test_y) THEN
            SELECT ctr_x + 1 INTO ctr_x;
        END IF;
    END LOOP;
    FOR itr_y IN SELECT generate_series(1, test_y) LOOP
        IF EXISTS (SELECT 1 FROM xborder WHERE xborder.lin_x = test_x AND xborder.lin_y = itr_y) THEN
            SELECT ctr_y + 1 INTO ctr_y;
        END IF;
    END LOOP;
    RETURN ctr_x % 2 = 1 AND ctr_y % 2 = 1;
END;
$$ LANGUAGE PLpgSQL;

CREATE FUNCTION xdist(lin_x1 INTEGER, lin_x2 INTEGER) RETURNS BIGINT AS $$
DECLARE dist BIGINT;
BEGIN
    SELECT abs(linearize_x1.pos_x - linearize_x2.pos_x) + 1 FROM linearize_x AS linearize_x1
        INNER JOIN linearize_x AS linearize_x2 ON true
        WHERE linearize_x1.lin_x = lin_x1 AND linearize_x2.lin_x = lin_x2
    INTO dist;
    RETURN dist;
END;
$$ LANGUAGE PLpgSQL;

CREATE FUNCTION ydist(lin_y1 INTEGER, lin_y2 INTEGER) RETURNS BIGINT AS $$
DECLARE dist BIGINT;
BEGIN
    SELECT abs(linearize_y1.pos_y - linearize_y2.pos_y) + 1 FROM linearize_y AS linearize_y1
        INNER JOIN linearize_y AS linearize_y2 ON true
        WHERE linearize_y1.lin_y = lin_y1 AND linearize_y2.lin_y = lin_y2
    INTO dist;
    RETURN dist;
END;
$$ LANGUAGE PLpgSQL;

INSERT INTO colored_tiles(lin_x, lin_y) SELECT xborder.lin_x, xborder.lin_y FROM xborder ON CONFLICT DO NOTHING;
INSERT INTO colored_tiles(lin_x, lin_y) SELECT yborder.lin_x, yborder.lin_y FROM yborder ON CONFLICT DO NOTHING;

INSERT INTO colored_tiles(lin_x, lin_y)
SELECT pos.lin_x, pos.lin_y FROM max_red_tiles
    JOIN LATERAL (SELECT * FROM (SELECT generate_series(1, max_red_tiles.lin_x)) CROSS JOIN (SELECT generate_series(1, max_red_tiles.lin_y))) AS pos(lin_x, lin_y) ON true
    WHERE is_inside(pos.lin_x, pos.lin_y)
ON CONFLICT DO NOTHING;

INSERT INTO white_tiles(lin_x, lin_y)
SELECT pos.lin_x, pos.lin_y FROM max_red_tiles
    JOIN LATERAL (SELECT * FROM (SELECT generate_series(1, max_red_tiles.lin_x)) CROSS JOIN (SELECT generate_series(1, max_red_tiles.lin_y))) AS pos(lin_x, lin_y) ON true
    WHERE NOT EXISTS (SELECT 1 FROM colored_tiles WHERE colored_tiles.lin_x = pos.lin_x AND colored_tiles.lin_y = pos.lin_y);

CREATE FUNCTION fully_colored(lin_x1 INTEGER, lin_y1 INTEGER, lin_x2 INTEGER, lin_y2 INTEGER) RETURNS BOOLEAN AS $$
BEGIN
    RETURN NOT EXISTS (SELECT 1 FROM white_tiles
        WHERE ((lin_x1 <= white_tiles.lin_x AND white_tiles.lin_x <= lin_x2) OR (lin_x2 <= white_tiles.lin_x AND white_tiles.lin_x <= lin_x1))
          AND ((lin_y1 <= white_tiles.lin_y AND white_tiles.lin_y <= lin_y2) OR (lin_y2 <= white_tiles.lin_y AND white_tiles.lin_y <= lin_y1)));
END;
$$ LANGUAGE PLpgSQL;

SELECT max(xdist(tiles1.lin_x, tiles2.lin_x) * ydist(tiles1.lin_y, tiles2.lin_y)) FROM red_tiles AS tiles1
    CROSS JOIN red_tiles AS tiles2
    WHERE fully_colored(tiles1.lin_x, tiles1.lin_y, tiles2.lin_x, tiles2.lin_y);
