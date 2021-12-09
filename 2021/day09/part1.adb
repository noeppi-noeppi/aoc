with Ada.Text_IO;

procedure part1 is

   type Index is range 0 .. 200;
   type Cell is range 0 .. 9;
   type Row is array (Index) of Cell;
   type Grid is array (Index) of Row;
   
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
   
   grid_result: GridResult;
   the_grid: Grid;
   width: Integer;
   height: Integer;
   
   risk: Integer := 0;
   value: Integer;
   
begin
   grid_result := readg;
   the_grid := grid_result.parsedGrid;
   width := grid_result.width;
   height := grid_result.height;
   
   for x in 1 .. width loop
      for y in 1 .. height loop
         value := e(the_grid, x, y);
         if (x = 1 or value < e(the_grid, x - 1, y))
           and (x = width or value < e(the_grid, x + 1, y))
           and (y = 1 or value < e(the_grid, x, y - 1))
           and (y = height or value < e(the_grid, x, y + 1)) then
            risk := risk + value + 1;
         end if;
      end loop;
   end loop;
   
   writeln(risk);
end part1;

