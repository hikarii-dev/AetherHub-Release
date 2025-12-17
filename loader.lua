-- Aether Hub v5.0 - EXACT Nexo Hub Clone
-- Perfect copy of Nexo Hub design

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Configuration
local API_URL = "https://roblox-production-7b1c.up.railway.app"
local DISCORD_INVITE = "https://discord.gg/cnEXsPDKuU"
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()

-- Game configuration
local GAMES = {
    {
        id = "brainrot-museum",
        name = "Rob the Brainrot Museum",
        icon = "🏛️",
        script_url = "https://raw.githubusercontent.com/hikarii-dev/AetherHub-Release/main/games/brainrot-museum.lua"
    }
}

-- Verify key
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

-- Глобальные переменные для ключа
_G.AetherHubKeyValid = false
_G.AetherHubCurrentKey = ""
_G.ScriptRunning = true

-- Функция фоновой проверки ключа
local function startKeyMonitor()
    task.spawn(function()
        while _G.ScriptRunning do
            task.wait(10) -- Проверка каждые 10 секунд
            
            if _G.AetherHubCurrentKey ~= "" then
                local valid, reason = verifyKey(_G.AetherHubCurrentKey, GAMES[1].id)
                
                if not valid then
                    warn("[Aether Hub] Key invalid! Reason:", reason)
                    _G.AetherHubKeyValid = false
                    _G.ScriptRunning = false
                    _G.AetherHubCurrentKey = ""
                    
                    -- Удаляем все вкладки игр из sidebar
                    local sidebarFrame = _G.AetherHub_Sidebar
                    if sidebarFrame then
                        for _, child in pairs(sidebarFrame:GetChildren()) do
                            if child:IsA("TextButton") and child.Name ~= "Key Access" then
                                child:Destroy()
                            end
                        end
                    end
                    
                    -- Возвращаемся на страницу Key Access
                    if _G.AetherHub_ShowKeyPage then
                        _G.AetherHub_ShowKeyPage()
                    end
                    
                    -- Уведомление
                    Notify("⚠️ Key Expired", "Please enter a new key", 5)
                    
                    warn("[Aether Hub] Key expired - returned to Key Access page")
                    break
                end
            end
        end
    end)
end

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AetherHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- BLUR
local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 20
BlurEffect.Parent = game:GetService("Lighting")

-- Main Frame - ТОЧНЫЕ РАЗМЕРЫ КАК У NEXO
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 710, 0, 450)
MainFrame.Position = UDim2.new(0.5, -355, 0.5, -225)
MainFrame.BackgroundTransparency = 1
MainFrame.Parent = ScreenGui

-- Background - ПРОЗРАЧНЫЙ с blur
local Background = Instance.new("Frame")
Background.Size = UDim2.new(1, 0, 1, 0)
Background.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Background.BackgroundTransparency = 0.3
Background.BorderSizePixel = 0
Background.Parent = MainFrame

local BgCorner = Instance.new("UICorner")
BgCorner.CornerRadius = UDim.new(0, 8)
BgCorner.Parent = Background

-- TopBar - ПРОЗРАЧНЫЙ
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundTransparency = 1
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

-- БЕЛЫЙ РАЗДЕЛИТЕЛЬ под топбаром
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -16, 0, 1)
Divider.Position = UDim2.new(0, 8, 1, 0)
Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Divider.BackgroundTransparency = 0.85
Divider.BorderSizePixel = 0
Divider.Parent = TopBar

-- Title
local TitleIcon = Instance.new("TextLabel")
TitleIcon.Size = UDim2.new(0, 20, 1, 0)
TitleIcon.Position = UDim2.new(0, 8, 0, 0)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Text = "🔑"
TitleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleIcon.TextSize = 14
TitleIcon.Font = Enum.Font.Gotham
TitleIcon.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 120, 1, 0)
Title.Position = UDim2.new(0, 32, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Aether Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(0, 200, 1, 0)
Subtitle.Position = UDim2.new(0, 118, 0, 0)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Key System Loaded!"
Subtitle.TextColor3 = Color3.fromRGB(120, 120, 120)
Subtitle.TextSize = 11
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = TopBar

-- Window Control Buttons
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 40, 0, 35)
MinimizeBtn.Position = UDim2.new(1, -120, 0, 0)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TopBar

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    BlurEffect.Enabled = false
end)

