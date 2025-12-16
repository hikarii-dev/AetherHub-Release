-- Aether Hub v5.0 - Nexo Style UI with BLUR
-- Exact copy of Nexo Hub design

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

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AetherHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- BLUR EFFECT (как у Nexo!)
local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 15
BlurEffect.Parent = game:GetService("Lighting")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 700, 0, 420)
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -210)
MainFrame.BackgroundTransparency = 1
MainFrame.Parent = ScreenGui

-- Background Frame with semi-transparent dark color
local Background = Instance.new("Frame")
Background.Name = "Background"
Background.Size = UDim2.new(1, 0, 1, 0)
Background.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Background.BackgroundTransparency = 0.25
Background.BorderSizePixel = 0
Background.Parent = MainFrame

local BackgroundCorner = Instance.new("UICorner")
BackgroundCorner.CornerRadius = UDim.new(0, 10)
BackgroundCorner.Parent = Background

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
TopBar.BackgroundTransparency = 0
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

-- Fix corner clipping
local TopBarFix = Instance.new("Frame")
TopBarFix.Size = UDim2.new(1, 0, 0, 10)
TopBarFix.Position = UDim2.new(0, 0, 1, -10)
TopBarFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
TopBarFix.BackgroundTransparency = 0
TopBarFix.BorderSizePixel = 0
TopBarFix.Parent = TopBar

-- Title Icon
local TitleIcon = Instance.new("TextLabel")
TitleIcon.Size = UDim2.new(0, 20, 1, 0)
TitleIcon.Position = UDim2.new(0, 10, 0, 0)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Text = "🔑"
TitleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleIcon.TextSize = 14
TitleIcon.Font = Enum.Font.Gotham
TitleIcon.Parent = TopBar

-- Title Text
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 150, 1, 0)
Title.Position = UDim2.new(0, 35, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Aether Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Subtitle
local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(0, 200, 1, 0)
Subtitle.Position = UDim2.new(0, 200, 0, 0)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Key System Loaded!"
Subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
Subtitle.TextSize = 11
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = TopBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 35, 1, 0)
CloseButton.Position = UDim2.new(1, -35, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TopBar

CloseButton.MouseButton1Click:Connect(function()
    BlurEffect:Destroy()
    ScreenGui:Destroy()
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 200, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Sidebar.BackgroundTransparency = 0.2
Sidebar.BorderSizePixel = 0
Sidebar.ClipsDescendants = true
Sidebar.Parent = MainFrame

-- Sidebar bottom corner fix
local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 10)
SidebarCorner.Parent = Sidebar

local SidebarFix = Instance.new("Frame")
SidebarFix.Size = UDim2.new(0, 10, 1, 0)
SidebarFix.Position = UDim2.new(1, -10, 0, 0)
SidebarFix.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
SidebarFix.BackgroundTransparency = 0.2
SidebarFix.BorderSizePixel = 0
SidebarFix.Parent = Sidebar

local SidebarTopFix = Instance.new("Frame")
SidebarTopFix.Size = UDim2.new(1, 0, 0, 10)
SidebarTopFix.Position = UDim2.new(0, 0, 0, 0)
SidebarTopFix.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
SidebarTopFix.BackgroundTransparency = 0.2
SidebarTopFix.BorderSizePixel = 0
SidebarTopFix.Parent = Sidebar

-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -200, 1, -35)
ContentArea.Position = UDim2.new(0, 200, 0, 35)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- ===================================
-- SIDEBAR BUTTONS
-- ===================================

local currentTab = nil
local keyVerified = false
local currentKey = ""

