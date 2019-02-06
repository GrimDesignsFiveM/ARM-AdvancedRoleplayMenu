local onduty = false

local currentAction = "none"
local obj_net = nil

local handCuffed = false
local drag = false
local officerDrag = -1

local propslist = {}
local lockAskingFine = false

SpawnedSpikes = {}


RegisterCommand('onduty', function()
	onduty = not onduty
	local str = nil
	if onduty then
		str = "^2 onduty"
	else
		str = "^1 offduty"
	end
TriggerEvent('chatMessage', "^1[SYSTEM]:^0 You are now"..str.."^0.")
end, false)

--
--Menu
--

Citizen.CreateThread(function()

	WarMenu.CreateMenu('main', 'Interaction Menu')
	WarMenu.CreateMenu('leo', 'Law Enforcement')
	WarMenu.CreateMenu('items', 'Items')
	WarMenu.CreateSubMenu('closeMenu', 'main', 'Are you sure?')

    while true do
		if WarMenu.IsMenuOpened('main') then
			if onduty then
				if WarMenu.MenuButton('Law Enforcement', 'leo') then -- Open LEO Menu
				end
			end

			if WarMenu.MenuButton('Items', 'items') then -- Open LEO Menu
			end
			
			if WarMenu.MenuButton('Exit', 'closeMenu') then -- Exit Menu
			end
			
			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('items') then
			if WarMenu.Button("Deliver Package") then
				DoAction("box_carry")
				WarMenu.Display()
			elseif WarMenu.Button("Deliver Pizza") then
				WarMenu.Display()
				DoAction("pizza_delivery")
			elseif WarMenu.Button("Carry Crate") then
				DoAction("crate_delivery")
				WarMenu.Display()
			elseif WarMenu.Button("Drop Item") then
				DoAction("none")
				WarMenu.Display()
			elseif WarMenu.Button("Give Item") then
				DoAction("give_item")
				WarMenu.Display()
			end
			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('leo') then
			if WarMenu.Button(i18n.translate("menu_weapons_title")) then 
				RemoveWeapons()
				WarMenu.Display()
			elseif WarMenu.Button(i18n.translate("menu_toggle_cuff_title")) then 
				ToggleCuff()
				WarMenu.Display()
			elseif WarMenu.Button(i18n.translate("menu_force_player_get_in_car_title")) then 
				PutInVehicle()
				WarMenu.Display()
			elseif WarMenu.Button(i18n.translate("menu_force_player_get_out_car_title")) then 
				UnseatVehicle()
				WarMenu.Display()
			elseif WarMenu.Button(i18n.translate("menu_drag_player_title")) then 
				DragPlayer()
				WarMenu.Display()
			elseif WarMenu.Button("Give Fine") then -- Open fines Menu
				Fines()
			end
			WarMenu.Display()

        elseif WarMenu.IsMenuOpened('closeMenu') then
		
			if WarMenu.Button('Yes') then
			
				WarMenu.CloseMenu()
			
			elseif WarMenu.MenuButton('No', 'main') then
			
			end
			
			WarMenu.Display()
			
        elseif IsControlJustReleased(0, 244) then --M by default
			
			WarMenu.OpenMenu('main')
		
		end

        Citizen.Wait(0)
    end
end)

--
--Functions
--

