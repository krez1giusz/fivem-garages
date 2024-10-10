
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData, isNew) -- When a player loads

end)


RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function() -- When a player logs out

end)

CreateThread(function()
	Wait(500)
	--print(json.encode(Ultrax.Garaze))
	x = Ultrax.Garaze
	for i=1,#x do
		exports.ox_target:addSphereZone({
			coords = vector3(x[i].pedCoords.x,x[i].pedCoords.y,x[i].pedCoords.z+0.9),
			radius = 2.5,
			debug = false,
			options = {
				{
					name = 'garaz_open',
					action = function()
						openGarage(x[i].garageName)
					end,
					icon = 'fa-solid fa-warehouse',
					label = 'Otwórz swój garaż',
				}
			}
		})
		ESX.SpawnPed(x[i].pedModel, x[i].pedCoords, x[i].heading)
	end
	for i=1,#Ultrax.Impounds do
		exports.ox_target:addSphereZone({
			coords = vector3(Ultrax.Impounds[i].pedCoords.x,Ultrax.Impounds[i].pedCoords.y,Ultrax.Impounds[i].pedCoords.z+0.9),
			radius = 1.5,
			debug = false,
			options = {
				{
					name = 'impound_open',
					action = function()
						openImpound(Ultrax.Impounds[i].garageName)
					end,
					icon = 'fa-solid fa-warehouse',
					label = 'Odholuj swoje pojazdy',
				}
			}
		})
		ESX.SpawnPed(Ultrax.Impounds[i].pedModel,Ultrax.Impounds[i].pedCoords,Ultrax.Impounds[i].heading)
	end
	for i=1,#Ultrax.PoliceImpounds do
		exports.ox_target:addSphereZone({
			coords = vector3(Ultrax.PoliceImpounds[i].pedCoords.x,Ultrax.PoliceImpounds[i].pedCoords.y,Ultrax.PoliceImpounds[i].pedCoords.z+0.9),
			radius = 1.5,
			debug = false,
			options = {
				{
					name = 'impound_open',
					action = function()
						openPoliceImpound(Ultrax.PoliceImpounds[i].garageName)
					end,
					icon = 'fa-solid fa-warehouse',
					label = 'Sprawdź listę pojazdów',
				}
			}
		})
		ESX.SpawnPed(Ultrax.PoliceImpounds[i].pedModel,Ultrax.PoliceImpounds[i].pedCoords,Ultrax.PoliceImpounds[i].heading)
	end
	CreateBlips()
end)



