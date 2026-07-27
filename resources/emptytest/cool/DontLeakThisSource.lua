-- ============================================================
-- BR Hub | JailBird Edition – v2.9.3 (Tag added)
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().SpinBotSettings = { Enabled = false, Mode = "Spin" }
getgenv().AimbotSettings = {
    Enabled = false,
    Smoothness = 1,
    TargetPart = "Head",
    TeamCheck = false,
    FOV = 100,
    ShowFOV = false,
    VisibleOnly = false,
    RainbowFOV = false,
    FOVTransparency = 0.8,
    FOVColor = Color3.fromRGB(255, 0, 100)
}
getgenv().EspSettings = {
    Boxes = false,
    Tracers = false,
    Skeleton = false,
    Name = false,
    Health = false,
    Tool = false,
    Rainbow = false,
    LineThickness = 2,
    EnemyColor = Color3.fromRGB(255, 50, 50),
    TeammateColor = Color3.fromRGB(50, 150, 255)
}
getgenv().HitboxSettings = { Enabled = false, Size = 4, WallCheck = false }
getgenv().WalkSpeedValue = 16
getgenv().TPWalkSpeed = 0
getgenv().CameraFOVEnabled = false
getgenv().CameraFOVValue = 70
getgenv().RandomHighPingEnabled = false
getgenv().SpinAroundEnabled = false
getgenv().JumpscareDelay = 0.1
getgenv().TeleportKillEnabled = false

local Connections = {
    Spin = nil, Noclip = nil, Backstab = nil, InfiniteAmmo = nil,
    TPWalk = nil, InfJump = nil, Esp = nil, Chams = nil,
    CameraFOV = nil, PingChanger = nil, SpinAround = nil, LeanSpammer = nil,
    AutoPing = nil, TeleportKill = nil
}

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local customThemes = {
    { Name = "Obsidian", Accent = Color3.fromHex("#1a1a1a"), Background = Color3.fromHex("#0d0d0d"), Outline = Color3.fromHex("#404040"), Text = Color3.fromHex("#e0e0e0"), Placeholder = Color3.fromHex("#6b6b6b"), Button = Color3.fromHex("#2b2b2b"), Icon = Color3.fromHex("#9e9e9e") },
    { Name = "Crimson", Accent = Color3.fromHex("#2d1111"), Background = Color3.fromHex("#1a0a0a"), Outline = Color3.fromHex("#ff4444"), Text = Color3.fromHex("#ffffff"), Placeholder = Color3.fromHex("#8b5e5e"), Button = Color3.fromHex("#4a2020"), Icon = Color3.fromHex("#ff6666") },
    { Name = "Ocean", Accent = Color3.fromHex("#0b1a2a"), Background = Color3.fromHex("#050d14"), Outline = Color3.fromHex("#3a8fd4"), Text = Color3.fromHex("#e6f0ff"), Placeholder = Color3.fromHex("#5b7a9e"), Button = Color3.fromHex("#1a2e42"), Icon = Color3.fromHex("#5aa9e6") },
    { Name = "Sunset", Accent = Color3.fromHex("#2a1a1a"), Background = Color3.fromHex("#140a0a"), Outline = Color3.fromHex("#ff8c42"), Text = Color3.fromHex("#ffe0cc"), Placeholder = Color3.fromHex("#8c6242"), Button = Color3.fromHex("#3d2626"), Icon = Color3.fromHex("#ffb380") },
    { Name = "Forest", Accent = Color3.fromHex("#1a2e1a"), Background = Color3.fromHex("#0d1a0d"), Outline = Color3.fromHex("#4caf50"), Text = Color3.fromHex("#e0ffe0"), Placeholder = Color3.fromHex("#5e8c5e"), Button = Color3.fromHex("#2b472b"), Icon = Color3.fromHex("#81c784") },
}
for _, theme in ipairs(customThemes) do WindUI:AddTheme(theme) end
WindUI:SetTheme("Ocean")

local Window = WindUI:CreateWindow({
    Title = "BR Hub | JailBird",
    Icon = "shield",
    Author = "by i41p on discord",
    Folder = "BR_Hub"
})

Window:EditOpenButton({
    Title = "BR Hub | Jailbird",
    Icon = "terminal",
    CornerRadius = UDim.new(0, 12),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("FF0F7B"), Color3.fromHex("F89B29")),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

Window:Tag({
    Title = "v2.9.3",
    Icon = "github",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 3,
})

local ConfigManager = Window.ConfigManager
local currentConfig = ConfigManager:CreateConfig("DefaultConfig")

local function ReadThemeFile()
    if isfile and isfolder and readfile then
        if isfolder("BR_Hub") and isfile("BR_Hub/theme.txt") then
            return readfile("BR_Hub/theme.txt")
        end
    end
    return nil
end
local savedTheme = ReadThemeFile()
if savedTheme then pcall(function() WindUI:SetTheme(savedTheme) end) else WindUI:SetTheme("Ocean") end

local function IsVisible(targetPart)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    rayParams.IgnoreWater = true
    local origin = Camera.CFrame.Position
    local dir = targetPart.Position - origin
    local result = workspace:Raycast(origin, dir, rayParams)
    return result == nil
end

local function GetClosestPlayer()
    local target = nil
    local shortest = math.huge
    local settings = getgenv().AimbotSettings
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local aimPart = plr.Character:FindFirstChild(settings.TargetPart)
            if not hrp or not aimPart then continue end
            if settings.TeamCheck and LocalPlayer.Team and plr.Team == LocalPlayer.Team then continue end
            if settings.VisibleOnly and not IsVisible(aimPart) then continue end
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                if dist <= settings.FOV and dist < shortest then target = plr; shortest = dist end
            end
        end
    end
    return target
end

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local fovGui = Instance.new("ScreenGui")
fovGui.Name = "FOVCircle"
fovGui.IgnoreGuiInset = true
fovGui.Parent = playerGui

local fovFrame = Instance.new("Frame")
fovFrame.Name = "Circle"
fovFrame.Size = UDim2.new(0, 200, 0, 200)
fovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovFrame.BackgroundTransparency = 1
fovFrame.BorderSizePixel = 0
fovFrame.Parent = fovGui

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = getgenv().AimbotSettings.FOVColor or Color3.fromRGB(255, 0, 100)
fovStroke.Thickness = 1.5
fovStroke.Transparency = 0.8
fovStroke.Parent = fovFrame

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovFrame
fovFrame.Visible = getgenv().AimbotSettings.ShowFOV

local function UpdateFOVCircle(radius)
    fovFrame.Size = UDim2.new(0, radius * 2, 0, radius * 2)
end
UpdateFOVCircle(getgenv().AimbotSettings.FOV)

RunService.Heartbeat:Connect(function()
    local aimSettings = getgenv().AimbotSettings
    local hitSettings = getgenv().HitboxSettings
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if head and hrp then
                local inFov = false
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude; inFov = dist <= aimSettings.FOV end
                local wallOk = true
                if hitSettings.WallCheck then wallOk = IsVisible(hrp) end
                if hitSettings.Enabled and inFov and wallOk then
                    local sz = Vector3.new(hitSettings.Size, hitSettings.Size, hitSettings.Size)
                    head.Size = sz; head.CanCollide = false
                    hrp.Size = sz; hrp.CanCollide = false
                else
                    head.Size = Vector3.new(2, 1, 1); head.CanCollide = true
                    hrp.Size = Vector3.new(2, 2, 1); hrp.CanCollide = true
                end
            end
        end
    end
    if aimSettings.Enabled then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(aimSettings.TargetPart) then
            local targetPos = target.Character[aimSettings.TargetPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), 1 / aimSettings.Smoothness)
        end
    end
    if aimSettings.RainbowFOV and fovFrame.Visible then
        local hue = (tick() * 0.5) % 1
        fovStroke.Color = Color3.fromHSV(hue, 1, 1)
    end
end)

