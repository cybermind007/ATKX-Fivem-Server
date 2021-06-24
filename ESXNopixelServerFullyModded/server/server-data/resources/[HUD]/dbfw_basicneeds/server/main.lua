DBFWCore = nil

TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)

DBFWCore.RegisterUsableItem('bread', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('bread', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 500000)
	TriggerClientEvent('dbfw_basicneeds:onEat', source)
	TriggerClientEvent('notification', source, _U('used_bread'))
end)

DBFWCore.RegisterUsableItem('chocolate', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('chocolate', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 80000)
	TriggerClientEvent('dbfw_basicneeds:onEatChocolate', source)
	TriggerClientEvent('notification', source, _U('used_chocolate'))
end)

DBFWCore.RegisterUsableItem('orange', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('orange', 1)

	TriggerClientEvent('dbfw_status:add', source, 'thirst', 80000)
	TriggerClientEvent('dbfw_basicneeds:onDrinkCocaCola', source)
end)

DBFWCore.RegisterUsableItem('candy', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('candy', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 80000)
	TriggerClientEvent('dbfw_basicneeds:onEatCandy', source)
	TriggerClientEvent('notification', source, _U('used_candy'))
end)

DBFWCore.RegisterUsableItem('IceCream', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('IceCream', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 80000)
	TriggerClientEvent('dbfw_status:add', source, 'thirst', -5000)
	TriggerClientEvent('dbfw_basicneeds:onEatIceCream', source)
	TriggerClientEvent('notification', source, _U('used_IceCream'))
end)

DBFWCore.RegisterUsableItem('pancakes', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('pancakes', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 80000)
	TriggerClientEvent('dbfw_status:add', source, 'thirst', -5000)
	TriggerClientEvent('dbfw_basicneeds:onEatPancakes', source)
	TriggerClientEvent('notification', source, _U('used_pancakes'))
end)

DBFWCore.RegisterUsableItem('icecoffee', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('icecoffee', 1)

	TriggerClientEvent('dbfw_status:add', source, 'thirst', 200000)
	TriggerClientEvent('dbfw_basicneeds:onDrinkNoProp', source, 7000)
	TriggerClientEvent('notification', source, _U('used_icecoffee'))
end)

DBFWCore.RegisterUsableItem('milkshake', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('milkshake', 1)

	TriggerClientEvent('dbfw_status:add', source, 'thirst', 200000)
	TriggerClientEvent('dbfw_basicneeds:onDrinkNoProp', source, 8000)
	TriggerClientEvent('notification', source, _U('used_milkshake'))
end)

DBFWCore.RegisterUsableItem('slushy', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('slushy', 1)

	TriggerClientEvent('dbfw_status:add', source, 'thirst', 200000)
	TriggerClientEvent('dbfw_basicneeds:onDrinkNoProp', source, 8000)
	TriggerClientEvent('notification', source, _U('used_slushy'))
end)


DBFWCore.RegisterUsableItem('hotdog', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('hotdog', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 250000)
	TriggerClientEvent('dbfw_basicneeds:onEatHotdog', source)
	TriggerClientEvent('notification', source, _U('used_hotdog'))
end)

DBFWCore.RegisterUsableItem('schnitzel', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('schnitzel', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 300000)
	TriggerClientEvent('dbfw_basicneeds:onEatNoProp', source, 4000)
	TriggerClientEvent('notification', source, _U('used_schnitzel'))
end)

DBFWCore.RegisterUsableItem('filet_mignon', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('filet_mignon', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 350000)
	TriggerClientEvent('dbfw_basicneeds:onEatNoProp', source, 6500)
	TriggerClientEvent('notification', source, _U('used_filet_mignon'))
end)

DBFWCore.RegisterUsableItem('taco', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('taco', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 300000)
	TriggerClientEvent('dbfw_basicneeds:onDrinkTaco', source)
	TriggerClientEvent('notification', source, _U('used_taco'))
end)

DBFWCore.RegisterUsableItem('torpedo', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('torpedo', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 300000)
	TriggerClientEvent('dbfw_basicneeds:onDrinkTaco', source)
	TriggerClientEvent('notification', source, _U('used_torpedo'))
end)

