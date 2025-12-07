CREATE TABLE input (
    line_number SERIAL PRIMARY KEY NOT NULL,
    line_text   TEXT NOT NULL
);

COPY input (line_text) FROM '/aocinput.txt';

CREATE VIEW manifold_height (height) AS SELECT max(input.line_number) FROM input;

CREATE TABLE beam (
    pos_x INTEGER NOT NULL,
    pos_y INTEGER NOT NULL,
    timelines NUMERIC NOT NULL,
    PRIMARY KEY (pos_x, pos_y)
);

CREATE TABLE splitters (
    pos_x INTEGER NOT NULL,
    pos_y INTEGER NOT NULL,
    PRIMARY KEY (pos_x, pos_y)
);

INSERT INTO beam(pos_x, pos_y, timelines)
SELECT chars.idx, input.line_number, 1 FROM input
    JOIN LATERAL (SELECT row_number() OVER (), * FROM regexp_split_to_table(input.line_text, '')) AS chars(idx, chr) ON true
    WHERE chars.chr = 'S';

INSERT INTO splitters(pos_x, pos_y)
SELECT chars.idx, input.line_number FROM input
    JOIN LATERAL (SELECT row_number() OVER (), * FROM regexp_split_to_table(input.line_text, '')) AS chars(idx, chr) ON true
    WHERE chars.chr = '^';

DO
$$
DECLARE level_y INTEGER;
DECLARE split_x INTEGER;
DECLARE split_y INTEGER;
DECLARE split_timelines NUMERIC;
BEGIN
    FOR level_y IN SELECT generate_series(1, manifold_height.height) FROM manifold_height LOOP
        INSERT INTO beam(pos_x, pos_y, timelines)
        SELECT beam.pos_x, beam.pos_y + 1, beam.timelines FROM beam
            LEFT JOIN splitters ON splitters.pos_x = beam.pos_x AND splitters.pos_y = beam.pos_y + 1
            WHERE beam.pos_y = level_y AND splitters.pos_y IS NULL
        ON CONFLICT DO NOTHING;

        FOR split_x, split_y, split_timelines IN SELECT unnest(ARRAY[splitters.pos_x - 1, splitters.pos_x + 1]), splitters.pos_y, beam.timelines
            FROM beam
            INNER JOIN splitters ON splitters.pos_x = beam.pos_x AND splitters.pos_y = beam.pos_y + 1
            WHERE beam.pos_y = level_y
        LOOP
            INSERT INTO beam(pos_x, pos_y, timelines)
                VALUES (split_x, split_y, split_timelines)
            ON CONFLICT (pos_x, pos_y) DO UPDATE SET timelines = beam.timelines + excluded.timelines;
        END LOOP;
    END LOOP;
END
$$;

SELECT sum(beam.timelines) FROM beam
    LEFT JOIN manifold_height ON true
    WHERE beam.pos_y = manifold_height.height;