-- ESP system (tracers from screen bottom)
local espGui = Instance.new("ScreenGui")
espGui.Name = "ESP_Gui"
espGui.ResetOnSpawn = false
espGui.IgnoreGuiInset = true
espGui.Parent = playerGui

local espObjects = {}
local function clearESP()
    for _, obj in pairs(espObjects) do if obj and obj.Parent then obj:Destroy() end end
    espObjects = {}
end

local function createLine2D(from, to, color)
    local thickness = getgenv().EspSettings.LineThickness or 2
    if thickness < 1 then thickness = 1 end
    local length = (to - from).Magnitude
    if length < 1 then return nil end
    local angle = math.atan2(to.Y - from.Y, to.X - from.X)
    local mid = (from + to) / 2
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, length, 0, thickness)
    frame.Position = UDim2.new(0, mid.X - length/2, 0, mid.Y - thickness/2)
    frame.BackgroundColor3 = color
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.Rotation = math.deg(angle)
    frame.Parent = espGui
    return frame
end

local function drawBoxESP(plr, color)
    local char = plr.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    local headPos, headOn = Camera:WorldToViewportPoint(head.Position)
    if not headOn then return end
    local headScreen = Vector2.new(headPos.X, headPos.Y)
    local boxWidth = 60
    local boxHeight = 80
    local topLeft = Vector2.new(headScreen.X - boxWidth/2, headScreen.Y - boxHeight/2)
    local topRight = Vector2.new(headScreen.X + boxWidth/2, headScreen.Y - boxHeight/2)
    local bottomLeft = Vector2.new(headScreen.X - boxWidth/2, headScreen.Y + boxHeight/2)
    local bottomRight = Vector2.new(headScreen.X + boxWidth/2, headScreen.Y + boxHeight/2)
    local function drawBoxLine(p1, p2)
        local line = createLine2D(p1, p2, color)
        if line then table.insert(espObjects, line) end
    end
    drawBoxLine(topLeft, topRight)
    drawBoxLine(topRight, bottomRight)
    drawBoxLine(bottomRight, bottomLeft)
    drawBoxLine(bottomLeft, topLeft)
end

local function createText(text, position, color, size, center)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.TextColor3 = color
    label.TextScaled = false
    label.TextSize = size or 14
    label.Font = Enum.Font.GothamBold
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.Size = UDim2.new(0, 200, 0, 30)
    label.Position = UDim2.new(0, position.X - 100, 0, position.Y - 15)
    label.TextXAlignment = center and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = espGui
    return label
end

local function updateESP()
    local espSettings = getgenv().EspSettings
    if not (espSettings.Boxes or espSettings.Skeleton or espSettings.Tracers or espSettings.Name or espSettings.Health or espSettings.Tool) then
        clearESP(); return
    end
    clearESP()
    local rainbowColor
    if espSettings.Rainbow then rainbowColor = Color3.fromHSV((tick() * 0.2) % 1, 1, 1) end

    local tracerStart = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or not plr.Character then continue end
        local char = plr.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local torso = char:FindFirstChild("Torso")
        local leftArm = char:FindFirstChild("Left Arm")
        local rightArm = char:FindFirstChild("Right Arm")
        local leftLeg = char:FindFirstChild("Left Leg")
        local rightLeg = char:FindFirstChild("Right Leg")
        local humanoid = char:FindFirstChildOfClass("Humanoid")

        local enemyColor = espSettings.EnemyColor or Color3.fromRGB(255, 50, 50)
        local teamColor = espSettings.TeammateColor or Color3.fromRGB(50, 150, 255)
        local isTeam = LocalPlayer.Team and plr.Team and plr.Team == LocalPlayer.Team
        local baseColor = isTeam and teamColor or enemyColor
        local displayColor = espSettings.Rainbow and rainbowColor or baseColor

        if espSettings.Boxes then drawBoxESP(plr, displayColor) end
        if espSettings.Skeleton and torso and head and leftArm and rightArm and leftLeg and rightLeg then
            local function worldToScreen(pos)
                local vec, on = Camera:WorldToViewportPoint(pos)
                if on then return Vector2.new(vec.X, vec.Y), true end
                return nil, false
            end
            local function drawLine3D(fromW, toW, col)
                local f2, fOn = worldToScreen(fromW)
                local t2, tOn = worldToScreen(toW)
                if fOn and tOn then
                    local line = createLine2D(f2, t2, col)
                    if line then table.insert(espObjects, line) end
                end
            end
            drawLine3D(torso.Position, head.Position, displayColor)
            drawLine3D(torso.Position, leftArm.Position, displayColor)
            drawLine3D(torso.Position, rightArm.Position, displayColor)
            local lFoot = leftLeg.CFrame * Vector3.new(0, -leftLeg.Size.Y/2, 0)
            local rFoot = rightLeg.CFrame * Vector3.new(0, -rightLeg.Size.Y/2, 0)
            drawLine3D(torso.Position, lFoot, displayColor)
            drawLine3D(torso.Position, rFoot, displayColor)
        end
        if espSettings.Tracers and hrp then
            local toP, on = Camera:WorldToViewportPoint(hrp.Position)
            if on then
                local line = createLine2D(tracerStart, Vector2.new(toP.X, toP.Y), displayColor)
                if line then table.insert(espObjects, line) end
            end
        end
        if (espSettings.Name or espSettings.Health or espSettings.Tool) and head then
            local headP, on = Camera:WorldToViewportPoint(head.Position)
            if on then
                local base = Vector2.new(headP.X, headP.Y)
                local y = base.Y - 40
                local offset = 0
                if espSettings.Name and plr.Name then
                    local label = createText(plr.Name, Vector2.new(base.X, y - offset), displayColor, 14, true)
                    if label then table.insert(espObjects, label) end
                    offset = offset + 20
                end
                if espSettings.Health and humanoid then
                    local hp = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                    local hpColor = espSettings.Rainbow and rainbowColor or Color3.fromRGB(255 - hp*2.55, hp*2.55, 0)
                    local label = createText(hp.."%", Vector2.new(base.X, y - offset), hpColor, 12, true)
                    if label then table.insert(espObjects, label) end
                    offset = offset + 18
                end
                if espSettings.Tool then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        local label = createText("["..tool.Name.."]", Vector2.new(base.X, y - offset), displayColor, 11, true)
                        if label then table.insert(espObjects, label) end
                    end
                end
            end
        end
    end
end
RunService.Heartbeat:Connect(updateESP)

LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
end)

local uiVisible = true
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightControl then
        uiVisible = not uiVisible
        pcall(function() Window.Main.Visible = uiVisible end)
    end
end)

