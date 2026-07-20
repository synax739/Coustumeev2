-- DELTA EXECUTOR - GERÇEK KARAKTER KOPYALAMA (R6/R15)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- ===== AKSESUAR KOPYALAMA (DERİNLEMESİNE) =====
local function copyAccessories(fromChar, toChar)
    -- Eski aksesuarları temizle
    for _, child in pairs(toChar:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Hat") or 
           child:IsA("Model") and (child.Name:match("Hat") or child.Name:match("Accessory") or child.Name:match("Face")) then
            child:Destroy()
        end
    end
    
    local count = 0
    -- Tüm aksesuarları tara (derinlemesine)
    for _, acc in pairs(fromChar:GetChildren()) do
        -- Aksesuar kontrolü
        if acc:IsA("Accessory") or acc:IsA("Hat") then
            local clone = acc:Clone()
            clone.Parent = toChar
            
            -- Handle'ı düzenle
            if clone:FindFirstChild("Handle") then
                local handle = clone.Handle
                local origHandle = acc:FindFirstChild("Handle")
                if origHandle then
                    handle.Color = origHandle.Color
                    handle.Material = origHandle.Material
                    handle.Transparency = origHandle.Transparency
                    handle.Size = origHandle.Size
                end
            end
            count = count + 1
        end
        
        -- Model içindeki aksesuarlar (Face, Hat vs)
        if acc:IsA("Model") then
            for _, subAcc in pairs(acc:GetChildren()) do
                if subAcc:IsA("Accessory") or subAcc:IsA("Hat") or 
                   subAcc:IsA("Part") and (subAcc.Name:match("Face") or subAcc.Name:match("Hat")) then
                    local clone = subAcc:Clone()
                    clone.Parent = toChar
                    count = count + 1
                end
            end
        end
    end
    
    return count
end

-- ===== GİYSİ KOPYALAMA =====
local function copyClothing(fromHumanoid, toHumanoid)
    if not fromHumanoid or not toHumanoid then return end
    
    -- Shirt
    if fromHumanoid:FindFirstChild("Shirt") then
        local shirt = fromHumanoid.Shirt:Clone()
        shirt.Parent = toHumanoid
    end
    
    -- Pants
    if fromHumanoid:FindFirstChild("Pants") then
        local pants = fromHumanoid.Pants:Clone()
        pants.Parent = toHumanoid
    end
    
    -- ShirtGraphic
    if fromHumanoid:FindFirstChild("ShirtGraphic") then
        local graphic = fromHumanoid.ShirtGraphic:Clone()
        graphic.Parent = toHumanoid
    end
    
    -- TShirt
    if fromHumanoid:FindFirstChild("TShirt") then
        local tshirt = fromHumanoid.TShirt:Clone()
        tshirt.Parent = toHumanoid
    end
end

-- ===== ANA KOPYALAMA =====
local function copyCharacter(targetPlayer)
    local targetChar = targetPlayer.Character
    if not targetChar then
        return "❌ Hedef karakter yok!"
    end
    
    local myChar = player.Character
    if not myChar then
        return "❌ Senin karakterin yok!"
    end
    
    local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
    local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
    
    if not myHumanoid or not targetHumanoid then
        return "❌ Humanoid bulunamadı!"
    end
    
    -- 1. BODYCOLORS (TEN RENGİ)
    local myColors = myHumanoid:FindFirstChild("BodyColors")
    local targetColors = targetHumanoid:FindFirstChild("BodyColors")
    
    if myColors and targetColors then
        myColors.HeadColor = targetColors.HeadColor
        myColors.TorsoColor = targetColors.TorsoColor
        myColors.LeftArmColor = targetColors.LeftArmColor
        myColors.RightArmColor = targetColors.RightArmColor
        myColors.LeftLegColor = targetColors.LeftLegColor
        myColors.RightLegColor = targetColors.RightLegColor
    end
    
    -- 2. VÜCUT PARÇALARI (RENK + MALZEME)
    local bodyParts = {"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg", "UpperTorso", "LowerTorso"}
    for _, name in pairs(bodyParts) do
        local tp = targetChar:FindFirstChild(name)
        local mp = myChar:FindFirstChild(name)
        if tp and mp then
            mp.Color = tp.Color
            mp.Material = tp.Material
            mp.Transparency = tp.Transparency
            mp.Reflectance = tp.Reflectance
        end
    end
    
    -- 3. GİYSİLER
    copyClothing(targetHumanoid, myHumanoid)
    
    -- 4. AKSESUARLAR
    local accCount = copyAccessories(targetChar, myChar)
    
    -- 5. ÖZEL PARÇALAR (Face, Body vs)
    for _, child in pairs(targetChar:GetChildren()) do
        if child:IsA("Model") and child.Name:match("Face") then
            local clone = child:Clone()
            clone.Parent = myChar
        end
    end
    
    return "✅ " .. targetPlayer.Name .. " kopyalandı! (" .. accCount .. " aksesuar)"
end

-- ===== PANEL =====
local gui = Instance.new("ScreenGui")
gui.Parent = player.PlayerGui
gui.Name = "KopyalamaPaneli"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 380, 0, 450)
frame.Position = UDim2.new(0.5, -190, 0.5, -225)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0, 200, 255)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

