--[[
    Aether Hub v1.0.0
    Created by hikarii.dev
    https://discord.gg/2fpWv8B9ch
]]

local AetherHub = {}

-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- Config
local CONFIG_URL = "https://raw.githubusercontent.com/hikarii-dev/AetherHub-Release/main/config.json"
local DISCORD_INVITE = "https://discord.gg/2fpWv8B9ch"

-- Local Player
local LocalPlayer = Players.LocalPlayer
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()

-- Folders
local FOLDER_NAME = "AetherHub"
if not isfolder(FOLDER_NAME) then
    makefolder(FOLDER_NAME)
end

-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Load Config
local function loadConfig()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(CONFIG_URL))
    end)
    
    if success then
        return result
    else
        warn("[Aether Hub] Failed to load config:", result)
        return nil
    end
end

-- Check if key file exists and is valid
local function checkSavedKey(gameId)
    local keyFile = FOLDER_NAME .. "/" .. gameId .. "_key.json"
    
    if isfile(keyFile) then
        local success, keyData = pcall(function()
            return HttpService:JSONDecode(readfile(keyFile))
        end)
        
        if success and keyData then
            -- Check if key is expired
            if keyData.expires == "never" or (keyData.expires and os.time() < keyData.expires) then
                -- Check HWID match
                if keyData.hwid == HWID then
                    return true, keyData
                end
            end
        end
    end
    
    return false, nil
end

-- Save key to file
local function saveKey(gameId, key, expires)
    local keyData = {
        key = key,
        game = gameId,
        expires = expires,
        hwid = HWID,
        saved_at = os.time()
    }
    
    local keyFile = FOLDER_NAME .. "/" .. gameId .. "_key.json"
    writefile(keyFile, HttpService:JSONEncode(keyData))
end

-- Verify key with GitHub-hosted database
local function verifyKey(key, gameId)
    local success, response = pcall(function()
        local keysUrl = "https://raw.githubusercontent.com/hikarii-dev/AetherHub-Release/main/api/keys.json"
        local data = game:HttpGet(keysUrl)
        return HttpService:JSONDecode(data)
    end)
    
    if not success then
        warn("[Aether Hub] Failed to fetch keys database:", response)
        return false, nil
    end
    
    -- Check if key exists
    if response.keys[key] then
        local keyData = response.keys[key]
        
        -- Check if key is active
        if keyData.status ~= "active" then
            return false, nil
        end
        
        -- Check if expired
        if keyData.expires then
            if os.time() > keyData.expires then
                return false, nil -- Expired
            end
        end
        
        -- Check HWID if set
        if keyData.hwid and keyData.hwid ~= HWID then
            return false, nil -- Key bound to different PC
        end
        
        -- Valid key!
        return true, keyData.expires or "never"
    end
    
    return false, nil
end

-- Load game script
local function loadGame(game)
    Rayfield:Notify({
        Title = "Loading Game",
        Content = "Loading " .. game.name .. "...",
        Duration = 2,
    })
    
    task.wait(0.5)
    
    local success, err = pcall(function()
        loadstring(game:HttpGet(game.script))()
    end)
    
    if success then
        Rayfield:Destroy()
    else
        Rayfield:Notify({
            Title = "Error",
            Content = "Failed to load game: " .. tostring(err),
            Duration = 5,
        })
    end
end

