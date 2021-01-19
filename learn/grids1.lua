-- grid testing 1

engine.name = "PolyPerc"


g1 = grid.connect(1)
g2 = grid.connect(2)

function init()
  engine.amp(1)
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

function keypress(x,y,z)
  if z==1 then
    engine.hz(100+x*4+y*64)
    print("hz " .. 100+x*4+y*64)
  end
  led(x,y,z*15)
  refresh()
end

g1.key = function(x,y,z)
  keypress(x,y,z)
end

g2.key = function(x,y,z)
  keypress(x, y+8, z)
end