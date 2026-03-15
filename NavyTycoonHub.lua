-- ================================================
-- ⚓ NAVY TYCOON HUB v2
-- Mobile Friendly | Delta Executor
-- Fitur: Auto Pompa Oil + TP Pulau/Brangkas Orang
-- ================================================

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local StarterGui   = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player       = Players.LocalPlayer

local flying    = false
local flySpeed  = 60
local walkSpeed = 30
local goingUp   = false
local goingDown = false
local bv, bg
local autoOil   = false
local autoBuild = false

local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title, Text = text, Duration = 3
        })
    end)
end

local function getHRP()
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

local function teleportTo(pos)
    local hrp = getHRP()
    if hrp and pos then
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
        task.wait(0.4)
    end
end

local function findRemote(name)
    local rs = game:GetService("ReplicatedStorage")
    for _, v in ipairs(rs:GetDescendants()) do
        if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) and
           v.Name:lower():find(name:lower()) then
            return v
        end
    end
    return nil
end

local function fireRemote(name, ...)
    pcall(function()
        local r = findRemote(name)
        if r then
            if r:IsA("RemoteEvent") then r:FireServer(...)
            elseif r:IsA("RemoteFunction") then r:InvokeServer(...) end
        end
    end)
end

-- =====================
-- SCAN OIL PUMP
-- =====================
local function findOilPumps()
    local pumps = {}
    pcall(function()
        local keywords = {"oil","pump","oilrig","rig","drill","petroleum","fuel","barrel"}
        for _, obj in ipairs(workspace:GetDescendants()) do
            local nameLow = obj.Name:lower()
            for _, kw in ipairs(keywords) do
                if nameLow:find(kw) then
                    local pos = Vector3.new(0,0,0)
                    if obj:IsA("BasePart") then
                        pos = obj.Position
                    else
                        local bp = obj:FindFirstChildOfClass("BasePart")
                        if bp then pos = bp.Position end
                    end
                    local cd = obj:FindFirstChildOfClass("ClickDetector") or
                               obj:FindFirstChild("ClickDetector", true)
                    local pp = obj:FindFirstChildOfClass("ProximityPrompt") or
                               obj:FindFirstChild("ProximityPrompt", true)
                    -- Cek apakah bisa diinteraksi
                    if cd or pp or obj:GetAttribute("OilAmount") or
                       obj:GetAttribute("Fuel") or obj:GetAttribute("Amount") then
                        table.insert(pumps, {
                            obj  = obj,
                            name = obj.Name,
                            pos  = pos,
                            cd   = cd,
                            pp   = pp,
                        })
                    end
                    break
                end
            end
        end
    end)
    return pumps
end

-- =====================
-- POMPA OIL
-- =====================
local function pumpOil(pump)
    pcall(function()
        teleportTo(pump.pos)
        task.wait(0.3)
        if pump.cd then fireclickdetector(pump.cd) end
        if pump.pp then fireproximityprompt(pump.pp) end
        -- Fire remote pompa
        local remotes = {"PumpOil","CollectOil","Pump","CollectFuel","HarvestOil",
                         "InteractOil","OilInteract","Collect","Interact"}
        for _, rn in ipairs(remotes) do
            fireRemote(rn, pump.obj)
            fireRemote(rn)
        end
    end)
end

-- =====================
-- SCAN PULAU PEMAIN
-- =====================
local function getPlayerIslands()
    local islands = {}
    pcall(function()
        -- Scan dari karakter pemain lain
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    table.insert(islands, {
                        name = "👤 "..p.Name,
                        pos  = hrp.Position,
                        type = "player",
                        obj  = p.Character,
                    })
                end
            end
        end

        -- Scan workspace untuk island/base/plot
        local islandKeywords = {"island","base","plot","tycoon","harbor","dock","team","territory"}
        for _, obj in ipairs(workspace:GetChildren()) do
            local nameLow = obj.Name:lower()
            for _, kw in ipairs(islandKeywords) do
                if nameLow:find(kw) then
                    local pos = Vector3.new(0,10,0)
                    local bp = obj:FindFirstChildOfClass("BasePart")
                    if bp then pos = bp.Position end
                    local owner = obj:GetAttribute("Owner") or
                                  obj:GetAttribute("Player") or
                                  obj:GetAttribute("Team") or
                                  obj.Name
                    table.insert(islands, {
                        name = "🏝️ "..tostring(owner),
                        pos  = pos,
                        type = "island",
                        obj  = obj,
                    })
                    break
                end
            end
        end
    end)
    return islands
