local mihomoSock = "/tmp/mihomo-party.sock"
local secret = "2314"
local mihomoHost = "127.0.0.1"
local port = "9090"
local mihomoApi = {
	ui = string.format("http://mihomo.x/ui/#/setup?hostname=%s&port=%s&secret=%s", mihomoHost, port, secret),
	config = string.format("http://%s/configs", mihomoHost),
}

local defaultHeaders = {
	["Authorization"] = string.format("Bearer %s", secret),
	["Content-Type"] = "application/json",
}
local utunIP = "192.18.0.1"

local hs = hs
local menu = hs.menubar.new()
local modulePath = hs.configdir .. "/modules"
local mode, tunEnable = "", false

menu:setClickCallback(function()
	hs.urlevent.openURL(mihomoApi.ui)
end)

local function updateMenu(m, t)
	local imgPath
	if t then
		imgPath = modulePath .. "/" .. m .. ".png"
	else
		imgPath = modulePath .. "/disabled.png"
	end

	print(imgPath)
	local img = hs.image.imageFromPath(imgPath)
	menu:setIcon(img:setSize({ w = 18, h = 18 }))
end

local function chanageMode(cMode)
	local code, result =
		hs.http.doRequest(mihomoApi.config, "PATCH", string.format('{"mode":"%s"}', cMode), defaultHeaders)
	print(code, result)
end

local function configUpdate()
	local code, result = hs.http.get(mihomoApi.config, defaultHeaders)
	print(code)
	if code == 200 then
		local config = hs.json.decode(result)
		local newMode, newTunEnable = config.mode, config.tun.enable
		if newMode ~= mode or newTunEnable ~= tunEnable then
			mode, tunEnable = newMode, newTunEnable
			updateMenu(mode, tunEnable)
		end
	else
		updateMenu()
	end
end

networkWatcher = hs.network.reachability.forAddress(utunIP):setCallback(configUpdate):start()

configUpdate()
