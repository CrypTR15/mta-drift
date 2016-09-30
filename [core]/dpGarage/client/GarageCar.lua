-- Выбор автомобиля
GarageCar = {}

addEvent("dpGarage.loaded", false)

local CAR_POSITION = Vector3 { x = 2915.438, y = -3186.282, z = 2535.2 }
local vehicle
local vehiclesList = {}
local currentVehicle = 1
local currentTuningTable = {}

-- Время, на которое размораживается машина при смене модели
local unfreezeTimer

-- Дата, которая округляется при сохранении
local configurationData = {
	"WheelsOffsetF", 
	"WheelsOffsetR", 
	"WheelsWidthF", 
	"WheelsWidthR", 
	"WheelsAngleF", 
	"WheelsAngleR", 
	"WheelsSize",
	"Suspension"
}
-- Цвета, которые выставляются белыми по умолчанию и округляются
local colorsData = {
	"BodyColor", 
	"WheelsColorR", 
	"WheelsColorF", 
	"SpoilerColor"
}
-- Дата, которая копируется как есть
local copyData = {
	"Numberplate",
	"StreetHandling",
	"DriftHandling"
}

local function setData(key, value)
	vehicle:setData(key, value, false)
end

local function updateVehicle()
	if not vehiclesList[currentVehicle] then
		outputDebugString("Could not load vehicle: " .. tostring(currentVehicle))
		return
	end

	vehicle.model = vehiclesList[currentVehicle].model

	vehicle:setColor(255, 0, 0, 255, 255, 255)
	vehicle.position = CAR_POSITION

	currentTuningTable = {}
	if type(vehiclesList[currentVehicle].tuning) == "string" then
		currentTuningTable = fromJSON(vehiclesList[currentVehicle].tuning)
	end

	if isTimer(unfreezeTimer) then killTimer(unfreezeTimer) end
	unfreezeTimer = setTimer(function ()
		if currentTuningTable.Suspension and tonumber(currentTuningTable.Suspension) > 0.5 then
			vehicle.velocity = Vector3(0, 0, 0.01)
		else
			vehicle.velocity = Vector3(0, 0, -0.01)
		end
	end, 250, 2)	
	
	-- Наклейки
	local stickersJSON = vehiclesList[currentVehicle].stickers
	if stickersJSON then
		local stickers = fromJSON(stickersJSON)
		if type(stickers) ~= "table" then
			stickers = {}
		end
		setData("stickers", stickers)	
	else
		setData("stickers", {})
	end
	
	GarageCar.resetTuning()
	CarTexture.reset()
end

function GarageCar.getId()
	return vehiclesList[currentVehicle]._id
end

function GarageCar.start(car, vehicles)
	vehiclesList = vehicles
	currentVehicle = 1
	vehicle = car
	vehicle.position = CAR_POSITION
	--vehicle = createVehicle(411, CAR_POSITION)
	vehicle.rotation = Vector3(0, 0, -90)
	vehicle.dimension = localPlayer.dimension

	addEventHandler("dpGarage.loaded", resourceRoot, updateVehicle)

	setData("LightsState", false)
end

function GarageCar.stop()
	if isElement(vehicle) then
		destroyElement(vehicle)
	end
	removeEventHandler("dpGarage.loaded", resourceRoot, updateVehicle)
end

function GarageCar.getVehicle()
	return vehicle
end

function GarageCar.showNextCar()
	currentVehicle = currentVehicle + 1
	if currentVehicle > #vehiclesList then
		currentVehicle = 1
	end
	updateVehicle()
end

function GarageCar.showPreviousCar()
	currentVehicle = currentVehicle - 1
	if currentVehicle < 1 then
		currentVehicle = #vehiclesList
	end
	updateVehicle()
end

function GarageCar.showCarById(id)
	for i, vehicle in ipairs(vehiclesList) do
		if vehicle._id == id then
			currentVehicle = i
			updateVehicle()
			return true
		end
	end
	return false
end

function GarageCar.previewTuning(name, value)
	setData(name, value)
end

function GarageCar.previewHandling(name, value)
	vehicle:setData(name, value, true)
	triggerServerEvent("dpGarage.previewHandling", vehicle, name, value)
end