function DoAction(index)
	Citizen.CreateThread(function()
		if index == "give_item" then
			local distance = GetClosestPlayer()
			if (distance ~= -1 and distance < 3) then
				local one = GetPlayerServerId(GetClosestPlayer())
				TriggerServerEvent("arm:GiveItem", one, currentAction)
				ClearPedSecondaryTask(GetPlayerPed(PlayerId()))
				DetachEntity(NetToObj(obj_net), 1, 1)
				DeleteEntity(NetToObj(obj_net))
				obj_net = nil
				currentAction = "none"
				return
			else
				TriggerEvent('chatMessage', "^1[SYSTEM]:^0 No players are near you.")
				return
			end
        end
        if currentAction ~= "none" then
			ClearPedSecondaryTask(GetPlayerPed(PlayerId()))
			DetachEntity(NetToObj(obj_net), 1, 1)
			DeleteEntity(NetToObj(obj_net))
			obj_net = nil
			currentAction = "none"
        end
        if index == "none" then
			ClearPedSecondaryTask(GetPlayerPed(PlayerId()))
			DetachEntity(NetToObj(obj_net), 1, 1)
			DeleteEntity(NetToObj(obj_net))
			obj_net = nil
            currentAction = "none"
            return
        end
        
		RequestModel(GetHashKey(config.actions[index].animObjects.name))
		while not HasModelLoaded(GetHashKey(config.actions[index].animObjects.name)) do
			Citizen.Wait(100)
		end

		RequestAnimDict(config.actions[index].animDictionary)
		while not HasAnimDictLoaded(config.actions[index].animDictionary) do
			Citizen.Wait(100)
		end

		local plyCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 0.0, -5.0)
		local objSpawned = CreateObject(GetHashKey(config.actions[index].animObjects.name), plyCoords.x, plyCoords.y, plyCoords.z, 1, 1, 1)
		Citizen.Wait(1000)
		local netid = ObjToNet(objSpawned)
		SetNetworkIdExistsOnAllMachines(netid, true)
		NetworkSetNetworkIdDynamic(netid, true)
		SetNetworkIdCanMigrate(netid, false)
		AttachEntityToEntity(objSpawned, GetPlayerPed(PlayerId()), GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422), config.actions[index].animObjects.xoff, config.actions[index].animObjects.yoff, config.actions[index].animObjects.zoff, config.actions[index].animObjects.xrot, config.actions[index].animObjects.yrot, config.actions[index].animObjects.zrot, 1, 1, 0, 1, 0, 1)
		TaskPlayAnim(GetPlayerPed(PlayerId()), 1.0, -1, -1, 50, 0, 0, 0, 0) -- 50 = 32 + 16 + 2
		TaskPlayAnim(GetPlayerPed(PlayerId()), config.actions[index].animDictionary, config.actions[index].animationName, 1.0, -1, -1, 50, 0, 0, 0, 0)
		obj_net = netid
		currentAction = index
    end)
end


-- --Citizens