-- Function to create sidebar button
local function CreateSidebarButton(text, icon, yPos, onClick)
    local Button = Instance.new("TextButton")
    Button.Name = text
    Button.Size = UDim2.new(1, -12, 0, 40)
    Button.Position = UDim2.new(0, 6, 0, yPos)
    Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Button.BackgroundTransparency = 0.4
    Button.BorderSizePixel = 0
    Button.AutoButtonColor = false
    Button.ClipsDescendants = true
    Button.Parent = Sidebar
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button
    
    -- Highlight bar (активная вкладка)
    local Highlight = Instance.new("Frame")
    Highlight.Name = "Highlight"
    Highlight.Size = UDim2.new(0, 3, 1, 0)
    Highlight.Position = UDim2.new(0, 0, 0, 0)
    Highlight.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    Highlight.BorderSizePixel = 0
    Highlight.Visible = false
    Highlight.Parent = Button
    
    local ButtonIcon = Instance.new("TextLabel")
    ButtonIcon.Size = UDim2.new(0, 30, 1, 0)
    ButtonIcon.Position = UDim2.new(0, 10, 0, 0)
    ButtonIcon.BackgroundTransparency = 1
    ButtonIcon.Text = icon
    ButtonIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    ButtonIcon.TextSize = 16
    ButtonIcon.Font = Enum.Font.Gotham
    ButtonIcon.Parent = Button
    
    local ButtonText = Instance.new("TextLabel")
    ButtonText.Size = UDim2.new(1, -50, 1, 0)
    ButtonText.Position = UDim2.new(0, 42, 0, 0)
    ButtonText.BackgroundTransparency = 1
    ButtonText.Text = text
    ButtonText.TextColor3 = Color3.fromRGB(200, 200, 200)
    ButtonText.TextSize = 12
    ButtonText.Font = Enum.Font.Gotham
    ButtonText.TextXAlignment = Enum.TextXAlignment.Left
    ButtonText.Parent = Button
    
    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.new(0, 20, 1, 0)
    Arrow.Position = UDim2.new(1, -22, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "›"
    Arrow.TextColor3 = Color3.fromRGB(120, 120, 120)
    Arrow.TextSize = 18
    Arrow.Font = Enum.Font.GothamBold
    Arrow.Parent = Button
    
    -- Hover effect
    Button.MouseEnter:Connect(function()
        if currentTab ~= text then
            TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
        end
    end)
    
    Button.MouseLeave:Connect(function()
        if currentTab ~= text then
            TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundTransparency = 0.4}):Play()
        end
    end)
    
    Button.MouseButton1Click:Connect(function()
        currentTab = text
        onClick()
        
        -- Update all buttons
        for _, btn in pairs(Sidebar:GetChildren()) do
            if btn:IsA("TextButton") then
                local highlight = btn:FindFirstChild("Highlight")
                if btn.Name == text then
                    btn.BackgroundTransparency = 0.2
                    if highlight then highlight.Visible = true end
                else
                    btn.BackgroundTransparency = 0.4
                    if highlight then highlight.Visible = false end
                end
            end
        end
    end)
    
    return Button
end

-- ===================================
-- CONTENT PAGES
-- ===================================

local function ClearContent()
    for _, child in pairs(ContentArea:GetChildren()) do
        child:Destroy()
    end
end

local function ShowNotification(title, message, duration)
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 280, 0, 70)
    notification.Position = UDim2.new(1, -290, 0, 15)
    notification.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notification.BackgroundTransparency = 0
    notification.BorderSizePixel = 0
    notification.Parent = ScreenGui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = notification
    
    local notifTitle = Instance.new("TextLabel")
    notifTitle.Size = UDim2.new(1, -16, 0, 22)
    notifTitle.Position = UDim2.new(0, 12, 0, 8)
    notifTitle.BackgroundTransparency = 1
    notifTitle.Text = title
    notifTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifTitle.TextSize = 13
    notifTitle.Font = Enum.Font.GothamBold
    notifTitle.TextXAlignment = Enum.TextXAlignment.Left
    notifTitle.Parent = notification
    
    local notifMessage = Instance.new("TextLabel")
    notifMessage.Size = UDim2.new(1, -16, 0, 32)
    notifMessage.Position = UDim2.new(0, 12, 0, 32)
    notifMessage.BackgroundTransparency = 1
    notifMessage.Text = message
    notifMessage.TextColor3 = Color3.fromRGB(180, 180, 180)
    notifMessage.TextSize = 11
    notifMessage.Font = Enum.Font.Gotham
    notifMessage.TextXAlignment = Enum.TextXAlignment.Left
    notifMessage.TextWrapped = true
    notifMessage.Parent = notification
    
    task.wait(duration or 3)
    notification:Destroy()