function GarageCar.applyTuning(name, value)
	if not value then
		value = vehicle:getData(name)
	else		
		vehicle:setData(name, value, false)
	end
	currentTuningTable[name] = value
end

function GarageCar.applyHandling(name, value)
	if not value then
		value = vehicle:getData(name)
	else
		GarageCar.previewHandling(name, value)
		vehicle:setData(name, value, false)
	end
	currentTuningTable[name] = value
end

function GarageCar.applyTuningFromData(name)
	currentTuningTable[name] = vehicle:getData(name)
end

function GarageCar.resetTuning()
	-- Сброс компонентов
	local componentNames = exports.dpVehicles:getComponentsNames()

	for i, name in ipairs(componentNames) do
		setData(name, currentTuningTable[name])
	end

	for i, name in ipairs(configurationData) do
		local value = currentTuningTable[name]
		if type(value) == "number" then
			setData(name, value)
		else
			setData(name, 0)
		end
	end

	-- Цвета
	if not currentTuningTable.BodyColor then
		currentTuningTable.BodyColor = {212, 0, 40}
	end
	for i, name in ipairs(colorsData) do
		if currentTuningTable[name] then
			setData(name, currentTuningTable[name])
		else
			setData(name, {255, 255, 255})
		end
	end
	--outputDebugString(tostring(vehicle.model) .. " color: " .. table.concat(vehicle:getData("BodyColor"), ", "))

	for i, name in ipairs(copyData) do
		setData(name, currentTuningTable[name])
	end

	-- Высота подвески	
	local suspensionHeight = currentTuningTable["Suspension"]
	if type(suspensionHeight) == "number" then
		GarageCar.applyHandling("Suspension", suspensionHeight)
	end

	-- Размер колёс по-умолчанию
	if not currentTuningTable["WheelsSize"] then
		local defaultWheelsSize = exports.dpVehicles:getModelDefaultWheelsSize(vehicle.model)
		if not defaultWheelsSize then
			defaultWheelsSize = 0.69
		end
		GarageCar.applyTuning("WheelsSize", defaultWheelsSize)
	end

	if not currentTuningTable["Numberplate"] then
		GarageCar.applyTuning("Numberplate", "DRIFT")
	end

	if not currentTuningTable["StreetHandling"] then
		GarageCar.applyTuning("StreetHandling", 0)
	end

	if not currentTuningTable["DriftHandling"] then
		GarageCar.applyTuning("DriftHandling", 0)
	end	
end

function GarageCar.getTuningTable()
	local componentNames = exports.dpVehicles:getComponentsNames()
	local tuningTable = {}
	for i, name in ipairs(componentNames) do
		tuningTable[name] = vehicle:getData(name)
	end

	for i, name in ipairs(configurationData) do
		tuningTable[name] = vehicle:getData(name)
		if type(tuningTable[name]) == "number" then
			tuningTable[name] = math.ceil(tuningTable[name] * 100) / 100
		end
	end	

	for i, name in ipairs(colorsData) do
		tuningTable[name] = vehicle:getData(name)
		if not tuningTable[name] then
			tuningTable[name] = {255, 255, 255}
		else
			for i, color in ipairs(tuningTable[name]) do
				tuningTable[name][i] = math.floor(color)
			end
		end
	end

	for i, name in ipairs(copyData) do
		tuningTable[name] = vehicle:getData(name)
	end
	
	return tuningTable
end

function GarageCar.save()
	CarTexture.save()
	local tuningTable = GarageCar.getTuningTable()
	vehiclesList[currentVehicle].tuning = toJSON(tuningTable)
	vehiclesList[currentVehicle].stickers = toJSON(vehicle:getData("stickers"))

	triggerServerEvent("dpGarage.saveCar", resourceRoot,
		currentVehicle, 
		tuningTable,
		vehicle:getData("stickers")
	)
end

function GarageCar.getComponentsCount(name)
	if not name then
		return 0
	end
	if 	name == "Spoilers" or 
		name == "Numberplate" or
		name == "WheelsF" or
		name == "WheelsR"
	then
		return 1
	end	
	local count = 0
	for i = 1, 50 do
		if not vehicle:getComponentPosition(name .. tostring(i)) then
			return count
		end
		count = count + 1
	end
	return count
end