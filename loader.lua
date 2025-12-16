-- Aether Hub v4.1
-- Token-based system - Keys ONLY after Linkvertise

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Configuration
local API_URL = "https://roblox-production-7b1c.up.railway.app"
local DISCORD_INVITE = "https://discord.gg/cnEXsPDKuU"
local LINKVERTISE_URL = "https://link-hub.net/2492639/F5hLLRGhoqWt"
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()

-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Verify key with API
local function verifyKey(key, gameId)
    local success, response = pcall(function()
        local url = API_URL .. "/verify?key=" .. key .. "&hwid=" .. HWID .. "&game=" .. gameId
        print("[Aether Hub] Verifying:", url)
        
        local data = game:HttpGet(url)
        print("[Aether Hub] Response:", data)
        
        return HttpService:JSONDecode(data)
    end)
    
    if not success then
        warn("[Aether Hub] Verify API Error:", response)
        return false, nil, "Connection failed. Check Railway!"
    end
    
    if response.valid then
        return true, response.expires, response.type
    end
    
    return false, response.reason, response.message
end

-- Create token (NOT key!)
local function createToken(gameId)
    local success, response = pcall(function()
        local url = API_URL .. "/create-token?game=" .. gameId
        print("[Aether Hub] Creating token for:", gameId)
        
        local data = game:HttpGet(url)
        print("[Aether Hub] Response:", data)
        
        return HttpService:JSONDecode(data)
    end)
    
    if not success then
        warn("[Aether Hub] Token API Error:", response)
        return false, "Connection failed. Check Railway!"
    end
    
    if response.success then
        return true, response.token
    end
    
    return false, response.message or response.reason or "Unknown error"
end