CreateBlips = function()
	blips = {}
	for k,v in next, Ultrax.Garaze do
		if v.blip.type ~= -1 then
			blips[k] = AddBlipForCoord(v.Center.x, v.Center.y, v.Center.z)
            SetBlipSprite (blips[k], v.blip.type)
            SetBlipDisplay(blips[k], 4)
            SetBlipScale (blips[k], v.blip.scale)
            SetBlipColour (blips[k], v.blip.colour)
            SetBlipAsShortRange(blips[k], true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(v.blip.name)
            EndTextCommandSetBlipName(blips[k])
		end
	end
end

openPoliceImpound = function(garaz)
	impoundTable = {}
	ESX.TriggerServerCallback('ultrax:garages:getVehiclesToImpoundPolice', function(vehicles)
		if #vehicles > 0 then
			for i=1, #vehicles do
				impoundTable[#impoundTable] = {
					title =  GetDisplayNameFromVehicleModel(vehicles[i].model),
					description = vehicles[i].plate,
					image = retrieveImage(vehicles[i].model),
					arrow = true,
					colorScheme = 'blue',
					onSelect = function()
						lib.hideContext()
						ESX.ShowNotification('Pojazd zostal odholowany na parking obok!', 4000, 'error')
						TriggerServerEvent('ultrax:garages:updateState', vehicles[i].plate,1,'Policyjny')
					end,
					metadata = {
					  {
						['label'] = 'Karoseria',
						['value'] =  math.floor((vehicles[i].bodyHealth/10 ))..'%',
						['progress'] = vehicles[i].bodyHealth,
					  },
					  {
						['label'] = 'Silnik',
						['value'] = math.floor((vehicles[i].engineHealth/10 ))..'%',
						['progress'] = vehicles[i].engineHealth,
					  },
					  {
						['label'] = 'Olej',
						['progress'] = 55,
					  },
					  {
						['label'] = 'Paliwo',
						['progress'] = math.floor(vehicles[i].fuelLevel),
					  },
					},
				}
			end

			lib.registerContext({
				id = 'odholownikpd',
				title = 'Odholownik LSPD',
				options = impoundTable
			  })
			lib.showContext('odholownikpd')

			--print(json.encode(vehicles))
		else
			ESX.ShowNotification("Brak skonfiskowanych pojazdów!", 4000, 'error')		
	
		end


		--json.encode(vehicles)

	end)
end


RegisterCommand('gracze', function()
	ESX.TriggerServerCallback('ultrax:garages:checkPlayers', function(players)
		for i=1,#players do
			ped = GetPlayerPed(GetPlayerFromServerId(players[i]))
			if IsPedInAnyVehicle(ped) then
				print('w samochodzie')
			else
				print('poza fura')
			end
		end
	end)
end)



checkVehToImpound = function()
	ESX.TriggerServerCallback('ultrax:garages:checkPlayers', function(players)
		for i=1,#players do
			ped = GetPlayerPed(GetPlayerFromServerId(players[i]))
			if IsPedInAnyVehicle(ped) then

				print('w samochodzie')
			else
				print('poza fura')
			end
		end
	end)
end




RegisterCommand('getvehp', function()
	local allVehicles = exports.ultrax_devScript:EnumVehs()
	for v in allVehicles do
		print(v)
		print(GetVehicleNumberPlateText(v))
	end
	--print(GetVehicleEngineHealth(GetVehiclePedIsIn(PlayerPedId())))
end)
RegisterCommand('waterh', function()
	print(IsEntityInWater(GetVehiclePedIsIn(PlayerPedId(), true)))
end)

openImpound = function(garaz)
	impoundTable = {}
	ESX.TriggerServerCallback('ultrax:garages:getVehiclesToImpound', function(vehicles)
		if #vehicles > 0 then
			for i=1, #vehicles do
				print(vehicles[i].plate)
				impoundTable[#impoundTable+1] = {
					title =  GetDisplayNameFromVehicleModel(vehicles[i].model),
					description = vehicles[i].plate,
					image = retrieveImage(vehicles[i].model),
					arrow = true,
					colorScheme = 'blue',
					onSelect = function()
						local onMap = isVehicleOnMap(vehicles[i].plate)
						local bodyhealth = GetVehicleBodyHealth(onMap)
						local enghealth = GetVehicleEngineHealth(onMap)
						local inwater = IsEntityInWater(onMap)
						local waterh = GetEntitySubmergedLevel(onMap)
						if onMap then
							if bodyhealth <= 0 or enghealth <= 0 or inwater or waterh >= 0.35 then
								ESX.TriggerServerCallback("ultrax:garages:hasMoney", function(has)
									if has then
		
										lib.progressBar({
											duration = 10000,
											label = 'Odholowywanie pojazdu....',
											useWhileDead = false,
											canCancel = false,
										})
		
										TriggerServerEvent('ultrax:garages:updateState', vehicles[i].plate,1,'Odholownik')
										ESX.ShowNotification('Pojazd o tablicach: '..vehicles[i].plate..' został odholowany!', 4000, 'success')
									else
										ESX.ShowNotification('Potrzebujesz: '..Ultrax.Prices.Impound..'$!', 4000, 'error')
									end
								end, Ultrax.Prices.Impound)
								return
							else
								ESX.ShowNotification('Pojazd jest już poza garażem...', 4000, 'error')
							end
						else
							ESX.TriggerServerCallback("ultrax:garages:hasMoney", function(has)
								if has then
	
									lib.progressBar({
										duration = 10000,
										label = 'Odholowywanie pojazdu....',
										useWhileDead = false,
										canCancel = false,
									})
	
									TriggerServerEvent('ultrax:garages:updateState', vehicles[i].plate,1,'Odholownik')
									ESX.ShowNotification('Pojazd o tablicach: '..vehicles[i].plate..' został odholowany!', 4000, 'success')
								else
									ESX.ShowNotification('Potrzebujesz: '..Ultrax.Prices.Impound..'$!', 4000, 'error')
								end
							end, Ultrax.Prices.Impound)
							return
						end
						lib.hideContext()
					end,
					metadata = {
					  {
						['label'] = 'Karoseria',
						['value'] =  math.floor((vehicles[i].bodyHealth/10 ))..'%',
						['progress'] = vehicles[i].bodyHealth,
					  },
					  {
						['label'] = 'Silnik',
						['value'] = math.floor((vehicles[i].engineHealth/10 ))..'%',
						['progress'] = vehicles[i].engineHealth,
					  },
					  {
						['label'] = 'Olej',
						['progress'] = 55,
					  },
					  {
						['label'] = 'Paliwo',
						['progress'] = math.floor(vehicles[i].fuelLevel),
					  },
					},
				}
			end

			lib.registerContext({
				id = 'Odholownik',
				title = 'Odholownik',
				options = impoundTable
			  })
			lib.showContext('Odholownik')

			--print(json.encode(vehicles))
		else
			ESX.ShowNotification("Nie posiadasz pojazdów do odholowania!", 4000, 'error')		
		end


		--json.encode(vehicles)

	end)
end


RegisterCommand('gar', function()
	local vehicles = ESX.Game.GetVehiclesInArea(GetEntityCoords(PlayerPedId()), 1500)
	for i=1, #vehicles do
		local plate = GetVehicleNumberPlateText(vehicles[i])
		if plate == '23QBA543' then
			local engHealth = GetVehicleEngineHealth(vehicles[i])
			if engHealth >= 150.0 then
				ESX.ShowNotification('Auto stoi gdzieś zaparkowane!', 4000, 'info')
			else
				print('impounding car')
			end
		else
			print('Cardoesnotexist, impound')
		end
		print(vehicles[i])
	end

end)

RegisterCommand('olej', function()
	print(GetVehicleOilLevel(GetVehiclePedIsIn(PlayerPedId())))
end)



RegisterCommand('impoundlspd', function()
	setVehicleImpounded()

end)

setVehicleImpounded = function()
	ped = PlayerPedId()
	if IsPedInAnyVehicle(PlayerPedId(), true) then
		plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), true))
		ESX.TriggerServerCallback('ultrax:garages:impoundVehicle', function(isOwned, plate, properties)
			if isOwned then
				ESX.Game.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId(), true))
			else
				ESX.ShowNotification('Pojazd nie należy do żadnego z obywateli tego stanu!', 4000, 'error')
			end
		end, plate, ESX.Game.GetVehicleProperties(GetVehiclePedIsIn(PlayerPedId(), true)))
	else
		ESX.ShowNotification('Musisz znajdować się pojeździe!', 4000, 'error')
	end
