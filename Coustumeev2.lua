-- DELTA EXECUTOR - TAM KARAKTER KOPYALAMA (FULL)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local isMobile = UserInputService.TouchEnabled
local screenGui = nil
local mobileBtn = nil
local panelOpen = false

-- ===== AKSESUAR KOPYALAMA (YENİ SİSTEM) =====
local function copyAllAccessories(fromChar, toChar)
    -- Eski aksesuarları temizle (MODEL olanları da)
    local toRemove = {}
    for _, child in pairs(toChar:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Hat") or child:IsA("Model") then
            if child.Name:match("Hat") or child.Name:match("Accessory") or 
               child.Name:match("Face") or child.Name:match("Hair") or
               child.Name:match("Head") or child:FindFirstChild("Handle") then
                table.insert(toRemove, child)
            end
        end
    end
    for _, child in pairs(toRemove) do
        child:Destroy()
    end
    
    local count = 0
    
    -- TÜM aksesuarları tara (Accessory, Hat, Model)
    for _, acc in pairs(fromChar:GetChildren()) do
        -- Accessory tipi
        if acc:IsA("Accessory") or acc:IsA("Hat") then
            local clone = acc:Clone()
            clone.Parent = toChar
            count = count + 1
        end
        
        -- Model tipi (YENİ ROBLOX SİSTEMİ)
        if acc:IsA("Model") then
            -- Handle var mı kontrol et (aksesuar olduğunu gösterir)
            if acc:FindFirstChild("Handle") then
                local clone = acc:Clone()
                clone.Parent = toChar
                count = count + 1
            end
            
            -- İçindeki aksesuarları kontrol et
            for _, sub in pairs(acc:GetChildren()) do
                if sub:IsA("Accessory") or sub:IsA("Hat") then
                    local clone = sub:Clone()
                    clone.Parent = toChar
                    count = count + 1
                end
                if sub:IsA("Model") and sub:FindFirstChild("Handle") then
                    local clone = sub:Clone()
                    clone.Parent = toChar
                    count = count + 1
                end
            end
        end
    end
    
    return count
end

-- ===== ANA KOPYALAMA =====
local function copyCharacter(targetPlayer)
    local targetChar = targetPlayer.Character
    if not targetChar then
        return "❌ Hedef karakter yok!", 0
    end
    
    local myChar = player.Character
    if not myChar then
        return "❌ Senin karakterin yok!", 0
    end
    
    local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
    local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
    
    if not myHumanoid or not targetHumanoid then
        return "❌ Humanoid yok!", 0
    end
    
    -- 1. TEN RENGİ (BodyColors)
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
    
    -- 2. VÜCUT PARÇALARI (renk + malzeme)
    local parts = {"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg", "UpperTorso", "LowerTorso"}
    for _, name in pairs(parts) do
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
    if targetHumanoid.Shirt and targetHumanoid.Shirt ~= "" then
        myHumanoid.Shirt = targetHumanoid.Shirt
    end
    if targetHumanoid.Pants and targetHumanoid.Pants ~= "" then
        myHumanoid.Pants = targetHumanoid.Pants
    end
    if targetHumanoid.ShirtGraphic and targetHumanoid.ShirtGraphic ~= "" then
        myHumanoid.ShirtGraphic = targetHumanoid.ShirtGraphic
    end
    if targetHumanoid.TShirt and targetHumanoid.TShirt ~= "" then
        myHumanoid.TShirt = targetHumanoid.TShirt
    end
    
    -- 4. AKSESUARLAR (TÜMÜ)
    local accCount = copyAllAccessories(targetChar, myChar)
    
    -- 5. SAÇ (Hair) - ÖZEL
    for _, child in pairs(targetChar:GetChildren()) do
        if child:IsA("Model") and (child.Name:match("Hair") or child.Name:match("hair")) then
            local clone = child:Clone()
            clone.Parent = myChar
            accCount = accCount + 1
        end
    end
    
    return "✅ " .. targetPlayer.Name .. " kopyalandı! (" .. accCount .. " aksesuar)", accCount
end

-- ===== MOBİL BUTON =====
local function createMobileButton()
    if mobileBtn then mobileBtn:Destroy() end
    if screenGui then return end
    
    mobileBtn = Instance.new("TextButton")
    mobileBtn.Parent = player.PlayerGui
    mobileBtn.Size = UDim2.new(0, 60, 0, 60)
    mobileBtn.Position = UDim2.new(0.88, 0, 0.05, 0)
    mobileBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    mobileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    mobileBtn.Text = "🌀"
    mobileBtn.Font = Enum.Font.GothamBold
    mobileBtn.TextSize = 30
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

-- ===== PANEL =====
local function openPanel()
    if screenGui then 
        screenGui:Destroy()
        screenGui = nil
    end
    
    panelOpen = true
    screenGui = Instance.new("ScreenGui")
    screenGui.Parent = player.PlayerGui
    screenGui.Name = "KopyalamaPaneli"
    screenGui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = isMobile and UDim2.new(0.9, 0, 0.7, 0) or UDim2.new(0, 380, 0, 460)
    frame.Position = UDim2.new(0.5, isMobile and -170 or -190, 0.5, isMobile and -200 or -230)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 200, 255)
    frame.Parent = screenGui
    frame.Active = true
    frame.Draggable = true
    
    -- Başlık
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Text = "🌀 KARAKTER KOPYALA"
    title.TextColor3 = Color3.fromRGB(0, 220, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = isMobile and 20 or 16
    title.Parent = frame
    
    -- KAPAT BUTONU (Panel içinde)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -40, 0, 3)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Text = "✕"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.Parent = frame
    closeBtn.MouseButton1Click:Connect(function()
        if screenGui then 
            screenGui:Destroy()
            screenGui = nil
        end
        panelOpen = false
        if isMobile then
            createMobileButton()
        end
    end)
    
    -- Liste başlığı
    local listLabel = Instance.new("TextLabel")
    listLabel.Size = UDim2.new(0.9, 0, 0, 25)
    listLabel.Position = UDim2.new(0.05, 0, 0, 40)
    listLabel.Text = "📋 OYUNCULAR (Tıkla - Kopyala):"
    listLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    listLabel.BackgroundTransparency = 1
    listLabel.Font = Enum.Font.GothamBold
    listLabel.TextSize = isMobile and 15 or 13
    listLabel.Parent = frame
    
    -- Liste
    local playerList = Instance.new("ScrollingFrame")
    playerList.Size = UDim2.new(0.9, 0, 0, isMobile and 270 or 240)
    playerList.Position = UDim2.new(0.05, 0, 0, 70)
    playerList.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
    playerList.BackgroundTransparency = 0.3
    playerList.BorderSizePixel = 1
    playerList.BorderColor3 = Color3.fromRGB(0, 100, 200)
    playerList.Parent = frame
    playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    -- Durum
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0.9, 0, 0, isMobile and 40 or 35)
    status.Position = UDim2.new(0.05, 0, 0, isMobile and 350 or 320)
    status.Text = "Hazır"
    status.TextColor3 = Color3.fromRGB(200, 200, 255)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Gotham
    status.TextSize = isMobile and 15 or 13
    status.Parent = frame
    
    -- ===== LİSTEYİ DOLDUR =====
    local function updateList()
        for _, child in pairs(playerList:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        local yPos = 5
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(0.9, 0, 0, isMobile and 38 or 32)
                btn.Position = UDim2.new(0.05, 0, 0, yPos)
                btn.BackgroundColor3 = Color3.fromRGB(45, 45, 75)
                btn.TextColor3 = Color3.fromRGB(200, 200, 255)
                btn.Text = "👤 " .. p.Name
                btn.Font = Enum.Font.Gotham
                btn.TextSize = isMobile and 15 or 13
                btn.Parent = playerList
                
                btn.MouseButton1Click:Connect(function()
                    status.Text = "⏳ Kopyalanıyor: " .. p.Name
                    status.TextColor3 = Color3.fromRGB(255, 200, 0)
                    
                    local result, count = copyCharacter(p)
                    status.Text = result
                    if result:match("✅") then
                        status.TextColor3 = Color3.fromRGB(0, 255, 100)
                    else
                        status.TextColor3 = Color3.fromRGB(255, 50, 50)
                    end
                end)
                
                yPos = yPos + (isMobile and 43 or 37)
            end
        end
        
        playerList.CanvasSize = UDim2.new(0, 0, 0, yPos + 10)
    end
    
    updateList()
    Players.PlayerAdded:Connect(updateList)
    Players.PlayerRemoving:Connect(updateList)
    
    -- Bilgi
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(0.9, 0, 0, 25)
    info.Position = UDim2.new(0.05, 0, 0, isMobile and 400 or 365)
    info.Text = "💡 Ten rengi + Giysi + Aksesuar + Saç"
    info.TextColor3 = Color3.fromRGB(100, 200, 255)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = isMobile and 13 or 11
    info.Parent = frame
end

-- ===== F8 İLE AÇ/KAPA =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F8 then
        if panelOpen then
            if screenGui then 
                screenGui:Destroy()
                screenGui = nil
            end
            panelOpen = false
            if isMobile then
                createMobileButton()
            end
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
if isMobile then
    createMobileButton()
    print("🌀 Mobil buton aktif! Tıkla aç.")
else
    openPanel()
    print("🌀 Panel açıldı! F8 ile kapat.")
end

print("📌 Ten rengi + Giysi + Aksesuar + Saç kopyalanır")
