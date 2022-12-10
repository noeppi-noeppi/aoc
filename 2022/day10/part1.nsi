!include LogicLib.nsh
!include nsDialogs.nsh

Var InputDialog
Var InputTextField

Name "AdventOfCode 2022 Day 10 Part 1"
OutFile "part1.exe"
Page custom nsInputPage nsInputPageLeave
Section
  SetOutPath $INSTDIR
SectionEnd

!macro ConsumeString
  Pop $7
  Pop $8
  StrCpy $9 $8 "" $7
  Push $9
  StrCpy $9 $8 $7
  Push $9
!macroend

!macro PushBack
  Pop $7
  Pop $8
  StrCpy $9 "$7$8"
  Push $9
!macroend

!macro SkipSpaces
  ${Do}
    Push 1
    !insertmacro ConsumeString
    Pop $7
    ${If} $7 != " "
    ${AndIf} $7 != "$\r"
    ${AndIf} $7 != "$\n"
      ${ExitDo}
    ${EndIf}
  ${Loop}
  Push $7
  !insertmacro PushBack
!macroend

!macro ParseNum
  Push 0
  Pop $6
  ${Do}
    !insertmacro SkipSpaces
    Push 1
    !insertmacro ConsumeString
    Pop $7
    ${Switch} $7
      ${Case} "0"
        IntOp $6 $6 * 10
        ${Break}
      ${Case} "1"
        IntOp $6 $6 * 10
        IntOp $6 $6 + 1
        ${Break}
      ${Case} "2"
        IntOp $6 $6 * 10
        IntOp $6 $6 + 2
        ${Break}
      ${Case} "3"
        IntOp $6 $6 * 10
        IntOp $6 $6 + 3
        ${Break}
      ${Case} "4"
        IntOp $6 $6 * 10
        IntOp $6 $6 + 4
        ${Break}
      ${Case} "5"
        IntOp $6 $6 * 10
        IntOp $6 $6 + 5
        ${Break}
      ${Case} "6"
        IntOp $6 $6 * 10
        IntOp $6 $6 + 6
        ${Break}
      ${Case} "7"
        IntOp $6 $6 * 10
        IntOp $6 $6 + 7
        ${Break}
      ${Case} "8"
        IntOp $6 $6 * 10
        IntOp $6 $6 + 8
        ${Break}
      ${Case} "9"
        IntOp $6 $6 * 10
        IntOp $6 $6 + 9
        ${Break}
      ${CaseElse}
        ${ExitDo}
    ${EndSwitch}
  ${Loop}
  Push $7
  !insertmacro PushBack
  Push $6
!macroend

Function nsInputPage
    nsDialogs::Create 1018
    Pop $InputDialog
  ${If} $InputDialog == error
        Abort
    ${EndIf}
  ${NSD_CreateRichEdit} 0 13u 100% -13u "Enter input."
    Pop $InputTextField
    nsDialogs::Show
FunctionEnd

Function nsInputPageLeave
    ${NSD_GetText} $InputTextField $0
  Push $0
  
  Push 1
  Pop $2
  Push 2
  Pop $3
  Push 0
  Pop $4
  Push 0
  Pop $5

  ${Do}
    !insertmacro SkipSpaces
    Pop $0
    Push $0
    ${If} $0 == ""
      ${ExitDo}
    ${EndIf}

    Push 4
    !insertmacro ConsumeString
    Pop $0

    ${If} $0 == "addx"
      !insertmacro SkipSpaces

      Push 1
      !insertmacro ConsumeString
      Pop $1
      ${If} $1 == "-"
        !insertmacro ParseNum
        Pop $1
        IntOp $2 $2 - $1
      ${Else}
        Push $1
        !insertmacro PushBack
        !insertmacro ParseNum
        Pop $1
        IntOp $2 $2 + $1
      ${EndIf}
      IntOp $3 $3 + 2
    ${Else}
      IntOp $3 $3 + 1
    ${EndIf}
    
    ${If} $3 >= 20
    ${AndIf} $4 < 20
      IntOp $9 $2 * 20
      IntOp $5 $5 + $9
      Push 20
      Pop $4
    ${ElseIf} $3 >= 60
    ${AndIf} $4 < 60
      IntOp $9 $2 * 60
      IntOp $5 $5 + $9
      Push 60
      Pop $4
    ${ElseIf} $3 >= 100
    ${AndIf} $4 < 100
      IntOp $9 $2 * 100
      IntOp $5 $5 + $9
      Push 100
      Pop $4
    ${ElseIf} $3 >= 140
    ${AndIf} $4 < 140
      IntOp $9 $2 * 140
      IntOp $5 $5 + $9
      Push 140
      Pop $4
    ${ElseIf} $3 >= 180
    ${AndIf} $4 < 180
      IntOp $9 $2 * 180
      IntOp $5 $5 + $9
      Push 180
      Pop $4
    ${ElseIf} $3 >= 220
    ${AndIf} $4 < 220
      IntOp $9 $2 * 220
      IntOp $5 $5 + $9
      Push 220
      Pop $4
    ${EndIf}
  ${Loop}
  
  MessageBox MB_OK $5
FunctionEnd
