-- DELTA EXECUTOR - KARAKTER KOPYALAMA (BASİT)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- ===== KOPYALAMA FONKSİYONU =====
local function copyChar(target)
    local targetChar = target.Character
    if not targetChar then return end
    
    local myChar = player.Character
    if not myChar then return end
    
    -- Renkleri kopyala
    local parts = {"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}
    for _, p in pairs(parts) do
        local tp = targetChar:FindFirstChild(p)
        local mp = myChar:FindFirstChild(p)
        if tp and mp then
            mp.Color = tp.Color
            mp.Material = tp.Material
        end
    end
    
    -- Giysiler
    local th = targetChar:FindFirstChildOfClass("Humanoid")
    local mh = myChar:FindFirstChildOfClass("Humanoid")
    if th and mh then
        if th.Shirt then mh.Shirt = th.Shirt end
        if th.Pants then mh.Pants = th.Pants end
        if th.ShirtGraphic then mh.ShirtGraphic = th.ShirtGraphic end
    end
    
    -- Aksesuarları temizle
    for _, c in pairs(myChar:GetChildren()) do
        if c:IsA("Accessory") or c:IsA("Hat") then
            c:Destroy()
        end
    end
    
    -- Aksesuarları kopyala
    for _, acc in pairs(targetChar:GetChildren()) do
        if acc:IsA("Accessory") or acc:IsA("Hat") then
            local clone = acc:Clone()
            clone.Parent = myChar
        end
    end
end

-- ===== PANEL =====
local gui = Instance.new("ScreenGui")
gui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 350)
frame.Position = UDim2.new(0.5, -150, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0, 180, 255)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

-- Başlık
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🌀 KOPYALA"
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame

-- Kapatma butonu
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 25, 0, 25)
close.Position = UDim2.new(1, -30, 0, 3)
close.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.Parent = frame
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Input
local input = Instance.new("TextBox")
input.Size = UDim2.new(0.8, 0, 0, 30)
input.Position = UDim2.new(0.1, 0, 0, 35)
input.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
input.TextColor3 = Color3.fromRGB(255, 255, 255)
input.PlaceholderText = "İsim yaz..."
input.PlaceholderColor3 = Color3.fromRGB(150, 150, 180)
input.Font = Enum.Font.Gotham
input.TextSize = 14
input.Parent = frame

-- Buton
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0.5, 0, 0, 35)
btn.Position = UDim2.new(0.25, 0, 0, 75)
btn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Text = "KOPYALA"
btn.Font = Enum.Font.GothamBold
btn.TextSize = 15
btn.Parent = frame

-- Durum
local status = Instance.new("TextLabel")
status.Size = UDim2.new(0.9, 0, 0, 25)
status.Position = UDim2.new(0.05, 0, 0, 120)
status.Text = "Hazır"
status.TextColor3 = Color3.fromRGB(200, 200, 255)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.Parent = frame

-- Liste
local listFrame = Instance.new("ScrollingFrame")
listFrame.Size = UDim2.new(0.9, 0, 0, 150)
listFrame.Position = UDim2.new(0.05, 0, 0, 150)
listFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
listFrame.BackgroundTransparency = 0.3
listFrame.BorderSizePixel = 1
listFrame.BorderColor3 = Color3.fromRGB(0, 100, 200)
listFrame.Parent = frame
listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

-- Listeyi güncelle
local function updateList()
    for _, c in pairs(listFrame:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    
    local y = 5
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0.9, 0, 0, 28)
            b.Position = UDim2.new(0.05, 0, 0, y)
            b.BackgroundColor3 = Color3.fromRGB(45, 45, 75)
            b.TextColor3 = Color3.fromRGB(200, 200, 255)
            b.Text = p.Name
            b.Font = Enum.Font.Gotham
            b.TextSize = 12
            b.Parent = listFrame
            
            b.MouseButton1Click:Connect(function()
                input.Text = p.Name
                status.Text = "✅ " .. p.Name .. " seçildi"
                status.TextColor3 = Color3.fromRGB(0, 255, 100)
            end)
            
            y = y + 33
        end
    end
    listFrame.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

updateList()
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)

-- Kopyala
btn.MouseButton1Click:Connect(function()
    local name = input.Text
    if name == "" or name == "İsim yaz..." then
        status.Text = "⚠️ İsim yaz!"
        status.TextColor3 = Color3.fromRGB(255, 200, 0)
        return
    end
    
    local target = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower() == name:lower() then
            target = p
            break
        end
    end
    
    if not target then
        status.Text = "❌ Oyuncu yok!"
        status.TextColor3 = Color3.fromRGB(255, 50, 50)
        return
    end
    
    status.Text = "⏳ Kopyalanıyor..."
    status.TextColor3 = Color3.fromRGB(255, 200, 0)
    
    copyChar(target)
    
    status.Text = "✅ " .. target.Name .. " kopyalandı!"
    status.TextColor3 = Color3.fromRGB(0, 255, 100)
end)

print("🌀 KARAKTER KOPYALAMA AKTİF!")
