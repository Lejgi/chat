Config = {}

-- Language selection
Config.Locale = 'en'

-- Basic translations used by the tracker
Config.Lang = {
    en = {
        ['❌ Nepodařilo se odstranit tracker!'] = '❌ Failed to remove tracker!',
        ['🚫 Nemáš oprávnění instalovat GPS!'] = '🚫 You do not have permission to install GPS!',
        ['🚫 Nikdo v blízkosti.'] = '🚫 No one nearby.',
        ['📡 Instalace GPS Trackeru'] = '📡 Install GPS Tracker',
        ['🚗 Nainstalovat GPS Tracker na vozidlo'] = '🚗 Install GPS Tracker on vehicle',
        ['📂 FBI Tablet'] = '📂 FBI Tablet',
        ['📂 Sledování osob'] = '📂 Person Tracking',
        ['🚗 Sledování vozidel'] = '🚗 Vehicle Tracking',
        ['📂 Otevřít FBI Tablet'] = '📂 Open FBI Tablet',
        ['📡 Nainstalovat GPS Tracker'] = '📡 Install GPS Tracker',
        ['🚗 Vozidlo nebylo nalezeno!'] = '🚗 Vehicle not found!',
        ['✅ Tracker odstraněn.'] = '✅ Tracker removed.',
        ['❌ Žádné vozidlo poblíž.'] = '❌ No vehicle nearby.',
        ['🛰️ Vyber akci s GPS Detektorem'] = '🛰️ Choose action with GPS Detector',
        ['🎯 Skenuj hráče'] = '🎯 Scan player',
        ['🚗 Skenuj vozidlo'] = '🚗 Scan vehicle',
        ['🔍 Tracker Detected'] = '🔍 Tracker Detected',
        ['❌ Pokusit se odstranit tracker'] = '❌ Try to remove tracker',
        ['🚫 Nemáš přístup k FBI Tabletu!'] = '🚫 You have no access to the FBI Tablet!'
    },
    cz = {}
}

function _L(key)
    local lang = Config.Lang[Config.Locale] or {}
    return lang[key] or key
end

Config.TapDeviceItem = 'tap_device'
Config.GpsTrackerItem = 'gps_tracker'
Config.RequiredJob = 'fbi'
Config.WebhookUrl = 'https://discord.com/api/webhooks/1364994489080484025/bcByyohAZyNXJrocFK8TLZu3-Lyf0tODX77PWkESGrasztBXhgrcJCV7DIV6933ZBS1o'

Config.TabletZone = {
    coords = vec3(-26.0095, 6498.9956, 31.2844), -- Přizpůsob si lokaci
    size = vec3(1.5, 1.5, 2.0),
    rotation = 0.0
}

Config.DetectorRadius = 3.0 -- Maximální vzdálenost od vozidla (v metrech)
Config.DetectorFailureChance = 1 -- % šance na selhání odstranění trackeru

