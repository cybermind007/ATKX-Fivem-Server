Config              = {}
Config.DrawDistance = 100.0
Config.MaxDelivery	= 10
Config.TruckPrice	= 30     -- old config from orginal script not used in this version.
Config.Locale = 'en'
Config.MulitplyBags = true   -- Multiplies BagPay by number of workers - 4 max.
Config.TruckPlateNumb = 0
Config.BagPay       = 4

Config.Trucks = {
	"trash",
}

Config.Cloakroom = {
	CloakRoom = {
			Pos   = {x = -321.70, y = -1545.94, z = 31.02},
			Size  = {x = 1.0, y = 1.0, z = 1.0},
			Color = {r = 255, g = 0, b = 0},
			Type  = 20
		},
}

Config.Zones = {
	VehicleSpawner = {
			Pos   = {x = -316.16, y = -1536.08, z = 27.65},
			Size  = {x = 1.0, y = 1.0, z = 1.0},
			Color = {r = 255, g = 0, b = 0},
			Type  = 20
		},

	VehicleSpawnPoint = {
			Pos   = {x = -328.50, y = -1520.99, z = 27.53},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Color = {r = 0, g = 0, b = 0},
			Type  = -27
		},
}
Config.DumpstersAvaialbe = {
    "prop_dumpster_01a",
    "prop_dumpster_02a",
	"prop_dumpster_02b",
	"prop_dumpster_3a",
	"prop_dumpster_4a",
	"prop_dumpster_4b",
	"prop_skip_01a",
	"prop_skip_02a",
	"prop_skip_06a",
	"prop_skip_05a",
	"prop_skip_03",
	"prop_skip_10a"
}


Config.Livraison = {
	-------------------------------------------Los Santos
		-- fleeca
		Delivery1LS = {
				Pos   = {x = 114.83280181885, y = -1462.3127441406, z = 29.295083999634},
				Color = {r = 0, g = 0, b = 0},
				Size  = {x = 5.0, y = 5.0, z = 3.0},
				Color = {r = 0, g = 0, b = 0},
				Type  = 27,
				Paye = 312
			},
		-- fleeca2
		Delivery2LS = {
				Pos   = {x = -6.0481648445129, y = -1566.2338867188, z = 29.209197998047},
				Color = {r = 0, g = 0, b = 0},
				Size  = {x = 5.0, y = 5.0, z = 3.0},
				Color = {r = 0, g = 0, b = 0},
				Type  = 27,
				Paye = 317
			},
		-- blainecounty
		Delivery3LS = {
				Pos   = {x = -1.8858588933945, y = -1729.553832578, z = 29.25233840942},
				Color = {r = 0, g = 0, b = 0},
				Size  = {x = 5.0, y = 5.0, z = 3.0},
				Color = {r = 0, g = 0, b = 0},
				Type  = 27,
				Paye = 318
			},
		-- PrincipalBank
		Delivery4LS = {
				Pos   = {x = 159.09, y = -1816.69, z = 27.9},
				Color = {r = 0, g = 0, b = 0},
				Size  = {x = 5.0, y = 5.0, z = 3.0},
				Color = {r = 0, g = 0, b = 0},
				Type  = 27,
				Paye = 313
			},
		-- route68e
		Delivery5LS = {
				Pos   = {x = 358.94696044922, y = -1805.0723876953, z = 28.966590881348},
				Color = {r = 0, g = 0, b = 0},
				Size  = {x = 5.0, y = 5.0, z = 3.0},
				Color = {r = 0, g = 0, b = 0},
				Type  = 27,
				Paye = 302
			},
		--littleseoul
		Delivery6LS = {
				Pos   = {x = 481.36560058594, y = -1274.8297119141, z = 29.64475440979},
				Color = {r = 0, g = 0, b = 0},
				Size  = {x = 5.0, y = 5.0, z = 3.0},
				Color = {r = 0, g = 0, b = 0},
				Type  = 27,
				Paye = 306
			},
		--Mt Haan Dr Radio Tower
		Delivery7LS = {
				Pos   = {x = 342.78308105469, y = -1036.4720458984, z = 29.194206237793},
				Color = {r = 0, g = 0, b = 0},
				Size  = {x = 5.0, y = 5.0, z = 3.0},
				Color = {r = 0, g = 0, b = 0},
				Type  = 27,
				Paye = 305
			},
	------------------------------------------- 2nd Patrol 
		-- Elysian Fields
		Delivery1BC = {
				Pos   = {x = 443.96984863281, y = -574.33978271484, z = 28.494501113892},
				Color = {r = 0, g = 0, b = 0},
				Size  = {x = 5.0, y = 5.0, z = 3.0},
				Color = {r = 0, g = 0, b = 0},
				Type  = 27,
				Paye = 301
			},
		-- Dutch London
		Delivery2BC = {
				Pos   = {x = -31.948055267334, y = -93.437454223633, z = 57.249073028564},
				Color = {r = 0, g = 0, b = 0},
				Size  = {x = 5.0, y = 5.0, z = 3.0},
				Color = {r = 0, g = 0, b = 0},
				Type  = 27,
				Paye = 321
			},
		-- Autopia Pkwy
		Delivery3BC = {
				Pos   = {x = 283.10873413086, y = -164.81878662109, z = 60.060565948486},
				Color = {r = 0, g = 0, b = 0},
				Size  = {x = 5.0, y = 5.0, z = 3.0},
				Color = {r = 0, g = 0, b = 0},
				Type  = 27,
				Paye = 325
			},
			
		RetourCamion = {
				Pos   = {x = -335.26095581055, y = -1529.5614013672, z = 27.565467834473},
				Color = {r = 0, g = 0, b = 0},
				Size  = {x = 5.0, y = 5.0, z = 3.0},
				Color = {r = 0, g = 0, b = 0},
				Type  = 27,
				Paye = 300
			},
		
		AnnulerMission = {
				Pos   = {x = -314.62796020508, y = -1514.5662841797, z = 27.677434921265},
				Color = {r = 0, g = 0, b = 0},
				Size  = {x = 5.0, y = 5.0, z = 3.0},
				Color = {r = 0, g = 0, b = 0},
				Type  = 27,
				Paye = 300
			},
	}