program part1;

type bingo = array [ 0..4, 0..4 ] of integer;
type bingop = ^bingo;
type intarr = array of integer;
type intarrp = ^intarr;

var line: string;
var parts: intarrp;
var numbers: array of integer;
var current_bp: bingop;
var bingos: array of bingo;
var bingo_length: integer = 0;
var nc: integer;
var bc: integer;
var wv: LongInt;

procedure SplitString(str: string; const d: Char; arr: intarrp);
var non_empty: boolean;
var i: integer;
var counter: integer = 1;
var current: string = '';
begin
    for i := 1 to integer(Length(str)) do
    begin
        if str[i] = d then
        begin
            if non_empty then
            begin
                counter := counter + 1;
                non_empty := false;
            end;
        end
        else
        begin
            non_empty := true;
        end;
    end;
    SetLength(arr^, counter);
    counter := 0;
    for i := 1 to integer(Length(str)) do
    begin
        if str[i] = d then
        begin
            if Length(current) <> 0 then
            begin
                Val(current, arr^[counter]);
                current := '';
                counter := counter + 1;
            end;
        end
        else
            current := current + str[i];
    end;
    Val(current, arr^[counter]);
end;

function ReadBingo(): bingop;
var cl: string;
var b: bingo;
var bp: bingop;
var i: integer;
var lineparts: intarrp;
begin
    ReadLn(cl);
    if integer(Length(cl)) = 0 then
        ReadBingo := nil
    else
    begin
        New(lineparts);
        for i := 0 to 4 do
        begin
            if i <> 0 then
            begin
                ReadLn(cl);
            end;
            SplitString(cl, ' ',  lineparts);
            b[i][0] := lineparts^[0];
            b[i][1] := lineparts^[1];
            b[i][2] := lineparts^[2];
            b[i][3] := lineparts^[3];
            b[i][4] := lineparts^[4];
        end;
        Dispose(lineparts);
        New(bp);
        bp^ := b;
        ReadBingo := bp;
    end;
end;

function HasInSubList(numbers: array of integer; count: integer; n: integer): boolean;
var i: integer = 0;
begin
    HasInSubList := false;
    for i := 0 to count do
        if numbers[i] = n then
        begin
            HasInSubList := true;
            break;
        end;
end;

function CheckWinPart(numbers: array of integer; count: integer; n1: integer; n2: integer; n3: integer; n4: integer; n5: integer): boolean;
begin
    CheckWinPart := HasInSubList(numbers, count, n1) and HasInSubList(numbers, count, n2) and HasInSubList(numbers, count, n3) and HasInSubList(numbers, count, n4) and HasInSubList(numbers, count, n5);
end;

function CheckWin(b: bingo; numbers: array of integer; count: integer): boolean;
begin
    CheckWin := CheckWinPart(numbers, count, b[0][0], b[0][1], b[0][2], b[0][3], b[0][4])
      or CheckWinPart(numbers, count, b[1][0], b[1][1], b[1][2], b[1][3], b[1][4])
      or CheckWinPart(numbers, count, b[2][0], b[2][1], b[2][2], b[2][3], b[2][4])
      or CheckWinPart(numbers, count, b[3][0], b[3][1], b[3][2], b[3][3], b[3][4])
      or CheckWinPart(numbers, count, b[4][0], b[4][1], b[4][2], b[4][3], b[4][4])
      or CheckWinPart(numbers, count, b[0][0], b[1][0], b[2][0], b[3][0], b[4][0])
      or CheckWinPart(numbers, count, b[0][1], b[1][1], b[2][1], b[3][1], b[4][1])
      or CheckWinPart(numbers, count, b[0][2], b[1][2], b[2][2], b[3][2], b[4][2])
      or CheckWinPart(numbers, count, b[0][3], b[1][3], b[2][3], b[3][3], b[4][3])
      or CheckWinPart(numbers, count, b[0][4], b[1][4], b[2][4], b[3][4], b[4][4]);
end;

function WinValue(b: bingo; numbers: array of integer; count: integer): LongInt;
var v: LongInt = 0;
var i: integer = 0;
var j: integer = 0;
begin
    if CheckWin(b, numbers, count) then
    begin
        for i := 0 to 4 do
            for j := 0 to 4 do
               if not HasInSubList(numbers, count, b[i][j]) then
                   v := v + b[i][j];
        WinValue := v * numbers[count];
    end
    else
        WinValue := -1;
end;

begin
    New(parts);
    ReadLn(line);
    SplitString(line, ',', parts);
    numbers := parts^;
    
    SetLength(bingos, 200);
    while true do
    begin
        ReadLn(line);
        current_bp := ReadBingo();
        if current_bp <> nil then
        begin
            bingo_length := bingo_length + 1;
            bingos[bingo_length] := current_bp^;
            Dispose(current_bp);
        end
        else
            break;
    end;
    
    for nc := 0 to Length(numbers) do
    begin
        for bc := 0 to bingo_length do
        begin
            wv := WinValue(bingos[bc], numbers, nc);
            if wv <> -1 then
            begin
                WriteLn(wv);
                exit();
            end;
        end;
    end;
end.