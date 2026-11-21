--[[
    kizithebusy HUB — Pro Showcase Edition V7 (Rayfield Gen2 | PC & Mobile)
    - Dedicated Abu Mashlah Kite Farm (Orbit at Custom Distance by Car/Foot + Auto-Equip & Shoot)
    - Aimbot Option: Abu Mashlah Only Mode (Works Inside Car)
    - Car Waypoint Navigation System (Save/Name/Delete Locations + Fly by Car 20-200)
    - Car Hover Patrol Mode (0-200 Speed) + 6000 Max Radius & ESP + Stay Seated on Stop
    - Driver-Seat-Only Protection + Monster Screen Warning Watcher -> Discord Webhook
    - Smart Tent Routine + Ranged Auto-Shoot with Line-of-Sight + Dynamic FOV
]]

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

---------------------------------------------------------
-- Configuration & Settings Management
---------------------------------------------------------
local CONFIG = {
    HubName = "kizithebusy HUB",
    Subtitle = "Pro Showcase Edition V7 • Safe Gen2",
    DiscordLink = "https://discord.gg/JEewdnUyK8",
    LogoID = "rbxassetid://96007556931310"
}

local SaveFileName = "kizithebusy_Hub_V7_Settings.json"
local Settings = {
    -- Auto-Farm
    AutoFarmActive = false,
    FarmMode = "WalkJump",
    FarmRange = 450,
    FarmT1 = false,
    FarmT2 = false,
    FarmT3 = false,
    FarmT4 = false,
    FarmT5 = true,
    FarmT6 = true,
    FarmAutoShoot = true,
    FarmShootRange = 25,
    FarmAutoPickup = true,
    FarmAutoEquip = true,
    AntiStuckActive = true,
    AutoEvadeMonster = true,
    EvadeTriggerDist = 60,

    -- Dedicated Abu Mashlah Kite Farm (Patrol Tab)
    AutoFarmMashlah = false,
    MashlahKeepDist = 75,
    MashlahAutoShoot = true,

    -- Tent / Ezba Return Loop
    AutoTentActive = false,
    TentIntervalMinutes = 5,
    TentPosX = nil,
    TentPosY = nil,
    TentPosZ = nil,

    -- Car Waypoints System
    Waypoints = {},
    WaypointCarSpeed = 160,

    -- ESP & Pro Visuals
    DhabAll = false,
    DhabRareOnly = true,
    RareChams = true,
    RareTracers = true,
    SmartAlerts = true,
    Players = false,
    Vehicles = false,
    ShopEzba = false,
    Edge = false,
    EspDistance = 1200,

    -- Smooth Safe Aimbot + Error Margin
    Aimbot = false,
    AimbotRareOnly = false,
    AimbotMashlahOnly = false,
    AimbotSmoothness = 0.45,
    AimbotDistance = 150,
    RequireWeapon = false,
    UseFOVCircle = true,
    FOVRadius = 130,
    HoldRightClick = false,
    UseErrorMargin = true,
    AimAccuracy = 95,

    -- Deep Circle Patrol, Car Flight & Auto-Stop
    PatrolActive = false,
    CarPatrolFly = false,
    CarPatrolSpeed = 140,
    PatrolRadius = 1000,
    ShowPatrolRings = true,
    StopOnT6 = true,
    StopOnT5 = false,
    StopOnMonster = true,
    StopOnDamage = true,

    -- Discord Webhook
    DiscordWebhook = "",
    DiscordAlertsActive = false,

    -- HUD & Safe Utils
    RareHudActive = true,
    HudPosX = 0.74,
    HudPosY = 0.14,
    AntiAfkActive = true,
    VehicleBoostActive = false,
    VehicleMaxSpeed = 200
}

if writefile and readfile and isfile and isfile(SaveFileName) then
    local success, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(SaveFileName))
    end)
    if success and type(decoded) == "table" then
        for k, v in pairs(decoded) do
            if Settings[k] ~= nil and k ~= "PatrolActive" and k ~= "AutoFarmActive" then
                Settings[k] = v
            end
        end
    end
end

if type(Settings.Waypoints) ~= "table" then
    Settings.Waypoints = {}
end

local function SaveSettings()
    if writefile then
        pcall(function()
            writefile(SaveFileName, HttpService:JSONEncode(Settings))
        end)
    end
end

---------------------------------------------------------
-- Discord Webhook Sender
---------------------------------------------------------
local HttpRequestFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local function SendDiscordWebhook(Title, Description, ColorInt)
    if not Settings.DiscordAlertsActive or not Settings.DiscordWebhook or Settings.DiscordWebhook == "" then
        return
    end
    if type(HttpRequestFunc) ~= "function" then return end

    task.spawn(function()
        pcall(function()
            local Payload = {
                username = "kizithebusy HUB • رادار الصيد",
                embeds = {{
                    title = Title,
                    description = Description,
                    color = ColorInt or 9133302,
                    footer = { text = "اللاعب: " .. LP.Name .. " • " .. os.date("%H:%M:%S") }
                }}
            }
            HttpRequestFunc({
                Url = Settings.DiscordWebhook,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(Payload)
            })
        end)
    end)
end

---------------------------------------------------------
-- Themes, Colors & Data Tables
---------------------------------------------------------
local DarkTheme = {
    Panel = Color3.fromRGB(18, 14, 34),
    Header = Color3.fromRGB(28, 21, 52),
    Accent = Color3.fromRGB(139, 92, 246),
    Glow = Color3.fromRGB(192, 132, 252),
    Locked = Color3.fromRGB(52, 211, 153)
}

local Colors = {
    White = Color3.fromRGB(255, 255, 255),
    Muted = Color3.fromRGB(180, 180, 200),
    PlayerColor = Color3.fromRGB(255, 60, 60),
    VehicleColor = Color3.fromRGB(255, 150, 0),
    ShopColor = Color3.fromRGB(56, 189, 248),
    EdgeColor = Color3.fromRGB(239, 68, 68)
}

local RarityNames = {
    T1 = "عادي", T2 = "مميز", T3 = "نادر", T4 = "فاخر", T5 = "أسطوري", T6 = "خرافي",
    Common = "عادي", Uncommon = "مميز", Rare = "نادر", Epic = "فاخر", Legendary = "أسطوري", Mythic = "خرافي"
}

local StateNames = {
    idle = "واقف 🧍",
    walk = "يمشي 🚶",
    flee = "يهرب 🏃",
    alert = "منتبه ⚠️",
    display = "يستعرض ✨",
    dead = "ميت 💀",
    down = "طايح 💀"
}

local RarityColors = {
    T1 = Color3.fromRGB(150, 160, 175),
    T2 = Color3.fromRGB(70, 160, 95),
    T3 = Color3.fromRGB(65, 130, 195),
    T4 = Color3.fromRGB(150, 100, 210),
    T5 = Color3.fromRGB(255, 185, 45),
    T6 = Color3.fromRGB(255, 45, 75)
}

local MonsterKeywords = {"mashlah", "مشلح", "fanoos", "فانوس", "malbous", "ملبوس", "ghurz", "غرز"}

---------------------------------------------------------
-- Session Stats & Bot State
---------------------------------------------------------
local SessionStartTime = tick()
local SessionStats = {
    T5Caught = 0,
    T6Caught = 0,
    TotalCaught = 0
}
local BotStatusText = "جاهز (Idle)"
local IsTravelingToWaypoint = false
local ActiveMashlahTarget = nil
local MashlahOrbitAngle = 0

local function FormatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

---------------------------------------------------------
-- Overlay UIs (Pro Dashboard HUD & Dynamic FOV Circle)
---------------------------------------------------------
local function getOverlayParent()
    if type(gethui) == "function" then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    return LP:WaitForChild("PlayerGui")
end

local overlayParent = getOverlayParent()
for _, c in ipairs(overlayParent:GetChildren()) do
    if c.Name == "kizithebusy_Overlay" then c:Destroy() end
end

local overlayGui = Instance.new("ScreenGui")
overlayGui.Name = "kizithebusy_Overlay"
overlayGui.ResetOnSpawn = false
overlayGui.Parent = overlayParent

local HasDrawing = (type(Drawing) == "table" or type(Drawing) == "userdata") and type(Drawing.new) == "function"

local FOVCircle = nil
if HasDrawing then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1.6
    FOVCircle.Color = DarkTheme.Glow
    FOVCircle.Filled = false
    FOVCircle.Transparency = 0.75
    FOVCircle.Visible = false
end

local NotifySound = Instance.new("Sound", overlayGui)
NotifySound.SoundId = "rbxassetid://4590657391"
NotifySound.Volume = 0.5
NotifySound.RollOffMaxDistance = 0

local RareHud = Instance.new("Frame", overlayGui)
RareHud.Name = "RareHud"
RareHud.Size = UDim2.new(0, 275, 0, 155)
RareHud.Position = UDim2.new(Settings.HudPosX, 0, Settings.HudPosY, 0)
RareHud.BackgroundColor3 = DarkTheme.Panel
RareHud.BackgroundTransparency = 0.12
RareHud.BorderSizePixel = 0
RareHud.Visible = Settings.RareHudActive
RareHud.Active = true
Instance.new("UICorner", RareHud).CornerRadius = UDim.new(0, 12)

local RareHudStroke = Instance.new("UIStroke", RareHud)
RareHudStroke.Color = DarkTheme.Accent
RareHudStroke.Thickness = 1.6

local HudHeader = Instance.new("Frame", RareHud)
HudHeader.Size = UDim2.new(1, 0, 0, 30)
HudHeader.BackgroundColor3 = DarkTheme.Header
HudHeader.BorderSizePixel = 0
Instance.new("UICorner", HudHeader).CornerRadius = UDim.new(0, 12)

local RareHudTitle = Instance.new("TextLabel", HudHeader)
RareHudTitle.Size = UDim2.new(1, -16, 1, 0)
RareHudTitle.Position = UDim2.new(0, 8, 0, 0)
RareHudTitle.BackgroundTransparency = 1
RareHudTitle.Text = "👑 kizithebusy PRO • رادار وإحصائيات"
RareHudTitle.TextColor3 = DarkTheme.Glow
RareHudTitle.TextSize = 12
RareHudTitle.Font = Enum.Font.GothamBold
RareHudTitle.TextXAlignment = Enum.TextXAlignment.Left

local HudStatsLabel = Instance.new("TextLabel", RareHud)
HudStatsLabel.Size = UDim2.new(1, -16, 0, 34)
HudStatsLabel.Position = UDim2.new(0, 8, 0, 34)
HudStatsLabel.BackgroundTransparency = 1
HudStatsLabel.Text = "الحالة: جاهز | ⏱️ 00:00:00\n🟠 T5: 0  |  🔴 T6: 0  |  🎒 الكل: 0"
HudStatsLabel.TextColor3 = Colors.Muted
HudStatsLabel.TextSize = 11
HudStatsLabel.Font = Enum.Font.GothamSemibold
HudStatsLabel.TextXAlignment = Enum.TextXAlignment.Left
HudStatsLabel.TextYAlignment = Enum.TextYAlignment.Top

local HudDivider = Instance.new("Frame", RareHud)
HudDivider.Size = UDim2.new(1, -16, 0, 1)
HudDivider.Position = UDim2.new(0, 8, 0, 72)
HudDivider.BackgroundColor3 = DarkTheme.Accent
HudDivider.BackgroundTransparency = 0.5
HudDivider.BorderSizePixel = 0

local RareHudContent = Instance.new("TextLabel", RareHud)
RareHudContent.Size = UDim2.new(1, -16, 1, -80)
RareHudContent.Position = UDim2.new(0, 8, 0, 76)
RareHudContent.BackgroundTransparency = 1
RareHudContent.Text = "جاري البحث عن ضب أسطوري أو خرافي قريب..."
RareHudContent.TextColor3 = Colors.White
RareHudContent.TextSize = 11
RareHudContent.Font = Enum.Font.GothamMedium
RareHudContent.TextWrapped = true
RareHudContent.TextXAlignment = Enum.TextXAlignment.Left
RareHudContent.TextYAlignment = Enum.TextYAlignment.Top

local HudDragging, HudDragStart, HudStartPosition = false, nil, nil
RareHud.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        HudDragging = true
        HudDragStart = Input.Position
        HudStartPosition = RareHud.Position
        Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                HudDragging = false
                Settings.HudPosX = RareHud.Position.X.Scale
                Settings.HudPosY = RareHud.Position.Y.Scale
                SaveSettings()
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(Input)
    if HudDragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
        local Delta = Input.Position - HudDragStart
        RareHud.Position = UDim2.new(HudStartPosition.X.Scale, HudStartPosition.X.Offset + Delta.X, HudStartPosition.Y.Scale, HudStartPosition.Y.Offset + Delta.Y)
    end
