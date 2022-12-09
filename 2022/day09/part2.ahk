Gui,Add, text,,Info
Gui,Add,Edit,r10 w600 vTextInput
Gui,Add,Button,xs+200 gOK,OK

Gui,Show
Return

GuiClose:
ExitApp

OK:

HX := 0
HY := 0
TX1 := 0
TY1 := 0
TX2 := 0
TY2 := 0
TX3 := 0
TY3 := 0
TX4 := 0
TY4 := 0
TX5 := 0
TY5 := 0
TX6 := 0
TY6 := 0
TX7 := 0
TY7 := 0
TX8 := 0
TY8 := 0
TX9 := 0
TY9 := 0
VST := []

GuiControlGet, INP,, TextInput
CMDS := StrSplit(INP, "`n")
for IDX, ELEM in CMDS {
    TK := StrSplit(ELEM, " ")
    Loop % TK[2] {
        Move(TK[1])
        CID := % TX9 . ":" . TY9
        ISLEFT := HasNoEntry(VST, CID)
        if (ISLEFT) {
            VST.Push(CID)
        }
    }
}
MsgBox, % VST.MaxIndex()
return

Move(DIR) {
    global HX
    global HY
    global TX1
    global TY1
    global TX2
    global TY2
    global TX3
    global TY3
    global TX4
    global TY4
    global TX5
    global TY5
    global TX6
    global TY6
    global TX7
    global TY7
    global TX8
    global TY8
    global TX9
    global TY9

    switch DIR {
        Case "U": HY -= 1
        Case "D": HY += 1
        Case "L": HX -= 1
        Case "R": HX += 1
    }

    MoveTail(HX, HY, TX1, TY1)
    MoveTail(TX1, TY1, TX2, TY2)
    MoveTail(TX2, TY2, TX3, TY3)
    MoveTail(TX3, TY3, TX4, TY4)
    MoveTail(TX4, TY4, TX5, TY5)
    MoveTail(TX5, TY5, TX6, TY6)
    MoveTail(TX6, TY6, TX7, TY7)
    MoveTail(TX7, TY7, TX8, TY8)
    MoveTail(TX8, TY8, TX9, TY9)
}

MoveTail(ByRef HX, ByRef HY, ByRef TX, ByRef TY) {
    if (HX == TX) {
        if (HY > TY + 1) {
            TY := HY - 1
            Sleep, 0
        } else if (HY < TY - 1) {
            TY := HY + 1
            Sleep, 0
        }
    } else if (HY == TY) {
        if (HX > TX + 1) {
            TX := HX - 1
            Sleep, 0
        } else if (HX < TX - 1) {
            TX := HX + 1
            Sleep, 0
        }
    } else if (Abs(HX - TX) > 1 || Abs(HY - TY) > 1) {
        if (HX > TX) {
            TX += 1
            Sleep, 0
        } else {
            TX -= 1
            Sleep, 0
        }
        if (HY > TY) {
            TY += 1
            Sleep, 0
        } else {
            TY -= 1
            Sleep, 0
        }
    }
}

HasNoEntry(HARR, HVAL) {
    RESULT := 1
    for HIDX, HELEM in HARR {
		if (HELEM == HVAL) {
            RESULT := 0
            Sleep, 0
        }
    }
	return RESULT
}
