-- Aether Hub v5.0 - Nexo Style UI
-- Modern transparent design with sidebar

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

-- Main Frame (Container)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 700, 0, 450)
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -225)
MainFrame.BackgroundTransparency = 1
MainFrame.Parent = ScreenGui

-- Background with blur effect
local Background = Instance.new("Frame")
Background.Name = "Background"
Background.Size = UDim2.new(1, 0, 1, 0)
Background.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Background.BackgroundTransparency = 0.3
Background.BorderSizePixel = 0
Background.Parent = MainFrame

local BackgroundCorner = Instance.new("UICorner")
BackgroundCorner.CornerRadius = UDim.new(0, 12)
BackgroundCorner.Parent = Background

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TopBar.BackgroundTransparency = 0.2
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 12)
TopBarCorner.Parent = TopBar

-- Fix corner clipping
local TopBarFix = Instance.new("Frame")
TopBarFix.Size = UDim2.new(1, 0, 0, 12)
TopBarFix.Position = UDim2.new(0, 0, 1, -12)
TopBarFix.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TopBarFix.BackgroundTransparency = 0.2
TopBarFix.BorderSizePixel = 0
TopBarFix.Parent = TopBar

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔑 Aether Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Subtitle
local Subtitle = Instance.new("TextLabel")
Subtitle.Name = "Subtitle"
Subtitle.Size = UDim2.new(0, 200, 1, 0)
Subtitle.Position = UDim2.new(0, 150, 0, 0)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Key System Loaded!"
Subtitle.TextColor3 = Color3.fromRGB(180, 180, 180)
Subtitle.TextSize = 12
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = TopBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 20
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TopBar

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 200, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Sidebar.BackgroundTransparency = 0.3
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 0)
SidebarCorner.Parent = Sidebar

