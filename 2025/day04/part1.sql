CREATE TABLE input (
    line_number SERIAL PRIMARY KEY NOT NULL,
    line_text   TEXT NOT NULL
);

COPY input (line_text) FROM '/aocinput.txt';

CREATE TABLE paper_rolls (
    pos_x INTEGER NOT NULL,
    pos_y INTEGER NOT NULL,
    PRIMARY KEY (pos_x, pos_y)
);

INSERT INTO paper_rolls(pos_x, pos_y)
SELECT chars.idx, input.line_number FROM input
    JOIN LATERAL (SELECT row_number() OVER (), * FROM regexp_split_to_table(input.line_text, '')) AS chars(idx, chr) ON true
    WHERE chars.chr = '@';

CREATE VIEW north     (pos_x, pos_y) AS SELECT paper_rolls.pos_x    , paper_rolls.pos_y - 1 FROM paper_rolls;
CREATE VIEW north_east(pos_x, pos_y) AS SELECT paper_rolls.pos_x + 1, paper_rolls.pos_y - 1 FROM paper_rolls;
CREATE VIEW east      (pos_x, pos_y) AS SELECT paper_rolls.pos_x + 1, paper_rolls.pos_y     FROM paper_rolls;
CREATE VIEW south_east(pos_x, pos_y) AS SELECT paper_rolls.pos_x + 1, paper_rolls.pos_y + 1 FROM paper_rolls;
CREATE VIEW south     (pos_x, pos_y) AS SELECT paper_rolls.pos_x    , paper_rolls.pos_y + 1 FROM paper_rolls;
CREATE VIEW south_west(pos_x, pos_y) AS SELECT paper_rolls.pos_x - 1, paper_rolls.pos_y + 1 FROM paper_rolls;
CREATE VIEW west      (pos_x, pos_y) AS SELECT paper_rolls.pos_x - 1, paper_rolls.pos_y     FROM paper_rolls;
CREATE VIEW north_west(pos_x, pos_y) AS SELECT paper_rolls.pos_x - 1, paper_rolls.pos_y - 1 FROM paper_rolls;

CREATE TABLE neighbours(
    pos_x INTEGER NOT NULL,
    pos_y INTEGER NOT NULL,
    count INTEGER NOT NULL,
    PRIMARY KEY (pos_x, pos_y)
);

INSERT INTO neighbours(pos_x, pos_y, count)
SELECT neighbour_list.pos_x, neighbour_list.pos_y, count(*)
    FROM (SELECT * FROM north
        UNION ALL SELECT * FROM north_east
        UNION ALL SELECT * FROM east
        UNION ALL SELECT * FROM south_east
        UNION ALL SELECT * FROM south
        UNION ALL SELECT * FROM south_west
        UNION ALL SELECT * FROM west
        UNION ALL SELECT * FROM north_west) AS neighbour_list(pos_x, pos_y)
    GROUP BY neighbour_list.pos_x, neighbour_list.pos_y;

SELECT count(*) FROM paper_rolls
    LEFT JOIN neighbours ON paper_rolls.pos_x = neighbours.pos_x AND paper_rolls.pos_y = neighbours.pos_y
    WHERE neighbours.count IS NULL OR neighbours.count < 4;
