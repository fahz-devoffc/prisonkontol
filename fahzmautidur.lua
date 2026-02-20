--[[
    Deobfuscated by Lisa (Just-Lisa)
    Original: Advanced Aimbot & ESP System with GUI
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Teams = game:GetService("Teams")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Drawing check
local DrawingAvailable = false
pcall(function()
    if Drawing and Drawing.new then
        local test = Drawing.new("Circle")
        test.Visible = false
        test:Remove()
        DrawingAvailable = true
    end
end)

if not DrawingAvailable then
    Drawing = {
        new = function()
            return {
                Visible = false,
                Color = Color3.new(1,1,1),
                Thickness = 1,
                Transparency = 1,
                Filled = false,
                Position = Vector2.new(0,0),
                From = Vector2.new(0,0),
                To = Vector2.new(0,0),
                Radius = 0,
                Remove = function() end
            }
        end
    }
end

-- File system paths
local ConfigFolder = "JustLisaConfigs"
local DefaultConfigPath = ConfigFolder .. "/defaultConfig.cfg"

-- Settings defaults
local Settings = {
    FOV = 100,
    Enabled = true,
    TeamCheck = true,
    WallCheck = true,
    Smoothness = 0,
    TargetPart = "Head",
    UseTeamAim = false,
    TeamAimSettings = {},
    
    ESPTracers = false,
    ESPNames = false,
    ESPChams = false,
    ESPTeamCheck = true,
    ESPRange = 1000,
    ESPStuds = false,
    UseTeamColors = true,
    TeamESPSettings = {},
    
    MiniGUIVisible = false
}

-- Color scheme
local Colors = {
    bg = Color3.fromRGB(15,15,25),
    element = Color3.fromRGB(25,25,40),
    accent1 = Color3.fromRGB(0,255,255),
    accent2 = Color3.fromRGB(180,0,255),
    text = Color3.fromRGB(240,240,255),
    success = Color3.fromRGB(50,255,100),
    off = Color3.fromRGB(255,50,80)
}

-- Notification function
local function Notify(title, message, duration)
    -- GUI notification implementation
    print("[" .. title .. "] " .. message)
end

Notify("System", "Loaded successfully", 7)

-- Main GUI
local GUI = Instance.new("ScreenGui")
GUI.Name = "JustLisaAimbotGUI"
GUI.ResetOnSpawn = false
GUI.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Draggable function
local function MakeDraggable(frame, dragArea)
    local dragging, dragStart, startPos
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            local connection
            connection = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Main window
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0,250,0,380)
MainFrame.Position = UDim2.new(0.5,-125,0.5,-190)
MainFrame.BackgroundColor3 = Colors.bg
MainFrame.Active = true
MainFrame.Visible = Settings.Enabled
MainFrame.Parent = GUI

-- Rounded corners
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,12)
Instance.new("UIStroke", MainFrame).Color = Colors.accent1

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(0,100,0,35)
TitleBar.Position = UDim2.new(0.1,0,0.15,0)
TitleBar.BackgroundColor3 = Colors.bg
TitleBar.Parent = GUI

Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", TitleBar).Color = Colors.accent2

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1,0,1,0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "LisaAI"
TitleText.TextColor3 = Colors.accent1
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 14
TitleText.Parent = TitleBar

-- Minimize button
local MinimizeBtn = Instance.new("Frame")
MinimizeBtn.Size = UDim2.new(0,120,0,40)
MinimizeBtn.Position = UDim2.new(0.8,0,0.2,0)
MinimizeBtn.BackgroundColor3 = Colors.bg
MinimizeBtn.Visible = Settings.MiniGUIVisible
MinimizeBtn.Parent = GUI

Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", MinimizeBtn).Color = Colors.accent1

local MinimizeInner = Instance.new("Frame")
MinimizeInner.Size = UDim2.new(1,-6,1,-6)
MinimizeInner.Position = UDim2.new(0,3,0,3)
MinimizeInner.BackgroundColor3 = Settings.Enabled and Colors.accent2 or Colors.element
MinimizeInner.Text = "MINI"
MinimizeInner.TextColor3 = Colors.text
MinimizeInner.Font = Enum.Font.GothamBold
MinimizeInner.TextSize = 14
MinimizeInner.Parent = MinimizeBtn

Instance.new("UICorner", MinimizeInner).CornerRadius = UDim.new(0,6)

-- Make GUI elements draggable
MakeDraggable(TitleBar, TitleText)
MakeDraggable(MainFrame, MainFrame)
MakeDraggable(MinimizeBtn, MinimizeInner)

-- Tab buttons
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1,-20,0,40)
TabContainer.Position = UDim2.new(0,10,0,10)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local function CreateTabButton(name, position)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.33,-3,1,0)
    btn.Position = position
    btn.BackgroundColor3 = Colors.element
    btn.Text = name
    btn.TextColor3 = Colors.text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = TabContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    return btn
end

local TabAimbot = CreateTabButton("Aimbot", UDim2.new(0,0,0,0))
TabAimbot.BackgroundColor3 = Colors.accent2
local TabESP = CreateTabButton("ESP", UDim2.new(0.33,3,0,0))
local TabConfig = CreateTabButton("Config", UDim2.new(0.66,6,0,0))

-- Tab content frames
local AimbotTab = Instance.new("ScrollingFrame")
AimbotTab.Size = UDim2.new(1,0,1,-60)
AimbotTab.Position = UDim2.new(0,0,0,60)
AimbotTab.BackgroundTransparency = 1
AimbotTab.CanvasSize = UDim2.new(0,0,0,600)
AimbotTab.ScrollBarThickness = 2
AimbotTab.Parent = MainFrame

local ESPTab = Instance.new("ScrollingFrame")
ESPTab.Size = UDim2.new(1,0,1,-60)
ESPTab.Position = UDim2.new(0,0,0,60)
ESPTab.BackgroundTransparency = 1
ESPTab.Visible = false
ESPTab.CanvasSize = UDim2.new(0,0,0,650)
ESPTab.ScrollBarThickness = 2
ESPTab.Parent = MainFrame