-- Main Hub Window
local Window = Rayfield:CreateWindow({
    Name = "🌟 Aether Hub v4.1",
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
    -- Добавляй новые игры здесь
}

-- Create tab for each game
for _, game in ipairs(GAMES) do
    local gameTab = Window:CreateTab(game.icon .. " " .. game.name, nil)
    
    gameTab:CreateSection("Enter Your Key")
    
    local keyInput = ""
    local keyVerified = false
    local activateButton = nil
    
    gameTab:CreateInput({
        Name = "Key",
        PlaceholderText = "AETH-TRIAL-XXXXXXXX",
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
                    Content = "Please enter a key first",
                    Duration = 2
                })
                return
            end
            
            Rayfield:Notify({
                Title = "Verifying...",
                Content = "Checking key validity...",
                Duration = 2
            })
            
            local valid, expiresOrReason, keyTypeOrMessage = verifyKey(keyInput, game.id)
            
            if valid then
                keyVerified = true
                
                local expiryText = ""
                if keyTypeOrMessage == "trial" then
                    local timeLeft = expiresOrReason - os.time()
                    local hoursLeft = math.floor(timeLeft / 3600)
                    local minsLeft = math.floor((timeLeft % 3600) / 60)
                    expiryText = hoursLeft .. "h " .. minsLeft .. "m"
                elseif expiresOrReason then
                    local timeLeft = expiresOrReason - os.time()
                    local daysLeft = math.floor(timeLeft / 86400)
                    expiryText = daysLeft .. " days"
                end
                
                Rayfield:Notify({
                    Title = "✅ Key Valid!",
                    Content = "Time left: " .. expiryText,
                    Duration = 3
                })
                
                -- Показываем кнопку Activate Script
                task.wait(0.5)
                if not activateButton then
                    activateButton = gameTab:CreateButton({
                        Name = "🚀 Activate Script",
                        Callback = function()
                            -- Start background key checker
                            _G.AetherHubKeyValid = true
                            
                            task.spawn(function()
                                while task.wait(60) do
                                    local valid, _, _ = verifyKey(keyInput, game.id)
                                    if not valid then
                                        _G.AetherHubKeyValid = false
                                        
                                        pcall(function()
                                            game:GetService("StarterGui"):SetCore("SendNotification", {
                                                Title = "⏰ Aether Hub",
                                                Text = "Key expired! Get a new one.",
                                                Duration = 10
                                            })
                                        end)
                                        
                                        break
                                    end
                                end
                            end)
                            
                            -- Load game script
                            Rayfield:Notify({
                                Title = "Loading Script",
                                Content = "Please wait...",
                                Duration = 2
                            })
                            
                            task.wait(0.5)
                            
                            print("[Aether Hub] Loading script from:", game.script_url)
                            
                            local success, err = pcall(function()
                                local scriptCode = game:HttpGet(game.script_url, true)
                                
                                if not scriptCode or scriptCode == "" then
                                    error("Empty script response")
                                end
                                
                                print("[Aether Hub] Script loaded, size:", #scriptCode, "bytes")
                                
                                local loadFunc, loadErr = loadstring(scriptCode)
                                if not loadFunc then
                                    error("Loadstring failed: " .. tostring(loadErr))
                                end
                                
                                loadFunc()
                            end)
                            
                            if success then
                                Rayfield:Notify({
                                    Title = "✅ Script Loaded",
                                    Content = "Enjoy!",
                                    Duration = 3
                                })
                            else
                                warn("[Aether Hub] Script load error:", err)
                                Rayfield:Notify({
                                    Title = "❌ Load Error",
                                    Content = "Check Output (F9) for details",
                                    Duration = 5
                                })
                            end
                        end
                    })
                end
                
            else
                local errorMsg = "Invalid key"
                
                if expiresOrReason == "expired" then
                    errorMsg = "Key has expired"
                elseif expiresOrReason == "hwid_mismatch" then
                    errorMsg = "Key is bound to another PC"
                elseif expiresOrReason == "already_used_in_other_game" then
                    errorMsg = keyTypeOrMessage or "Key used in another game"
                elseif expiresOrReason == "not_found" then
                    errorMsg = "Key not found. Did you complete Linkvertise?"
                elseif expiresOrReason == "claim_expired" then
                    errorMsg = "Key expired (10 min after claim). Get new one."
                elseif keyTypeOrMessage then
                    errorMsg = keyTypeOrMessage
                end
                
                Rayfield:Notify({
                    Title = "❌ " .. errorMsg,
                    Content = "Check your key or get a new one",
                    Duration = 4
                })
            end
        end
    })
    
    gameTab:CreateSection("Get a Key")
    
    gameTab:CreateButton({
        Name = "🎁 Get Trial Key (FREE)",
        Callback = function()
            Rayfield:Notify({
                Title = "Creating Token...",
                Content = "Please wait...",
                Duration = 2
            })
            
            -- Создаем токен (НЕ ключ!)
            local success, tokenOrMessage = createToken(game.id)
            
            if success then
                -- Формируем Linkvertise URL с ТОКЕНОМ
                local fullUrl = LINKVERTISE_URL .. "?token=" .. tokenOrMessage
                
                if setclipboard then
                    setclipboard(fullUrl)
                    Rayfield:Notify({
                        Title = "✅ Link Copied!",
                        Content = "Paste in browser → Complete checkpoint → Get key!",
                        Duration = 6
                    })
                else
                    Rayfield:Notify({
                        Title = "⚠️ Can't Copy",
                        Content = "Open: " .. LINKVERTISE_URL .. " (Token in console F9)",
                        Duration = 6
                    })
                    print("[Aether Hub] Your token:", tokenOrMessage)
                    print("[Aether Hub] Full URL:", fullUrl)
                end
            else
                if tokenOrMessage:find("exhausted") then
                    Rayfield:Notify({
                        Title = "❌ No Keys Left",
                        Content = "Join Discord for premium keys!",
                        Duration = 5
                    })
                else
                    Rayfield:Notify({
                        Title = "Error",
                        Content = tokenOrMessage,
                        Duration = 3
                    })
                end
            end
        end
    })
    
    gameTab:CreateButton({
        Name = "💎 Get Premium Key",
        Callback = function()
            if setclipboard then
                setclipboard(DISCORD_INVITE)
                Rayfield:Notify({
                    Title = "💎 Premium Keys",
                    Content = "Join Discord: $5/month, $10/3months",
                    Duration = 5
                })
            end
        end
    })
    
    gameTab:CreateSection("Support")
    
    gameTab:CreateButton({
        Name = "📋 Copy Discord Link",
        Callback = function()
            if setclipboard then
                setclipboard(DISCORD_INVITE)
                Rayfield:Notify({
                    Title = "✅ Copied!",
                    Content = "Discord link copied",
                    Duration = 3
                })
            end
        end
    })
end

-- Info Tab
local InfoTab = Window:CreateTab("ℹ️ Info", nil)

InfoTab:CreateSection("How to Get Trial Key")

InfoTab:CreateLabel("1️⃣ Click 'Get Trial Key (FREE)'")
InfoTab:CreateLabel("2️⃣ Linkvertise link copied")
InfoTab:CreateLabel("3️⃣ Paste in browser")
InfoTab:CreateLabel("4️⃣ Complete checkpoint")
InfoTab:CreateLabel("5️⃣ Get your key!")
InfoTab:CreateLabel("6️⃣ Paste key here & verify")

InfoTab:CreateSection("Pricing")

InfoTab:CreateLabel("🎁 Trial: FREE (3 hours)")
InfoTab:CreateLabel("   Via Linkvertise checkpoint")
InfoTab:CreateLabel("   One key per game")

InfoTab:CreateLabel("")

InfoTab:CreateLabel("💎 Monthly: $5")
InfoTab:CreateLabel("   30 days access")
InfoTab:CreateLabel("   All games included")

InfoTab:CreateLabel("")

InfoTab:CreateLabel("💎 3 Months: $10")
InfoTab:CreateLabel("   90 days access")
InfoTab:CreateLabel("   All games included")

InfoTab:CreateSection("Supported Games")

InfoTab:CreateLabel("✅ Rob the Brainrot Museum")
InfoTab:CreateLabel("🔜 More games coming soon!")

InfoTab:CreateSection("Support")

InfoTab:CreateLabel("Discord: " .. DISCORD_INVITE)
InfoTab:CreateLabel("Contact: @hikarii.dev")