-- TABS with icons
local InfoTab = Window:Tab({ Title = "Info", Icon = "home" })
InfoTab:Button({ Title = "Welcome to BR Hub", Desc = "Current Version: v2.9.3", Icon = "lucide:info", Callback = function() end })
InfoTab:Divider()
InfoTab:Button({ Title = "Changelog", Desc = "✓ Icons added\n✓ Teleport Kill multi-target\n✓ Tracers from bottom\n✓ No cooldown auto kill\n✓ All previous features", Icon = "lucide:file-text", Callback = function() end })
InfoTab:Divider()
InfoTab:Button({ Title = "Script Credits", Desc = "Lead Developer: goth\nUI Framework: WindUI", Icon = "lucide:user", Callback = function() end })

local MoveTab = Window:Tab({ Title = "Movement", Icon = "user" })
local movSec1 = MoveTab:Section({ Title = "Speed Settings" })
local walkSpeedSlider = movSec1:Slider({ Title = "WalkSpeed", Desc = "Movement speed (max 50)", Step = 1, Flag = "WalkSpeed", Value = { Min = 16, Max = 50, Default = 16 }, Icon = "lucide:sliders-horizontal", Callback = function(value) getgenv().WalkSpeedValue = value; local hum = (LocalPlayer.Character or {}):FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = value end end })
currentConfig:Register("WalkSpeed", walkSpeedSlider)
local tpWalkSpeedSlider = movSec1:Slider({ Title = "TP Walk Speed", Desc = "Multiplier for TP Walk (0-20)", Step = 1, Flag = "TPWalkSpeed", Value = { Min = 0, Max = 20, Default = 0 }, Icon = "lucide:sliders-horizontal", Callback = function(value) getgenv().TPWalkSpeed = value end })
currentConfig:Register("TPWalkSpeed", tpWalkSpeedSlider)

local movSec2 = MoveTab:Section({ Title = "Movement Options" })
local infJumpToggle = movSec2:Toggle({ Title = "Infinite Jump", Desc = "Jump continuously", Icon = "lucide:zap", Flag = "InfiniteJump", Callback = function(state) if state then Connections.InfJump = UserInputService.JumpRequest:Connect(function() local char = LocalPlayer.Character; if char and char:FindFirstChild("Humanoid") then char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end) else if Connections.InfJump then Connections.InfJump:Disconnect(); Connections.InfJump = nil end end end })
currentConfig:Register("InfiniteJump", infJumpToggle)
local noclipToggle = movSec2:Toggle({ Title = "Noclip", Desc = "Walk through walls", Icon = "lucide:shield-off", Flag = "Noclip", Callback = function(state) if state then Connections.Noclip = RunService.Stepped:Connect(function() local char = LocalPlayer.Character; if char then for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end) else if Connections.Noclip then Connections.Noclip:Disconnect(); Connections.Noclip = nil end end end })
currentConfig:Register("Noclip", noclipToggle)
local tpWalkToggle = movSec2:Toggle({ Title = "TP Walk", Desc = "Teleport forward", Icon = "lucide:zap", Flag = "TPWalk", Callback = function(state) if state then if Connections.TPWalk then Connections.TPWalk:Disconnect() end; Connections.TPWalk = RunService.Heartbeat:Connect(function(dt) if not getgenv().TPWalkEnabled then return end; local char = LocalPlayer.Character; if not char then return end; local hum = char:FindFirstChildOfClass("Humanoid"); local root = char:FindFirstChild("HumanoidRootPart"); if not hum or not root then return end; local dir = hum.MoveDirection; if dir.Magnitude > 0.1 then local speed = getgenv().TPWalkSpeed or 0; root.CFrame = root.CFrame + (dir * speed * dt) end end); getgenv().TPWalkEnabled = true else if Connections.TPWalk then Connections.TPWalk:Disconnect(); Connections.TPWalk = nil end; getgenv().TPWalkEnabled = false end end })
currentConfig:Register("TPWalk", tpWalkToggle)

local AimTab = Window:Tab({ Title = "Aim", Icon = "crosshair" })
local aimSec1 = AimTab:Section({ Title = "Aimbot Settings" })
local aimbotToggle = aimSec1:Toggle({ Title = "Aimbot (Camera Lock)", Desc = "Locks camera onto nearest enemy", Icon = "lucide:eye", Flag = "Aimbot", Callback = function(v) getgenv().AimbotSettings.Enabled = v end })
currentConfig:Register("Aimbot", aimbotToggle)
local teamCheckToggle = aimSec1:Toggle({ Title = "Team Check", Desc = "Ignore teammates", Icon = "lucide:users", Flag = "TeamCheck", Callback = function(v) getgenv().AimbotSettings.TeamCheck = v end })
currentConfig:Register("TeamCheck", teamCheckToggle)
local visibleOnlyToggle = aimSec1:Toggle({ Title = "Visible Only", Desc = "Only lock if visible", Icon = "lucide:eye", Flag = "VisibleOnly", Callback = function(v) getgenv().AimbotSettings.VisibleOnly = v end })
currentConfig:Register("VisibleOnly", visibleOnlyToggle)
local smoothnessSlider = aimSec1:Slider({ Title = "Smoothness", Desc = "Lower = faster (1=instant)", Step = 1, Flag = "Smoothness", Value = { Min = 1, Max = 10, Default = 1 }, Icon = "lucide:sliders-horizontal", Callback = function(v) getgenv().AimbotSettings.Smoothness = v end })
currentConfig:Register("Smoothness", smoothnessSlider)

local aimSec2 = AimTab:Section({ Title = "FOV Circle" })
local showFOVToggle = aimSec2:Toggle({ Title = "Show FOV Circle", Desc = "Show aimbot FOV", Icon = "lucide:eye", Flag = "ShowFOV", Callback = function(v) getgenv().AimbotSettings.ShowFOV = v; fovFrame.Visible = v end })
currentConfig:Register("ShowFOV", showFOVToggle)
local fovRadiusSlider = aimSec2:Slider({ Title = "FOV Radius", Desc = "Radius in pixels", Step = 10, Flag = "FOVRadius", Value = { Min = 30, Max = 600, Default = 100 }, Icon = "lucide:sliders-horizontal", Callback = function(v) getgenv().AimbotSettings.FOV = v; UpdateFOVCircle(v) end })
currentConfig:Register("FOVRadius", fovRadiusSlider)
local fovThicknessSlider = aimSec2:Slider({ Title = "FOV Thickness", Desc = "Outline thickness", Step = 0.5, Flag = "FOVThickness", Value = { Min = 0.5, Max = 5, Default = 1.5 }, Icon = "lucide:sliders-horizontal", Callback = function(v) fovStroke.Thickness = v end })
currentConfig:Register("FOVThickness", fovThicknessSlider)
local fovTransparencySlider = aimSec2:Slider({ Title = "FOV Transparency", Desc = "0=solid, 1=invisible", Step = 0.05, Flag = "FOVTransparency", Value = { Min = 0, Max = 1, Default = 0.8 }, Icon = "lucide:eye", Callback = function(v) fovStroke.Transparency = v; getgenv().AimbotSettings.FOVTransparency = v end })
currentConfig:Register("FOVTransparency", fovTransparencySlider)
local rainbowFOVToggle = aimSec2:Toggle({ Title = "Rainbow FOV", Desc = "Cycle colors", Icon = "lucide:star", Flag = "RainbowFOV", Callback = function(v) getgenv().AimbotSettings.RainbowFOV = v; if not v then fovStroke.Color = getgenv().AimbotSettings.FOVColor or Color3.fromRGB(255,0,100) end end })
currentConfig:Register("RainbowFOV", rainbowFOVToggle)
local fovColorpicker = aimSec2:Colorpicker({ Title = "FOV Color", Desc = "Pick a custom color", Icon = "lucide:pencil", Flag = "FOVColor", Value = getgenv().AimbotSettings.FOVColor or Color3.fromRGB(255,0,100), Callback = function(color) getgenv().AimbotSettings.FOVColor = color; if not getgenv().AimbotSettings.RainbowFOV then fovStroke.Color = color end end })
currentConfig:Register("FOVColor", fovColorpicker)