end)

---------------------------------------------------------
-- State, Caches & Entity Tracking
---------------------------------------------------------
local TrackedEntities = {}
local NotifiedRareDhabs = {}
local CountedPickedDhabs = {}
local LastKnownStates = {}
local EspCache = {}
local ChamCache = {}
local TracerCache = {}
local BlacklistedTargets = {}

local PatrolCenter = nil
local PatrolPausedReason = nil
local RingVisualParts = {}
local PatrolAngle = 0
local PatrolRingIndex = 1

local SavedTentPosition = nil
if Settings.TentPosX and Settings.TentPosY and Settings.TentPosZ then
    SavedTentPosition = Vector3.new(Settings.TentPosX, Settings.TentPosY, Settings.TentPosZ)
end

local function CleanupEntityVisuals(Obj)
    if EspCache[Obj] then
        pcall(function() EspCache[Obj]:Destroy() end)
        EspCache[Obj] = nil
    end
    if ChamCache[Obj] then
        pcall(function() ChamCache[Obj]:Destroy() end)
        ChamCache[Obj] = nil
    end
    if TracerCache[Obj] then
        pcall(function() TracerCache[Obj]:Remove() end)
        TracerCache[Obj] = nil
    end
end
local function IsDhabMountedOrCarried(Model)
    if not Model or not Model.Parent then return false end

    local curr = Model.Parent
    while curr and curr ~= Workspace do
        local nLow = curr.Name:lower()
        if Players:GetPlayerFromCharacter(curr) then return true end
        if curr:FindFirstChildOfClass("VehicleSeat") or TrackedEntities[curr] == "Vehicle" then
            return true
        end
        if nLow:find("rack") or nLow:find("roof") or nLow:find("cargo") or nLow:find("cage") or nLow:find("trunk") or nLow:find("carry") or nLow:find("slot") or nLow:find("mount") then
            return true
        end
        curr = curr.Parent
    end

    for Key, Value in pairs(Model:GetAttributes()) do
        local kLow = tostring(Key):lower()
        local vLow = tostring(Value):lower()
        if kLow:find("mount") or kLow:find("carr") or kLow:find("load") or kLow:find("stor") or kLow:find("attach") or kLow:find("roof") or kLow:find("owner") or kLow:find("holder") then
            if Value == true or (type(Value) == "string" and Value ~= "" and vLow ~= "none" and vLow ~= "false") then
                return true
            end
        end
        if kLow == "state" and (vLow:find("carr") or vLow:find("mount") or vLow:find("load") or vLow:find("stor") or vLow:find("rack")) then
            return true
        end
    end

    local Part = Model.PrimaryPart or Model:FindFirstChild("HumanoidRootPart") or Model:FindFirstChildWhichIsA("BasePart")
    if Part then
        local ok, connected = pcall(function() return Part:GetConnectedParts(true) end)
        if ok and type(connected) == "table" then
            for _, cPart in ipairs(connected) do
                if cPart:IsA("VehicleSeat") then return true end
                local cModel = cPart:FindFirstAncestorOfClass("Model")
                if cModel and cModel ~= Model then
                    if TrackedEntities[cModel] == "Vehicle" or Players:GetPlayerFromCharacter(cModel) or cModel:FindFirstChildOfClass("VehicleSeat") then
                        return true
                    end
                end
            end
        end
    end

    return false
end
local function IsDhabAlive(Model)
    if not Model or not Model.Parent then return false end

    local Hum = Model:FindFirstChildOfClass("Humanoid")
    if Hum and Hum.Health <= 0 then
        return false
    end

    for Key, Value in pairs(Model:GetAttributes()) do
        local kLow = tostring(Key):lower()
        local vLow = tostring(Value):lower()
        if (kLow == "dead" or kLow == "isdead" or kLow == "killed" or kLow == "captured") and Value == true then
            return false
        end
        if kLow == "health" or kLow == "hp" then
            local num = tonumber(Value)
            if num and num <= 0 then return false end
        end
        if kLow == "state" and (vLow == "dead" or vLow == "down" or vLow == "captured" or vLow == "ragdoll") then
            return false
        end
    end

    for _, desc in ipairs(Model:GetDescendants()) do
        if desc:IsA("ProximityPrompt") and desc.Enabled then
            return false
        end
    end

    return true
end

local function IsMonsterAlive(Model)
    if not Model or not Model.Parent then return false end
    local Hum = Model:FindFirstChildOfClass("Humanoid")
    if Hum and Hum.Health <= 0 then return false end
    for Key, Value in pairs(Model:GetAttributes()) do
        local kLow = tostring(Key):lower()
        if (kLow == "dead" or kLow == "isdead") and Value == true then return false end
        if (kLow == "health" or kLow == "hp") and tonumber(Value) and tonumber(Value) <= 0 then return false end
    end
    return true
end

local function GetDhabInfo(Model)
    if IsDhabMountedOrCarried(Model) then
        CleanupEntityVisuals(Model)
        return nil
    end
    local TierFound, StateFound = nil, nil
    for Key, Value in pairs(Model:GetAttributes()) do
        local KeyLower = tostring(Key):lower()
        if KeyLower == "tier" then
            local tStr = tostring(Value):upper()
            if tStr == "T1" or tStr == "T2" or tStr == "T3" or tStr == "T4" or tStr == "T5" or tStr == "T6" then
                TierFound = tStr
            end
        elseif KeyLower == "state" then
            StateFound = tostring(Value):lower()
        end
    end

    if not TierFound then return nil end
    local Rarity = RarityNames[TierFound] or "عادي"
    local Alive = IsDhabAlive(Model)

    if not Alive then
        LastKnownStates[Model] = "ميت 💀"
    elseif StateFound and StateNames[StateFound] then
        LastKnownStates[Model] = StateNames[StateFound]
    elseif not LastKnownStates[Model] or LastKnownStates[Model] == "ميت 💀" then
        LastKnownStates[Model] = "حي 🟢"
    end

    return LastKnownStates[Model], Rarity, TierFound, Alive
end

local function IsMashlahModel(Model)
    if not Model then return false end
    local NameLower = Model.Name:lower()
    return NameLower:find("mashlah") ~= nil or NameLower:find("مشلح") ~= nil
end

local function IsMonsterModel(Model)
    local NameLower = Model.Name:lower()
    for _, kw in ipairs(MonsterKeywords) do
        if NameLower:find(kw) then return true end
    end
    return false
end

local function ClassifyModel(Model)
    if not Model:IsA("Model") or Model == LP.Character then return nil end
    if Players:GetPlayerFromCharacter(Model) then return "Player" end

    local _, _, ValidTier = GetDhabInfo(Model)
    if ValidTier then return "Dhab" end

    if IsMonsterModel(Model) then return "Monster" end

    local NameLower = Model.Name:lower()
    if NameLower:find("car") or NameLower:find("veh") or NameLower:find("seat") or NameLower:find("nissan") or NameLower:find("toyota") or NameLower:find("gmc") or NameLower:find("selvrado") or NameLower:find("ddsn") or Model:FindFirstChildOfClass("VehicleSeat") then
        return "Vehicle"
    end

    if Model.Name == "DhabEzbaShop" or NameLower:find("ezba") or NameLower:find("عزب") then return "ShopEzba" end
    if Model.Name == "DhabMapEdge" or NameLower:find("edge") or NameLower:find("boundary") then return "Edge" end

    return nil
end

local function RegisterModel(Model)
    if not Model:IsA("Model") then return end
    task.defer(function()
        if not Model.Parent then return end
        local Cat = ClassifyModel(Model)
        if Cat then
            TrackedEntities[Model] = Cat
        end
    end)
end

for _, Obj in ipairs(Workspace:GetDescendants()) do
    if Obj:IsA("Model") then
        RegisterModel(Obj)
    end
end

Workspace.DescendantAdded:Connect(function(Obj)
    if Obj:IsA("Model") then
        RegisterModel(Obj)
    elseif Obj:IsA("VehicleSeat") and Obj.Parent and Obj.Parent:IsA("Model") then
        RegisterModel(Obj.Parent)
    end
end)

Workspace.DescendantRemoving:Connect(function(Obj)
    if TrackedEntities[Obj] then
        TrackedEntities[Obj] = nil
        LastKnownStates[Obj] = nil
        BlacklistedTargets[Obj] = nil
    end
    CleanupEntityVisuals(Obj)
end)

---------------------------------------------------------
-- Visual 3D Ring Zone Drawer
---------------------------------------------------------
local function ClearRingVisuals()
    for _, p in ipairs(RingVisualParts) do
        if p and p.Parent then p:Destroy() end
    end
    table.clear(RingVisualParts)
end

local function DrawPatrolRings()
    ClearRingVisuals()
    if not Settings.ShowPatrolRings or not PatrolCenter then return end

    local Scales = {1.0, 0.60, 0.30}
    local RingColors = {DarkTheme.Accent, Color3.fromRGB(56, 189, 248), Color3.fromRGB(255, 180, 50)}
    local Segments = 24

    for idx, scale in ipairs(Scales) do
        local r = Settings.PatrolRadius * scale
        local col = RingColors[idx]
        for i = 1, Segments do
            local a1 = (i / Segments) * math.pi * 2
            local a2 = ((i + 1) / Segments) * math.pi * 2
            local p1 = Vector3.new(PatrolCenter.X + math.cos(a1) * r, PatrolCenter.Y + 1.5, PatrolCenter.Z + math.sin(a1) * r)
            local p2 = Vector3.new(PatrolCenter.X + math.cos(a2) * r, PatrolCenter.Y + 1.5, PatrolCenter.Z + math.sin(a2) * r)

            local dist = (p2 - p1).Magnitude
            local part = Instance.new("Part")
            part.Name = "kizithebusy_Ring"
            part.Anchored = true
            part.CanCollide = false
            part.Material = Enum.Material.Neon
            part.Color = col
            part.Transparency = 0.45
            part.Size = Vector3.new(0.35, 0.35, dist)
            part.CFrame = CFrame.new((p1 + p2) / 2, p2)
            part.Parent = Workspace
            table.insert(RingVisualParts, part)
        end
    end
end

---------------------------------------------------------
-- Rayfield Gen2 Window & Notification Helper
---------------------------------------------------------
local window = Rayfield:CreateWindow({
    name = CONFIG.HubName,
    subtitle = CONFIG.Subtitle,
    sidebarLayout = true,
})
-- إغلاق النسخة القديمة تلقائياً عند التحديث لمنع تكرار القوائم
if type(getgenv) == "function" and type(getgenv().KiziHubCleanup) == "function" then
    pcall(getgenv().KiziHubCleanup)
end

if type(getgenv) == "function" then
    getgenv().KiziHubCleanup = function()
        pcall(ClearRingVisuals)
        pcall(function()
            if overlayGui and overlayGui.Parent then overlayGui:Destroy() end
        end)
        pcall(function()
            if window and type(window.Destroy) == "function" then window:Destroy() end
        end)
    end
end
local function Notify(titleText, contentText, dur)
    pcall(function()
        window:Notify({
            title = titleText,
            content = contentText,
            duration = dur or 3,
        })
    end)
end

---------------------------------------------------------
-- Monster Warning Text & Screen Alert Watcher (Webhook)
---------------------------------------------------------
local WarningKeywords = {
    "الأرض تهتز", "الارض تهتز", "تهتز",
    "أبو مشلح", "ابو مشلح", "مشلح",
    "فانوس", "ملبوس", "غرز",
    "ظلام", "خطر", "اقترب"
}
local LastWarningWebhookTime = 0

local function CheckMonsterWarningText(RawText)
    if type(RawText) ~= "string" or #RawText < 3 or #RawText > 180 then return end
    if (tick() - LastWarningWebhookTime) < 12 then return end

    for _, kw in ipairs(WarningKeywords) do
        if RawText:find(kw, 1, true) then
            LastWarningWebhookTime = tick()
            if Settings.SmartAlerts then
                pcall(function() NotifySound:Play() end)
                Notify("⚠️ تحذير ظهور وحش!", RawText, 5)
            end
            SendDiscordWebhook(
                "⚠️ تحذير: اقتراب وحش في السيرفر!",
                "ظهرت رسالة تحذير في اللعبة:\n> **" .. RawText .. "**",
                15548997
            )
            break
        end
    end
end