local MaximizeBtn = Instance.new("TextButton")
MaximizeBtn.Size = UDim2.new(0, 40, 0, 35)
MaximizeBtn.Position = UDim2.new(1, -80, 0, 0)
MaximizeBtn.BackgroundTransparency = 1
MaximizeBtn.Text = "☐"
MaximizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MaximizeBtn.TextSize = 13
MaximizeBtn.Font = Enum.Font.GothamBold
MaximizeBtn.Parent = TopBar

local isMaximized = false
local savedPosition = UDim2.new(0.5, -355, 0.5, -225)
local savedSize = UDim2.new(0, 710, 0, 450)

MaximizeBtn.MouseButton1Click:Connect(function()
    if not isMaximized then
        -- Maximize
        savedPosition = MainFrame.Position
        savedSize = MainFrame.Size
        MainFrame.Position = UDim2.new(0, 0, 0, 0)
        MainFrame.Size = UDim2.new(1, 0, 1, 0)
        isMaximized = true
    else
        -- Restore
        MainFrame.Position = savedPosition
        MainFrame.Size = savedSize
        isMaximized = false
    end
end)

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

CloseBtn.MouseButton1Click:Connect(function()
    BlurEffect:Destroy()
    ScreenGui:Destroy()
end)

-- Sidebar - ПРОЗРАЧНЫЙ, без видимой границы
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 220, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundTransparency = 1
Sidebar.BorderSizePixel = 0
Sidebar.ClipsDescendants = true
Sidebar.Parent = MainFrame

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -220, 1, -35)
Content.Position = UDim2.new(0, 220, 0, 35)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Глобальные переменные для доступа из функций
_G.AetherHub_Sidebar = Sidebar
_G.AetherHub_Content = Content

-- ===================================
-- SIDEBAR BUTTON
-- ===================================

local currentTab = "Key Access"

local function CreateTab(name, icon, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, -8, 0, 34)
    btn.Position = UDim2.new(0, 4, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = Sidebar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn
    
    -- Highlight bar
    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.Size = UDim2.new(0, 2, 1, -4)
    bar.Position = UDim2.new(0, 0, 0, 2)
    bar.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    bar.BorderSizePixel = 0
    bar.Visible = false
    bar.Parent = btn
    
    -- Иконка
    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(0, 22, 1, 0)
    iconLbl.Position = UDim2.new(0, 6, 0, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = icon
    iconLbl.TextColor3 = Color3.fromRGB(170, 170, 170)
    iconLbl.TextSize = 14
    iconLbl.Font = Enum.Font.Gotham
    iconLbl.Parent = btn
    
    -- Текст
    local textLbl = Instance.new("TextLabel")
    textLbl.Size = UDim2.new(1, -34, 1, 0)
    textLbl.Position = UDim2.new(0, 30, 0, 0)
    textLbl.BackgroundTransparency = 1
    textLbl.Text = name
    textLbl.TextColor3 = Color3.fromRGB(190, 190, 190)
    textLbl.TextSize = 14
    textLbl.Font = Enum.Font.Gotham
    textLbl.TextXAlignment = Enum.TextXAlignment.Left
    textLbl.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        currentTab = name
        callback()
        
        for _, b in pairs(Sidebar:GetChildren()) do
            if b:IsA("TextButton") then
                local barItem = b:FindFirstChild("Bar")
                if b.Name == name then
                    b.BackgroundTransparency = 0.7
                    if barItem then barItem.Visible = true end
                else
                    b.BackgroundTransparency = 1
                    if barItem then barItem.Visible = false end
                end
            end
        end
    end)
    
    return btn
end

-- ===================================
-- PAGES
-- ===================================

local function Clear()
    for _, c in pairs(Content:GetChildren()) do
        c:Destroy()
    end
end

local function Notify(title, msg, dur)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 270, 0, 65)
    notif.Position = UDim2.new(1, -280, 1, -75)
    notif.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    notif.BorderSizePixel = 0
    notif.Parent = ScreenGui
    
    local nc = Instance.new("UICorner")
    nc.CornerRadius = UDim.new(0, 6)
    nc.Parent = notif
    
    local nt = Instance.new("TextLabel")
    nt.Size = UDim2.new(1, -14, 0, 20)
    nt.Position = UDim2.new(0, 10, 0, 6)
    nt.BackgroundTransparency = 1
    nt.Text = title
    nt.TextColor3 = Color3.fromRGB(255, 255, 255)
    nt.TextSize = 22
    nt.Font = Enum.Font.GothamBold
    nt.TextXAlignment = Enum.TextXAlignment.Left
    nt.Parent = notif
    
    local nm = Instance.new("TextLabel")
    nm.Size = UDim2.new(1, -14, 0, 32)
    nm.Position = UDim2.new(0, 10, 0, 32)
    nm.BackgroundTransparency = 1
    nm.Text = msg
    nm.TextColor3 = Color3.fromRGB(170, 170, 170)
    nm.TextSize = 18
    nm.Font = Enum.Font.Gotham
    nm.TextXAlignment = Enum.TextXAlignment.Left
    nm.TextWrapped = true
    nm.Parent = notif
    
    task.wait(dur or 3)
    notif:Destroy()