local aimSec3 = AimTab:Section({ Title = "Hitbox Expander" })
local hitboxToggle = aimSec3:Toggle({ Title = "Head Hitbox Size Changer", Desc = "Enlarge head hitbox", Icon = "lucide:plus", Flag = "HitboxEnabled", Callback = function(v) getgenv().HitboxSettings.Enabled = v end })
currentConfig:Register("HitboxEnabled", hitboxToggle)
local hitboxSizeSlider = aimSec3:Slider({ Title = "Hitbox Size", Desc = "Size (2-15)", Step = 1, Flag = "HitboxSize", Value = { Min = 2, Max = 15, Default = 6 }, Icon = "lucide:sliders-horizontal", Callback = function(v) getgenv().HitboxSettings.Size = v end })
currentConfig:Register("HitboxSize", hitboxSizeSlider)
local hitboxWallCheckToggle = aimSec3:Toggle({ Title = "Hitbox Wall Check", Desc = "Only expand if not behind wall", Icon = "lucide:eye-off", Flag = "HitboxWallCheck", Callback = function(v) getgenv().HitboxSettings.WallCheck = v end })
currentConfig:Register("HitboxWallCheck", hitboxWallCheckToggle)

local AntiAimTab = Window:Tab({ Title = "Anti Aim", Icon = "shield-off" })
local aaSec1 = AntiAimTab:Section({ Title = "Spin Bot" })
local function StartSpinBot()
    if Connections.Spin then Connections.Spin:Disconnect() end
    local currentAngle = 0
    Connections.Spin = RunService.Heartbeat:Connect(function()
        if getgenv().SpinBotSettings.Enabled then
            local char = LocalPlayer.Character; if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid"); local root = char:FindFirstChild("HumanoidRootPart")
            if not root or not hum then return end
            hum.AutoRotate = false
            if getgenv().SpinBotSettings.Mode == "Spin" then
                currentAngle = (currentAngle + 160) % 360
                root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(currentAngle), 0)
            elseif getgenv().SpinBotSettings.Mode == "MoonWalk" then
                local camDir = Camera.CFrame.LookVector; local horiz = Vector3.new(camDir.X, 0, camDir.Z).Unit
                if horiz.Magnitude < 0.001 then horiz = Vector3.new(0,0,-1) end
                root.CFrame = CFrame.lookAt(root.Position, root.Position - horiz)
            end
        end
    end)
end
local spinBotToggle = aaSec1:Toggle({ Title = "Spin Bot", Desc = "Continuously rotate", Icon = "lucide:refresh-cw", Flag = "SpinBotEnabled", Callback = function(state) getgenv().SpinBotSettings.Enabled = state; if state then StartSpinBot() else if Connections.Spin then Connections.Spin:Disconnect(); Connections.Spin = nil end; local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.AutoRotate = true end end end })
currentConfig:Register("SpinBotEnabled", spinBotToggle)
local spinModeDropdown = aaSec1:Dropdown({ Title = "SpinBot Mode", Desc = "Select rotation style", Flag = "SpinBotMode", Values = { { Title = "Spin", Desc = "Fast yaw spin", Icon = "lucide:refresh-cw", Callback = function() getgenv().SpinBotSettings.Mode = "Spin"; if getgenv().SpinBotSettings.Enabled then StartSpinBot() end end }, { Title = "MoonWalk", Desc = "Face opposite camera", Icon = "lucide:arrow-left-right", Callback = function() getgenv().SpinBotSettings.Mode = "MoonWalk"; if getgenv().SpinBotSettings.Enabled then StartSpinBot() end end } } })
currentConfig:Register("SpinBotMode", spinModeDropdown)

local aaSec2 = AntiAimTab:Section({ Title = "Lean Spammer" })
local leanSpammerToggle = aaSec2:Toggle({ Title = "Lean Spammer", Desc = "Random lean stances", Icon = "lucide:arrow-left-right", Flag = "LeanSpammer", Callback = function(state) if state then if Connections.LeanSpammer then Connections.LeanSpammer:Disconnect() end; Connections.LeanSpammer = RunService.Heartbeat:Connect(function() local stanceRemote = ReplicatedStorage:FindFirstChild("GameEvents"); if stanceRemote then stanceRemote = stanceRemote:FindFirstChild("Stance") end; if stanceRemote then stanceRemote:FireServer("Standing", math.random(-1,1)) end end) else if Connections.LeanSpammer then Connections.LeanSpammer:Disconnect(); Connections.LeanSpammer = nil end end end })
currentConfig:Register("LeanSpammer", leanSpammerToggle)
local leanSpeedSlider = aaSec2:Slider({ Title = "Lean Speed", Desc = "How frequent (1-20)", Step = 1, Flag = "LeanSpammerSpeed", Value = { Min = 1, Max = 20, Default = 5 }, Icon = "lucide:sliders-horizontal", Callback = function(value) getgenv().LeanSpammerSpeed = value; if Connections.LeanSpammer then Connections.LeanSpammer:Disconnect(); Connections.LeanSpammer = RunService.Heartbeat:Connect(function() local stanceRemote = ReplicatedStorage:FindFirstChild("GameEvents"); if stanceRemote then stanceRemote = stanceRemote:FindFirstChild("Stance") end; if stanceRemote then stanceRemote:FireServer("Standing", math.random(-1,1)) end; task.wait(1/value) end) end end })
currentConfig:Register("LeanSpammerSpeed", leanSpeedSlider)

local ExploitsTab = Window:Tab({ Title = "Exploits", Icon = "zap" })

local expSec1 = ExploitsTab:Section({ Title = "Ping Manipulation" })
local pingChangerToggle = expSec1:Toggle({ Title = "Ping Changer", Desc = "Fake your ping", Icon = "lucide:zap", Flag = "PingChanger", Callback = function(state) if state then if Connections.PingChanger then Connections.PingChanger:Disconnect() end; Connections.PingChanger = RunService.Heartbeat:Connect(function() local latencyValue = getgenv().RandomHighPingEnabled and math.random(500,1000) or (getgenv().PingChangerValue or 0); local eventModule = ReplicatedStorage:FindFirstChild("GameEvents"); if eventModule then local latencyEvent = eventModule:FindFirstChild("Latency"); if latencyEvent then latencyEvent:FireServer(latencyValue) end end end) else if Connections.PingChanger then Connections.PingChanger:Disconnect(); Connections.PingChanger = nil end end end })
currentConfig:Register("PingChanger", pingChangerToggle)
local randomHighPingToggle = expSec1:Toggle({ Title = "Random High Ping", Desc = "Random 500-1000", Icon = "lucide:refresh-cw", Flag = "RandomHighPing", Callback = function(state) getgenv().RandomHighPingEnabled = state end })
currentConfig:Register("RandomHighPing", randomHighPingToggle)
local pingChangerSlider = expSec1:Slider({ Title = "Ping Value", Desc = "Manual value (0-1000)", Step = 1, Flag = "PingChangerValue", Value = { Min = 0, Max = 1000, Default = 0 }, Icon = "lucide:sliders-horizontal", Callback = function(value) getgenv().PingChangerValue = value end })
currentConfig:Register("PingChangerValue", pingChangerSlider)