end


retrieveImage = function(vehicleModel)
	return Ultrax.Images[string.lower(GetDisplayNameFromVehicleModel(vehicleModel))]
end





-- RegisterCommand('getpoint', function()
-- 	coords = GetEntityCoords(PlayerPedId(), true)
-- 	print(GetPointOnRoadSide(coords.x,coords.y,coords.z,true))
-- end)

-- RegisterCommand('gmodel', function() 
--   print(retrieveImage(GetEntityModel(GetVehiclePedIsIn(PlayerPedId()))))
-- end)


openGarage = function(whichgarage)
	--print("Garaż: "..whichgarage)
	vehicleTable = {}
	ESX.TriggerServerCallback('ultrax:garages:getVehicles', function(vehicles, currentgarage)
		if vehicles ~= nil then
		  for i=1, #vehicles do
			--print(json.encode(vehicles[i]))
			vehicleTable[#vehicleTable+1] = {
				title =  GetDisplayNameFromVehicleModel(vehicles[i].model),
				description = vehicles[i].plate,
				image = retrieveImage(vehicles[i].model),
				arrow = true,
				colorScheme = 'blue',
				onSelect = function()
					lib.hideContext()
					spawnVehicle(vehicles[i].plate, vehicles[i].model, whichgarage,vehicles[i])
				end,
				metadata = {
				  {
					['label'] = 'Karoseria',
					['value'] =  math.floor((vehicles[i].bodyHealth/10 ))..'%',
					['progress'] = vehicles[i].bodyHealth,
				  },
				  {
					['label'] = 'Silnik',
					['value'] = math.floor((vehicles[i].engineHealth/10 ))..'%',
					['progress'] = vehicles[i].engineHealth,
				  },
				  {
					['label'] = 'Olej',
					['progress'] = 55,
				  },
				  {
					['label'] = 'Paliwo',
					['progress'] = math.floor(vehicles[i].fuelLevel),
				  },
				},
			}
		  end
		else
		  ESX.ShowNotification('Nie posiadasz żadnych pojazdów!')
		end
		vehicleTable[#vehicleTable+1] = {
			title = 'Namierz pojazd',
			description = 'Możliwy transport pojazdu',
			arrow = false,
			colorScheme = 'blue',
			onSelect = function()
				lib.hideContext()
				openTransferMenu()
			end,
		}
		lib.registerContext({
		  id = 'garazeXd',
		  title = 'GARAŻ: '..whichgarage,
		  options = vehicleTable
		})
		lib.showContext('garazeXd')
	  end, whichgarage)
