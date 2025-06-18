Config = {}

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