end

-- =====================
-- SCAN BRANGKAS / VAULT
-- =====================
local function getVaults()
    local vaults = {}
    pcall(function()
        local vaultKeywords = {
            "vault","safe","chest","treasure","storage","cash","money",
            "brangkas","locker","bank","deposit","crate","box"
        }
        for _, obj in ipairs(workspace:GetDescendants()) do
            local nameLow = obj.Name:lower()
            for _, kw in ipairs(vaultKeywords) do
                if nameLow:find(kw) then
                    local pos = Vector3.new(0,10,0)
                    if obj:IsA("BasePart") then
                        pos = obj.Position
                    else
                        local bp = obj:FindFirstChildOfClass("BasePart")
                        if bp then pos = bp.Position end
                    end
                    -- Cek apakah milik orang lain
                    local owner = obj:GetAttribute("Owner") or
                                  obj:GetAttribute("Player") or
                                  obj:GetAttribute("Team") or "?"
                    local cd = obj:FindFirstChildOfClass("ClickDetector") or
                               obj:FindFirstChild("ClickDetector", true)
                    local pp = obj:FindFirstChildOfClass("ProximityPrompt") or
                               obj:FindFirstChild("ProximityPrompt", true)
                    table.insert(vaults, {
                        obj   = obj,
                        name  = obj.Name,
                        owner = tostring(owner),
                        pos   = pos,
                        cd    = cd,
                        pp    = pp,
                    })
                    break
                end
            end
        end
    end)
    return vaults
end

