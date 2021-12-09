with Ada.Text_IO;

procedure part2 is

   type Index is range 0 .. 200;
   type LargeIndex is range 0 .. 1000;
   type Cell is range 0 .. 9;
   type Row is array (Index) of Cell;
   type Grid is array (Index) of Row;
   type BasinRow is array (Index) of Integer;
   type BasinGrid is array (Index) of BasinRow;
   type BasinList is array (LargeIndex) of Integer;
   
   type RowResult is record
      parsedRow: Row;
      width: Integer;
   end record;
   
   type GridResult is record
      parsedGrid: Grid;
      width: Integer;
      height: Integer;
   end record;

   procedure writeln(n: integer) is
      str : String := Integer'Image(n);
   begin
      Ada.Text_IO.Put_Line(str);
   end writeln;

   function parseCell(chr: Character) return Cell is
   begin
      return Cell(Character'Pos(chr) - 48);
   end parseCell;

   function readln return RowResult is
      line: String(1 .. 200) := (others => ' ');
      len: integer;
      resultRow: Row;
      result: RowResult;
   begin
      Ada.Text_IO.Get_Line(line, len);
      for i in 1 .. len loop
         resultRow(Index(i)) := parseCell(line(i));
      end loop;
      result := (resultRow, len);
      return result;
   end readln;
   
   function readg return GridResult is
      line: RowResult;
      width: Integer;
      height: Integer := 0;
      the_grid: Grid;
      result: GridResult;
   begin
      line := readln;
      while line.width /= 0 loop
         height := height + 1;
         width := line.width;
         the_grid(Index(height)) := line.parsedRow;
         line := readln;
      end loop;
      result := (the_grid, width, height);
      return result;
   end readg;
   
   function e(the_grid: Grid; x: Integer; y: Integer) return Integer is
   begin
      return Integer(the_grid(Index(y))(Index(x)));
   end;
   
   function e(the_grid: BasinGrid; x: Integer; y: Integer) return Integer is
   begin
      return the_grid(Index(y))(Index(x));
   end;
   
   procedure s(the_grid: in out BasinGrid; x: Integer; y: Integer; v: Integer) is
   begin
      the_grid(Index(y))(Index(x)) := v;
   end;
   
   procedure mark_basins(the_grid: Grid; basins: in out BasinGrid; list: in out BasinList; id: Integer; x: Integer; y: Integer; width: Integer; height: Integer) is
   begin
      if x >= 1 and x <= width and y >= 1 and y <= height
        and e(the_grid, x, y) /= 9 and e(basins, x, y) = 0 then
         s(basins, x, y, id);
         list(LargeIndex(id)) := list(LargeIndex(id)) + 1;
         mark_basins(the_grid, basins, list, id, x - 1, y, width, height);
         mark_basins(the_grid, basins, list, id, x + 1, y, width, height);
         mark_basins(the_grid, basins, list, id, x, y - 1, width, height);
         mark_basins(the_grid, basins, list, id, x, y + 1, width, height);
      end if;
   end;
   
   grid_result: GridResult;
   the_grid: Grid;
   width: Integer;
   height: Integer;
   
   basins: BasinGrid;
   basin_list: BasinList;
   next_id: Integer := 0;
   
   basin1: Integer := 0;
   basin2: Integer := 0;
   basin3: Integer := 0;
   value: Integer;
begin
   grid_result := readg;
   the_grid := grid_result.parsedGrid;
   width := grid_result.width;
   height := grid_result.height;
   
   for x in 1 .. width loop
     for y in 1 .. height loop
        s(basins, x, y, 0);
     end loop;
   end loop;
   
   for x in 1 .. width loop
      for y in 1 .. height loop
         if e(the_grid, x, y) /= 9 and e(basins, x, y) = 0 then
            next_id := next_id + 1;
            mark_basins(the_grid, basins, basin_list, next_id, x, y, width, height);
         end if;
      end loop;
   end loop;
   
   for i in 1 .. next_id loop
      value := basin_list(LargeIndex(i));
      if value > basin1 then
         basin3 := basin2;
         basin2 := basin1;
         basin1 := value;
      elsif value > basin2 then
         basin3 := basin2;
         basin2 := value;
      elsif value > basin3 then
         basin3 := value;
      end if;
   end loop;
   
   writeln(basin1 * basin2 * basin3);
end part2;

