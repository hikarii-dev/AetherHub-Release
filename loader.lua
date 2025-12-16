-- Aether Hub v3.0
-- Simple premium system with trial key

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Configuration
local API_URL = "https://roblox-production-7b1c.up.railway.app" -- Твой Railway URL
local DISCORD_INVITE = "https://discord.gg/2fpWv8B9ch"
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()

-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Verify key with API
local function verifyKey(key)
    local success, response = pcall(function()
        local url = API_URL .. "/verify?key=" .. key .. "&hwid=" .. HWID
        local data = game:HttpGet(url)
        return HttpService:JSONDecode(data)
    end)
    
    if not success then
        warn("[Aether Hub] API Error:", response)
        return false, nil, nil
    end
    
    if response.valid then
        return true, response.expires, response.type
    end
    
    return false, response.reason, nil
end

-- Create expired screen
local function showExpiredScreen(Window)
    -- Destroy all existing tabs
    -- Note: Rayfield doesn't have a direct way to remove tabs,
    -- so we'll create a new window instead
    
    Rayfield:Destroy()
    
    local ExpiredWindow = Rayfield:CreateWindow({
        Name = "⏰ Aether Hub - Trial Expired",
        LoadingTitle = "Session Ended",
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
    
    local MainTab = ExpiredWindow:CreateTab("💎 Get Premium", nil)
    
    MainTab:CreateSection("Trial Expired")
    
    MainTab:CreateParagraph({
        Title = "⏰ Your trial has ended",
        Content = "Thank you for trying Aether Hub! To continue using our scripts, please purchase a premium key."
    })
    
    MainTab:CreateSection("Premium Pricing")
    
    MainTab:CreateLabel("💎 Monthly: $5")
    MainTab:CreateLabel("   ⏰ 30 days access")
    MainTab:CreateLabel("   ✅ All games included")
    
    MainTab:CreateLabel("")
    
    MainTab:CreateLabel("💎 3 Months: $10")
    MainTab:CreateLabel("   ⏰ 90 days access")
    MainTab:CreateLabel("   ✅ All games included")
    MainTab:CreateLabel("   🎁 Save $5!")
    
    MainTab:CreateSection("How to Purchase")
    
    MainTab:CreateButton({
        Name = "📋 Copy Discord Link",
        Callback = function()
            if setclipboard then
                setclipboard(DISCORD_INVITE)
                Rayfield:Notify({
                    Title = "✅ Copied!",
                    Content = "Discord link copied to clipboard",
                    Duration = 3
                })
            end
        end
    })
    
    MainTab:CreateButton({
        Name = "🌐 Open Discord",
        Callback = function()
            if setclipboard then
                setclipboard(DISCORD_INVITE)
            end
            -- Note: Can't directly open browser from Roblox
            Rayfield:Notify({
                Title = "Discord Link Copied",
                Content = "Paste in your browser to join!",
                Duration = 5
            })
        end
    })
    
    MainTab:CreateParagraph({
        Title = "📝 Purchase Steps",
        Content = "1. Join our Discord server\n2. Go to #purchase channel\n3. DM @hikarii.dev\n4. Send payment\n5. Receive your key instantly!"
    })
end

-- Background key checker (runs every 60 seconds)
local function startKeyChecker(currentKey, Window)
    -- Создаем глобальную переменную для игровых скриптов
    _G.AetherHubKeyValid = true
    _G.AetherHubCheckKey = function()
        local valid, expiresOrReason, keyType = verifyKey(currentKey)
        return valid
    end
    
    task.spawn(function()
        while task.wait(60) do
            local valid, expiresOrReason, keyType = verifyKey(currentKey)
            
            if not valid then
                warn("[Aether Hub] Key expired or invalid:", expiresOrReason)
                _G.AetherHubKeyValid = false -- Сообщаем игровому скрипту
                
                -- Закрываем Hub БЕЗ уведомлений
                pcall(function()
                    Rayfield:Destroy()
                end)
                
                -- Показываем уведомление через StarterGui
                task.wait(0.5)
                pcall(function()
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "⏰ Aether Hub",
                        Text = "Key expired! Get premium in Discord.",
                        Duration = 10
                    })
                end)
                
                break
            end
            
            -- Check if about to expire (< 5 minutes left) - ТОЛЬКО для premium ключей
            if keyType ~= "trial" and expiresOrReason then
                local timeLeft = expiresOrReason - os.time()
                if timeLeft < 300 and timeLeft > 0 then
                    pcall(function()
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "⏰ Key Expiring Soon",
                            Text = "Less than 5 minutes remaining!",
                            Duration = 10
                        })
                    end)
                end
            end
        end
    end)
end