local ConfigTab = Instance.new("ScrollingFrame")
ConfigTab.Size = UDim2.new(1,0,1,-60)
ConfigTab.Position = UDim2.new(0,0,0,60)
ConfigTab.BackgroundTransparency = 1
ConfigTab.Visible = false
ConfigTab.CanvasSize = UDim2.new(0,0,0,450)
ConfigTab.ScrollBarThickness = 2
ConfigTab.Parent = MainFrame

-- Tab switching
TabAimbot.MouseButton1Click:Connect(function()
    AimbotTab.Visible = true
    ESPTab.Visible = false
    ConfigTab.Visible = false
    TabAimbot.BackgroundColor3 = Colors.accent2
    TabESP.BackgroundColor3 = Colors.element
    TabConfig.BackgroundColor3 = Colors.element
end)

TabESP.MouseButton1Click:Connect(function()
    AimbotTab.Visible = false
    ESPTab.Visible = true
    ConfigTab.Visible = false
    TabAimbot.BackgroundColor3 = Colors.element
    TabESP.BackgroundColor3 = Colors.accent2
    TabConfig.BackgroundColor3 = Colors.element
end)

TabConfig.MouseButton1Click:Connect(function()
    AimbotTab.Visible = false
    ESPTab.Visible = false
    ConfigTab.Visible = true
    TabAimbot.BackgroundColor3 = Colors.element
    TabESP.BackgroundColor3 = Colors.element
    TabConfig.BackgroundColor3 = Colors.accent2
end)

-- Helper function to create buttons
local function CreateButton(parent, text, position, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-20,0,35)
    btn.Position = position
    btn.Text = text
    btn.BackgroundColor3 = color or Colors.element
    btn.TextColor3 = Colors.text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    return btn
end

-- Aimbot tab elements
local ToggleBtn
local function UpdateToggle(value)
    Settings.Enabled = value
    if ToggleBtn then
        ToggleBtn.Text = (Settings.Enabled and "Enabled" or "Disabled")
        ToggleBtn.BackgroundColor3 = Settings.Enabled and Colors.accent2 or Colors.element
    end
    MinimizeInner.BackgroundColor3 = Settings.Enabled and Colors.accent2 or Colors.element
end

ToggleBtn = CreateButton(AimbotTab, "Enabled", UDim2.new(0,10,0,0), Colors.accent2)
ToggleBtn.MouseButton1Click:Connect(function()
    UpdateToggle(not Settings.Enabled)
end)

local TeamAimBtn = CreateButton(AimbotTab, "Team Check", UDim2.new(0,10,0,45), Colors.element)
TeamAimBtn.MouseButton1Click:Connect(function()
    Settings.TeamCheck = not Settings.TeamCheck
    TeamAimBtn.Text = "Team Check: " .. (Settings.TeamCheck and "On" or "Off")
    TeamAimBtn.BackgroundColor3 = Settings.TeamCheck and Colors.accent1 or Colors.element
    TeamAimBtn.TextColor3 = Settings.TeamCheck and Color3.new(0,0,0) or Colors.text
end)

-- FOV slider
local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(0.6,0,0,35)
FOVLabel.Position = UDim2.new(0,10,0,90)
FOVLabel.PlaceholderText = "FOV"
FOVLabel.Text = tostring(Settings.FOV)
FOVLabel.BackgroundColor3 = Colors.element
FOVLabel.TextColor3 = Colors.text
FOVLabel.Font = Enum.Font.GothamBold
FOVLabel.TextSize = 14
FOVLabel.Parent = AimbotTab
Instance.new("UICorner", FOVLabel).CornerRadius = UDim.new(0,8)

local FOVSetBtn = Instance.new("TextButton")
FOVSetBtn.Size = UDim2.new(0.35,-10,0,35)
FOVSetBtn.Position = UDim2.new(0.65,0,0,90)
FOVSetBtn.Text = "Set"
FOVSetBtn.BackgroundColor3 = Colors.accent1
FOVSetBtn.TextColor3 = Color3.new(0,0,0)
FOVSetBtn.Font = Enum.Font.GothamBold
FOVSetBtn.TextSize = 14
FOVSetBtn.Parent = AimbotTab
Instance.new("UICorner", FOVSetBtn).CornerRadius = UDim.new(0,8)

FOVSetBtn.MouseButton1Click:Connect(function()
    local val = tonumber(FOVLabel.Text)
    if val then
        Settings.FOV = val
    end
end)

-- Smoothness slider
local SmoothLabel = Instance.new("TextLabel")
SmoothLabel.Size = UDim2.new(1,-20,0,20)
SmoothLabel.Position = UDim2.new(0,10,0,135)
SmoothLabel.Text = "Smoothness: " .. Settings.Smoothness .. (Settings.Smoothness == 0 and " (Off)" or "")
SmoothLabel.TextColor3 = Colors.text
SmoothLabel.Font = Enum.Font.GothamBold
SmoothLabel.TextSize = 14
SmoothLabel.BackgroundTransparency = 1
SmoothLabel.TextXAlignment = Enum.TextXAlignment.Left
SmoothLabel.Parent = AimbotTab

local SmoothBar = Instance.new("Frame")
SmoothBar.Size = UDim2.new(1,-20,0,8)
SmoothBar.Position = UDim2.new(0,10,0,160)
SmoothBar.BackgroundColor3 = Colors.element
SmoothBar.Parent = AimbotTab
Instance.new("UICorner", SmoothBar).CornerRadius = UDim.new(0,4)

local SmoothFill = Instance.new("Frame")
SmoothFill.Size = UDim2.new(0,0,1,0)
SmoothFill.BackgroundColor3 = Colors.accent2
SmoothFill.Parent = SmoothBar
Instance.new("UICorner", SmoothFill).CornerRadius = UDim.new(0,4)

