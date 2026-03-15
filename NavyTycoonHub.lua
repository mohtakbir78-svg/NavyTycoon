-- ============================================
--         NAVY TYCOON HUB v4.0
--   ESP Kapal + Speed Boat + Teleport Pulau
--   GUI Horizontal | Mobile Friendly
--   Fix: tombol tidak terhalang topbar Roblox
--   Compatible: Delta, Arceus X, Fluxus
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

local STATE = {
    espEnabled     = false,
    speedBoat      = false,
    boatSpeed      = 100,
    dragging       = false,
    dragStartPos   = nil,
    dragStartFrame = nil,
    activeTab      = nil,
}

-- ============================================
-- HAPUS GUI LAMA
-- ============================================
pcall(function()
    local old = plr.PlayerGui:FindFirstChild("NavyHub")
    if old then old:Destroy() end
end)

-- ============================================
-- GUI ROOT
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NavyHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.Parent = plr.PlayerGui

-- ============================================
-- MAIN FRAME
-- Posisi BAWAH layar agar tidak terhalang topbar
-- ============================================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 340, 0, 46)
mainFrame.Position = UDim2.new(0.5, -170, 1, -220)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 15, 28)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = false
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(0, 100, 220)
mainStroke.Thickness = 1.5

-- ============================================
-- TAB BAR (horizontal)
-- ============================================
local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(1, 0, 0, 46)
tabBar.Position = UDim2.new(0, 0, 0, 0)
tabBar.BackgroundColor3 = Color3.fromRGB(12, 18, 32)
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 10
tabBar.Parent = mainFrame
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 10)

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 4)
tabLayout.Parent = tabBar

local tabPad = Instance.new("UIPadding")
tabPad.PaddingLeft = UDim.new(0, 6)
tabPad.PaddingRight = UDim.new(0, 6)
tabPad.Parent = tabBar

-- ============================================
-- PANEL CONTENT (muncul ke atas tab bar)
-- ============================================
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(1, 0, 0, 0)
panel.Position = UDim2.new(0, 0, 0, 46)
panel.BackgroundColor3 = Color3.fromRGB(10, 15, 28)
panel.BorderSizePixel = 0
panel.AutomaticSize = Enum.AutomaticSize.Y
panel.Visible = false
panel.ClipsDescendants = true
panel.ZIndex = 5
panel.Parent = mainFrame
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

local panelStroke = Instance.new("UIStroke", panel)
panelStroke.Color = Color3.fromRGB(0, 100, 220)
panelStroke.Thickness = 1.5

local panelScroll = Instance.new("ScrollingFrame")
panelScroll.Size = UDim2.new(1, 0, 0, 260)
panelScroll.BackgroundTransparency = 1
panelScroll.ScrollBarThickness = 3
panelScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 120, 255)
panelScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
panelScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
panelScroll.ZIndex = 5
panelScroll.Parent = panel

local scrollLayout = Instance.new("UIListLayout")
scrollLayout.Padding = UDim.new(0, 5)
scrollLayout.Parent = panelScroll

local scrollPad = Instance.new("UIPadding")
scrollPad.PaddingLeft = UDim.new(0, 10)
scrollPad.PaddingRight = UDim.new(0, 10)
scrollPad.PaddingTop = UDim.new(0, 8)
scrollPad.PaddingBottom = UDim.new(0, 8)
scrollPad.Parent = panelScroll

-- ============================================
-- HELPERS UI
-- ============================================
local function makeLabel(parent, text, color, zindex)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(140, 170, 220)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = zindex or 6
    lbl.Parent = parent
    return lbl
end

