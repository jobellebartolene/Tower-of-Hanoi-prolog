# Tower-of-Hanoi-prolog
Tower of Hanoi

**HOW TO RUN**

BEFORE YOU START
- SWI-Prolog must be installed. (Check later with: swipl --version)
- hanoi_web.pl must be saved in a folder, for example:
  C:\Users\Acer\Downloads\Tower of Hanoi


STEP 1: Open the folder that has hanoi_web.pl
  Open File Explorer and go to the folder.
  You should see hanoi_web.pl in the list.


STEP 2: Open Command Prompt INSIDE that folder (easiest way)
  1. Click the address bar at the top of File Explorer
     (the long box that shows the folder path).
  2. Type:  cmd
  3. Press Enter.
  A black window opens. Its last line should end with the folder name:
     C:\Users\Acer\Downloads\Tower of Hanoi>

  (Another way: open cmd from the Start menu, then type
     cd /d "C:\Users\Acer\Downloads\Tower of Hanoi"
   and press Enter.)


STEP 3: Check the file is there
  Type:   dir *.pl
  Press Enter. You should see hanoi_web.pl in the list.


STEP 4: Start the game server
  Type:   swipl hanoi_web.pl
  Press Enter.

  Wait for this message:
     % Started server at http://localhost:8080/
     Tower of Hanoi is running at http://localhost:8080/

  Then you will see a prompt like:  1 ?-
  That is normal. Do NOT close this window.


STEP 5: Open the game in Chrome
  1. Open Chrome.
  2. Click the address bar, type:  localhost:8080
  3. Press Enter.
  The Tower of Hanoi page appears with three towers.


STEP 6: Play
  - Set "Number of disks" (1 to 10), then click New Game.
  - Play by hand: click a tower to pick up its top disk,
    then click the tower where you want to drop it.
  - Or click "Auto Solve (Prolog)" and watch Prolog solve it.
  - "Pause", "Next Step" and the "Speed" slider control Auto Solve.
  - Minimum moves = 2^N - 1  (3 disks = 7 moves, 6 disks = 63 moves).


STEP 7: Stop the game
  1. Click the black cmd window.
  2. Type:  halt.
  3. Press Enter.
  (Do not forget the dot.) The server stops and the page will not
  load anymore until you start it again.


TO PLAY AGAIN LATER
  Repeat Steps 2, 4 and 5 only:
  open cmd in the folder -> swipl hanoi_web.pl -> localhost:8080


IF SOMETHING GOES WRONG
- "source_sink hanoi_web.pl does not exist"
    You are in the wrong folder. Do Step 2 again from the folder
    that contains hanoi_web.pl.

- "swipl is not recognized"
    Use the full path instead:
    "C:\Program Files\swipl\bin\swipl.exe" hanoi_web.pl

- "Address already in use"
    Another Prolog window is still running. Close it and try again.
    Or change 8080 to 8081 in hanoi_web.pl and open localhost:8081.

- Page will not load
    Make sure the cmd window is still open and still shows the
    "running at" message.

- Blank page
    In Chrome press Ctrl + Shift + R to reload.

- Windows Firewall popup
    Click Allow. The game only runs on your own computer.
