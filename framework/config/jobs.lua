-- EletroCast Framework Jobs Configuration
Jobs = {}

-- Job Definitions (QBCore-style)
Jobs['unemployed'] = {
    label = 'Unemployed',
    type = 'unemployed',
    defaultDuty = false,
    offDutyPay = false,
    grades = {
        [0] = {
            name = 'Unemployed',
            payment = 200,
            isboss = false
        }
    }
}

Jobs['police'] = {
    label = 'Los Santos Police Department',
    type = 'leo',
    defaultDuty = true,
    offDutyPay = false,
    grades = {
        [0] = {
            name = 'Cadet',
            payment = 750,
            isboss = false
        },
        [1] = {
            name = 'Officer',
            payment = 1000,
            isboss = false
        },
        [2] = {
            name = 'Sergeant',
            payment = 1250,
            isboss = false
        },
        [3] = {
            name = 'Lieutenant',
            payment = 1500,
            isboss = true
        },
        [4] = {
            name = 'Captain',
            payment = 1750,
            isboss = true
        },
        [5] = {
            name = 'Chief',
            payment = 2000,
            isboss = true
        }
    }
}

Jobs['ambulance'] = {
    label = 'Los Santos Medical Department',
    type = 'ems',
    defaultDuty = true,
    offDutyPay = false,
    grades = {
        [0] = {
            name = 'Trainee',
            payment = 750,
            isboss = false
        },
        [1] = {
            name = 'Paramedic',
            payment = 1000,
            isboss = false
        },
        [2] = {
            name = 'Doctor',
            payment = 1250,
            isboss = false
        },
        [3] = {
            name = 'Surgeon',
            payment = 1500,
            isboss = true
        },
        [4] = {
            name = 'Chief',
            payment = 1750,
            isboss = true
        }
    }
}

Jobs['mechanic'] = {
    label = 'Mechanic',
    type = 'mechanic',
    defaultDuty = true,
    offDutyPay = false,
    grades = {
        [0] = {
            name = 'Trainee',
            payment = 500,
            isboss = false
        },
        [1] = {
            name = 'Mechanic',
            payment = 750,
            isboss = false
        },
        [2] = {
            name = 'Lead Mechanic',
            payment = 1000,
            isboss = true
        },
        [3] = {
            name = 'Manager',
            payment = 1250,
            isboss = true
        }
    }
}

Jobs['taxi'] = {
    label = 'Taxi Driver',
    type = 'taxi',
    defaultDuty = true,
    offDutyPay = false,
    grades = {
        [0] = {
            name = 'Driver',
            payment = 300,
            isboss = false
        },
        [1] = {
            name = 'Experienced Driver',
            payment = 450,
            isboss = true
        }
    }
}

Jobs['trucker'] = {
    label = 'Trucker',
    type = 'trucker',
    defaultDuty = true,
    offDutyPay = false,
    grades = {
        [0] = {
            name = 'Driver',
            payment = 400,
            isboss = false
        },
        [1] = {
            name = 'Experienced Driver',
            payment = 600,
            isboss = false
        },
        [2] = {
            name = 'Lead Driver',
            payment = 800,
            isboss = true
        }
    }
}

Jobs['realestate'] = {
    label = 'Real Estate',
    type = 'realestate',
    defaultDuty = true,
    offDutyPay = false,
    grades = {
        [0] = {
            name = 'Agent',
            payment = 600,
            isboss = false
        },
        [1] = {
            name = 'Senior Agent',
            payment = 800,
            isboss = false
        },
        [2] = {
            name = 'Manager',
            payment = 1200,
            isboss = true
        }
    }
}

-- Job Centers/Locations
JobCenters = {
    {
        coords = vector3(-265.0, -963.6, 31.2),
        jobs = {'taxi', 'trucker', 'mechanic'},
        blip = {
            sprite = 351,
            color = 2,
            scale = 0.8,
            label = 'Job Center'
        }
    }
}

-- Boss Actions Locations
BossActions = {
    ['police'] = {
        coords = vector3(461.45, -986.2, 30.73),
        jobs = {'police'},
        grade = 3 -- Minimum grade to access
    },
    ['ambulance'] = {
        coords = vector3(335.46, -594.52, 43.28),
        jobs = {'ambulance'},
        grade = 3
    },
    ['mechanic'] = {
        coords = vector3(-347.99, -133.43, 39.01),
        jobs = {'mechanic'},
        grade = 2
    }
}