-- Load game script
local function loadGame(gameScript, currentKey, Window)
    Rayfield:Notify({
        Title = "Loading Script",
        Content = "Please wait...",
        Duration = 2
    })
    
    task.wait(0.5)
    
    -- Start background key checker ПЕРЕД загрузкой скрипта
    startKeyChecker(currentKey, Window)
    
    -- Даем время установиться _G.AetherHubKeyValid
    task.wait(0.5)
    
    local success, err = pcall(function()
        local scriptCode = game:HttpGet(gameScript, true)
        loadstring(scriptCode)()
    end)
    
    if success then
        -- НЕ удаляем Hub! Просто скрываем его
        -- Rayfield:Destroy() -- УБРАЛИ ЭТУ СТРОКУ!
        
        -- Уведомление об успешной загрузке
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "✅ Script Loaded",
                Text = "Enjoy! Hub is hidden (press RightShift to toggle)",
                Duration = 5
            })
        end)
    else
        Rayfield:Notify({
            Title = "Error",
            Content = "Failed to load script: " .. tostring(err),
            Duration = 5
        })
    end
end

-- Main Hub Window
local Window = Rayfield:CreateWindow({
    Name = "🌟 Aether Hub v3.0",
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

-- Main Tab
local MainTab = Window:CreateTab("🏠 Main", nil)

MainTab:CreateSection("Welcome to Aether Hub!")

MainTab:CreateParagraph({
    Title = "🎁 Free Trial Available!",
    Content = "Try Aether Hub for 1 hour with the trial key!\nKey: AETH-TRIAL-2025\n(One-time use per PC)"
})

MainTab:CreateSection("Enter Your Key")

local keyInput = ""

MainTab:CreateInput({
    Name = "Key",
    PlaceholderText = "AETH-XXXX-XXXX",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        keyInput = Text
    end
})

MainTab:CreateButton({
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
        
        local valid, expiresOrReason, keyType = verifyKey(keyInput)
        
        if valid then
            local expiryText = ""
            if keyType == "trial" then
                expiryText = "1 hour"
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
            
            -- Show games tab
            task.wait(1)
            
            local GamesTab = Window:CreateTab("🎮 Games", nil)
            
            -- Rob the Brainrot Museum
            GamesTab:CreateSection("Rob the Brainrot Museum")
            
            GamesTab:CreateButton({
                Name = "🚀 Launch Script",
                Callback = function()
                    loadGame("https://raw.githubusercontent.com/hikarii-dev/AetherHub-Release/main/games/brainrot-museum.lua", keyInput, Window)
                end
            })
            
            -- Future games will be added here
            
        else
            local errorMsg = "Invalid key"
            if expiresOrReason == "expired" then
                errorMsg = "Key has expired"
            elseif expiresOrReason == "already_used" then
                errorMsg = "Trial already used on this PC"
            elseif expiresOrReason == "hwid_mismatch" then
                errorMsg = "Key is bound to another PC"
            elseif expiresOrReason == "not_found" then
                errorMsg = "Key not found"
            end
            
            Rayfield:Notify({
                Title = "❌ " .. errorMsg,
                Content = "Please check your key or get a new one",
                Duration = 4
            })
        end
    end
})

MainTab:CreateSection("Get a Key")

MainTab:CreateButton({
    Name = "📋 Copy Discord Link",
    Callback = function()
        if setclipboard then
            setclipboard(DISCORD_INVITE)
            Rayfield:Notify({
                Title = "✅ Copied!",
                Content = "Discord link copied! Paste in your browser.",
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title = "Discord Server",
                Content = "Join: " .. DISCORD_INVITE,
                Duration = 5
            })
        end
    end
})

-- Info Tab
local InfoTab = Window:CreateTab("ℹ️ Info", nil)

InfoTab:CreateSection("Pricing")

InfoTab:CreateLabel("🎁 Trial: FREE (1 hour)")
InfoTab:CreateLabel("   Key: AETH-TRIAL-2025")
InfoTab:CreateLabel("   One-time use per PC")

InfoTab:CreateLabel("")

InfoTab:CreateLabel("💎 Monthly: $5")
InfoTab:CreateLabel("   30 days access")

InfoTab:CreateLabel("")

InfoTab:CreateLabel("💎 3 Months: $10")
InfoTab:CreateLabel("   90 days access")
InfoTab:CreateLabel("   Save $5!")

InfoTab:CreateSection("Supported Games")

InfoTab:CreateLabel("✅ Rob the Brainrot Museum")
InfoTab:CreateLabel("🔜 More games coming soon!")

InfoTab:CreateSection("Support")

InfoTab:CreateLabel("Discord: " .. DISCORD_INVITE)
InfoTab:CreateLabel("Contact: @hikarii.dev")
