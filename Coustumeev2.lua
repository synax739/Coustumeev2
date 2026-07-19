-- Delta Executor - Gelişmiş Karakter Kopyalama Paneli
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Kullanıcı arayüzü
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

-- Ana Panel
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
mainFrame.Parent = screenGui
mainFrame.Active = true
mainFrame.Draggable = true

-- Başlık
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "🔮 KARAKTER KOPYALAMA SİSTEMİ 🔮"
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

-- Kullanıcı adı giriş kutusu
local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(0.8, 0, 0, 40)
inputBox.Position = UDim2.new(0.1, 0, 0, 50)
inputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.PlaceholderText = "Kullanıcı adını yaz (örn: ItsFunneh)"
inputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
inputBox.Font = Enum.Font.Gotham
inputBox.TextSize = 14
inputBox.Parent = mainFrame

-- Kopyala butonu
local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(0.4, 0, 0, 40)
copyButton.Position = UDim2.new(0.3, 0, 0, 100)
copyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
copyButton.Text = "👤 KARAKTERİ KOPYALA"
copyButton.Font = Enum.Font.GothamBold
copyButton.TextSize = 14
copyButton.Parent = mainFrame

-- Serverdaki oyuncu listesi
local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(0.9, 0, 0, 250)
playerList.Position = UDim2.new(0.05, 0, 0, 160)
playerList.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
playerList.BackgroundTransparency = 0.3
playerList.BorderSizePixel = 1
playerList.BorderColor3 = Color3.fromRGB(0, 100, 200)
playerList.Parent = mainFrame
playerList.CanvasSize = UDim2.new(0, 0, 0, 0)

-- Listeyi güncelle
local function updatePlayerList()
    -- Eski listeyi temizle
    for _, child in pairs(playerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local yPos = 5
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.9, 0, 0, 30)
            btn.Position = UDim2.new(0.05, 0, 0, yPos)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
            btn.TextColor3 = Color3.fromRGB(200, 200, 255)
            btn.Text = "📌 " .. p.Name
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 13
            btn.Parent = playerList
            
            -- Tıklandığında input'a adını yaz
            btn.MouseButton1Click:Connect(function()
                inputBox.Text = p.Name
            end)
            
            yPos = yPos + 35
        end
    end
    
    playerList.CanvasSize = UDim2.new(0, 0, 0, yPos + 10)
end

-- İlk listeyi doldur
updatePlayerList()

-- Oyuncu girince/çıkınca güncelle
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- Karakter kopyalama fonksiyonu
local function copyCharacterFromName(username)
    -- Önce serverda var mı kontrol et
    local targetPlayer = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower() == username:lower() then
            targetPlayer = p
            break
        end
    end
    
    if not targetPlayer then
        inputBox.Text = "❌ Oyuncu serverda bulunamadı!"
        wait(2)
        inputBox.Text = username
        return
    end
    
    local targetChar = targetPlayer.Character
    if not targetChar or not targetChar:FindFirstChild("Head") then
        inputBox.Text = "❌ Karakter yüklenemedi!"
        wait(2)
        inputBox.Text = username
        return
    end
    
    local myChar = player.Character
    if not myChar then return end
    
    -- Tüm vücut parçalarını kopyala
    local parts = {"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}
    for _, partName in pairs(parts) do
        local targetPart = targetChar:FindFirstChild(partName)
        local myPart = myChar:FindFirstChild(partName)
        if targetPart and myPart then
            myPart.Color = targetPart.Color
            myPart.Material = targetPart.Material
            myPart.Transparency = targetPart.Transparency
            myPart.Reflectance = targetPart.Reflectance
        end
    end
    
    -- Aksesuarları kopyala
    for _, acc in pairs(targetChar:GetChildren()) do
        if acc:IsA("Accessory") or acc:IsA("Hat") or acc:IsA("Shirt") or acc:IsA("Pants") then
            local clone = acc:Clone()
            clone.Parent = myChar
            -- Biraz şeffaf yapalım ki fark edilsin (test amaçlı)
            if clone:FindFirstChild("Handle") then
                clone.Handle.Transparency = 0.3
            end
        end
    end
    
    inputBox.Text = "✅ " .. username .. " kopyalandı!"
    wait(1.5)
    inputBox.Text = username
end

-- Kopyala butonuna tıklama
copyButton.MouseButton1Click:Connect(function()
    local name = inputBox.Text
    if name and name ~= "" and name ~= "Kullanıcı adını yaz (örn: ItsFunneh)" then
        copyCharacterFromName(name)
    else
        inputBox.Text = "⚠️ Geçerli bir isim yaz!"
        wait(2)
        inputBox.Text = ""
    end
end)

-- Kapatma butonu
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = mainFrame
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Panel mesajı
local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, 0, 0, 30)
infoText.Position = UDim2.new(0, 0, 0, 450)
infoText.Text = "⚠️ Sadece serverdaki oyuncular kopyalanabilir"
infoText.TextColor3 = Color3.fromRGB(255, 200, 0)
infoText.BackgroundTransparency = 1
infoText.Font = Enum.Font.Gotham
infoText.TextSize = 11
infoText.Parent = mainFrame