task.spawn(function()
    local PGui = LP:WaitForChild("PlayerGui", 10)
    if not PGui then return end

    local function HookTextObject(Obj)
        if not Obj:IsA("TextLabel") then return end
        if Obj:IsDescendantOf(overlayGui) or Obj.Name:find("Rayfield") then return end

        CheckMonsterWarningText(Obj.Text)
        Obj:GetPropertyChangedSignal("Text"):Connect(function()
            if Obj.Visible then
                CheckMonsterWarningText(Obj.Text)
            end
        end)
    end

    for _, desc in ipairs(PGui:GetDescendants()) do
        HookTextObject(desc)
    end
    PGui.DescendantAdded:Connect(HookTextObject)
end)

---------------------------------------------------------
-- Car Hover Flight, Smart Anti-Stuck, Movement & FireWeapon
---------------------------------------------------------
local function GetPart(Model)
    return Model:FindFirstChild("Head") or Model:FindFirstChild("HumanoidRootPart") or Model.PrimaryPart or Model:FindFirstChildWhichIsA("BasePart")
end

local WalkRayParams = RaycastParams.new()
WalkRayParams.FilterType = Enum.RaycastFilterType.Exclude

local function ShouldJumpObstacle(MyChar, MyRoot)
    WalkRayParams.FilterDescendantsInstances = {MyChar}
    local Origin = MyRoot.Position - Vector3.new(0, 1.2, 0)
    local Forward = MyRoot.CFrame.LookVector * 6.5
    local Hit = Workspace:Raycast(Origin, Forward, WalkRayParams)
    if Hit and Hit.Instance and Hit.Instance.CanCollide then
        return true
    end
    return false
end

local GlideBodyVel = nil
local CarBodyVel = nil
local CarBodyGyro = nil

local function ClearCarFlight()
    if CarBodyVel then
        pcall(function() CarBodyVel:Destroy() end)
        CarBodyVel = nil
    end
    if CarBodyGyro then
        pcall(function() CarBodyGyro:Destroy() end)
        CarBodyGyro = nil
    end
end

local function ClearGlide()
    if GlideBodyVel then
        pcall(function() GlideBodyVel:Destroy() end)
        GlideBodyVel = nil
    end
    ClearCarFlight()
end

local function GetCurrentVehicleSeat(Hum)
    if Hum and Hum.SeatPart and Hum.SeatPart:IsA("VehicleSeat") then
        return Hum.SeatPart
    end
    return nil
end

local function StopCarMomentum(Seat)
    ClearCarFlight()
    if not Seat then return end
    local CarModel = Seat:FindFirstAncestorOfClass("Model")
    local MainPart = (CarModel and CarModel.PrimaryPart) or Seat
    pcall(function()
        MainPart.AssemblyLinearVelocity = Vector3.zero
        MainPart.AssemblyAngularVelocity = Vector3.zero
    end)
end
local CarRayParams = RaycastParams.new()
CarRayParams.FilterType = Enum.RaycastFilterType.Exclude

local function MoveCarTowardsTarget(Seat, TargetPos, Speed)
    local CarModel = Seat:FindFirstAncestorOfClass("Model")
    local MainPart = (CarModel and CarModel.PrimaryPart) or Seat

    if not CarBodyVel or CarBodyVel.Parent ~= MainPart then
        ClearCarFlight()
        CarBodyVel = Instance.new("BodyVelocity")
        -- قوة على X و Z فقط، والارتفاع Y = 0 عشان الجاذبية تثبّت الكفرات بالأرض
        CarBodyVel.MaxForce = Vector3.new(9e6, 0, 9e6)
        CarBodyVel.Parent = MainPart

        CarBodyGyro = Instance.new("BodyGyro")
        CarBodyGyro.MaxTorque = Vector3.new(4e5, 9e6, 4e5)
        CarBodyGyro.P = 8000
        CarBodyGyro.Parent = MainPart
    end

    if Speed <= 0 then
        CarBodyVel.MaxForce = Vector3.new(9e6, 0, 9e6)
        CarBodyVel.Velocity = Vector3.zero
        return
    end

    local FlatTarget = Vector3.new(TargetPos.X, MainPart.Position.Y, TargetPos.Z)
    local Diff = FlatTarget - MainPart.Position
    if Diff.Magnitude <= 1 then
        CarBodyVel.MaxForce = Vector3.new(9e6, 0, 9e6)
        CarBodyVel.Velocity = Vector3.zero
        return
    end

    local MoveDir = Diff.Unit
    CarBodyGyro.CFrame = CFrame.new(MainPart.Position, FlatTarget)

    -- فحص الأرض والعوائق لتجاوز الصخور بدون البقاء في الهواء
    CarRayParams.FilterDescendantsInstances = {CarModel or Seat, LP.Character}
    local DownHit = Workspace:Raycast(MainPart.Position, Vector3.new(0, -10, 0), CarRayParams)
    local FrontHit = Workspace:Raycast(MainPart.Position + Vector3.new(0, 1, 0), MoveDir * 14, CarRayParams)

    local IsGrounded = (DownHit ~= nil and (MainPart.Position.Y - DownHit.Position.Y) <= 6.5)

    if FrontHit and FrontHit.Instance and FrontHit.Instance.CanCollide and IsGrounded then
        -- دفعة خفيفة ولحظية لتسلق الصخرة أو الطعس فقط
        CarBodyVel.MaxForce = Vector3.new(9e6, 6e5, 9e6)
        CarBodyVel.Velocity = Vector3.new(MoveDir.X * Speed, 22, MoveDir.Z * Speed)
    else
        -- إرجاع Y = 0 فوراً حتى تنزل الكفرات للأرض ولا تنقفط
        CarBodyVel.MaxForce = Vector3.new(9e6, 0, 9e6)
        CarBodyVel.Velocity = Vector3.new(MoveDir.X * Speed, 0, MoveDir.Z * Speed)
    end
end

local LastStuckCheckPos = nil
local LastStuckCheckTime = tick()
local StrafeSign = 1

local function CheckAndResolveStuck(MyChar, MyRoot, Hum, UseGlide)
    if not Settings.AntiStuckActive then return false end
    local now = tick()
    if not LastStuckCheckPos then
        LastStuckCheckPos = MyRoot.Position
        LastStuckCheckTime = now
        return false
    end

    if (now - LastStuckCheckTime) >= 2.0 then
        local movedDist = (Vector3.new(MyRoot.Position.X, 0, MyRoot.Position.Z) - Vector3.new(LastStuckCheckPos.X, 0, LastStuckCheckPos.Z)).Magnitude
        LastStuckCheckPos = MyRoot.Position
        LastStuckCheckTime = now

        if movedDist < 2.2 then
            StrafeSign = -StrafeSign
            local SideOffset = MyRoot.CFrame.RightVector * (10 * StrafeSign) - MyRoot.CFrame.LookVector * 3
            local EscapePos = MyRoot.Position + SideOffset
            Hum.Jump = true
            if UseGlide and GlideBodyVel then
                GlideBodyVel.Velocity = (EscapePos - MyRoot.Position).Unit * 24 + Vector3.new(0, 8, 0)
            else
                Hum:MoveTo(EscapePos)
            end
            task.wait(0.3)
            Hum.Jump = true
            return true
        end
    end
    return false
end

local function MoveTowardsTarget(MyChar, MyRoot, Hum, TargetPos, UseGlide)
    if CheckAndResolveStuck(MyChar, MyRoot, Hum, UseGlide) then
        return
    end

    if UseGlide then
        if not GlideBodyVel or GlideBodyVel.Parent ~= MyRoot then
            ClearGlide()
            GlideBodyVel = Instance.new("BodyVelocity")
            GlideBodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            GlideBodyVel.Parent = MyRoot
        end
        local GoalPos = TargetPos + Vector3.new(0, 3.5, 0)
        local Dir = (GoalPos - MyRoot.Position)
        if Dir.Magnitude > 0.1 then
            GlideBodyVel.Velocity = Dir.Unit * 26
        end
        MyRoot.CFrame = CFrame.new(MyRoot.Position, Vector3.new(TargetPos.X, MyRoot.Position.Y, TargetPos.Z))
    else
        ClearGlide()
        Hum:MoveTo(TargetPos)
        if ShouldJumpObstacle(MyChar, MyRoot) then
            Hum.Jump = true
        end
    end
end

local function EnsureToolEquipped(MyChar, Hum)
    local CurrentTool = MyChar:FindFirstChildOfClass("Tool")
    if CurrentTool then return CurrentTool end
    if not Settings.FarmAutoEquip then return nil end

    local Backpack = LP:FindFirstChildOfClass("Backpack")
    if Backpack then
        local Tool = Backpack:FindFirstChildOfClass("Tool")
        if Tool then
            pcall(function() Hum:EquipTool(Tool) end)
            return Tool
        end
    end
    return nil
end

local LastFireTime = 0
local function FireWeapon(MyChar, Hum)
    if (tick() - LastFireTime) < 0.15 then return end
    LastFireTime = tick()

    local Tool = EnsureToolEquipped(MyChar, Hum)
    if Tool then
        pcall(function() Tool:Activate() end)
    end

    if type(mouse1press) == "function" and type(mouse1release) == "function" then
        pcall(function()
            mouse1press()
            task.delay(0.05, mouse1release)
        end)
    elseif type(mouse1click) == "function" then
        pcall(mouse1click)
    else
        pcall(function()
            local cx = Camera.ViewportSize.X / 2
            local cy = Camera.ViewportSize.Y / 2
            VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
            task.delay(0.05, function()
                pcall(function()
                    VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
                end)
            end)
        end)
    end
end

---------------------------------------------------------
-- Car Waypoint Navigation Helpers
---------------------------------------------------------
local WaypointInputName = ""
local SelectedWaypointName = nil
local WaypointDropdown = nil

local function GetWaypointNames()
    local names = {}
    for _, wp in ipairs(Settings.Waypoints) do
        if wp and type(wp.name) == "string" and wp.name ~= "" then
            table.insert(names, wp.name)
        end
    end
    if #names == 0 then
        table.insert(names, "لا توجد مواقع محفوظة")
    end
    return names
end

local function FindWaypointByName(wpName)
    if not wpName or wpName == "" then return nil, nil end
    for idx, wp in ipairs(Settings.Waypoints) do
        if wp.name == wpName then
            return wp, idx
        end
    end
    return nil, nil
end

local function RefreshWaypointDropdown()
    local names = GetWaypointNames()
    if WaypointDropdown then
        pcall(function()
            if type(WaypointDropdown.SetOptions) == "function" then
                WaypointDropdown:SetOptions(names)
            elseif type(WaypointDropdown.Refresh) == "function" then
                WaypointDropdown:Refresh(names, true)
            elseif type(WaypointDropdown.Set) == "function" then
                WaypointDropdown:Set(names)
            end
        end)
    end
end

local function StartCarTripToWaypoint(TargetName)
    local wp = FindWaypointByName(TargetName)
    if not wp then
        Notify("تنبيه التنقل", "اختر موقعاً محفوظاً من القائمة أو اكتب اسمه أولاً!", 3)
        return
    end

    local MyChar = LP.Character
    local Hum = MyChar and MyChar:FindFirstChildOfClass("Humanoid")
    local Seat = GetCurrentVehicleSeat(Hum)
    if not Seat then
        Notify("اركب السيارة أولاً", "يجب أن تكون جالساً في مقعد السائق للانتقال بالسيارة!", 3)
        return
    end

    IsTravelingToWaypoint = true
    local GoalPos = Vector3.new(wp.x, wp.y, wp.z)
    BotStatusText = "متجه بالسيارة إلى: " .. wp.name .. " 🚗"
    Notify("🚗 انطلاق الرحلة", "جاري الانتقال بالسيارة إلى (" .. wp.name .. ")...", 3)

    task.spawn(function()
        local TripStart = tick()
        while overlayGui.Parent and IsTravelingToWaypoint and (tick() - TripStart) < 120 do
            local CharNow = LP.Character
            local RootNow = CharNow and CharNow:FindFirstChild("HumanoidRootPart")
            local HumNow = CharNow and CharNow:FindFirstChildOfClass("Humanoid")
            local SeatNow = GetCurrentVehicleSeat(HumNow)

            if not RootNow or not SeatNow then
                Notify("تم إلغاء الرحلة", "نزلت من مقعد السائق أثناء التنقل.", 3)
                break
            end

            local FlatDist = (Vector3.new(GoalPos.X, RootNow.Position.Y, GoalPos.Z) - RootNow.Position).Magnitude
            BotStatusText = string.format("إلى %s • %dm 🚗", wp.name, math.floor(FlatDist))

            if FlatDist <= 14 then
                StopCarMomentum(SeatNow)
                Notify("✅ تم الوصول!", "وصلت بالسيارة إلى موقع (" .. wp.name .. ") بنجاح.", 3)
                break
            end

            local ActiveSpeed = Settings.WaypointCarSpeed
            if FlatDist < 45 then
                ActiveSpeed = math.max(35, ActiveSpeed * 0.45)
            end

            MoveCarTowardsTarget(SeatNow, GoalPos, ActiveSpeed)
            task.wait(0.08)
        end

        local HumEnd = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        StopCarMomentum(GetCurrentVehicleSeat(HumEnd))
        IsTravelingToWaypoint = false
        BotStatusText = "جاهز (Idle)"
    end)
