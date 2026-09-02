local targetApp = "Helium"
local lostFocusTimer = nil

local appWatcher = hs.application.watcher.new(function(appName, eventType, app)

    print(appName)
    if appName ~= targetApp then
        return
    end

    -- 程序获得焦点
    if eventType == hs.application.watcher.activated then
        print(targetApp .. " activated")

        -- 取消之前的隐藏计时
        if lostFocusTimer then
            lostFocusTimer:stop()
            lostFocusTimer = nil
        end
    end


    -- 程序失去焦点
    if eventType == hs.application.watcher.deactivated then
        print(targetApp .. " lost focus")

        if lostFocusTimer then
            lostFocusTimer:stop()
        end

        lostFocusTimer = hs.timer.doAfter(5, function()

            local currentApp = hs.application.get(targetApp)

            if currentApp and not currentApp:isFrontmost() then
                currentApp:hide()
                print(targetApp .. " hidden")
            end

            lostFocusTimer = nil
        end)
    end

end)

appWatcher:start()