local function makeToggle(parent, labelText, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(18, 26, 46)
    row.BorderSizePixel = 0
    row.ZIndex = 6
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(200, 220, 255)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 7
    lbl.Parent = row

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 44, 0, 22)
    toggleBg.Position = UDim2.new(1, -52, 0.5, -11)
    toggleBg.BackgroundColor3 = Color3.fromRGB(40, 55, 80)
    toggleBg.BorderSizePixel = 0
    toggleBg.ZIndex = 7
    toggleBg.Parent = row
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = UDim2.new(0, 3, 0.5, -8)
    circle.BackgroundColor3 = Color3.fromRGB(100, 130, 180)
    circle.BorderSizePixel = 0
    circle.ZIndex = 8
    circle.Parent = toggleBg
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local isOn = false
    local tw = TweenInfo.new(0.18, Enum.EasingStyle.Quad)

    local function set(val)
        isOn = val
        TweenService:Create(toggleBg, tw, {
            BackgroundColor3 = isOn and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(40, 55, 80)
        }):Play()
        TweenService:Create(circle, tw, {
            Position = isOn and UDim2.new(0, 25, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
            BackgroundColor3 = isOn and Color3.new(1, 1, 1) or Color3.fromRGB(100, 130, 180)
        }):Play()
        if callback then pcall(callback, isOn) end
    end

    -- Gunakan TextButton transparan sebagai area klik agar mobile bisa pencet
    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.ZIndex = 9
    clickArea.Parent = row

    clickArea.MouseButton1Click:Connect(function()
        set(not isOn)
    end)

    return set
end

local function makeButton(parent, labelText, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = color or Color3.fromRGB(0, 80, 180)
    btn.Text = labelText
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.ZIndex = 7
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)

    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.08), {
            BackgroundColor3 = Color3.fromRGB(0, 40, 100)
        }):Play()
        task.wait(0.12)
        TweenService:Create(btn, TweenInfo.new(0.08), {
            BackgroundColor3 = color or Color3.fromRGB(0, 80, 180)
        }):Play()
        if callback then
            local ok, err = pcall(callback)
            if not ok then warn("[NavyHub] " .. tostring(err)) end
        end
    end)

    return btn
end

local function makeDivider(parent)
    local d = Instance.new("Frame")
    d.Size = UDim2.new(1, 0, 0, 1)
    d.BackgroundColor3 = Color3.fromRGB(30, 50, 80)
    d.BorderSizePixel = 0
    d.ZIndex = 6
    d.Parent = parent
end

-- ============================================
-- TAB SYSTEM
-- ============================================
local tabs = {}
local tabContents = {}

local function clearPanel()
    for _, c in ipairs(panelScroll:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then
            c:Destroy()
        end
    end
end

local function makeTab(icon, name, buildFn)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 72, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(20, 32, 55)
    btn.Text = icon .. "\n" .. name
    btn.TextColor3 = Color3.fromRGB(140, 170, 220)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.ZIndex = 12
    btn.Parent = tabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)

    local activeBar = Instance.new("Frame")
    activeBar.Size = UDim2.new(0.7, 0, 0, 2)
    activeBar.Position = UDim2.new(0.15, 0, 1, -3)
    activeBar.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    activeBar.BorderSizePixel = 0
    activeBar.Visible = false
    activeBar.ZIndex = 13
    activeBar.Parent = btn
    Instance.new("UICorner", activeBar).CornerRadius = UDim.new(1, 0)

    table.insert(tabs, {btn = btn, bar = activeBar, name = name, buildFn = buildFn})

    btn.MouseButton1Click:Connect(function()
        -- Toggle: kalau tab sudah aktif, tutup panel
        if STATE.activeTab == name and panel.Visible then
            panel.Visible = false
            STATE.activeTab = nil
            for _, t in ipairs(tabs) do
                t.btn.BackgroundColor3 = Color3.fromRGB(20, 32, 55)
                t.btn.TextColor3 = Color3.fromRGB(140, 170, 220)
                t.bar.Visible = false
            end
            return
        end

        STATE.activeTab = name
        panel.Visible = true

        -- Reset semua tab style
        for _, t in ipairs(tabs) do
            t.btn.BackgroundColor3 = Color3.fromRGB(20, 32, 55)
            t.btn.TextColor3 = Color3.fromRGB(140, 170, 220)
            t.bar.Visible = false
        end

        -- Aktifkan tab ini
        btn.BackgroundColor3 = Color3.fromRGB(0, 60, 140)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        activeBar.Visible = true

        -- Build konten
        clearPanel()
        pcall(buildFn)
    end)
