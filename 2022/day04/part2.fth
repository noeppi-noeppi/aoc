CREATE line-buf 128 ALLOT
VARIABLE line-idx
VARIABLE cnum
VARIABLE cidx

: READLN \ [4] -> continue
  128 0 DO 0 line-buf I + c! LOOP
  line-buf 128 STDIN READ-LINE THROW
  DROP DROP
  
  line-buf c@ 0 = IF
    DROP
    0
  ELSE
    0 line-idx !
    0 cnum !
    0 cidx !
    BEGIN
      line-buf line-idx @ + c@ 48 >=
      line-buf line-idx @ + c@ 57 <=
      AND IF
        line-buf line-idx @ + c@ 48 - cnum @ 10 * + cnum !
      ELSE
        DUP cidx @ CELL * + cnum @ SWAP !
        0 cnum !
        cidx @ 1 + cidx !
      THEN
      
      line-idx @ 1 + line-idx !
    line-buf line-idx @ + c@ 0 = UNTIL
    cidx @ CELL * + cnum @ SWAP !
    1
  THEN
;

CREATE buf 4 CELLS ALLOT
VARIABLE num
: READLNS \ -> num
  0 num !
  BEGIN
    buf READLN
    
    buf 0 CELL * + @ buf 2 CELL * + @ >=
    buf 0 CELL * + @ buf 3 CELL * + @ <=
    AND
    buf 1 CELL * + @ buf 2 CELL * + @ >=
    buf 1 CELL * + @ buf 3 CELL * + @ <=
    AND OR
    buf 2 CELL * + @ buf 0 CELL * + @ >=
    buf 2 CELL * + @ buf 1 CELL * + @ <=
    AND OR
    buf 3 CELL * + @ buf 0 CELL * + @ >=
    buf 3 CELL * + @ buf 1 CELL * + @ <=
    AND OR
    OVER AND IF
      num @ 1 + num !
    THEN
  0 = UNTIL
  num @
;

READLNS CR .

CR
BYE