end

---------------------------------------------------------
-- Saved Tent Eat & Drink Routine (Driver Seat Only + Exact Snap)
---------------------------------------------------------
local IsEatingAtTent = false
local LastTentTimestamp = tick()

local function TriggerNearbyFoodWaterPrompts(Radius)
    local MyChar = LP.Character
    local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
    if not MyRoot then return end

    for _, Obj in ipairs(Workspace:GetDescendants()) do
        if Obj:IsA("ProximityPrompt") and Obj.Enabled then
            local ParentPart = Obj.Parent:IsA("BasePart") and Obj.Parent or (Obj.Parent:IsA("Model") and Obj.Parent:FindFirstChildWhichIsA("BasePart"))
            if ParentPart then
                local Dist = (ParentPart.Position - MyRoot.Position).Magnitude
                if Dist <= Radius then
                    local ActionLow = (Obj.ActionText .. " " .. Obj.ObjectText .. " " .. Obj.Parent.Name):lower()
                    if ActionLow:find("تمر") or ActionLow:find("ماء") or ActionLow:find("موية") or ActionLow:find("اشرب") or ActionLow:find("أكل") or ActionLow:find("اكل") or ActionLow:find("eat") or ActionLow:find("drink") or ActionLow:find("date") or ActionLow:find("water") or ActionLow:find("coffee") or ActionLow:find("قهوة") or ActionLow:find("furn_") then
                        if type(fireproximityprompt) == "function" then
                            pcall(function() fireproximityprompt(Obj) end)
                            task.wait(0.55)
                        end
                    end
                end
            end
        end
    end
end

local function ExecuteTentEatRoutine()
    if IsEatingAtTent then return end
    if not SavedTentPosition then
        Notify("تنبيه الخيمة", "احفظ موقع الخيمة أولاً من تبويب اوتو فارم!", 3)
        LastTentTimestamp = tick()
        return
    end

    IsEatingAtTent = true
    BotStatusText = "الرجوع للخيمة (أكل وشرب) ⛺"
    Notify("⛺ وقت الأكل والشرب", "جاري التوجه إلى موقع الخيمة المحفوظ...", 3)

    local MyChar = LP.Character
    local Hum = MyChar and MyChar:FindFirstChildOfClass("Humanoid")
    local SavedSeat = GetCurrentVehicleSeat(Hum)

    local StartWalk = tick()
    while overlayGui.Parent and (tick() - StartWalk) < 45 do
        MyChar = LP.Character
        local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
        Hum = MyChar and MyChar:FindFirstChildOfClass("Humanoid")
        if not MyRoot or not Hum then break end

        local SeatNow = GetCurrentVehicleSeat(Hum)
        local FlatDist = (Vector3.new(SavedTentPosition.X, MyRoot.Position.Y, SavedTentPosition.Z) - MyRoot.Position).Magnitude

        if SeatNow then
            SavedSeat = SeatNow
            if FlatDist <= 14 then
                StopCarMomentum(SeatNow)
                task.wait(0.25)
                Hum.Jump = true
                task.wait(0.45)
                break
            else
                local TravelSpeed = math.max(Settings.CarPatrolSpeed, 90)
                MoveCarTowardsTarget(SeatNow, SavedTentPosition, TravelSpeed)
            end
        else
            if FlatDist <= 3.5 then
                ClearGlide()
                Hum:MoveTo(MyRoot.Position)
                break
            end
            MoveTowardsTarget(MyChar, MyRoot, Hum, SavedTentPosition, (Settings.FarmMode == "GentleGlide"))
        end
        task.wait(0.12)
    end

    ClearGlide()

    MyChar = LP.Character
    local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
    Hum = MyChar and MyChar:FindFirstChildOfClass("Humanoid")
    if MyRoot and Hum then
        local SnapStart = tick()
        while (tick() - SnapStart) < 5 do
            local ExactDist = (Vector3.new(SavedTentPosition.X, MyRoot.Position.Y, SavedTentPosition.Z) - MyRoot.Position).Magnitude
            if ExactDist <= 2.5 then
                Hum:MoveTo(MyRoot.Position)
                break
            end
            Hum:MoveTo(SavedTentPosition)
            if ExactDist <= 9 then
                MyRoot.CFrame = CFrame.new(SavedTentPosition.X, MyRoot.Position.Y, SavedTentPosition.Z)
                break
            end
            task.wait(0.2)
        end
    end

    for _ = 1, 3 do
        if MyRoot and Hum then
            local Drift = (Vector3.new(SavedTentPosition.X, MyRoot.Position.Y, SavedTentPosition.Z) - MyRoot.Position).Magnitude
            if Drift > 3 then
                MyRoot.CFrame = CFrame.new(SavedTentPosition.X, MyRoot.Position.Y, SavedTentPosition.Z)
            end
        end
        TriggerNearbyFoodWaterPrompts(16)
        task.wait(0.55)
    end

    if SavedSeat and SavedSeat.Parent and SavedSeat:IsA("VehicleSeat") and MyChar and Hum then
        BotStatusText = "الرجوع لمقعد السائق 🚗"
        local CarModel = SavedSeat:FindFirstAncestorOfClass("Model")
        local DisabledPassengerSeats = {}

        if CarModel then
            for _, obj in ipairs(CarModel:GetDescendants()) do
                if obj:IsA("Seat") and not obj:IsA("VehicleSeat") and obj.CanTouch then
                    obj.CanTouch = false
                    table.insert(DisabledPassengerSeats, obj)
                end
            end
        end

        local ReturnStart = tick()
        while overlayGui.Parent and (tick() - ReturnStart) < 15 do
            MyRoot = MyChar:FindFirstChild("HumanoidRootPart")
            if not MyRoot then break end

            if Hum.SeatPart and Hum.SeatPart ~= SavedSeat then
                Hum.Jump = true
                task.wait(0.2)
            elseif Hum.SeatPart == SavedSeat then
                break
            end

            local SeatDist = (SavedSeat.Position - MyRoot.Position).Magnitude
            if SeatDist <= 14 then
                ClearGlide()
                MyRoot.CFrame = SavedSeat.CFrame + Vector3.new(0, 1.5, 0)
                task.wait(0.1)
                pcall(function() SavedSeat:Sit(Hum) end)
                task.wait(0.3)
                if Hum.SeatPart == SavedSeat then break end
            end

            MoveTowardsTarget(MyChar, MyRoot, Hum, SavedSeat.Position, false)
            task.wait(0.15)
        end

        for _, pSeat in ipairs(DisabledPassengerSeats) do
            if pSeat and pSeat.Parent then
                pSeat.CanTouch = true
            end
        end
        ClearGlide()
    end

    LastTentTimestamp = tick()
    IsEatingAtTent = false
    BotStatusText = "جاهز (Idle)"
    Notify("✅ تم الأكل والشرب", "تمت تعبئة الجوع والعطش من الخيمة والعودة لمقعد السائق!", 3)
end

---------------------------------------------------------
-- Tabs & Official Gen2 Controls
---------------------------------------------------------
local InfoTab = window:CreateTab({ name = "المعلومات", icon = 93364949241311 })
local WaypointsTab = window:CreateTab({ name = "التنقل بالسيارة", icon = 93364949241311 })
local FarmTab = window:CreateTab({ name = "اوتو فارم", icon = 93364949241311 })
local PatrolTab = window:CreateTab({ name = "الدوران التلقائي", icon = 93364949241311 })
local EspTab = window:CreateTab({ name = "قائمة ESP", icon = 93364949241311 })
local AimTab = window:CreateTab({ name = "الايمبوت", icon = 93364949241311 })
local UtilsTab = window:CreateTab({ name = "أدوات آمنة", icon = 93364949241311 })

-- Tab 1: Info & Discord Webhook
InfoTab:CreateSection({ name = "💎 مرحباً بك في kizithebusy HUB (V7)" })

InfoTab:CreateButton({
    name = "💬 نسخ رابط مجتمع Discord",
    description = "ينسخ رابط السيرفر إلى الحافظة مباشرة.",
    callback = function()
        if setclipboard then
            setclipboard(CONFIG.DiscordLink)
            Notify("تم النسخ!", "تم نسخ رابط الديسكورد إلى الحافظة بنجاح.", 3)
        end
    end
})

InfoTab:CreateButton({
    name = "🔄 تصفير عداد إحصائيات الجلسة",
    description = "يعيد ضبط عداد الصيد (T5 / T6) والمؤقت إلى الصفر.",
    callback = function()
        SessionStartTime = tick()
        SessionStats.T5Caught = 0
        SessionStats.T6Caught = 0
        SessionStats.TotalCaught = 0
        table.clear(CountedPickedDhabs)
        Notify("تم التصفير", "تم إعادة تعيين إحصائيات الجلسة.", 2)
    end
})
InfoTab:CreateButton({
    name = "🔄 تحديث وإعادة تشغيل السكربت الآن",
    description = "يحمل آخر تعديل من GitHub فوراً بدون الخروج من اللعبة.",
    callback = function()
        Notify("جاري التحديث...", "سيتم إغلاق هذه النسخة وتحميل آخر تحديث من GitHub.", 2)
        task.wait(0.3)
        if type(getgenv) == "function" and type(getgenv().KiziHubCleanup) == "function" then
            pcall(getgenv().KiziHubCleanup)
        end
        local url = "https://raw.githubusercontent.com/KiziTheBusy/9yd/main/Kizi.Lua?v=" .. tostring(math.floor(tick()))
        loadstring(game:HttpGet(url))()
    end
})
InfoTab:CreateSection({ name = "🔔 إشعارات ديسكورد (Discord Webhook)" })

InfoTab:CreateInput({
    name = "رابط Discord Webhook",
    placeholder = "https://discord.com/api/webhooks/...",
    value = Settings.DiscordWebhook,
    callback = function(text)
        Settings.DiscordWebhook = text
        SaveSettings()
    end
})

InfoTab:CreateToggle({
    name = "📨 تفعيل إرسال الإشعارات إلى ديسكورد",
    description = "يرسل إشعاراً عند رصد نادر أو ظهور تحذير وحش (الأرض تهتز / أبو مشلح).",
    value = Settings.DiscordAlertsActive,
    callback = function(value)
        Settings.DiscordAlertsActive = value
        SaveSettings()
    end
})

InfoTab:CreateButton({
    name = "🧪 إرسال إشعار تجريبي لديسكورد",
    description = "يختبر صحة رابط الويب هوك ويرسل رسالة تجريبية.",
    callback = function()
        if Settings.DiscordWebhook == "" then
            Notify("تنبيه", "الصق رابط الـ Webhook في الخانة أعلاه أولاً!", 3)
            return
        end
        local PrevState = Settings.DiscordAlertsActive
        Settings.DiscordAlertsActive = true
        SendDiscordWebhook("✅ اتصال ناجح!", "تم ربط **kizithebusy HUB V7** بسيرفر الديسكورد بنجاح.", 3447003)
        Settings.DiscordAlertsActive = PrevState
        Notify("تم الإرسال", "تحقق من قناة الديسكورد الآن!", 3)
    end
})

-- Tab 2: Car Waypoints & Fast Travel
WaypointsTab:CreateSection({ name = "📌 حفظ موقع جديد بإحداثياتك الحالية" })

WaypointsTab:CreateInput({
    name = "اسم الموقع (مثال: خيمتي، محل العزب، مكان T6)",
    placeholder = "اكتب اسم الموقع هنا...",
    value = "",
    callback = function(text)
        WaypointInputName = tostring(text or ""):gsub("^%s*(.-)%s*$", "%1")
    end
})

WaypointsTab:CreateButton({
    name = "📍 حفظ موقعي الحالي بهذا الاسم",
    description = "يحفظ إحداثياتك الحالية (أو موقع سيارتك) بشكل دائم.",
    callback = function()
        if WaypointInputName == "" then
            Notify("اكتب اسماً أولاً", "اكتب اسم الموقع في الخانة أعلاه قبل الضغط على حفظ.", 3)
            return
        end
        local MyChar = LP.Character
        local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
        if not MyRoot then
            Notify("خطأ", "شخصيتك غير موجودة حالياً.", 3)
            return
        end

        local Pos = MyRoot.Position
        local Existing, Idx = FindWaypointByName(WaypointInputName)
        local NewEntry = {
            name = WaypointInputName,
            x = math.floor(Pos.X * 10) / 10,
            y = math.floor(Pos.Y * 10) / 10,
            z = math.floor(Pos.Z * 10) / 10
        }

        if Existing and Idx then
            Settings.Waypoints[Idx] = NewEntry
            Notify("تم تحديث الموقع", "تم تحديث إحداثيات (" .. WaypointInputName .. ") بنجاح!", 3)
        else
            table.insert(Settings.Waypoints, NewEntry)
            Notify("تم حفظ الموقع", "تم حفظ موقع (" .. WaypointInputName .. ") في قائمتك بنجاح!", 3)
        end

        SelectedWaypointName = WaypointInputName
        SaveSettings()
        RefreshWaypointDropdown()
    end
})

