local function run(cmd)
	local output = hs.execute(cmd)
	if output == nil then
		return ""
	end
	return output:gsub("%s+$", "")
end

local preCarrier = ""
local function checkNetwork()
	local carrier = run("curl -s cip.cc  | awk -F: '/运营商/{print $2}' | xargs")
	if preCarrier == carrier then
		return
	end

	preCarrier = carrier

	if carrier == "移动" or carrier == "联通" then
		hs.alert.show("当前运营商: " .. carrier)
	end
end

KEEP = hs.timer.doEvery(60, checkNetwork)

checkNetwork()
