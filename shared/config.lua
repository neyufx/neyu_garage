-- Configurations des garages

Config = {
    vehicleLimit = 10, -- Limite de véhicules dans le garage
    splitGarages = true, -- Si true alors les véhicules sont stockée dans des garages différents
    returnPrice = 5000 -- Prix pour payer le changement de garage
}

GarageConfig = {
    -- Garage de secours mettre les même coordonées si vous voulez pas de garage de secours
    [1] = {
        garageName = "Parking Cube",
        menuCoords = vector3(213.59, -809.22, 31.01),
        maxDistance = 4.0,
        vehicleSpawnCoords = {
            {
                coord = vector3(238.13, -776.35, 30.0),
                heading = 160.0
            },
            {
                coord = vector3(232.6, -808.03, 30.0),
                heading = 70.81
            }
        },
        vehicleReturnCoords = vector3(214.99, -791.33, 30.84),
    },
    [2] = {
        garageName = "Parking Occupation",
        menuCoords = vector3(275.58, -344.90, 45.17),
        maxDistance = 3.0,
        vehicleSpawnCoords = {
            {
                coord = vector3(277.24, -340.0, 43.92),
                heading = 73.19
            },
            {
                coord = vector3(286.8, -332.53, 43.92),
                heading = 246.94
            }
        },
        vehicleReturnCoords = vector3(274.53, -328.69, 44.92),
    },
    [3] = {
        garageName = "Parking Central",
        menuCoords = vector3(-348.99, -875.03, 31.32),
        maxDistance = 5.0,
        vehicleSpawnCoords = {
            {
                coord = vector3(-334.89, -892.20, 30.07),
                heading = -13.0,
            },
            {
                coord = vector3(-324.0, -894.20, 30.07),
                heading = -13.0
            }
        },
        vehicleReturnCoords = vector3(-340.03, -876.65, 31.07),
    },
    [4] = {
        garageName = "Parking Brouge",
        menuCoords = vector3(345.22, -1687.72, 32.53),
        maxDistance = 3.0,
        vehicleSpawnCoords = {
            {
                coord = vector3(356.83, -1678.26, 31.54),
                heading = 48.5
            },
            {
                coord = vector3(361.68, -1672.95, 31.54),
                heading = 48.5
            }
        },
        vehicleReturnCoords = vector3(354.52, -1681.31, 32.54),
    },
    [5] = {
        garageName = "Parking Mirror",
        menuCoords = vector3(1036.24, -763.24, 57.99),
        maxDistance = 3.0,
        vehicleSpawnCoords = {
            {
                coord = vector3(1022.68, -755.25, 57.00),
                heading = 227.25
            },
            {
                coord = vector3(1027.93, -771.02, 57.30),
                heading = 145.0
            }
        },
        vehicleReturnCoords = vector3(1029.33, -763.94, 57.99),
    },
    [6] = {
        garageName = "Parking Aéroport",
        menuCoords = vector3(-954.56, -2704.25, 13.83),
        maxDistance = 3.0,
        vehicleSpawnCoords = {
            {
                coord = vector3(-961.68, -2699.57, 12.83),
                heading = 151.59
            },
            {
                coord = vector3(-964.62, -2697.72, 12.83),
                heading = 145.0
            },
            {
                coord = vector3(-970.62, -2695.68, 12.83),
                heading = 152.0
            },
            {
                coord = vector3(-970.1, -2693.92, 12.83),
                heading = 152.0
            },
            {
                coord = vector3(-973.12, -2692.39, 12.83),
                heading = 152.0
            }
        },
        vehicleReturnCoords = vector3(1029.33, -763.94, 57.99),
    },
    [7] = {
        garageName = "Parking Spanish",
        menuCoords = vector3(68.0, 12.92, 69.21),
        maxDistance = 5.0,
        vehicleSpawnCoords = {
            {
                coord = vector3(63.93, 16.25, 68.5),
                heading = 339.45
            },
            {
                coord = vector3(57.51, 18.05, 68.29),
                heading = 345.0
            },
        },
        vehicleReturnCoords = vector3(77.27, 20.96, 69.12),
    },
    [8] = {
        garageName = "Parking Rockfords",
        menuCoords = vector3(-726.86, -64.43, 41.75),
        maxDistance = 3.0,
        vehicleSpawnCoords = {
            {
                coord = vector3(-733.36, -71.78, 41.0),
                heading = 28.7
            },
            {
                coord = vector3(-743.26, -76.92, 41.0),
                heading = 27.12
            },
        },
        vehicleReturnCoords = vector3(77.27, 20.96, 69.12),
    },
    [9] = {
        garageName = "Parking Morningwood",
        menuCoords = vector3(-1207.39, -351.46, 37.29),
        maxDistance = 3.0,
        vehicleSpawnCoords = {
            {
                coord = vector3(-1200.66, -371.03, 36.59),
                heading = 28.34
            },
            {
                coord = vector3(-1207.84, -374.71, 36.73),
                heading = 28.7
            },
        },
        vehicleReturnCoords = vector3(77.27, 20.96, 69.12),
    },
    [10] = {
        garageName = "Parking Highway",
        menuCoords = vector3(-2174.84, -365.56, 13.1),
        maxDistance = 3.0,
        vehicleSpawnCoords = {
            {
                coord = vector3(-2185.45, -369.63, 12.47),
                heading = 168.27
            },
            {
                coord = vector3(-2172.68, -372.33, 12.49),
                heading = 168.49
            },
        },
        vehicleReturnCoords = vector3(-2166.41, -373.17, 13.07),
    },
}