DBFWCore.RegisterUsableItem('torta', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('torta', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 300000)
	TriggerClientEvent('dbfw_basicneeds:onDrinkTaco', source)
	TriggerClientEvent('notification', source, _U('used_torta'))
end)

DBFWCore.RegisterUsableItem('fishtaco', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('fishtaco', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 300000)
	TriggerClientEvent('dbfw_basicneeds:onDrinkTaco', source)
	TriggerClientEvent('notification', source, _U('used_fishtaco'))
end)

DBFWCore.RegisterUsableItem('bleeder', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('bleeder', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 300000)
	TriggerClientEvent('dbfw_basicneeds:onDrinkTaco', source)
	TriggerClientEvent('notification', source, _U('used_bleeder'))
end)

DBFWCore.RegisterUsableItem('sushiplate', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('sushiplate', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 300000)
	TriggerClientEvent('dbfw_basicneeds:onEatNoProp', source)
	TriggerClientEvent('notification', source, 'You ate 1x Sushi Plate')
end)

DBFWCore.RegisterUsableItem('sushirolls', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('sushirolls', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 300000)
	TriggerClientEvent('dbfw_basicneeds:onEatNoProp', source)
	TriggerClientEvent('notification', source, 'You ate 1x Sushi Rolls')
end)

DBFWCore.RegisterUsableItem('onigiri', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('onigiri', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 300000)
	TriggerClientEvent('dbfw_basicneeds:onEatNoProp', source)
	TriggerClientEvent('notification', source, 'You ate 1x Onigiri')
end)

DBFWCore.RegisterUsableItem('mingo', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('mingo', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 300000)
	TriggerClientEvent('dbfw_basicneeds:onEatNoProp', source)
	TriggerClientEvent('notification', source, 'You ate 1x Mingo')
end)

DBFWCore.RegisterUsableItem('veggysalad', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('veggysalad', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 300000)
	TriggerClientEvent('dbfw_basicneeds:onEatNoProp', source)
	TriggerClientEvent('notification', source, 'You ate 1x Veggy Salad')
end)

DBFWCore.RegisterUsableItem('sandwich', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('sandwich', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 350000)
	TriggerClientEvent('dbfw_basicneeds:onEatSandwich', source)
	TriggerClientEvent('notification', source, _U('used_sandwich'))
end)

DBFWCore.RegisterUsableItem('hamburger', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('hamburger', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 700000)
	TriggerClientEvent('dbfw_basicneeds:onEat', source)
	TriggerClientEvent('notification', source, _U('used_hamburger'))
end)

DBFWCore.RegisterUsableItem('shamburger', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('shamburger', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 700000)
	TriggerClientEvent('dbfw_basicneeds:onEat', source)
	TriggerClientEvent('notification', source, _U('used_hamburger'))
end)

DBFWCore.RegisterUsableItem('vhamburger', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('vhamburger', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 700000)
	TriggerClientEvent('dbfw_basicneeds:onEat', source)
	TriggerClientEvent('notification', source, _U('used_hamburger'))
end)

DBFWCore.RegisterUsableItem('fvburger', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('fvburger', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 700000)
	TriggerClientEvent('dbfw_basicneeds:onEat', source)
	TriggerClientEvent('notification', source, _U('used_hamburger'))
end)

DBFWCore.RegisterUsableItem('fburger', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('fburger', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 700000)
	TriggerClientEvent('dbfw_basicneeds:onEat', source)
	TriggerClientEvent('notification', source, _U('used_hamburger'))
end)

DBFWCore.RegisterUsableItem('cupcake', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('cupcake', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 100000)
	TriggerClientEvent('dbfw_status:add', source, 'thirst', -5000)
	TriggerClientEvent('dbfw_basicneeds:onEatCupCake', source)
	TriggerClientEvent('notification', source, _U('used_cupcake'))
end)

DBFWCore.RegisterUsableItem('chips', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('chips', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 150000)
	TriggerClientEvent('dbfw_basicneeds:onEatNoProp', source)
	TriggerClientEvent('notification', source, _U('used_chips'))
end)

DBFWCore.RegisterUsableItem('water', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('water', 1)

	TriggerClientEvent('dbfw_status:add', source, 'thirst', 500000)
	TriggerClientEvent('dbfw_basicneeds:onDrink', source)
	TriggerClientEvent('notification', source, _U('used_water'))
end)

