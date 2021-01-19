-- grid testing 2

engine.name = "PolyPerc"

steps = {}

g1 = grid.connect(1)
g2 = grid.connect(2)

function init()
  engine.amp(1)
  for i=1,16 do
    table.insert(steps,1)
  end
  grid_redraw()
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
  print("all off")
end

function keypress(x,y,z)
  if z==1 then
    steps[y]=x
    print(steps[1], steps[2], steps[3], steps[4])
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
    led(steps[i],i,15)
  end
  refresh()
end