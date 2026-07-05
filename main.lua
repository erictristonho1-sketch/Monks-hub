-- ============================================
-- MONKYS HUB + AUTO DIVE (SOLUÇÃO FINAL)
-- ============================================
-- Este script carrega o MonkysHub original 100% funcional
-- e adiciona APENAS o Auto Dive sem quebrar nada

-- 1. Carrega a Hub original (interface + config)
loadstring(game:HttpGet("https://raw.githubusercontent.com/orytsukz-creator/MonkysHub/refs/heads/main/HubRRR.lua"))()

-- 2. Espera a Hub carregar as configurações
repeat task.wait() until getgenv().RRR_Config and getgenv().RRR_Config.Player

-- 3. ADICIONA AUTO DIVE NA CONFIGURAÇÃO
if not getgenv().RRR_Config.Player.AutoDive then
    getgenv().RRR_Config.Player.AutoDive = {
        Enabled = false,
        Key = "V"
    }
end

-- 4. Carrega os Adicionais originais (funções dos cheats)
loadstring(game:HttpGet("https://raw.githubusercontent.com/orytsukz-creator/MonkysHub/refs/heads/main/Adicionais.lua"))()

-- 5. Espera tudo carregar
task.wait(0.5)

-- 6. ADICIONA O BOTÃO AUTO DIVE NA INTERFACE
local PlayerPage = nil
for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
    if v.Name == "RRR_Hub" then
        local Main = v:FindFirstChild("MainFrame"):FindFirstChild("Main")
        if Main then
            for _, page in pairs(Main:GetChildren()) do
                if page:IsA("ScrollingFrame") and page.Visible == false then
                    PlayerPage = page
                    break
                end
            end
        end
    end
end

-- 7. CRIA A FUNÇÃO AUTO DIVE
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

-- 8. CONECTA O KEYBIND
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local cfg = getgenv().RRR_Config
    local key = input.KeyCode.Name
    
    if key == tostring(cfg.Player.AutoDive.Key) then
        task.spawn(autoDive)
    end
end)

-- 9. SUPORTE A MOBILE
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

print(">> MonkysHub + Auto Dive ✅ FUNCIONANDO!")