-- =====================
-- MAIN GUI
-- =====================
local function createGUI()
    pcall(function()
        local old = game.CoreGui:FindFirstChild("NavyHub")
        if old then old:Destroy() end
    end)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NavyHub"
    ScreenGui.ResetOnSpawn = false
    pcall(function() ScreenGui.Parent = game.CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = player.PlayerGui end

    -- Frame
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1,-20,0,350)
    Frame.Position = UDim2.new(0,10,1,-370)
    Frame.BackgroundColor3 = Color3.fromRGB(12,22,38)
    Frame.BorderSizePixel = 0
    Frame.Visible = true
    Frame.ZIndex = 5
    Frame.Parent = ScreenGui
    Instance.new("UICorner",Frame).CornerRadius = UDim.new(0,16)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(30,100,200)
    stroke.Thickness = 1.5
    stroke.Parent = Frame

    -- Title
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1,0,0,40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(15,70,150)
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 6
    TitleBar.Parent = Frame
    Instance.new("UICorner",TitleBar).CornerRadius = UDim.new(0,16)

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1,-50,1,0)
    TitleLbl.Position = UDim2.new(0,12,0,0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = "⚓ Navy Tycoon Hub v2"
    TitleLbl.TextColor3 = Color3.fromRGB(255,255,255)
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextScaled = true
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.ZIndex = 7
    TitleLbl.Parent = TitleBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0,34,0,34)
    CloseBtn.Position = UDim2.new(1,-36,0,3)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextScaled = true
    CloseBtn.ZIndex = 7
    CloseBtn.Parent = TitleBar
    Instance.new("UICorner",CloseBtn).CornerRadius = UDim.new(0,8)

    -- Tab Bar
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1,-16,0,36)
    TabBar.Position = UDim2.new(0,8,0,44)
    TabBar.BackgroundTransparency = 1
    TabBar.ZIndex = 6
    TabBar.Parent = Frame

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0,5)
    TabLayout.Parent = TabBar

    local function makeTab(icon, name)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.25,-5,1,0)
        btn.BackgroundColor3 = Color3.fromRGB(25,45,75)
        btn.Text = icon.." "..name
        btn.TextColor3 = Color3.fromRGB(160,190,220)
        btn.Font = Enum.Font.GothamBold
        btn.TextScaled = true
        btn.ZIndex = 7
        btn.Parent = TabBar
        Instance.new("UICorner",btn).CornerRadius = UDim.new(0,8)
        return btn
    end

    local FlyTab    = makeTab("🚀","Fly")
    local OilTab    = makeTab("🛢️","Oil")
    local TpTab     = makeTab("📍","Pulau")
    local VaultTab  = makeTab("🔒","Brangkas")

    -- Content
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1,-16,1,-90)
    Content.Position = UDim2.new(0,8,0,86)
    Content.BackgroundTransparency = 1
    Content.ZIndex = 6
    Content.Parent = Frame

    local function makePanel()
        local p = Instance.new("Frame")
        p.Size = UDim2.new(1,0,1,0)
        p.BackgroundTransparency = 1
        p.Visible = false
        p.ZIndex = 6
        p.Parent = Content
        return p
    end

    local function mkBtn(parent,txt,color,x,y,w,h)
        local b = Instance.new("TextButton")
        b.Position = UDim2.new(x,4,0,y)
        b.Size = UDim2.new(w,-8,0,h or 46)
        b.BackgroundColor3 = color
        b.Text = txt
        b.TextColor3 = Color3.fromRGB(255,255,255)
        b.Font = Enum.Font.GothamBold
        b.TextScaled = true
        b.ZIndex = 7
        b.Parent = parent
        Instance.new("UICorner",b).CornerRadius = UDim.new(0,10)
        return b
    end

    local function mkLbl(parent,txt,x,y,w,h,size,color)
        local l = Instance.new("TextLabel")
        l.Position = UDim2.new(x,4,0,y)
        l.Size = UDim2.new(w,-8,0,h or 22)
        l.BackgroundTransparency = 1
        l.Text = txt
        l.TextColor3 = color or Color3.fromRGB(170,200,230)
        l.Font = Enum.Font.GothamBold
        l.TextSize = size or 13
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextWrapped = true
        l.ZIndex = 7
        l.Parent = parent
        return l
    end

    local function mkScroll(parent, x, y, w, h, dir)
        local s = Instance.new("ScrollingFrame")
        s.Position = UDim2.new(x,4,0,y)
        s.Size = UDim2.new(w,-8,0,h)
        s.BackgroundTransparency = 1
        s.ScrollBarThickness = 3
        s.ScrollBarImageColor3 = Color3.fromRGB(30,100,200)
        s.ScrollingDirection = dir or Enum.ScrollingDirection.X
        s.ZIndex = 7
        s.Parent = parent
        return s
    end

    -- ================================
    -- PANEL FLY & SPEED
    -- ================================
    local FlyPanel = makePanel()

    local FlyLbl    = mkLbl(FlyPanel,"✈️ Fly Speed: "..flySpeed,0,0,0.5,20,13)
    local FlyToggle = mkBtn(FlyPanel,"🚀 Fly: OFF",Color3.fromRGB(150,90,15),0,22,0.5,46)
    local UpBtn     = mkBtn(FlyPanel,"⬆️ NAIK\n(Tahan)",Color3.fromRGB(15,90,190),0,74,0.5,54)
    local DownBtn   = mkBtn(FlyPanel,"⬇️ TURUN\n(Tahan)",Color3.fromRGB(90,30,170),0,134,0.5,54)
    local FlySpUp   = mkBtn(FlyPanel,"➕ Fly +10",Color3.fromRGB(15,130,50),0,194,0.5,38)
    local FlySpDn   = mkBtn(FlyPanel,"➖ Fly -10",Color3.fromRGB(130,50,30),0,238,0.5,38)

    local SpdLbl    = mkLbl(FlyPanel,"⚡ Speed: "..walkSpeed,0.5,0,0.5,20,13)
    local SpdUp     = mkBtn(FlyPanel,"➕ Speed +10",Color3.fromRGB(15,90,180),0.5,22,0.5,46)
    local SpdDown   = mkBtn(FlyPanel,"➖ Speed -10",Color3.fromRGB(70,50,150),0.5,74,0.5,46)
    local Spd50     = mkBtn(FlyPanel,"🏃 x50",Color3.fromRGB(30,120,50),0.5,126,0.5,38)
    local SpdReset  = mkBtn(FlyPanel,"🔄 Reset",Color3.fromRGB(50,50,50),0.5,170,0.5,38)
    local ijActive  = false
    local IJBtn     = mkBtn(FlyPanel,"🦘 Inf Jump: OFF",Color3.fromRGB(40,80,40),0.5,214,0.5,38)
    local afkActive = false
    local AfkBtn    = mkBtn(FlyPanel,"💤 Anti AFK: OFF",Color3.fromRGB(60,40,90),0.5,258,0.5,38)

    UpBtn.MouseButton1Down:Connect(function() goingUp=true end)
    UpBtn.MouseButton1Up:Connect(function() goingUp=false end)
    UpBtn.MouseLeave:Connect(function() goingUp=false end)
    DownBtn.MouseButton1Down:Connect(function() goingDown=true end)
    DownBtn.MouseButton1Up:Connect(function() goingDown=false end)
    DownBtn.MouseLeave:Connect(function() goingDown=false end)

    FlyToggle.MouseButton1Click:Connect(function()
        local char=player.Character; if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart")
        local hum=char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        flying=not flying
        if flying then
            hum.PlatformStand=true
            bv=Instance.new("BodyVelocity",hrp); bv.MaxForce=Vector3.new(1e5,1e5,1e5); bv.Velocity=Vector3.zero
            bg=Instance.new("BodyGyro",hrp); bg.MaxTorque=Vector3.new(1e5,1e5,1e5); bg.P=1e4; bg.CFrame=hrp.CFrame
            FlyToggle.BackgroundColor3=Color3.fromRGB(15,150,50); FlyToggle.Text="🚀 Fly: ON"
            notify("Fly","✅ Aktif! Tahan ⬆️ naik")
        else
            flying=false; goingUp=false; goingDown=false
            hum.PlatformStand=false
            if bv then bv:Destroy() bv=nil end
            if bg then bg:Destroy() bg=nil end
            FlyToggle.BackgroundColor3=Color3.fromRGB(150,90,15); FlyToggle.Text="🚀 Fly: OFF"
            notify("Fly","❌ Nonaktif")
        end
    end)
    FlySpUp.MouseButton1Click:Connect(function() flySpeed=math.min(flySpeed+10,300); FlyLbl.Text="✈️ Fly Speed: "..flySpeed end)
    FlySpDn.MouseButton1Click:Connect(function() flySpeed=math.max(flySpeed-10,10); FlyLbl.Text="✈️ Fly Speed: "..flySpeed end)
    SpdUp.MouseButton1Click:Connect(function()
        walkSpeed=math.min(walkSpeed+10,300)
        local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed=walkSpeed end; SpdLbl.Text="⚡ Speed: "..walkSpeed
    end)
    SpdDown.MouseButton1Click:Connect(function()
        walkSpeed=math.max(walkSpeed-10,16)
        local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed=walkSpeed end; SpdLbl.Text="⚡ Speed: "..walkSpeed
    end)
    Spd50.MouseButton1Click:Connect(function()
        walkSpeed=50; local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed=50 end; SpdLbl.Text="⚡ Speed: 50"
    end)
    SpdReset.MouseButton1Click:Connect(function()
        walkSpeed=16; local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed=16 end; SpdLbl.Text="⚡ Speed: 16"; notify("Speed","Reset!")
    end)
    IJBtn.MouseButton1Click:Connect(function()
        ijActive=not ijActive
        IJBtn.BackgroundColor3=ijActive and Color3.fromRGB(30,150,50) or Color3.fromRGB(40,80,40)
        IJBtn.Text=ijActive and "🦘 Inf Jump: ON" or "🦘 Inf Jump: OFF"
    end)
    UserInputService.JumpRequest:Connect(function()
        if ijActive then
            local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
    AfkBtn.MouseButton1Click:Connect(function()
        afkActive=not afkActive
        AfkBtn.BackgroundColor3=afkActive and Color3.fromRGB(100,50,160) or Color3.fromRGB(60,40,90)
        AfkBtn.Text=afkActive and "💤 Anti AFK: ON" or "💤 Anti AFK: OFF"
        if afkActive then task.spawn(function()
            while afkActive do pcall(function()
                local v=Instance.new("VirtualUser"); v.Parent=game
                v:CaptureController(); v:ClickButton2(Vector2.new()); v:Destroy()
            end); task.wait(55) end
        end) end
    end)
    RunService.RenderStepped:Connect(function()
        if not flying then return end
        local char=player.Character; if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart")
        if not hrp or not bv or not bg then return end
        local hum=char:FindFirstChildOfClass("Humanoid")
        local md=hum and hum.MoveDirection or Vector3.zero
        local dir=Vector3.zero
        if md.Magnitude>0 then dir=Vector3.new(md.X,0,md.Z) end
        if goingUp then dir=dir+Vector3.new(0,1,0) elseif goingDown then dir=dir+Vector3.new(0,-1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
        if dir.Magnitude>0 then dir=dir.Unit end
        bv.Velocity=dir*flySpeed; bg.CFrame=workspace.CurrentCamera.CFrame
    end)

    -- ================================
    -- PANEL OIL PUMP
    -- ================================
    local OilPanel = makePanel()

    mkLbl(OilPanel,"🛢️ Auto Pompa Oil:",0,0,1,20,14,Color3.fromRGB(255,215,50))
    local oilStatusLbl = mkLbl(OilPanel,"Status: ⏹️ Tidak aktif",0,22,1,20,12,Color3.fromRGB(200,200,100))
    local oilLogLbl    = mkLbl(OilPanel,"📝 Log: -",0,44,1,20,11,Color3.fromRGB(140,200,140))
    local oilCountLbl  = mkLbl(OilPanel,"🛢️ Oil pump: 0 ditemukan",0,66,1,20,12,Color3.fromRGB(170,200,230))

    local AutoOilBtn  = mkBtn(OilPanel,"🛢️ Auto Pump: OFF",Color3.fromRGB(80,50,15),0,90,1,50)
    local ScanOilBtn  = mkBtn(OilPanel,"🔍 Scan Oil Pump",Color3.fromRGB(20,90,160),0,146,0.5,44)
    local PumpAllBtn  = mkBtn(OilPanel,"⛏️ Pump Sekali",Color3.fromRGB(130,90,15),0.5,146,0.5,44)

    local OilScroll = mkScroll(OilPanel, 0, 198, 1, 90)
    local OilSLayout = Instance.new("UIListLayout")
    OilSLayout.FillDirection = Enum.FillDirection.Horizontal
    OilSLayout.Padding = UDim.new(0,4)
    OilSLayout.Parent = OilScroll

    local scannedPumps = {}

    local function scanAndShowPumps()
        for _, v in ipairs(OilScroll:GetChildren()) do
            if v:IsA("TextButton") then v:Destroy() end
        end
        oilLogLbl.Text = "📝 Scanning oil pump..."
        task.spawn(function()
            scannedPumps = findOilPumps()
            oilCountLbl.Text = "🛢️ "..#scannedPumps.." oil pump ditemukan"
            if #scannedPumps == 0 then
                oilLogLbl.Text = "📝 Tidak ada oil pump"
                notify("Oil","❌ Tidak ada oil pump ditemukan")
            else
                oilLogLbl.Text = "📝 "..#scannedPumps.." pump ditemukan!"
                notify("Oil","✅ "..#scannedPumps.." oil pump!")
                for i, pump in ipairs(scannedPumps) do
                    local tag = Instance.new("TextButton")
                    tag.Size = UDim2.new(0,100,1,-4)
                    tag.BackgroundColor3 = Color3.fromRGB(60,40,15)
                    tag.Text = "🛢️ "..pump.name
                    tag.TextColor3 = Color3.fromRGB(220,180,100)
                    tag.Font = Enum.Font.GothamBold
                    tag.TextSize = 11
                    tag.TextWrapped = true
                    tag.ZIndex = 8
                    tag.LayoutOrder = i
                    tag.Parent = OilScroll
                    Instance.new("UICorner",tag).CornerRadius = UDim.new(0,6)
                    tag.MouseButton1Click:Connect(function()
                        pumpOil(pump)
                        notify("Pump","🛢️ Pompa "..pump.name)
                    end)
                end
                OilScroll.CanvasSize = UDim2.new(0,OilSLayout.AbsoluteContentSize.X+10,0,0)
            end
        end)
    end

    ScanOilBtn.MouseButton1Click:Connect(scanAndShowPumps)
    PumpAllBtn.MouseButton1Click:Connect(function()
        if #scannedPumps == 0 then notify("Pump","⚠️ Scan dulu!"); return end
        task.spawn(function()
            for i, pump in ipairs(scannedPumps) do
                pumpOil(pump)
                oilLogLbl.Text = "📝 Pump "..i.."/"..#scannedPumps.." "..pump.name
                task.wait(0.6)
            end
            oilLogLbl.Text = "📝 ✅ Semua dipompa! "..os.date("%H:%M:%S")
            notify("Pump","✅ Semua oil pump selesai!")
        end)
    end)

    AutoOilBtn.MouseButton1Click:Connect(function()
        autoOil = not autoOil
        if autoOil then
            AutoOilBtn.BackgroundColor3 = Color3.fromRGB(160,100,20)
            AutoOilBtn.Text = "🛢️ Auto Pump: ON"
            oilStatusLbl.Text = "Status: ✅ Aktif"
            oilStatusLbl.TextColor3 = Color3.fromRGB(80,220,80)
            notify("Auto Oil","✅ Aktif!")
            task.spawn(function()
                while autoOil do
                    pcall(function()
                        local pumps = findOilPumps()
                        oilCountLbl.Text = "🛢️ "..#pumps.." pump"
                        for _, pump in ipairs(pumps) do
                            if not autoOil then break end
                            pumpOil(pump)
                            oilLogLbl.Text = "📝 Pump "..pump.name.." "..os.date("%H:%M:%S")
                            task.wait(0.8)
                        end
                    end)
                    task.wait(6)
                end
            end)
        else
            autoOil=false
            AutoOilBtn.BackgroundColor3=Color3.fromRGB(80,50,15)
            AutoOilBtn.Text="🛢️ Auto Pump: OFF"
            oilStatusLbl.Text="Status: ⏹️ Tidak aktif"
            oilStatusLbl.TextColor3=Color3.fromRGB(200,200,100)
            oilLogLbl.Text="📝 Dihentikan"
            notify("Auto Oil","❌ Nonaktif")
        end
    end)

    -- ================================
    -- PANEL TELEPORT PULAU
    -- ================================
    local TpPanel = makePanel()

    mkLbl(TpPanel,"📍 Teleport Pulau & Base:",0,0,1,20,14,Color3.fromRGB(255,215,50))
    local tpLogLbl = mkLbl(TpPanel,"📝 Log: -",0,22,1,18,11,Color3.fromRGB(140,200,140))

    local TpSelfBtn   = mkBtn(TpPanel,"🏠 Base Sendiri",Color3.fromRGB(15,130,50),0,44,0.5,44)
    local ScanIslBtn  = mkBtn(TpPanel,"🔍 Scan Semua",Color3.fromRGB(15,90,180),0.5,44,0.5,44)

    -- Preset lokasi
    local presets = {
        {name="🏝️ Tengah",    pos=Vector3.new(0,10,0)},
        {name="🔵 Team 1",    pos=Vector3.new(-600,10,0)},
        {name="🔴 Team 2",    pos=Vector3.new(600,10,0)},
        {name="🟢 Team 3",    pos=Vector3.new(0,10,-600)},
        {name="🟡 Team 4",    pos=Vector3.new(0,10,600)},
        {name="🟣 Team 5",    pos=Vector3.new(-400,10,-400)},
        {name="⛽ Oil Rig 1", pos=Vector3.new(250,10,250)},
        {name="⛽ Oil Rig 2", pos=Vector3.new(-250,10,250)},
        {name="⛽ Oil Rig 3", pos=Vector3.new(250,10,-250)},
        {name="⛽ Oil Rig 4", pos=Vector3.new(-250,10,-250)},
    }

    local PresetScroll = mkScroll(TpPanel,0,96,1,86)
    local PSLayout = Instance.new("UIListLayout")
    PSLayout.FillDirection = Enum.FillDirection.Horizontal
    PSLayout.Padding = UDim.new(0,4)
    PSLayout.Parent = PresetScroll

    for _, loc in ipairs(presets) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0,100,1,-4)
        b.BackgroundColor3 = Color3.fromRGB(15,50,110)
        b.Text = loc.name
        b.TextColor3 = Color3.fromRGB(180,220,255)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 12
        b.TextWrapped = true
        b.ZIndex = 8
        b.Parent = PresetScroll
        Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
        b.MouseButton1Click:Connect(function()
            teleportTo(loc.pos); tpLogLbl.Text="📝 TP ke "..loc.name
            notify("TP","📍 "..loc.name)
        end)
    end
    PresetScroll.CanvasSize = UDim2.new(0,PSLayout.AbsoluteContentSize.X+10,0,0)
    PSLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        PresetScroll.CanvasSize = UDim2.new(0,PSLayout.AbsoluteContentSize.X+10,0,0)
    end)

    mkLbl(TpPanel,"👥 Pemain di Server:",0,190,1,20,13,Color3.fromRGB(170,200,230))

    local PlayerScroll = mkScroll(TpPanel,0,212,1,86)
    local PlLayout = Instance.new("UIListLayout")
    PlLayout.FillDirection = Enum.FillDirection.Horizontal
    PlLayout.Padding = UDim.new(0,4)
    PlLayout.Parent = PlayerScroll

    TpSelfBtn.MouseButton1Click:Connect(function()
        pcall(function()
            local spawn = workspace:FindFirstChildOfClass("SpawnLocation") or
                          workspace:FindFirstChild("SpawnLocation",true)
            if spawn then teleportTo(spawn.Position)
            else teleportTo(Vector3.new(0,10,0)) end
        end)
        tpLogLbl.Text="📝 TP base sendiri"; notify("TP","🏠 Base sendiri!")
    end)

    ScanIslBtn.MouseButton1Click:Connect(function()
        for _, v in ipairs(PlayerScroll:GetChildren()) do
            if v:IsA("TextButton") then v:Destroy() end
        end
        tpLogLbl.Text = "📝 Scanning..."
        task.spawn(function()
            local islands = getPlayerIslands()
            if #islands == 0 then
                tpLogLbl.Text="📝 Tidak ada pemain/pulau"
                notify("Scan","❌ Tidak ada")
            else
                tpLogLbl.Text="📝 "..#islands.." ditemukan!"
                notify("Scan","✅ "..#islands.." lokasi!")
                for i, isl in ipairs(islands) do
                    local b = Instance.new("TextButton")
                    b.Size = UDim2.new(0,110,1,-4)
                    b.BackgroundColor3 = Color3.fromRGB(15,50,110)
                    b.Text = isl.name
                    b.TextColor3 = Color3.fromRGB(180,220,255)
                    b.Font = Enum.Font.GothamBold
                    b.TextSize = 12
                    b.TextWrapped = true
                    b.ZIndex = 8
                    b.LayoutOrder = i
                    b.Parent = PlayerScroll
                    Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
                    b.MouseButton1Click:Connect(function()
                        -- Update posisi terbaru kalau player
                        if isl.type == "player" then
                            for _, p in ipairs(Players:GetPlayers()) do
                                if ("👤 "..p.Name) == isl.name then
                                    local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                                    if hrp then isl.pos = hrp.Position end
                                end
                            end
                        end
                        teleportTo(isl.pos)
                        tpLogLbl.Text="📝 TP ke "..isl.name
                        notify("TP","📍 "..isl.name)
                    end)
                end
                PlayerScroll.CanvasSize = UDim2.new(0,PlLayout.AbsoluteContentSize.X+10,0,0)
            end
        end)
    end)

    PlLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        PlayerScroll.CanvasSize = UDim2.new(0,PlLayout.AbsoluteContentSize.X+10,0,0)
    end)

    -- ================================
    -- PANEL BRANGKAS / VAULT
    -- ================================
    local VaultPanel = makePanel()

    mkLbl(VaultPanel,"🔒 Teleport ke Brangkas:",0,0,1,20,14,Color3.fromRGB(255,215,50))
    mkLbl(VaultPanel,"Cari & TP ke vault/safe/chest pemain lain",0,22,1,18,11,Color3.fromRGB(180,180,180))

    local vaultLogLbl   = mkLbl(VaultPanel,"📝 Log: -",0,44,1,18,11,Color3.fromRGB(140,200,140))
    local vaultCountLbl = mkLbl(VaultPanel,"🔒 Vault: 0 ditemukan",0,64,1,18,12,Color3.fromRGB(170,200,230))

    local ScanVaultBtn  = mkBtn(VaultPanel,"🔍 Scan Semua Brangkas",Color3.fromRGB(15,90,180),0,86,1,46)

    local VaultScroll = mkScroll(VaultPanel,0,140,1,1,Enum.ScrollingDirection.Y)
    VaultScroll.Size = UDim2.new(1,0,1,-140)
    VaultScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    VaultScroll.ScrollBarThickness = 4

    local VLayout = Instance.new("UIListLayout")
    VLayout.SortOrder = Enum.SortOrder.LayoutOrder
    VLayout.Padding = UDim.new(0,4)
    VLayout.Parent = VaultScroll

    ScanVaultBtn.MouseButton1Click:Connect(function()
        for _, v in ipairs(VaultScroll:GetChildren()) do
            if v:IsA("Frame") then v:Destroy() end
        end
        vaultLogLbl.Text = "📝 Scanning brangkas..."
        task.spawn(function()
            local vaults = getVaults()
            vaultCountLbl.Text = "🔒 "..#vaults.." brangkas ditemukan"
            if #vaults == 0 then
                vaultLogLbl.Text = "📝 Tidak ada brangkas ditemukan"
                notify("Vault","❌ Tidak ada brangkas")
            else
                vaultLogLbl.Text = "📝 "..#vaults.." brangkas!"
                notify("Vault","✅ "..#vaults.." brangkas ditemukan!")
                for i, vault in ipairs(vaults) do
                    local row = Instance.new("Frame")
                    row.Size = UDim2.new(1,-4,0,52)
                    row.BackgroundColor3 = Color3.fromRGB(25,40,70)
                    row.BorderSizePixel = 0
                    row.ZIndex = 8
                    row.LayoutOrder = i
                    row.Parent = VaultScroll
                    Instance.new("UICorner",row).CornerRadius = UDim.new(0,8)

                    local nameLbl = Instance.new("TextLabel")
                    nameLbl.Size = UDim2.new(0.6,0,0.5,0)
                    nameLbl.Position = UDim2.new(0,6,0,2)
                    nameLbl.BackgroundTransparency = 1
                    nameLbl.Text = "🔒 "..vault.name
                    nameLbl.TextColor3 = Color3.fromRGB(200,220,255)
                    nameLbl.Font = Enum.Font.GothamBold
                    nameLbl.TextSize = 13
                    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                    nameLbl.ZIndex = 9
                    nameLbl.Parent = row

                    local ownerLbl = Instance.new("TextLabel")
                    ownerLbl.Size = UDim2.new(0.6,0,0.5,0)
                    ownerLbl.Position = UDim2.new(0,6,0.5,0)
                    ownerLbl.BackgroundTransparency = 1
                    ownerLbl.Text = "👤 "..vault.owner
                    ownerLbl.TextColor3 = Color3.fromRGB(150,180,220)
                    ownerLbl.Font = Enum.Font.Gotham
                    ownerLbl.TextSize = 11
                    ownerLbl.TextXAlignment = Enum.TextXAlignment.Left
                    ownerLbl.ZIndex = 9
                    ownerLbl.Parent = row

                    local tpVaultBtn = Instance.new("TextButton")
                    tpVaultBtn.Size = UDim2.new(0.4,-8,1,-8)
                    tpVaultBtn.Position = UDim2.new(0.6,4,0,4)
                    tpVaultBtn.BackgroundColor3 = Color3.fromRGB(15,90,180)
                    tpVaultBtn.Text = "📍 TP"
                    tpVaultBtn.TextColor3 = Color3.fromRGB(255,255,255)
                    tpVaultBtn.Font = Enum.Font.GothamBold
                    tpVaultBtn.TextScaled = true
                    tpVaultBtn.ZIndex = 9
                    tpVaultBtn.Parent = row
                    Instance.new("UICorner",tpVaultBtn).CornerRadius = UDim.new(0,8)
                    tpVaultBtn.MouseButton1Click:Connect(function()
                        teleportTo(vault.pos)
                        -- Coba klik/interact vault
                        if vault.cd then fireclickdetector(vault.cd) end
                        if vault.pp then fireproximityprompt(vault.pp) end
                        vaultLogLbl.Text = "📝 TP ke "..vault.name.." ("..vault.owner..")"
                        notify("Vault","🔒 TP ke "..vault.name)
                    end)
                end
                VaultScroll.CanvasSize = UDim2.new(0,0,0,VLayout.AbsoluteContentSize.Y+10)
            end
        end)
    end)

    VLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        VaultScroll.CanvasSize = UDim2.new(0,0,0,VLayout.AbsoluteContentSize.Y+10)
    end)

    -- ================================
    -- TAB SWITCHING
    -- ================================
    local allTabs   = {FlyTab, OilTab, TpTab, VaultTab}
    local allPanels = {FlyPanel, OilPanel, TpPanel, VaultPanel}

    local function switchTab(idx)
        for i,p in ipairs(allPanels) do p.Visible=(i==idx) end
        for i,t in ipairs(allTabs) do
            t.BackgroundColor3 = (i==idx) and Color3.fromRGB(15,70,150) or Color3.fromRGB(25,45,75)
            t.TextColor3 = (i==idx) and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,180,220)
        end
    end

    for i,t in ipairs(allTabs) do
        t.MouseButton1Click:Connect(function() switchTab(i) end)
    end

    -- Tombol Buka
    local OpenBtn = Instance.new("TextButton")
    OpenBtn.Size = UDim2.new(0,70,0,70)
    OpenBtn.Position = UDim2.new(1,-80,1,-190)
    OpenBtn.BackgroundColor3 = Color3.fromRGB(15,70,150)
    OpenBtn.Text = "⚓\nNavy"
    OpenBtn.TextColor3 = Color3.fromRGB(255,255,255)
    OpenBtn.Font = Enum.Font.GothamBold
    OpenBtn.TextScaled = true
    OpenBtn.ZIndex = 10
    OpenBtn.Parent = ScreenGui
    Instance.new("UICorner",OpenBtn).CornerRadius = UDim.new(0,18)

    OpenBtn.MouseButton1Click:Connect(function()
        Frame.Visible = not Frame.Visible
        if Frame.Visible then switchTab(1) end
    end)
    CloseBtn.MouseButton1Click:Connect(function() Frame.Visible=false end)

    switchTab(1)
end

createGUI()
notify("Navy Hub v2","✅ Loaded! GUI terbuka ⚓")
print("✅ Navy Tycoon Hub v2 loaded!")
