Config = {}
Translation = {}

Config.Shopkeeper = 416176080 -- hash of the shopkeeper ped
Config.Locale = 'en' -- 'en', 'sv' or 'custom'
local copsNeeded = 1

Config.Shops = {
    {coords = vector3(24.03, -1345.63, 29.5-0.98), heading = 266.0, money = {150, 475}, cops = copsNeeded, blip = false, name = '7/11', cooldown = {hour = 1, minute = 0, second = 0}, robbed = false},
    {coords = vector3(-705.73, -914.91, 19.22-0.98), heading = 91.0, money = {150, 475}, cops = copsNeeded, blip = false, name = '7/11', cooldown = {hour = 1, minute = 0, second = 0}, robbed = false},
    {coords = vector3(1165.283, -322.409, 69.205-0.98), heading = 89.0, money = {150, 475}, cops = copsNeeded, blip = false, name = '7/11', cooldown = {hour = 1, minute = 0, second = 0}, robbed = false},
    {coords = vector3(-1819.917, 794.526, 138.082-0.98), heading = 131.0, money = {150, 475}, cops = copsNeeded, blip = false, name = '7/11', cooldown = {hour = 1, minute = 0, second = 0}, robbed = false},
    {coords = vector3(-3038.762, 584.141, 7.909-0.98), heading = 19.0, money = {150, 475}, cops = copsNeeded, blip = false, name = '7/11', cooldown = {hour = 1, minute = 0, second = 0}, robbed = false},
    {coords = vector3(-3242.379, 999.599, 12.831-0.98), heading = 349.0, money = {150, 475}, cops = copsNeeded, blip = false, name = '7/11', cooldown = {hour = 1, minute = 0, second = 0}, robbed = false},
    {coords = vector3(1727.416, 6415.314, 35.037-0.98), heading = 240.0, money = {150, 475}, cops = copsNeeded, blip = false, name = '7/11', cooldown = {hour = 1, minute = 0, second = 0}, robbed = false},
    {coords = vector3(1697.803, 4922.701, 42.064-0.98), heading = 328.0, money = {150, 475}, cops = copsNeeded, blip = false, name = '7/11', cooldown = {hour = 1, minute = 0, second = 0}, robbed = false},
    {coords = vector3(1959.820, 3739.945, 32.344-0.98), heading = 296.0, money = {150, 475}, cops = copsNeeded, blip = false, name = '7/11', cooldown = {hour = 1, minute = 0, second = 0}, robbed = false},
    {coords = vector3(2677.931, 3279.108, 55.241-0.98), heading = 330.0, money = {150, 475}, cops = copsNeeded, blip = false, name = '7/11', cooldown = {hour = 1, minute = 0, second = 0}, robbed = false},
    {coords = vector3(549.287, 2671.445, 42.157-0.98), heading = 104.0, money = {150, 475}, cops = copsNeeded, blip = false, name = '7/11', cooldown = {hour = 1, minute = 0, second = 0}, robbed = false},
    {coords = vector3(372.316, 326.488, 103.566-0.98), heading = 256.0, money = {150, 475}, cops = copsNeeded, blip = false, name = '7/11', cooldown = {hour = 1, minute = 0, second = 0}, robbed = false},
    {coords = vector3(-46.214, -1758.283, 29.421-0.98), heading = 47.0, money = {150, 475}, cops = copsNeeded, blip = false, name = '7/11', cooldown = {hour = 1, minute = 0, second = 0}, robbed = false}
}

Translation = {
    ['en'] = {
        ['shopkeeper'] = 'shopkeeper',
        ['robbed'] = "I was just robbed and ~r~don't ~w~have any money left!",
        ['cashrecieved'] = 'You got:',
        ['currency'] = '$',
        ['scared'] = 'Scared:',
        ['no_cops'] = 'There are ~r~not~w~ enough cops online!',
        ['cop_msg'] = 'We have sent a photo of the robber taken by the CCTV camera!',
        ['set_waypoint'] = 'Set waypoint to the store',
        ['hide_box'] = 'Close this box',
        ['robbery'] = 'Robbery in progress',
        ['walked_too_far'] = 'You walked too far away!'
    },
    ['sv'] = {
        ['shopkeeper'] = 'butiksbiträde',
        ['robbed'] = 'Jag blev precis rånad och har inga pengar kvar!',
        ['cashrecieved'] = 'Du fick:',
        ['currency'] = 'SEK',
        ['scared'] = 'Rädd:',
        ['no_cops'] = 'Det är inte tillräckligt med poliser online!',
        ['cop_msg'] = 'Vi har skickat en bild på rånaren från övervakningskamerorna!',
        ['set_waypoint'] = 'Sätt GPS punkt på butiken',
        ['hide_box'] = 'Stäng denna rutan',
        ['robbery'] = 'Pågående butiksrån',
        ['walked_too_far'] = 'Du gick för långt bort!'
    },
    ['custom'] = { -- edit this to your language
        ['shopkeeper'] = '',
        ['robbed'] = '',
        ['cashrecieved'] = '',
        ['currency'] = '',
        ['scared'] = '',
        ['no_cops'] = '',
        ['cop_msg'] = '',
        ['set_waypoint'] = '',
        ['hide_box'] = '',
        ['robbery'] = '',
        ['walked_too_far'] = ''
    }
}