-----------------------
-- GrimDesigns 
-- Copyrighted © GrimDesigns 2019
-- Do not redistribute or edit in any way without my permission.
----------------------

function getPlayerID(source)
    local identifiers = GetPlayerIdentifiers(source)
    local player = getIdentifiant(identifiers)
    return player
end

function getIdentifiant(id)
    for _, v in ipairs(id) do
        return v
    end
end

RegisterNetEvent("arm:GiveItem")
AddEventHandler("arm:GiveItem", function(target, currentAction)
	local index  = currentAction
	local source = target
	TriggerClientEvent("arm:RecieveItem", source, index)
end)

RegisterServerEvent('police:removeWeapons')
AddEventHandler('police:removeWeapons', function(target)
	local identifier = getPlayerID(target)
	TriggerClientEvent("police:removeWeapons", target)
end)

RegisterServerEvent('police:confirmUnseat')
AddEventHandler('police:confirmUnseat', function(t)
	TriggerClientEvent("police:notify", source, "CHAR_ANDREAS", 1, i18n.translate("title_notification"), false, i18n.translate("unseat_sender_notification_part_1") .. GetPlayerName(t) .. i18n.translate("unseat_sender_notification_part_2"))
	TriggerClientEvent('police:unseatme', t)
end)

RegisterServerEvent('police:dragRequest')
AddEventHandler('police:dragRequest', function(t)
	TriggerClientEvent("police:notify", source, "CHAR_ANDREAS", 1, i18n.translate("title_notification"), false, i18n.translate("drag_sender_notification_part_1").. GetPlayerName(t) .. i18n.translate("drag_sender_notification_part_2"))
	TriggerClientEvent('police:toggleDrag', t, source)
end)

RegisterServerEvent('police:finesGranted')
AddEventHandler('police:finesGranted', function(target, amount)
	TriggerClientEvent('police:payFines', target, amount, source)
	TriggerClientEvent("police:notify", source, "CHAR_ANDREAS", 1, i18n.translate("title_notification"), false, i18n.translate("send_fine_request_part_1")..amount..i18n.translate("send_fine_request_part_2")..GetPlayerName(target))
end)

RegisterServerEvent('police:finesETA')
AddEventHandler('police:finesETA', function(officer, code)
	if(code==1) then
		TriggerClientEvent("police:notify", officer, "CHAR_ANDREAS", 1, i18n.translate("title_notification"), false, GetPlayerName(source)..i18n.translate("already_have_a_pendind_fine_request"))
	elseif(code==2) then
		TriggerClientEvent("police:notify", officer, "CHAR_ANDREAS", 1, i18n.translate("title_notification"), false, GetPlayerName(source)..i18n.translate("request_fine_timeout"))
	elseif(code==3) then
		TriggerClientEvent("police:notify", officer, "CHAR_ANDREAS", 1, i18n.translate("title_notification"), false, GetPlayerName(source)..i18n.translate("request_fine_refused"))
	elseif(code==0) then
		TriggerClientEvent("police:notify", officer, "CHAR_ANDREAS", 1, i18n.translate("title_notification"), false, GetPlayerName(source)..i18n.translate("request_fine_accepted"))
	end
end)

RegisterServerEvent('police:cuffGranted')
AddEventHandler('police:cuffGranted', function(t)
	TriggerClientEvent("police:notify", source, "CHAR_ANDREAS", 1, i18n.translate("title_notification"), false, i18n.translate("toggle_cuff_player_part_1")..GetPlayerName(t)..i18n.translate("toggle_cuff_player_part_2"))
	TriggerClientEvent('police:getArrested', t)
end)

RegisterServerEvent('police:forceEnterAsk')
AddEventHandler('police:forceEnterAsk', function(t, v)
	TriggerClientEvent("police:notify", source, "CHAR_ANDREAS", 1, i18n.translate("title_notification"), false, i18n.translate("force_player_get_in_vehicle_part_1")..GetPlayerName(t)..i18n.translate("force_player_get_in_vehicle_part_2"))
	TriggerClientEvent('police:forcedEnteringVeh', t, v)
end)

RegisterServerEvent('CheckPoliceVeh')
AddEventHandler('CheckPoliceVeh', function(vehicle)
	TriggerClientEvent('FinishPoliceCheckForVeh',source)
	TriggerClientEvent('policeveh:spawnVehicle', source, vehicle)
end)

-----------------------
-- GrimDesigns 
-- Copyrighted © GrimDesigns 2019
-- Do not redistribute or edit in any way without my permission.
----------------------
