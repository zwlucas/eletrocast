-- EletroCast Framework Configuration
Config = {}

-- Framework Settings
Config.FrameworkName = "EletroCast Framework"
Config.UseDebug = true
Config.UseMultiCharacter = true
Config.MaxCharacters = 3

-- Player Settings
Config.DefaultSpawn = vector4(195.17, -933.77, 29.7, 144.5) -- Mission Row
Config.EnablePVP = false
Config.ShowPlayerBlips = false

-- Economy Settings
Config.StartingCash = 5000
Config.StartingBank = 25000
Config.PaycheckInterval = 30 * 60 * 1000 -- 30 minutes
Config.EnableDirtyMoney = true

-- Inventory Settings
Config.MaxInventorySlots = 35
Config.MaxInventoryWeight = 120000 -- 120kg
Config.CleanupDroppedItems = true
Config.DropTimeout = 5 * 60 * 1000 -- 5 minutes

-- Vehicle Settings
Config.VehicleKeys = true
Config.VehicleDespawnTime = 10 * 60 * 1000 -- 10 minutes
Config.AllowedEngineToggles = true

-- Job Settings
Config.WhitelistJobs = {
    'police',
    'ambulance'
}

-- Database Settings
Config.MySQL = {
    UseOxMySQL = true,
    Host = 'localhost',
    Database = 'electrocast_framework',
    Username = 'root',
    Password = ''
}

-- Logging Settings
Config.Logging = {
    Enable = true,
    LogLevel = 'info', -- debug, info, warn, error
    LogToFile = true,
    LogToConsole = true
}

-- UI Settings (ox_lib integration)
Config.UI = {
    UseOxLib = true,
    NotificationPosition = 'top-right',
    ProgressBarPosition = 'bottom',
    MenuTheme = 'dark'
}

-- Security Settings
Config.Security = {
    AntiCheat = true,
    LogSuspiciousActivity = true,
    BanDuration = 24 * 60 * 60 * 1000, -- 24 hours
    MaxWarnings = 3
}

-- Zones and Locations
Config.Zones = {
    PillboxHospital = {
        coords = vector3(298.6, -584.4, 43.3),
        radius = 15.0
    },
    MissionRowPD = {
        coords = vector3(428.9, -984.5, 30.7),
        radius = 20.0
    },
    LosSantosCustoms = {
        coords = vector3(-365.4, -131.8, 38.3),
        radius = 10.0
    }
}

-- Permissions/Groups
Config.Groups = {
    ['superadmin'] = {
        level = 100,
        inherit = 'admin'
    },
    ['admin'] = {
        level = 80,
        inherit = 'mod'
    },
    ['mod'] = {
        level = 50,
        inherit = 'user'
    },
    ['user'] = {
        level = 0
    }
}