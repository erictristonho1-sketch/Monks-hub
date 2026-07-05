-- ============================================
-- MONKYS HUB + AUTO DIVE (HUB NOVO)
-- Criado do zero, imitando a estrutura do Rytsu
-- ============================================

local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local ConfigFile = "RRR_Settings.json"

-- ============================================
-- CONFIGURAÇÃO INICIAL
-- ============================================
getgenv().RRR_Config = {
    Misc = {
        AutoGoal = { Enabled = false, Key = "G", Type = "New" },
        AutoSteal = { Enabled = false, Key = "F" },
        PowerShot = { Enabled = false, Power = "230", Effect = false, Effect2 = false, HoldTime = "0.47" }
    },
    Player = {
        CancelCutscene = { Enabled = false, Key = "C" },
        FakeFlow = false,
        FakeMetavision = false,
        SkillOnGkBox = false,
        AutoDive = { Enabled = false, Key = "V" }
    }
}

local BlacklistedKeys = {["W"]=true,["A"]=true,["S"]=true,["D"]=true,["Space"]=true}

local function Save()
    if writefile then 
        pcall(function() 
            writefile(ConfigFile, HttpService:JSONEncode(getgenv().RRR_Config)) 
        end) 
    end
end

local function Load()
    if isfile and isfile(ConfigFile) then
        local s, decoded = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
        if s and type(decoded) == "table" then
            for cat, content in pairs(decoded) do
                if getgenv().RRR_Config[cat] then
                    for key, val in pairs(content) do 
                        getgenv().RRR_Config[cat][key] = val 
                    end
                end
            end
        end
    end
end
Load()

-- ============================================
-- INTERFACE
-- ============================================
local RRR = Instance.new("ScreenGui")
RRR.Name = "RRR_Hub"
RRR.ResetOnSpawn = false
pcall(function() RRR.Parent = CoreGui end)
if not RRR.Parent then RRR.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local Drag = Instance.new("ImageLabel")
Drag.Name = "MainFrame"
Drag.Size = UDim2.new(0, 520, 0, 350)
Drag.Position = UDim2.new(0.5, -260, 0.5, -175)
Drag.Image = "rbxassetid://132146341566959"
Drag.BackgroundTransparency = 1
Drag.Active = true
Drag.Parent = RRR

local Main = Instance.new("ImageLabel")
Main.Size = UDim2.new(0.78, 0, 0.82, 0)
Main.Position = UDim2.new(0.18, 0, 0.14, 0)
Main.Image = "rbxassetid://116118555895648"
Main.BackgroundTransparency = 1
Main.Parent = Drag

local function CreatePage()
    local pg = Instance.new("ScrollingFrame")
    pg.Size = UDim2.new(1, -10, 1, -10)
    pg.BackgroundTransparency = 1
    pg.BorderSizePixel = 0
    pg.ScrollBarThickness = 3
    pg.AutomaticCanvasSize = Enum.AutomaticSize.Y
    pg.Visible = false
    pg.Parent = Main
    local layout = Instance.new("UIListLayout", pg)
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    return pg
end

local MiscPage = CreatePage()
local PlayerPage = CreatePage()
MiscPage.Visible = true

local function AddCheat(parent, text, category, configKey, hasBind)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(45, 65, 110)
    frame.BackgroundTransparency = 0.3
    frame.Parent = parent
    Instance.new("UICorner", frame)

    local label = Instance.new("TextLabel")
    label.Text = "  " .. text
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 18
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.16, 0, 0.62, 0)
    btn.Position = UDim2.new(0.81, 0, 0.18, 0)
    btn.TextScaled = true
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    if hasBind then
        local bBtn = Instance.new("TextButton")
        bBtn.Size = UDim2.new(0.18, 0, 0.55, 0)
        bBtn.Position = UDim2.new(0.58, 0, 0.22, 0)
        bBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        bBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        bBtn.Text = tostring(getgenv().RRR_Config[category][configKey].Key):gsub("Button", "")
        bBtn.Parent = frame
        Instance.new("UICorner", bBtn)

        bBtn.MouseButton1Click:Connect(function()
            bBtn.Text = "..."
            local input = UserInputService.InputBegan:Wait()
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local kn = input.KeyCode.Name
                if not BlacklistedKeys[kn] then
                    getgenv().RRR_Config[category][configKey].Key = kn
                    bBtn.Text = kn
                    Save()
                else
                    bBtn.Text = tostring(getgenv().RRR_Config[category][configKey].Key):gsub("Button", "")
                end
            end
        end)
    end

    local function update()
        local val = getgenv().RRR_Config[category][configKey]
        if type(val) == "table" then val = val.Enabled end
        btn.Text = val and "ON" or "OFF"
        btn.BackgroundColor3 = val and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    end

    update()
    btn.MouseButton1Click:Connect(function()
        local d = getgenv().RRR_Config[category][configKey]
        if type(d) == "table" then d.Enabled = not d.Enabled else getgenv().RRR_Config[category][configKey] = not d end
        update()
        Save()
    end)
