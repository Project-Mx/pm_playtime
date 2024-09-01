ESX = nil
local playerPlaytime = 0


local function checkWeaponRestrictions()
    if playerPlaytime and IsPedArmed(PlayerPedId(), 7) then 
        local weaponHash = GetSelectedPedWeapon(PlayerPedId())
        local weaponName = ESX.GetWeaponFromHash(weaponHash).name
        local playtimeHours = playerPlaytime / 60 
        local requiredHours = Config.RequiredHours

        local playerData = ESX.GetPlayerData()
        local job = playerData.job.name

        for _, whitelistedJob in ipairs(Config.WhitelistedJobs) do
            if job == whitelistedJob then
                return 
            end
        end

        if Config.RequireHours then
            if playtimeHours < requiredHours then
                Wait(1000)
                TriggerEvent('ox_inventory:disarm', 1, true)
                TriggerEvent('chat:addMessage', {
                    color = { 65, 105, 225 },
                    multiline = false,
                    args = { Config.Messages.noPlaytime:format(requiredHours) }
                })
            end
        else
            for _, weapon in ipairs(Config.WeaponHours) do
                if weapon.weapon == weaponName then
                    requiredHours = weapon.hours
                    if playtimeHours < requiredHours then
                        Wait(1000)
                        TriggerEvent('ox_inventory:disarm', 1, true)
                        TriggerEvent('chat:addMessage', {
                            color = { 65, 105, 225 },
                            multiline = false,
                            args = { Config.Messages.noPlaytime:format(requiredHours) }
                        })
                    end
                    return
                end
            end
        end
    end
end


Citizen.CreateThread(function()
    ESX = exports['es_extended']:getSharedObject()

    ESX.TriggerServerCallback('pm_playtime:getTime', function(time)
        if time then
            playerPlaytime = time
        else
            playerPlaytime = 0
        end
        checkWeaponRestrictions()
    end)

    TriggerEvent('chat:addSuggestion', '/' .. Config.Commands.setPlaytime, 'Set playtime for a player', {
        { name = 'playerid', help = 'ID of the player' },
        { name = 'playtime', help = 'Playtime in minutes' }
    })
    TriggerEvent('chat:addSuggestion', '/' .. Config.Commands.getPlaytime, 'Get your current playtime')
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) 
        if playerPlaytime then
            playerPlaytime = playerPlaytime + 1 
            TriggerServerEvent('pm_playtime:AddTime', 1)
        end
    end
end)


RegisterCommand(Config.Commands.getPlaytime, function(source, args, rawCommand)
    if playerPlaytime then
        local timeh = math.floor(playerPlaytime / 60)
        local timem = playerPlaytime - timeh * 60

        ESX.TriggerServerCallback('pm_playtime:getCharacterName', function(characterName)
            local message = Config.Messages.playtimeMessage:format(timeh .. " hours and " .. timem .. " minutes")
            TriggerEvent('pm_playtime:ChatMessage', message)
        end)
    else
        TriggerEvent('pm_playtime:ChatMessage', "Playtime data is not available.")
    end
end)


RegisterNetEvent('pm_playtime:ChatMessage')
AddEventHandler('pm_playtime:ChatMessage', function(text)
    TriggerEvent('chat:addMessage', {
        color = { 255, 0, 0 },
        multiline = true,
        args = { "[!]", text }
    })
end)


lib.onCache('weapon', function(value)
    if ESX == nil then
        return
    end
    checkWeaponRestrictions()
end)

RegisterNetEvent('pm_playtime:UpdatePlaytime')
AddEventHandler('pm_playtime:UpdatePlaytime', function(playtime)
    playerPlaytime = playtime
    checkWeaponRestrictions() 
end)

CreateThread(function()
    while true do
        local sleep = 1000 -- Check every second
        if ESX.IsPlayerLoaded() then
            ESX.TriggerServerCallback('pm_playtime:getTime', function(time)
                if time then
                    playerPlaytime = time
                else
                    playerPlaytime = 0
                end
                checkWeaponRestrictions()
            end)
            break 
        end
        Wait(sleep)
    end
end)
