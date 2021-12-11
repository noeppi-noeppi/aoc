Module: day11

define class <cave> (<object>)
  slot width :: <integer>, required-init-keyword: width:;
  slot height :: <integer>, required-init-keyword: height:;
  slot squids :: <vector>, required-init-keyword: squids:;
end class <cave>;

define class <squid> (<object>)
  slot energy :: <integer>, required-init-keyword: energy:;
  slot flashed :: <boolean>, required-init-keyword: flashed:;
end class <squid>;

define function has-squid(cave :: <cave>, x :: <integer>, y :: <integer>) => (has :: <boolean>)
  x >= 0 & x < cave.width & y >= 0 & y < cave.height;
end;
  
define function get-squid(cave :: <cave>, x :: <integer>, y :: <integer>) => (squid :: <squid>)
  cave.squids[y][x]
end;

define function check-flash(cave :: <cave>, x :: <integer>, y :: <integer>) => (flashes :: <integer>)
  let flashes = 0;
  if (has-squid(cave, x, y))
    let squid = get-squid(cave, x, y);
    squid.energy := squid.energy + 1;
    if (~squid.flashed & squid.energy > 9)
      squid.flashed := #t;
      flashes := flashes + 1;
      if (has-squid(cave, x - 1, y - 1)) flashes := flashes + check-flash(cave, x - 1, y - 1) end;
      if (has-squid(cave, x - 1, y)) flashes := flashes + check-flash(cave, x - 1, y) end;
      if (has-squid(cave, x - 1, y + 1)) flashes := flashes + check-flash(cave, x - 1, y + 1) end;
      if (has-squid(cave, x, y - 1)) flashes := flashes + check-flash(cave, x, y - 1) end;
      if (has-squid(cave, x, y + 1)) flashes := flashes + check-flash(cave, x, y + 1) end;
      if (has-squid(cave, x + 1, y - 1)) flashes := flashes + check-flash(cave, x + 1, y - 1) end;
      if (has-squid(cave, x + 1, y)) flashes := flashes + check-flash(cave, x + 1, y) end;
      if (has-squid(cave, x + 1, y + 1)) flashes := flashes + check-flash(cave, x + 1, y + 1) end;
    end;
  end;
  flashes
end;

define function main()
  let width = 0;
  let height = 0;
  let squids = make(<stretchy-vector>, size: 0);
  let current = read-line(*standard-input*);
  until (size(current) == 0)
    let vec = make(<stretchy-vector>, size: 0);
    width := size(current);
    height := height + 1;
    for (idx from 0 below size(current))
      add!(vec, make(<squid>, energy: as(<integer>, current[idx]) - 48, flashed: #f));
    end;
    add!(squids, vec);
    current := read-line(*standard-input*);
  end;
  
  let cave = make(<cave>, width: width, height: height, squids: squids);
  let flashes = 0;
    
  for (idx from 0 below 100)
    for (x from 0 below width)
      for (y from 0 below height)
        flashes := flashes + check-flash(cave, x, y);
      end;
    end;
    for (x from 0 below width)
      for (y from 0 below height)
        let squid = get-squid(cave, x, y);
        if (squid.flashed)
          squid.energy := 0;
          squid.flashed := #f;
        end;
      end;
    end;
  end;
  format-out("%d\n", flashes);
end;

main();