end

-- KEY ACCESS PAGE
local function ShowKeyAccessPage()
    ClearContent()
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -30, 1, -30)
    Container.Position = UDim2.new(0, 15, 0, 15)
    Container.BackgroundTransparency = 1
    Container.Parent = ContentArea
    
    -- Title
    local PageTitle = Instance.new("TextLabel")
    PageTitle.Size = UDim2.new(1, 0, 0, 35)
    PageTitle.BackgroundTransparency = 1
    PageTitle.Text = "🔑 Key Access"
    PageTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    PageTitle.TextSize = 22
    PageTitle.Font = Enum.Font.GothamBold
    PageTitle.TextXAlignment = Enum.TextXAlignment.Left
    PageTitle.Parent = Container
    
    -- Key Input Label
    local InputLabel = Instance.new("TextLabel")
    InputLabel.Size = UDim2.new(1, 0, 0, 18)
    InputLabel.Position = UDim2.new(0, 0, 0, 50)
    InputLabel.BackgroundTransparency = 1
    InputLabel.Text = "Enter Your Key:"
    InputLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    InputLabel.TextSize = 12
    InputLabel.Font = Enum.Font.Gotham
    InputLabel.TextXAlignment = Enum.TextXAlignment.Left
    InputLabel.Parent = Container
    
    -- Key Input Box
    local KeyInput = Instance.new("TextBox")
    KeyInput.Size = UDim2.new(1, 0, 0, 42)
    KeyInput.Position = UDim2.new(0, 0, 0, 73)
    KeyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    KeyInput.BackgroundTransparency = 0.3
    KeyInput.BorderSizePixel = 0
    KeyInput.PlaceholderText = "Example: alot of random"
    KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    KeyInput.Text = ""
    KeyInput.TextColor3 = Color3.fromRGB(220, 220, 220)
    KeyInput.TextSize = 13
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.ClearTextOnFocus = false
    KeyInput.Parent = Container
    
    local KeyInputCorner = Instance.new("UICorner")
    KeyInputCorner.CornerRadius = UDim.new(0, 6)
    KeyInputCorner.Parent = KeyInput
    
    local KeyInputPadding = Instance.new("UIPadding")
    KeyInputPadding.PaddingLeft = UDim.new(0, 12)
    KeyInputPadding.Parent = KeyInput
    
    -- Функция создания кнопки
    local function CreateActionButton(text, icon, yPos, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 0, 42)
        Button.Position = UDim2.new(0, 0, 0, yPos)
        Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Button.BackgroundTransparency = 0.3
        Button.BorderSizePixel = 0
        Button.Text = ""
        Button.AutoButtonColor = false
        Button.Parent = Container
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 6)
        ButtonCorner.Parent = Button
        
        local ButtonIcon = Instance.new("TextLabel")
        ButtonIcon.Size = UDim2.new(0, 28, 1, 0)
        ButtonIcon.Position = UDim2.new(0, 12, 0, 0)
        ButtonIcon.BackgroundTransparency = 1
        ButtonIcon.Text = icon
        ButtonIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
        ButtonIcon.TextSize = 16
        ButtonIcon.Parent = Button
        
        local ButtonText = Instance.new("TextLabel")
        ButtonText.Size = UDim2.new(1, -55, 1, 0)
        ButtonText.Position = UDim2.new(0, 42, 0, 0)
        ButtonText.BackgroundTransparency = 1
        ButtonText.Text = text
        ButtonText.TextColor3 = Color3.fromRGB(220, 220, 220)
        ButtonText.TextSize = 13
        ButtonText.Font = Enum.Font.Gotham
        ButtonText.TextXAlignment = Enum.TextXAlignment.Left
        ButtonText.Parent = Button
        
        local ButtonArrow = Instance.new("TextLabel")
        ButtonArrow.Size = UDim2.new(0, 28, 1, 0)
        ButtonArrow.Position = UDim2.new(1, -28, 0, 0)
        ButtonArrow.BackgroundTransparency = 1
        ButtonArrow.Text = "›"
        ButtonArrow.TextColor3 = Color3.fromRGB(120, 120, 120)
        ButtonArrow.TextSize = 20
        ButtonArrow.Font = Enum.Font.GothamBold
        ButtonArrow.Parent = Button
        
        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundTransparency = 0.1}):Play()
        end)
        
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundTransparency = 0.3}):Play()
        end)
        
        Button.MouseButton1Click:Connect(callback)
        
        return Button
    end
    
    -- Button: Get Key
    CreateActionButton("Get Key (Copy Discord)", "🔑", 125, function()
        if setclipboard then
            setclipboard(DISCORD_INVITE)
            ShowNotification("✅ Copied!", "Join Discord → #get-key channel", 4)
        else
            ShowNotification("Join Discord", DISCORD_INVITE, 4)
        end
    end)
    
    -- Button: Buy Premium
    CreateActionButton("Buy Permanent Key", "💰", 177, function()
        if setclipboard then
            setclipboard(DISCORD_INVITE)
            ShowNotification("💎 Premium", "$5/mo, $10/3mo - No Linkvertise!", 5)
        end
    end)
    
    -- Button: Verify Key
    CreateActionButton("Verify Key", "✅", 229, function()
        local key = KeyInput.Text
        if key == "" then
            ShowNotification("❌ Error", "Enter a key first", 2)
            return
        end
        
        ShowNotification("⏳ Verifying...", "Please wait...", 2)
        
        -- Verify with first game
        local valid, reason = verifyKey(key, GAMES[1].id)
        
        if valid then
            keyVerified = true
            currentKey = key
            ShowNotification("✅ Valid!", "Key verified successfully", 3)
            
            -- Add game buttons to sidebar
            task.wait(0.5)
            for i, gameConfig in ipairs(GAMES) do
                CreateSidebarButton(gameConfig.name, gameConfig.icon, 60 + ((i - 1) * 48), function()
                    ShowGamePage(gameConfig)
                end)
            end
        else
            local errorMsg = "Invalid key"
            if reason == "not_found" then
                errorMsg = "Key not found. Get from Discord!"
            elseif reason then
                errorMsg = reason
            end
            ShowNotification("❌ " .. errorMsg, "Check your key", 4)
        end
    end)
