%% hanoi_web.pl: Tower of Hanoi web game powered by SWI-Prolog
%% Run:  swipl hanoi_web.pl     (then open http://localhost:8080/)

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_parameters)).

:- http_handler(root(.),    home_page,     []).
:- http_handler(root(solve), solve_handler, []).

:- initialization(start).

%% start(+Port): start the web server and open the browser.
start :- start(8080).
start(Port) :-
    http_server(http_dispatch, [port(Port)]),
    format(atom(URL), 'http://localhost:~d/', [Port]),
    format("Tower of Hanoi is running at ~w~n", [URL]),
    catch(www_open_browser(URL), _, true).

%% ---------------------------------------------------------------
%% Solver (same recursive logic as before)
%% ---------------------------------------------------------------

%% hanoi(+N, +From, +To, +Via): print the moves.
hanoi(N, From, To, Via) :-
    N > 0,
    N1 is N - 1,
    hanoi(N1, From, Via, To),                  % 1. move N-1 disks out of the way
    format("Move disk ~d from ~w to ~w~n", [N, From, To]),  % 2. move the biggest disk
    hanoi(N1, Via, To, From).                  % 3. move N-1 disks on top of it
hanoi(0, _, _, _).                             % base case: nothing to move

%% hanoi_moves(+N, +From, +To, +Via, -Moves): same recursion, returns a list.
hanoi_moves(N, From, To, Via, Moves) :-
    N > 0,
    N1 is N - 1,
    hanoi_moves(N1, From, Via, To, Before),
    hanoi_moves(N1, Via, To, From, After),
    append(Before, [move(N, From, To)|After], Moves).
hanoi_moves(0, _, _, _, []).

count_moves(N, Count) :-
    hanoi_moves(N, left, right, center, Moves),
    length(Moves, Count).

verify_moves(N) :-
    must_be(nonneg, N),
    count_moves(N, Count),
    Expected is 2^N - 1,
    (   Count =:= Expected
    ->  format("N = ~d: ~d moves, expected 2^~d - 1 = ~d. OK~n",
               [N, Count, N, Expected])
    ;   format("N = ~d: ~d moves, expected ~d. MISMATCH~n",
               [N, Count, Expected]),
        fail
    ).

%% ---------------------------------------------------------------
%% HTTP handlers
%% ---------------------------------------------------------------

%% /solve?n=5 -> JSON list of moves computed by Prolog (towers a, b, c)
solve_handler(Request) :-
    http_parameters(Request, [n(N, [integer, between(1, 10)])]),
    hanoi_moves(N, a, c, b, Moves),
    length(Moves, Count),
    maplist(move_dict, Moves, Dicts),
    reply_json_dict(_{n: N, count: Count, moves: Dicts}).

move_dict(move(D, F, T), _{disk: D, from: F, to: T}).

home_page(_Request) :-
    page_html(HTML),
    format("Content-type: text/html; charset=UTF-8~n~n"),
    write(HTML).

