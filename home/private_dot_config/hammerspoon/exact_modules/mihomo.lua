local mihomoSock = "/tmp/mihomo-party.sock"
local utunIP = "192.18.0.1"

local hs = hs
local menu = hs.menubar.new()
local modulePath = hs.configdir .. "/modules"
local mode, tunEnable = "", false

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

menu:setClickCallback(function()
	hs.application.launchOrFocus("Mihomo Party")
end)
updateMenu("", false)

local SOCK_HEADER, SOCK_CONTENT = 1, 2
local function configUpdate()
	local client
	client = hs.socket.new(function(data, tag)
		if tag == SOCK_HEADER then
			local contentLength = data:match("\r\nContent%-Length: (%d+)\r\n")
			client:read(tonumber(contentLength), SOCK_CONTENT)
		elseif tag == SOCK_CONTENT then
			local config = hs.json.decode(data)
			local newMode, newTunEnable = config.mode, config.tun.enable
			print(newMode, newTunEnable)
			if newMode ~= mode or newTunEnable ~= tunEnable then
				mode, tunEnable = newMode, newTunEnable
				updateMenu(mode, tunEnable)
			end
		end
	end)

	client:connect(mihomoSock, function()
		client:write("GET /configs HTTP/1.0\r\n\r\n", 0, function()
			client:read("\r\n\r\n", SOCK_HEADER)
		end)
	end)
end

local timer
local function safeConfigUpdate()
	if timer then
		timer:stop()
	end

	timer = hs.timer.doAfter(5, configUpdate)
end

appWatcher = hs.application.watcher
	.new(function(name, event, appObj)
		if name == "Mihomo Party" then
			if event == hs.application.watcher.launching or event == hs.application.watcher.deactivated then
				safeConfigUpdate()
			elseif event == hs.application.watcher.terminated then
				print(event)
				safeConfigUpdate()
			end
		end
	end)
	:start()

networkWatcher = hs.network.reachability.forAddress(utunIP):setCallback(safeConfigUpdate):start()

configUpdate()
