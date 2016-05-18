TuningConfig = {}

local tuningConfig = {}
TuningConfig.config = tuningConfig

-- Получение цены и уровня для компонента
function TuningConfig.getComponentConfig(model, name, id)
	if id == 0 then
		return {price = 0, level = 0}
	end
	local conf = tuningConfig[model]
	if not conf then
		conf = tuningConfig.default
	end
	local componentsList = conf.components[name]
	if not componentsList then
		componentsList = {}
	end
	if name == "Wheels" then
		componentsList = tuningConfig.Wheels
	end
	return {price = componentsList[id], level = 0}
end

function TuningConfig.getComponentsCount(model, name)
	local conf = tuningConfig[model]
	if not conf then
		conf = tuningConfig.default
	end
	local componentsList = conf.components[name]
	if not componentsList then
		componentsList = {}
	end
	if name == "Wheels" then
		componentsList = tuningConfig.Wheels
	end
	return #componentsList
end

-- Цены на колёса
-- 17 стандартных колёс
tuningConfig.Wheels = {
	100,
	200,
	300,
	400,
	500,
	600,
	700,
	800,
	900,
	1000,
	1100,
	1200,
	1300,
	1400,
	1500,
	1600,
	1700
}

-- Цены на спойлеры
-- 20 стандартных спойлеров + спойлеры, уникальные для некоторых авто 
tuningConfig.Spoilers = {
	1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20
}

-- Настройки по умолчанию
-- используются, если для автомобиля не прописаны настройки
tuningConfig.default = {
	-- Стоковые компоненты всегда бесплатные
	components = {
		FrontBump 	= {},
		RearBump 	= {},
		SideSkirts 	= {},
		-- Указываются цены только на уникальные для машины спойлеры
		-- цены на общие для всех машин спойлеры указываются выше 
		Spoilers = {},
	}
}

----------------------------------- Настройки для отдельных машин -------------------------------------
tuningConfig[562] = {
	-- Цены на компоненты
	components = {
		FrontBump 	= {5000, 7500, 10000},
		RearBump 	= {5000, 7500, 10000},
		SideSkirts 	= {2500, 5000, 7500},
		Spoilers 	= {5000, 15000}
	}
}