-- --Fines
-- buttonsFine[#buttonsFine+1] = {name = "$250", func = 'Fines', params = 250}
-- buttonsFine[#buttonsFine+1] = {name = "$500", func = 'Fines', params = 500}
-- buttonsFine[#buttonsFine+1] = {name = "$1000", func = 'Fines', params = 1000}
-- buttonsFine[#buttonsFine+1] = {name = "$1500", func = 'Fines', params = 1500}
-- buttonsFine[#buttonsFine+1] = {name = "$2000", func = 'Fines', params = 2000}
-- buttonsFine[#buttonsFine+1] = {name = "$4000", func = 'Fines', params = 4000}
-- buttonsFine[#buttonsFine+1] = {name = "$6000", func = 'Fines', params = 6000}
-- buttonsFine[#buttonsFine+1] = {name = "$8000", func = 'Fines', params = 8000}
-- buttonsFine[#buttonsFine+1] = {name = "$10000", func = 'Fines', params = 10000}
-- buttonsFine[#buttonsFine+1] = {name = i18n.translate("menu_custom_amount_fine_title"), func = 'Fines', params = -1}


--
--Events handlers
--

RegisterNetEvent('police:getArrested')
AddEventHandler('police:getArrested', function()
	handCuffed = not handCuffed
	if(handCuffed) then
		TriggerEvent("police:notify",  "CHAR_ANDREAS", 1, i18n.translate("title_notification"), false, i18n.translate("now_cuffed"))
	else
		TriggerEvent("police:notify",  "CHAR_ANDREAS", 1, i18n.translate("title_notification"), false, i18n.translate("now_uncuffed"))
		drag = false
	end
end)

RegisterNetEvent('police:payFines')
AddEventHandler('police:payFines', function(amount, sender)
	Citizen.CreateThread(function()
		
		if(lockAskingFine ~= true) then
			lockAskingFine = true
			local notifReceivedAt = GetGameTimer()
			Notification(i18n.translate("info_fine_request_before_amount")..amount..i18n.translate("info_fine_request_after_amount"))
			while(true) do
				Wait(0)
				
				if (GetTimeDifference(GetGameTimer(), notifReceivedAt) > 15000) then
					TriggerServerEvent('police:finesETA', sender, 2)
					Notification(i18n.translate("request_fine_expired"))
					lockAskingFine = false
					break
				end
				
				if IsControlPressed(1, config.bindings.accept_fine) then
					Notification(i18n.translate("pay_fine_success_before_amount")..amount..i18n.translate("pay_fine_success_after_amount"))
					TriggerServerEvent('police:finesETA', sender, 0)
					lockAskingFine = false
					break
				end
				
				if IsControlPressed(1, config.bindings.refuse_fine) then
					TriggerServerEvent('police:finesETA', sender, 3)
					lockAskingFine = false
					break
				end
			end
		else
			TriggerServerEvent('police:finesETA', sender, 1)
		end
	end)
end)

RegisterNetEvent("police:notify")
AddEventHandler("police:notify", function(icon, type, sender, title, text)
	SetNotificationTextEntry("STRING");
	AddTextComponentString(text);
	SetNotificationMessage(icon, icon, true, type, sender, title, text);
	DrawNotification(false, true);
end)

--Piece of code given by Thefoxeur54
RegisterNetEvent('police:unseatme')
AddEventHandler('police:unseatme', function(t)
	local ped = GetPlayerPed(t)        
	ClearPedTasksImmediately(ped)
	plyPos = GetEntityCoords(PlayerPedId(),  true)
	local xnew = plyPos.x+2
	local ynew = plyPos.y+2
   
	SetEntityCoords(PlayerPedId(), xnew, ynew, plyPos.z)
end)

RegisterNetEvent('police:toggleDrag')
AddEventHandler('police:toggleDrag', function(t)
	if(handCuffed) then
		drag = not drag
		officerDrag = t
	end
end)

RegisterNetEvent('police:forcedEnteringVeh')
AddEventHandler('police:forcedEnteringVeh', function(veh)
	if(handCuffed) then
		local pos = GetEntityCoords(PlayerPedId())
		local entityWorld = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 20.0, 0.0)

		local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, PlayerPedId(), 0)
		local _, _, _, _, vehicleHandle = GetRaycastResult(rayHandle)

		if vehicleHandle ~= nil then
			if(IsVehicleSeatFree(vehicleHandle, 1)) then
				SetPedIntoVehicle(PlayerPedId(), vehicleHandle, 1)
			else 
				if(IsVehicleSeatFree(vehicleHandle, 2)) then
					SetPedIntoVehicle(PlayerPedId(), vehicleHandle, 2)
				end
			end
		end
	end
end)

RegisterNetEvent('police:removeWeapons')
AddEventHandler('police:removeWeapons', function()
    RemoveAllPedWeapons(PlayerPedId(), true)
end)

--
--Functions
--

function Notification(msg)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(msg)
	DrawNotification(0,1)
end

function drawNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

function GetPlayers()
    local players = {}

    for i = 0, 31 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end

    return players
end

function GetClosestPlayer()
	local players = GetPlayers()
	local closestDistance = -1
	local closestPlayer = -1
	local ply = PlayerPedId()
	local plyCoords = GetEntityCoords(ply, 0)
	
	for index,value in ipairs(players) do
		local target = GetPlayerPed(value)
		if(target ~= ply) then
			local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
			local distance = Vdist(targetCoords["x"], targetCoords["y"], targetCoords["z"], plyCoords["x"], plyCoords["y"], plyCoords["z"])
			if(closestDistance == -1 or closestDistance > distance) then
				closestPlayer = value
				closestDistance = distance
			end
		end
	end
	
	return closestPlayer, closestDistance
end

function drawTxt(text,font,centre,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(centre)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x, y)
end

function ServiceOn()
	isInService = true
	TriggerServerEvent("police:takeService")
end

function ServiceOff()
	isInService = false
	TriggerServerEvent("police:breakService")
end

function DisplayHelpText(str)
	BeginTextCommandDisplayHelp("STRING")
	AddTextComponentSubstringPlayerName(str)
	EndTextCommandDisplayHelp(0, 0, 1, -1)
end

local alreadyDead = false
local playerStillDragged = false

Citizen.CreateThread(function()
	
    while true do
        Citizen.Wait(5)
		if (handCuffed == true) then
			RequestAnimDict('mp_arresting')
			while not HasAnimDictLoaded('mp_arresting') do
				Citizen.Wait(0)
			end

			local myPed = PlayerPedId()
			local animation = 'idle'
			local flags = 16
			
			while(IsPedBeingStunned(myPed, 0)) do
				ClearPedTasksImmediately(myPed)
			end
			TaskPlayAnim(myPed, 'mp_arresting', animation, 8.0, -8, -1, flags, 0, 0, 0, 0)
		end
		
		--Piece of code from Drag command (by Frazzle, Valk, Michael_Sanelli, NYKILLA1127 : https://forum.fivem.net/t/release-drag-command/22174)
		if drag then
			local ped = GetPlayerPed(GetPlayerFromServerId(officerDrag))
			local myped = PlayerPedId()
			AttachEntityToEntity(myped, ped, 4103, 11816, 0.48, 0.00, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
			playerStillDragged = true
		else
			if(playerStillDragged) then
				DetachEntity(PlayerPedId(), true, false)
				playerStillDragged = false
			end
		end
    end
end)

Citizen.CreateThread(function()
	while true do
		if drag then
			local ped = GetPlayerPed(GetPlayerFromServerId(playerPedDragged))
			plyPos = GetEntityCoords(ped, true)
			SetEntityCoords(ped, plyPos.x, plyPos.y, plyPos.z)    
		end
		Citizen.Wait(1000)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if IsPedInAnyVehicle(PlayerPedId(), false) then
			currentVeh = GetVehiclePedIsIn(PlayerPedId(), false)
			x,y,z = table.unpack(GetEntityCoords(PlayerPedId(), true))

			if DoesObjectOfTypeExistAtCoords(x, y, z, 0.9, GetHashKey("P_ld_stinger_s"), true) then
				for i= 0, 7 do					
					SetVehicleTyreBurst(currentVeh, i, true, 1148846080)
				end

				Citizen.Wait(100)
				DeleteSpike()
			end
		end
	end
end)

function DoTraffic()
	Citizen.CreateThread(function()
        TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_CAR_PARK_ATTENDANT", 0, false)
        Citizen.Wait(60000)
        ClearPedTasksImmediately(PlayerPedId())
    end)
	drawNotification(i18n.translate("menu_doing_traffic_notification"))
end

function Note()
	Citizen.CreateThread(function()
        TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_CLIPBOARD", 0, false)
        Citizen.Wait(20000)
        ClearPedTasksImmediately(PlayerPedId())
    end) 
	drawNotification(i18n.translate("menu_taking_notes_notification"))
end

function StandBy()
	Citizen.CreateThread(function()
        TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_COP_IDLES", 0, true)
        Citizen.Wait(20000)
        ClearPedTasksImmediately(PlayerPedId())
    end)
	drawNotification(i18n.translate("menu_being_stand_by_notification"))
end

function StandBy2()
	Citizen.CreateThread(function()
        TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GUARD_STAND", 0, 1)
        Citizen.Wait(20000)
        ClearPedTasksImmediately(PlayerPedId())
    end)
	drawNotification(i18n.translate("menu_being_stand_by_notification"))
end

function CheckInventory()
	local t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 3) then
		TriggerServerEvent("police:targetCheckInventory", GetPlayerServerId(t))
	else
		TriggerEvent('chatMessage', i18n.translate("title_notification"), {255, 0, 0}, i18n.translate("no_player_near_ped"))
	end
end

function CheckId()
	local t , distance  = GetClosestPlayer()
    if(distance ~= -1 and distance < 3) then
		TriggerServerEvent('gc:copOpenIdentity', GetPlayerServerId(t))
    else
		TriggerEvent('chatMessage', i18n.translate("title_notification"), {255, 0, 0}, i18n.translate("no_player_near_ped"))
	end
end

function RemoveWeapons()
    local t, distance = GetClosestPlayer()
    if(distance ~= -1 and distance < 3) then
        TriggerServerEvent("police:removeWeapons", GetPlayerServerId(t))
    else
        TriggerEvent('chatMessage', i18n.translate("title_notification"), {255, 0, 0}, i18n.translate("no_player_near_ped"))
    end
end

function ToggleCuff()
	local t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 3) then
		TriggerServerEvent("police:cuffGranted", GetPlayerServerId(t))
	else
		TriggerEvent('chatMessage', i18n.translate("title_notification"), {255, 0, 0}, i18n.translate("no_player_near_ped"))
	end
end

function PutInVehicle()
	local t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 3) then
		local v = GetVehiclePedIsIn(PlayerPedId(), true)
		TriggerServerEvent("police:forceEnterAsk", GetPlayerServerId(t), v)
	else
		TriggerEvent('chatMessage', i18n.translate("title_notification"), {255, 0, 0}, i18n.translate("no_player_near_ped"))
	end
end

function UnseatVehicle()
	local t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 4) then
		TriggerServerEvent("police:confirmUnseat", GetPlayerServerId(t))
	else
		TriggerEvent('chatMessage', i18n.translate("title_notification"), {255, 0, 0}, i18n.translate("no_player_near_ped"))
	end
end

function DragPlayer()
	local t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 3) then
		TriggerServerEvent("police:dragRequest", GetPlayerServerId(t))
		TriggerEvent("police:notify", "CHAR_ANDREAS", 1, i18n.translate("title_notification"), false, i18n.translate("drag_sender_notification_part_1") .. GetPlayerName(serverTargetPlayer) .. i18n.translate("drag_sender_notification_part_2"))
	else
		TriggerEvent('chatMessage', i18n.translate("title_notification"), {255, 0, 0}, i18n.translate("no_player_near_ped"))
	end
end

function Fines()
	local t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 3) then
		Citizen.Trace("Price : "..tonumber(amount))

		DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8S", "", "", "", "", "", 20)
		while (UpdateOnscreenKeyboard() == 0) do
			DisableAllControlActions(0);
			Wait(0);
		end
		if (GetOnscreenKeyboardResult()) then
			local res = tonumber(GetOnscreenKeyboardResult())
			if(res ~= nil and res ~= 0) then
				amount = tonumber(res)
			end
		end
		
		if(tonumber(amount) ~= -1) then
			TriggerServerEvent("police:finesGranted", GetPlayerServerId(t), tonumber(amount))
		end
	else
		TriggerEvent('chatMessage', i18n.translate("title_notification"), {255, 0, 0}, i18n.translate("no_player_near_ped"))
	end
end

function Crochet()
	Citizen.CreateThread(function()
		local pos = GetEntityCoords(PlayerPedId())
		local entityWorld = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 20.0, 0.0)

		local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, PlayerPedId(), 0)
		local _, _, _, _, vehicleHandle = GetRaycastResult(rayHandle)
		if(DoesEntityExist(vehicleHandle)) then
			local prevObj = GetClosestObjectOfType(pos.x, pos.y, pos.z, 10.0, GetHashKey("prop_weld_torch"), false, true, true)
			if(IsEntityAnObject(prevObj)) then
				SetEntityAsMissionEntity(prevObj)
				DeleteObject(prevObj)
			end
			TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_WELDING", 0, true)
			Citizen.Wait(20000)
			SetVehicleDoorsLocked(vehicleHandle, 1)
			ClearPedTasksImmediately(PlayerPedId())
			drawNotification(i18n.translate("menu_veh_opened_notification"))
		else
			drawNotification(i18n.translate("no_veh_near_ped"))
		end
	end)
end

function SpawnSpikesStripe()
	if IsPedInAnyPoliceVehicle(PlayerPedId()) then
		local modelHash = GetHashKey("P_ld_stinger_s")
		local currentVeh = GetVehiclePedIsIn(PlayerPedId(), false)	
		local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(currentVeh, 0.0, -5.2, -0.25))

		RequestScriptAudioBank("BIG_SCORE_HIJACK_01", true)
		Citizen.Wait(500)

		RequestModel(modelHash)
		while not HasModelLoaded(modelHash) do
			Citizen.Wait(0)
		end

		if HasModelLoaded(modelHash) then
			SpikeObject = CreateObject(modelHash, x, y, z, true, false, true)
			SetEntityNoCollisionEntity(SpikeObject, PlayerPedId(), 1)
			SetEntityDynamic(SpikeObject, false)
			ActivatePhysics(SpikeObject)

			if DoesEntityExist(SpikeObject) then			
				local height = GetEntityHeightAboveGround(SpikeObject)

				SetEntityCoords(SpikeObject, x, y, z - height + 0.05)
				SetEntityHeading(SpikeObject, GetEntityHeading(PlayerPedId())-80.0)
				SetEntityCollision(SpikeObject, false, false)
				PlaceObjectOnGroundProperly(SpikeObject)

				SetEntityAsMissionEntity(SpikeObject, false, false)				
				SetModelAsNoLongerNeeded(modelHash)
				PlaySoundFromEntity(-1, "DROP_STINGER", PlayerPedId(), "BIG_SCORE_3A_SOUNDS", 0, 0)
			end			
			drawNotification("Spike stripe~g~ deployed~w~.")
		end
	else
		drawNotification("You need to get ~y~inside~w~ a ~y~police vehicle~w~.")
		PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
	end
end

function DeleteSpike()
	local model = GetHashKey("P_ld_stinger_s")
	local x,y,z = table.unpack(GetEntityCoords(PlayerPedId(), true))

	if DoesObjectOfTypeExistAtCoords(x, y, z, 0.9, model, true) then
		local spike = GetClosestObjectOfType(x, y, z, 0.9, model, false, false, false)
		DeleteObject(spike)
	end	
end

function CheckPlate()
	local pos = GetEntityCoords(PlayerPedId())
	local entityWorld = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 20.0, 0.0)

	local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, PlayerPedId(), 0)
	local _, _, _, _, vehicleHandle = GetRaycastResult(rayHandle)
	if(DoesEntityExist(vehicleHandle)) then
		TriggerServerEvent("police:checkingPlate", GetVehicleNumberPlateText(vehicleHandle))
	else
		drawNotification(i18n.translate("no_veh_near_ped"))
	end