DBFWCore.RegisterUsableItem('cocacola', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('cocacola', 1)

	TriggerClientEvent('dbfw_status:add', source, 'thirst', 200000)
	TriggerClientEvent('dbfw_basicneeds:onDrinkCocaCola', source)
	TriggerClientEvent('notification', source, _U('used_cocacola'))
end)

DBFWCore.RegisterUsableItem('soda', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('soda', 1)

	TriggerClientEvent('dbfw_status:add', source, 'thirst', 200000)
	TriggerClientEvent('dbfw_basicneeds:onDrinkCocaCola', source)
	TriggerClientEvent('notification', source, _U('used_soda'))
end)

DBFWCore.RegisterUsableItem('tchips', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('tchips', 1)

	TriggerClientEvent('dbfw_status:add', source, 'thirst', 200000)
	TriggerClientEvent('dbfw_basicneeds:onEatChips', source)
	TriggerClientEvent('notification', source, _U('used_tchips'))
end)

DBFWCore.RegisterUsableItem('cola', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('cola', 1)

	TriggerClientEvent('dbfw_status:add', source, 'thirst', 200000)
	TriggerClientEvent('dbfw_basicneeds:onDrinkCocaCola', source)
	TriggerClientEvent('notification', source, _U('used_cocacola'))
end)

DBFWCore.RegisterUsableItem('orangejuice', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('orangejuice', 1)

	TriggerClientEvent('dbfw_status:add', source, 'thirst', 200000)
	TriggerClientEvent('dbfw_basicneeds:onDrinkOrange', source)
	TriggerClientEvent('notification', source, _U('used_orangejuicea'))
end)

DBFWCore.RegisterUsableItem('icetea', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('icetea', 1)

	TriggerClientEvent('dbfw_status:add', source, 'thirst', 200000)
	TriggerClientEvent('dbfw_basicneeds:onDrinkIceTea', source)
	TriggerClientEvent('notification', source, _U('used_icetea'))
end)

DBFWCore.RegisterUsableItem('coffe', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('coffe', 1)

	TriggerClientEvent('dbfw_status:add', source, 'thirst', 150000)
	TriggerClientEvent('dbfw_status:add', source, 'hunger', 5000)
	TriggerClientEvent('dbfw_basicneeds:onDrinkCoffe', source)
	TriggerClientEvent('notification', source, _U('used_coffe'))
end)


DBFWCore.RegisterUsableItem('Coffee', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('Coffee', 1)

	TriggerClientEvent('dbfw_status:add', source, 'thirst', 150000)
	TriggerClientEvent('dbfw_status:add', source, 'hunger', 5000)
	TriggerClientEvent('dbfw_basicneeds:onDrinkCoffe', source)
	TriggerClientEvent('notification', source, _U('used_coffe'))
end)


-- Bar stuff
DBFWCore.RegisterUsableItem('wine', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('wine', 1)

	TriggerClientEvent('dbfw_status:add', source, 'drunk', 100000)
	TriggerClientEvent('dbfw_basicneeds:onDrinkWine', source)
	TriggerClientEvent('notification', source, _U('used_wine'))
end)

DBFWCore.RegisterUsableItem('beer', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('beer', 1)

	TriggerClientEvent('dbfw_status:add', source, 'drunk', 50000)
	TriggerClientEvent('dbfw_basicneeds:onDrinkBeer', source)
	TriggerClientEvent('notification', source, _U('used_beer'))
end)

DBFWCore.RegisterUsableItem('marlo', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('marlo', 1)

	TriggerClientEvent('dbfw_status:add', source, 'drunk', 80000)
	TriggerClientEvent('dbfw_basicneeds:onDrinkBeer', source)
end)

DBFWCore.RegisterUsableItem('vodka', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('vodka', 1)

	TriggerClientEvent('dbfw_status:add', source, 'drunk', 81000)
	TriggerClientEvent('dbfw_basicneeds:onDrinkVodka', source)
end)

DBFWCore.RegisterUsableItem('vodkaxred', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('vodkaxred', 1)

	TriggerClientEvent('dbfw_status:add', source, 'drunk', 85000)
	TriggerClientEvent('dbfw_basicneeds:onDrinkVodka', source)
end)