local SmoothButton = Instance.new("TextButton")
SmoothButton.Size = UDim2.new(1,0,1,0)
SmoothButton.BackgroundTransparency = 1
SmoothButton.Text = ""
SmoothButton.Parent = SmoothBar

local draggingSmooth = false
SmoothButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSmooth = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSmooth = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSmooth and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mouseX = UserInputService:GetMouseLocation().X
        local barX = mouseX - SmoothBar.AbsolutePosition.X
        local percent = math.clamp(barX / SmoothBar.AbsoluteSize.X, 0, 1)
        SmoothFill.Size = UDim2.new(percent,0,1,0)
        Settings.Smoothness = math.floor(percent * 10)
        SmoothLabel.Text = "Smoothness: " .. Settings.Smoothness .. (Settings.Smoothness == 0 and " (Off)" or "")
    end
end)

-- Target part selector
local PartBtn = CreateButton(AimbotTab, "Target Part: Head", UDim2.new(0,10,0,180), Colors.element)
local PartsList = {"Head", "Torso", "HumanoidRootPart"}
local CurrentPartIndex = 1
PartBtn.MouseButton1Click:Connect(function()
    CurrentPartIndex = (CurrentPartIndex % #PartsList) + 1
    Settings.TargetPart = PartsList[CurrentPartIndex]
    PartBtn.Text = "Target Part: " .. Settings.TargetPart
end)

-- Wall check toggle
local WallCheckBtn = CreateButton(AimbotTab, "Wall Check: On", UDim2.new(0,10,0,225), Colors.element)
WallCheckBtn.TextColor3 = Colors.success
WallCheckBtn.MouseButton1Click:Connect(function()
    Settings.WallCheck = not Settings.WallCheck
    WallCheckBtn.Text = "Wall Check: " .. (Settings.WallCheck and "On" or "Off")
    WallCheckBtn.TextColor3 = Settings.WallCheck and Colors.success or Colors.off
end)

-- Team aim toggle
local TeamAimToggle = CreateButton(AimbotTab, "Team Aim: Off", UDim2.new(0,10,0,270), Colors.element)
TeamAimToggle.TextColor3 = Colors.success
TeamAimToggle.MouseButton1Click:Connect(function()
    Settings.UseTeamAim = not Settings.UseTeamAim
    TeamAimToggle.Text = "Team Aim: " .. (Settings.UseTeamAim and "On" or "Off")
    TeamAimToggle.TextColor3 = Settings.UseTeamAim and Colors.success or Colors.off
end)

-- Team selection area
local TeamAimLabel = Instance.new("TextLabel")
TeamAimLabel.Size = UDim2.new(0.65,-20,0,25)
TeamAimLabel.Position = UDim2.new(0,10,0,315)
TeamAimLabel.Text = "Teams to target:"
TeamAimLabel.TextColor3 = Colors.accent2
TeamAimLabel.Font = Enum.Font.GothamBold
TeamAimLabel.TextSize = 12
TeamAimLabel.BackgroundTransparency = 1
TeamAimLabel.TextXAlignment = Enum.TextXAlignment.Left
TeamAimLabel.Parent = AimbotTab

local TeamSelectAll = Instance.new("TextButton")
TeamSelectAll.Size = UDim2.new(0,40,0,25)
TeamSelectAll.Position = UDim2.new(0,155,0,315)
TeamSelectAll.BackgroundColor3 = Settings.UseTeamAim and Colors.success or Colors.off
TeamSelectAll.Text = Settings.UseTeamAim and "On" or "Off"
TeamSelectAll.TextColor3 = Color3.new(1,1,1)
TeamSelectAll.Font = Enum.Font.GothamBold
TeamSelectAll.TextSize = 12
TeamSelectAll.Parent = AimbotTab
Instance.new("UICorner", TeamSelectAll).CornerRadius = UDim.new(0,4)
Instance.new("UIStroke", TeamSelectAll).Color = Color3.new(0,0,0)

TeamSelectAll.MouseButton1Click:Connect(function()
    Settings.UseTeamAim = not Settings.UseTeamAim
    TeamSelectAll.BackgroundColor3 = Settings.UseTeamAim and Colors.success or Colors.off
    TeamSelectAll.Text = Settings.UseTeamAim and "On" or "Off"
end)

-- Team list container
local TeamList = Instance.new("Frame")
TeamList.Size = UDim2.new(1,-20,0,200)
TeamList.Position = UDim2.new(0,10,0,345)
TeamList.BackgroundTransparency = 1
TeamList.Parent = AimbotTab
Instance.new("UIListLayout", TeamList).Padding = UDim.new(0,5)

local function UpdateTeamList()
    for _, child in pairs(TeamList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    for _, team in pairs(Teams:GetTeams()) do
        local teamName = team.Name
        if Settings.TeamAimSettings[teamName] == nil then
            Settings.TeamAimSettings[teamName] = true
        end
        
        local teamBtn = Instance.new("TextButton")
        teamBtn.Size = UDim2.new(1,0,0,32)
        teamBtn.Text = teamName .. ": " .. (Settings.TeamAimSettings[teamName] and "On" or "Off")
        teamBtn.BackgroundColor3 = Settings.TeamAimSettings[teamName] and Colors.element or Colors.bg
        teamBtn.TextColor3 = Settings.TeamAimSettings[teamName] and team.TeamColor.Color or Color3.fromRGB(150,150,150)
        teamBtn.Font = Enum.Font.GothamBold
        teamBtn.TextSize = 13
        teamBtn.Parent = TeamList
        Instance.new("UICorner", teamBtn).CornerRadius = UDim.new(0,6)
        Instance.new("UIPadding", teamBtn).PaddingLeft = UDim.new(0,10)
        
        teamBtn.MouseButton1Click:Connect(function()
            Settings.TeamAimSettings[teamName] = not Settings.TeamAimSettings[teamName]
            teamBtn.Text = teamName .. ": " .. (Settings.TeamAimSettings[teamName] and "On" or "Off")
            teamBtn.BackgroundColor3 = Settings.TeamAimSettings[teamName] and Colors.element or Colors.bg
            teamBtn.TextColor3 = Settings.TeamAimSettings[teamName] and team.TeamColor.Color or Color3.fromRGB(150,150,150)
        end)
    end
end

-- ESP tab elements
local TracersBtn = CreateButton(ESPTab, "Tracers: Off", UDim2.new(0,10,0,10), Colors.element)
TracersBtn.MouseButton1Click:Connect(function()
    Settings.ESPTracers = not Settings.ESPTracers
    TracersBtn.Text = "Tracers: " .. (Settings.ESPTracers and "On" or "Off")
    TracersBtn.BackgroundColor3 = Settings.ESPTracers and Colors.accent1 or Colors.element
    TracersBtn.TextColor3 = Settings.ESPTracers and Color3.new(0,0,0) or Colors.text
end)

local NamesBtn = CreateButton(ESPTab, "Names: Off", UDim2.new(0,10,0,55), Colors.element)
NamesBtn.MouseButton1Click:Connect(function()
    Settings.ESPNames = not Settings.ESPNames
    NamesBtn.Text = "Names: " .. (Settings.ESPNames and "On" or "Off")
    NamesBtn.BackgroundColor3 = Settings.ESPNames and Colors.accent1 or Colors.element
    NamesBtn.TextColor3 = Settings.ESPNames and Color3.new(0,0,0) or Colors.text
end)

local ChamsBtn = CreateButton(ESPTab, "Chams: Off", UDim2.new(0,10,0,100), Colors.element)
ChamsBtn.MouseButton1Click:Connect(function()
    Settings.ESPChams = not Settings.ESPChams
    ChamsBtn.Text = "Chams: " .. (Settings.ESPChams and "On" or "Off")
    ChamsBtn.BackgroundColor3 = Settings.ESPChams and Colors.accent1 or Colors.element
    ChamsBtn.TextColor3 = Settings.ESPChams and Color3.new(0,0,0) or Colors.text
end)

local ESPTeamBtn = CreateButton(ESPTab, "Team Check: On", UDim2.new(0,10,0,145), Colors.element)
ESPTeamBtn.MouseButton1Click:Connect(function()
    Settings.ESPTeamCheck = not Settings.ESPTeamCheck
    ESPTeamBtn.Text = "Team Check: " .. (Settings.ESPTeamCheck and "On" or "Off")
    ESPTeamBtn.BackgroundColor3 = Settings.ESPTeamCheck and Colors.accent1 or Colors.element
    ESPTeamBtn.TextColor3 = Settings.ESPTeamCheck and Color3.new(0,0,0) or Colors.text
end)

local ESPStudsBtn = CreateButton(ESPTab, "Show Distance: Off", UDim2.new(0,10,0,190), Colors.element)
ESPStudsBtn.TextColor3 = Colors.success
ESPStudsBtn.MouseButton1Click:Connect(function()
    Settings.ESPStuds = not Settings.ESPStuds
    ESPStudsBtn.Text = "Show Distance: " .. (Settings.ESPStuds and "On" or "Off")
    ESPStudsBtn.TextColor3 = Settings.ESPStuds and Colors.success or Colors.off
end)

-- ESP Range slider
local ESPRangeLabel = Instance.new("TextLabel")
ESPRangeLabel.Size = UDim2.new(1,-20,0,20)
ESPRangeLabel.Position = UDim2.new(0,10,0,230)
ESPRangeLabel.Text = "ESP Range: " .. Settings.ESPRange
ESPRangeLabel.TextColor3 = Colors.text
ESPRangeLabel.Font = Enum.Font.GothamBold
ESPRangeLabel.TextSize = 14
ESPRangeLabel.BackgroundTransparency = 1
ESPRangeLabel.TextXAlignment = Enum.TextXAlignment.Left
ESPRangeLabel.Parent = ESPTab

local ESPRangeValue = Instance.new("TextButton")
ESPRangeValue.Size = UDim2.new(0.3,0,0,25)
ESPRangeValue.Position = UDim2.new(0.65,0,0,230)
ESPRangeValue.Text = tostring(Settings.ESPRange)
ESPRangeValue.BackgroundColor3 = Colors.element
ESPRangeValue.TextColor3 = Colors.text
ESPRangeValue.Font = Enum.Font.GothamBold
ESPRangeValue.TextSize = 12
ESPRangeValue.Parent = ESPTab
Instance.new("UICorner", ESPRangeValue).CornerRadius = UDim.new(0,4)

local ESPRangeBar = Instance.new("Frame")
ESPRangeBar.Size = UDim2.new(1,-20,0,8)
ESPRangeBar.Position = UDim2.new(0,10,0,255)
ESPRangeBar.BackgroundColor3 = Colors.element
ESPRangeBar.Parent = ESPTab
Instance.new("UICorner", ESPRangeBar).CornerRadius = UDim.new(0,4)

local ESPRangeFill = Instance.new("Frame")
ESPRangeFill.Size = UDim2.new(Settings.ESPRange/10000,0,1,0)
ESPRangeFill.BackgroundColor3 = Colors.accent1
ESPRangeFill.Parent = ESPRangeBar
Instance.new("UICorner", ESPRangeFill).CornerRadius = UDim.new(0,4)

local ESPRangeButton = Instance.new("TextButton")
ESPRangeButton.Size = UDim2.new(1,0,1,0)
ESPRangeButton.BackgroundTransparency = 1
ESPRangeButton.Text = ""
ESPRangeButton.Parent = ESPRangeBar

local function UpdateESPRange(value)
    Settings.ESPRange = math.clamp(math.floor(value), 0, 10000)
    ESPRangeLabel.Text = "ESP Range: " .. Settings.ESPRange
    ESPRangeValue.Text = tostring(Settings.ESPRange)
    ESPRangeFill.Size = UDim2.new(Settings.ESPRange/10000,0,1,0)
end

ESPRangeValue.FocusLost:Connect(function()
    local val = tonumber(ESPRangeValue.Text)
    if val then
        UpdateESPRange(val)
    else
        ESPRangeValue.Text = tostring(Settings.ESPRange)
    end
end)

local draggingESPRange = false
ESPRangeButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingESPRange = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingESPRange = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingESPRange and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mouseX = UserInputService:GetMouseLocation().X
        local barX = mouseX - ESPRangeBar.AbsolutePosition.X
        local percent = math.clamp(barX / ESPRangeBar.AbsoluteSize.X, 0, 1)
        UpdateESPRange(percent * 10000)
    end
end)

-- Team colors toggle
local TeamColorsBtn = Instance.new("TextButton")
TeamColorsBtn.Size = UDim2.new(0.65,-20,0,25)
TeamColorsBtn.Position = UDim2.new(0,10,0,280)
TeamColorsBtn.Text = "Use Team Colors:"
TeamColorsBtn.TextColor3 = Colors.accent2
TeamColorsBtn.Font = Enum.Font.GothamBold
TeamColorsBtn.TextSize = 12
TeamColorsBtn.BackgroundTransparency = 1
TeamColorsBtn.TextXAlignment = Enum.TextXAlignment.Left
TeamColorsBtn.Parent = ESPTab

local TeamColorsToggle = Instance.new("TextButton")
TeamColorsToggle.Size = UDim2.new(0,40,0,25)
TeamColorsToggle.Position = UDim2.new(0,130,0,280)
TeamColorsToggle.BackgroundColor3 = Settings.UseTeamColors and Colors.success or Colors.off
TeamColorsToggle.Text = Settings.UseTeamColors and "On" or "Off"
TeamColorsToggle.TextColor3 = Color3.new(1,1,1)
TeamColorsToggle.Font = Enum.Font.GothamBold
TeamColorsToggle.TextSize = 12
TeamColorsToggle.Parent = ESPTab
Instance.new("UICorner", TeamColorsToggle).CornerRadius = UDim.new(0,4)
Instance.new("UIStroke", TeamColorsToggle).Color = Color3.new(0,0,0)

TeamColorsToggle.MouseButton1Click:Connect(function()
    Settings.UseTeamColors = not Settings.UseTeamColors
    TeamColorsToggle.BackgroundColor3 = Settings.UseTeamColors and Colors.success or Colors.off
    TeamColorsToggle.Text = Settings.UseTeamColors and "On" or "Off"
end)

-- Team ESP list
local TeamESPList = Instance.new("Frame")
TeamESPList.Size = UDim2.new(1,-20,0,200)
TeamESPList.Position = UDim2.new(0,10,0,310)
TeamESPList.BackgroundTransparency = 1
TeamESPList.Parent = ESPTab
Instance.new("UIListLayout", TeamESPList).Padding = UDim.new(0,5)

local function UpdateTeamESPList()
    for _, child in pairs(TeamESPList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    for _, team in pairs(Teams:GetTeams()) do
        local teamName = team.Name
        if Settings.TeamESPSettings[teamName] == nil then
            Settings.TeamESPSettings[teamName] = true
        end
        
        local teamBtn = Instance.new("TextButton")
        teamBtn.Size = UDim2.new(1,0,0,32)
        teamBtn.Text = teamName .. ": " .. (Settings.TeamESPSettings[teamName] and "On" or "Off")
        teamBtn.BackgroundColor3 = Settings.TeamESPSettings[teamName] and Colors.element or Colors.bg
        teamBtn.TextColor3 = Settings.TeamESPSettings[teamName] and team.TeamColor.Color or Color3.fromRGB(150,150,150)
        teamBtn.Font = Enum.Font.GothamBold
        teamBtn.TextSize = 13
        teamBtn.Parent = TeamESPList
        Instance.new("UICorner", teamBtn).CornerRadius = UDim.new(0,6)
        Instance.new("UIPadding", teamBtn).PaddingLeft = UDim.new(0,10)
        
        teamBtn.MouseButton1Click:Connect(function()
            Settings.TeamESPSettings[teamName] = not Settings.TeamESPSettings[teamName]
            teamBtn.Text = teamName .. ": " .. (Settings.TeamESPSettings[teamName] and "On" or "Off")
            teamBtn.BackgroundColor3 = Settings.TeamESPSettings[teamName] and Colors.element or Colors.bg
            teamBtn.TextColor3 = Settings.TeamESPSettings[teamName] and team.TeamColor.Color or Color3.fromRGB(150,150,150)
        end)
    end
end

-- Update lists when teams change
Teams.ChildAdded:Connect(function()
    UpdateTeamESPList()
    UpdateTeamList()
end)

Teams.ChildRemoved:Connect(function()
    UpdateTeamESPList()
    UpdateTeamList()
end)

UpdateTeamESPList()
UpdateTeamList()

-- Update all UI elements
local function UpdateAllUI()
    UpdateToggle(Settings.Enabled)
    TeamAimBtn.Text = "Team Check: " .. (Settings.TeamCheck and "On" or "Off")
    TeamAimBtn.BackgroundColor3 = Settings.TeamCheck and Colors.accent1 or Colors.element
    TeamAimBtn.TextColor3 = Settings.TeamCheck and Color3.new(0,0,0) or Colors.text
    MinimizeBtn.Visible = Settings.MiniGUIVisible
    
    FOVLabel.Text = tostring(Settings.FOV)
    SmoothFill.Size = UDim2.new(Settings.Smoothness/10,0,1,0)
    SmoothLabel.Text = "Smoothness: " .. Settings.Smoothness .. (Settings.Smoothness == 0 and " (Off)" or "")
    PartBtn.Text = "Target Part: " .. Settings.TargetPart
    
    WallCheckBtn.Text = "Wall Check: " .. (Settings.WallCheck and "On" or "Off")
    WallCheckBtn.TextColor3 = Settings.WallCheck and Colors.success or Colors.off
    
    TeamAimToggle.Text = "Team Aim: " .. (Settings.UseTeamAim and "On" or "Off")
    TeamAimToggle.TextColor3 = Settings.UseTeamAim and Colors.success or Colors.off
    
    TeamSelectAll.Text = Settings.UseTeamAim and "On" or "Off"
    TeamSelectAll.BackgroundColor3 = Settings.UseTeamAim and Colors.success or Colors.off
    UpdateTeamList()
    
    TracersBtn.Text = "Tracers: " .. (Settings.ESPTracers and "On" or "Off")
    TracersBtn.BackgroundColor3 = Settings.ESPTracers and Colors.accent1 or Colors.element
    TracersBtn.TextColor3 = Settings.ESPTracers and Color3.new(0,0,0) or Colors.text
    
    NamesBtn.Text = "Names: " .. (Settings.ESPNames and "On" or "Off")
    NamesBtn.BackgroundColor3 = Settings.ESPNames and Colors.accent1 or Colors.element
    NamesBtn.TextColor3 = Settings.ESPNames and Color3.new(0,0,0) or Colors.text
    
    ChamsBtn.Text = "Chams: " .. (Settings.ESPChams and "On" or "Off")
    ChamsBtn.BackgroundColor3 = Settings.ESPChams and Colors.accent1 or Colors.element
    ChamsBtn.TextColor3 = Settings.ESPChams and Color3.new(0,0,0) or Colors.text
    
    ESPTeamBtn.Text = "Team Check: " .. (Settings.ESPTeamCheck and "On" or "Off")
    ESPTeamBtn.BackgroundColor3 = Settings.ESPTeamCheck and Colors.accent1 or Colors.element
    ESPTeamBtn.TextColor3 = Settings.ESPTeamCheck and Color3.new(0,0,0) or Colors.text
    
    ESPStudsBtn.Text = "Show Distance: " .. (Settings.ESPStuds and "On" or "Off")
    ESPStudsBtn.TextColor3 = Settings.ESPStuds and Colors.success or Colors.off
    
    UpdateESPRange(Settings.ESPRange)
    
    TeamColorsToggle.Text = Settings.UseTeamColors and "On" or "Off"
    TeamColorsToggle.BackgroundColor3 = Settings.UseTeamColors and Colors.success or Colors.off
    UpdateTeamESPList()
end

-- Config tab elements
local ConfigFileName = nil
local ConfigInput = Instance.new("TextBox")
ConfigInput.Size = UDim2.new(0.65,0,0,35)
ConfigInput.Position = UDim2.new(0,10,0,10)
ConfigInput.PlaceholderText = "Config name"
ConfigInput.Text = ""
ConfigInput.BackgroundColor3 = Colors.element
ConfigInput.TextColor3 = Colors.text
ConfigInput.Font = Enum.Font.GothamBold
ConfigInput.TextSize = 14
ConfigInput.Parent = ConfigTab
Instance.new("UICorner", ConfigInput).CornerRadius = UDim.new(0,8)

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0.3,-5,0,35)
SaveBtn.Position = UDim2.new(0.7,0,0,10)
SaveBtn.Text = "Save"
SaveBtn.BackgroundColor3 = Colors.accent1
SaveBtn.TextColor3 = Color3.new(0,0,0)
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.TextSize = 14
SaveBtn.Parent = ConfigTab
Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0,8)

