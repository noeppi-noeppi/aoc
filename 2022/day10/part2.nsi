!include LogicLib.nsh
!include nsDialogs.nsh

Var InputDialog
Var InputTextField

Name "AdventOfCode 2022 Day 10 Part 2"
OutFile "part2.exe"
Unicode True
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
  Push 2
  Pop $4
  StrCpy $5 "██"

  ${Do}
    !insertmacro SkipSpaces
    Pop $0
    Push $0
    ${If} $0 == ""
    ${AndIf} $4 >= 240
      ${ExitDo}
    ${EndIf}
    
    ${If} $0 == ""
      Push 240
      Pop $3
    ${Else}
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
    ${EndIf}
    
    ${If} $3 > $4
      IntOp $9 $4 + 1
      Var /GLOBAL i
      ${ForEach} $i $9 $3 + 1
         IntOp $8 $i - 1
         IntOp $8 $8 % 40
         ${If} $8 == 0
           StrCpy $5 "$5$\r$\n"
         ${EndIf}
         IntOp $6 $2 - 1
         IntOp $7 $2 + 1
         ${If} $8 >= $6
         ${AndIf} $8 <= $7
           StrCpy $5 "$5█"
         ${Else}
           StrCpy $5 "$5░"
         ${EndIf}
      ${Next}
      Push $3
      Pop $4
    ${EndIf}
  ${Loop}
  
    MessageBox MB_OK "$5"
FunctionEnd