end

-- KEY ACCESS PAGE
local function ShowKeyPage()
    Clear()
    
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, -24, 1, -24)
    page.Position = UDim2.new(0, 12, 0, 12)
    page.BackgroundTransparency = 1
    page.Parent = Content
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 32)
    title.BackgroundTransparency = 1
    title.Text = "🔑 Key Access"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = page
    
    -- КОНТЕЙНЕР - темное поле
    local inputContainer = Instance.new("Frame")
    inputContainer.Size = UDim2.new(1, 0, 0, 38)
    inputContainer.Position = UDim2.new(0, 0, 0, 45)
    inputContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    inputContainer.BackgroundTransparency = 0.3
    inputContainer.BorderSizePixel = 0
    inputContainer.Parent = page
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 5)
    containerCorner.Parent = inputContainer
    
    -- Label ВНУТРИ контейнера слева
    local inputLabel = Instance.new("TextLabel")
    inputLabel.Size = UDim2.new(0, 120, 1, 0)
    inputLabel.Position = UDim2.new(0, 12, 0, 0)
    inputLabel.BackgroundTransparency = 1
    inputLabel.Text = "Enter Your Key:"
    inputLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    inputLabel.TextSize = 12
    inputLabel.Font = Enum.Font.GothamSemibold
    inputLabel.TextXAlignment = Enum.TextXAlignment.Left
    inputLabel.Parent = inputContainer
    
    -- СВЕТЛОЕ поле для ввода ВНУТРИ контейнера справа
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0, 330, 0, 28)
    input.Position = UDim2.new(1, -338, 0, 5)
    input.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    input.BackgroundTransparency = 0.2
    input.BorderSizePixel = 0
    input.PlaceholderText = "Poelsidjeudj2jaksujskd"
    input.PlaceholderColor3 = Color3.fromRGB(110, 110, 110)
    input.Text = ""
    input.TextColor3 = Color3.fromRGB(230, 230, 230)
    input.TextSize = 12
    input.Font = Enum.Font.Gotham
    input.ClearTextOnFocus = false
    input.Parent = inputContainer
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = input
    
    local inputPadding = Instance.new("UIPadding")
    inputPadding.PaddingLeft = UDim.new(0, 8)
    inputPadding.PaddingRight = UDim.new(0, 8)
    inputPadding.Parent = input
    
    local function Btn(txt, ico, y, cb)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 38)  -- КОМПАКТНЫЙ 38px
        b.Position = UDim2.new(0, 0, 0, y)
        b.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
        b.BackgroundTransparency = 0.2
        b.BorderSizePixel = 1
        b.BorderColor3 = Color3.fromRGB(65, 65, 65)
        b.BorderMode = Enum.BorderMode.Inset
        b.Text = ""
        b.AutoButtonColor = false
        b.Parent = page
        
        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0, 5)
        bc.Parent = b
        
        local bi = Instance.new("TextLabel")
        bi.Size = UDim2.new(0, 26, 1, 0)
        bi.Position = UDim2.new(0, 10, 0, 0)
        bi.BackgroundTransparency = 1
        bi.Text = ico
        bi.TextColor3 = Color3.fromRGB(255, 255, 255)
        bi.TextSize = 14
        bi.Parent = b
        
        local bt = Instance.new("TextLabel")
        bt.Size = UDim2.new(1, -50, 1, 0)
        bt.Position = UDim2.new(0, 38, 0, 0)
        bt.BackgroundTransparency = 1
        bt.Text = txt
        bt.TextColor3 = Color3.fromRGB(220, 220, 220)
        bt.TextSize = 13
        bt.Font = Enum.Font.GothamSemibold
        bt.TextXAlignment = Enum.TextXAlignment.Left
        bt.Parent = b
        
        local ba = Instance.new("TextLabel")
        ba.Size = UDim2.new(0, 26, 1, 0)
        ba.Position = UDim2.new(1, -26, 0, 0)
        ba.BackgroundTransparency = 1
        ba.Text = "›"
        ba.TextColor3 = Color3.fromRGB(100, 100, 100)
        ba.TextSize = 18
        ba.Font = Enum.Font.GothamBold
        ba.Parent = b
        
        b.MouseEnter:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.1), {BackgroundTransparency = 0.1}):Play()
        end)
        
        b.MouseLeave:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.1), {BackgroundTransparency = 0.3}):Play()
        end)
        
        b.MouseButton1Click:Connect(cb)
    end
    
    Btn("Get Key (Copy Discord Link)", "🔑", 93, function()
        if setclipboard then
            setclipboard(DISCORD_INVITE)
            Notify("Link Copied", "Join Discord → #get-key", 4)
        else
            Notify("Join Discord", DISCORD_INVITE, 4)
        end
    end)
    
    Btn("Buy Permanent Key - Join Discord", "💰", 137, function()
        if setclipboard then
            setclipboard(DISCORD_INVITE)
            Notify("Link Copied", "Join Discord → #get-key", 4)
        else
            Notify("Join Discord", DISCORD_INVITE, 4)
        end
    end)
    
    Btn("Verify Key", "✅", 181, function()
        local key = input.Text
        if key == "" then
            Notify("❌ Error", "Enter key first", 2)
            return
        end
        
        Notify("Verifying...", "Please wait...", 2)
        
        local valid, reason = verifyKey(key, GAMES[1].id)
        
        if valid then
            _G.AetherHubKeyValid = true
            _G.AetherHubCurrentKey = key
            _G.ScriptRunning = true
            
            -- Запускаем мониторинг ключа
            startKeyMonitor()
            
            -- Добавляем игры мгновенно
            for i, g in ipairs(GAMES) do
                CreateTab(g.name, g.icon, 48, function()
                    ShowGamePage(g)
                end)
            end
            
            -- Уведомление показываем сразу
            task.spawn(function()
                Notify("✅ Valid!", "Key verified", 3)
            end)
        else
            local err = "Invalid key"
            if reason == "not_found" then
                err = "Key not found"
            elseif reason then
                err = reason
            end
            Notify("❌ " .. err, "Check key", 4)
        end
    end)
    
    Btn("Join Discord - Press to copy link", "📢", 225, function()
        if setclipboard then
            setclipboard(DISCORD_INVITE)
            Notify("Link Copied", "Join Discord → #get-key", 4)
        else
            Notify("Join Discord", DISCORD_INVITE, 4)
        end
    end)