end

-- ============================================
-- TELEPORT HELPER
-- ============================================
local function safeTP(pos)
    -- Teleport 60 studs di atas posisi target agar tidak stuck di dalam objek
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 60, 0))
end

local function findIslandOfPlayer(targetPlr)
    local targetName = targetPlr.Name:lower()
    local keywords = {"island", "base", "plot", "tycoon", "pulau", "territory"}

    -- Prioritas 1: nama objek mengandung nama player
    for _, obj in ipairs(workspace:GetChildren()) do
        local n = obj.Name:lower()
        if n:find(targetName) then
            local part = (obj:IsA("BasePart") and obj)
                or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
            if part then return part.Position end
        end
    end

    -- Prioritas 2: cek value Owner di dalam model
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") then
            local n = obj.Name:lower()
            local isIsland = false
            for _, kw in ipairs(keywords) do
                if n:find(kw) then isIsland = true break end
            end
            if isIsland then
                for _, val in ipairs(obj:GetDescendants()) do
                    if (val.Name:lower() == "owner" or val.Name:lower() == "playername" or val.Name:lower() == "ownername") then
                        if tostring(val.Value):lower() == targetName then
                            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            if part then return part.Position end
                        end
                    end
                end
            end
        end
    end

    -- Prioritas 3: keyword island di workspace children
    for _, obj in ipairs(workspace:GetChildren()) do
        local n = obj.Name:lower()
        for _, kw in ipairs(keywords) do
            if n:find(kw) then
                local part = (obj:IsA("BasePart") and obj)
                    or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                if part then return part.Position end
            end
        end
    end

    return nil
end

-- ============================================
-- TAB 1: ESP
-- ============================================
makeTab("👁️", "ESP", function()
    makeLabel(panelScroll, "  Deteksi kapal di seluruh map", Color3.fromRGB(100, 160, 255))

    makeToggle(panelScroll, "🚢 ESP Semua Kapal", function(on)
        STATE.espEnabled = on
        if not on then
            for _, obj in ipairs(workspace:GetDescendants()) do
                pcall(function()
                    local e = obj:FindFirstChild("_NavyESP")
                    if e then e:Destroy() end
                end)
            end
        end
    end)

    makeToggle(panelScroll, "🔴 Highlight Kapal Musuh", function(on)
        STATE.enemyHighlight = on
    end)

    makeToggle(panelScroll, "🟢 Highlight Kapal Sendiri", function(on)
        STATE.friendHighlight = on
    end)

    makeDivider(panelScroll)

    makeButton(panelScroll, "🔄 Refresh ESP Sekarang", Color3.fromRGB(0, 80, 160), function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                local e = obj:FindFirstChild("_NavyESP")
                if e then e:Destroy() end
            end)
        end
        print("[NavyHub] ESP di-refresh")
    end)
end)

