local home = os.getenv("HOME")
local mcliPath = home .. "/.local/bin/mcli"

local hs = hs
local menu = hs.menubar.new()
local modulePath = hs.configdir .. "/modules"
local mode, tunEnable = "", false

menu:setClickCallback(function()
	local output, success = hs.execute(mcliPath .. " mihomo dashboard -p", true)
	if success then
		hs.urlevent.openURL(output)
	end
end)

local function updateMenu(m, t)
	local imgPath
	if t then
		imgPath = modulePath .. "/" .. m .. ".png"
	else
		imgPath = modulePath .. "/disabled.png"
	end

	local img = hs.image.imageFromPath(imgPath)
	menu:setIcon(img:setSize({ w = 18, h = 18 }))
end

local function configUpdate()
	local output, success = hs.execute(mcliPath .. " mihomo configs", true)
	if success then
		local config = hs.json.decode(output)
		local newMode, newTunEnable = config.mode, config.tun.enable
		if newMode ~= mode or newTunEnable ~= tunEnable then
			mode, tunEnable = newMode, newTunEnable
			updateMenu(mode, tunEnable)
		end
	else
		updateMenu()
	end
end

configUpdate()
MIHOMO_TIMER = hs.timer.doAfter(5, function()
	configUpdate()
end)
