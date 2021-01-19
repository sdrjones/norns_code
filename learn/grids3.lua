-- grid testing 3

engine.name = "PolyPerc"

steps = {}

g1 = grid.connect(1)
g2 = grid.connect(2)
keys = midi.connect(1)

function init()
  engine.amp(1)
  for i=1,16 do
    table.insert(steps,1)
  end
  grid_redraw()
  position = 1
  counter = metro.init()
  counter.time = 0.1
  counter.count = -1
  counter.event = count
  counter:start()
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

g1.key = function(x,y,z)
  keypress(x,y,z)
end

g2.key = function(x,y,z)
  keypress(x, y+8, z)
end



function grid_redraw()
  all_off()
  for i=1,16 do
    led(steps[i],i,i==position and 15 or 0)
  end
  refresh()
end

function count()
  position = (position % 16) + 1
  --engine.hz(steps[position]*100)
  grid_redraw()
end


keys.event = function(data)
  local d = midi.to_msg(data)
  if d.type == "note_on" then
    engine.amp(d.vel / 127)
    engine.hz((440 / 32) * (2 ^ ((d.note - 9) / 12)))
  end
  if d.type == "cc" then
    print("cc " .. d.cc .. " = " .. d.val)
  end
end