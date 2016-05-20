Panel = {}
local screenWidth, screenHeight = UI:getScreenSize()
local width = 500
local height = 380
local panel
-- Табы
local TABS_HEIGHT = 50
local tabsNames = {"account", "teleport", "settings", "garage", "map"}
local tabsButtons = {}
local tabs = {}
local tabsHandlers = {}
local currentTab

function Panel.create()
	if panel then
		return false
	end
	panel = UI:createDpPanel {
		x = (screenWidth - width) / 2,
		y = (screenHeight - height) / 1.7,
		width = width,
		height = height,
		type = "light"
	}
	UI:addChild(panel)

	if screenHeight >= 710 then
		local logoTexture = exports.dpAssets:createTexture("logo.png")
		local textureWidth, textureHeight = dxGetMaterialSize(logoTexture)
		local logoWidth = 415
		local logoHeight = textureHeight * 415 / textureWidth	
		local logoImage = UI:createImage({
			x = (width - logoWidth) / 2,
			y = -logoHeight - 25,
			width = logoWidth, 
			height = logoHeight,
			texture = logoTexture
		})
		UI:addChild(panel, logoImage)
	end

	-- Табы
	local tabWidth = width / #tabsNames
	for i, name in ipairs(tabsNames) do
		tabsButtons[name] = UI:createDpButton {
			x = (i - 1) * tabWidth,
			y = 0,
			width = tabWidth,
			height = TABS_HEIGHT,
			type = "default_dark",
			fontType = "defaultSmall",
			locale = "main_panel_tab_" .. name
		}
		UI:addChild(panel, tabsButtons[name])
	end
end

function Panel.addTab(name)
	local tab = UI:createDpPanel {
		x = 0, y = TABS_HEIGHT,
		width = width,
		height = height - TABS_HEIGHT,
		type = "transparent"
	}
	UI:addChild(panel, tab)
	UI:setVisible(tab, false)
	tabs[name] = tab
	return tab
end

function Panel.showTab(name)
	if not tabs[name] then
		if tabsHandlers[name] then
			tabsHandlers[name]()
		end
		return
	end
	if currentTab then
		UI:setVisible(tabs[currentTab], false)
		UI:setType(tabsButtons[currentTab], "default_dark")
	end
	currentTab = name
	UI:setVisible(tabs[currentTab], true)
	UI:setType(tabsButtons[currentTab], "primary")
end

function Panel.setVisible(visible)
	if UI:getVisible(panel) == not not visible then
		return
	end
	if not panel then
		return false
	end
	if not not visible then
		if not localPlayer:getData("username") or localPlayer:getData("dpCore.state") then
			return false
		end
	end
	UI:setVisible(panel, not not visible)
	exports.dpHUD:setVisible(not visible)
	UIDataBinder.setActive(visible)
	showCursor(not not visible)
end

function Panel.isVisible()
	return UI:getVisible(panel)
end

addEvent("dpUI.click", false)
addEventHandler("dpUI.click", resourceRoot, function (widget)
	for name, button in pairs(tabsButtons) do
		if widget == button then
			Panel.showTab(name)
			return
		end
	end 
end)

tabsHandlers.garage = function ()
	exports.dpGarage:enterGarage()
	localPlayer:setData("dpCore.state", "some_shiet", false)
	Panel.setVisible(false)
end

tabsHandlers.map = function ()
	exports.dpWorldMap:setVisible(true)
	Panel.setVisible(false)
end