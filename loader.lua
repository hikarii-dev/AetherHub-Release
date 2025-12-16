-- Aether Hub v5.0 - Shared Key System
-- One key for everyone via Discord

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Configuration
local API_URL = "https://roblox-production-7b1c.up.railway.app"
local DISCORD_INVITE = "https://discord.gg/cnEXsPDKuU"
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()

-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Verify key with API
local function verifyKey(key, gameId)
    local success, response = pcall(function()
        local url = API_URL .. "/verify?key=" .. key .. "&hwid=" .. HWID .. "&game=" .. gameId
        local data = game:HttpGet(url)
        return HttpService:JSONDecode(data)
    end)
    
    if not success then
        warn("[Aether Hub] API Error:", response)
        return false, "Connection failed"
    end
    
    return response.valid, response.reason or response.message
end

-- Main Hub Window
local Window = Rayfield:CreateWindow({
    Name = "🌟 Aether Hub v5.0",
    LoadingTitle = "Aether Hub",
    LoadingSubtitle = "by hikarii.dev",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = true,
        Invite = DISCORD_INVITE,
        RememberJoins = false
    },
    KeySystem = false
})

-- Game configuration
local GAMES = {
    {
        id = "brainrot-museum",
        name = "Rob the Brainrot Museum",
        icon = "🏛️",
        script_url = "https://raw.githubusercontent.com/hikarii-dev/AetherHub-Release/main/games/brainrot-museum.lua"
    }
}

-- Create tab for each game
for _, game in ipairs(GAMES) do
    local gameTab = Window:CreateTab(game.icon .. " " .. game.name, nil)
    
    gameTab:CreateSection("Enter Key")
    
    local keyInput = ""
    local activateButton = nil
    
    gameTab:CreateInput({
        Name = "Key",
        PlaceholderText = "AETH-SHARED-XXXX",
        RemoveTextAfterFocusLost = false,
        Callback = function(Text)
            keyInput = Text
        end
    })
    
    gameTab:CreateButton({
        Name = "✅ Verify Key",
        Callback = function()
            if keyInput == "" then
                Rayfield:Notify({
                    Title = "Error",
                    Content = "Enter a key first",
                    Duration = 2
                })
                return
            end
            
            Rayfield:Notify({
                Title = "Verifying...",
                Content = "Please wait...",
                Duration = 2
            })
            
            local valid, reason = verifyKey(keyInput, game.id)
            
            if valid then
                Rayfield:Notify({
                    Title = "✅ Valid!",
                    Content = "Key verified successfully",
                    Duration = 3
                })
                
                -- Show Activate button
                task.wait(0.5)
                if not activateButton then
                    activateButton = gameTab:CreateButton({
                        Name = "🚀 Activate Script",
                        Callback = function()
                            -- Start key checker (every 10 seconds)
                            _G.AetherHubKeyValid = true
                            _G.AetherHubCurrentKey = keyInput
                            
                            task.spawn(function()
                                while task.wait(10) do  -- Check every 10 sec
                                    local valid, _ = verifyKey(_G.AetherHubCurrentKey, game.id)
                                    if not valid then
                                        _G.AetherHubKeyValid = false
                                        
                                        -- Show notification
                                        pcall(function()
                                            game:GetService("StarterGui"):SetCore("SendNotification", {
                                                Title = "⏰ Key Expired",
                                                Text = "Key changed! Get new one from Discord.",
                                                Duration = 10
                                            })
                                        end)
                                        
                                        -- Close script and reopen hub
                                        task.wait(1)
                                        loadstring(game:HttpGet("https://raw.githubusercontent.com/hikarii-dev/AetherHub-Release/main/loader.lua"))()
                                        
                                        break
                                    end
                                end
                            end)
                            
                            -- Load game script
                            Rayfield:Notify({
                                Title = "Loading...",
                                Content = "Please wait...",
                                Duration = 2
                            })
                            
                            task.wait(0.5)
                            
                            local success, err = pcall(function()
                                local code = game:HttpGet(game.script_url, true)
                                loadstring(code)()
                            end)
                            
                            if success then
                                Rayfield:Notify({
                                    Title = "✅ Loaded!",
                                    Content = "Enjoy!",
                                    Duration = 3
                                })
                            else
                                warn("[Aether Hub] Load error:", err)
                                Rayfield:Notify({
                                    Title = "❌ Error",
                                    Content = "Failed to load. Check F9",
                                    Duration = 5
                                })
                            end
                        end
                    })
                end
                
            else
                local errorMsg = "Invalid key"
                if reason == "not_found" then
                    errorMsg = "Key not found. Get from Discord!"
                elseif reason then
                    errorMsg = reason
                end
                
                Rayfield:Notify({
                    Title = "❌ " .. errorMsg,
                    Content = "Check your key",
                    Duration = 4
                })
            end
        end
    })
    
    gameTab:CreateSection("Get Key")
    
    gameTab:CreateButton({
        Name = "🎁 Get Key (Discord)",
        Callback = function()
            if setclipboard then
                setclipboard(DISCORD_INVITE)
                Rayfield:Notify({
                    Title = "✅ Copied!",
                    Content = "Join Discord → #get-key channel",
                    Duration = 5
                })
            else
                Rayfield:Notify({
                    Title = "Join Discord",
                    Content = DISCORD_INVITE,
                    Duration = 5
                })
            end
        end
    })
    
    gameTab:CreateButton({
        Name = "💎 Get Premium",
        Callback = function()
            if setclipboard then
                setclipboard(DISCORD_INVITE)
                Rayfield:Notify({
                    Title = "💎 Premium",
                    Content = "$5/mo, $10/3mo - No Linkvertise!",
                    Duration = 5
                })
            end
        end
    })
end

-- Info Tab
local InfoTab = Window:CreateTab("ℹ️ Info", nil)

InfoTab:CreateSection("How to Get Key")

InfoTab:CreateLabel("1️⃣ Click 'Get Key (Discord)'")
InfoTab:CreateLabel("2️⃣ Join Discord server")
InfoTab:CreateLabel("3️⃣ Go to #get-key channel")
InfoTab:CreateLabel("4️⃣ Click Linkvertise link")
InfoTab:CreateLabel("5️⃣ Complete checkpoint")
InfoTab:CreateLabel("6️⃣ Copy key from text")
InfoTab:CreateLabel("7️⃣ Paste here & verify")

InfoTab:CreateSection("About Keys")

InfoTab:CreateLabel("🎁 Trial: FREE")
InfoTab:CreateLabel("   Shared key (updates every 3h)")
InfoTab:CreateLabel("   Via Linkvertise")

InfoTab:CreateLabel("")

InfoTab:CreateLabel("💎 Premium: $5-10")
InfoTab:CreateLabel("   Personal key (no Linkvertise!)")
InfoTab:CreateLabel("   30 or 90 days")
InfoTab:CreateLabel("   All games included")

InfoTab:CreateSection("Supported Games")

InfoTab:CreateLabel("✅ Rob the Brainrot Museum")
InfoTab:CreateLabel("🔜 More coming soon!")

InfoTab:CreateSection("Support")

InfoTab:CreateLabel("Discord: " .. DISCORD_INVITE)
InfoTab:CreateLabel("Contact: @hikarii.dev")
