-- strum
-- button 3 strums
-- button 2 flips mode
-- encoder 2: repeats in mode 1, time interval in mode 2
-- encoder 3: note interval

engine.name = "PolyPerc"

function init()
  repeats = 8
  interval = 5
  mode = 1
  space = 0.08
  strum = metro.init(note, 0.08, repeats)
end

function key(n,z)
  if n == 3 and z == 1 then
    strum:stop()
    strum.count = repeats
    strum.time = space
    root = 40 + math.random(12)*2
    engine.hz(midi_to_hz(root))
    strum:start()
  end
  if n == 2 then
    if z == 1 then
      mode = 2
    else
      mode = 1
    end
  end
end

function enc(n,d)
  if n == 2 and mode == 1 then
    repeats = (repeats + d) % 10
  elseif n == 2 and mode == 2 then
    space = ((space * 50) + d) / 50
  elseif n == 3 then
    interval = (interval + d) % 12
  end
end

function note(stage)
  engine.hz(midi_to_hz(root + stage * interval))
end

function midi_to_hz(note)
  return (440 / 32) * (2 ^ ((note - 9) / 12))
end