DBFWCore.RegisterUsableItem('viski', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('viski', 1)

	TriggerClientEvent('dbfw_status:add', source, 'drunk', 333333)
	TriggerClientEvent('dbfw_basicneeds:onDrinkWhisky', source)
	TriggerClientEvent('notification', source, _U('used_whisky'))
end)

DBFWCore.RegisterUsableItem('kaberna', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('kaberna', 1)

	TriggerClientEvent('dbfw_status:add', source, 'drunk', 333333)
	TriggerClientEvent('dbfw_basicneeds:onDrinkWhisky', source)
end)

DBFWCore.RegisterUsableItem('tequila', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('tequila', 1)

	TriggerClientEvent('dbfw_status:add', source, 'drunk', 230000)
	TriggerClientEvent('dbfw_basicneeds:onDrinkTequila', source)
	TriggerClientEvent('notification', source, _U('used_tequila'))
end)

DBFWCore.RegisterUsableItem('milk', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('milk', 1)

	TriggerClientEvent('dbfw_basicneeds:onDrinkMilk', source)
	TriggerClientEvent('notification', source, _U('used_milk'))
end)

-- Disco Stuff
DBFWCore.RegisterUsableItem('gintonic', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('gintonic', 1)

	TriggerClientEvent('dbfw_status:add', source, 'drunk', 200000)
	TriggerClientEvent('dbfw_basicneeds:onDrinkGin', source)
	TriggerClientEvent('notification', source, _U('used_gintonic'))
end)

DBFWCore.RegisterUsableItem('absinthe', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('absinthe', 1)

	TriggerClientEvent('dbfw_status:add', source, 'drunk', 350000)
	TriggerClientEvent('dbfw_basicneeds:onDrinkAbsinthe', source)
	TriggerClientEvent('notification', source, _U('used_absinthe'))
end)

DBFWCore.RegisterUsableItem('champagne', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('champagne', 1)

	TriggerClientEvent('dbfw_status:add', source, 'drunk', 75000)
	TriggerClientEvent('dbfw_basicneeds:onDrinkChampagne', source)
	TriggerClientEvent('notification', source, _U('used_champagne'))
end)

-- Cigarett
DBFWCore.RegisterUsableItem('cigarett', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)
	local lighter = xPlayer.getInventoryItem('lighter')
	
		if lighter.count > 0 then
			xPlayer.removeInventoryItem('cigarett', 1)
			TriggerClientEvent('dbfw_cigarett:startSmoke', source)
		else
			TriggerClientEvent('notification', source, 'You do not have a Lighter')
		end
end)

DBFWCore.RegisterUsableItem('nachos', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('nachos', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 350000)
	TriggerClientEvent('dbfw_basicneeds:onEatNoProp', source, 4000)
	TriggerClientEvent('notification', source, 'You ate 1x Nachos')
end)

DBFWCore.RegisterUsableItem('toast', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('toast', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 350000)
	TriggerClientEvent('dbfw_basicneeds:onEatNoProp', source, 7000)
	TriggerClientEvent('notification', source, 'You ate 1x Toast')
end)

DBFWCore.RegisterUsableItem('frenchtoast', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('frenchtoast', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 350000)
	TriggerClientEvent('dbfw_basicneeds:onEatNoProp', source, 7000)
	TriggerClientEvent('notification', source, 'You ate 1x French Toast')
end)

DBFWCore.RegisterUsableItem('spaghetti', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('spaghetti', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 350000)
	TriggerClientEvent('dbfw_basicneeds:onEatNoProp', source, 7500)
	TriggerClientEvent('notification', source, 'You ate 1x Spaghetti')
end)

DBFWCore.RegisterUsableItem('chickensandwich', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('chickensandwich', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 350000)
	TriggerClientEvent('dbfw_basicneeds:onEatNoProp', source, 7500)
	TriggerClientEvent('notification', source, 'You ate 1x Chicken Sandwich')
end)

DBFWCore.RegisterUsableItem('pizza', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('pizza', 1)

	TriggerClientEvent('dbfw_status:add', source, 'hunger', 350000)
	TriggerClientEvent('dbfw_basicneeds:onEatNoProp', source, 7500)
	TriggerClientEvent('notification', source, 'You ate 1x Pizza')
end)