-- Auto Kill (no cooldown)
local expSec2 = ExploitsTab:Section({ Title = "Auto Kill" })
local function isAlive(character) local hum = character:FindFirstChildOfClass("Humanoid"); return hum and hum.Health > 0 end
local autoKillV1Connection = nil; local autoKillV1Running = false
local function AutoKillV1Loop()
    if not autoKillV1Running then return end
    local localChar = LocalPlayer.Character; if not localChar or not isAlive(localChar) then return end
    local remote = ReplicatedStorage:FindFirstChild("GameEvents"); if remote then remote = remote:FindFirstChild("Damage") end; if not remote then return end
    local origin = Camera.CFrame.Position
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if LocalPlayer.Team and plr.Team and plr.Team == LocalPlayer.Team then continue end
        local char = plr.Character; if not char or not isAlive(char) then continue end
        local head = char:FindFirstChild("Head"); if not head then continue end
        local dir = (head.Position - origin).Unit
        local rayParams = RaycastParams.new(); rayParams.FilterType = Enum.RaycastFilterType.Exclude; rayParams.FilterDescendantsInstances = {localChar}
        local result = workspace:Raycast(origin, dir * 1000, rayParams)
        if result and result.Instance:IsDescendantOf(char) then
            local hitPoint = result.Position; local hitDir = (hitPoint - origin).Unit
            remote:FireServer(plr, 200, "Bayonet", { Normal = -hitDir, Direction = hitDir, StartPosition = origin, Instance = result.Instance, Material = Enum.Material.Plastic, EndPosition = hitPoint })
            break
        end
    end
end
local autoKillV1Toggle = expSec2:Toggle({ Title = "Auto Kill V1 [BETA]", Desc = "Raycast to head (no cooldown)", Icon = "lucide:skull", Flag = "AutoKillV1", Callback = function(state) if state then if autoKillV1Connection then autoKillV1Connection:Disconnect() end; autoKillV1Running = true; autoKillV1Connection = RunService.Heartbeat:Connect(AutoKillV1Loop) else autoKillV1Running = false; if autoKillV1Connection then autoKillV1Connection:Disconnect(); autoKillV1Connection = nil end end end })
currentConfig:Register("AutoKillV1", autoKillV1Toggle)

local autoKillV2Connection = nil; local autoKillV2Running = false
local function AutoKillV2Loop()
    if not autoKillV2Running then return end
    local localChar = LocalPlayer.Character; if not localChar or not isAlive(localChar) then return end
    local remote = ReplicatedStorage:FindFirstChild("GameEvents"); if remote then remote = remote:FindFirstChild("Damage") end; if not remote then return end
    local origin = Camera.CFrame.Position; local priority = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if LocalPlayer.Team and plr.Team and plr.Team == LocalPlayer.Team then continue end
        local char = plr.Character; if not char or not isAlive(char) then continue end
        local head = char:FindFirstChild("Head")
        if head then
            local dir = (head.Position - origin).Unit
            local rayParams = RaycastParams.new(); rayParams.FilterType = Enum.RaycastFilterType.Exclude; rayParams.FilterDescendantsInstances = {localChar}
            local result = workspace:Raycast(origin, dir * 1000, rayParams)
            if result and result.Instance:IsDescendantOf(char) then
                local hitPoint = result.Position; local hitDir = (hitPoint - origin).Unit
                remote:FireServer(plr, 200, "Bayonet", { Normal = -hitDir, Direction = hitDir, StartPosition = origin, Instance = result.Instance, Material = Enum.Material.Plastic, EndPosition = hitPoint })
                return
            end
        end
        for _, name in ipairs(priority) do
            local part = char:FindFirstChild(name)
            if part then
                local dir = (part.Position - origin).Unit
                local rayParams = RaycastParams.new(); rayParams.FilterType = Enum.RaycastFilterType.Exclude; rayParams.FilterDescendantsInstances = {localChar}
                local result = workspace:Raycast(origin, dir * 1000, rayParams)
                if result and result.Instance:IsDescendantOf(char) then
                    local hitPoint = result.Position; local hitDir = (hitPoint - origin).Unit
                    remote:FireServer(plr, 200, "Bayonet", { Normal = -hitDir, Direction = hitDir, StartPosition = origin, Instance = result.Instance, Material = Enum.Material.Plastic, EndPosition = hitPoint })
                    return
                end
            end
        end
    end
end
local autoKillV2Toggle = expSec2:Toggle({ Title = "Auto Kill V2 [BETA]", Desc = "Raycast to all parts (no cooldown)", Icon = "lucide:skull", Flag = "AutoKillV2", Callback = function(state) if state then if autoKillV2Connection then autoKillV2Connection:Disconnect() end; autoKillV2Running = true; autoKillV2Connection = RunService.Heartbeat:Connect(AutoKillV2Loop) else autoKillV2Running = false; if autoKillV2Connection then autoKillV2Connection:Disconnect(); autoKillV2Connection = nil end end end })
currentConfig:Register("AutoKillV2", autoKillV2Toggle)