-- Main Hub UI
local function createHub(config)
    local Window = Rayfield:CreateWindow({
        Name = config.hub.name .. " v" .. config.hub.version,
        LoadingTitle = "Loading Aether Hub...",
        LoadingSubtitle = "by " .. config.hub.author,
        ConfigurationSaving = {
            Enabled = false
        },
        Discord = {
            Enabled = true,
            Invite = config.hub.discord,
            RememberJoins = true
        }
    })
    
    -- Games Tab
    local GamesTab = Window:CreateTab("🎮 Games", nil)
    
    for _, game in ipairs(config.games) do
        local section = GamesTab:CreateSection(game.name)
        
        -- Check if player is in the correct game
        local isCorrectGame = game.placeId == game.PlaceId
        
        -- Check for saved key
        local hasSavedKey, savedKeyData = checkSavedKey(game.id)
        
        local statusText = "Status: "
        if hasSavedKey then
            if savedKeyData.expires == "never" then
                statusText = statusText .. "✅ Premium Active"
            else
                local timeLeft = savedKeyData.expires - os.time()
                local hours = math.floor(timeLeft / 3600)
                statusText = statusText .. "✅ Active (" .. hours .. "h left)"
            end
        else
            statusText = statusText .. "🔒 Key Required"
        end
        
        GamesTab:CreateLabel(statusText)
        
        -- Get Key Button
        if not hasSavedKey then
            GamesTab:CreateButton({
                Name = "🔑 Get Key",
                Callback = function()
                    Rayfield:Notify({
                        Title = "Get Key",
                        Content = "Join our Discord to get a key!",
                        Duration = 3,
                    })
                    
                    task.wait(1)
                    
                    -- Open Discord invite
                    if setclipboard then
                        setclipboard(config.hub.discord)
                        Rayfield:Notify({
                            Title = "Discord Link Copied",
                            Content = "Join and go to #get-keys channel",
                            Duration = 4,
                        })
                    end
                end
            })
            
            -- Enter Key Input
            local keyInput = ""
            GamesTab:CreateInput({
                Name = "Enter Key",
                PlaceholderText = "AETH-XXXX-XXXX",
                RemoveTextAfterFocusLost = false,
                Callback = function(Text)
                    keyInput = Text
                end
            })
            
            -- Verify Key Button
            GamesTab:CreateButton({
                Name = "✅ Verify Key",
                Callback = function()
                    if keyInput == "" then
                        Rayfield:Notify({
                            Title = "Error",
                            Content = "Please enter a key first",
                            Duration = 2,
                        })
                        return
                    end
                    
                    Rayfield:Notify({
                        Title = "Verifying...",
                        Content = "Checking key validity...",
                        Duration = 2,
                    })
                    
                    local valid, expires = verifyKey(keyInput, game.id)
                    
                    if valid then
                        saveKey(game.id, keyInput, expires)
                        
                        Rayfield:Notify({
                            Title = "✅ Key Verified!",
                            Content = "Loading game...",
                            Duration = 2,
                        })
                        
                        task.wait(1)
                        loadGame(game)
                    else
                        Rayfield:Notify({
                            Title = "❌ Invalid Key",
                            Content = "Key is invalid or expired",
                            Duration = 3,
                        })
                    end
                end
            })
        else
            -- Launch Game Button (key already saved)
            GamesTab:CreateButton({
                Name = "🚀 Launch Game",
                Callback = function()
                    -- Check if in correct game
                    if game.placeId ~= game.PlaceId then
                        Rayfield:Notify({
                            Title = "Wrong Game",
                            Content = "Please join " .. game.name,
                            Duration = 3,
                        })
                        return
                    end
                    
                    loadGame(game)
                end
            })
            
            -- Reset Key Button
            GamesTab:CreateButton({
                Name = "🔄 Reset Key",
                Callback = function()
                    local keyFile = FOLDER_NAME .. "/" .. game.id .. "_key.json"
                    if isfile(keyFile) then
                        delfile(keyFile)
                        Rayfield:Notify({
                            Title = "Key Reset",
                            Content = "Please restart the hub",
                            Duration = 3,
                        })
                    end
                end
            })
        end
    end
    
    -- Info Tab
    local InfoTab = Window:CreateTab("ℹ️ Info", nil)
    
    InfoTab:CreateParagraph({
        Title = "Aether Hub v" .. config.hub.version,
        Content = [[Welcome to Aether Hub!

Premium Roblox script hub with advanced features.

Join our Discord for keys and support.
        
Created by ]] .. config.hub.author
    })
    
    InfoTab:CreateButton({
        Name = "📱 Join Discord",
        Callback = function()
            if setclipboard then
                setclipboard(config.hub.discord)
                Rayfield:Notify({
                    Title = "Discord Link Copied",
                    Content = "Paste in your browser to join!",
                    Duration = 3,
                })
            end
        end
    })
    
    InfoTab:CreateButton({
        Name = "💎 Buy Premium Key",
        Callback = function()
            Rayfield:Notify({
                Title = "Premium Keys",
                Content = "Monthly: $5 | Lifetime: $20\nContact @hikarii.dev in Discord",
                Duration = 6,
            })
        end
    })
end

-- Initialize
local function init()
    local config = loadConfig()
    
    if not config then
        warn("[Aether Hub] Failed to initialize")
        return
    end
    
    createHub(config)
end

-- Run
init()
