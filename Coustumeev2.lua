-- Delta Executor - TAM KARAKTER KOPYALAMA SİSTEMİ (Vücut + Aksesuar + Animasyon)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Panel açık/kapalı durumu
local panelVisible = true
local screenGui = nil

-- Kısayol tuşu (F8 ile aç/kapa)
local TOGGLE_KEY = Enum.KeyCode.F8

-- Karakter kopyalama fonksiyonu (GELİŞMİŞ)
local function copyCharacterFull(targetPlayer)
    local targetChar = targetPlayer.Character
    if not targetChar or not targetChar:FindFirstChild("Head") then
        return false, "Hedef karakter yüklenemedi!"
    end
    
    local myChar = player.Character
    if not myChar then return false, "Kendi karakterin yüklenemedi!" end
    
    -- 1. VÜCUT PARÇALARI (Ten rengi + malzeme + şeffaflık)
    local bodyParts = {
        "Head", "Torso", "LeftArm", "RightArm", 
        "LeftLeg", "RightLeg", "UpperTorso", "LowerTorso"
    }
    
    for _, partName in pairs(bodyParts) do
        local targetPart = targetChar:FindFirstChild(partName)
        local myPart = myChar:FindFirstChild(partName)
        if targetPart and myPart then
            -- Ten rengi
            myPart.Color = targetPart.Color
            
            -- Malzeme (deri, metal, plastik vs)
            myPart.Material = targetPart.Material
            
            -- Şeffaflık
            myPart.Transparency = targetPart.Transparency
            
            -- Yansıma
            myPart.Reflectance = targetPart.Reflectance
            
            -- Boyut (bazı oyunlarda çalışır)
            if targetPart.Size and myPart.Size then
                myPart.Size = targetPart.Size
            end
            
            -- Doku (eğer varsa)
            if targetPart.TextureID and targetPart.TextureID ~= "" then
                myPart.TextureID = targetPart.TextureID
            end
        end
    end
    
    -- 2. KİLİT PARÇALARI (Bazı özel vücut parçaları)
    local specialParts = {"LeftFoot", "RightFoot", "LeftHand", "RightHand"}
    for _, partName in pairs(specialParts) do
        local targetPart = targetChar:FindFirstChild(partName)
        local myPart = myChar:FindFirstChild(partName)
        if targetPart and myPart then
            myPart.Color = targetPart.Color
            myPart.Material = targetPart.Material
            myPart.Transparency = targetPart.Transparency
        end
    end
    
    -- 3. AKSESUARLAR (Şapka, gözlük, sırt çantası, kılıç vs)
    -- Eski aksesuarları temizle (sadece kopyalananlar)
    for _, child in pairs(myChar:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Hat") or 
           child:IsA("Shirt") or child:IsA("Pants") or
           child:IsA("ShirtGraphic") or child:IsA("Pants") then
            child:Destroy()
        end
    end
    
    -- Yeni aksesuarları kopyala
    local accessoryCount = 0
    for _, acc in pairs(targetChar:GetChildren()) do
        if acc:IsA("Accessory") or acc:IsA("Hat") or 
           acc:IsA("Shirt") or acc:IsA("Pants") or
           acc:IsA("ShirtGraphic") or acc:IsA("Pants") then
            
            local clone = acc:Clone()
            clone.Parent = myChar
            
            -- Aksesuar handle'ını düzenle
            if clone:FindFirstChild("Handle") then
                local handle = clone.Handle
                -- Orijinal renk ve malzemeyi koru
                if targetChar:FindFirstChild(acc.Name) and 
                   targetChar[acc.Name]:FindFirstChild("Handle") then
                    local origHandle = targetChar[acc.Name].Handle
                    handle.Color = origHandle.Color
                    handle.Material = origHandle.Material
                    handle.Transparency = origHandle.Transparency
                end
            end
            
            accessoryCount = accessoryCount + 1
        end
    end
    
    -- 4. GİYSİLER (Shirt ve Pants ID'leri)
    local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
    local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
    
    if targetHumanoid and myHumanoid then
        -- Tişört
        if targetHumanoid.ShirtGraphic then
            myHumanoid.ShirtGraphic = targetHumanoid.ShirtGraphic
        end
        if targetHumanoid.Shirt then
            myHumanoid.Shirt = targetHumanoid.Shirt
        end
        -- Pantolon
        if targetHumanoid.Pants then
            myHumanoid.Pants = targetHumanoid.Pants
        end
    end
    
    -- 5. ANİMASYONLAR (Walk, Run, Jump)
    if myChar:FindFirstChild("Humanoid") and targetChar:FindFirstChild("Humanoid") then
        local myAnimator = myChar.Humanoid:FindFirstChildOfClass("Animator")
        local targetAnimator = targetChar.Humanoid:FindFirstChildOfClass("Animator")
        
        if myAnimator and targetAnimator then
            -- Animasyonları kopyala (test amaçlı)
            for _, anim in pairs(targetAnimator:GetPlayingAnimationTracks()) do
                if anim.Animation and anim.Animation.AnimationId then
                    local newAnim = Instance.new("Animation")
                    newAnim.AnimationId = anim.Animation.AnimationId
                    local track = myAnimator:LoadAnimation(newAnim)
                    track:Play()
                end
            end
        end
    end
    
    return true, string.format("✅ %s birebir kopyalandı! (%d aksesuar)", 
                               targetPlayer.Name, accessoryCount)
end

-- Panel oluşturma fonksiyonu
local function createPanel()
    if screenGui then screenGui:Destroy() end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Parent = player.PlayerGui
    screenGui.Name = "KopyalamaPaneli"
    
    -- Ana Panel
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 450, 0, 550)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(0, 180, 255)
    mainFrame.Parent = screenGui
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    -- Arka plan blur efekti
    local blur = Instance.new("BlurEffect")
    blur.Size = 5
    blur.Parent = game:GetService("Lighting")
    
    -- Başlık
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "🌀 TAM KARAKTER KOPYALAMA 🌀"
    title.TextColor3 = Color3.fromRGB(0, 220, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Parent = mainFrame
    
    -- Kullanıcı adı girişi
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0.8, 0, 0, 40)
    inputBox.Position = UDim2.new(0.1, 0, 0, 55)
    inputBox.BackgroundColor3 = Color3.fromRGB(35, 35, 60)
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.PlaceholderText = "Kullanıcı adını yaz..."
    inputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 180)
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 14
    inputBox.Parent = mainFrame
    inputBox.ClearTextOnFocus = false
    
    -- Kopyala butonu
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0.4, 0, 0, 40)
    copyBtn.Position = UDim2.new(0.3, 0, 0, 105)
    copyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Text = "🎯 BİREBİR KOPYALA"
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 15
    copyBtn.Parent = mainFrame
    
    -- Durum mesajı
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
    statusLabel.Position = UDim2.new(0.05, 0, 0, 155)
    statusLabel.Text = "Hazır..."
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 13
    statusLabel.Parent = mainFrame
    
    -- Server oyuncu listesi
    local listLabel = Instance.new("TextLabel")
    listLabel.Size = UDim2.new(0.9, 0, 0, 25)
    listLabel.Position = UDim2.new(0.05, 0, 0, 190)
    listLabel.Text = "📋 SERVERDAKİ OYUNCULAR (Tıkla seç):"
    listLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    listLabel.BackgroundTransparency = 1
    listLabel.Font = Enum.Font.GothamBold
    listLabel.TextSize = 13
    listLabel.Parent = mainFrame
    
    local playerList = Instance.new("ScrollingFrame")
    playerList.Size = UDim2.new(0.9, 0, 0, 250)
    playerList.Position = UDim2.new(0.05, 0, 0, 220)
    playerList.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
    playerList.BackgroundTransparency = 0.3
    playerList.BorderSizePixel = 1
    playerList.BorderColor3 = Color3.fromRGB(0, 100, 200)
    playerList.Parent = mainFrame
    playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    -- Listeyi güncelle
    local function updatePlayerList()
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
                    inputBox.Text = p.Name
                    statusLabel.Text = "✅ " .. p.Name .. " seçildi!"
                    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                end)
                
                yPos = yPos + 37
            end
        end
        playerList.CanvasSize = UDim2.new(0, 0, 0, yPos + 10)
    end
    
    updatePlayerList()
    Players.PlayerAdded:Connect(updatePlayerList)
    Players.PlayerRemoving:Connect(updatePlayerList)
    
    -- Kopyala butonu işlevi
    copyBtn.MouseButton1Click:Connect(function()
        local name = inputBox.Text
        if not name or name == "" or name == "Kullanıcı adını yaz..." then
            statusLabel.Text = "⚠️ Lütfen bir isim yaz veya listeden seç!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
            return
        end
        
        -- Hedef oyuncuyu bul
        local target = nil
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name:lower() == name:lower() then
                target = p
                break
            end
        end
        
        if not target then
            statusLabel.Text = "❌ Oyuncu serverda bulunamadı!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            return
        end
        
        statusLabel.Text = "⏳ Kopyalanıyor..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        
        local success, message = copyCharacterFull(target)
        statusLabel.Text = message
        statusLabel.TextColor3 = success and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    end)
    
    -- Kapatma butonu
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -38, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Text = "✕"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.Parent = mainFrame
    closeBtn.MouseButton1Click:Connect(function()
        panelVisible = false
        if screenGui then screenGui:Destroy() end
    end)
    
    -- Bilgi metni
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 25)
    info.Position = UDim2.new(0, 0, 0, 520)
    info.Text = "🔹 Vücut + Ten rengi + Aksesuar + Giysi + Animasyon"
    info.TextColor3 = Color3.fromRGB(100, 200, 255)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = 11
    info.Parent = mainFrame
    
    local info2 = Instance.new("TextLabel")
    info2.Size = UDim2.new(1, 0, 0, 20)
    info2.Position = UDim2.new(0, 0, 0, 540)
    info2.Text = "📌 F8 tuşu ile aç/kapa"
    info2.TextColor3 = Color3.fromRGB(150, 150, 200)
    info2.BackgroundTransparency = 1
    info2.Font = Enum.Font.Gotham
    info2.TextSize = 10
    info2.Parent = mainFrame
end

-- Panel göster/gizle fonksiyonu
local function togglePanel()
    panelVisible = not panelVisible
    if panelVisible then
        createPanel()
        print("🔮 Panel açıldı")
    else
        if screenGui then 
            screenGui:Destroy()
            screenGui = nil
        end
        print("🔮 Panel kapandı")
    end
end

-- İlk paneli oluştur
createPanel()

-- F8 tuşu ile aç/kapa
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == TOGGLE_KEY then
        togglePanel()
    end
end)

-- Konsol mesajı
print("🔮 Tam Karakter Kopyalama Sistemi Aktif!")
print("📌 F8 ile paneli açıp kapatabilirsin")
