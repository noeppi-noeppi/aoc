CREATE TABLE input (
    line_number SERIAL PRIMARY KEY NOT NULL,
    line_text   TEXT NOT NULL
);

COPY input (line_text) FROM '/aocinput.txt';

CREATE VIEW manifold_height (height) AS SELECT max(input.line_number) FROM input;

CREATE TABLE beam (
    pos_x INTEGER NOT NULL,
    pos_y INTEGER NOT NULL,
    PRIMARY KEY (pos_x, pos_y)
);

CREATE TABLE splitters (
    pos_x INTEGER NOT NULL,
    pos_y INTEGER NOT NULL,
    PRIMARY KEY (pos_x, pos_y)
);

INSERT INTO beam(pos_x, pos_y)
SELECT chars.idx, input.line_number FROM input
    JOIN LATERAL (SELECT row_number() OVER (), * FROM regexp_split_to_table(input.line_text, '')) AS chars(idx, chr) ON true
    WHERE chars.chr = 'S';

INSERT INTO splitters(pos_x, pos_y)
SELECT chars.idx, input.line_number FROM input
    JOIN LATERAL (SELECT row_number() OVER (), * FROM regexp_split_to_table(input.line_text, '')) AS chars(idx, chr) ON true
    WHERE chars.chr = '^';

CREATE TABLE travel (amount INTEGER NOT NULL);

DO
$$
BEGIN
    WHILE 0 NOT IN (SELECT * FROM travel) LOOP
        WITH
        inserted1 AS (INSERT INTO beam(pos_x, pos_y)
            SELECT beam.pos_x, beam.pos_y + 1 FROM beam
                LEFT JOIN manifold_height ON true
                LEFT JOIN splitters ON splitters.pos_x = beam.pos_x AND splitters.pos_y = beam.pos_y + 1
                WHERE beam.pos_y < manifold_height.height AND splitters.pos_y IS NULL
            ON CONFLICT DO NOTHING
            RETURNING *),
        inserted2 AS (INSERT INTO beam(pos_x, pos_y)
            SELECT unnest(ARRAY[splitters.pos_x - 1, splitters.pos_x + 1]), splitters.pos_y FROM beam
                INNER JOIN splitters ON splitters.pos_x = beam.pos_x AND splitters.pos_y = beam.pos_y + 1
            ON CONFLICT DO NOTHING
            RETURNING *)
        INSERT INTO travel(amount)
        SELECT count(*) FROM (SELECT * FROM inserted1 UNION ALL SELECT * FROM inserted2) AS inserted;
    END LOOP;
END
$$;

SELECT count(*) FROM beam
    INNER JOIN splitters ON splitters.pos_x = beam.pos_x AND splitters.pos_y = beam.pos_y + 1;