WaypointsTab:CreateSection({ name = "🚗 الانتقال السريع بالسيارة للمواقع المحفوظة" })

WaypointDropdown = WaypointsTab:CreateDropdown({
    name = "اختر الموقع المحفوظ",
    options = GetWaypointNames(),
    value = GetWaypointNames()[1],
    callback = function(val)
        local picked = type(val) == "table" and val[1] or val
        if picked and picked ~= "لا توجد مواقع محفوظة" then
            SelectedWaypointName = picked
        end
    end
})

WaypointsTab:CreateSlider({
    name = "⚡ سرعة التنقل بالسيارة (20 إلى 200)",
    range = { 20, 200 },
    increment = 5,
    value = Settings.WaypointCarSpeed,
    callback = function(value)
        Settings.WaypointCarSpeed = value
        SaveSettings()
    end
})

WaypointsTab:CreateButton({
    name = "🚗 انطلق للموقع المحدد بالسيارة",
    description = "اركب مقعد السائق واضغط هنا ليطير بك مباشرة للموقع المحفوظ.",
    callback = function()
        local TargetName = SelectedWaypointName
        if (not TargetName or not FindWaypointByName(TargetName)) and WaypointInputName ~= "" then
            TargetName = WaypointInputName
        end
        StartCarTripToWaypoint(TargetName)
    end
})

WaypointsTab:CreateButton({
    name = "🛑 إيقاف الرحلة الحالية فوراً",
    description = "يوقف حركة السيارة في مكانك الحالي.",
    callback = function()
        IsTravelingToWaypoint = false
        local Hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        StopCarMomentum(GetCurrentVehicleSeat(Hum))
        BotStatusText = "جاهز (Idle)"
        Notify("تم الإيقاف", "تم إلغاء رحلة التنقل الحالية.", 2)
    end
})

WaypointsTab:CreateButton({
    name = "🗑️ حذف الموقع المحدد",
    description = "يحذف الموقع المختار من قائمة المواقع المحفوظة.",
    callback = function()
        local TargetName = SelectedWaypointName
        if (not TargetName or not FindWaypointByName(TargetName)) and WaypointInputName ~= "" then
            TargetName = WaypointInputName
        end
        local _, Idx = FindWaypointByName(TargetName)
        if Idx then
            table.remove(Settings.Waypoints, Idx)
            SelectedWaypointName = nil
            SaveSettings()
            RefreshWaypointDropdown()
            Notify("تم الحذف", "تم حذف موقع (" .. tostring(TargetName) .. ") بنجاح.", 3)
        else
            Notify("تنبيه", "لم يتم العثور على موقع محدد لحذفه.", 2)
        end
    end
})

-- Tab 3: Smart Auto-Farm
FarmTab:CreateSection({ name = "🚜 إعدادات الأوتو فارم الاحترافي" })

FarmTab:CreateToggle({
    name = "🚀 تشغيل الأوتو فارم (Auto-Farm)",
    description = "يتجه للضبان الحية المختارة بأولوية T6 ثم T5 مع فك التعليق التلقائي.",
    value = Settings.AutoFarmActive,
    callback = function(value)
        Settings.AutoFarmActive = value
        if value then
            PatrolPausedReason = nil
            LastTentTimestamp = tick()
            table.clear(BlacklistedTargets)
            Notify("اوتو فارم", "تم تشغيل الأوتو فارم الذكي بنجاح.", 2)
        else
            ClearGlide()
            BotStatusText = "متوقف (Idle)"
        end
    end
})

FarmTab:CreateToggle({
    name = "🕊️ وضع الانزلاق الخفيف (بدل المشي والقفز)",
    description = "انزلاق ناعم بسرعة آمنة (26) لتفادي العوائق وحماية السيرفر.",
    value = (Settings.FarmMode == "GentleGlide"),
    callback = function(value)
        Settings.FarmMode = value and "GentleGlide" or "WalkJump"
        SaveSettings()
    end
})

FarmTab:CreateToggle({
    name = "🧠 فك التعليق الذكي (Anti-Stuck + Blacklist)",
    description = "يقفز ويتحرك جانبياً إذا علق خلف صخرة، ويتجاهل الهدف المستحيل مؤقتاً.",
    value = Settings.AntiStuckActive,
    callback = function(value)
        Settings.AntiStuckActive = value
        SaveSettings()
    end
})

FarmTab:CreateToggle({
    name = "🔫 تفعيل الطلق / الضرب التلقائي (Auto-Shoot)",
    description = "يفعّل السلاح ويطلق تلقائياً مع الأوتو فارم والايمبوت.",
    value = Settings.FarmAutoShoot,
    callback = function(value)
        Settings.FarmAutoShoot = value
        SaveSettings()
    end
})

FarmTab:CreateSlider({
    name = "🎯 مسافة التوقف للإطلاق (للأسلحة البعيدة)",
    range = { 7, 150 },
    increment = 5,
    value = Settings.FarmShootRange,
    callback = function(value)
        Settings.FarmShootRange = value
        SaveSettings()
    end
})

FarmTab:CreateToggle({
    name = "🧰 تجهيز السلاح تلقائياً (Auto-Equip)",
    description = "يمسك السلاح تلقائياً من الحقيبة إذا لم يكن في يدك (حتى داخل السيارة).",
    value = Settings.FarmAutoEquip,
    callback = function(value)
        Settings.FarmAutoEquip = value
        SaveSettings()
    end
})

FarmTab:CreateToggle({
    name = "🎒 تفعيل الشيل / الالتقاط التلقائي (Auto-Pickup)",
    description = "يلتقط الضب فوراً بعد موته ويسجله في الإحصائيات.",
    value = Settings.FarmAutoPickup,
    callback = function(value)
        Settings.FarmAutoPickup = value
        SaveSettings()
    end
})

FarmTab:CreateSlider({
    name = "نطاق البحث عن الضبان حولك (بالمتر)",
    range = { 100, 1500 },
    increment = 50,
    value = Settings.FarmRange,
    callback = function(value)
        Settings.FarmRange = value
        SaveSettings()
    end
})

FarmTab:CreateSection({ name = "🎯 اختر فئات الضبان المطلوبة للفارم" })

FarmTab:CreateToggle({ name = "⚪ فئة T1 (عادي)", value = Settings.FarmT1, callback = function(v) Settings.FarmT1 = v SaveSettings() end })
FarmTab:CreateToggle({ name = "🟢 فئة T2 (مميز)", value = Settings.FarmT2, callback = function(v) Settings.FarmT2 = v SaveSettings() end })
FarmTab:CreateToggle({ name = "🔵 فئة T3 (نادر)", value = Settings.FarmT3, callback = function(v) Settings.FarmT3 = v SaveSettings() end })
FarmTab:CreateToggle({ name = "🟣 فئة T4 (فاخر)", value = Settings.FarmT4, callback = function(v) Settings.FarmT4 = v SaveSettings() end })
FarmTab:CreateToggle({ name = "🟠 فئة T5 (أسطوري)", value = Settings.FarmT5, callback = function(v) Settings.FarmT5 = v SaveSettings() end })
FarmTab:CreateToggle({ name = "🔴 فئة T6 (خرافي)", value = Settings.FarmT6, callback = function(v) Settings.FarmT6 = v SaveSettings() end })

FarmTab:CreateSection({ name = "⛺ العودة للخيمة والأكل التلقائي" })

FarmTab:CreateButton({
    name = "📍 حفظ موقع الخيمة هنا",
    description = "احفظ إحداثيات خيمتك ليرجع لها البوت وياكل ويشرب.",
    callback = function()
        local MyChar = LP.Character
        local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
        if MyRoot then
            SavedTentPosition = MyRoot.Position
            Settings.TentPosX = SavedTentPosition.X
            Settings.TentPosY = SavedTentPosition.Y
            Settings.TentPosZ = SavedTentPosition.Z
            SaveSettings()
            Notify("تم حفظ الخيمة", "تم حفظ موقع الخيمة بنجاح!", 3)
        else
            Notify("خطأ", "شخصيتك غير موجودة حالياً.", 3)
        end
    end
})

FarmTab:CreateToggle({
    name = "🍽️ تفعيل العودة للخيمة والأكل التلقائي",
    value = Settings.AutoTentActive,
    callback = function(value)
        Settings.AutoTentActive = value
        LastTentTimestamp = tick()
        SaveSettings()
    end
})

FarmTab:CreateSlider({
    name = "مؤقت العودة للخيمة (بالدقائق)",
    range = { 2, 15 },
    increment = 1,
    value = Settings.TentIntervalMinutes,
    callback = function(value)
        Settings.TentIntervalMinutes = value
        SaveSettings()
    end
})

FarmTab:CreateButton({
    name = "🏃 تجربة الرجوع للخيمة والأكل الآن",
    callback = function()
        task.spawn(ExecuteTentEatRoutine)
    end
})

-- Tab 4: Deep Circle Patrol, Car Flight & Abu Mashlah Farm
PatrolTab:CreateSection({ name = "👹 أوتو فارم أبو مشلح الذكي (مواجهة من مسافة)" })

PatrolTab:CreateToggle({
    name = "⚔️ تفعيل أوتو فارم أبو مشلح فقط (دوران + قفل كاميرا)",
    description = "يحافظ على المسافة التي تحددها بينك وبين أبو مشلح ويطلق عليه من السيارة أو مشياً.",
    value = Settings.AutoFarmMashlah,
    callback = function(value)
        Settings.AutoFarmMashlah = value
        if not value then
            ActiveMashlahTarget = nil
        else
            PatrolPausedReason = nil
            Notify("⚔️ فارم أبو مشلح", "سيتم الحفاظ على مسافة " .. tostring(Settings.MashlahKeepDist) .. "m وإطلاق النار عليه فور رسبنته!", 3)
        end
        SaveSettings()
    end
})

PatrolTab:CreateSlider({
    name = "📏 المسافة المطلوبة بينك وبين أبو مشلح (بالمتر)",
    range = { 20, 250 },
    increment = 5,
    value = Settings.MashlahKeepDist,
    callback = function(value)
        Settings.MashlahKeepDist = value
        SaveSettings()
    end
})

PatrolTab:CreateToggle({
    name = "🔫 إخراج السلاح وإطلاق النار تلقائياً على أبو مشلح",
    description = "يخرج السلاح تلقائياً من الحقيبة ويطلق على أبو مشلح وأنت داخل السيارة.",
    value = Settings.MashlahAutoShoot,
    callback = function(value)
        Settings.MashlahAutoShoot = value
        SaveSettings()
    end
})

PatrolTab:CreateSection({ name = "🧭 إعدادات الدوران والسيارة الطائرة" })

PatrolTab:CreateButton({
    name = "📍 تحديد مركز الدائرة هنا",
    description = "يضبط مركز الدائرة في موقعك الحالي ويرسم الحلقات الثلاث.",
    callback = function()
        local MyChar = LP.Character
        local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
        if MyRoot then
            PatrolCenter = MyRoot.Position
            DrawPatrolRings()
            Notify("تم تحديد المركز", "تم ضبط مركز الدائرة ورسم الحلقات (100% / 60% / 30%).", 3)
        else
            Notify("خطأ", "شخصيتك غير موجودة حالياً.", 3)
        end
    end
})

PatrolTab:CreateToggle({
    name = "🧭 تفعيل الدوران الآمن في عمق الدائرة",
    value = Settings.PatrolActive,
    callback = function(value)
        if value and not PatrolCenter then
            local MyChar = LP.Character
            local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
            if MyRoot then
                PatrolCenter = MyRoot.Position
                DrawPatrolRings()
            end
        end
        Settings.PatrolActive = value
        if value then
            PatrolPausedReason = nil
        else
            ClearGlide()
            BotStatusText = "متوقف (Idle)"
        end
    end
})

PatrolTab:CreateToggle({
    name = "🚗 طيران/انزلاق السيارة أثناء الدوران (بدون سحب سيرفر)",
    description = "اركب مقعد السائق وسيطير البوت بالسيارة بسرعة عالية ويبقى بداخلها عند التوقف.",
    value = Settings.CarPatrolFly,
    callback = function(value)
        Settings.CarPatrolFly = value
        if not value then ClearCarFlight() end
        SaveSettings()
    end
})

