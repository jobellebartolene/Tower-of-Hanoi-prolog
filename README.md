# Tower-of-Hanoi-prolog
Tower of Hanoi

**HOW TO RUN**

Needs: SWI-Prolog installed, and hanoi_web.pl saved in a folder.

1. Open the folder that has hanoi_web.pl in File Explorer.
2. Click the address bar, type  cmd  and press Enter.
3. Type  swipl hanoi_web.pl  and press Enter.
   Wait for: Tower of Hanoi is running at http://localhost:8080/
   (Keep this black window open.)
4. Open Chrome and go to  localhost:8080
5. Set the number of disks, click New Game, then play by hand
   or click Auto Solve (Prolog).
6. To stop: click the black window, type  halt.  and press Enter.

Problems:
- "source_sink does not exist": you are in the wrong folder. Redo step 2.
- "swipl is not recognized": use
  "C:\Program Files\swipl\bin\swipl.exe" hanoi_web.pl
- "Address already in use": close the other Prolog window and try again.