-- ============================================
-- TAB 2: SPEED
-- ============================================
makeTab("⚡", "Speed", function()
    makeLabel(panelScroll, "  Boost kapal yang kamu tumpangi", Color3.fromRGB(100, 160, 255))

    makeToggle(panelScroll, "⚡ Speed Boat ON", function(on)
        STATE.speedBoat = on
        if not on then
            for _, v in ipairs(workspace:GetDescendants()) do
                pcall(function()
                    if v.Name == "_NavyBoostBV" then v:Destroy() end
                end)
            end
        end
    end)

    makeDivider(panelScroll)

    -- Speed slider row
    local speedRow = Instance.new("Frame")
    speedRow.Size = UDim2.new(1, 0, 0, 40)
    speedRow.BackgroundColor3 = Color3.fromRGB(18, 26, 46)
    speedRow.BorderSizePixel = 0
    speedRow.ZIndex = 6
    speedRow.Parent = panelScroll
    Instance.new("UICorner", speedRow).CornerRadius = UDim.new(0, 7)

    local speedLbl = Instance.new("TextLabel")
    speedLbl.Size = UDim2.new(0.5, 0, 1, 0)
    speedLbl.Position = UDim2.new(0, 10, 0, 0)
    speedLbl.BackgroundTransparency = 1
    speedLbl.Text = "Speed: " .. STATE.boatSpeed
    speedLbl.TextColor3 = Color3.fromRGB(200, 220, 255)
    speedLbl.Font = Enum.Font.GothamBold
    speedLbl.TextSize = 12
    speedLbl.TextXAlignment = Enum.TextXAlignment.Left
    speedLbl.ZIndex = 7
    speedLbl.Parent = speedRow

    local minusBtn = Instance.new("TextButton")
    minusBtn.Size = UDim2.new(0, 34, 0, 26)
    minusBtn.Position = UDim2.new(0.55, 0, 0.5, -13)
    minusBtn.BackgroundColor3 = Color3.fromRGB(30, 50, 85)
    minusBtn.Text = "−"
    minusBtn.TextColor3 = Color3.new(1, 1, 1)
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.TextSize = 18
    minusBtn.BorderSizePixel = 0
    minusBtn.ZIndex = 8
    minusBtn.Parent = speedRow
    Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 6)

    local plusBtn = Instance.new("TextButton")
    plusBtn.Size = UDim2.new(0, 34, 0, 26)
    plusBtn.Position = UDim2.new(0.55, 40, 0.5, -13)
    plusBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 180)
    plusBtn.Text = "+"
    plusBtn.TextColor3 = Color3.new(1, 1, 1)
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.TextSize = 18
    plusBtn.BorderSizePixel = 0
    plusBtn.ZIndex = 8
    plusBtn.Parent = speedRow
    Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 6)

    minusBtn.MouseButton1Click:Connect(function()
        STATE.boatSpeed = math.max(20, STATE.boatSpeed - 20)
        speedLbl.Text = "Speed: " .. STATE.boatSpeed
    end)

    plusBtn.MouseButton1Click:Connect(function()
        STATE.boatSpeed = math.min(500, STATE.boatSpeed + 20)
        speedLbl.Text = "Speed: " .. STATE.boatSpeed
    end)

    makeLabel(panelScroll, "  Tahan W = maju | S = mundur", Color3.fromRGB(100, 140, 200))
end)

-- ============================================
-- TAB 3: TELEPORT
-- ============================================
makeTab("📍", "TP", function()
    makeLabel(panelScroll, "  ── Pulaumu ──", Color3.fromRGB(0, 200, 100))

    makeButton(panelScroll, "🏝️ Pulau Sendiri", Color3.fromRGB(0, 110, 55), function()
        local plrName = plr.Name:lower()
        local keywords = {"island", "base", "plot", "tycoon", "pulau", "territory"}

        for _, obj in ipairs(workspace:GetChildren()) do
            local n = obj.Name:lower()
            if n:find(plrName) then
                local part = (obj:IsA("BasePart") and obj)
                    or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                if part then
                    safeTP(part.Position)
                    print("[NavyHub] TP ke pulau sendiri")
                    return
                end
            end
        end

        for _, obj in ipairs(workspace:GetChildren()) do
            local n = obj.Name:lower()
            for _, kw in ipairs(keywords) do
                if n:find(kw) then
                    local part = (obj:IsA("BasePart") and obj)
                        or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                    if part then
                        safeTP(part.Position)
                        print("[NavyHub] TP ke: " .. obj.Name)
                        return
                    end
                end
            end
        end
        warn("[NavyHub] Pulau sendiri tidak ditemukan")
    end)

    makeButton(panelScroll, "🌊 Tengah Laut", Color3.fromRGB(0, 50, 120), function()
        safeTP(Vector3.new(0, 0, 0))
    end)

    makeDivider(panelScroll)
    makeLabel(panelScroll, "  ── Pulau Player Lain ──", Color3.fromRGB(80, 140, 255))

    -- Buat tombol per player
    local otherPlayers = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr then
            table.insert(otherPlayers, p)
        end
    end

    if #otherPlayers == 0 then
        makeLabel(panelScroll, "  (Tidak ada player lain)", Color3.fromRGB(100, 120, 160))
    else
        for _, targetPlr in ipairs(otherPlayers) do
            local tName = targetPlr.Name
            makeButton(panelScroll, "🏝️  " .. tName, Color3.fromRGB(0, 60, 130), function()
                local pos = findIslandOfPlayer(targetPlr)
                if pos then
                    safeTP(pos)
                    print("[NavyHub] TP ke pulau " .. tName)
                else
                    -- Fallback ke posisi karakter
                    local tChar = targetPlr.Character
                    if tChar then
               local tHrp = tChar:FindFirstChild("HumanoidRootPart")
                        if tHrp then
                            safeTP(tHrp.Position)
                            print("[NavyHub] TP ke posisi " .. tName .. " (pulau tidak ditemukan)")
                            return
                        end
                    end
                    warn("[NavyHub] Tidak bisa TP ke " .. tName)
                end
            end)
        end
    end

    makeDivider(panelScroll)
    makeButton(panelScroll, "🔄 Refresh Daftar Player", Color3.fromRGB(20, 50, 100), function()
        -- Re-open tab ini
        clearPanel()
        for _, t in ipairs(tabs) do
            if t.name == "TP" then
                pcall(t.buildFn)
                break
            end
        end
    end)
end)

