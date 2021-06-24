


RegisterServerEvent("mech:check:materials")
AddEventHandler("mech:check:materials", function()
    local src = source
    exports.ghmattimysql:execute("SELECT * FROM mech_materials",{}, function(result)
        if result ~= nil then
            print(result[1]['Aluminum'])
            local strng = "\n Aluminum - " .. result[1]["Aluminum"] .. " \n Rubber - " .. result[1]["Rubber"] .. " \n Scrap - " .. result[1]["Scrap"] .. " \n Plastic - " .. result[1]["Plastic"] .. " \n Copper - " .. result[1]["Copper"] .. " \n Steel - " .. result[1]["Steel"] .. " \n Glass - " .. result[1]["Glass"]
            --TriggerClientEvent("DoLongHudText",src,strng)
            TriggerClientEvent("customNotification",src, strng)
            --TriggerClientEvent('chat:addMessage', src, { template = '<div class="chat-message jail"><b>'..strng..'</div>')
			--TriggerClientEvent("chatMessagess",-1, "OOC "..name..":  ", 2, strng)
        end
    end)

end)

RegisterServerEvent("mech:add:materials")
AddEventHandler("mech:add:materials", function(materials,amount)
    local src = source
    local addMaterials = 0
    TriggerClientEvent('inventory:removeItem',src,string.lower(materials), amount)
    exports.ghmattimysql:execute("SELECT * FROM mech_materials",{}, function(result)
        local set = ""
        local values = {}
        if materials == "Aluminum" or materials == "aluminum" then
             addMaterials = result[1]['Aluminum'] + amount
             set = "Aluminum = @Aluminum"
             values = {['Aluminum'] = addMaterials}
        elseif materials == "Rubber" or materials == "rubber" then
            addMaterials = result[1]['Rubber'] + amount
            set = "Rubber = @Rubber"
            values = {['Rubber'] = addMaterials}
        elseif materials == "Scrap" or materials == "scrap" then
            addMaterials = result[1]['Scrap'] + amount
            set = "Scrap = @Scrap"
            values = {['Scrap'] = addMaterials}
        elseif materials == "Plastic" or materials == "plastic" then
            addMaterials = result[1]['Plastic'] + amount
            set = "Plastic = @Plastic"
            values = {['Plastic'] = addMaterials}
        elseif materials == "Copper" or materials == "copper" then
            addMaterials = result[1]['Copper'] + amount
            set = "Copper = @Copper"
            values = {['Copper'] = addMaterials}
        elseif materials == "Steel" or materials == "steel" then
            addMaterials = result[1]['Steel'] + amount
            set = "Steel = @Steel"
            values = {['Steel'] = addMaterials}
        elseif materials == "Glass" or materials == "glass" then
            addMaterials = result[1]['Glass'] + amount
            set = "Glass = @Glass"
            values = {['Glass'] = addMaterials}
        end
        print('Adding materials', firstToUpper(materials),addMaterials, set)
        AddMaterials(firstToUpper(materials),addMaterials,set,values)

    --     local set = "model = @model,drawables = @drawables,props = @props,drawtextures = @drawtextures,proptextures = @proptextures"
    --     MySQL.Async.execute("UPDATE character_current SET "..set.." WHERE identifier = @identifier", values)
    -- exports.ghmattimysql:execute("UPDATE mech_materials SET ()")


    end)
    
end)

RegisterServerEvent("mech:remove:materials")
AddEventHandler("mech:remove:materials", function(materials,amount)
    local src = source
    local addMaterials = 0
    if amount == nil then
        TriggerClient('DoShotHudText',src, 'Are you crazy?', 2) 
        return
    end
    exports.ghmattimysql:execute("SELECT * FROM mech_materials",{}, function(result)
        local set = ""
        local values = {}
        if materials == "Aluminum" or materials == "aluminum" then
             addMaterials = result[1]['Aluminum'] - amount
             set = "Aluminum = @Aluminum"
             values = {['Aluminum'] = addMaterials}
        elseif materials == "Rubber" or materials == "rubber" then
            addMaterials = result[1]['Rubber'] - amount
            set = "Rubber = @Rubber"
            values = {['Rubber'] = addMaterials}
        elseif materials == "Scrap" or materials == "scrap" then
            addMaterials = result[1]['Scrap'] - amount
            set = "Scrap = @Scrap"
            values = {['Scrap'] = addMaterials}
        elseif materials == "Plastic" or materials == "plastic" then
            addMaterials = result[1]['Plastic'] - amount
            set = "Plastic = @Plastic"
            values = {['Plastic'] = addMaterials}
        elseif materials == "Copper" or materials == "copper" then
            addMaterials = result[1]['Copper'] - amount
            set = "Copper = @Copper"
            values = {['Copper'] = addMaterials}
        elseif materials == "Steel" or materials == "steel" then
            addMaterials = result[1]['Steel'] - amount
            set = "Steel = @Steel"
            values = {['Steel'] = addMaterials}
        elseif materials == "Glass" or materials == "glass" then
            addMaterials = result[1]['Glass'] - amount
            set = "Glass = @Glass"
            values = {['Glass'] = addMaterials}
        end
        print('Adding materials', firstToUpper(materials),addMaterials, set)
        AddMaterials(firstToUpper(materials),addMaterials,set,values)

    --     local set = "model = @model,drawables = @drawables,props = @props,drawtextures = @drawtextures,proptextures = @proptextures"
    --     MySQL.Async.execute("UPDATE character_current SET "..set.." WHERE identifier = @identifier", values)
    -- exports.ghmattimysql:execute("UPDATE mech_materials SET ()")


    end)
    
end)

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function AddMaterials(materials,amount,set,values)
    print("my materials to add ",materials,amount,set,values)
    -- local set = "model = @model,drawables = @drawables,props = @props,drawtextures = @drawtextures,proptextures = @proptextures"
    --     MySQL.Async.execute("UPDATE character_current SET "..set.." WHERE identifier = @identifier", values)
     exports.ghmattimysql:execute("UPDATE mech_materials SET "..set.."", values)
end