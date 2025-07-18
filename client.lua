local isPlayingAnim = false
local isShowingIds = false

Citizen.CreateThread(function()
    while true do
        Wait(0)

        local ped = PlayerPedId()
        local isDead = IsEntityDead(ped)

        -- जब मरेको हुन्छ, control input block हुन्छ, त्यसलाई override गरौँ
        if isDead then
            -- U key (303) को input block हटाउने
            EnableControlAction(0, 303, true)
        end

        -- अब key input manual track गरौं
        if IsControlPressed(0, 303) then
            if not isShowingIds then
                isShowingIds = true
            end

            if not isPlayingAnim and not isDead then
                startInvestigateAnim()
                isPlayingAnim = true
            end
        else
            if isShowingIds then
                isShowingIds = false
            end
            if isPlayingAnim then
                ClearPedTasks(ped)
                isPlayingAnim = false
            end
        end

        if isShowingIds then
            local players = GetActivePlayers()
            local myCoords = GetEntityCoords(ped)

            DrawNotificationText(#players)

            for _, player in ipairs(players) do
                local targetPed = GetPlayerPed(player)
                if DoesEntityExist(targetPed) then
                    local coords = GetEntityCoords(targetPed)
                    if coords.x ~= 0.0 and coords.y ~= 0.0 and coords.z ~= 0.0 then
                        local dist = #(coords - myCoords)
                        if dist < 25.0 then
                            DrawText3D(coords.x, coords.y, coords.z + 1.0, tostring(GetPlayerServerId(player)))
                        end
                    end
                end
            end
        end

    end
end)

function startInvestigateAnim()
    local ped = PlayerPedId()
    local dict = "mp_cp_welcome_tutthink"
    local anim = "b_think"

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end

    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 49, 0, false, false, false)
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local camCoords = GetGameplayCamCoords()
    local dist = #(vector3(x, y, z) - camCoords)

    if onScreen then
        local scale = 400 / (GetGameplayCamFov() * dist)
        SetTextScale(0.45 * scale, 0.45 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextCentre(true)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function DrawNotificationText(totalPlayers)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(0.9, 0.9)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    SetTextCentre(false)
    AddTextComponentString("Player Online")
    DrawText(0.85, 0.12)

    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(0.8, 0.8)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    SetTextCentre(false)
    AddTextComponentString(tostring(totalPlayers))
    DrawText(0.89, 0.16)
end