-- Başlık
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "🌀 GERÇEK KARAKTER KOPYALA"
title.TextColor3 = Color3.fromRGB(0, 220, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

-- Kapat
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 3)
close.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.Text = "✕"
close.Font = Enum.Font.GothamBold
close.TextSize = 16
close.Parent = frame
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Liste başlığı
local listLabel = Instance.new("TextLabel")
listLabel.Size = UDim2.new(0.9, 0, 0, 25)
listLabel.Position = UDim2.new(0.05, 0, 0, 40)
listLabel.Text = "📋 OYUNCULAR (Tıkla - Kopyala):"
listLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
listLabel.BackgroundTransparency = 1
listLabel.Font = Enum.Font.GothamBold
listLabel.TextSize = 13
listLabel.Parent = frame

-- Liste
local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(0.9, 0, 0, 250)
playerList.Position = UDim2.new(0.05, 0, 0, 70)
playerList.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
playerList.BackgroundTransparency = 0.3
playerList.BorderSizePixel = 1
playerList.BorderColor3 = Color3.fromRGB(0, 100, 200)
playerList.Parent = frame
playerList.CanvasSize = UDim2.new(0, 0, 0, 0)

-- Durum
local status = Instance.new("TextLabel")
status.Size = UDim2.new(0.9, 0, 0, 40)
status.Position = UDim2.new(0.05, 0, 0, 330)
status.Text = "Hazır"
status.TextColor3 = Color3.fromRGB(200, 200, 255)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.Parent = frame

-- Bilgi
local info = Instance.new("TextLabel")
info.Size = UDim2.new(0.9, 0, 0, 30)
info.Position = UDim2.new(0.05, 0, 0, 380)
info.Text = "💡 R6 ve R15 karakterler desteklenir"
info.TextColor3 = Color3.fromRGB(100, 200, 255)
info.BackgroundTransparency = 1
info.Font = Enum.Font.Gotham
info.TextSize = 11
info.Parent = frame

-- ===== LİSTEYİ DOLDUR =====
local function updateList()
    for _, child in pairs(playerList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local yPos = 5
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.9, 0, 0, 32)
            btn.Position = UDim2.new(0.05, 0, 0, yPos)
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 75)
            btn.TextColor3 = Color3.fromRGB(200, 200, 255)
            btn.Text = "👤 " .. p.Name
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 13
            btn.Parent = playerList
            
            btn.MouseButton1Click:Connect(function()
                status.Text = "⏳ Kopyalanıyor: " .. p.Name
                status.TextColor3 = Color3.fromRGB(255, 200, 0)
                
                local result = copyCharacter(p)
                status.Text = result
                if result:match("✅") then
                    status.TextColor3 = Color3.fromRGB(0, 255, 100)
                else
                    status.TextColor3 = Color3.fromRGB(255, 50, 50)
                end
            end)
            
            yPos = yPos + 37
        end
    end
    
    playerList.CanvasSize = UDim2.new(0, 0, 0, yPos + 10)
end

updateList()
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)

print("🌀 GERÇEK KARAKTER KOPYALAMA AKTİF!")
print("📌 R6/R15 desteği ile çalışır")