-- Teleport & Spin
local expSec3 = ExploitsTab:Section({ Title = "Teleport & Spin" })
local autoTeleportToggle = expSec3:Toggle({ Title = "Auto Teleport To Enemies", Desc = "Teleport above & behind", Icon = "lucide:zap", Flag = "KillAll", Callback = function(state) if state then local TargetIndex = 1; local LastTargetTime = 0; Connections.Backstab = RunService.Heartbeat:Connect(function() if not getgenv().BackstabActive then return end; local localChar = LocalPlayer.Character; local localHRP = localChar and localChar:FindFirstChild("HumanoidRootPart"); if not localHRP then return end; local validEnemies = {}; for _, player in pairs(Players:GetPlayers()) do if player ~= LocalPlayer and player.Character then if not LocalPlayer.Team or player.Team ~= LocalPlayer.Team then local enemyHum = player.Character:FindFirstChildOfClass("Humanoid"); local enemyHRP = player.Character:FindFirstChild("HumanoidRootPart"); if enemyHum and enemyHRP and enemyHum.Health > 0 then table.insert(validEnemies, player.Character) end end end end; if #validEnemies == 0 then return end; if os.clock() - LastTargetTime >= 2 then TargetIndex = TargetIndex + 1; if TargetIndex > #validEnemies then TargetIndex = 1 end; LastTargetTime = os.clock() end; local targetChar = validEnemies[TargetIndex] or validEnemies[1]; if targetChar then local targetHRP = targetChar:FindFirstChild("HumanoidRootPart"); local targetHead = targetChar:FindFirstChild("Head"); if targetHRP then localChar.HumanoidRootPart.CFrame = targetHRP.CFrame * CFrame.new(0, 3.5, 0.5) end; if targetHead then Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetHead.Position) end end end); getgenv().BackstabActive = true else if Connections.Backstab then Connections.Backstab:Disconnect(); Connections.Backstab = nil end; getgenv().BackstabActive = false end end })
currentConfig:Register("KillAll", autoTeleportToggle)

local spinAroundToggle = expSec3:Toggle({ Title = "Spin Around Target", Desc = "Orbit enemy (needs Auto Teleport)", Icon = "lucide:refresh-cw", Flag = "SpinAround", Callback = function(state) getgenv().SpinAroundEnabled = state; if state then if Connections.SpinAround then Connections.SpinAround:Disconnect() end; Connections.SpinAround = RunService.Heartbeat:Connect(function() if not getgenv().SpinAroundEnabled or not getgenv().BackstabActive then return end; local localChar = LocalPlayer.Character; if not localChar then return end; local lRoot = localChar:FindFirstChild("HumanoidRootPart"); if not lRoot then return end; local targetChar = nil; local targetHRP = nil; local shortestDist = math.huge; for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer and plr.Character then if LocalPlayer.Team and plr.Team == LocalPlayer.Team then continue end; local eHum = plr.Character:FindFirstChildOfClass("Humanoid"); local eHRP = plr.Character:FindFirstChild("HumanoidRootPart"); if eHum and eHRP and eHum.Health > 0 then local dist = (eHRP.Position - lRoot.Position).Magnitude; if dist < shortestDist then shortestDist = dist; targetChar = plr.Character; targetHRP = eHRP end end end end; if targetHRP then local angle = (tick() * 10) % 1 * math.pi * 2; local pos = targetHRP.Position + Vector3.new(math.cos(angle)*5, 3.5, math.sin(angle)*5); lRoot.CFrame = CFrame.new(pos, targetHRP.Position) end end) else if Connections.SpinAround then Connections.SpinAround:Disconnect(); Connections.SpinAround = nil end end end })
currentConfig:Register("SpinAround", spinAroundToggle)

-- Experimental: Teleport Kill with multi-target and 0.01s delay
local expSecDrop = ExploitsTab:Section({ Title = "Experimental" })
local teleportKillConnection = nil; local teleportKillRunning = false
local function TeleportKillLoop()
    if not teleportKillRunning then return end
    local localChar = LocalPlayer.Character; if not localChar or not isAlive(localChar) then return end
    local remote = ReplicatedStorage:FindFirstChild("GameEvents"); if remote then remote = remote:FindFirstChild("Damage") end; if not remote then return end
    local lRoot = localChar:FindFirstChild("HumanoidRootPart"); if not lRoot then return end

    local firstEnemy = nil
    local firstHead = nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if LocalPlayer.Team and plr.Team and plr.Team == LocalPlayer.Team then continue end
        local char = plr.Character; if not char or not isAlive(char) then continue end
        local head = char:FindFirstChild("Head"); if not head then continue end
        firstEnemy = plr
        firstHead = head
        break
    end
    if not firstHead then return end

    local originalCFrame = lRoot.CFrame
    local behindHead = firstHead.Position - (firstHead.CFrame.LookVector * 0.5)
    lRoot.CFrame = CFrame.new(behindHead, firstHead.Position)

    local camPos = Camera.CFrame.Position
    local endPos = firstHead.Position
    local direction = (endPos - camPos).Unit
    local normal = -direction
    remote:FireServer(firstEnemy, 200, "Bayonet", {
        Normal = normal, Direction = direction, StartPosition = camPos,
        Instance = firstHead, Material = Enum.Material.Plastic, EndPosition = endPos
    })

    local localChar = LocalPlayer.Character
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or plr == firstEnemy then continue end
        if LocalPlayer.Team and plr.Team and plr.Team == LocalPlayer.Team then continue end
        local char = plr.Character; if not char or not isAlive(char) then continue end
        local head = char:FindFirstChild("Head"); if not head then continue end

        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {localChar}
        local result = workspace:Raycast(Camera.CFrame.Position, head.Position - Camera.CFrame.Position, rayParams)
        if result == nil or (result.Instance and result.Instance:IsDescendantOf(char)) then
            local camPos2 = Camera.CFrame.Position
            local endPos2 = head.Position
            local direction2 = (endPos2 - camPos2).Unit
            local normal2 = -direction2
            remote:FireServer(plr, 200, "Bayonet", {
                Normal = normal2, Direction = direction2, StartPosition = camPos2,
                Instance = head, Material = Enum.Material.Plastic, EndPosition = endPos2
            })
        end
    end

    task.wait(0.01)

    lRoot.CFrame = originalCFrame
end
local teleportKillToggle = expSecDrop:Toggle({
    Title = "Teleport Kill (Test)",
    Desc = "Blink behind, kill one, then shoot all visible enemies, blink back after 0.01s",
    Icon = "lucide:zap", Flag = "TeleportKill",
    Callback = function(state)
        teleportKillRunning = state
        if state then
            if teleportKillConnection then teleportKillConnection:Disconnect() end
            teleportKillConnection = RunService.Heartbeat:Connect(TeleportKillLoop)
        else
            if teleportKillConnection then teleportKillConnection:Disconnect(); teleportKillConnection = nil end
        end
    end
})
currentConfig:Register("TeleportKill", teleportKillToggle)

-- Weapon & Build
local expSec4 = ExploitsTab:Section({ Title = "Weapon & Build" })
local noReloadToggle = expSec4:Toggle({ Title = "No Reload", Desc = "Spam reload remote", Icon = "lucide:refresh-cw", Flag = "InfiniteAmmo", Callback = function(state) if state then Connections.InfiniteAmmo = RunService.Heartbeat:Connect(function() local re = ReplicatedStorage:FindFirstChild("GameEvents"); if re then re = re:FindFirstChild("Reload") end; if re then re:FireServer("PPSH-41") end end) else if Connections.InfiniteAmmo then Connections.InfiniteAmmo:Disconnect(); Connections.InfiniteAmmo = nil end end end })
currentConfig:Register("InfiniteAmmo", noReloadToggle)

local instaBarricadeEnabled = false; local instaBarricadeConnection = nil; local originalHoldDurations = {}
local function setHoldDuration(prompt)
    pcall(function()
        if prompt:IsA("ProximityPrompt") then
            if instaBarricadeEnabled then originalHoldDurations[prompt] = prompt.HoldDuration; prompt.HoldDuration = 0
            elseif originalHoldDurations[prompt] then prompt.HoldDuration = originalHoldDurations[prompt]; originalHoldDurations[prompt] = nil end
        end
    end)
end
local function applyInstaBarricade()
    if instaBarricadeEnabled then for _, obj in ipairs(workspace:GetDescendants()) do setHoldDuration(obj) end; instaBarricadeConnection = workspace.DescendantAdded:Connect(setHoldDuration)
    else if instaBarricadeConnection then instaBarricadeConnection:Disconnect(); instaBarricadeConnection = nil end; for _, obj in ipairs(workspace:GetDescendants()) do setHoldDuration(obj) end; table.clear(originalHoldDurations) end
end
local instaBarricadeToggle = expSec4:Toggle({ Title = "Insta Barricade", Desc = "Instant build", Icon = "lucide:zap", Flag = "InstaBarricade", Callback = function(state) instaBarricadeEnabled = state; applyInstaBarricade() end })
currentConfig:Register("InstaBarricade", instaBarricadeToggle)

local autoBarricadeEnabled = false; local autoBarricadeConnection = nil
local function startAutoBarricade()
    if autoBarricadeConnection then autoBarricadeConnection:Disconnect() end
    autoBarricadeConnection = RunService.Heartbeat:Connect(function()
        if not autoBarricadeEnabled then return end
        for _, obj in ipairs(workspace:GetDescendants()) do if obj:IsA("ProximityPrompt") then pcall(function() obj:InputHoldBegin(); obj:InputHoldEnd() end) end end
    end)
end
local autoBarricadeToggle = expSec4:Toggle({ Title = "Auto Barricade", Desc = "Auto-build prompts", Icon = "lucide:refresh-cw", Flag = "AutoBarricade", Callback = function(state) autoBarricadeEnabled = state; if state then startAutoBarricade() else if autoBarricadeConnection then autoBarricadeConnection:Disconnect(); autoBarricadeConnection = nil end end end })
currentConfig:Register("AutoBarricade", autoBarricadeToggle)

-- Ping Spam
local expSec5 = ExploitsTab:Section({ Title = "Ping Spam" })
local autoPingEnabled = false; local nearest3PingEnabled = false; local lastPingTime = 0
local function firePing(targetPos) local pingRemote = ReplicatedStorage:FindFirstChild("GameEvents"); if pingRemote then pingRemote = pingRemote:FindFirstChild("PingLocation") end; if pingRemote then pingRemote:FireServer(targetPos, "Part", Vector3.new(0,1,0)) end end
local function updateAutoPing()
    if Connections.AutoPing then Connections.AutoPing:Disconnect(); Connections.AutoPing = nil end
    if not autoPingEnabled then return end
    Connections.AutoPing = RunService.Heartbeat:Connect(function()
        if not autoPingEnabled then return end
        local localPlayer = Players.LocalPlayer; if not localPlayer.Character then return end
        if nearest3PingEnabled then
            local enemies = {}; local myTeam = localPlayer.Team
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= localPlayer and plr.Character then
                    if myTeam and plr.Team == myTeam then continue end
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then local dist = (hrp.Position - localPlayer.Character.Head.Position).Magnitude; table.insert(enemies, {dist = dist, pos = hrp.Position}) end
                end
            end
            table.sort(enemies, function(a,b) return a.dist < b.dist end)
            for i = 1, math.min(3, #enemies) do firePing(enemies[i].pos) end
        else
            local now = os.clock(); if now - lastPingTime < 0.333 then return end; lastPingTime = now
            local camera = workspace.CurrentCamera; local screenCenter = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2); local closestDist = 300; local closestPos = nil
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr == localPlayer or not plr.Character then continue end
                if localPlayer.Team and plr.Team == localPlayer.Team then continue end
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
                local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                if onScreen then local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude; if dist < closestDist then closestDist = dist; closestPos = hrp.Position end end
            end
            if closestPos then firePing(closestPos) end
        end
    end)
end
local autoPingToggle = expSec5:Toggle({ Title = "Auto Ping", Desc = "Ping under crosshair", Icon = "lucide:send", Flag = "AutoPing", Callback = function(state) autoPingEnabled = state; updateAutoPing() end })
currentConfig:Register("AutoPing", autoPingToggle)
local nearest3PingToggle = expSec5:Toggle({ Title = "Nearest 3 Ping", Desc = "Ping 3 nearest", Icon = "lucide:users", Flag = "Nearest3Ping", Callback = function(state) nearest3PingEnabled = state; if autoPingEnabled then updateAutoPing() end end })
currentConfig:Register("Nearest3Ping", nearest3PingToggle)

-- Utility Buttons
local expSec6 = ExploitsTab:Section({ Title = "Utility Buttons" })
expSec6:Button({ Title = "Anti Kick", Desc = "Prevent kicks", Icon = "lucide:ban", Callback = function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-anti-kick-211995"))() end })
expSec6:Button({ Title = "Gun Spoofer", Desc = "Equip any tool", Icon = "lucide:hammer", Callback = function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Game-tool-equipper-12139"))() end })

-- Jumpscare
local expSec7 = ExploitsTab:Section({ Title = "Jumpscare" })
local jumpscareDelay = 0.1
expSec7:Button({ Title = "Jumpscare", Desc = "Teleport to enemy you're looking at, then back", Icon = "lucide:zap", Callback = function()
    local function getEnemyUnderCrosshair()
        local lp = LocalPlayer; local cam = Camera; local screenCenter = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2); local closest = nil; local closestDist = 150
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == lp then continue end
            if lp.Team and plr.Team and plr.Team == lp.Team then continue end
            local char = plr.Character; if not char then continue end
            local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
            local pos, onScreen = cam:WorldToViewportPoint(hrp.Position); if not onScreen then continue end
            local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
            if dist < closestDist then closestDist = dist; closest = { Player = plr, Character = char, HRP = hrp, Head = char:FindFirstChild("Head") } end
        end
        return closest
    end
    local target = getEnemyUnderCrosshair(); if not target then return end
    local lpChar = LocalPlayer.Character; if not lpChar then return end
    local lRoot = lpChar:FindFirstChild("HumanoidRootPart"); if not lRoot then return end
    local originalCF = lRoot.CFrame; local originalCamCF = Camera.CFrame
    local enemyRoot = target.HRP; local enemyHead = target.Head or enemyRoot; local enemyCF = enemyRoot.CFrame
    local frontOffset = enemyCF.LookVector * 2.5; local newPos = enemyCF.Position + frontOffset; newPos = Vector3.new(newPos.X, enemyCF.Position.Y + 1, newPos.Z)
    lRoot.CFrame = CFrame.new(newPos, enemyHead.Position); Camera.CFrame = CFrame.new(Camera.CFrame.Position, enemyHead.Position)
    task.wait(getgenv().JumpscareDelay or 0.1)
    lRoot.CFrame = originalCF; Camera.CFrame = originalCamCF
end })
local jumpscareDelaySlider = expSec7:Slider({ Title = "Jumpscare Delay", Desc = "Time before return (0-2s)", Step = 0.1, Flag = "JumpscareDelay", Value = { Min = 0, Max = 2, Default = 0.1 }, Icon = "lucide:clock", Callback = function(value) getgenv().JumpscareDelay = value end })
currentConfig:Register("JumpscareDelay", jumpscareDelaySlider)

-- Visuals Tab
local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local visSec1 = VisualsTab:Section({ Title = "ESP" })
local skeletonToggle = visSec1:Toggle({ Title = "Skeleton ESP", Desc = "Body lines", Icon = "lucide:activity", Flag = "SkeletonESP", Callback = function(v) getgenv().EspSettings.Skeleton = v end })
currentConfig:Register("SkeletonESP", skeletonToggle)
local tracersToggle = visSec1:Toggle({ Title = "Tracers ESP", Desc = "Line from bottom", Icon = "lucide:chevron-up", Flag = "TracersESP", Callback = function(v) getgenv().EspSettings.Tracers = v end })
currentConfig:Register("TracersESP", tracersToggle)
local nameEspToggle = visSec1:Toggle({ Title = "Name ESP", Desc = "Player name", Icon = "lucide:user", Flag = "NameESP", Callback = function(v) getgenv().EspSettings.Name = v end })
currentConfig:Register("NameESP", nameEspToggle)
local healthEspToggle = visSec1:Toggle({ Title = "Health ESP", Desc = "Health %", Icon = "lucide:activity", Flag = "HealthESP", Callback = function(v) getgenv().EspSettings.Health = v end })
currentConfig:Register("HealthESP", healthEspToggle)
local toolEspToggle = visSec1:Toggle({ Title = "Tool ESP", Desc = "Tool name", Icon = "lucide:hammer", Flag = "ToolESP", Callback = function(v) getgenv().EspSettings.Tool = v end })
currentConfig:Register("ToolESP", toolEspToggle)
local rainbowEspToggle = visSec1:Toggle({ Title = "Rainbow ESP", Desc = "Cycle colors", Icon = "lucide:star", Flag = "RainbowESP", Callback = function(v) getgenv().EspSettings.Rainbow = v end })
currentConfig:Register("RainbowESP", rainbowEspToggle)
local enemyColorpicker = visSec1:Colorpicker({ Title = "Enemy ESP Color", Desc = "Color for enemies", Icon = "lucide:pencil", Flag = "EnemyESPColor", Value = getgenv().EspSettings.EnemyColor or Color3.fromRGB(255,50,50), Callback = function(color) getgenv().EspSettings.EnemyColor = color end })
currentConfig:Register("EnemyESPColor", enemyColorpicker)
local teammateColorpicker = visSec1:Colorpicker({ Title = "Teammate ESP Color", Desc = "Color for teammates", Icon = "lucide:pencil", Flag = "TeammateESPColor", Value = getgenv().EspSettings.TeammateColor or Color3.fromRGB(50,150,255), Callback = function(color) getgenv().EspSettings.TeammateColor = color end })
currentConfig:Register("TeammateESPColor", teammateColorpicker)
local visSec4 = VisualsTab:Section({ Title = "ESP Appearance" })
local lineThicknessSlider = visSec4:Slider({ Title = "Line Thickness", Desc = "1-5", Step = 0.1, Flag = "ESPLineThickness", Value = { Min = 1, Max = 5, Default = 2 }, Icon = "lucide:sliders-horizontal", Callback = function(v) getgenv().EspSettings.LineThickness = v end })
currentConfig:Register("ESPLineThickness", lineThicknessSlider)
local visSec2 = VisualsTab:Section({ Title = "Other Visuals" })
local chamsToggle = visSec2:Toggle({ Title = "Player Wallhack (Chams)", Desc = "Outline through walls", Icon = "lucide:users", Flag = "Chams", Callback = function(state) if state then local function ApplyChams(player) if player == LocalPlayer then return end; player.CharacterAdded:Connect(function(char) local h = Instance.new("Highlight"); h.Name = "JB_ESP"; h.FillColor = Color3.fromRGB(255,0,100); h.OutlineColor = Color3.fromRGB(255,255,255); h.FillTransparency = 0.5; h.Parent = char end); if player.Character then local h = Instance.new("Highlight"); h.Name = "JB_ESP"; h.FillColor = Color3.fromRGB(255,0,100); h.OutlineColor = Color3.fromRGB(255,255,255); h.FillTransparency = 0.5; h.Parent = player.Character end end; for _, p in pairs(Players:GetPlayers()) do ApplyChams(p) end; Connections.Chams = Players.PlayerAdded:Connect(ApplyChams) else if Connections.Chams then Connections.Chams:Disconnect(); Connections.Chams = nil end; for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("JB_ESP") then p.Character.JB_ESP:Destroy() end end end end })
currentConfig:Register("Chams", chamsToggle)
local fullbrightToggle = visSec2:Toggle({ Title = "Fullbright", Desc = "No shadows", Icon = "lucide:star", Flag = "Fullbright", Callback = function(state) if state then Lighting.Brightness = 4; Lighting.Ambient = Color3.fromRGB(255,255,255); Lighting.GlobalShadows = false else Lighting.Brightness = 2; Lighting.Ambient = Color3.fromRGB(130,130,130); Lighting.GlobalShadows = true end end })
currentConfig:Register("Fullbright", fullbrightToggle)

-- Utility Tab
local UtilTab = Window:Tab({ Title = "Utility", Icon = "wrench" })
local utilSec1 = UtilTab:Section({ Title = "Camera" })
local cameraFOVToggle = utilSec1:Toggle({ Title = "Camera FOV Override", Desc = "Override FOV", Icon = "lucide:eye", Flag = "CameraFOVEnabled", Callback = function(state) getgenv().CameraFOVEnabled = state; if state then Camera.FieldOfView = getgenv().CameraFOVValue or 70; if Connections.CameraFOV then Connections.CameraFOV:Disconnect() end; Connections.CameraFOV = RunService.Heartbeat:Connect(function() if getgenv().CameraFOVEnabled then Camera.FieldOfView = getgenv().CameraFOVValue or 70 end end) else if Connections.CameraFOV then Connections.CameraFOV:Disconnect(); Connections.CameraFOV = nil end; Camera.FieldOfView = 70 end end })
currentConfig:Register("CameraFOVEnabled", cameraFOVToggle)
local cameraFOVSlider = utilSec1:Slider({ Title = "Camera FOV Value", Desc = "FOV in degrees (60-150)", Step = 1, Flag = "CameraFOVValue", Value = { Min = 60, Max = 150, Default = 70 }, Icon = "lucide:sliders-horizontal", Callback = function(value) getgenv().CameraFOVValue = value; if getgenv().CameraFOVEnabled then Camera.FieldOfView = value end end })
currentConfig:Register("CameraFOVValue", cameraFOVSlider)
local utilSec2 = UtilTab:Section({ Title = "Misc" })
utilSec2:Button({ Title = "Teleport Upwards", Desc = "+25 studs", Icon = "lucide:chevron-up", Callback = function() local r = LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if r then r.CFrame = r.CFrame + Vector3.new(0,25,0) end end })
utilSec2:Button({ Title = "Teleport Downwards", Desc = "-15 studs", Icon = "lucide:chevron-down", Callback = function() local r = LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if r then r.CFrame = r.CFrame + Vector3.new(0,-15,0) end end })
utilSec2:Button({ Title = "Infinite Camera Zoom", Desc = "Zoom distance 5000", Icon = "lucide:search", Callback = function() LocalPlayer.CameraMaxZoomDistance = 5000 end })
utilSec2:Button({ Title = "Respawn / Reset Character", Desc = "Kill character", Icon = "lucide:skull", Callback = function() local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.Health = 0 end end })

-- Settings Tab
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })
local setSec1 = SettingsTab:Section({ Title = "Theme" })
local themeNames = {}; for _, theme in ipairs(customThemes) do table.insert(themeNames, theme.Name) end; table.sort(themeNames)
setSec1:Dropdown({ Title = "Select Theme", Desc = "Auto-saved", Icon = "lucide:settings", Flag = "SavedTheme", Values = themeNames, Value = savedTheme or "Ocean", Callback = function(theme) pcall(function() WindUI:SetTheme(theme) end); pcall(function() if not isfolder("BR_Hub") then makefolder("BR_Hub") end; writefile("BR_Hub/theme.txt", theme) end) end })
local setSec2 = SettingsTab:Section({ Title = "Config Management" })
setSec2:Button({ Title = "Save Config", Desc = "Save all settings", Icon = "lucide:save", Callback = function() currentConfig:Save() end })
setSec2:Button({ Title = "Load Config", Desc = "Load settings from disk", Icon = "lucide:refresh-cw", Callback = function() currentConfig:Load() end })
setSec2:Button({ Title = "Delete Config", Desc = "Delete config file", Icon = "lucide:trash-2", Callback = function() pcall(function() if isfile("BR_Hub/config.json") then delfile("BR_Hub/config.json") end end) end })

LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5); if getgenv().SpinBotSettings.Enabled then StartSpinBot() end end)

pcall(function() currentConfig:Load() end)

print("BR Hub loaded successfully")