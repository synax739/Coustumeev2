-- Delta Executor - GERÇEK BİREBİR KARAKTER KOPYALAMA (Mobil Uyumlu)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Değişkenler
local panelVisible = true
local screenGui = nil
local isMobile = UserInputService.TouchEnabled

-- ANA KOPYALAMA FONKSİYONU (GELİŞMİŞ)
local function copyCharacterFULL(targetPlayer)
    local targetChar = targetPlayer.Character
    if not targetChar or not targetChar:FindFirstChild("Head") then
        return false, "❌ Hedef karakter yüklenemedi!"
    end
    
    local myChar = player.Character
    if not myChar then return false, "❌ Kendi karakterin yüklenemedi!" end
    
    local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
    local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
    if not myHumanoid or not targetHumanoid then 
        return false, "❌ Humanoid bulunamadı!" 
    end
    
    -- ===== 1. VÜCUT ORANLARI (Boy, kilo, kol uzunluğu) =====
    -- BodyScale kullanarak vücut oranlarını kopyala
    local myScale = myHumanoid:FindFirstChild("BodyScale") or Instance.new("Model")
    myScale.Name = "BodyScale"
    myScale.Parent = myHumanoid
    
    local targetScale = targetHumanoid:FindFirstChild("BodyScale")
    if targetScale then
        for _, prop in pairs({"Height", "Width", "HeadScale", "BodyTypeScale"}) do
            if targetScale:FindFirstChild(prop) then
                local newScale = targetScale[prop]:Clone()
                newScale.Parent = myScale
            end
        end
    end
    
    -- ===== 2. TÜM VÜCUT PARÇALARI (Derinlemesine) =====
    local allParts = {}
    for _, part in pairs(targetChar:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            table.insert(allParts, part)
        end
    end
    
    for _, targetPart in pairs(allParts) do
        local myPart = myChar:FindFirstChild(targetPart.Name)
        if myPart and myPart:IsA("BasePart") then
            -- Renk
            myPart.Color = targetPart.Color
            -- Malzeme
            myPart.Material = targetPart.Material
            -- Şeffaflık
            myPart.Transparency = targetPart.Transparency
            -- Yansıma
            myPart.Reflectance = targetPart.Reflectance
            -- Boyut (VÜCUT YAPISI İÇİN ÇOK ÖNEMLİ)
            myPart.Size = targetPart.Size
            -- Pozisyon
            myPart.CFrame = targetPart.CFrame
            -- Doku
            if targetPart.TextureID and targetPart.TextureID ~= "" then
                myPart.TextureID = targetPart.TextureID
            end
            -- Renk3 (bazı özel parçalar)
            if targetPart.Color3 then
                myPart.Color3 = targetPart.Color3
            end
        end
    end
    
    -- ===== 3. AKSESUARLAR (TÜMÜ - ÖZELLİKLE YÜZ AKSESUARLARI) =====
    -- Eski aksesuarları temizle
    for _, child in pairs(myChar:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Hat") or 
           child:IsA("Shirt") or child:IsA("Pants") or
           child:IsA("ShirtGraphic") or child:IsA("Pants") or
           child:IsA("Model") and child.Name:match("Accessory") then
            child:Destroy()
        end
    end
    
    local accessoryCount = 0
    -- Tüm aksesuarları tara
    for _, acc in pairs(targetChar:GetChildren()) do
        -- Aksesuar, şapka, model, veya aksesuar içeren her şey
        if acc:IsA("Accessory") or acc:IsA("Hat") or 
           (acc:IsA("Model") and (acc.Name:match("Hat") or acc.Name:match("Accessory") or acc.Name:match("Face"))) then
           
            local clone = acc:Clone()
            clone.Parent = myChar
            
            -- Handle'ı düzenle (YÜZ AKSESUARLARI İÇİN)
            if clone:FindFirstChild("Handle") then
                local handle = clone.Handle
                local origHandle = acc:FindFirstChild("Handle")
                if origHandle then
                    handle.Color = origHandle.Color
                    handle.Material = origHandle.Material
                    handle.Transparency = origHandle.Transparency
                    handle.Size = origHandle.Size
                    handle.CFrame = origHandle.CFrame -- POZİSYON ÇOK ÖNEMLİ
                end
            end
            
            -- Attachment'ları kopyala (aksesuar bağlantı noktaları)
            for _, att in pairs(acc:GetChildren()) do
                if att:IsA("Attachment") then
                    local newAtt = att:Clone()
                    newAtt.Parent = clone
                end
            end
            
            accessoryCount = accessoryCount + 1
        end
    end
    
    -- ===== 4. YÜZ ÖZELLİKLERİ (ÖZEL) =====
    -- Face aksesuarlarını özel olarak kopyala
    for _, acc in pairs(targetChar:GetChildren()) do
        if acc:IsA("Model") and (acc.Name:match("Face") or acc.Name:match("face")) then
            local clone = acc:Clone()
            clone.Parent = myChar
            -- Yüzü doğru konuma yerleştir
            if clone:FindFirstChild("Handle") then
                clone.Handle.CFrame = myChar.Head.CFrame
            end
            accessoryCount = accessoryCount + 1
        end
    end
    
    -- ===== 5. GİYSİLER (Shirt + Pants) =====
    if targetHumanoid and myHumanoid then
        -- Tişört
        if targetHumanoid.ShirtGraphic and targetHumanoid.ShirtGraphic ~= "" then
            myHumanoid.ShirtGraphic = targetHumanoid.ShirtGraphic
        end
        if targetHumanoid.Shirt and targetHumanoid.Shirt ~= "" then
            myHumanoid.Shirt = targetHumanoid.Shirt
        end
        -- Pantolon
        if targetHumanoid.Pants and targetHumanoid.Pants ~= "" then
            myHumanoid.Pants = targetHumanoid.Pants
        end
        -- T-Shirt
        if targetHumanoid.TShirt and targetHumanoid.TShirt ~= "" then
            myHumanoid.TShirt = targetHumanoid.TShirt
        end
    end
    
    -- ===== 6. VÜCUT RENGİ (TEN RENGİ) =====
    if targetHumanoid and myHumanoid then
        myHumanoid.BreakJointsOnDeath = targetHumanoid.BreakJointsOnDeath
        myHumanoid.MaxHealth = targetHumanoid.MaxHealth
        myHumanoid.Health = targetHumanoid.Health
    end
    
    -- ===== 7. BODY COLORS (Ten rengi detay) =====
    local myBodyColors = myHumanoid:FindFirstChild("BodyColors")
    local targetBodyColors = targetHumanoid:FindFirstChild("BodyColors")
    if myBodyColors and targetBodyColors then
        myBodyColors.HeadColor = targetBodyColors.HeadColor
        myBodyColors.TorsoColor = targetBodyColors.TorsoColor
        myBodyColors.LeftArmColor = targetBodyColors.LeftArmColor
        myBodyColors.RightArmColor = targetBodyColors.RightArmColor
        myBodyColors.LeftLegColor = targetBodyColors.LeftLegColor
        myBodyColors.RightLegColor = targetBodyColors.RightLegColor
    end
    
    return true, string.format("✅ %s BİREBİR kopyalandı! (%d aksesuar)", 
                               targetPlayer.Name, accessoryCount)
end

-- ===== MOBİL UYUMLU PANEL =====
local function createPanel()
    if screenGui then screenGui:Destroy() end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Parent = player.PlayerGui
    screenGui.Name = "KopyalamaPaneli"
    screenGui.ResetOnSpawn = false
    
    -- Ana Panel (Mobil için büyük)
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = isMobile and UDim2.new(0.9, 0, 0.8, 0) or UDim2.new(0, 450, 0, 600)
    mainFrame.Position = UDim2.new(0.5, isMobile and -200 or -225, 0.5, isMobile and -300 or -300)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 3
    mainFrame.BorderColor3 = Color3.fromRGB(0, 200, 255)
    mainFrame.Parent = screenGui
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    -- Başlık
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "🌀 BİREBİR KOPYALAMA 🌀"
    title.TextColor3 = Color3.fromRGB(0, 220, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = isMobile and 22 or 20
    title.Parent = mainFrame
    
    -- Kullanıcı adı girişi (Mobil için büyük)
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0.8, 0, 0, isMobile and 50 or 40)
    inputBox.Position = UDim2.new(0.1, 0, 0, 60)
    inputBox.BackgroundColor3 = Color3.fromRGB(35, 35, 60)
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.PlaceholderText = "Kullanıcı adını yaz..."
    inputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 180)
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = isMobile and 18 or 14
    inputBox.Parent = mainFrame
    inputBox.ClearTextOnFocus = false
    
    -- Kopyala butonu (Mobil için büyük)
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0.6, 0, 0, isMobile and 55 or 40)
    copyBtn.Position = UDim2.new(0.2, 0, 0, 120)
    copyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Text = "🎯 BİREBİR KOPYALA"
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = isMobile and 18 or 15
    copyBtn.Parent = mainFrame
    
    -- Durum mesajı
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0.9, 0, 0, 40)
    statusLabel.Position = UDim2.new(0.05, 0, 0, 180)
    statusLabel.Text = "📌 Hazır..."
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = isMobile and 16 or 13
    statusLabel.Parent = mainFrame
    
    -- Oyuncu listesi başlığı
    local listLabel = Instance.new("TextLabel")
    listLabel.Size = UDim2.new(0.9, 0, 0, 30)
    listLabel.Position = UDim2.new(0.05, 0, 0, 225)
    listLabel.Text = "📋 SERVERDAKİ OYUNCULAR:"
    listLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    listLabel.BackgroundTransparency = 1
    listLabel.Font = Enum.Font.GothamBold
    listLabel.TextSize = isMobile and 16 or 13
    listLabel.Parent = mainFrame
    
    -- Oyuncu listesi (Mobil için büyük)
    local playerList = Instance.new("ScrollingFrame")
    playerList.Size = UDim2.new(0.9, 0, 0, isMobile and 250 or 200)
    playerList.Position = UDim2.new(0.05, 0, 0, 260)
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
                btn.Size = UDim2.new(0.9, 0, 0, isMobile and 40 or 32)
                btn.Position = UDim2.new(0.05, 0, 0, yPos)
                btn.BackgroundColor3 = Color3.fromRGB(45, 45, 75)
                btn.TextColor3 = Color3.fromRGB(200, 200, 255)
                btn.Text = "👤 " .. p.Name
                btn.Font = Enum.Font.Gotham
                btn.TextSize = isMobile and 16 or 13
                btn.Parent = playerList
                
                btn.MouseButton1Click:Connect(function()
                    inputBox.Text = p.Name
                    statusLabel.Text = "✅ " .. p.Name .. " seçildi!"
                    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                end)
                
                yPos = yPos + (isMobile and 45 or 37)
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
            statusLabel.Text = "⚠️ Lütfen bir isim yaz!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
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
            statusLabel.Text = "❌ Oyuncu serverda yok!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            return
        end
        
        statusLabel.Text = "⏳ Kopyalanıyor..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        
        local success, message = copyCharacterFULL(target)
        statusLabel.Text = message
        statusLabel.TextColor3 = success and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    end)
    
    -- ===== MOBİL İÇİN AÇ/KAPA BUTONU =====
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0.15, 0, 0, isMobile and 45 or 35)
    toggleBtn.Position = UDim2.new(0.82, 0, 0, 5)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Text = "✕"
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = isMobile and 24 or 18
    toggleBtn.Parent = mainFrame
    toggleBtn.MouseButton1Click:Connect(function()
        panelVisible = false
        if screenGui then 
            screenGui:Destroy()
            screenGui = nil
        end
        -- Mobil için buton göster
        showMobileToggle()
    end)
    
    -- Bilgi metni
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 25)
    info.Position = UDim2.new(0, 0, 0, isMobile and 570 or 560)
    info.Text = "🔹 Vücut + Ten rengi + Aksesuar + Giysi + Oranlar"
    info.TextColor3 = Color3.fromRGB(100, 200, 255)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = isMobile and 14 or 11
    info.Parent = mainFrame