local ConfigListBtn = Instance.new("TextButton")
ConfigListBtn.Size = UDim2.new(1,-20,0,30)
ConfigListBtn.Position = UDim2.new(0,10,0,55)
ConfigListBtn.Text = "▼ Load Config ▼"
ConfigListBtn.BackgroundColor3 = Colors.element
ConfigListBtn.TextColor3 = Colors.text
ConfigListBtn.Font = Enum.Font.Gotham
ConfigListBtn.TextSize = 14
ConfigListBtn.TextXAlignment = Enum.TextXAlignment.Left
ConfigListBtn.Parent = ConfigTab
Instance.new("UICorner", ConfigListBtn).CornerRadius = UDim.new(0,8)

local ConfigList = Instance.new("Frame")
ConfigList.Size = UDim2.new(1,-20,0,0)
ConfigList.Position = UDim2.new(0,10,0,90)
ConfigList.BackgroundColor3 = Colors.bg
ConfigList.BorderSizePixel = 0
ConfigList.Visible = false
ConfigList.Parent = ConfigTab
Instance.new("UIListLayout", ConfigList).Padding = UDim.new(0,2)

local listVisible = false
ConfigListBtn.MouseButton1Click:Connect(function()
    listVisible = not listVisible
    ConfigListBtn.Text = (listVisible and "▲ Hide Configs ▲" or "▼ Load Config ▼")
    ConfigList.Size = (listVisible and UDim2.new(1,-20,0,100) or UDim2.new(1,-20,0,0))
    ConfigList.Visible = listVisible
end)