end



getCurrentGarage = function()
	pc = GetEntityCoords(PlayerPedId(), true)
	for i=1, #Ultrax.Garaze do
		if #(Ultrax.Garaze[i].Center - pc) <= 30.0 then
			--print('yessir')
			return Ultrax.Garaze[i].garageName
		end
	end
end

CurrentGarageCenter = function()
	pc = GetEntityCoords(PlayerPedId(), true)
	for i=1, #Ultrax.Garaze do
		if #(Ultrax.Garaze[i].Center - pc) <= Ultrax.Garaze[i].Radius then
			return Ultrax.Garaze[i].Center
		end
	end
end



openTransferMenu = function()
	vehicleTable = {}
	ESX.TriggerServerCallback('ultrax:garages:getAllCars', function(table)


		if #table > 0 then
			for i=1, #table do
				vehicleTable[#vehicleTable+1] = {
					title =  GetDisplayNameFromVehicleModel(table[i].vehicle.model),
					description = table[i].garage..' | '..table[i].vehicle.plate,
					image = retrieveImage(table[i].vehicle.model),
					arrow = true,
					colorScheme = 'blue',
					onSelect = function()
						lib.hideContext()
						CompletePrompt(table[i].vehicle.plate, table[i].garage, getCurrentGarage())
						--transferVehicle(table[i].vehicle.plate, table[i].garage, getCurrentGarage())
					end,
					metadata = {
					  {
						['label'] = 'Karoseria',
						['value'] =  math.floor((table[i].vehicle.bodyHealth/10 ))..'%',
						['progress'] = table[i].vehicle.bodyHealth,
					  },
					  {
						['label'] = 'Silnik',
						['value'] = math.floor((table[i].vehicle.engineHealth/10 ))..'%',
						['progress'] = table[i].vehicle.engineHealth,
					  },
					  {
						['label'] = 'Olej',
						['progress'] = 55,
					  },
					  {
						['label'] = 'Paliwo',
						['progress'] = math.floor(table[i].vehicle.fuelLevel),
					  },
					},
				}
			end
			lib.registerContext({
				id = 'transfer',
				title = 'Namierzanie',
				options = vehicleTable
			  })
			  lib.showContext('transfer')
		else
			ESX.ShowNotification('Nie masz żadnych pojazdów do namierzenia!', 4000, 'error')
		end
	end, getCurrentGarage())
end


CompletePrompt = function(plate,garazog,garazto)
	lib.registerContext({
		id = 'acceptTransfer',
		title = "LOKAJ | Skorzystanie z transportu pojazdu: "..Ultrax.Prices.Transfer..'$',
		options = {
			{
				title = 'Sprowadź pojazd',
				description = plate,
				icon = 'circle-check',
				onSelect = function()
					lib.hideContext()
					transferVehicle(plate, garazog, garazto)
				end,
			},
			{
				title = 'Anuluj',
				icon = 'circle-xmark',
				onSelect = function()
					lib.hideContext()
					openTransferMenu()
				end,
			},
		}
	})
	lib.showContext('acceptTransfer')
end


transferVehicle = function(tablice, garazog,garazto)
	--print(tablice,garazog,garazto)
	ESX.TriggerServerCallback('ultrax:garage:checkMoney', function(canTransfer) 
		if canTransfer then
			lib.progressBar({
				duration = 1000, --Ultrax.Transfer.ProgressTime,
				label = 'Pojazd jest dostarczany....',
				useWhileDead = false,
				canCancel = false,
			})
			Wait(1000)--Ultrax.Transfer.ProgressTime)
			TriggerServerEvent('ultrax:garage:swapGarage', tablice, garazog, garazto)
			ESX.ShowNotification('Pojazd dostarczony, możesz go wyciągnąc z garażu!', 4000, 'success')
		else
			ESX.ShowNotification('Nie posiadasz wystarczającej ilości gotówki, do tego potrzebujesz: '..Ultrax.Prices.Transfer..'$!', 4000, 'error')
		end
	end, Ultrax.Prices.Transfer)
