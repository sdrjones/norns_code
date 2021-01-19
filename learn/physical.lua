-- physical
-- norns study 4
--
-- grid controls arpeggio
-- midi controls root note
-- ENC2 = bpm
-- ENC3 = scale

engine.name = 'PolyPerc'

music = require 'musicutil'
beatclock = require 'beatclock'

steps = {}
position = 1
transpose = 0
beatupdate = 1

mode = math.random(#music.SCALES)
scale = music.generate_scale_of_length(60,music.SCALES[mode].name,8)

function init()
  for i=1,16 do
    table.insert(steps,math.random(8))
  end
  grid_redraw()
  clock.run(count)
  pulse = metro.init(led_pulse, 0.05, 1)
end

function enc(n,d)
  if n == 1 then
    params:delta("clock_source",d)
  elseif n == 2 then
    params:delta("clock_tempo",d)
  elseif n == 3 then
    mode = util.clamp(mode + d, 1, #music.SCALES)
    scale = music.generate_scale_of_length(60,music.SCALES[mode].name,8)
  end
  redraw()
end

function led(x,y,z)
  local g = g1
  if y > 8 then
    g = g2
    y = y - 8
  end
  g:led(x,y,z)
end

function refresh()
  g1:refresh()
  g2:refresh()
end

function all_off()
  for x=1,8 do
    for y=1,8 do
      g1:led(x,y,0)
      g2:led(x,y,0)
    end
  end
  refresh()
end

function keypress(x,y,z)
  if z==1 then
    steps[y]=x
    grid_redraw()
  end
end

function redraw()
  screen.clear()
  screen.level(15)
  screen.move(0,20)
  screen.text("clock source: "..params:string("clock_source"))
  screen.move(0,30)
  screen.text("bpm: "..params:get("clock_tempo"))
  screen.move(0,40)
  screen.text(music.SCALES[mode].name)
  screen.update()
end

g1 = grid.connect(1)
g2 = grid.connect(2)
keys = midi.connect(1)

--g.key = function(x,y,z)
--  if z == 1 then
--    steps[x] = 9-y
--    grid_redraw()
--  end
--end

g1.key = function(x,y,z)
  keypress(x,y,z)
end

g2.key = function(x,y,z)
  keypress(x, y+8, z)
end


function grid_redraw()
  all_off()
  for i=1,16 do
    led(steps[i],i,((i==position) and (beatupdate==1)) and 0 or 15)
  end
  refresh()
end

function count()
  while true do
    clock.sync(1/4)
    position = (position % 16) + 1
    engine.hz(music.note_num_to_freq(scale[steps[position]] + transpose))
    beatupdate = 1
    pulse:stop()
    pulse:start()
    grid_redraw()
    redraw() -- for bpm changes on LINK, MIDI, or crow
  end
end

function led_pulse(stage)
  beatupdate = 0
  grid_redraw()
end

keys = midi.connect(1)
keys.event = function(data)
  local d = midi.to_msg(data)
  if d.type == "note_on" then
    transpose = d.note - 60
  end
end