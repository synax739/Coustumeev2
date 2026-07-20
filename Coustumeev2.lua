-- Delta Executor - BİREBİR KOPYALAMA V2 (Düzeltilmiş)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Değişkenler
local screenGui = nil
local mobileBtn = nil
local panelVisible = false
local isMobile = UserInputService.TouchEnabled

-- ===== KOPYALAMA FONKSİYONU (IŞINLANMA YOK) =====
local function copyCharacter(targetPlayer)
    local targetChar = targetPlayer.Character
    if not targetChar or not targetChar:FindFirstChild("Head") then
        return false, "❌ Karakter yüklenemedi!"
    end
    
    local myChar = player.Character
    if not myChar then return false, "❌ Senin karakterin yok!" end
    
    local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
    local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
    if not myHumanoid or not targetHumanoid then
        return false, "❌ Humanoid bulunamadı!"
    end
    
    -- 1. VÜCUT RENKLERİ (Ten rengi)
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
    
    -- 2. VÜCUT PARÇALARI (Sadece renk ve malzeme - BOYUT YOK)
    local parts = {"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}
    for _, name in pairs(parts) do
        local tp = targetChar:FindFirstChild(name)
        local mp = myChar:FindFirstChild(name)
        if tp and mp then
            mp.Color = tp.Color
            mp.Material = tp.Material
            mp.Transparency = tp.Transparency
            mp.Reflectance = tp.Reflectance
            -- BOYUT KOPYALAMA YOK - IŞINLANMAYI ÖNLE
        end
    end
    
    -- 3. GİYSİLER
    if targetHumanoid.Shirt and targetHumanoid.Shirt ~= "" then
        myHumanoid.Shirt = targetHumanoid.Shirt
    end
    if targetHumanoid.Pants and targetHumanoid.Pants ~= "" then
        myHumanoid.Pants = targetHumanoid.Pants
    end
    if targetHumanoid.ShirtGraphic and targetHumanoid.ShirtGraphic ~= "" then
        myHumanoid.ShirtGraphic = targetHumanoid.ShirtGraphic
    end
    
    -- 4. AKSESUARLARI TEMİZLE
    for _, child in pairs(myChar:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Hat") or 
           child:IsA("Shirt") or child:IsA("Pants") or
           child:IsA("Model") and (child.Name:match("Hat") or child.Name:match("Accessory") or child.Name:match("Face")) then
            child:Destroy()
        end
    end
    
    -- 5. AKSESUARLARI KOPYALA (IŞINLANMA YOK - SADECE KLON)
    local count = 0
    for _, acc in pairs(targetChar:GetChildren()) do
        if acc:IsA("Accessory") or acc:IsA("Hat") or 
           (acc:IsA("Model") and (acc.Name:match("Hat") or acc.Name:match("Accessory") or acc.Name:match("Face"))) then
            
            local clone = acc:Clone()
            clone.Parent = myChar
            count = count + 1
        end
    end
    
    return true, string.format("✅ %s kopyalandı! (%d aksesuar)", targetPlayer.Name, count)
end

-- ===== MOBİL AÇMA BUTONU =====
local function createMobileButton()
    if mobileBtn then mobileBtn:Destroy() end
    if screenGui then return end
    
    mobileBtn = Instance.new("TextButton")
    mobileBtn.Parent = player.PlayerGui
    mobileBtn.Size = UDim2.new(0, 55, 0, 55)
    mobileBtn.Position = UDim2.new(0.88, 0, 0.05, 0)
    mobileBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    mobileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    mobileBtn.Text = "🌀"
    mobileBtn.Font = Enum.Font.GothamBold
    mobileBtn.TextSize = 28
    mobileBtn.BackgroundTransparency = 0.15
    mobileBtn.BorderSizePixel = 2
    mobileBtn.BorderColor3 = Color3.fromRGB(0, 220, 255)
    mobileBtn.Name = "KopyalaButon"
    
    mobileBtn.MouseButton1Click:Connect(function()
        if mobileBtn then 
            mobileBtn:Destroy()
            mobileBtn = nil
        end
        openPanel()
    end)
end

-- ===== PANEL AÇ =====
local function openPanel()
    if screenGui then 
        screenGui:Destroy()
        screenGui = nil
    end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Parent = player.PlayerGui
    screenGui.Name = "KopyalamaPaneli"
    screenGui.ResetOnSpawn = false
    
    -- KÜÇÜK PANEL (Mobil için optimize)
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = isMobile and UDim2.new(0.85, 0, 0.6, 0) or UDim2.new(0, 350, 0, 420)
    mainFrame.Position = UDim2.new(0.5, isMobile and -170 or -175, 0.5, isMobile and -200 or -210)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(0, 200, 255)
    mainFrame.Parent = screenGui
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    -- Başlık
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "🌀 KOPYALA"
    title.TextColor3 = Color3.fromRGB(0, 220, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = isMobile and 20 or 18
    title.Parent = mainFrame
    
    -- KAPAT BUTONU (Panel içinde)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 3)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Text = "✕"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = mainFrame
    closeBtn.MouseButton1Click:Connect(function()
        if screenGui then 
            screenGui:Destroy()
            screenGui = nil
        end
        createMobileButton()
    end)
    
    -- Input
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0.8, 0, 0, isMobile and 40 or 35)
    inputBox.Position = UDim2.new(0.1, 0, 0, 40)
    inputBox.BackgroundColor3 = Color3.fromRGB(35, 35, 60)
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.PlaceholderText = "İsim yaz..."
    inputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 180)
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = isMobile and 16 or 14
    inputBox.Parent = mainFrame
    inputBox.ClearTextOnFocus = false
    
    -- Kopyala butonu
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0.5, 0, 0, isMobile and 45 or 35)
    copyBtn.Position = UDim2.new(0.25, 0, 0, 85)
    copyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Text = "🎯 KOPYALA"
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = isMobile and 16 or 14
    copyBtn.Parent = mainFrame
    
    -- Durum
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
    statusLabel.Position = UDim2.new(0.05, 0, 0, 135)
    statusLabel.Text = "Hazır"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = isMobile and 14 or 12
    statusLabel.Parent = mainFrame
    
    -- Oyuncu listesi başlığı
    local listLabel = Instance.new("TextLabel")
    listLabel.Size = UDim2.new(0.9, 0, 0, 25)
    listLabel.Position = UDim2.new(0.05, 0, 0, 170)
    listLabel.Text = "📋 OYUNCULAR"
    listLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    listLabel.BackgroundTransparency = 1
    listLabel.Font = Enum.Font.GothamBold
    listLabel.TextSize = isMobile and 14 or 12
    listLabel.Parent = mainFrame
    
    -- Liste
    local playerList = Instance.new("ScrollingFrame")
    playerList.Size = UDim2.new(0.9, 0, 0, isMobile and 150 or 130)
    playerList.Position = UDim2.new(0.05, 0, 0, 200)
    playerList.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
    playerList.BackgroundTransparency = 0.3
    playerList.BorderSizePixel = 1
    playerList.BorderColor3 = Color3.fromRGB(0, 100, 200)
    playerList.Parent = mainFrame
    playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    -- Listeyi doldur
    local function updateList()
        for _, child in pairs(playerList:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        local yPos = 5
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(0.9, 0, 0, isMobile and 35 or 28)
                btn.Position = UDim2.new(0.05, 0, 0, yPos)
                btn.BackgroundColor3 = Color3.fromRGB(45, 45, 75)
                btn.TextColor3 = Color3.fromRGB(200, 200, 255)
                btn.Text = "👤 " .. p.Name
                btn.Font = Enum.Font.Gotham
                btn.TextSize = isMobile and 14 or 12
                btn.Parent = playerList
                
                btn.MouseButton1Click:Connect(function()
                    inputBox.Text = p.Name
                    statusLabel.Text = "✅ " .. p.Name
                    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                end)
                
                yPos = yPos + (isMobile and 40 or 33)
            end
        end
        playerList.CanvasSize = UDim2.new(0, 0, 0, yPos + 10)
    end
    
    updateList()
    Players.PlayerAdded:Connect(updateList)
    Players.PlayerRemoving:Connect(updateList)
    
    -- Kopyala işlemi
    copyBtn.MouseButton1Click:Connect(function()
        local name = inputBox.Text
        if not name or name == "" or name == "İsim yaz..." then
            statusLabel.Text = "⚠️ İsim yaz!"
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
            statusLabel.Text = "❌ Oyuncu yok!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            return
        end
        
        statusLabel.Text = "⏳ Kopyalanıyor..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        
        local success, msg = copyCharacter(target)
        statusLabel.Text = msg
        statusLabel.TextColor3 = success and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    end)
end

-- ===== F8 İLE AÇ/KAPA (PC) =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F8 then
        if screenGui then
            screenGui:Destroy()
            screenGui = nil
            createMobileButton()
        else
            if mobileBtn then
                mobileBtn:Destroy()
                mobileBtn = nil
            end
            openPanel()
        end
    end
end)

-- ===== BAŞLAT =====
-- Mobil ise buton göster, değilse panel aç
if isMobile then
    createMobileButton()
    print("🌀 Mobil buton aktif! Tıkla aç.")
else
    openPanel()
    print("🌀 Panel açıldı! F8 ile kapat.")
end