local function RefreshConfigList()
    -- File system functions check
    local function hasFileSystem()
        return writefile and readfile and isfolder and makefolder and listfiles
    end
    
    if not hasFileSystem() then return end
    
    for _, child in pairs(ConfigList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local files = listfiles(ConfigFolder)
    for _, file in pairs(files) do
        local filename = file:match("([^/\\]+)$"):gsub(".json$", "")
        if filename ~= "defaultConfig" then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,0,0,25)
            btn.Text = filename
            btn.BackgroundColor3 = Colors.element
            btn.TextColor3 = Colors.text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 12
            btn.Parent = ConfigList
            btn.MouseButton1Click:Connect(function()
                ConfigFileName = filename
                ConfigInput.Text = filename
                for _, b in pairs(ConfigList:GetChildren()) do
                    if b:IsA("TextButton") then
                        b.TextColor3 = Colors.text
                    end
                end
                btn.TextColor3 = Colors.accent1
                listVisible = false
                ConfigListBtn.Text = "▼ Load Config ▼"
                ConfigList.Visible = false
                ConfigList.Size = UDim2.new(1,-20,0,0)
            end)
        end
    end
end

local function SaveConfig(name)
    if not hasFileSystem() then return end
    
    local data = {
        fov = Settings.FOV,
        enabled = Settings.Enabled,
        smoothness = Settings.Smoothness,
        targetPartName = Settings.TargetPart,
        aimTeamCheck = Settings.TeamCheck,
        wallCheckEnabled = Settings.WallCheck,
        useTeamAim = Settings.UseTeamAim,
        teamAimSettings = Settings.TeamAimSettings,
        espTracers = Settings.ESPTracers,
        espNames = Settings.ESPNames,
        espChams = Settings.ESPChams,
        espTeamCheck = Settings.ESPTeamCheck,
        miniGuiVisible = Settings.MiniGUIVisible,
        useTeamColors = Settings.UseTeamColors,
        espStuds = Settings.ESPStuds,
        teamEspSettings = Settings.TeamESPSettings,
        espRange = Settings.ESPRange
    }
    
    writefile(ConfigFolder .. "/" .. name .. ".json", HttpService:JSONEncode(data))
    RefreshConfigList()
    Notify("Saved", name, 3)
