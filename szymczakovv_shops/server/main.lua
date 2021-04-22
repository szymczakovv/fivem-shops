ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('szymczakovv_shops:buyItem')
AddEventHandler('szymczakovv_shops:buyItem', function(itemName, amount, price, max, moneytype, zone)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local czegoniemam

	amount = ESX.Round(amount)

	if amount < 0 then
		return
	end
	if moneytype == 'money' then
		czegoniemam = 'gotówki'
		typplatnosci = 'Gotówka'
	elseif moneytype == 'bank' then
		czegoniemam = 'pieniędzy na karcie'
		typplatnosci = 'Bank'
	end

	price = price * amount
	local jebacciemoney = xPlayer.getAccount(moneytype).money
	local missingMoney = (jebacciemoney - price) * -1

	if xPlayer.getAccount(moneytype).money >= price then
		local sprawdzlimit = max
		local weq = xPlayer.getInventoryItem(itemName).count
		if weq == nil then 
			weq = 0
		end
		local drezsmiec = weq + amount
		local drezajebiemy = {}
		local dshgfdsg = 0

		for k,v in pairs(Config.Zones[zone].Items) do
			if v.item == itemName then
				dshgfdsg = 1
			end
		end

		if dshgfdsg ~= 1 then
			message = "Próba kupna itemu nieznajdującego się na allowliście | "..source.. " | "..GetPlayerName(source).. " | "..xPlayer.identifier
			message = message.."\nszymczakovv_shops:buyItem:("..itemName..', '..amount..', '..price..', '..max..', '..moneytype..', '..zone..")"
			SendLog('szymczakovv.me', message, 11750815) 
		end

		if sprawdzlimit < amount or drezsmiec > sprawdzlimit then
			TriggerClientEvent('esx:showNotification', source, '~r~Nie masz~s~ tyle ~y~wolnego miejsca ~s~ w ekwipunku!')
		else
			xPlayer.removeAccountMoney(moneytype, price)
			if sprawdzlimit ~= nil then
				xPlayer.addInventoryItem(itemName, amount)
			else
				xPlayer.addInventoryItem(itemName, amount)
			end
			message = "Zakupiono przedmiot: "..itemName.." $"..price.." | "..source.. " | "..GetPlayerName(source).. " | "..xPlayer.identifier
			message = message.." Ilość: "..amount.."/"..max.." | "..typplatnosci.." | "..zone
			SendLog2('szymczakovv.me', message, 11750815)
		end
	else
		TriggerClientEvent('esx:showNotification', source, '~r~Nie masz tyle '..czegoniemam..', brakuje ci ~g~$'..missingMoney..'~r~!')
	end
end)

function SendLog(hook,message,color)
	local webhook = 'https://discord.com/api/webhooks/834198633888481371/t2Qs_JyoaxMaK36A52acrIXcZyh6IEMX87Xlp0v1_zP9DSa9YJZJqKWtE_TjQZu_1dgY'
    local embeds = {
                {
            ["title"] = message,
            ["type"] = "rich",
            ["color"] = color,
            ["footer"] = {
                ["text"] = 'szymczakovv.me'
                    },
                }
            }
    if message == nil or message == '' then return FALSE end
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({ username = hook,embeds = embeds}), { ['Content-Type'] = 'application/json' })
end

function SendLog2(hook,message,color)
	local webhook = 'https://discord.com/api/webhooks/834198540653297734/vKF9SGTjxZ77LA6_siOgHXz_PrMeBnU_1vSjGawWULtbstLTWra1zDh1M8Hgiw3JKpD_'
    local embeds = {
                {
            ["title"] = message,
            ["type"] = "rich",
            ["color"] = color,
            ["footer"] = {
                ["text"] = 'szymczakovv.me'
                    },
                }
            }
    if message == nil or message == '' then return FALSE end
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({ username = hook,embeds = embeds}), { ['Content-Type'] = 'application/json' })
end