end

-- ===== MOBİL AÇ/KAPA BUTONU =====
local mobileToggleBtn = nil

local function showMobileToggle()
    if mobileToggleBtn then mobileToggleBtn:Destroy() end
    if screenGui then return end
    
    mobileToggleBtn = Instance.new("TextButton")
    mobileToggleBtn.Parent = player.PlayerGui
    mobileToggleBtn.Size = UDim2.new(0, 60, 0, 60)
    mobileToggleBtn.Position = UDim2.new(0.85, 0, 0.05, 0)
    mobileToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    mobileToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    mobileToggleBtn.Text = "🌀"
    mobileToggleBtn.Font = Enum.Font.GothamBold
    mobileToggleBtn.TextSize = 30
    mobileToggleBtn.BackgroundTransparency = 0.2
    mobileToggleBtn.BorderSizePixel = 2
    mobileToggleBtn.BorderColor3 = Color3.fromRGB(0, 200, 255)
    mobileToggleBtn.Name = "ToggleButton"
    
    -- Tıklanınca paneli aç
    mobileToggleBtn.MouseButton1Click:Connect(function()
        panelVisible = true
        if mobileToggleBtn then 
            mobileToggleBtn:Destroy()
            mobileToggleBtn = nil
        end
        createPanel()
    end)
end

-- ===== PANELİ AÇ/KAPA =====
local function togglePanel()
    panelVisible = not panelVisible
    if panelVisible then
        if mobileToggleBtn then 
            mobileToggleBtn:Destroy()
            mobileToggleBtn = nil
        end
        createPanel()
        print("🌀 Panel açıldı")
    else
        if screenGui then 
            screenGui:Destroy()
            screenGui = nil
        end
        showMobileToggle()
        print("🌀 Panel kapandı")
    end
end

-- F8 tuşu ile aç/kapa (PC için)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F8 then
        togglePanel()
    end
end)

-- İlk paneli oluştur
createPanel()

print("🌀 BİREBİR KARAKTER KOPYALAMA SİSTEMİ AKTİF!")
print("📱 Mobil: Ekrandaki butona tıkla")
print("💻 PC: F8 tuşu ile aç/kapa")
