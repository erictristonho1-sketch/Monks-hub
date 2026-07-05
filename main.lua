-- ============================================
-- MONKYS HUB + AUTO DIVE COM BOTÃO NA INTERFACE
-- ============================================

-- 1. Carrega a Hub original
loadstring(game:HttpGet("https://raw.githubusercontent.com/orytsukz-creator/MonkysHub/refs/heads/main/HubRRR.lua"))()

-- 2. Espera a Hub carregar
repeat task.wait() until getgenv().RRR_Config and getgenv().RRR_Config.Player

-- 3. ADICIONA AUTO DIVE NA CONFIGURAÇÃO
if not getgenv().RRR_Config.Player.AutoDive then
    getgenv().RRR_Config.Player.AutoDive = {
        Enabled = false,
        Key = "V"
    }
end

-- 4. Carrega os Adicionais originais
loadstring(game:HttpGet("https://raw.githubusercontent.com/orytsukz-creator/MonkysHub/refs/heads/main/Adicionais.lua"))()

-- 5. Espera tudo carregar
task.wait(1)

-- 6. ENCONTRA A INTERFACE E ADICIONA O BOTÃO AUTO DIVE
local CoreGui = game:GetService("CoreGui")
local PlayerPage = nil

for _, screenGui in pairs(CoreGui:GetChildren()) do
    if screenGui.Name == "RRR_Hub" then
        local MainFrame = screenGui:FindFirstChild("MainFrame")
        if MainFrame then
            local Main = MainFrame:FindFirstChild("Main")
            if Main then
                -- Encontra a página Player (segunda ScrollingFrame)
                local count = 0
                for _, page in pairs(Main:GetChildren()) do
                    if page:IsA("ScrollingFrame") then
                        count = count + 1
                        if count == 2 then
                            PlayerPage = page
                            break
                        end
                    end
                end
            end
        end
    end
end

-- 7. FUNÇÃO PARA CRIAR O BOTÃO AUTO DIVE
if PlayerPage then
    local function AddAutoDiveButton()
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.95, 0, 0, 45)
        frame.BackgroundColor3 = Color3.fromRGB(45, 65, 110)
        frame.BackgroundTransparency = 0.3
        frame.Parent = PlayerPage
        Instance.new("UICorner", frame)

        local label = Instance.new("TextLabel")
        label.Text = "  Auto Dive"
        label.Size = UDim2.new(0.4, 0, 1, 0)
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextSize = 18
        label.Parent = frame

        local bBtn = Instance.new("TextButton")
        bBtn.Size = UDim2.new(0.18, 0, 0.55, 0)
        bBtn.Position = UDim2.new(0.58, 0, 0.22, 0)
        bBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        bBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        bBtn.Text = "V"
        bBtn.Parent = frame
        Instance.new("UICorner", bBtn)

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.16, 0, 0.62, 0)
        btn.Position = UDim2.new(0.81, 0, 0.18, 0)
        btn.TextScaled = true
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Parent = frame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

        local function update()
            local val = getgenv().RRR_Config.Player.AutoDive.Enabled
            btn.Text = val and "ON" or "OFF"
            btn.BackgroundColor3 = val and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        end

        update()
        btn.MouseButton1Click:Connect(function()
            getgenv().RRR_Config.Player.AutoDive.Enabled = not getgenv().RRR_Config.Player.AutoDive.Enabled
            update()
        end)

        bBtn.MouseButton1Click:Connect(function()
            bBtn.Text = "..."
            local input = game:GetService("UserInputService").InputBegan:Wait()
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local kn = input.KeyCode.Name
                if kn ~= "W" and kn ~= "A" and kn ~= "S" and kn ~= "D" and kn ~= "Space" then
                    getgenv().RRR_Config.Player.AutoDive.Key = kn
                    bBtn.Text = kn
                else
                    bBtn.Text = "V"
                end
            end
        end)
    end

    AddAutoDiveButton()
end

-- 8. CRIA A FUNÇÃO AUTO DIVE
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

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

local DiveRemote = nil
pcall(function()
    DiveRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Dive")
end)

local DiveActive = false

local function autoDive()
    local cfg = getgenv().RRR_Config
    if cfg.Player.AutoDive.Enabled ~= true or DiveActive then return end
    
    local hrp, ball = getHRP(), getBall()
    if not (hrp and ball) then return end
    
    DiveActive = true
    local oldPos = hrp.CFrame
    local startTime = tick()

    while ball and ball.Parent and (tick() - startTime < 1.2) do
        local state = ball:GetAttribute("State")
        if state == "UNTOUCHABLE" or state == player.Name then break end
        
        tpSeguro(CFrame.new(ball.Position + (ball.AssemblyLinearVelocity * 0.15) + Vector3.new(0,1,0)))
        if DiveRemote then 
            pcall(function() DiveRemote:FireServer() end)
        end
        task.wait(0.03)
    end

    task.wait(0.1)
    tpSeguro(oldPos)
    DiveActive = false
end

-- 9. CONECTA O KEYBIND
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local cfg = getgenv().RRR_Config
    local key = input.KeyCode.Name
    
    if key == tostring(cfg.Player.AutoDive.Key) then
        task.spawn(autoDive)
    end
end)

-- 10. SUPORTE A MOBILE
if UIS.TouchEnabled then
    task.spawn(function()
        task.wait(1)
        local mobileGui = player:WaitForChild("PlayerGui"):WaitForChild("MobileSupport", 15)
        local frame = mobileGui and mobileGui:WaitForChild("Frame")
        local cfg = getgenv().RRR_Config
        
        if frame and cfg.Player.AutoDive then
            local diveBtn = frame:FindFirstChild(tostring(cfg.Player.AutoDive.Key))
            if diveBtn then 
                diveBtn.MouseButton1Click:Connect(function() task.spawn(autoDive) end) 
            end
        end
    end)
end

print(">> MonkysHub + Auto Dive COM BOTÃO ✅ FUNCIONANDO!")