end

local function LoadConfig(name)
    if not hasFileSystem() then return end
    
    local path = ConfigFolder .. "/" .. name .. ".json"
    if isfile(path) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        if not success then return end
        
        Settings.FOV = data.fov or 100
        Settings.Enabled = data.enabled
        Settings.Smoothness = data.smoothness or 0
        Settings.TargetPart = data.targetPartName or "Head"
        Settings.TeamCheck = data.aimTeamCheck
        Settings.WallCheck = data.wallCheckEnabled
        Settings.UseTeamAim = data.useTeamAim or false
        if data.teamAimSettings then Settings.TeamAimSettings = data.teamAimSettings end
        Settings.ESPTracers = data.espTracers
        Settings.ESPNames = data.espNames
        Settings.ESPChams = data.espChams
        Settings.ESPTeamCheck = data.espTeamCheck
        Settings.MiniGUIVisible = data.miniGuiVisible or false
        Settings.UseTeamColors = data.useTeamColors or false
        Settings.ESPStuds = data.espStuds or false
        UpdateESPRange(data.espRange or 1000)
        if data.teamEspSettings then Settings.TeamESPSettings = data.teamEspSettings end
        
        UpdateAllUI()
        Notify("Loaded", name, 3)
    end
end

SaveBtn.MouseButton1Click:Connect(function()
    if ConfigInput.Text ~= "" then
        SaveConfig(ConfigInput.Text)
    end
end)

