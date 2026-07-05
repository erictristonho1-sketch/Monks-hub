-- Carrega a Interface COM AUTO DIVE
loadstring(game:HttpGet("https://raw.githubusercontent.com/erictristonho1-sketch/Monks-hub/refs/heads/main/HubRRR_FINAL.lua"))()

-- Espera carregar
repeat task.wait() until getgenv().RRR_Config and getgenv().RRR_Config.Player

-- Carrega as Funções (com Auto Dive)
loadstring(game:HttpGet("https://raw.githubusercontent.com/erictristonho1-sketch/Monks-hub/refs/heads/main/Adicionais_FINAL.lua"))()

print(">> MonkysHub + Auto Dive ✅")
