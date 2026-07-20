-- DELTA EXECUTOR - KARAKTER KOPYALAMA (SADE)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local isMobile = UserInputService.TouchEnabled
local gui = nil
local btn = nil

-- ===== KOPYALA =====
local function copy(target)
    local tc = target.Character
    if not tc then return "Karakter yok!" end
    
    local mc = player.Character
    if not mc then return "Senin karakterin yok!" end
    
    local mh = mc:FindFirstChildOfClass("Humanoid")
    local th = tc:FindFirstChildOfClass("Humanoid")
    if not mh or not th then return "Humanoid yok!" end
    
    -- Renkler
    local mc2 = mh:FindFirstChild("BodyColors")
    local tc2 = th:FindFirstChild("BodyColors")
    if mc2 and tc2 then
        mc2.HeadColor = tc2.HeadColor
        mc2.TorsoColor = tc2.TorsoColor
        mc2.LeftArmColor = tc2.LeftArmColor
        mc2.RightArmColor = tc2.RightArmColor
        mc2.LeftLegColor = tc2.LeftLegColor
        mc2.RightLegColor = tc2.RightLegColor
    end
    
    -- Vücut parçaları
    for _, name in pairs({"Head","Torso","LeftArm","RightArm","LeftLeg","RightLeg"}) do
        local tp = tc:FindFirstChild(name)
        local mp = mc:FindFirstChild(name)
        if tp and mp then
            mp.Color = tp.Color
            mp.Material = tp.Material
        end
    end
    
    -- Giysiler
    if th.Shirt ~= "" then mh.Shirt = th.Shirt end
    if th.Pants ~= "" then mh.Pants = th.Pants end
    if th.ShirtGraphic ~= "" then mh.ShirtGraphic = th.ShirtGraphic end
    
    -- Eski aksesuarları sil
    for _, c in pairs(mc:GetChildren()) do
        if c:IsA("Accessory") or c:IsA("Hat") then
            c:Destroy()
        end
    end
    
    -- Yeni aksesuarlar
    local say = 0
    for _, c in pairs(tc:GetChildren()) do
        if c:IsA("Accessory") or c:IsA("Hat") then
            local clone = c:Clone()
            clone.Parent = mc
            say = say + 1
        end
    end
    
    return "✅ " .. target.Name .. " kopyalandı! (" .. say .. " aksesuar)"
end

