-- EletroCast Framework Items Configuration
Items = {}

-- Item Definitions
Items['phone'] = {
    name = 'phone',
    label = 'Phone',
    weight = 250,
    type = 'item',
    image = 'phone.png',
    unique = false,
    useable = true,
    shouldClose = false,
    combinable = nil,
    description = 'A basic smartphone for communication'
}

Items['id_card'] = {
    name = 'id_card',
    label = 'ID Card',
    weight = 10,
    type = 'item',
    image = 'id_card.png',
    unique = true,
    useable = true,
    shouldClose = false,
    combinable = nil,
    description = 'Personal identification card with your details'
}

Items['driver_license'] = {
    name = 'driver_license',
    label = 'Driver License',
    weight = 10,
    type = 'item',
    image = 'driver_license.png',
    unique = true,
    useable = true,
    shouldClose = false,
    combinable = nil,
    description = 'Official driving license - required to drive vehicles'
}

Items['cash'] = {
    name = 'cash',
    label = 'Cash',
    weight = 0,
    type = 'item',
    image = 'cash.png',
    unique = false,
    useable = false,
    shouldClose = false,
    combinable = nil,
    description = 'Physical money for transactions'
}

-- Food & Drink Items
Items['burger'] = {
    name = 'burger',
    label = 'Burger',
    weight = 350,
    type = 'item',
    image = 'burger.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'A delicious burger that will satisfy your hunger'
}

Items['water'] = {
    name = 'water',
    label = 'Water',
    weight = 250,
    type = 'item',
    image = 'water.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Fresh water bottle to quench your thirst'
}

Items['coffee'] = {
    name = 'coffee',
    label = 'Coffee',
    weight = 200,
    type = 'item',
    image = 'coffee.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Hot coffee to keep you energized'
}

-- Medical Items
Items['bandage'] = {
    name = 'bandage',
    label = 'Bandage',
    weight = 150,
    type = 'item',
    image = 'bandage.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Medical bandage for treating minor wounds'
}

Items['painkillers'] = {
    name = 'painkillers',
    label = 'Painkillers',
    weight = 100,
    type = 'item',
    image = 'painkillers.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Pills to relieve pain and restore health'
}

-- Tools & Equipment
Items['lockpick'] = {
    name = 'lockpick',
    label = 'Lockpick',
    weight = 50,
    type = 'item',
    image = 'lockpick.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Useful tool for picking locks'
}

Items['repairkit'] = {
    name = 'repairkit',
    label = 'Repair Kit',
    weight = 2500,
    type = 'item',
    image = 'repairkit.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Basic vehicle repair kit'
}

Items['advancedrepairkit'] = {
    name = 'advancedrepairkit',
    label = 'Advanced Repair Kit',
    weight = 4000,
    type = 'item',
    image = 'advancedrepairkit.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Professional vehicle repair kit for complex repairs'
}

Items['jerry_can'] = {
    name = 'jerry_can',
    label = 'Jerry Can',
    weight = 2000,
    type = 'item',
    image = 'jerry_can.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Fuel container for refueling vehicles'
}

-- Weapons (basic items, actual weapon handling would be separate)
Items['weapon_pistol'] = {
    name = 'weapon_pistol',
    label = 'Pistol',
    weight = 1200,
    type = 'weapon',
    image = 'weapon_pistol.png',
    unique = true,
    useable = false,
    shouldClose = false,
    combinable = nil,
    description = 'A standard pistol for self-defense'
}

Items['pistol_ammo'] = {
    name = 'pistol_ammo',
    label = 'Pistol Ammo',
    weight = 100,
    type = 'item',
    image = 'pistol_ammo.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Ammunition for pistols'
}

-- Illegal Items
Items['marijuana'] = {
    name = 'marijuana',
    label = 'Marijuana',
    weight = 50,
    type = 'item',
    image = 'marijuana.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Illegal substance - possession is a crime',
    illegal = true
}

Items['cocaine'] = {
    name = 'cocaine',
    label = 'Cocaine',
    weight = 100,
    type = 'item',
    image = 'cocaine.png',
    unique = false,
    useable = false,
    shouldClose = true,
    combinable = nil,
    description = 'Highly illegal drug - severe penalties apply',
    illegal = true
}

-- Vehicle Items
Items['car_keys'] = {
    name = 'car_keys',
    label = 'Car Keys',
    weight = 50,
    type = 'item',
    image = 'car_keys.png',
    unique = true,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Keys to start and lock your vehicle'
}

-- Job-specific Items
Items['police_badge'] = {
    name = 'police_badge',
    label = 'Police Badge',
    weight = 100,
    type = 'item',
    image = 'police_badge.png',
    unique = true,
    useable = true,
    shouldClose = false,
    combinable = nil,
    description = 'Official police identification badge',
    job = 'police'
}

Items['handcuffs'] = {
    name = 'handcuffs',
    label = 'Handcuffs',
    weight = 300,
    type = 'item',
    image = 'handcuffs.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Police handcuffs for detaining suspects',
    job = 'police'
}

Items['medkit'] = {
    name = 'medkit',
    label = 'Medical Kit',
    weight = 1500,
    type = 'item',
    image = 'medkit.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Professional medical kit for treating injuries',
    job = 'ambulance'
}

-- Item Categories for better organization
ItemCategories = {
    ['essentials'] = {'phone', 'id_card', 'driver_license', 'cash'},
    ['food'] = {'burger', 'water', 'coffee'},
    ['medical'] = {'bandage', 'painkillers', 'medkit'},
    ['tools'] = {'lockpick', 'repairkit', 'advancedrepairkit', 'jerry_can'},
    ['weapons'] = {'weapon_pistol', 'pistol_ammo'},
    ['illegal'] = {'marijuana', 'cocaine'},
    ['vehicle'] = {'car_keys'},
    ['job_police'] = {'police_badge', 'handcuffs'},
    ['job_ems'] = {'medkit'}
}