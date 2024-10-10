RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer, isNew)

end)


AddEventHandler('esx:playerDropped', function(playerId, reason) -- When a player disconnects or logs out

end)



ESX.RegisterServerCallback("ultrax:garages:getVehiclesToImpound", function(source,cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND stored = 0 ', { 
		['@owner'] = xPlayer.identifier,
	}, function (result)
		if result[1] ~= nil then
			local vehicles = {}
			for _,v in pairs(result) do
				local vehicle = json.decode(v.vehicle)
				table.insert(vehicles, vehicle)
			end

			cb(vehicles)
		else
			cb({})
		end
	end)
end)

ESX.RegisterServerCallback("ultrax:garages:getVehiclesToImpoundPolice", function(source,cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE stored = 2 ', { 

	}, function (result)
		if result[1] ~= nil then
			local vehicles = {}
			for _,v in pairs(result) do
				local vehicle = json.decode(v.vehicle)
				table.insert(vehicles, vehicle)
			end

			cb(vehicles)
		else
			cb({})
		end
	end)
end)


ESX.RegisterServerCallback('ultrax:garages:getAllCars', function(source,cb,garaz)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND stored = 1 AND garage_id != @garage_id', { 
		['@owner'] = xPlayer.identifier,
		['@garage_id'] = garaz,
	}, function (result)
		if result[1] ~= nil then
			local vehicles = {}
			for _,v in pairs(result) do
				vehicles[#vehicles+1] = {vehicle = json.decode(v.vehicle), garage = v.garage_id}
			end
			cb(vehicles)
		else
			cb({})
		end
	end)
end)

ESX.RegisterServerCallback('ultrax:garages:getVehicles', function(source,cb, currentgarage)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND garage_id = @garage_id AND stored = 1 ', { 
		['@owner'] = xPlayer.identifier,
		['@garage_id'] = currentgarage,
	}, function (result)
		if result[1] ~= nil then
			local vehicles = {}
			for _,v in pairs(result) do
				local vehicle = json.decode(v.vehicle)
				table.insert(vehicles, vehicle)
			end
			
			cb(vehicles)
		else
			cb({})
		end
	end)
end)

RegisterServerEvent('ultrax:garages:updateState', function(vehPlate, storedId, garazyk)
	--print(vehPlate)
	MySQL.update('UPDATE owned_vehicles SET stored = ? WHERE plate = ?', {storedId, vehPlate}, function(affectedRows)

	end)
	if garazyk ~= nil then
		--print(garazyk, vehPlate)
		MySQL.update('UPDATE owned_vehicles SET garage_id = ? WHERE plate = ?', {garazyk, vehPlate}, function(affectedRows)

		end)
	end
end)

ESX.RegisterServerCallback('ultrax:garages:hideVehicle', function(source,cb,properties,garageName)
	local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE plate = @plate', { 
		['@plate'] = properties.plate,
	}, function (result)
		if result[1] ~= nil then
			if result[1].owner == xPlayer.identifier then
				MySQL.update('UPDATE owned_vehicles SET stored = ? WHERE plate = ?', {1, properties.plate}, function(affectedRows)
				end)
				MySQL.update('UPDATE owned_vehicles SET vehicle = ? WHERE plate = ?', {json.encode(properties), properties.plate}, function(affectedRows)
				end)
				MySQL.update('UPDATE owned_vehicles SET garage_id = ? WHERE plate = ?', {garageName, properties.plate}, function(affectedRows)
				end)
				cb(true)
			end
		else
			cb(false)
		end

	end)
end)


ESX.RegisterServerCallback('ultrax:garages:hasMoney', function(source,cb,amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getMoney() >= amount then
		cb(true)
	else
		cb(false)
	end
end)

ESX.RegisterServerCallback('ultrax:garages:impoundVehicle', function(source,cb,plate,properties)

	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE plate = @plate', { 
		['@plate'] = properties.plate,
	}, function (result)
		if result[1] ~= nil then
			MySQL.update('UPDATE owned_vehicles SET stored = ? WHERE plate = ?', {2, properties.plate}, function(affectedRows)
			end)
			MySQL.update('UPDATE owned_vehicles SET vehicle = ? WHERE plate = ?', {json.encode(properties), properties.plate}, function(affectedRows)
			end)
			MySQL.update('UPDATE owned_vehicles SET garage_id = ? WHERE plate = ?', {'Policyjny', properties.plate}, function(affectedRows)
			end)
			cb(true)
		else
			cb(false)
		end

	end)

end)

ESX.RegisterServerCallback('ultrax:garage:checkMoney', function(source,cb, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getMoney() >= amount then
		xPlayer.removeMoney(amount)
		cb(true)
	else
		cb(false)
	end
end)

RegisterServerEvent('ultrax:garage:swapGarage', function(tablica, garazog,garazto)
	--print(tablica,garazog,garazto)
	MySQL.update('UPDATE owned_vehicles SET garage_id = ? WHERE plate = ?', {garazto, tablica}, function(affectedRows)
		--print('swapped ;D')
	end)
end)

ESX.RegisterServerCallback('ultrax:garages:checkPlayers', function(source,cb)
	local all = ESX.GetPlayers()
	local playerTable = {}
	for i=1, #all, 1 do
		local xPlayer = ESX.GetPlayerFromId(all[i])
		playerTable[#playerTable+1] = xPlayer.source
	end

	cb(playerTable)
end)