CreateButton(ConfigTab, "Load Selected", UDim2.new(0,10,0,185), Colors.accent2).MouseButton1Click:Connect(function()
    if ConfigFileName then
        LoadConfig(ConfigFileName)
    end
end)

CreateButton(ConfigTab, "Save As (Overwrite)", UDim2.new(0,10,0,225), Colors.element).MouseButton1Click:Connect(function()
    if ConfigFileName then
        SaveConfig(ConfigFileName)
    end
end)

local AutoLoadLabel = Instance.new("TextLabel")
AutoLoadLabel.Size = UDim2.new(1,-20,0,20)
AutoLoadLabel.Position = UDim2.new(0,10,0,310)
AutoLoadLabel.Text = "Auto-load config (in defaultConfig.cfg)"
AutoLoadLabel.TextColor3 = Colors.text
AutoLoadLabel.Font = Enum.Font.Gotham
AutoLoadLabel.TextSize = 12
AutoLoadLabel.BackgroundTransparency = 1
AutoLoadLabel.Parent = ConfigTab

CreateButton(ConfigTab, "Set Auto-load", UDim2.new(0,10,0,265), Colors.element).MouseButton1Click:Connect(function()
    if ConfigFileName and hasFileSystem() then
        writefile(DefaultConfigPath, ConfigFileName)
        AutoLoadLabel.Text = "Auto-load set to: " .. ConfigFileName
        AutoLoadLabel.TextColor3 = Colors.success
    end
end)

CreateButton(ConfigTab, "Clear Auto-load", UDim2.new(0,10,0,335), Colors.element).MouseButton1Click:Connect(function()
    if hasFileSystem() and isfile(DefaultConfigPath) then
        pcall(function() if delfile then delfile(DefaultConfigPath) end end)
        AutoLoadLabel.Text = "Auto-load config (in defaultConfig.cfg)"
        AutoLoadLabel.TextColor3 = Colors.text
    end
end)

CreateButton(ConfigTab, "Delete Config", UDim2.new(0,10,0,375), Colors.off).MouseButton1Click:Connect(function()
    if ConfigFileName and hasFileSystem() then
        local path = ConfigFolder .. "/" .. ConfigFileName .. ".json"
        if isfile(path) then
            pcall(function() if delfile then delfile(path) end end)
            ConfigFileName = nil
            ConfigInput.Text = ""
            RefreshConfigList()
            Notify("Deleted", "Config removed", 3)
        end
    end
end)

-- Auto-load on startup
if hasFileSystem() then
    RefreshConfigList()
    if isfile(DefaultConfigPath) then
        local autoName = readfile(DefaultConfigPath)
        if isfile(ConfigFolder .. "/" .. autoName .. ".json") then
            AutoLoadLabel.Text = "Auto-load: " .. autoName
            AutoLoadLabel.TextColor3 = Colors.success
            ConfigFileName = autoName
            ConfigInput.Text = autoName
            LoadConfig(autoName)
        end
    end
end

