CREATE TABLE input (
    line_number SERIAL PRIMARY KEY NOT NULL,
    line_text   TEXT NOT NULL
);

COPY input (line_text) FROM '/aocinput.txt';

CREATE TABLE operations (group_id INTEGER PRIMARY KEY NOT NULL, operation CHAR NOT NULL);
CREATE TABLE arguments (group_id INTEGER NOT NULL, arg_num INTEGER NOT NULL, arg NUMERIC NOT NULL, PRIMARY KEY (group_id, arg_num));

INSERT INTO arguments(group_id, arg_num, arg)
SELECT
    cols.idx,
    input_args.line_number,
    cast(cast(cols.col AS INTEGER) AS NUMERIC)
FROM (SELECT input.line_number, input.line_text FROM input ORDER BY input.line_number DESC OFFSET 1) AS input_args(line_number, line_text)
JOIN LATERAL (SELECT row_number() OVER (), * FROM regexp_split_to_table(input_args.line_text, E'\\s+')) AS cols(idx, col) ON true;

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
