CREATE TABLE input (line_number SERIAL PRIMARY KEY NOT NULL, line_text TEXT NOT NULL);
COPY input (line_text) FROM '/aocinput.txt';

CREATE TABLE circuits (
    id INTEGER PRIMARY KEY NOT NULL,
    pos_x BIGINT NOT NULL,
    pos_y BIGINT NOT NULL,
    pos_z BIGINT NOT NULL,
    con   INTEGER,
    UNIQUE (pos_x, pos_y, pos_z)
);
CREATE UNIQUE INDEX circuits_pos_index ON circuits USING btree (pos_x, pos_y, pos_z);

INSERT INTO circuits(id, pos_x, pos_y, pos_z)
SELECT
    input.line_number,
    cast((string_to_array(input.line_text,','))[1] AS BIGINT),
    cast((string_to_array(input.line_text,','))[2] AS BIGINT),
    cast((string_to_array(input.line_text,','))[3] AS BIGINT)
FROM input;

CREATE FUNCTION circuit_find(box_id INTEGER) RETURNS TABLE (circuit_id INTEGER, tree_depth INTEGER) AS $$
DECLARE circuit_id INTEGER := box_id;
DECLARE tree_depth INTEGER := 0;
BEGIN
    WHILE EXISTS (SELECT circuits.con FROM circuits WHERE circuits.id = circuit_id AND circuits.con IS NOT NULL) LOOP
        SELECT circuits.con INTO circuit_id FROM circuits WHERE circuits.id = circuit_id;
        SELECT tree_depth + 1 INTO tree_depth;
    END LOOP;
    IF box_id <> circuit_id THEN
        UPDATE circuits SET con = circuit_id WHERE circuits.id = box_id;
    END IF;
    RETURN QUERY SELECT circuit_id, tree_depth;
END;
$$ LANGUAGE PLpgSQL;

CREATE FUNCTION circuit_connect(box_id1 INTEGER, box_id2 INTEGER) RETURNS VOID AS $$
DECLARE circuit_id1 INTEGER;
DECLARE circuit_id2 INTEGER;
DECLARE tree_depth1 INTEGER;
DECLARE tree_depth2 INTEGER;
BEGIN
    SELECT * INTO circuit_id1, tree_depth1 FROM circuit_find(box_id1);
    SELECT * INTO circuit_id2, tree_depth2 FROM circuit_find(box_id2);
    IF circuit_id1 <> circuit_id2 THEN
        IF tree_depth1 < tree_depth2 THEN
            UPDATE circuits SET con = circuit_id2 WHERE circuits.id = circuit_id1;
        ELSE
            UPDATE circuits SET con = circuit_id1 WHERE circuits.id = circuit_id2;
        END IF;
    END IF;
END;
$$ LANGUAGE PLpgSQL;

DO
$$
BEGIN
    PERFORM circuit_connect(circuits1.id, circuits2.id) FROM circuits AS circuits1
        INNER JOIN circuits AS circuits2 ON circuits1.id < circuits2.id
        ORDER BY (circuits1.pos_x - circuits2.pos_x) * (circuits1.pos_x - circuits2.pos_x)
               + (circuits1.pos_y - circuits2.pos_y) * (circuits1.pos_y - circuits2.pos_y)
               + (circuits1.pos_z - circuits2.pos_z) * (circuits1.pos_z - circuits2.pos_z) ASC
        LIMIT 1000;
END;
$$;

CREATE AGGREGATE prod(NUMERIC) (SFUNC = numeric_mul, STYPE = NUMERIC);

SELECT prod(largest_circuits.size) FROM (SELECT * FROM (SELECT count(*)
            FROM circuits
            GROUP BY (SELECT find.circuit_id FROM circuit_find(circuits.id) AS find(circuit_id, tree_depth))
        ) AS circuit_sizes(size)
        ORDER BY circuit_sizes.size DESC
        LIMIT 3
    ) AS largest_circuits(size);
