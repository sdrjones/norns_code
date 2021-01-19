-- spacetime
-- norns study 3
--
-- ENC 1 - sweep filter
-- ENC 2 - select edit position
-- ENC 3 - choose command
-- KEY 3 - randomise command set
--
-- spacetime is a wierd function sequencer
-- it plays a note in each step
-- each step is a symbol for the action
-- + increase note
-- - decrease note
-- < goto bottom note
-- > goto top note
-- * random note
-- M fast metro
-- S slow metro
-- # jump random pos
-- 5 jump in 5's
-- 1 jump in 1's
-- 3 jump in 3's
-- $ random command

engine.name = "PolyPerc"

note = 40
position = 1
step = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
STEPS = 16
edit = 1
metroFast = 0.125
metroSlow = 0.25
jump = 5
mynextcall = inc
last = inc

function inc()
  note = util.clamp(note + jump, 40, 120)
  last = inc
end

function dec()
  note = util.clamp(note - jump, 40, 120)
  last = dec
end

function
  bottom() note = 40
  last = bottom
end

function
  top() note = 120
  last = top
end

function rand()
  note = math.random(80) + 40
  last = rand
end

function randcmd()
  act[math.random(COMMANDS)]()
end

function metrofast() counter.time = metroFast end
function metroslow() counter.time = metroSlow end
function positionrand() position = math.random(STEPS) end

function five()
  jump = 5 
  last()
end

function three()
  jump = 3
  last()
end

function one()
  jump = 1 
  last()
end

act = {inc, dec, bottom, top, rand, metrofast, metroslow, positionrand, five, three, one, randcmd}
COMMANDS = 12
label = {"+", "-", "<", ">", "*", "M", "S", "#", "5", "3", "1", "$"}


function init()
  engine.amp(1)
  mynextcall = inc
  last = inc
  params:add_control("cutoff","cutoff", controlspec.new(50, 5000, 'exp',0,555,'hz'))
  params:set_action("cutoff", function(x) engine.cutoff(x) end)
  counter = metro.init(count, metroFast, -1)
  counter:start()
end

function count()
  position = (position % STEPS) + 1
  mynextcall = act[step[position]]
  mynextcall()
  engine.hz(midi_to_hz(note))
  redraw()
end

function redraw()
  screen.clear()
  for i=1,16 do
    screen.level((i == edit) and 15 or 2)
    screen.move(i*8-8,40)
    screen.text(label[step[i]])
    if i == position then
      screen.move(i*8-8,45)
      screen.line_rel(6,0)
      screen.stroke()
    end
  end
  screen.update()
end

function enc(n,d)
  if n == 1 then
    params:delta("cutoff", d)
  elseif n == 2 then
    edit = util.clamp(edit + d, 1, STEPS)
  elseif n == 3 then
    step[edit] = util.clamp(step[edit]+d, 1, COMMANDS)
  end
  redraw()
end

function key(n,z)
  if n==3 and z==1 then
    randomize_steps()
  end
end

function randomize_steps()
  for i=1,16 do
    step[i] = math.random(COMMANDS)
  end
end
  
function midi_to_hz(note)
  local hz = (440/32) * (2 ^ ((note - 9) / 12))
  return hz
end

