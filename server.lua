
local ESX = exports['es_extended']:getSharedObject()


ESX.RegisterServerCallback('pm_playtime:getGroup', function(src, cb)
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        cb(xPlayer.getGroup())
    else
        cb(nil)
    end
end)


ESX.RegisterServerCallback('pm_playtime:getTime', function(src, cb)
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        local playtime = MySQL.Sync.fetchScalar("SELECT playtime FROM users WHERE identifier = @identifier", {['@identifier'] = xPlayer.getIdentifier()})
        playtime = playtime or 0  
        cb(playtime)
    else
        cb(nil)
    end
end)


ESX.RegisterServerCallback('pm_playtime:getCharacterName', function(src, cb)
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        local result = MySQL.Sync.fetchAll("SELECT firstname, lastname FROM users WHERE identifier = @identifier", {['@identifier'] = xPlayer.getIdentifier()})
        if result[1] then
            cb(result[1].firstname .. " " .. result[1].lastname)
        else
            cb("Unknown")
        end
    else
        cb("Unknown")
    end
end)


RegisterNetEvent('pm_playtime:AddTime')
AddEventHandler('pm_playtime:AddTime', function(zeit)
    local src = source
    if src == nil then
        return
    end

    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        local playtime = MySQL.Sync.fetchScalar("SELECT playtime FROM users WHERE identifier = @identifier", {['@identifier'] = xPlayer.getIdentifier()})
        playtime = playtime or 0  
        local realtime = playtime + (zeit or 0)  
        local nam = GetPlayerName(src)

        if nam == nil then
            return
        end

        MySQL.Async.execute("UPDATE users SET playtime = @realt WHERE identifier = @identifier", {
            ['@identifier'] = xPlayer.getIdentifier(),
            ['@realt'] = realtime
        })
        MySQL.Async.execute("UPDATE users SET name = @name WHERE identifier = @identifier", {
            ['@identifier'] = xPlayer.getIdentifier(),
            ['@name'] = nam
        })
    end
end)


RegisterCommand(Config.Commands.setPlaytime, function(source, args, rawCommand)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        local playerGroup = xPlayer.getGroup()
        if not isAdmin(playerGroup) then
            TriggerClientEvent('chat:addMessage', src, { args = { '[!]', Config.Messages.notAdmin }, color = { 255, 0, 0 } })
            return
        end

        if #args < 2 then
            TriggerClientEvent('chat:addMessage', src, { args = { '[!]', 'Usage: /setp {id} {minutes}' }, color = { 255, 0, 0 } })
            return
        end

        local targetId = tonumber(args[1])
        local minutes = tonumber(args[2])
        if targetId and minutes then
            local targetPlayer = ESX.GetPlayerFromId(targetId)
            if targetPlayer then
                MySQL.Async.execute("UPDATE users SET playtime = @playtime WHERE identifier = @identifier", {
                    ['@identifier'] = targetPlayer.getIdentifier(),
                    ['@playtime'] = minutes
                }, function(rowsChanged)
                    if rowsChanged > 0 then
                        TriggerClientEvent('chat:addMessage', src, { args = { '[!]', Config.Messages.setPlaytimeSuccess:format(GetPlayerName(targetId), minutes) }, color = { 0, 255, 0 } })
                        TriggerClientEvent('pm_playtime:UpdatePlaytime', targetId, minutes) -- Update the target player's playtime cache
                    else
                        TriggerClientEvent('chat:addMessage', src, { args = { '[!]', 'Failed to set playtime.' }, color = { 255, 0, 0 } })
                    end
                end)
            else
                TriggerClientEvent('chat:addMessage', src, { args = { '[!]', 'Player not found.' }, color = { 255, 0, 0 } })
            end
        else
            TriggerClientEvent('chat:addMessage', src, { args = { '[!]', 'Invalid arguments.' }, color = { 255, 0, 0 } })
        end
    else
        TriggerClientEvent('chat:addMessage', src, { args = {'[!]', 'Player not found.' }, color = { 255, 0, 0 } })
    end
end, false)


function isAdmin(group)
    for _, adminGroup in ipairs(Config.AdminGroups) do
        if group == adminGroup then
            return true
        end
    end
    return false
end


lib.callback.register('pm_playtime:checkPlaytime', function(source, weaponName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then

        local job = xPlayer.getJob().name
        for _, whitelistedJob in ipairs(Config.WhitelistedJobs) do
            if job == whitelistedJob then
                return true 
            end
        end


        for _, whitelistedWeapon in ipairs(Config.WhitelistedWeapons) do
            if weaponName == whitelistedWeapon then
                return true 
            end
        end


        local playtime = MySQL.Sync.fetchScalar("SELECT playtime FROM users WHERE identifier = @identifier", {['@identifier'] = xPlayer.getIdentifier()})
        playtime = playtime or 0  
        local playtimeHours = playtime / 60 


        if Config.RequireHours then
            return playtimeHours >= Config.RequiredHours 
        else
            for _, weapon in ipairs(Config.WeaponHours) do
                if weapon.weapon == weaponName then
                    return playtimeHours >= weapon.hours
                end
            end
        end
    end
    return false
end)


ESX.RegisterServerCallback('pm_playtime:getTime', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local playtime = MySQL.Sync.fetchScalar("SELECT playtime FROM users WHERE identifier = @identifier", {
            ['@identifier'] = xPlayer.getIdentifier()
        })
        playtime = playtime or 0 
        cb(playtime)
    else
        cb(nil)
    end
end)

exports('getHours', function(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        local playtime = MySQL.Sync.fetchScalar("SELECT playtime FROM users WHERE identifier = @identifier", {['@identifier'] = xPlayer.getIdentifier()})
        return playtime
    else
        return 0
    end
end)

exports('getHoursIdentifier', function(identifier)
    local playtime = MySQL.Sync.fetchScalar("SELECT playtime FROM users WHERE identifier = @identifier", {['@identifier'] = identifier})
    if playtime >= 0 then
        return playtime
    else
        return 0
    end
end)