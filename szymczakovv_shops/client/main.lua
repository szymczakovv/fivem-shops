ESX                           = nil
local HasAlreadyEnteredMarker = false
local LastZone                = nil
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local PlayerData              = {}

CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	Citizen.Wait(5000)
	PlayerData = ESX.GetPlayerData()
end)

function OpenShopMenu(zone)
	PlayerData = ESX.GetPlayerData()

	local elements = {}
	for k,v in pairs(Config.Zones[zone].Items) do
		table.insert(elements, 
			{
				label =  v.title..' <span style="color: #7cfc00;">$'..v.price..'</span>',
				item = v.item,
				price = v.price,
				titleconfirm = v.title,
				value      = 1,
				type       = 'slider',
				min        = 1,
				max        = v.limit
			}
		)
	end

	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop', {
		title    = 'Sklep',
		align    = 'center',
		elements = elements
	}, function(data, menu)
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_confirm', {
			title    = 'Czym chcesz zapłacić za '..data.current.titleconfirm..' za '..data.current.price..'$?',
			align    = 'center',
			elements = {
				{label = 'Gotówką',  value = 'gotowka'},
				{label = 'Kartą', value = 'karta'},
				{label = 'Nie chce nic kupywać', value = 'niechce'},
			}
		}, function(data2, menu2)
			if data2.current.value == 'gotowka' then
				TriggerServerEvent('szymczakovv_shops:buyItem', data.current.item, data.current.value, data.current.price, data.current.max, 'money', zone)
			elseif data2.current.value == 'karta' then
				TriggerServerEvent('szymczakovv_shops:buyItem', data.current.item, data.current.value, data.current.price, data.current.max, 'bank', zone)
			elseif data2.current.value == 'niechce' then
				menu2.close()
				menu.open()
			end

			menu2.close()
		end, function(data2, menu2)
			menu2.close()
		end)			
	end, function(data, menu)
		menu.close()
		CurrentAction     = 'shop_menu'
		CurrentActionMsg  = 'Naciśnij ~INPUT_CONTEXT~ aby skorzystać ze ~y~sklepu~s~.'
		CurrentActionData = {zone = zone}
	end)
end

CreateThread(function()
	for k,v in pairs(Config.Zones) do
	if v.Blips then
		for i = 1, #v.Pos, 1 do
			local blip = AddBlipForCoord(v.Pos[i].x, v.Pos[i].y, v.Pos[i].z)

			SetBlipSprite (blip, v.Blip.Sprite)
			SetBlipDisplay(blip, 4)
			SetBlipScale  (blip, 0.8)
			SetBlipColour (blip, v.Blip.Color)
			SetBlipAsShortRange(blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(v.Blip.Name)
			EndTextCommandSetBlipName(blip)
			end
		end
	end
end)

AddEventHandler('szymczakovv_shops:hasEnteredMarker', function(zone)
	CurrentAction     = 'shop_menu'
	CurrentActionMsg  = 'Naciśnij ~INPUT_CONTEXT~ aby skorzystać ze ~y~sklepu~s~.'
	CurrentActionData = {zone = zone}
end)

AddEventHandler('szymczakovv_shops:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

CreateThread(function()
	while true do
		Citizen.Wait(5)
		local coords, sleep = GetEntityCoords(Citizen.InvokeNative(0x43A66C31C68491C0, -1)), true

		for k,v in pairs(Config.Zones) do
			for i = 1, #v.Pos, 1 do
				if(Config.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, true) < Config.DrawDistance) then
					sleep = false
					DrawMarker(Config.Type, v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.Size.x, Config.Size.y, Config.Size.z, Config.Color.r, Config.Color.g, Config.Color.b, 100, false, true, 2, false, false, false, false)
				end
			end
		end
		if sleep then
			Citizen.Wait(1000)
		end
	end
end)

CreateThread(function()
	while true do
		Citizen.Wait(10)
		local coords, sleep = GetEntityCoords(Citizen.InvokeNative(0x43A66C31C68491C0, -1)), true
		local isInMarker  = false
		local currentZone = nil

		for k,v in pairs(Config.Zones) do
			for i = 1, #v.Pos, 1 do
				if(GetDistanceBetweenCoords(coords, v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, true) < Config.Size.x) then
					sleep = false
					isInMarker  = true
					ShopItems   = v.Items
					currentZone = k
					LastZone    = k
				end
			end
		end
		if isInMarker and not HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = true
			TriggerEvent('szymczakovv_shops:hasEnteredMarker', currentZone)
		end
		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('szymczakovv_shops:hasExitedMarker', LastZone)
		end
		if sleep then
			Citizen.Wait(1000)
		end
	end
end)

CreateThread(function()
	while true do
		Citizen.Wait(10)

		if CurrentAction ~= nil then

			SetTextComponentFormat('STRING')
			AddTextComponentString(CurrentActionMsg)
			DisplayHelpTextFromStringLabel(0, 0, 1, -1)

			if IsControlJustReleased(0, 38) then

				if CurrentAction == 'shop_menu' then
					OpenShopMenu(CurrentActionData.zone)
				end

				CurrentAction = nil

			end

		else
			Citizen.Wait(500)
		end
	end
end)