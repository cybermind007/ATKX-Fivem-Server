callbackData = nil
RegisterNetEvent('dbfw-uimenu:createMenu')
AddEventHandler('dbfw-uimenu:createMenu', function(myMenu, cb)
    callbackData = nil
    SendNUIMessage({
        action = "show",
        menu = myMenu
    })
    SetNuiFocus(true, true)
    while callbackData == nil do Wait(500); end
    cb(callbackData)
end)

RegisterNUICallback("closeUI", function(data) -- when the ESC button is pressed within the menu, we send a value of false back to the callback.
    SetNuiFocus(false, false)
    local value = (data.value and string.sub(data.value, 1, 1) == "{" and json.decode(data.value)) or data.value
    callbackData = value
end)

RegisterNUICallback("selectedValue", function(data) -- The event used for final selection. This closes the menu and returns the values
    SetNuiFocus(false, false)
    local value = (data.value and string.sub(data.value, 1, 1) == "{" and json.decode(data.value)) or data.value
    callbackData = value
end)

RegisterNUICallback("hoveredValue", function(data) -- The hover event used for triggering both a hover event, and a checklist check event
    local value = (data.value and string.sub(data.value, 1, 1) == "{" and json.decode(data.value)) or data.value
    TriggerEvent(data.event, value)
end)



--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

-- The following is an example of how to use the above in a resource that needs a menu
--local myListMenu = {
--    menutype = "list",
--    menulabel = "Testing", 
--    showBack = true,
--    menu = {
--            {label = 'South Rockford Drive', value = 'apartment1'},
--            {label = 'Morningwood Blvd', value = 'apartment2'},
--            {label = 'Integrity Way', value = 'apartment3'},
--            {label = 'Tinsel Towers', value = 'apartment4'},
--            {label = 'Fantastic Plaza', value = 'apartment5'},
--        {submenuLabel = "Submenu", submenu = {
--            {icon = "fas fa-door-open", label = "Option 11", value = {myObject = "object Testing", canSendAnObject = true}}, 
--           {icon = "fas fa-door-open", label = "Option 12", value ="option12"}, -- if you wish to prepend your selection names with an icon, you can. Just add the icon name like so from fontawesome
--            {icon = "fas fa-door-open", label = "Option 13", value ="option13"},
--            {icon = "fas fa-door-open", label = "Option 14", value ="option14"},
--            {icon = "fas fa-door-open", label = "Option 15", value ="option15"},
--        }},
--      {label = "Option 6", value ="option6"},
--        {label = "Option 7", value ="option7"},
--        {label = "Option 8", value ="option8"},
--    }
--}

--local myMultiMenu = {
--    menutype = "multiselect",
--    menulabel = "Testing",
--    event = "myevent:hover", -- the event name you wish this menu to trigger when clicking an item
--    showBack = true,
--    menu = {
--        {label = "Option 1", value ="option1", hasitem = true}, -- When creating the menu, marking hasitem to true prepends a green checkmark to the list item. hasitem marked false prepends a red X
--        {label = "Option 2", value ="option2", hasitem = true},
--        {label = "Option 3", value ="option3", hasitem = false},
--        {label = "Option 4", value ="option4", hasitem = false},
--        {label = "Option 6", value ="option6", hasitem = false},
--        {label = "Option 7", value ="option7", hasitem = true},
--        {label = "Option 8", value ="option8", hasitem = false},
--    }
--}

--local myHoverMenu = {
--    menutype = "hover",
--    menulabel = "Apartments",
--    event = "myevent:hover", -- the event name you wish to trigger when hovering over an item in the list
--    showBack = true,
--    menu = {
--            {label = 'South Rockford Drive', value = 'apartment1'},
--            {label = 'Morningwood Blvd', value = 'apartment2'},
--            {label = 'Integrity Way', value = 'apartment3'},
--            {label = 'Tinsel Towers', value = 'apartment4'},
--            {label = 'Fantastic Plaza', value = 'apartment5'},
--    }
--}


--RegisterCommand("listmenutest", function()
--    TriggerEvent("dbfw-uimenu:createMenu", myListMenu, function(value)
--        print(value) -- this value will be the value "selected" when using the "list" menu type. If the value stored above in the mneu creation was an object, it will be an json decoded object here. If it was just a string, just a string will be returned. 
--    end)
--end)

--RegisterCommand("multimenutest", function()
--    TriggerEvent("dbfw-uimenu:createMenu", myMultiMenu, function(value)
--        print(value) -- this value will return false no matter what, this just returns the callback of closing the menu. The value you need is within the event
--    end)
--end)

--RegisterCommand("hovermenutest", function()
--    TriggerEvent("dbfw-uimenu:createMenu", myHoverMenu, function(value)
--        print(value) -- this is the value selected from within the hover menu.
--    end)
--end)

--RegisterNetEvent('myevent:hover')
--AddEventHandler('myevent:hover', function(value) -- testing name of a event called on either "hover", or on "check" of a checklist menu. Value is sent to create functionality of the item that was selected
    --print(value)
--end)