end

local UpBar = Instance.new("ImageLabel", Drag)
UpBar.Size = UDim2.new(1, 0, 0.22, 0)
UpBar.Position = UDim2.new(0, 0, -0.08, 0)
UpBar.Image = "rbxassetid://74857124519074"
UpBar.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", UpBar)
Title.Text = "R.R.R HUB · Meta Lock"
Title.Position = UDim2.new(0.05, 0, 0.2, 0)
Title.Size = UDim2.new(0.8, 0, 0.6, 0)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 25
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("ImageButton", UpBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 25)
CloseBtn.Position = UDim2.new(0.9, 0, 0.3, 0)
CloseBtn.Image = "rbxassetid://138567149317610"
CloseBtn.BackgroundTransparency = 1
CloseBtn.MouseButton1Click:Connect(function() Drag.Visible = false end)

local Side = Instance.new("Frame", Drag)
Side.Size = UDim2.new(0.15, 0, 0.5, 0)
Side.Position = UDim2.new(0.02, 0, 0.18, 0)
Side.BackgroundTransparency = 1
Instance.new("UIListLayout", Side).Padding = UDim.new(0, 10)

local function MakeTab(t, p)
    local b = Instance.new("TextButton", Side)
    b.Size = UDim2.new(1, 0, 0, 35)
    b.BackgroundTransparency = 1
    b.Text = t
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 22
    b.MouseButton1Click:Connect(function()
        MiscPage.Visible = (p == MiscPage)
        PlayerPage.Visible = (p == PlayerPage)
    end)
end

MakeTab("Misc", MiscPage)
MakeTab("Player", PlayerPage)

AddCheat(MiscPage, "Auto Steal", "Misc", "AutoSteal", true)
AddCheat(MiscPage, "Auto Goal", "Misc", "AutoGoal", true)
AddCheat(PlayerPage, "Cancel Cutscene", "Player", "CancelCutscene", true)
AddCheat(PlayerPage, "Fake Flow", "Player", "FakeFlow", false)
AddCheat(PlayerPage, "Fake Metavision", "Player", "FakeMetavision", false)
AddCheat(PlayerPage, "Auto Dive", "Player", "AutoDive", true)

-- DRAG
local dS, sP, dragging
Drag.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dS = i.Position
        sP = Drag.Position
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - dS
        Drag.Position = UDim2.new(sP.X.Scale, sP.X.Offset + delta.X, sP.Y.Scale, sP.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- TOGGLE COM Z
UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.Z then
        Drag.Visible = not Drag.Visible
    end
end)

-- ============================================
-- FUNÇÕES DOS CHEATS
-- ============================================
local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")
local DiveRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Dive")

local Ativo = { Steal = false, Goal = false, Dive = false }

local function getHRP()
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

local function getBall()
    return workspace:FindFirstChild("Ball")
end

local function tpSeguro(pos)
    local hrp = getHRP()
    if not hrp then return end
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.CFrame = pos
end

-- AUTO STEAL (IGUAL AO RYTSU)
local function autoSteal()
    local cfg = getgenv().RRR_Config
    if cfg.Misc.AutoSteal.Enabled ~= true or Ativo.Steal then return end
    local hrp, ball = getHRP(), getBall()
    if not (hrp and ball) then return end
    
    Ativo.Steal = true
    local oldPos = hrp.CFrame
    local startTime = tick()

    while ball and ball.Parent and (tick() - startTime < 1.2) do
        local state = ball:GetAttribute("State")
        if state == "UNTOUCHABLE" or state == player.Name then break end
        
        tpSeguro(CFrame.new(ball.Position + (ball.AssemblyLinearVelocity * 0.15) + Vector3.new(0,2,0)))
        Tackle:FireServer()
        task.wait(0.03)
    end

    task.wait(0.1)
    tpSeguro(oldPos)
    Ativo.Steal = false
end