end

spawnVehicle = function(plate, vehicle, garage, properties)

	garaz = Ultrax.Garaze
	for i=1, #garaz do

		if garaz[i].garageName == garage then
			spawnpoints =  garaz[i].VehicleSpawnPoints

			for i=1, #spawnpoints do
				if not IsAnyVehicleNearPoint(spawnpoints[i].pos.x, spawnpoints[i].pos.y, spawnpoints[i].pos.z, 2.65) then
					ESX.Game.SpawnVehicle(vehicle, spawnpoints[i].pos, spawnpoints[i].heading, function(pojazd)
						ESX.Game.SetVehicleProperties(pojazd, properties) 
						SetVehicleDoorsLocked(pojazd, 2)
						SetEntityHeading(pojazd, spawnpoints[i].heading)
						TriggerServerEvent('ultrax:garages:updateState', plate,0)
					end, true)
					return
				end
			end
		end
	end
end

exports("hideVehicle", function()
	pc = GetEntityCoords(PlayerPedId(), true)
	for i=1, #Ultrax.Garaze do
		if CurrentGarageCenter() then
			playerVehicle = GetVehiclePedIsIn(PlayerPedId(), true)
			vproperties = ESX.Game.GetVehicleProperties(playerVehicle)

			ESX.TriggerServerCallback('ultrax:garages:hideVehicle', function(isOwned, properties)
				if isOwned then
					TaskLeaveVehicle(PlayerPedId(), playerVehicle, 0)
					Wait(2000)
					ESX.Game.DeleteVehicle(playerVehicle)
				else
					ESX.ShowNotification('Ten pojazd nie należy do Ciebie!', 4000, 'error')
				end
			end, vproperties, getCurrentGarage())
			break
		else
			if IsPedInAnyVehicle(PlayerPedId(),false) then
				ESX.ShowNotification('Musisz znajdować się w obszarze parkingu!', 4000, 'error')
				break
			else
				ESX.ShowNotification("Musisz znajdować się w pojeździe!", 4000, 'error')
				break
			end
		end
	end
end)

RegisterCommand('driv', function()
	local veh = GetVehiclePedIsIn(PlayerPedId())
	local v = IsVehicleDriveable(veh, true)



	print(v)
end)

RegisterCommand('healt', function()
	local veh = GetVehiclePedIsIn(PlayerPedId())
	SetVehicleEngineHealth(veh, 0)
	print(GetVehicleEngineHealth(veh))

end)


isVehicleOnMap = function(pPlate)
	print(pPlate)
	local vehiclePool = GetGamePool('CVehicle') -- Get the list of vehicles (entities) from the pool
	for i = 1, #vehiclePool do -- loop through each vehicle (entity)
		local plate = GetVehicleNumberPlateText(vehiclePool[i])
		if plate == pPlate then
			print('returnin true')
			return vehiclePool[i] 
		end
	end
	print('returnin false')
	return nil
end

RegisterCommand('pool', function()
	local vehiclePool = GetGamePool('CVehicle') -- Get the list of vehicles (entities) from the pool
	local playerPlate = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false))
	for i = 1, #vehiclePool do -- loop through each vehicle (entity)
		local plate = GetVehicleNumberPlateText(vehiclePool[i])
		local submerged = GetEntitySubmergedLevel(vehiclePool[i])
		local exploded = GetVehicleBodyHealth(vehiclePool[i])
		print(plate, playerPlate)
		if plate == playerPlate then
			if submerged >= 0.7 or exploded <= 100.0 then
				print(" ROZJEBANY GDZIES")
			else
				print("GIT JEST")
			end
		end
	end



end)


-- getSpawnPoint = function(spawnpoints)
-- 	returnPos = nil
-- 	for i=1, #spawnpoints do
-- 		print(json.encode(spawnpoints[i]))
-- 		-- print(spawnpoints[i].pos.x, spawnpoints[i].pos.y, spawnpoints[i].pos.z)
-- 		if not IsAnyVehicleNearPoint(spawnpoints[i].pos.x, spawnpoints[i].pos.y, spawnpoints[i].pos.z, 2.5) then
-- 			returnPos = spawnpoints[i]
-- 		else
-- 			returnPos = nil
-- 		end
-- 	end

-- 	return returnPos
-- end
	