%% ---------------------------------------------------------------
%% The web page (HTML + CSS + JavaScript)
%% ---------------------------------------------------------------
page_html("<!doctype html>
<html lang='en'><head><meta charset='utf-8'>
<meta name='viewport' content='width=device-width, initial-scale=1'>
<title>Tower of Hanoi - Prolog Web Game</title>
<style>
body{font-family:Segoe UI,Arial,sans-serif;background:#0f2a5e;color:#eef3ff;margin:0;padding:20px;text-align:center}
h1{margin:0;font-size:26px}
.sub{color:#9fb4e6;font-size:13px;margin-bottom:14px}
.bar{display:flex;flex-wrap:wrap;gap:8px;justify-content:center;align-items:center;margin-bottom:8px}
input[type=number]{width:60px;padding:6px;border-radius:6px;border:0}
button{padding:7px 14px;border:0;border-radius:6px;background:#1fc8e8;color:#05233a;font-weight:600;cursor:pointer}
button.alt{background:#5a77b8;color:#fff}
#msg{min-height:22px;color:#ffd54f;font-size:14px}
#stats{font-size:13px;color:#b9c9ee;margin-bottom:6px}
.board{display:flex;justify-content:space-around;max-width:820px;margin:10px auto;height:270px}
.tower{position:relative;width:30%;display:flex;flex-direction:column;justify-content:flex-end;align-items:center;cursor:pointer;border-radius:8px}
.tower.sel{background:rgba(255,213,79,.15)}
.tower:before{content:'';position:absolute;bottom:0;width:8px;height:100%;background:#cfd8ee;border-radius:4px}
.disk{position:relative;height:22px;margin-top:2px;border-radius:6px;color:#111;font-size:12px;line-height:22px}
.lbl{max-width:820px;margin:0 auto;display:flex;justify-content:space-around;font-size:13px;color:#b9c9ee}
.lbl span{width:30%}
.panels{display:flex;flex-wrap:wrap;gap:14px;max-width:820px;margin:16px auto;text-align:left}
.panel{flex:1 1 300px;background:#173877;border-radius:8px;padding:10px 14px;font-size:13px}
.panel h3{margin:0 0 6px;font-size:14px}
#log{max-height:140px;overflow:auto}
</style></head><body>
<h1>Tower of Hanoi</h1>
<div class='sub'>A web game powered by Prolog</div>
<div class='bar'>
 <label>Number of disks (1-10): <input id='n' type='number' min='1' max='10' value='3'></label>
 <button onclick='newGame()'>New Game</button>
 <button onclick='autoSolve()'>Auto Solve (Prolog)</button>
 <button class='alt' onclick='pauseToggle()'>Pause</button>
 <button class='alt' onclick='nextStep()'>Next Step</button>
 <label>Speed <input id='spd' type='range' min='100' max='1000' value='700' oninput='speedChange()'></label>
</div>
<div id='msg'></div>
<div id='stats'></div>
<div class='board'>
 <div class='tower' id='ta' onclick=\"pick('a')\"></div>
 <div class='tower' id='tb' onclick=\"pick('b')\"></div>
 <div class='tower' id='tc' onclick=\"pick('c')\"></div>
</div>
<div class='lbl'><span>Tower A</span><span>Tower B</span><span>Tower C</span></div>
<div class='panels'>
 <div class='panel'><h3>Move log</h3><div id='log'></div></div>
 <div class='panel'><h3>How to play</h3>
  1. Move only one disk at a time.<br>
  2. Only the top disk of a tower can be moved.<br>
  3. Never put a bigger disk on a smaller one.<br>
  4. Move every disk from Tower A to Tower C.<br>
  Click a tower to pick its top disk, then click where to drop it.</div>
</div>
<script>
var n=3,pegs,moves=0,sel=null,plan=[],timer=null;
function el(i){return document.getElementById(i)}
function msg(t){el('msg').textContent=t}
function delay(){return 1100-parseInt(el('spd').value)}
function stop(){if(timer){clearInterval(timer);timer=null}}
function newGame(){
 stop();
 n=Math.max(1,Math.min(10,parseInt(el('n').value)||3));
 el('n').value=n;
 pegs={a:[],b:[],c:[]};
 for(var i=n;i>=1;i--)pegs.a.push(i);
 moves=0;sel=null;plan=[];el('log').innerHTML='';
 msg('New game started. Click a tower to pick its top disk.');
 draw();
}
function draw(){
 ['a','b','c'].forEach(function(k){
  var t=el('t'+k);t.innerHTML='';
  t.className='tower'+(sel===k?' sel':'');
  pegs[k].slice().reverse().forEach(function(d){
   var x=document.createElement('div');
   x.className='disk';
   x.style.width=(24+d*66/n)+'%';
   x.style.background='hsl('+(d*300/(n+1))+',70%,62%)';
   x.textContent=d;
   t.appendChild(x);
  });
 });
 el('stats').textContent='Moves made: '+moves+' | Minimum possible: '+(Math.pow(2,n)-1);
}
function move(f,t){
 var s=pegs[f],d=s[s.length-1];
 if(!d){msg('Tower '+f.toUpperCase()+' is empty.');return false}
 var top=pegs[t][pegs[t].length-1];
 if(top&&top<d){msg('Not allowed: a bigger disk cannot go on a smaller one.');return false}
 pegs[t].push(s.pop());moves++;
 var row=document.createElement('div');
 row.textContent='Move '+moves+': disk '+d+' from '+f.toUpperCase()+' to '+t.toUpperCase();
 el('log').prepend(row);
 draw();
 if(pegs.c.length===n){msg('Solved in '+moves+' moves!')}else{msg('')}
 return true;
}
function pick(k){
 if(plan.length)return;
 if(sel===null){if(pegs[k].length)sel=k}
 else{if(sel!==k)move(sel,k);sel=null}
 draw();
}
function step(){
 if(!plan.length){stop();return}
 var m=plan.shift();move(m.from,m.to);
 if(!plan.length)stop();
}
function run(){stop();timer=setInterval(step,delay())}
function autoSolve(){
 newGame();
 msg('Asking Prolog for the solution...');
 fetch('/solve?n='+n).then(function(r){return r.json()}).then(function(j){
  plan=j.moves;
  msg('Prolog found '+j.count+' moves. Playing them now.');
  run();
 }).catch(function(){msg('Could not reach the Prolog server.')});
}
function pauseToggle(){
 if(timer){stop();msg('Paused.')}else if(plan.length){run()}
}
function nextStep(){stop();step()}
function speedChange(){if(timer)run()}
newGame();
</script></body></html>").