-- AUTO DIVE (MESMO PADRÃO DO AUTO STEAL)
local function autoDive()
    local cfg = getgenv().RRR_Config
    if cfg.Player.AutoDive.Enabled ~= true or Ativo.Dive then return end
    local hrp, ball = getHRP(), getBall()
    if not (hrp and ball) then return end
    
    Ativo.Dive = true
    local oldPos = hrp.CFrame
    local startTime = tick()

    while ball and ball.Parent and (tick() - startTime < 1.2) do
        local state = ball:GetAttribute("State")
        if state == "UNTOUCHABLE" or state == player.Name then break end
        
        tpSeguro(CFrame.new(ball.Position + (ball.AssemblyLinearVelocity * 0.15) + Vector3.new(0,1,0)))
        DiveRemote:FireServer()
        task.wait(0.03)
    end

    task.wait(0.1)
    tpSeguro(oldPos)
    Ativo.Dive = false
end

-- AUTO GOAL (BÁSICO)
local function autoGoal()
    local cfg = getgenv().RRR_Config
    if cfg.Misc.AutoGoal.Enabled ~= true or Ativo.Goal then return end
    local hrp, ball = getHRP(), getBall()
    if not (hrp and ball) then return end
    
    Ativo.Goal = true
    local oldPos = hrp.CFrame
    local startTime = tick()

    while ball and ball.Parent and (tick() - startTime < 1.2) do
        local state = ball:GetAttribute("State")
        if state == "UNTOUCHABLE" or state == player.Name then break end
        
        tpSeguro(CFrame.new(ball.Position + (ball.AssemblyLinearVelocity * 0.15) + Vector3.new(0,2,0)))
        Tackle:FireServer()
        task.wait(0.03)
    end

    task.wait(0.5)
    tpSeguro(oldPos)
    Ativo.Goal = false
end

-- ============================================
-- INPUTS
-- ============================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local cfg = getgenv().RRR_Config
    local key = input.KeyCode.Name
    
    if key == tostring(cfg.Misc.AutoSteal.Key) then task.spawn(autoSteal)
    elseif key == tostring(cfg.Misc.AutoGoal.Key) then task.spawn(autoGoal)
    elseif key == tostring(cfg.Player.AutoDive.Key) then task.spawn(autoDive)
    end
end)

print(">> MonkysHub + Auto Dive ✅ CARREGADO!")
-- ============================================
-- MONKYS HUB + AUTO DIVE (HUB NOVO)
-- Criado do zero, imitando a estrutura do Rytsu
-- ============================================

local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local ConfigFile = "RRR_Settings.json"

-- ============================================
-- CONFIGURAÇÃO INICIAL
-- ============================================
getgenv().RRR_Config = {
    Misc = {
        AutoGoal = { Enabled = false, Key = "G", Type = "New" },
        AutoSteal = { Enabled = false, Key = "F" },
        PowerShot = { Enabled = false, Power = "230", Effect = false, Effect2 = false, HoldTime = "0.47" }
    },
    Player = {
        CancelCutscene = { Enabled = false, Key = "C" },
        FakeFlow = false,
        FakeMetavision = false,
        SkillOnGkBox = false,
        AutoDive = { Enabled = false, Key = "V" }
    }
}

local BlacklistedKeys = {["W"]=true,["A"]=true,["S"]=true,["D"]=true,["Space"]=true}

local function Save()
    if writefile then 
        pcall(function() 
            writefile(ConfigFile, HttpService:JSONEncode(getgenv().RRR_Config)) 
        end) 
    end
end

local function Load()
    if isfile and isfile(ConfigFile) then
        local s, decoded = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
        if s and type(decoded) == "table" then
            for cat, content in pairs(decoded) do
                if getgenv().RRR_Config[cat] then
                    for key, val in pairs(content) do 
                        getgenv().RRR_Config[cat][key] = val 
                    end
                end
            end
        end
    end
end
Load()

-- ============================================
-- INTERFACE
-- ============================================
local RRR = Instance.new("ScreenGui")
RRR.Name = "RRR_Hub"
RRR.ResetOnSpawn = false
pcall(function() RRR.Parent = CoreGui end)
if not RRR.Parent then RRR.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local Drag = Instance.new("ImageLabel")
Drag.Name = "MainFrame"
Drag.Size = UDim2.new(0, 520, 0, 350)
Drag.Position = UDim2.new(0.5, -260, 0.5, -175)
Drag.Image = "rbxassetid://132146341566959"
Drag.BackgroundTransparency = 1
Drag.Active = true
Drag.Parent = RRR

