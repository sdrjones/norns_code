local twin40h = {g1 = nil, g2 = nil, flipz = false, led_map = {}}

function empty(x,y,z)
end

local _twin40hkey = empty

function twin40h.init(flipz)
  if twin40h.g1 == nil then
    twin40h.g1 = grid.connect(1)
end
  if twin40h.g2 == nil then
    twin40h.g2 = grid.connect(2)
  end
  twin40h.flipz = false or flipz
  twin40h.g1.key = function(x,y,z)
    twin40h.key(y,9-x,z)
  end
  twin40h.g2.key = function(x,y,z)
    twin40h.key(y+8,9-x,z)
  end
  twin40h.device = twin40h
  twin40h.rows = 16
  twin40h.cols = 8
end

function twin40h.set_led_map(led_map)
    twin40h.led_map = led_map
end

function twin40h.connected()
  return twin40h.g1 ~= nil
end

function twin40h.flip_z(z)
  if (z == 15) then
    z = 0
  elseif (z > 0) then
    z = 15
  end
  return z
end

function twin40h.convert_z(z)
  return twin40h.led_map[z] or twin40h.flip_z(z)
end

function twin40h:led(y,x,z)
  local cg = twin40h.g1

  if y > 8 then
    cg = twin40h.g2
    y = y - 8
  end
  if (twin40h.flipz) then
    z = twin40h.convert_z(z)
  end
  --print("led " .. x .. " " .. y .. " " .. z)
  cg:led(9-x,y,z)
end

function twin40h:refresh()
  if (twin40h.g1) then
    twin40h.g1:refresh()
  end
  if (twin40h.g2) then
    twin40h.g2:refresh()
  end
end

function twin40h.key(x,y,z)
  _twin40hkey(x,y,z)
end



function twin40h.setkeyfunc(keyfunc)
  twin40h.key = keyfunc
end

function twin40h.off(cg, val)
  for x=1,8 do
    for y=1,8 do
      cg:led(x,y,val)
    end
  end
  cg:refresh()
end

function twin40h.setall(val)
  if twin40h.g1 then
    twin40h.off(twin40h.g1, val)
  end

  if twin40h.g2 then
    twin40h.off(twin40h.g2, val)
  end
end

function twin40h:all(val)
  twin40h.setall(val)
end

return twin40h