-- ===== PANEL AÇ =====
local function ac()
    if gui then gui:Destroy() end
    
    gui = Instance.new("ScreenGui")
    gui.Parent = player.PlayerGui
    gui.Name = "Kopyala"
    
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 300, 0, 350)
    f.Position = UDim2.new(0.5, -150, 0.5, -175)
    f.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
    f.BackgroundTransparency = 0.1
    f.BorderSizePixel = 2
    f.BorderColor3 = Color3.fromRGB(0, 200, 255)
    f.Parent = gui
    f.Active = true
    f.Draggable = true
    
    -- Başlık
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 30)
    t.Text = "🌀 KOPYALA"
    t.TextColor3 = Color3.fromRGB(0, 220, 255)
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.GothamBold
    t.TextSize = 16
    t.Parent = f
    
    -- Kapat (panel içi)
    local kapat = Instance.new("TextButton")
    kapat.Size = UDim2.new(0, 30, 0, 30)
    kapat.Position = UDim2.new(1, -35, 0, 0)
    kapat.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    kapat.TextColor3 = Color3.fromRGB(255, 255, 255)
    kapat.Text = "X"
    kapat.Font = Enum.Font.GothamBold
    kapat.TextSize = 16
    kapat.Parent = f
    kapat.MouseButton1Click:Connect(function()
        gui:Destroy()
        gui = nil
        if isMobile then
            -- Mobil butonu geri göster
            local mb = Instance.new("TextButton")
            mb.Parent = player.PlayerGui
            mb.Size = UDim2.new(0, 50, 0, 50)
            mb.Position = UDim2.new(0.88, 0, 0.05, 0)
            mb.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
            mb.TextColor3 = Color3.fromRGB(255, 255, 255)
            mb.Text = "🌀"
            mb.Font = Enum.Font.GothamBold
            mb.TextSize = 25
            mb.BorderSizePixel = 2
            mb.BorderColor3 = Color3.fromRGB(0, 220, 255)
            mb.Name = "MobilButon"
            btn = mb
            mb.MouseButton1Click:Connect(function()
                mb:Destroy()
                btn = nil
                ac()
            end)
        end
    end)
    
    -- Liste başlığı
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(0.9, 0, 0, 25)
    lb.Position = UDim2.new(0.05, 0, 0, 35)
    lb.Text = "📋 OYUNCULAR:"
    lb.TextColor3 = Color3.fromRGB(150, 200, 255)
    lb.BackgroundTransparency = 1
    lb.Font = Enum.Font.GothamBold
    lb.TextSize = 13
    lb.Parent = f
    
    -- Liste
    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(0.9, 0, 0, 180)
    list.Position = UDim2.new(0.05, 0, 0, 65)
    list.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
    list.BackgroundTransparency = 0.3
    list.BorderSizePixel = 1
    list.BorderColor3 = Color3.fromRGB(0, 100, 200)
    list.Parent = f
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    -- Durum
    local durum = Instance.new("TextLabel")
    durum.Size = UDim2.new(0.9, 0, 0, 30)
    durum.Position = UDim2.new(0.05, 0, 0, 255)
    durum.Text = "Hazır"
    durum.TextColor3 = Color3.fromRGB(200, 200, 255)
    durum.BackgroundTransparency = 1
    durum.Font = Enum.Font.Gotham
    durum.TextSize = 13
    durum.Parent = f
    
    -- Bilgi
    local bilgi = Instance.new("TextLabel")
    bilgi.Size = UDim2.new(0.9, 0, 0, 25)
    bilgi.Position = UDim2.new(0.05, 0, 0, 290)
    bilgi.Text = "💡 Ten rengi + Giysi + Aksesuar"
    bilgi.TextColor3 = Color3.fromRGB(100, 200, 255)
    bilgi.BackgroundTransparency = 1
    bilgi.Font = Enum.Font.Gotham
    bilgi.TextSize = 11
    bilgi.Parent = f
    
    -- LİSTEYİ DOLDUR
    local function doldur()
        for _, c in pairs(list:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        
        local y = 5
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                local but = Instance.new("TextButton")
                but.Size = UDim2.new(0.9, 0, 0, 28)
                but.Position = UDim2.new(0.05, 0, 0, y)
                but.BackgroundColor3 = Color3.fromRGB(45, 45, 75)
                but.TextColor3 = Color3.fromRGB(200, 200, 255)
                but.Text = "👤 " .. p.Name
                but.Font = Enum.Font.Gotham
                but.TextSize = 12
                but.Parent = list
                
                but.MouseButton1Click:Connect(function()
                    durum.Text = "⏳ Kopyalanıyor: " .. p.Name
                    durum.TextColor3 = Color3.fromRGB(255, 200, 0)
                    
                    local sonuc = copy(p)
                    durum.Text = sonuc
                    if sonuc:match("✅") then
                        durum.TextColor3 = Color3.fromRGB(0, 255, 100)
                    else
                        durum.TextColor3 = Color3.fromRGB(255, 50, 50)
                    end
                end)
                
                y = y + 33
            end
        end
        list.CanvasSize = UDim2.new(0, 0, 0, y + 10)
    end
    
    doldur()
    Players.PlayerAdded:Connect(doldur)
    Players.PlayerRemoving:Connect(doldur)
end

-- ===== MOBİL BUTON =====
if isMobile then
    btn = Instance.new("TextButton")
    btn.Parent = player.PlayerGui
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.Position = UDim2.new(0.88, 0, 0.05, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = "🌀"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 25
    btn.BorderSizePixel = 2
    btn.BorderColor3 = Color3.fromRGB(0, 220, 255)
    btn.Name = "MobilButon"
    btn.MouseButton1Click:Connect(function()
        btn:Destroy()
        btn = nil
        ac()
    end)
else
    ac()
end

print("🌀 KARAKTER KOPYALAMA AKTİF!")