-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -200, 1, -40)
ContentArea.Position = UDim2.new(0, 200, 0, 40)
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
    Button.Size = UDim2.new(1, -10, 0, 45)
    Button.Position = UDim2.new(0, 5, 0, yPos)
    Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Button.BackgroundTransparency = 0.5
    Button.BorderSizePixel = 0
    Button.AutoButtonColor = false
    Button.Parent = Sidebar
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = Button
    
    local ButtonIcon = Instance.new("TextLabel")
    ButtonIcon.Size = UDim2.new(0, 30, 1, 0)
    ButtonIcon.Position = UDim2.new(0, 10, 0, 0)
    ButtonIcon.BackgroundTransparency = 1
    ButtonIcon.Text = icon
    ButtonIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    ButtonIcon.TextSize = 18
    ButtonIcon.Font = Enum.Font.Gotham
    ButtonIcon.Parent = Button
    
    local ButtonText = Instance.new("TextLabel")
    ButtonText.Size = UDim2.new(1, -50, 1, 0)
    ButtonText.Position = UDim2.new(0, 45, 0, 0)
    ButtonText.BackgroundTransparency = 1
    ButtonText.Text = text
    ButtonText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ButtonText.TextSize = 13
    ButtonText.Font = Enum.Font.Gotham
    ButtonText.TextXAlignment = Enum.TextXAlignment.Left
    ButtonText.Parent = Button
    
    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.new(0, 20, 1, 0)
    Arrow.Position = UDim2.new(1, -25, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "›"
    Arrow.TextColor3 = Color3.fromRGB(150, 150, 150)
    Arrow.TextSize = 20
    Arrow.Font = Enum.Font.GothamBold
    Arrow.Parent = Button
    
    -- Hover effect
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        if currentTab ~= text then
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
        end
    end)
    
    Button.MouseButton1Click:Connect(function()
        currentTab = text
        onClick()
        -- Update all buttons
        for _, btn in pairs(Sidebar:GetChildren()) do
            if btn:IsA("TextButton") then
                if btn.Name == text then
                    btn.BackgroundTransparency = 0.2
                else
                    btn.BackgroundTransparency = 0.5
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
    notification.Size = UDim2.new(0, 300, 0, 80)
    notification.Position = UDim2.new(1, -320, 0, 20)
    notification.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notification.BackgroundTransparency = 0.1
    notification.BorderSizePixel = 0
    notification.Parent = ScreenGui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 10)
    notifCorner.Parent = notification
    
    local notifTitle = Instance.new("TextLabel")
    notifTitle.Size = UDim2.new(1, -20, 0, 25)
    notifTitle.Position = UDim2.new(0, 10, 0, 10)
    notifTitle.BackgroundTransparency = 1
    notifTitle.Text = title
    notifTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifTitle.TextSize = 14
    notifTitle.Font = Enum.Font.GothamBold
    notifTitle.TextXAlignment = Enum.TextXAlignment.Left
    notifTitle.Parent = notification
    
    local notifMessage = Instance.new("TextLabel")
    notifMessage.Size = UDim2.new(1, -20, 0, 35)
    notifMessage.Position = UDim2.new(0, 10, 0, 35)
    notifMessage.BackgroundTransparency = 1
    notifMessage.Text = message
    notifMessage.TextColor3 = Color3.fromRGB(200, 200, 200)
    notifMessage.TextSize = 12
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
    Container.Size = UDim2.new(1, -40, 1, -40)
    Container.Position = UDim2.new(0, 20, 0, 20)
    Container.BackgroundTransparency = 1
    Container.Parent = ContentArea
    
    -- Title
    local PageTitle = Instance.new("TextLabel")
    PageTitle.Size = UDim2.new(1, 0, 0, 40)
    PageTitle.BackgroundTransparency = 1
    PageTitle.Text = "🔑 Key Access"
    PageTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    PageTitle.TextSize = 24
    PageTitle.Font = Enum.Font.GothamBold
    PageTitle.TextXAlignment = Enum.TextXAlignment.Left
    PageTitle.Parent = Container
    
    -- Key Input Label
    local InputLabel = Instance.new("TextLabel")
    InputLabel.Size = UDim2.new(1, 0, 0, 20)
    InputLabel.Position = UDim2.new(0, 0, 0, 60)
    InputLabel.BackgroundTransparency = 1
    InputLabel.Text = "Enter Your Key:"
    InputLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    InputLabel.TextSize = 13
    InputLabel.Font = Enum.Font.Gotham
    InputLabel.TextXAlignment = Enum.TextXAlignment.Left
    InputLabel.Parent = Container
    
    -- Key Input Box
    local KeyInput = Instance.new("TextBox")
    KeyInput.Size = UDim2.new(1, 0, 0, 45)
    KeyInput.Position = UDim2.new(0, 0, 0, 85)
    KeyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    KeyInput.BackgroundTransparency = 0.3
    KeyInput.BorderSizePixel = 0
    KeyInput.PlaceholderText = "Example: alot of random"
    KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    KeyInput.Text = ""
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.TextSize = 14
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.ClearTextOnFocus = false
    KeyInput.Parent = Container
    
    local KeyInputCorner = Instance.new("UICorner")
    KeyInputCorner.CornerRadius = UDim.new(0, 8)
    KeyInputCorner.Parent = KeyInput
    
    local KeyInputPadding = Instance.new("UIPadding")
    KeyInputPadding.PaddingLeft = UDim.new(0, 15)
    KeyInputPadding.Parent = KeyInput
    
    -- Button: Get Key
    local GetKeyButton = Instance.new("TextButton")
    GetKeyButton.Size = UDim2.new(1, 0, 0, 45)
    GetKeyButton.Position = UDim2.new(0, 0, 0, 145)
    GetKeyButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    GetKeyButton.BackgroundTransparency = 0.3
    GetKeyButton.BorderSizePixel = 0
    GetKeyButton.Text = ""
    GetKeyButton.AutoButtonColor = false
    GetKeyButton.Parent = Container
    
    local GetKeyCorner = Instance.new("UICorner")
    GetKeyCorner.CornerRadius = UDim.new(0, 8)
    GetKeyCorner.Parent = GetKeyButton
    
    local GetKeyIcon = Instance.new("TextLabel")
    GetKeyIcon.Size = UDim2.new(0, 30, 1, 0)
    GetKeyIcon.Position = UDim2.new(0, 15, 0, 0)
    GetKeyIcon.BackgroundTransparency = 1
    GetKeyIcon.Text = "🔑"
    GetKeyIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetKeyIcon.TextSize = 18
    GetKeyIcon.Parent = GetKeyButton
    
    local GetKeyText = Instance.new("TextLabel")
    GetKeyText.Size = UDim2.new(1, -60, 1, 0)
    GetKeyText.Position = UDim2.new(0, 50, 0, 0)
    GetKeyText.BackgroundTransparency = 1
    GetKeyText.Text = "Get Key (Copy Discord)"
    GetKeyText.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetKeyText.TextSize = 14
    GetKeyText.Font = Enum.Font.Gotham
    GetKeyText.TextXAlignment = Enum.TextXAlignment.Left
    GetKeyText.Parent = GetKeyButton
    
    local GetKeyArrow = Instance.new("TextLabel")
    GetKeyArrow.Size = UDim2.new(0, 30, 1, 0)
    GetKeyArrow.Position = UDim2.new(1, -30, 0, 0)
    GetKeyArrow.BackgroundTransparency = 1
    GetKeyArrow.Text = "›"
    GetKeyArrow.TextColor3 = Color3.fromRGB(150, 150, 150)
    GetKeyArrow.TextSize = 24
    GetKeyArrow.Font = Enum.Font.GothamBold
    GetKeyArrow.Parent = GetKeyButton
    
    GetKeyButton.MouseEnter:Connect(function()
        TweenService:Create(GetKeyButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
    end)
    
    GetKeyButton.MouseLeave:Connect(function()
        TweenService:Create(GetKeyButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
    end)
    
    GetKeyButton.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(DISCORD_INVITE)
            ShowNotification("✅ Copied!", "Join Discord → #get-key channel", 4)
        else
            ShowNotification("Join Discord", DISCORD_INVITE, 4)
        end
    end)
    
    -- Button: Buy Premium
    local BuyButton = Instance.new("TextButton")
    BuyButton.Size = UDim2.new(1, 0, 0, 45)
    BuyButton.Position = UDim2.new(0, 0, 0, 200)
    BuyButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    BuyButton.BackgroundTransparency = 0.3
    BuyButton.BorderSizePixel = 0
    BuyButton.Text = ""
    BuyButton.AutoButtonColor = false
    BuyButton.Parent = Container
    
    local BuyCorner = Instance.new("UICorner")
    BuyCorner.CornerRadius = UDim.new(0, 8)
    BuyCorner.Parent = BuyButton
    
    local BuyIcon = Instance.new("TextLabel")
    BuyIcon.Size = UDim2.new(0, 30, 1, 0)
    BuyIcon.Position = UDim2.new(0, 15, 0, 0)
    BuyIcon.BackgroundTransparency = 1
    BuyIcon.Text = "💰"
    BuyIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    BuyIcon.TextSize = 18
    BuyIcon.Parent = BuyButton
    
    local BuyText = Instance.new("TextLabel")
    BuyText.Size = UDim2.new(1, -60, 1, 0)
    BuyText.Position = UDim2.new(0, 50, 0, 0)
    BuyText.BackgroundTransparency = 1
    BuyText.Text = "Buy Permanent Key"
    BuyText.TextColor3 = Color3.fromRGB(255, 255, 255)
    BuyText.TextSize = 14
    BuyText.Font = Enum.Font.Gotham
    BuyText.TextXAlignment = Enum.TextXAlignment.Left
    BuyText.Parent = BuyButton
    
    local BuyArrow = Instance.new("TextLabel")
    BuyArrow.Size = UDim2.new(0, 30, 1, 0)
    BuyArrow.Position = UDim2.new(1, -30, 0, 0)
    BuyArrow.BackgroundTransparency = 1
    BuyArrow.Text = "›"
    BuyArrow.TextColor3 = Color3.fromRGB(150, 150, 150)
    BuyArrow.TextSize = 24
    BuyArrow.Font = Enum.Font.GothamBold
    BuyArrow.Parent = BuyButton
    
    BuyButton.MouseEnter:Connect(function()
        TweenService:Create(BuyButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
    end)
    
    BuyButton.MouseLeave:Connect(function()
        TweenService:Create(BuyButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
    end)
    
    BuyButton.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(DISCORD_INVITE)
            ShowNotification("💎 Premium", "$5/mo, $10/3mo - No Linkvertise!", 5)
        end
    end)
    
    -- Button: Verify Key
    local VerifyButton = Instance.new("TextButton")
    VerifyButton.Size = UDim2.new(1, 0, 0, 45)
    VerifyButton.Position = UDim2.new(0, 0, 0, 255)
    VerifyButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    VerifyButton.BackgroundTransparency = 0.3
    VerifyButton.BorderSizePixel = 0
    VerifyButton.Text = ""
    VerifyButton.AutoButtonColor = false
    VerifyButton.Parent = Container
    
    local VerifyCorner = Instance.new("UICorner")
    VerifyCorner.CornerRadius = UDim.new(0, 8)
    VerifyCorner.Parent = VerifyButton
    
    local VerifyIcon = Instance.new("TextLabel")
    VerifyIcon.Size = UDim2.new(0, 30, 1, 0)
    VerifyIcon.Position = UDim2.new(0, 15, 0, 0)
    VerifyIcon.BackgroundTransparency = 1
    VerifyIcon.Text = "✅"
    VerifyIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    VerifyIcon.TextSize = 18
    VerifyIcon.Parent = VerifyButton
    
    local VerifyText = Instance.new("TextLabel")
    VerifyText.Size = UDim2.new(1, -60, 1, 0)
    VerifyText.Position = UDim2.new(0, 50, 0, 0)
    VerifyText.BackgroundTransparency = 1
    VerifyText.Text = "Verify Key"
    VerifyText.TextColor3 = Color3.fromRGB(255, 255, 255)
    VerifyText.TextSize = 14
    VerifyText.Font = Enum.Font.Gotham
    VerifyText.TextXAlignment = Enum.TextXAlignment.Left
    VerifyText.Parent = VerifyButton
    
    local VerifyArrow = Instance.new("TextLabel")
    VerifyArrow.Size = UDim2.new(0, 30, 1, 0)
    VerifyArrow.Position = UDim2.new(1, -30, 0, 0)
    VerifyArrow.BackgroundTransparency = 1
    VerifyArrow.Text = "›"
    VerifyArrow.TextColor3 = Color3.fromRGB(150, 150, 150)
    VerifyArrow.TextSize = 24
    VerifyArrow.Font = Enum.Font.GothamBold
    VerifyArrow.Parent = VerifyButton
    
    VerifyButton.MouseEnter:Connect(function()
        TweenService:Create(VerifyButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
    end)
    
    VerifyButton.MouseLeave:Connect(function()
        TweenService:Create(VerifyButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
    end)
    
    VerifyButton.MouseButton1Click:Connect(function()
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
                CreateSidebarButton(gameConfig.name, gameConfig.icon, 60 + (i * 55), function()
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
    Container.Size = UDim2.new(1, -40, 1, -40)
    Container.Position = UDim2.new(0, 20, 0, 20)
    Container.BackgroundTransparency = 1
    Container.Parent = ContentArea
    
    -- Title
    local PageTitle = Instance.new("TextLabel")
    PageTitle.Size = UDim2.new(1, 0, 0, 40)
    PageTitle.BackgroundTransparency = 1
    PageTitle.Text = gameConfig.icon .. " " .. gameConfig.name
    PageTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    PageTitle.TextSize = 24
    PageTitle.Font = Enum.Font.GothamBold
    PageTitle.TextXAlignment = Enum.TextXAlignment.Left
    PageTitle.Parent = Container
    
    -- Description
    local Description = Instance.new("TextLabel")
    Description.Size = UDim2.new(1, 0, 0, 60)
    Description.Position = UDim2.new(0, 0, 0, 50)
    Description.BackgroundTransparency = 1
    Description.Text = "Script is ready to be activated.\nClick the button below to start."
    Description.TextColor3 = Color3.fromRGB(180, 180, 180)
    Description.TextSize = 13
    Description.Font = Enum.Font.Gotham
    Description.TextXAlignment = Enum.TextXAlignment.Left
    Description.TextYAlignment = Enum.TextYAlignment.Top
    Description.TextWrapped = true
    Description.Parent = Container
    
    -- Activate Button
    local ActivateButton = Instance.new("TextButton")
    ActivateButton.Size = UDim2.new(1, 0, 0, 50)
    ActivateButton.Position = UDim2.new(0, 0, 0, 130)
    ActivateButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    ActivateButton.BackgroundTransparency = 0.2
    ActivateButton.BorderSizePixel = 0
    ActivateButton.Text = ""
    ActivateButton.AutoButtonColor = false
    ActivateButton.Parent = Container
    
    local ActivateCorner = Instance.new("UICorner")
    ActivateCorner.CornerRadius = UDim.new(0, 10)
    ActivateCorner.Parent = ActivateButton
    
    local ActivateText = Instance.new("TextLabel")
    ActivateText.Size = UDim2.new(1, 0, 1, 0)
    ActivateText.BackgroundTransparency = 1
    ActivateText.Text = "🚀 Activate Script"
    ActivateText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActivateText.TextSize = 16
    ActivateText.Font = Enum.Font.GothamBold
    ActivateText.Parent = ActivateButton
    
    ActivateButton.MouseEnter:Connect(function()
        TweenService:Create(ActivateButton, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    
    ActivateButton.MouseLeave:Connect(function()
        TweenService:Create(ActivateButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
    end)
    
    ActivateButton.MouseButton1Click:Connect(function()
        ShowNotification("⏳ Loading...", "Please wait...", 2)
        
        task.wait(0.5)
        
        local success, err = pcall(function()
            local scriptCode = game:HttpGet(gameConfig.script_url, true)
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
    InfoBox.Size = UDim2.new(1, 0, 0, 100)
    InfoBox.Position = UDim2.new(0, 0, 0, 200)
    InfoBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    InfoBox.BackgroundTransparency = 0.5
    InfoBox.BorderSizePixel = 0
    InfoBox.Parent = Container
    
    local InfoBoxCorner = Instance.new("UICorner")
    InfoBoxCorner.CornerRadius = UDim.new(0, 10)
    InfoBoxCorner.Parent = InfoBox
    
    local InfoTitle = Instance.new("TextLabel")
    InfoTitle.Size = UDim2.new(1, -20, 0, 25)
    InfoTitle.Position = UDim2.new(0, 10, 0, 10)
    InfoTitle.BackgroundTransparency = 1
    InfoTitle.Text = "ℹ️ Script Info"
    InfoTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    InfoTitle.TextSize = 14
    InfoTitle.Font = Enum.Font.GothamBold
    InfoTitle.TextXAlignment = Enum.TextXAlignment.Left
    InfoTitle.Parent = InfoBox
    
    local InfoText = Instance.new("TextLabel")
    InfoText.Size = UDim2.new(1, -20, 0, 55)
    InfoText.Position = UDim2.new(0, 10, 0, 35)
    InfoText.BackgroundTransparency = 1
    InfoText.Text = "✅ Auto Collect Cash\n✅ Auto Rebirth\n✅ Auto Steal & more!"
    InfoText.TextColor3 = Color3.fromRGB(200, 200, 200)
    InfoText.TextSize = 12
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

warn("[Aether Hub] ✅ Loaded successfully!")
