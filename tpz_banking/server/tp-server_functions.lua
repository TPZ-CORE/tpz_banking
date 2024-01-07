
function sendToDiscord(title, name, description, location)
    local logs = ""

    local webhook, avatar = Config.DiscordWebhooking.Webhook, Config.DiscordWebhooking.Avatar
    local color, title = 3447003, title

    logs = {
      {
        ["color"] = color,
        ["title"] = title,
        ["description"] = description,
        ["footer"] = { ["text"] = location }
      }
    }

    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST',
      json.encode({ ["username"] = name, ["avatar_url"] = avatar, embeds = logs }),
      { ['Content-Type'] = 'application/json' 
    })
    
end
  