-- ============================================
-- TAB 4: INFO
-- ============================================
makeTab("ℹ️", "Info", function()
    makeLabel(panelScroll, "  ⚓ NAVY TYCOON HUB v4.0", Color3.fromRGB(0, 180, 255))
    makeDivider(panelScroll)
    makeLabel(panelScroll, "  👁️ ESP: auto scan tiap 5 detik")
    makeLabel(panelScroll, "  ⚡ Speed: tahan W saat di kapal")
    makeLabel(panelScroll, "  📍 TP: muncul 60 studs di atas pulau")
    makeLabel(panelScroll, "  🔄 Klik tab aktif = tutup panel")
    makeLabel(panelScroll, "  📌 Drag title bar untuk pindah GUI")
    makeDivider(panelScroll)
    makeLabel(panelScroll, "  Compatible: Delta, Arceus X, Fluxus")
end)

-- ============================================
-- DRAG (pegang tab bar untuk pindah GUI)
-- ============================================
local dragConn
tabBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch
    or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        STATE.dragging = true
        STATE.dragStartPos = inp.Position
        STATE.dragStartFrame = mainFrame.Position
    end
end)

tabBar.InputChanged:Connect(function(inp)
    if STATE.dragging and (
        inp.UserInputType == Enum.UserInputType.Touch or
        inp.UserInputType == Enum.UserInputType.MouseMovement
    ) then
        pcall(function()
            local delta = inp.Position - STATE.dragStartPos
            local newX = STATE.dragStartFrame.X.Offset + delta.X
            local newY = STATE.dragStartFrame.Y.Offset + delta.Y
            mainFrame.Position = UDim2.new(
                STATE.dragStartFrame.X.Scale, newX,
                STATE.dragStartFrame.Y.Scale, newY
            )
        end)
    end
end)

tabBar.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch
    or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        STATE.dragging = false
    end
end)

-- ============================================
-- ESP CORE
-- ============================================
local function createShipESP(part, label, color)
    pcall(function()
        if part:FindFirstChild("_NavyESP") then return end

        local bb = Instance.new("BillboardGui")
        bb.Name = "_NavyESP"
        bb.AlwaysOnTop = true
        bb.Size = UDim2.new(0, 140, 0, 46)
        bb.StudsOffset = Vector3.new(0, 5, 0)
        bb.MaxDistance = 2000
        bb.Parent = part

        local bg = Instance.new("Frame", bb)
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        bg.BackgroundTransparency = 0.35
        bg.BorderSizePixel = 0
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)

        local stroke = Instance.new("UIStroke", bg)
        stroke.Color = color
        stroke.Thickness = 2

        local txt = Instance.new("TextLabel", bg)
        txt.Size = UDim2.new(1, -6, 0.58, 0)
        txt.Position = UDim2.new(0, 3, 0, 2)
        txt.BackgroundTransparency = 1
        txt.Text = label
        txt.TextColor3 = Color3.new(1, 1, 1)
        txt.TextScaled = true
        txt.Font = Enum.Font.GothamBold

        local distTxt = Instance.new("TextLabel", bg)
        distTxt.Size = UDim2.new(1, -6, 0.42, 0)
        distTxt.Position = UDim2.new(0, 3, 0.58, 0)
        distTxt.BackgroundTransparency = 1
        distTxt.TextColor3 = Color3.fromRGB(180, 200, 255)
        distTxt.TextScaled = true
        distTxt.Font = Enum.Font.Gotham

        local conn
        conn = RunService.Heartbeat:Connect(function()
            if not part or not part.Parent or not hrp or not hrp.Parent then
                pcall(function() conn:Disconnect() end)
                return
            end
            pcall(function()
                distTxt.Text = math.floor((hrp.Position - part.Position).Magnitude) .. " studs"
            end)
        end)
    end)
