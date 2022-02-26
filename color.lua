local Color = {}
setmetatable(Color, Color)

function Color.__call(t, r, g, b, a)
	-- Default to white
	return setmetatable({r = r or 1, g = g or 1, b = b or 1, a = a or 1}, Color)
end

function Color:__tostring()
	return "(R:" .. self.r .. ", G:" .. self.g .. ", B:" .. self.b .. ", A:" .. self.a .. ")"
end

function Color.values(self)
	return self.r, self.g, self.b, self.a
end

Color.Predefined = {
	black = Color(0, 0, 0),
	red = Color(1, 0, 0),
	green = Color(0, 1, 0),
	blue = Color(0, 0, 1),
	yellow = Color(1, 1, 0),
	magenta = Color(1, 0, 1),
	cyan = Color(0, 1, 1),
	white = Color(1, 1, 1),
}

return Color
