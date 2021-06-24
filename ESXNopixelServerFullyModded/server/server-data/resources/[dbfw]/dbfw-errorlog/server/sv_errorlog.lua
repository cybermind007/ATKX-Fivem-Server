RegisterServerEvent('LogClientError')
AddEventHandler('LogClientError', function(resource, error)
    local log = {
        {
            ["color"] = "9312783",
            ["title"] = "Error Log (" .. resource .. ") By " .. GetPlayerName(source),
            ["description"] = error,
        }
    }

    print("------------------ CLIENT ERROR IN RESOURCE: " .. resource.. '   By: '.. GetPlayerName(source))
    print(error)
    print("------------------ END OF CLIENT ERROR")

    PerformHttpRequest("https://discord.com/api/webhooks/763553104326426644/LHt8T65ZzYFmNnZGNTwssZLHmtR0GEsBdPEtvxN8YJdc3gwH1KAwHlSZ-i37sdZAhPnd", function(err, text, headers) end, 'POST', json.encode({username = "Error Logs", embeds = log}), { ['Content-Type'] = 'application/json' })
end)