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
TX := 0
TY := 0
VST := []

GuiControlGet, INP,, TextInput
CMDS := StrSplit(INP, "`n")
for IDX, ELEM in CMDS {
    TK := StrSplit(ELEM, " ")
    Loop % TK[2] {
        Move(TK[1])
        CID := % TX . ":" . TY
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
    global TX
    global TY

    switch DIR {
        Case "U": HY -= 1
        Case "D": HY += 1
        Case "L": HX -= 1
        Case "R": HX += 1
    }
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
