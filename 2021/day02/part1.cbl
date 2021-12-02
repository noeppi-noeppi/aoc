       IDENTIFICATION DIVISION.
       PROGRAM-ID. PART1.
       
       DATA DIVISION.
           WORKING-STORAGE SECTION.
               01 DATA-LINE PIC X(16) VALUE IS ' '.
               01 DATA-NUM  PIC 9(16) VALUE IS 0.
               01 RESULT    PIC Z(16) VALUE IS 1.
               01 POS       PIC 9(16) VALUE IS 0.
               01 DEPTH     PIC 9(16) VALUE IS 0.
               
       
       PROCEDURE DIVISION.
           1000-READ-LINE.
               ACCEPT DATA-LINE.
               IF DATA-LINE IS NOT EQUAL TO ' '
               THEN GO TO 1001-PROCESS-INPUT
               ELSE GO TO 1005-DISPLAY-RESULT
               END-IF.
               
           1001-PROCESS-INPUT.
               IF DATA-LINE(1:7) IS EQUAL TO 'forward'
               THEN GO TO 1002-FORWARD
               ELSE IF DATA-LINE(1:2) IS EQUAL TO 'up'
               THEN GO TO 1003-UP
               ELSE IF DATA-LINE(1:4) IS EQUAL TO 'down'
               THEN GO TO 1004-DOWN
               ELSE GO TO 1000-READ-LINE
               END-IF.
           
           1002-FORWARD.
               MOVE DATA-LINE(9:) TO DATA-NUM.
               ADD DATA-NUM TO POS.
               GO TO 1000-READ-LINE.
           
           1003-UP.
               MOVE DATA-LINE(4:) TO DATA-NUM.
               SUBTRACT DATA-NUM FROM DEPTH.
               GO TO 1000-READ-LINE.
           
           1004-DOWN.
               MOVE DATA-LINE(6:) TO DATA-NUM.
               ADD DATA-NUM TO DEPTH.
               GO TO 1000-READ-LINE.
           
           1005-DISPLAY-RESULT.
               MULTIPLY POS BY DEPTH GIVING RESULT.
               DISPLAY RESULT.
               STOP RUN.
