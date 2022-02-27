-- Require Vendor Module
function rvm(module)
	require("vendor." .. module .. "." .. module)
end