end

local SHIP_KW = {
    "ship","boat","vessel","destroyer","carrier",
    "battleship","cruiser","submarine","frigate",
    "warship","navy","speedboat","kapal"
}

local function scanShips()
    if not STATE.espEnabled then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            local n = obj.Name:lower()
            for _, kw in ipairs(SHIP_KW) do
                if n:find(kw) then
                    local part = obj:IsA("BasePart") and obj
                        or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                    if part and not part:FindFirstChild("_NavyESP") then
                        local isOwn = n:find(plr.Name:lower()) ~= nil
                        local color = isOwn and Color3.fromRGB(0,255,80) or Color3.fromRGB(255,80,80)
                        local label = isOwn and "🟢 "..obj.Name or "🔴 "..obj.Name
                        createShipESP(part, label, color)
                    end
                    break
                end
            end
        end)
    end
end

task.spawn(function()
    while true do
        task.wait(5)
        pcall(scanShips)
    end
end)

-- ============================================
-- SPEED BOAT LOOP
-- ============================================
task.spawn(function()
    while true do
        task.wait(0.1)
        if not STATE.speedBoat then continue end
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if (obj:IsA("Seat") or obj:IsA("VehicleSeat")) and obj.Occupant == hum then
                    local boatRoot = obj.Parent:FindFirstChildWhichIsA("BasePart")
                    if boatRoot then
                        local bv = boatRoot:FindFirstChild("_NavyBoostBV")
                        if not bv then
                            bv = Instance.new("BodyVelocity")
                            bv.Name = "_NavyBoostBV"
                            bv.MaxForce = Vector3.new(1e6, 0, 1e6)
                            bv.Velocity = Vector3.zero
                            bv.Parent = boatRoot
                        end
                        local cam = workspace.CurrentCamera
                        local look = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
                        if look.Magnitude > 0 then look = look.Unit end
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                            bv.Velocity = look * STATE.boatSpeed
                        elseif UserInputService:IsKeyDown(Enum.KeyCode.S) then
                            bv.Velocity = -look * (STATE.boatSpeed * 0.5)
                        else
                            bv.Velocity = Vector3.zero
                        end
                    end
                end
            end
        end)
    end
end)

-- ============================================
-- RESPAWN
-- ============================================
plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = newChar:WaitForChild("HumanoidRootPart")
    hum = newChar:WaitForChild("Humanoid")
end)

-- Auto-refresh daftar player
Players.PlayerAdded:Connect(function()
    if STATE.activeTab == "TP" then
        task.wait(1)
        clearPanel()
        for _, t in ipairs(tabs) do
            if t.name == "TP" then pcall(t.buildFn) break end
        end
    end
end)

Players.PlayerRemoving:Connect(function()
    if STATE.activeTab == "TP" then
        task.wait(0.5)
        clearPanel()
        for _, t in ipairs(tabs) do
            if t.name == "TP" then pcall(t.buildFn) break end
        end
    end
end)

print("✅ Navy Tycoon Hub v4.0 loaded!")
print("📱 GUI horizontal di bawah layar - aman dari topbar Roblox")
print("📍 Teleport muncul 60 studs di atas pulau")