-- Toggle main window
TitleText.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    MainFrame.Visible = Settings.Enabled
    UpdateToggle(Settings.Enabled)
end)

MinimizeInner.MouseButton1Click:Connect(function()
    UpdateToggle(not Settings.Enabled)
end)

-- Drawing objects
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Thickness = 2
FOVCircle.Color = Colors.accent2
FOVCircle.Filled = false
FOVCircle.Radius = Settings.FOV

-- ESP storage
local ESPObjects = {}

-- ESP Highlight function
local function AddESPHighlight(character, color)
    local highlight = character:FindFirstChild("ESPHighlight") or Instance.new("Highlight", character)
    highlight.Name = "ESPHighlight"
    highlight.FillColor = color
    highlight.OutlineColor = Color3.new(1,1,1)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
end

-- ESP NameTag function
local function AddESPNameTag(character, name, color, distance)
    local head = character:FindFirstChild("Head")
    if not head then return end
    
    local tag = head:FindFirstChild("ESPNameTag") or Instance.new("BillboardGui", head)
    tag.Name = "ESPNameTag"
    tag.AlwaysOnTop = true
    tag.Size = UDim2.new(0,200,0,50)
    tag.StudsOffset = Vector3.new(0,3,0)
    
    local text = tag:FindFirstChild("TextLabel") or Instance.new("TextLabel", tag)
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    
    local displayText = ""
    if Settings.ESPNames then
        displayText = name .. " "
    end
    if Settings.ESPStuds and distance then
        displayText = displayText .. "[" .. math.floor(distance) .. "m]"
    end
    
    text.Text = displayText
    text.TextColor3 = color
    text.Font = Enum.Font.GothamBold
    text.TextSize = 14
    text.TextStrokeTransparency = 0.5
end

-- Wall check function
local function IsVisible(part)
    if not Settings.WallCheck then return true end
    
    local origin = Camera.CFrame.Position
    local direction = part.Position - origin
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Exclude
    
    local result = workspace:Raycast(origin, direction, params)
    return result and result.Instance:IsDescendantOf(part.Parent)
end

-- Get closest player function
local function GetClosestPlayer()
    local target, closestDist = nil, math.huge
    local center = Camera.ViewportSize / 2
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end
            
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            if Settings.UseTeamAim then
                local teamName = player.Team and player.Team.Name
                if teamName and Settings.TeamAimSettings[teamName] == false then
                    continue
                end
            end
            
            local part = player.Character:FindFirstChild(Settings.TargetPart)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < closestDist and dist < Settings.FOV and IsVisible(part) then
                        closestDist = dist
                        target = part
                    end
                end
            end
        end
    end
    return target
end

-- Main render loop
RunService.RenderStepped:Connect(function()
    -- Update FOV circle
    if DrawingAvailable then
        FOVCircle.Position = Camera.ViewportSize / 2
        FOVCircle.Radius = Settings.FOV
        FOVCircle.Visible = Settings.Enabled
    end
    
    -- Aimbot logic
    if Settings.Enabled then
        local target = GetClosestPlayer()
        if target then
            if Settings.Smoothness == 0 then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            else
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), 1/(Settings.Smoothness * 2))
            end
        end
    end
    
    -- ESP logic
    for _, player in ipairs(Players:GetPlayers()) do
        if not ESPObjects[player] then
            ESPObjects[player] = {Line = Drawing.new("Line")}
        end
        
        local showESP = false
        local character = player.Character
        local distance = 0
        
        if player ~= LocalPlayer and character and character:FindFirstChild("Humanoid") then
            distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) or 0
            
            local alive = character:FindFirstChild("Humanoid") and (character.Humanoid.Health > 0)
            local sameTeam = player.Team == LocalPlayer.Team
            
            if alive and (distance <= Settings.ESPRange) then
                showESP = true
                if Settings.ESPTeamCheck and sameTeam then
                    showESP = false
                end
                
                local teamName = player.Team and player.Team.Name
                if teamName and Settings.TeamESPSettings[teamName] == false then
                    showESP = false
                end
            end
        end
        
        if showESP then
            local espColor = (Settings.UseTeamColors and player.TeamColor.Color) or Colors.accent1
            local espLine = ESPObjects[player].Line
            
            -- Tracers
            if Settings.ESPTracers and DrawingAvailable then
                local screenPos, onScreen = Camera:WorldToViewportPoint(character.HumanoidRootPart.Position)
                if onScreen then
                    espLine.Visible = true
                    espLine.Thickness = 1.5
                    espLine.Color = espColor
                    espLine.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    espLine.To = Vector2.new(screenPos.X, screenPos.Y)
                else
                    espLine.Visible = false
                end
            else
                espLine.Visible = false
            end
            
            -- Chams
            if Settings.ESPChams then
                AddESPHighlight(character, (Settings.UseTeamColors and player.TeamColor.Color) or Colors.accent2)
            elseif character:FindFirstChild("ESPHighlight") then
                character.ESPHighlight:Destroy()
            end
            
            -- Names/Distance
            if Settings.ESPNames or Settings.ESPStuds then
                AddESPNameTag(character, player.Name, espColor, distance)
            elseif character:FindFirstChild("Head") and character.Head:FindFirstChild("ESPNameTag") then
                character.Head.ESPNameTag:Destroy()
            end
        else
            if ESPObjects[player].Line then
                ESPObjects[player].Line.Visible = false
            end
            if player.Character then
                if player.Character:FindFirstChild("ESPHighlight") then
                    player.Character.ESPHighlight:Destroy()
                end
                if player.Character:FindFirstChild("Head") and player.Character.Head:FindFirstChild("ESPNameTag") then
                    player.Character.Head.ESPNameTag:Destroy()
                end
            end
        end
    end
end)

-- Cleanup when players leave
Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        pcall(function() ESPObjects[player].Line:Remove() end)
        ESPObjects[player] = nil
    end
end)

print("JustLisa: Script fully deobfuscated. System Ready.")
