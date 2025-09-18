-- EletroCast Framework Vehicles Configuration
Vehicles = {}

-- Vehicle Categories and Classifications
VehicleClasses = {
    [0] = 'compacts',
    [1] = 'sedans',
    [2] = 'suvs',
    [3] = 'coupes',
    [4] = 'muscle',
    [5] = 'sports_classics',
    [6] = 'sports',
    [7] = 'super',
    [8] = 'motorcycles',
    [9] = 'off_road',
    [10] = 'industrial',
    [11] = 'utility',
    [12] = 'vans',
    [13] = 'cycles',
    [14] = 'boats',
    [15] = 'helicopters',
    [16] = 'planes',
    [17] = 'service',
    [18] = 'emergency',
    [19] = 'military',
    [20] = 'commercial',
    [21] = 'trains'
}

-- Civilian Vehicles
Vehicles['adder'] = {
    model = 'adder',
    name = 'Truffade Adder',
    brand = 'Truffade',
    price = 1000000,
    category = 'super',
    type = 'automobile',
    shop = 'pdm',
    fuel = {
        type = 'gasoline',
        capacity = 65
    },
    performance = {
        speed = 95,
        acceleration = 90,
        braking = 85,
        handling = 80
    }
}

Vehicles['sultanrs'] = {
    model = 'sultanrs',
    name = 'Karin Sultan RS',
    brand = 'Karin',
    price = 95000,
    category = 'sports',
    type = 'automobile',
    shop = 'pdm',
    fuel = {
        type = 'gasoline',
        capacity = 60
    },
    performance = {
        speed = 85,
        acceleration = 88,
        braking = 80,
        handling = 85
    }
}

Vehicles['bison'] = {
    model = 'bison',
    name = 'Bravado Bison',
    brand = 'Bravado',
    price = 30000,
    category = 'vans',
    type = 'automobile',
    shop = 'pdm',
    fuel = {
        type = 'gasoline',
        capacity = 80
    },
    performance = {
        speed = 65,
        acceleration = 60,
        braking = 70,
        handling = 65
    }
}

Vehicles['faggio2'] = {
    model = 'faggio2',
    name = 'Pegassi Faggio',
    brand = 'Pegassi',
    price = 4000,
    category = 'motorcycles',
    type = 'bike',
    shop = 'pdm',
    fuel = {
        type = 'gasoline',
        capacity = 15
    },
    performance = {
        speed = 45,
        acceleration = 70,
        braking = 60,
        handling = 80
    }
}

-- Emergency Vehicles
Vehicles['police'] = {
    model = 'police',
    name = 'Police Cruiser',
    brand = 'Vapid',
    price = 0,
    category = 'emergency',
    type = 'automobile',
    job = 'police',
    fuel = {
        type = 'gasoline',
        capacity = 70
    },
    performance = {
        speed = 85,
        acceleration = 80,
        braking = 85,
        handling = 80
    },
    extras = {
        livery = true,
        lightbar = true,
        siren = true
    }
}

Vehicles['police2'] = {
    model = 'police2',
    name = 'Police Buffalo',
    brand = 'Bravado',
    price = 0,
    category = 'emergency',
    type = 'automobile',
    job = 'police',
    fuel = {
        type = 'gasoline',
        capacity = 70
    },
    performance = {
        speed = 90,
        acceleration = 85,
        braking = 85,
        handling = 85
    },
    extras = {
        livery = true,
        lightbar = true,
        siren = true
    }
}

Vehicles['ambulance'] = {
    model = 'ambulance',
    name = 'Ambulance',
    brand = 'Brute',
    price = 0,
    category = 'emergency',
    type = 'automobile',
    job = 'ambulance',
    fuel = {
        type = 'gasoline',
        capacity = 100
    },
    performance = {
        speed = 75,
        acceleration = 65,
        braking = 80,
        handling = 70
    },
    extras = {
        livery = true,
        lightbar = true,
        siren = true
    }
}