end

-- GAME PAGE
local function ShowGamePage(gameConfig)
    ClearContent()
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -30, 1, -30)
    Container.Position = UDim2.new(0, 15, 0, 15)
    Container.BackgroundTransparency = 1
    Container.Parent = ContentArea
    
    -- Title
    local PageTitle = Instance.new("TextLabel")
    PageTitle.Size = UDim2.new(1, 0, 0, 35)
    PageTitle.BackgroundTransparency = 1
    PageTitle.Text = gameConfig.icon .. " " .. gameConfig.name
    PageTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    PageTitle.TextSize = 22
    PageTitle.Font = Enum.Font.GothamBold
    PageTitle.TextXAlignment = Enum.TextXAlignment.Left
    PageTitle.Parent = Container
    
    -- Description
    local Description = Instance.new("TextLabel")
    Description.Size = UDim2.new(1, 0, 0, 50)
    Description.Position = UDim2.new(0, 0, 0, 45)
    Description.BackgroundTransparency = 1
    Description.Text = "Script is ready to be activated.\nClick the button below to start."
    Description.TextColor3 = Color3.fromRGB(160, 160, 160)
    Description.TextSize = 12
    Description.Font = Enum.Font.Gotham
    Description.TextXAlignment = Enum.TextXAlignment.Left
    Description.TextYAlignment = Enum.TextYAlignment.Top
    Description.TextWrapped = true
    Description.Parent = Container
    
    -- Activate Button
    local ActivateButton = Instance.new("TextButton")
    ActivateButton.Size = UDim2.new(1, 0, 0, 48)
    ActivateButton.Position = UDim2.new(0, 0, 0, 110)
    ActivateButton.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
    ActivateButton.BackgroundTransparency = 0
    ActivateButton.BorderSizePixel = 0
    ActivateButton.Text = ""
    ActivateButton.AutoButtonColor = false
    ActivateButton.Parent = Container
    
    local ActivateCorner = Instance.new("UICorner")
    ActivateCorner.CornerRadius = UDim.new(0, 8)
    ActivateCorner.Parent = ActivateButton
    
    local ActivateText = Instance.new("TextLabel")
    ActivateText.Size = UDim2.new(1, 0, 1, 0)
    ActivateText.BackgroundTransparency = 1
    ActivateText.Text = "🚀 Activate Script"
    ActivateText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActivateText.TextSize = 15
    ActivateText.Font = Enum.Font.GothamBold
    ActivateText.Parent = ActivateButton
    
    ActivateButton.MouseEnter:Connect(function()
        TweenService:Create(ActivateButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(70, 200, 85)}):Play()
    end)
    
    ActivateButton.MouseLeave:Connect(function()
        TweenService:Create(ActivateButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 180, 75)}):Play()
    end)
    
    ActivateButton.MouseButton1Click:Connect(function()
        ShowNotification("⏳ Loading...", "Please wait...", 2)
        
        task.wait(0.5)
        
        local success, err = pcall(function()
            local scriptCode = game:GetService("HttpService"):GetAsync(gameConfig.script_url)
            loadstring(scriptCode)()
        end)
        
        if success then
            ShowNotification("✅ Loaded!", "Enjoy!", 3)
        else
            warn("[Aether Hub] Load error:", err)
            ShowNotification("❌ Error", "Failed to load. Check F9", 5)
        end
    end)
    
    -- Info Box
    local InfoBox = Instance.new("Frame")
    InfoBox.Size = UDim2.new(1, 0, 0, 90)
    InfoBox.Position = UDim2.new(0, 0, 0, 172)
    InfoBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    InfoBox.BackgroundTransparency = 0.4
    InfoBox.BorderSizePixel = 0
    InfoBox.Parent = Container
    
    local InfoBoxCorner = Instance.new("UICorner")
    InfoBoxCorner.CornerRadius = UDim.new(0, 8)
    InfoBoxCorner.Parent = InfoBox
    
    local InfoTitle = Instance.new("TextLabel")
    InfoTitle.Size = UDim2.new(1, -16, 0, 22)
    InfoTitle.Position = UDim2.new(0, 12, 0, 10)
    InfoTitle.BackgroundTransparency = 1
    InfoTitle.Text = "ℹ️ Script Info"
    InfoTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    InfoTitle.TextSize = 13
    InfoTitle.Font = Enum.Font.GothamBold
    InfoTitle.TextXAlignment = Enum.TextXAlignment.Left
    InfoTitle.Parent = InfoBox
    
    local InfoText = Instance.new("TextLabel")
    InfoText.Size = UDim2.new(1, -16, 0, 50)
    InfoText.Position = UDim2.new(0, 12, 0, 34)
    InfoText.BackgroundTransparency = 1
    InfoText.Text = "✅ Auto Collect Cash\n✅ Auto Rebirth\n✅ Auto Steal & more!"
    InfoText.TextColor3 = Color3.fromRGB(180, 180, 180)
    InfoText.TextSize = 11
    InfoText.Font = Enum.Font.Gotham
    InfoText.TextXAlignment = Enum.TextXAlignment.Left
    InfoText.TextYAlignment = Enum.TextYAlignment.Top
    InfoText.TextWrapped = true
    InfoText.Parent = InfoBox
end

-- ===================================
-- INITIALIZE
-- ===================================

-- Create initial sidebar button
CreateSidebarButton("Key Access", "🔑", 10, ShowKeyAccessPage)

-- Show Key Access page by default
ShowKeyAccessPage()

-- Set first button as active
task.wait(0.1)
currentTab = "Key Access"
local firstButton = Sidebar:FindFirstChild("Key Access")
if firstButton then
    firstButton.BackgroundTransparency = 0.2
    local highlight = firstButton:FindFirstChild("Highlight")
    if highlight then highlight.Visible = true end
end

-- Make draggable
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
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
    if input == dragInput and dragging then
        update(input)
    end
end)

warn("[Aether Hub] ✅ Loaded successfully with BLUR effect!")