PatrolTab:CreateSlider({
    name = "⚡ سرعة مشي / طيران السيارة (0 إلى 200)",
    range = { 0, 200 },
    increment = 5,
    value = Settings.CarPatrolSpeed,
    callback = function(value)
        Settings.CarPatrolSpeed = value
        SaveSettings()
    end
})

PatrolTab:CreateToggle({
    name = "🏃 الهروب التلقائي من الوحوش الأخرى (Auto-Evade)",
    description = "يبتعد عن الوحوش (لا يهرب من أبو مشلح إذا كان فارم أبو مشلح مفعّلاً).",
    value = Settings.AutoEvadeMonster,
    callback = function(value)
        Settings.AutoEvadeMonster = value
        SaveSettings()
    end
})

PatrolTab:CreateSlider({
    name = "مسافة تفعيل الهروب من الوحش (بالمتر)",
    range = { 35, 120 },
    increment = 5,
    value = Settings.EvadeTriggerDist,
    callback = function(value)
        Settings.EvadeTriggerDist = value
        SaveSettings()
    end
})

PatrolTab:CreateButton({
    name = "▶️ استئناف الدوران / الفارم بعد التوقف",
    callback = function()
        PatrolPausedReason = nil
        Notify("تم الاستئناف", "تم إلغاء الإيقاف المؤقت والمتابعة.", 2)
    end
})

PatrolTab:CreateSlider({
    name = "نصف قطر الدائرة (بالمتر)",
    range = { 100, 6000 },
    increment = 100,
    value = Settings.PatrolRadius,
    callback = function(value)
        Settings.PatrolRadius = value
        SaveSettings()
        DrawPatrolRings()
    end
})

PatrolTab:CreateToggle({
    name = "⭕ إظهار حلقات الدائرة على الأرض",
    value = Settings.ShowPatrolRings,
    callback = function(value)
        Settings.ShowPatrolRings = value
        SaveSettings()
        if value then DrawPatrolRings() else ClearRingVisuals() end
    end
})

PatrolTab:CreateSection({ name = "🛑 شروط التوقف التلقائي (يبقى داخل السيارة)" })

PatrolTab:CreateToggle({ name = "🔴 توقف عند رصد ضب خرافي (T6)", value = Settings.StopOnT6, callback = function(v) Settings.StopOnT6 = v SaveSettings() end })
PatrolTab:CreateToggle({ name = "🟠 توقف عند رصد ضب أسطوري (T5)", value = Settings.StopOnT5, callback = function(v) Settings.StopOnT5 = v SaveSettings() end })
PatrolTab:CreateToggle({ name = "👹 توقف عند ظهور وحش (إذا الهروب وفارم أبو مشلح مطفي)", value = Settings.StopOnMonster, callback = function(v) Settings.StopOnMonster = v SaveSettings() end })
PatrolTab:CreateToggle({ name = "❤️ توقف عند نقص الهيلث (دمج)", value = Settings.StopOnDamage, callback = function(v) Settings.StopOnDamage = v SaveSettings() end })

-- Tab 5: ESP & Showcase Visuals
EspTab:CreateSection({ name = "👁️ خيارات الكشف والرادار الاحترافي" })

EspTab:CreateToggle({ name = "ESP جميع الضبان (T1 إلى T6)", value = Settings.DhabAll, callback = function(v) Settings.DhabAll = v SaveSettings() end })
EspTab:CreateToggle({ name = "ESP أسطوري (T5) وخرافي (T6) فقط", value = Settings.DhabRareOnly, callback = function(v) Settings.DhabRareOnly = v SaveSettings() end })
EspTab:CreateToggle({ name = "✨ توهج ثلاثي الأبعاد للضبان النادرة (Highlight Chams)", description = "يلوّن جسم الضب T5 بالذهبي و T6 بالأحمر من خلف الجدران.", value = Settings.RareChams, callback = function(v) Settings.RareChams = v SaveSettings() end })
EspTab:CreateToggle({ name = "📍 خطوط تتبع للضبان النادرة (2D Tracers)", description = "يرسم خطوطاً من أسفل الشاشة نحو الضبان T5 و T6.", value = Settings.RareTracers, callback = function(v) Settings.RareTracers = v SaveSettings() end })
EspTab:CreateToggle({ name = "🔔 تنبيهات صوتية عند ظهور نادر (T5 / T6)", value = Settings.SmartAlerts, callback = function(v) Settings.SmartAlerts = v SaveSettings() end })
EspTab:CreateToggle({ name = "ESP كشف اللاعبين", value = Settings.Players, callback = function(v) Settings.Players = v SaveSettings() end })
EspTab:CreateToggle({ name = "ESP كشف السيارات (المواتر)", value = Settings.Vehicles, callback = function(v) Settings.Vehicles = v SaveSettings() end })
EspTab:CreateToggle({ name = "⛺ ESP محل العزب", value = Settings.ShopEzba, callback = function(v) Settings.ShopEzba = v SaveSettings() end })
EspTab:CreateToggle({ name = "ESP حافة العالم", value = Settings.Edge, callback = function(v) Settings.Edge = v SaveSettings() end })

EspTab:CreateSlider({
    name = "مسافة الكشف (ESP Distance)",
    range = { 100, 6000 },
    increment = 100,
    value = Settings.EspDistance,
    callback = function(value)
        Settings.EspDistance = value
        SaveSettings()
    end
})

-- Tab 6: Smooth Safe Aimbot
AimTab:CreateSection({ name = "🎯 إعدادات الايمبوت الآمن" })

AimTab:CreateToggle({ name = "🎯 تفعيل الايمبوت الناعم (Smooth Aimbot)", value = Settings.Aimbot, callback = function(v) Settings.Aimbot = v SaveSettings() end })
AimTab:CreateToggle({ name = "👹 استهداف أبو مشلح فقط (يتجاهل الضبان)", description = "يقفل الايمبوت على أبو مشلح فقط (يعمل وأنت تسوق السيارة أيضاً).", value = Settings.AimbotMashlahOnly, callback = function(v) Settings.AimbotMashlahOnly = v SaveSettings() end })
AimTab:CreateToggle({ name = "👑 استهداف T5 و T6 فقط", value = Settings.AimbotRareOnly, callback = function(v) Settings.AimbotRareOnly = v SaveSettings() end })
AimTab:CreateToggle({ name = "🖱️ التصويب عند الضغط المستمر على كلك يمين فقط", value = Settings.HoldRightClick, callback = function(v) Settings.HoldRightClick = v SaveSettings() end })
AimTab:CreateToggle({ name = "🔫 يتطلب حمل أداة / سلاح باليد", value = Settings.RequireWeapon, callback = function(v) Settings.RequireWeapon = v SaveSettings() end })
AimTab:CreateToggle({ name = "⭕ إظهار دائرة FOV الديناميكية", value = Settings.UseFOVCircle, callback = function(v) Settings.UseFOVCircle = v SaveSettings() end })

AimTab:CreateSlider({ name = "حجم دائرة FOV", range = { 40, 600 }, increment = 10, value = Settings.FOVRadius, callback = function(v) Settings.FOVRadius = v SaveSettings() end })
AimTab:CreateSlider({ name = "أقصى مسافة للايمبوت (بالمتر)", range = { 20, 300 }, increment = 5, value = Settings.AimbotDistance, callback = function(v) Settings.AimbotDistance = v SaveSettings() end })
AimTab:CreateSlider({ name = "نعومة التصويب (0.05 ناعم جداً - 1.0 سريع)", range = { 0.05, 1.0 }, increment = 0.05, value = Settings.AimbotSmoothness, callback = function(v) Settings.AimbotSmoothness = v SaveSettings() end })

AimTab:CreateToggle({ name = "🎲 تفعيل هامش الخطأ البشري (Error Margin)", value = Settings.UseErrorMargin, callback = function(v) Settings.UseErrorMargin = v SaveSettings() end })
AimTab:CreateSlider({ name = "نسبة دقة التصويب (%)", range = { 70, 99 }, increment = 1, value = Settings.AimAccuracy, callback = function(v) Settings.AimAccuracy = v SaveSettings() end })

-- Tab 7: Safe Utilities
UtilsTab:CreateSection({ name = "🛡️ أدوات آمنة ومساعدة" })

UtilsTab:CreateToggle({
    name = "👑 إظهار لوحة الرادار والإحصائيات (HUD)",
    value = Settings.RareHudActive,
    callback = function(value)
        Settings.RareHudActive = value
        RareHud.Visible = value
        SaveSettings()
    end
})

UtilsTab:CreateToggle({ name = "💤 منع الطرد بسبب الخمول (Anti-AFK)", value = Settings.AntiAfkActive, callback = function(v) Settings.AntiAfkActive = v SaveSettings() end })
UtilsTab:CreateToggle({ name = "🏎️ تحسين سرعة المركبات الأرضية", value = Settings.VehicleBoostActive, callback = function(v) Settings.VehicleBoostActive = v SaveSettings() end })
UtilsTab:CreateSlider({ name = "السرعة القصوى للمركبة الأرضية", range = { 50, 200 }, increment = 5, value = Settings.VehicleMaxSpeed, callback = function(v) Settings.VehicleMaxSpeed = v SaveSettings() end })

---------------------------------------------------------
-- Core Logic: Target Priority, Mashlah Finder & Visual Builders
---------------------------------------------------------
local TierPriority = { T6 = 6, T5 = 5, T4 = 4, T3 = 3, T2 = 2, T1 = 1 }

local function IsTierSelectedForFarm(Tier)
    if Tier == "T1" then return Settings.FarmT1 end
    if Tier == "T2" then return Settings.FarmT2 end
    if Tier == "T3" then return Settings.FarmT3 end
    if Tier == "T4" then return Settings.FarmT4 end
    if Tier == "T5" then return Settings.FarmT5 end
    if Tier == "T6" then return Settings.FarmT6 end
    return false
end

local function FindAbuMashlah(MyPos)
    local ClosestModel, ClosestPart, ClosestDist = nil, nil, math.huge
    for Model, Cat in pairs(TrackedEntities) do
        if Cat == "Monster" and Model.Parent and IsMashlahModel(Model) and IsMonsterAlive(Model) then
            local Part = GetPart(Model)
            if Part then
                local Dist = (Part.Position - MyPos).Magnitude
                if Dist < ClosestDist then
                    ClosestDist = Dist
                    ClosestModel = Model
                    ClosestPart = Part
                end
            end
        end
    end
    return ClosestModel, ClosestPart, ClosestDist
end

local function FindNearestMonster(MyPos, MaxDist, IgnoreMashlah)
    local ClosestModel, ClosestPart, ClosestDist = nil, nil, MaxDist
    for Model, Cat in pairs(TrackedEntities) do
        if Cat == "Monster" and Model.Parent and IsMonsterAlive(Model) then
            if IgnoreMashlah and IsMashlahModel(Model) then continue end
            local Part = GetPart(Model)
            if Part then
                local Dist = (Part.Position - MyPos).Magnitude
                if Dist < ClosestDist then
                    ClosestDist = Dist
                    ClosestModel = Model
                    ClosestPart = Part
                end
            end
        end
    end
    return ClosestModel, ClosestPart, ClosestDist
end

local function FindBestFarmTarget(MyPos)
    local BestModel, BestPart, BestDist, BestScore = nil, nil, math.huge, -math.huge
    local now = tick()

    for Model, Cat in pairs(TrackedEntities) do
        if Cat == "Dhab" and Model.Parent then
            local blExpire = BlacklistedTargets[Model]
            if blExpire and blExpire > now then
                continue
            end

            local _, _, Tier, Alive = GetDhabInfo(Model)
            if Tier and IsTierSelectedForFarm(Tier) then
                if not Alive and not Settings.FarmAutoPickup then
                    continue
                end
                local Part = GetPart(Model)
                if Part then
                    local Dist = (Part.Position - MyPos).Magnitude
                    if Dist <= Settings.FarmRange then
                        local FinishBonus = (not Alive and Settings.FarmAutoPickup) and 250 or 0
                        local Score = (TierPriority[Tier] or 1) * 2000 + FinishBonus - Dist
                        if Score > BestScore then
                            BestScore = Score
                            BestModel = Model
                            BestPart = Part
                            BestDist = Dist
                        end
                    end
                end
            end
        end
    end

    return BestModel, BestPart, BestDist
end

