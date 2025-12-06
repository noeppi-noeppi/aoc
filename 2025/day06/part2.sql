CREATE TABLE input_raw (line_number SERIAL PRIMARY KEY NOT NULL, line_text TEXT NOT NULL);
COPY input_raw (line_text) FROM '/aocinput.txt';

CREATE TABLE input (line_number SERIAL PRIMARY KEY NOT NULL, line_text TEXT NOT NULL);

INSERT INTO input(line_number, line_text)
SELECT input_raw.line_number, input_raw.line_text || repeat(' ', meta.max_len - length(input_raw.line_text))
    FROM input_raw
    LEFT JOIN (SELECT max(length(all_lines.line_text)) FROM input_raw AS all_lines) AS meta(max_len) ON true;

CREATE TABLE input_op_line (col_number SERIAL PRIMARY KEY NOT NULL, char CHAR NOT NULL);

INSERT INTO input_op_line(char)
SELECT cast(regexp_split_to_table(line.line_text, '') AS CHAR)
    FROM (SELECT input.line_text FROM input ORDER BY input.line_number DESC LIMIT 1) AS line(line_text);

CREATE TABLE input_transposed (line_number INTEGER PRIMARY KEY NOT NULL, line_text TEXT NOT NULL);

INSERT INTO input_transposed(line_number, line_text)
SELECT input_op_line.col_number, string_agg(transposed.char, '') FROM input_op_line
    CROSS JOIN LATERAL (SELECT input_cols.char
        FROM(SELECT input.line_number, cast((regexp_split_to_array(input.line_text, ''))[input_op_line.col_number] AS CHAR) FROM input
            ORDER BY input.line_number DESC
            OFFSET 1) AS input_cols(lnum, char)
        ORDER BY input_cols.lnum ASC) AS transposed(char)
    GROUP BY input_op_line.col_number;

CREATE TABLE input_collated (group_id SERIAL PRIMARY KEY NOT NULL, args NUMERIC[]);

INSERT INTO input_collated(args)
SELECT cast(regexp_split_to_array(clusters.cluster_line, ',') AS NUMERIC[])
    FROM (SELECT regexp_split_to_table(fulltext.text, ',,')
        FROM (SELECT string_agg(sorted_line.text, ',')
              FROM (SELECT input_transposed.line_text FROM input_transposed ORDER BY input_transposed.line_number ASC) AS sorted_line(text)
        ) AS fulltext(text)
    ) AS clusters(cluster_line);

CREATE TABLE operations (group_id INTEGER PRIMARY KEY NOT NULL, operation CHAR NOT NULL);
CREATE TABLE arguments (group_id INTEGER NOT NULL, arg_num INTEGER NOT NULL, arg NUMERIC NOT NULL, PRIMARY KEY (group_id, arg_num));

INSERT INTO arguments(group_id, arg_num, arg)
SELECT
    input_collated.group_id,
    rows.idx,
    rows.row AS INTEGER
FROM input_collated
JOIN LATERAL (SELECT row_number() OVER (), * FROM unnest(input_collated.args)) AS rows(idx, row) ON true;

INSERT INTO operations(group_id, operation)
SELECT
    cols.idx,
    cast(cols.col AS CHAR)
FROM (SELECT input.line_number, input.line_text FROM input ORDER BY input.line_number DESC LIMIT 1) AS input_ops(line_number, line_text)
JOIN LATERAL (SELECT row_number() OVER (), * FROM regexp_split_to_table(input_ops.line_text, E'\\s+')) AS cols(idx, col) ON true;

CREATE AGGREGATE prod(NUMERIC) (SFUNC = numeric_mul, STYPE = NUMERIC);

CREATE VIEW answers_sum(group_id, answer) AS SELECT operations.group_id, sum(arguments.arg) FROM operations
    LEFT JOIN arguments ON operations.group_id = arguments.group_id
    WHERE operations.operation = '+'
    GROUP BY operations.group_id;

CREATE VIEW answers_prod(group_id, answer) AS SELECT operations.group_id, prod(arguments.arg) FROM operations
    LEFT JOIN arguments ON operations.group_id = arguments.group_id
    WHERE operations.operation = '*'
    GROUP BY operations.group_id;

CREATE VIEW answers(group_id, answer) AS SELECT answers_sum.group_id, answers_sum.answer FROM answers_sum
    UNION ALL SELECT answers_prod.group_id, answers_prod.answer FROM answers_prod;

SELECT sum(answers.answer) FROM answers;