local Main = Instance.new("ImageLabel")
Main.Size = UDim2.new(0.78, 0, 0.82, 0)
Main.Position = UDim2.new(0.18, 0, 0.14, 0)
Main.Image = "rbxassetid://116118555895648"
Main.BackgroundTransparency = 1
Main.Parent = Drag

local function CreatePage()
    local pg = Instance.new("ScrollingFrame")
    pg.Size = UDim2.new(1, -10, 1, -10)
    pg.BackgroundTransparency = 1
    pg.BorderSizePixel = 0
    pg.ScrollBarThickness = 3
    pg.AutomaticCanvasSize = Enum.AutomaticSize.Y
    pg.Visible = false
    pg.Parent = Main
    local layout = Instance.new("UIListLayout", pg)
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    return pg
end

local MiscPage = CreatePage()
local PlayerPage = CreatePage()
MiscPage.Visible = true

local function AddCheat(parent, text, category, configKey, hasBind)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(45, 65, 110)
    frame.BackgroundTransparency = 0.3
    frame.Parent = parent
    Instance.new("UICorner", frame)

    local label = Instance.new("TextLabel")
    label.Text = "  " .. text
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 18
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.16, 0, 0.62, 0)
    btn.Position = UDim2.new(0.81, 0, 0.18, 0)
    btn.TextScaled = true
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    if hasBind then
        local bBtn = Instance.new("TextButton")
        bBtn.Size = UDim2.new(0.18, 0, 0.55, 0)
        bBtn.Position = UDim2.new(0.58, 0, 0.22, 0)
        bBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        bBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        bBtn.Text = tostring(getgenv().RRR_Config[category][configKey].Key):gsub("Button", "")
        bBtn.Parent = frame
        Instance.new("UICorner", bBtn)

        bBtn.MouseButton1Click:Connect(function()
            bBtn.Text = "..."
            local input = UserInputService.InputBegan:Wait()
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local kn = input.KeyCode.Name
                if not BlacklistedKeys[kn] then
                    getgenv().RRR_Config[category][configKey].Key = kn
                    bBtn.Text = kn
                    Save()
                else
                    bBtn.Text = tostring(getgenv().RRR_Config[category][configKey].Key):gsub("Button", "")
                end
            end
        end)
    end

    local function update()
        local val = getgenv().RRR_Config[category][configKey]
        if type(val) == "table" then val = val.Enabled end
        btn.Text = val and "ON" or "OFF"
        btn.BackgroundColor3 = val and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    end

    update()
    btn.MouseButton1Click:Connect(function()
        local d = getgenv().RRR_Config[category][configKey]
        if type(d) == "table" then d.Enabled = not d.Enabled else getgenv().RRR_Config[category][configKey] = not d end
        update()
        Save()
    end)
end

local UpBar = Instance.new("ImageLabel", Drag)
UpBar.Size = UDim2.new(1, 0, 0.22, 0)
UpBar.Position = UDim2.new(0, 0, -0.08, 0)
UpBar.Image = "rbxassetid://74857124519074"
UpBar.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", UpBar)
Title.Text = "R.R.R HUB · Meta Lock"
Title.Position = UDim2.new(0.05, 0, 0.2, 0)
Title.Size = UDim2.new(0.8, 0, 0.6, 0)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 25
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("ImageButton", UpBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 25)
CloseBtn.Position = UDim2.new(0.9, 0, 0.3, 0)
CloseBtn.Image = "rbxassetid://138567149317610"
CloseBtn.BackgroundTransparency = 1
CloseBtn.MouseButton1Click:Connect(function() Drag.Visible = false end)

local Side = Instance.new("Frame", Drag)
Side.Size = UDim2.new(0.15, 0, 0.5, 0)
Side.Position = UDim2.new(0.02, 0, 0.18, 0)
Side.BackgroundTransparency = 1
Instance.new("UIListLayout", Side).Padding = UDim.new(0, 10)

local function MakeTab(t, p)
    local b = Instance.new("TextButton", Side)
    b.Size = UDim2.new(1, 0, 0, 35)
    b.BackgroundTransparency = 1
    b.Text = t
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 22
    b.MouseButton1Click:Connect(function()
        MiscPage.Visible = (p == MiscPage)
        PlayerPage.Visible = (p == PlayerPage)
    end)
end

MakeTab("Misc", MiscPage)
MakeTab("Player", PlayerPage)