local function GetOrCreateBillboard(Model)
    if EspCache[Model] and EspCache[Model].Parent then
        return EspCache[Model]
    end
    local Part = GetPart(Model)
    if not Part then return nil end

    local bb = Instance.new("BillboardGui")
    bb.Name = "kizithebusy_ESP"
    bb.Adornee = Part
    bb.Size = UDim2.new(0, 190, 0, 44)
    bb.StudsOffset = Vector3.new(0, 3.2, 0)
    bb.AlwaysOnTop = true
    bb.Parent = overlayGui

    local lbl = Instance.new("TextLabel", bb)
    lbl.Name = "InfoLabel"
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextStrokeTransparency = 0.25

    EspCache[Model] = bb
    return bb
end

local function UpdateCham(Model, Enabled, Color)
    if Enabled then
        local hl = ChamCache[Model]
        if not hl or not hl.Parent then
            hl = Instance.new("Highlight")
            hl.Name = "kizithebusy_Cham"
            hl.Adornee = Model
            hl.FillTransparency = 0.65
            hl.OutlineTransparency = 0.05
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = overlayGui
            ChamCache[Model] = hl
        end
        hl.FillColor = Color
        hl.OutlineColor = Color
        hl.Enabled = true
    elseif ChamCache[Model] then
        ChamCache[Model].Enabled = false
    end
end

---------------------------------------------------------
-- Main Loops (Abu Mashlah Kite Farm, Auto-Farm, Patrol, ESP, Aimbot)
---------------------------------------------------------
LP.Idled:Connect(function()
    if Settings.AntiAfkActive and overlayGui.Parent then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

local LastHealth = nil
task.spawn(function()
    while overlayGui.Parent do
        task.wait(0.25)
        local MyChar = LP.Character
        local Hum = MyChar and MyChar:FindFirstChildOfClass("Humanoid")
        if Hum then
            if LastHealth and Hum.Health < LastHealth and Settings.StopOnDamage and Settings.PatrolActive and not PatrolPausedReason then
                PatrolPausedReason = "نقص الهيلث (دمج)!"
                BotStatusText = "متوقف: تعرضت لدمج ❤️"
                ClearGlide()
                Notify("🛑 توقف الدوران التلقائي", "تم إيقاف الدوران بسبب تعرضك لضرر!", 4)
                SendDiscordWebhook("🛑 توقف الدوران التلقائي", "توقف البوت بسبب تعرض الشخصية لضرر (دمج).", 15548997)
            end
            LastHealth = Hum.Health
        else
            LastHealth = nil
        end
    end
end)

local CurrentFarmTarget = nil
local TargetLockStartTime = 0
local TargetStartDist = 0

task.spawn(function()
    while overlayGui.Parent do
        task.wait(0.10)
        if IsEatingAtTent or IsTravelingToWaypoint then
            ActiveMashlahTarget = nil
            continue
        end

        if Settings.AutoTentActive and (Settings.AutoFarmActive or Settings.PatrolActive or Settings.AutoFarmMashlah) and (tick() - LastTentTimestamp) >= (Settings.TentIntervalMinutes * 60) then
            ActiveMashlahTarget = nil
            ExecuteTentEatRoutine()
            continue
        end

        local MyChar = LP.Character
        local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
        local Hum = MyChar and MyChar:FindFirstChildOfClass("Humanoid")
        if not MyRoot or not Hum or Hum.Health <= 0 then
            ActiveMashlahTarget = nil
            ClearGlide()
            continue
        end

        local Seat = GetCurrentVehicleSeat(Hum)

        -- 0. Dedicated Abu Mashlah Kite Farm (Priority over Patrol & Evade)
        if Settings.AutoFarmMashlah then
            local MashlahModel, MashlahPart, MashlahDist = FindAbuMashlah(MyRoot.Position)
            if MashlahModel and MashlahPart then
                ActiveMashlahTarget = MashlahPart
                BotStatusText = string.format("⚔️ فارم أبو مشلح • %dm (الهدف %dm)", math.floor(MashlahDist), Settings.MashlahKeepDist)

                -- إخراج السلاح تلقائياً حتى وأنت داخل السيارة
                if Settings.FarmAutoEquip then
                    EnsureToolEquipped(MyChar, Hum)
                end

                local KeepDist = Settings.MashlahKeepDist
                local DiffFromMashlah = Vector3.new(MyRoot.Position.X - MashlahPart.Position.X, 0, MyRoot.Position.Z - MashlahPart.Position.Z)
                if DiffFromMashlah.Magnitude < 0.5 then
                    DiffFromMashlah = Vector3.new(1, 0, 0)
                end

                local TargetGoal
                if MashlahDist < (KeepDist - 8) then
                    -- إذا اقترب منك أبو مشلح: ابتعد مباشرة للخلف حتى المسافة المطلوبة
                    TargetGoal = MashlahPart.Position + DiffFromMashlah.Unit * (KeepDist + 10)
                elseif MashlahDist > (KeepDist + 15) then
                    -- إذا ابتعد: اقترب منه حتى المسافة المطلوبة فقط
                    TargetGoal = MashlahPart.Position + DiffFromMashlah.Unit * KeepDist
                else
                    -- حافظ على نفس المسافة مع دوران دائري ناعم حوله
                    MashlahOrbitAngle = MashlahOrbitAngle + 0.14
                    local BaseAngle = math.atan2(DiffFromMashlah.Z, DiffFromMashlah.X)
                    local NextAngle = BaseAngle + 0.35
                    TargetGoal = Vector3.new(
                        MashlahPart.Position.X + math.cos(NextAngle) * KeepDist,
                        MashlahPart.Position.Y,
                        MashlahPart.Position.Z + math.sin(NextAngle) * KeepDist
                    )
                end

                if Seat then
                    local KiteSpeed = math.max(Settings.CarPatrolSpeed, 95)
                    MoveCarTowardsTarget(Seat, TargetGoal, KiteSpeed)
                else
                    MoveTowardsTarget(MyChar, MyRoot, Hum, Vector3.new(TargetGoal.X, MyRoot.Position.Y, TargetGoal.Z), (Settings.FarmMode == "GentleGlide"))
                end
                continue
            else
                ActiveMashlahTarget = nil
            end
        else
            ActiveMashlahTarget = nil
        end

        -- 1. Auto-Evade Other Monsters
        if Settings.AutoEvadeMonster and (Settings.AutoFarmActive or Settings.PatrolActive) then
            local MonsterModel, MonsterPart, MonsterDist = FindNearestMonster(MyRoot.Position, Settings.EvadeTriggerDist, Settings.AutoFarmMashlah)
            if MonsterModel and MonsterPart then
                BotStatusText = "هروب من وحش (" .. math.floor(MonsterDist) .. "m) 🏃"
                local AwayDir = (MyRoot.Position - MonsterPart.Position)
                local FlatDir = Vector3.new(AwayDir.X, 0, AwayDir.Z)
                if FlatDir.Magnitude < 0.1 then FlatDir = Vector3.new(1, 0, 0) end
                local SafeGoal = MyRoot.Position + FlatDir.Unit * 65
                if Seat and Settings.CarPatrolFly then
                    MoveCarTowardsTarget(Seat, SafeGoal, math.max(Settings.CarPatrolSpeed, 110))
                else
                    MoveTowardsTarget(MyChar, MyRoot, Hum, SafeGoal, (Settings.FarmMode == "GentleGlide"))
                end
                continue
            end
        end

        -- 2. Patrol Auto-Stop Checks (يبقى داخل السيارة ولا ينزل)
        if Settings.PatrolActive and not PatrolPausedReason then
            for Model, Cat in pairs(TrackedEntities) do
                if Model.Parent then
                    local Part = GetPart(Model)
                    if Part and (Part.Position - MyRoot.Position).Magnitude <= Settings.PatrolRadius then
                        if Cat == "Monster" and Settings.StopOnMonster and not Settings.AutoEvadeMonster and not (Settings.AutoFarmMashlah and IsMashlahModel(Model)) then
                            PatrolPausedReason = "رصد وحش (" .. Model.Name .. ")"
                            BotStatusText = "متوقف: رصد وحش 👹"
                            StopCarMomentum(Seat)
                            Notify("🛑 توقف الدوران", "تم رصد وحش قريب!", 4)
                            SendDiscordWebhook("👹 رصد وحش قريب", "توقف الدوران بسبب رصد وحش: **" .. Model.Name .. "**", 15548997)
                            break
                        elseif Cat == "Dhab" then
                            local _, _, Tier, Alive = GetDhabInfo(Model)
                            if Alive then
                                if Tier == "T6" and Settings.StopOnT6 then
                                    PatrolPausedReason = "رصد ضب خرافي T6!"
                                    BotStatusText = "متوقف: ضب خرافي T6 👑"
                                    StopCarMomentum(Seat)
                                    Notify("👑 توقف الدوران", "تم العثور على ضب خرافي (T6)!", 5)
                                    SendDiscordWebhook("👑 تم رصد ضب خرافي (T6)!", "توقف البوت في مكانه عند رصد ضب خرافي قريب!", 16723275)
                                    break
                                elseif Tier == "T5" and Settings.StopOnT5 then
                                    PatrolPausedReason = "رصد ضب أسطوري T5!"
                                    BotStatusText = "متوقف: ضب أسطوري T5 🟠"
                                    StopCarMomentum(Seat)
                                    Notify("🟠 توقف الدوران", "تم العثور على ضب أسطوري (T5)!", 5)
                                    SendDiscordWebhook("🟠 تم رصد ضب أسطوري (T5)!", "توقف البوت في مكانه عند رصد ضب أسطوري قريب!", 16759085)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end

        if PatrolPausedReason then
            ClearGlide()
            continue
        end

        -- 3. Execute Smart Auto-Farm (Ranged + Line-of-Sight)
        if Settings.AutoFarmActive then
            local TargetModel, TargetPart, Dist = FindBestFarmTarget(MyRoot.Position)
            if TargetModel and TargetPart then
                local _, RarityStr, Tier, Alive = GetDhabInfo(TargetModel)
                local DesiredDist = (Alive and Settings.FarmAutoShoot) and Settings.FarmShootRange or 7.5

                local ClearShot = true
                if Alive and Settings.FarmAutoShoot and Dist > 10 and Dist <= DesiredDist then
                    WalkRayParams.FilterDescendantsInstances = {MyChar, TargetModel}
                    local RayOrigin = Camera.CFrame.Position
                    local RayHit = Workspace:Raycast(RayOrigin, TargetPart.Position - RayOrigin, WalkRayParams)
                    if RayHit and RayHit.Instance and RayHit.Instance.CanCollide then
                        ClearShot = false
                    end
                end

                if TargetModel ~= CurrentFarmTarget then
                    CurrentFarmTarget = TargetModel
                    TargetLockStartTime = tick()
                    TargetStartDist = Dist
                elseif Settings.AntiStuckActive and (Dist > DesiredDist or not ClearShot) and (tick() - TargetLockStartTime) >= 8 then
                    if Dist >= (TargetStartDist - 8) then
                        BlacklistedTargets[TargetModel] = tick() + 15
                        CurrentFarmTarget = nil
                        continue
                    else
                        TargetLockStartTime = tick()
                        TargetStartDist = Dist
                    end
                end

                BotStatusText = string.format("صيد %s (%s) • %dm", RarityStr or "", Tier or "", math.floor(Dist))

                if Alive then
                    if Settings.FarmAutoShoot and Dist <= DesiredDist and ClearShot then
                        ClearGlide()
                        Hum:MoveTo(MyRoot.Position)
                        MyRoot.CFrame = CFrame.new(MyRoot.Position, Vector3.new(TargetPart.Position.X, MyRoot.Position.Y, TargetPart.Position.Z))
                        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TargetPart.Position), 0.35)
                        FireWeapon(MyChar, Hum)
                    else
                        MoveTowardsTarget(MyChar, MyRoot, Hum, TargetPart.Position, (Settings.FarmMode == "GentleGlide"))
                    end
                else
                    if Dist > 7.5 then
                        MoveTowardsTarget(MyChar, MyRoot, Hum, TargetPart.Position, (Settings.FarmMode == "GentleGlide"))
                    else
                        ClearGlide()
                        Hum:MoveTo(MyRoot.Position)
                        if Settings.FarmAutoPickup then
                            local PromptFired = false
                            for _, desc in ipairs(TargetModel:GetDescendants()) do
                                if desc:IsA("ProximityPrompt") and desc.Enabled and type(fireproximityprompt) == "function" then
                                    pcall(function() fireproximityprompt(desc) end)
                                    PromptFired = true
                                end
                            end
                            if PromptFired and not CountedPickedDhabs[TargetModel] then
                                CountedPickedDhabs[TargetModel] = true
                                SessionStats.TotalCaught = SessionStats.TotalCaught + 1
                                if Tier == "T5" then SessionStats.T5Caught = SessionStats.T5Caught + 1 end
                                if Tier == "T6" then SessionStats.T6Caught = SessionStats.T6Caught + 1 end
                            end
                        end
                    end
                end
                continue
            else
                CurrentFarmTarget = nil
                if not Settings.PatrolActive then
                    BotStatusText = "يبحث عن هدف في النطاق... 🔍"
                end
            end
        end

        -- 4. Execute Deep Circle Patrol (Car Flight or Walking)
        if Settings.PatrolActive and PatrolCenter then
            local Scales = {1.0, 0.60, 0.30}
            local CurrentRadius = Settings.PatrolRadius * Scales[PatrolRingIndex]
            local GoalX = PatrolCenter.X + math.cos(PatrolAngle) * CurrentRadius
            local GoalZ = PatrolCenter.Z + math.sin(PatrolAngle) * CurrentRadius
            local GoalPos = Vector3.new(GoalX, PatrolCenter.Y, GoalZ)

            local UseCarNow = (Seat ~= nil and Settings.CarPatrolFly)
            local ReachDist = UseCarNow and 35 or 12

            BotStatusText = (UseCarNow and "طيران سيارة" or "دوران مشي") .. " (حلقة " .. tostring(PatrolRingIndex) .. "/3) 🧭"

            if (Vector3.new(GoalPos.X, MyRoot.Position.Y, GoalPos.Z) - MyRoot.Position).Magnitude <= ReachDist then
                PatrolAngle = PatrolAngle + 0.45
                if PatrolAngle >= math.pi * 2 then
                    PatrolAngle = 0
                    PatrolRingIndex = (PatrolRingIndex % 3) + 1
                end
            else
                if UseCarNow then
                    local RingSpeedFactor = (PatrolRingIndex == 3) and 0.65 or 1.0
                    MoveCarTowardsTarget(Seat, GoalPos, Settings.CarPatrolSpeed * RingSpeedFactor)
                else
                    ClearCarFlight()
                    MoveTowardsTarget(MyChar, MyRoot, Hum, Vector3.new(GoalX, MyRoot.Position.Y, GoalZ), (Settings.FarmMode == "GentleGlide"))
                end
            end
        else
            ClearGlide()
            if not Settings.AutoFarmActive then
                BotStatusText = "جاهز (Idle)"
            end
        end
    end
    ClearGlide()