end

function SpawnProps(model)
	if(#propslist < 20) then
		local prophash = GetHashKey(tostring(model))
		RequestModel(prophash)
		while not HasModelLoaded(prophash) do
			Citizen.Wait(0)
		end

		local offset = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.75, 0.0)
		local _, worldZ = GetGroundZFor_3dCoord(offset.x, offset.y, offset.z)
		local propsobj = CreateObjectNoOffset(prophash, offset.x, offset.y, worldZ, true, true, true)
		local heading = GetEntityHeading(PlayerPedId())

		SetEntityHeading(propsobj, heading)
		SetEntityAsMissionEntity(propsobj)
		SetModelAsNoLongerNeeded(prophash)

        propslist[#propslist+1] = ObjToNet(propsobj)
    else
        drawNotification("You have too many props spawned. Please remove some with the menu.")
	end
end

function RemoveLastProps()
	DeleteObject(NetToObj(propslist[#propslist]))
	propslist[#propslist] = nil
end

function RemoveAllProps()
	for i, props in pairs(propslist) do
		DeleteObject(NetToObj(props))
		propslist[i] = nil
	end

end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		for _, props in pairs(propslist) do
			local ox, oy, oz = table.unpack(GetEntityCoords(NetToObj(props), true))
			local cVeh = GetClosestVehicle(ox, oy, oz, 20.0, 0, 70)
			if(IsEntityAVehicle(cVeh)) then
				if IsEntityAtEntity(cVeh, NetToObj(props), 20.0, 20.0, 2.0, 0, 1, 0) then
					local cDriver = GetPedInVehicleSeat(cVeh, -1)
					TaskVehicleTempAction(cDriver, cVeh, 6, 1000)
					
					SetVehicleHandbrake(cVeh, true)
					SetVehicleIndicatorLights(cVeh, 0, true)
					SetVehicleIndicatorLights(cVeh, 1, true)
				end
			end
		end
	end
end)

-- Events --
RegisterNetEvent("arm:RecieveItem")
AddEventHandler("arm:RecieveItem", function(index)
    DoAction(index)
end)