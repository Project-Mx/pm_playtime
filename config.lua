Config = {}
Config.RequireHours = false -- Set to true to enforce general required hours, false to use specific weapon hours
Config.RequiredHours = 40 -- Default required playtime in hours
Config.WeaponHours = {
    { weapon = "WEAPON_PISTOL", hours = 50 },
    { weapon = "WEAPON_SMG", hours = 60 },
    { weapon = "WEAPON_KNIFE", hours = 20 },
    { weapon = "WEAPON_BAT", hours = 15 },
    -- Add other weapons with specific hours here
}
Config.WhitelistedJobs = { "police", "ambulance" } -- Jobs that bypass the playtime check
Config.WhitelistedWeapons = {  -- Weapons that are always allowed
    "WEAPON_NIGHTSTICK", 
    "WEAPON_STUNGUN" 
}
Config.AdminGroups = { "superadmin", "admin" } -- Admin groups allowed to use the set playtime command
Config.Commands = {
    setPlaytime = 'setp', -- Command for admins to set players' playtime
    getPlaytime = 'playtime' -- Command to check playtime
}
Config.Messages = {
    noPlaytime = "[WEAPONS]: ^0Your weapon has been removed as you don't have the required playtime to use a weapon. (%s Hours)",
    generalNoPlaytime = "[WEAPONS]: ^0Your weapon has been removed as you don't have the required playtime to use any weapon. (%s Hours)",
    playtimeMessage = 'You have a total of %s playtime!',
    setPlaytimeSuccess = 'You have successfully set %s\'s playtime to %s minutes.',
    notAdmin = 'You do not have permission to use this command.'
}
