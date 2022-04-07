
gs = {
	math = {
		pi = 3.14159
	}
}

gs.math.piOver2 = gs.math.pi / 2
gs.math.piOver4 = gs.math.pi / 4
gs.math.twoPi = gs.math.pi * 2

-- Thanks kikito: https://stackoverflow.com/a/2626144/4500719
function gs.math.sign(x)
  return x>0 and 1 or x<0 and -1 or 0
end

function gs.math.clamp(value, min, max)
	return math.min(max, math.max(value, min))
end