end

-- GAME PAGE
function ShowGamePage(gameData)
    Clear()
    
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, -24, 1, -24)
    page.Position = UDim2.new(0, 12, 0, 12)
    page.BackgroundTransparency = 1
    page.Parent = Content
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 32)
    title.BackgroundTransparency = 1
    title.Text = gameData.icon .. " " .. gameData.name
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = page
    
    local activate = Instance.new("TextButton")
    activate.Size = UDim2.new(1, 0, 0, 44)
    activate.Position = UDim2.new(0, 0, 0, 45)
    activate.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
    activate.BorderSizePixel = 0
    activate.Text = ""
    activate.AutoButtonColor = false
    activate.Parent = page
    
    local ac = Instance.new("UICorner")
    ac.CornerRadius = UDim.new(0, 6)
    ac.Parent = activate
    
    local at = Instance.new("TextLabel")
    at.Size = UDim2.new(1, 0, 1, 0)
    at.BackgroundTransparency = 1
    at.Text = "🚀 Activate Script"
    at.TextColor3 = Color3.fromRGB(255, 255, 255)
    at.TextSize = 17
    at.Font = Enum.Font.GothamBold
    at.Parent = activate
    
    activate.MouseEnter:Connect(function()
        TweenService:Create(activate, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(70, 200, 85)}):Play()
    end)
    
    activate.MouseLeave:Connect(function()
        TweenService:Create(activate, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 180, 75)}):Play()
    end)
    
    activate.MouseButton1Click:Connect(function()
        -- Проверяем валидность ключа ПЕРЕД запуском
        if not _G.AetherHubKeyValid or not _G.ScriptRunning then
            Notify("❌ Error", "Key expired! Enter new key", 4)
            return
        end
        
        Notify("⏳ Loading...", "Please wait...", 2)
        
        task.wait(0.3)
        
        -- Полностью очищаем старый Rayfield UI
        pcall(function()
            if _G.RayfieldInstance then
                _G.RayfieldInstance:Destroy()
                _G.RayfieldInstance = nil
            end
            
            -- Удаляем все Rayfield GUI из CoreGui
            local coreGui = game:GetService("CoreGui")
            for _, gui in pairs(coreGui:GetChildren()) do
                if gui.Name == "Rayfield" or gui.Name:find("Rayfield") then
                    gui:Destroy()
                end
            end
        end)
        
        task.wait(0.2)
        
        -- Шаг 1: Загружаем Rayfield заново
        local rayfieldSuccess = pcall(function()
            local rayfieldCode = game:HttpGet('https://sirius.menu/rayfield', true)
            _G.Rayfield = loadstring(rayfieldCode)()
            _G.RayfieldInstance = _G.Rayfield
        end)
        
        if not rayfieldSuccess or not _G.Rayfield then
            warn("[Aether Hub] Failed to load Rayfield")
            Notify("❌ Error", "UI library failed to load", 5)
            return
        end
        
        task.wait(0.2)
        
        -- Шаг 2: Теперь загружаем скрипт игры
        local scriptSuccess, scriptError = pcall(function()
            local scriptCode = game:HttpGet(gameData.script_url, true)
            loadstring(scriptCode)()
        end)
        
        if scriptSuccess then
            Notify("✅ Loaded!", "Enjoy!", 3)
        else
            warn("[Aether Hub] Script error:", scriptError)
            Notify("❌ Error", "Check F9 console", 5)
        end
    end)
    
    local info = Instance.new("Frame")
    info.Size = UDim2.new(1, 0, 0, 140)
    info.Position = UDim2.new(0, 0, 0, 101)
    info.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    info.BackgroundTransparency = 0.4
    info.BorderSizePixel = 0
    info.Parent = page
    
    local infoc = Instance.new("UICorner")
    infoc.CornerRadius = UDim.new(0, 6)
    infoc.Parent = info
    
    local infot = Instance.new("TextLabel")
    infot.Size = UDim2.new(1, -14, 0, 20)
    infot.Position = UDim2.new(0, 10, 0, 8)
    infot.BackgroundTransparency = 1
    infot.Text = "Script Info"
    infot.TextColor3 = Color3.fromRGB(255, 255, 255)
    infot.TextSize = 20
    infot.Font = Enum.Font.GothamBold
    infot.TextXAlignment = Enum.TextXAlignment.Left
    infot.Parent = info
    
    local infom = Instance.new("TextLabel")
    infom.Size = UDim2.new(1, -14, 0, 100)
    infom.Position = UDim2.new(0, 10, 0, 34)
    infom.BackgroundTransparency = 1
    infom.Text = "• Auto Collect Cash\n• Auto Rebirth\n• Auto Steal Brainrots with filtres: Price, Zones, Rariry\n• Auto Steal Lucky Blocks\n• Teleport To Zones, Base, Exit from Museum\n• Statistics tracking"
    infom.TextColor3 = Color3.fromRGB(170, 170, 170)
    infom.TextSize = 15
    infom.Font = Enum.Font.Gotham
    infom.TextXAlignment = Enum.TextXAlignment.Left
    infom.TextYAlignment = Enum.TextYAlignment.Top
    infom.TextWrapped = true
    infom.Parent = info
end

-- ===================================
-- INIT
-- ===================================

_G.AetherHub_ShowKeyPage = ShowKeyPage
CreateTab("Key Access", "🔑", 6, ShowKeyPage)
ShowKeyPage()

task.wait(0.05)
local firstBtn = Sidebar:FindFirstChild("Key Access")
if firstBtn then
    firstBtn.BackgroundTransparency = 0.7
    local bar = firstBtn:FindFirstChild("Bar")
    if bar then bar.Visible = true end
end

-- Draggable
local drag, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        drag = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                drag = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and drag then
        update(input)
    end
end)

-- Hotkey: Delete or Insert to toggle hub
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Delete or input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
        BlurEffect.Enabled = MainFrame.Visible
    end
end)

warn("[Aether Hub] ✅ Loaded - Nexo Style!")