end)

-- ESP, Chams, Discord Rare Alerts & Dashboard HUD Update Loop
task.spawn(function()
    while overlayGui.Parent do
        task.wait(0.3)
        local MyChar = LP.Character
        local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
        if not MyRoot then continue end

        local RareListText = {}

        for Model, Cat in pairs(TrackedEntities) do
            if not Model.Parent then
                CleanupEntityVisuals(Model)
                continue
            end
            local Part = GetPart(Model)
            if not Part then continue end

            local Dist = math.floor((Part.Position - MyRoot.Position).Magnitude)
            local ShouldShow = false
            local LabelText = ""
            local LabelColor = Colors.White

            if Cat == "Dhab" then
                local StateStr, RarityStr, Tier, Alive = GetDhabInfo(Model)
                if Tier then
                    local IsRare = (Tier == "T5" or Tier == "T6")
                    if IsRare and Alive then
                        table.insert(RareListText, string.format("• %s (%s) — %dm", RarityStr, Tier, Dist))
                        if not NotifiedRareDhabs[Model] then
                            NotifiedRareDhabs[Model] = true
                            if Settings.SmartAlerts then
                                pcall(function() NotifySound:Play() end)
                                Notify("👑 رصد ضب نادر!", string.format("ظهر ضب %s (%s) على بعد %d متر!", RarityStr, Tier, Dist), 4)
                            end
                            local EmbedColor = (Tier == "T6") and 16723275 or 16759085
                            SendDiscordWebhook(
                                string.format("👑 رصد ضب %s (%s)!", RarityStr, Tier),
                                string.format("تم رصد ضب **%s (%s)** على بُعد **%d متر** من موقعك.", RarityStr, Tier, Dist),
                                EmbedColor
                            )
                        end
                    end

                    UpdateCham(Model, (Settings.RareChams and IsRare and Dist <= Settings.EspDistance), RarityColors[Tier] or Colors.White)

                    if Dist <= Settings.EspDistance then
                        if Settings.DhabAll or (Settings.DhabRareOnly and IsRare) then
                            ShouldShow = true
                            LabelColor = RarityColors[Tier] or Colors.White
                            LabelText = string.format("[%s - %s]\n%s | %dm", Tier, RarityStr, StateStr, Dist)
                        end
                    end
                end
            elseif Cat == "Player" and Settings.Players and Dist <= Settings.EspDistance then
                ShouldShow = true
                LabelColor = Colors.PlayerColor
                LabelText = string.format("👤 %s\n%dm", Model.Name, Dist)
            elseif Cat == "Vehicle" and Settings.Vehicles and Dist <= Settings.EspDistance then
                ShouldShow = true
                LabelColor = Colors.VehicleColor
                LabelText = string.format("🚗 %s\n%dm", Model.Name, Dist)
            elseif Cat == "ShopEzba" and Settings.ShopEzba and Dist <= Settings.EspDistance then
                ShouldShow = true
                LabelColor = Colors.ShopColor
                LabelText = string.format("⛺ محل العزب\n%dm", Dist)
            elseif Cat == "Edge" and Settings.Edge and Dist <= Settings.EspDistance then
                ShouldShow = true
                LabelColor = Colors.EdgeColor
                LabelText = string.format("⚠️ حافة العالم\n%dm", Dist)
            end

            if ShouldShow then
                local bb = GetOrCreateBillboard(Model)
                if bb and bb:FindFirstChild("InfoLabel") then
                    bb.Enabled = true
                    bb.InfoLabel.Text = LabelText
                    bb.InfoLabel.TextColor3 = LabelColor
                end
            elseif EspCache[Model] then
                EspCache[Model].Enabled = false
            end
        end

        if Settings.RareHudActive then
            HudStatsLabel.Text = string.format(
                "الحالة: %s | ⏱️ %s\n🟠 T5: %d  |  🔴 T6: %d  |  🎒 الكل: %d",
                BotStatusText,
                FormatTime(tick() - SessionStartTime),
                SessionStats.T5Caught,
                SessionStats.T6Caught,
                SessionStats.TotalCaught
            )

            if #RareListText > 0 then
                RareHudContent.Text = table.concat(RareListText, "\n")
            else
                RareHudContent.Text = "لا يوجد ضب أسطوري أو خرافي حي قريب حالياً."
            end
        end
    end
end)

-- Smooth Aimbot (Supports Abu Mashlah Only & Auto-Farm Lock), FOV, Tracers & Boost
local RenderStepName = "kizithebusy_ProRender"
pcall(function() RunService:UnbindFromRenderStep(RenderStepName) end)

RunService:BindToRenderStep(RenderStepName, Enum.RenderPriority.Camera.Value + 1, function()
    if not overlayGui.Parent then
        if FOVCircle then pcall(function() FOVCircle:Remove() end) end
        for _, line in pairs(TracerCache) do
            pcall(function() line:Remove() end)
        end
        table.clear(TracerCache)
        pcall(function() RunService:UnbindFromRenderStep(RenderStepName) end)
        return
    end

    Camera = Workspace.CurrentCamera
    if not Camera then return end

    local Viewport = Camera.ViewportSize
    local CenterScreen = Vector2.new(Viewport.X / 2, Viewport.Y / 2)
    local BottomCenter = Vector2.new(Viewport.X / 2, Viewport.Y - 25)

    local MyChar = LP.Character
    local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
    local Hum = MyChar and MyChar:FindFirstChildOfClass("Humanoid")

    -- Gentle Vehicle Boost
    if Settings.VehicleBoostActive and Hum and Hum.SeatPart and Hum.SeatPart:IsA("VehicleSeat") then
        Hum.SeatPart.MaxSpeed = Settings.VehicleMaxSpeed
    end

    -- 2D Rare Tracers (T5 & T6)
    if HasDrawing then
        for Model, Cat in pairs(TrackedEntities) do
            if Cat == "Dhab" and Model.Parent and Settings.RareTracers and MyRoot then
                local _, _, Tier, Alive = GetDhabInfo(Model)
                local Part = GetPart(Model)
                if (Tier == "T5" or Tier == "T6") and Alive and Part and (Part.Position - MyRoot.Position).Magnitude <= Settings.EspDistance then
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                    if OnScreen then
                        local line = TracerCache[Model]
                        if not line then
                            line = Drawing.new("Line")
                            line.Thickness = 1.6
                            line.Transparency = 0.8
                            TracerCache[Model] = line
                        end
                        line.From = BottomCenter
                        line.To = Vector2.new(ScreenPos.X, ScreenPos.Y)
                        line.Color = RarityColors[Tier] or DarkTheme.Glow
                        line.Visible = true
                    elseif TracerCache[Model] then
                        TracerCache[Model].Visible = false
                    end
                elseif TracerCache[Model] then
                    TracerCache[Model].Visible = false
                end
            elseif TracerCache[Model] then
                TracerCache[Model].Visible = false
            end
        end
    end

    -- Priority 1: Dedicated Abu Mashlah Kite Farm Camera Lock & Auto-Fire
    if Settings.AutoFarmMashlah and ActiveMashlahTarget and ActiveMashlahTarget.Parent and MyRoot and Hum then
        local DesiredCFrame = CFrame.new(Camera.CFrame.Position, ActiveMashlahTarget.Position)
        Camera.CFrame = Camera.CFrame:Lerp(DesiredCFrame, math.max(Settings.AimbotSmoothness, 0.35))
        if Settings.MashlahAutoShoot then
            FireWeapon(MyChar, Hum)
        end
        if FOVCircle then
            FOVCircle.Position = CenterScreen
            FOVCircle.Radius = Settings.FOVRadius
            FOVCircle.Color = DarkTheme.Locked
            FOVCircle.Visible = Settings.UseFOVCircle
        end
        return
    end

    -- Priority 2: Standard Smooth Aimbot (Dhab or Abu Mashlah Only)
    local AimbotActiveNow = Settings.Aimbot and MyRoot
    if AimbotActiveNow and Settings.HoldRightClick then
        AimbotActiveNow = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    end
    if AimbotActiveNow and Settings.RequireWeapon and not MyChar:FindFirstChildOfClass("Tool") then
        AimbotActiveNow = false
    end

    local ClosestPart = nil
    if AimbotActiveNow then
        local ClosestScreenDist = Settings.UseFOVCircle and Settings.FOVRadius or math.huge
        for Model, Cat in pairs(TrackedEntities) do
            if Model.Parent then
                local ValidTarget = false
                if Settings.AimbotMashlahOnly then
                    ValidTarget = (Cat == "Monster" and IsMashlahModel(Model) and IsMonsterAlive(Model))
                elseif Cat == "Dhab" then
                    local _, _, Tier, Alive = GetDhabInfo(Model)
                    ValidTarget = (Alive and (not Settings.AimbotRareOnly or Tier == "T5" or Tier == "T6"))
                end

                if ValidTarget then
                    local Part = GetPart(Model)
                    if Part and (Part.Position - MyRoot.Position).Magnitude <= Settings.AimbotDistance then
                        local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                        if OnScreen then
                            local ScreenDist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - CenterScreen).Magnitude
                            if ScreenDist < ClosestScreenDist then
                                ClosestScreenDist = ScreenDist
                                ClosestPart = Part
                            end
                        end
                    end
                end
            end
        end

        if ClosestPart then
            local TargetPos = ClosestPart.Position
            if Settings.UseErrorMargin then
                local ErrorScale = (100 - Settings.AimAccuracy) * 0.04
                local Offset = Vector3.new(
                    math.sin(tick() * 3.1) * ErrorScale,
                    math.cos(tick() * 2.7) * ErrorScale,
                    math.sin(tick() * 2.3) * ErrorScale
                )
                TargetPos = TargetPos + Offset
            end
            local DesiredCFrame = CFrame.new(Camera.CFrame.Position, TargetPos)
            Camera.CFrame = Camera.CFrame:Lerp(DesiredCFrame, Settings.AimbotSmoothness)
            if Settings.FarmAutoShoot then
                FireWeapon(MyChar, Hum)
            end
        end
    end

    if FOVCircle then
        FOVCircle.Position = CenterScreen
        FOVCircle.Radius = Settings.FOVRadius
        FOVCircle.Color = ClosestPart and DarkTheme.Locked or DarkTheme.Glow
        FOVCircle.Visible = (Settings.Aimbot and Settings.UseFOVCircle)
    end
end)

Notify(CONFIG.HubName, "تم تحميل النسخة الاحترافية (V7) بنجاح!", 4)