-- Work Vehicles
Vehicles['flatbed'] = {
    model = 'flatbed',
    name = 'Flatbed Truck',
    brand = 'MTL',
    price = 45000,
    category = 'utility',
    type = 'automobile',
    shop = 'truck_dealer',
    job = 'mechanic',
    fuel = {
        type = 'diesel',
        capacity = 120
    },
    performance = {
        speed = 60,
        acceleration = 45,
        braking = 70,
        handling = 50
    }
}

Vehicles['towtruck'] = {
    model = 'towtruck',
    name = 'Tow Truck',
    brand = 'Brute',
    price = 35000,
    category = 'utility',
    type = 'automobile',
    shop = 'truck_dealer',
    job = 'mechanic',
    fuel = {
        type = 'diesel',
        capacity = 100
    },
    performance = {
        speed = 65,
        acceleration = 50,
        braking = 75,
        handling = 55
    }
}

Vehicles['taxi'] = {
    model = 'taxi',
    name = 'Downtown Taxi',
    brand = 'Vapid',
    price = 15000,
    category = 'service',
    type = 'automobile',
    job = 'taxi',
    fuel = {
        type = 'gasoline',
        capacity = 60
    },
    performance = {
        speed = 70,
        acceleration = 65,
        braking = 70,
        handling = 70
    }
}

-- Vehicle Shops Configuration
VehicleShops = {
    ['pdm'] = {
        name = 'Premium Deluxe Motorsport',
        coords = vector3(-56.79, -1096.7, 25.42),
        categories = {'compacts', 'sedans', 'suvs', 'coupes', 'muscle', 'sports_classics', 'sports', 'super', 'motorcycles', 'off_road', 'vans', 'cycles'},
        blip = {
            sprite = 326,
            color = 3,
            scale = 0.8
        }
    },
    ['truck_dealer'] = {
        name = 'Truck Dealer',
        coords = vector3(1224.86, -3326.29, 5.82),
        categories = {'utility', 'industrial', 'commercial'},
        blip = {
            sprite = 477,
            color = 17,
            scale = 0.8
        }
    }
}

-- Garage Locations
Garages = {
    ['centralgarage'] = {
        name = 'Central Garage',
        coords = vector3(215.9, -810.06, 30.73),
        spawn = vector4(215.9, -810.06, 30.73, 157.5),
        public = true,
        job = nil
    },
    ['motelgarage'] = {
        name = 'Motel Garage',
        coords = vector3(273.43, -343.99, 44.91),
        spawn = vector4(273.43, -343.99, 44.91, 342.03),
        public = true,
        job = nil
    },
    ['pdgarage'] = {
        name = 'Police Garage',
        coords = vector3(454.6, -1017.4, 28.4),
        spawn = vector4(454.6, -1017.4, 28.4, 90.0),
        public = false,
        job = 'police'
    },
    ['emsgarage'] = {
        name = 'EMS Garage',
        coords = vector3(294.23, -574.03, 43.18),
        spawn = vector4(294.23, -574.03, 43.18, 70.0),
        public = false,
        job = 'ambulance'
    }
}

-- Vehicle Fuel Types
FuelTypes = {
    ['gasoline'] = {
        name = 'Gasoline',
        price = 3.5, -- per liter
        stations = 'gas_station'
    },
    ['diesel'] = {
        name = 'Diesel',
        price = 3.2, -- per liter
        stations = 'gas_station'
    },
    ['electric'] = {
        name = 'Electric',
        price = 2.0, -- per kWh
        stations = 'charging_station'
    }
}

-- Fuel Stations
FuelStations = {
    {
        coords = vector3(49.4187, 2778.793, 58.043),
        type = 'gas_station',
        blip = {
            sprite = 361,
            color = 1,
            scale = 0.9
        }
    },
    {
        coords = vector3(263.894, 2606.463, 44.983),
        type = 'gas_station',
        blip = {
            sprite = 361,
            color = 1,
            scale = 0.9
        }
    },
    {
        coords = vector3(1039.958, 2671.134, 39.550),
        type = 'gas_station',
        blip = {
            sprite = 361,
            color = 1,
            scale = 0.9
        }
    }
}