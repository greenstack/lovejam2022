
gs = {
	math = {}
}

-- Thanks kikito: https://stackoverflow.com/a/2626144/4500719
function gs.math.sign(x)
  return x>0 and 1 or x<0 and -1 or 0
end
