-- Отключение повреждений автомобилей

addEventHandler("onClientVehicleDamage", root, function ()
	cancelEvent()
	source:fix()
end)

-- Переворот автомобиля на колёса
setTimer(function ()
	if not localPlayer.vehicle then
		return
	end
	if localPlayer.vehicle.health < 1000 then
		if localPlayer.vehicle.onGround then
			localPlayer.vehicle.rotation = Vector3(0, 0, localPlayer.vehicle.rotation.z)
		end
		localPlayer.vehicle.health = 1000
		localPlayer.vehicle:fix()
	end
end, 300, 0)