AddCheat(MiscPage, "Auto Steal", "Misc", "AutoSteal", true)
AddCheat(MiscPage, "Auto Goal", "Misc", "AutoGoal", true)
AddCheat(PlayerPage, "Cancel Cutscene", "Player", "CancelCutscene", true)
AddCheat(PlayerPage, "Fake Flow", "Player", "FakeFlow", false)
AddCheat(PlayerPage, "Fake Metavision", "Player", "FakeMetavision", false)
AddCheat(PlayerPage, "Auto Dive", "Player", "AutoDive", true)

-- DRAG
local dS, sP, dragging
Drag.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dS = i.Position
        sP = Drag.Position
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - dS
        Drag.Position = UDim2.new(sP.X.Scale, sP.X.Offset + delta.X, sP.Y.Scale, sP.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- TOGGLE COM Z
UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.Z then
        Drag.Visible = not Drag.Visible
    end
end)

-- ============================================
-- FUNÇÕES DOS CHEATS
-- ============================================
local Shoot = ReplicatedStorage:WaitForChild("ShootRE")
local Tackle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tackle")
local DiveRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Dive")

local Ativo = { Steal = false, Goal = false, Dive = false }

local function getHRP()
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

local function getBall()
    return workspace:FindFirstChild("Ball")
end

local function tpSeguro(pos)
    local hrp = getHRP()
    if not hrp then return end
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.CFrame = pos
end

-- AUTO STEAL (IGUAL AO RYTSU)
local function autoSteal()
    local cfg = getgenv().RRR_Config
    if cfg.Misc.AutoSteal.Enabled ~= true or Ativo.Steal then return end
    local hrp, ball = getHRP(), getBall()
    if not (hrp and ball) then return end
    
    Ativo.Steal = true
    local oldPos = hrp.CFrame
    local startTime = tick()

    while ball and ball.Parent and (tick() - startTime < 1.2) do
        local state = ball:GetAttribute("State")
        if state == "UNTOUCHABLE" or state == player.Name then break end
        
        tpSeguro(CFrame.new(ball.Position + (ball.AssemblyLinearVelocity * 0.15) + Vector3.new(0,2,0)))
        Tackle:FireServer()
        task.wait(0.03)
    end

    task.wait(0.1)
    tpSeguro(oldPos)
    Ativo.Steal = false
end

-- AUTO DIVE (MESMO PADRÃO DO AUTO STEAL)
local function autoDive()
    local cfg = getgenv().RRR_Config
    if cfg.Player.AutoDive.Enabled ~= true or Ativo.Dive then return end
    local hrp, ball = getHRP(), getBall()
    if not (hrp and ball) then return end
    
    Ativo.Dive = true
    local oldPos = hrp.CFrame
    local startTime = tick()

    while ball and ball.Parent and (tick() - startTime < 1.2) do
        local state = ball:GetAttribute("State")
        if state == "UNTOUCHABLE" or state == player.Name then break end
        
        tpSeguro(CFrame.new(ball.Position + (ball.AssemblyLinearVelocity * 0.15) + Vector3.new(0,1,0)))
        DiveRemote:FireServer()
        task.wait(0.03)
    end

    task.wait(0.1)
    tpSeguro(oldPos)
    Ativo.Dive = false
end

-- AUTO GOAL (BÁSICO)
local function autoGoal()
    local cfg = getgenv().RRR_Config
    if cfg.Misc.AutoGoal.Enabled ~= true or Ativo.Goal then return end
    local hrp, ball = getHRP(), getBall()
    if not (hrp and ball) then return end
    
    Ativo.Goal = true
    local oldPos = hrp.CFrame
    local startTime = tick()

    while ball and ball.Parent and (tick() - startTime < 1.2) do
        local state = ball:GetAttribute("State")
        if state == "UNTOUCHABLE" or state == player.Name then break end
        
        tpSeguro(CFrame.new(ball.Position + (ball.AssemblyLinearVelocity * 0.15) + Vector3.new(0,2,0)))
        Tackle:FireServer()
        task.wait(0.03)
    end

    task.wait(0.5)
    tpSeguro(oldPos)
    Ativo.Goal = false
end

-- ============================================
-- INPUTS
-- ============================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local cfg = getgenv().RRR_Config
    local key = input.KeyCode.Name
    
    if key == tostring(cfg.Misc.AutoSteal.Key) then task.spawn(autoSteal)
    elseif key == tostring(cfg.Misc.AutoGoal.Key) then task.spawn(autoGoal)
    elseif key == tostring(cfg.Player.AutoDive.Key) then task.spawn(autoDive)
    end
end)

print(">> MonkysHub + Auto Dive ✅ CARREGADO!")
