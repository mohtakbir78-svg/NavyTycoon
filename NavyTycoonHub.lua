-- ============================================
--         NAVY TYCOON HUB v5.0
--   ESP Kapal + Teleport Pulau
--   GUI Horizontal | Mobile Friendly
--   Fix: TP ke PULAU bukan ke orang
--   Fix: ESP auto scan tiap 5 detik
--   Hapus: Speed Boat
--   Compatible: Delta, Arceus X, Fluxus
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

local STATE = {
    espEnabled     = false,
    dragging       = false,
    dragStartPos   = nil,
    dragStartFrame = nil,
    activeTab      = nil,
}

pcall(function()
    local old = plr.PlayerGui:FindFirstChild("NavyHub")
    if old then old:Destroy() end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NavyHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.Parent = plr.PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 46)
mainFrame.Position = UDim2.new(0.5, -150, 1, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 15, 28)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = false
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
local ms = Instance.new("UIStroke", mainFrame)
ms.Color = Color3.fromRGB(0, 100, 220)
ms.Thickness = 1.5

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 46)
tabBar.BackgroundColor3 = Color3.fromRGB(12, 18, 32)
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 10
tabBar.Parent = mainFrame
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 10)
local tl = Instance.new("UIListLayout")
tl.FillDirection = Enum.FillDirection.Horizontal
tl.HorizontalAlignment = Enum.HorizontalAlignment.Center
tl.VerticalAlignment = Enum.VerticalAlignment.Center
tl.Padding = UDim.new(0, 5)
tl.Parent = tabBar
local tp2 = Instance.new("UIPadding")
tp2.PaddingLeft = UDim.new(0, 6)
tp2.PaddingRight = UDim.new(0, 6)
tp2.Parent = tabBar

local panel = Instance.new("Frame")
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
local ps2 = Instance.new("UIStroke", panel)
ps2.Color = Color3.fromRGB(0, 100, 220)
ps2.Thickness = 1.5

local panelScroll = Instance.new("ScrollingFrame")
panelScroll.Size = UDim2.new(1, 0, 0, 260)
panelScroll.BackgroundTransparency = 1
panelScroll.ScrollBarThickness = 3
panelScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 120, 255)
panelScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
panelScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
panelScroll.ZIndex = 5
panelScroll.Parent = panel
local sl = Instance.new("UIListLayout")
sl.Padding = UDim.new(0, 5)
sl.Parent = panelScroll
local sp = Instance.new("UIPadding")
sp.PaddingLeft = UDim.new(0, 10)
sp.PaddingRight = UDim.new(0, 10)
sp.PaddingTop = UDim.new(0, 8)
sp.PaddingBottom = UDim.new(0, 8)
sp.Parent = panelScroll

-- HELPERS
local function makeLabel(parent, text, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(140, 170, 220)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 6
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

    local tbg = Instance.new("Frame")
    tbg.Size = UDim2.new(0, 44, 0, 22)
    tbg.Position = UDim2.new(1, -52, 0.5, -11)
    tbg.BackgroundColor3 = Color3.fromRGB(40, 55, 80)
    tbg.BorderSizePixel = 0
    tbg.ZIndex = 7
    tbg.Parent = row
    Instance.new("UICorner", tbg).CornerRadius = UDim.new(1, 0)

    local circ = Instance.new("Frame")
    circ.Size = UDim2.new(0, 16, 0, 16)
    circ.Position = UDim2.new(0, 3, 0.5, -8)
    circ.BackgroundColor3 = Color3.fromRGB(100, 130, 180)
    circ.BorderSizePixel = 0
    circ.ZIndex = 8
    circ.Parent = tbg
    Instance.new("UICorner", circ).CornerRadius = UDim.new(1, 0)

    local isOn = false
    local tw = TweenInfo.new(0.18, Enum.EasingStyle.Quad)

    local function set(val)
        isOn = val
        TweenService:Create(tbg, tw, {BackgroundColor3 = isOn and Color3.fromRGB(0,120,255) or Color3.fromRGB(40,55,80)}):Play()
        TweenService:Create(circ, tw, {
            Position = isOn and UDim2.new(0,25,0.5,-8) or UDim2.new(0,3,0.5,-8),
            BackgroundColor3 = isOn and Color3.new(1,1,1) or Color3.fromRGB(100,130,180)
        }):Play()
        if callback then pcall(callback, isOn) end
    end

    local ca = Instance.new("TextButton")
    ca.Size = UDim2.new(1, 0, 1, 0)
    ca.BackgroundTransparency = 1
    ca.Text = ""
    ca.ZIndex = 9
    ca.Parent = row
    ca.MouseButton1Click:Connect(function() set(not isOn) end)
    return set
end

local function makeButton(parent, labelText, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = color or Color3.fromRGB(0,80,180)
    btn.Text = labelText
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.ZIndex = 7
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(0,40,100)}):Play()
        task.wait(0.12)
        TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundColor3 = color or Color3.fromRGB(0,80,180)}):Play()
        if callback then pcall(callback) end
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

-- TAB SYSTEM
local tabs = {}

local function clearPanel()
    for _, c in ipairs(panelScroll:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
    end
end

local function makeTab(icon, name, buildFn)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 86, 0, 36)
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

    local abar = Instance.new("Frame")
    abar.Size = UDim2.new(0.7, 0, 0, 2)
    abar.Position = UDim2.new(0.15, 0, 1, -3)
    abar.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    abar.BorderSizePixel = 0
    abar.Visible = false
    abar.ZIndex = 13
    abar.Parent = btn
    Instance.new("UICorner", abar).CornerRadius = UDim.new(1, 0)

    local td = {btn=btn, bar=abar, name=name, buildFn=buildFn}
    table.insert(tabs, td)

    btn.MouseButton1Click:Connect(function()
        if STATE.activeTab == name and panel.Visible then
            panel.Visible = false
            STATE.activeTab = nil
            for _, t in ipairs(tabs) do
                t.btn.BackgroundColor3 = Color3.fromRGB(20,32,55)
                t.btn.TextColor3 = Color3.fromRGB(140,170,220)
                t.bar.Visible = false
            end
            return
        end
        STATE.activeTab = name
        panel.Visible = true
        for _, t in ipairs(tabs) do
            t.btn.BackgroundColor3 = Color3.fromRGB(20,32,55)
            t.btn.TextColor3 = Color3.fromRGB(140,170,220)
            t.bar.Visible = false
        end
        btn.BackgroundColor3 = Color3.fromRGB(0,60,140)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        abar.Visible = true
        clearPanel()
        pcall(buildFn)
    end)
    return td
end

-- TELEPORT HELPER: 80 studs di atas
local function safeTP(pos)
    hrp.CFrame = CFrame.new(Vector3.new(pos.X, pos.Y + 80, pos.Z))
end

local ISLAND_KW = {"island","base","plot","tycoon","pulau","territory","zone","area","outpost"}

-- Cek apakah obj adalah karakter player
local function isPlayerChar(obj)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == obj then return true end
    end
    return false
end

-- Cari posisi pulau milik targetPlr
local function findIslandPos(targetPlr)
    local tname = targetPlr.Name:lower()

    -- Pass 1: nama model/part di workspace root mengandung nama player (skip karakter)
    for _, obj in ipairs(workspace:GetChildren()) do
        if isPlayerChar(obj) then continue end
        local n = obj.Name:lower()
        if n:find(tname) then
            local part = (obj:IsA("BasePart") and obj)
                or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
            if part then return part.Position, obj.Name end
        end
    end

    -- Pass 2: model island/plot yang punya value Owner = nama player
    for _, obj in ipairs(workspace:GetChildren()) do
        if isPlayerChar(obj) then continue end
        if obj:IsA("Model") then
            local n = obj.Name:lower()
            local isIsl = false
            for _, kw in ipairs(ISLAND_KW) do
                if n:find(kw) then isIsl = true break end
            end
            if isIsl then
                for _, val in ipairs(obj:GetDescendants()) do
                    if val:IsA("StringValue") then
                        local vn = val.Name:lower()
                        if vn=="owner" or vn=="playername" or vn=="ownername" or vn=="player" then
                            if tostring(val.Value):lower() == tname then
                                local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                                if part then return part.Position, obj.Name end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Pass 3: ambil semua keyword island tapi pastikan posisinya jauh dari semua karakter
    local charPositions = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local h = p.Character:FindFirstChild("HumanoidRootPart")
            if h then table.insert(charPositions, h.Position) end
        end
    end

    local function nearChar(pos)
        for _, cp in ipairs(charPositions) do
            if (pos - cp).Magnitude < 30 then return true end
        end
        return false
    end

    for _, obj in ipairs(workspace:GetChildren()) do
        if isPlayerChar(obj) then continue end
        local n = obj.Name:lower()
        for _, kw in ipairs(ISLAND_KW) do
            if n:find(kw) then
                local part = (obj:IsA("BasePart") and obj)
                    or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                if part and not nearChar(part.Position) then
                    return part.Position, obj.Name
                end
                break
            end
        end
    end

    return nil, nil
end

-- ============================================
-- TAB 1: ESP
-- ============================================
local espStatusRef = {}

makeTab("👁️", "ESP", function()
    makeLabel(panelScroll, "  Deteksi kapal di seluruh map", Color3.fromRGB(100, 160, 255))

    local statusLbl = makeLabel(panelScroll, "  ⏸ Status: Nonaktif", Color3.fromRGB(180, 80, 80))
    espStatusRef[1] = statusLbl

    makeToggle(panelScroll, "🚢 ESP Semua Kapal", function(on)
        STATE.espEnabled = on
        if espStatusRef[1] then
            espStatusRef[1].Text = on and "  ✅ Aktif - scan tiap 5 detik" or "  ⏸ Status: Nonaktif"
            espStatusRef[1].TextColor3 = on and Color3.fromRGB(80,220,80) or Color3.fromRGB(180,80,80)
        end
        if not on then
            for _, obj in ipairs(workspace:GetDescendants()) do
                pcall(function()
                    local e = obj:FindFirstChild("_NavyESP")
                    if e then e:Destroy() end
                end)
            end
        end
    end)

    makeDivider(panelScroll)

    makeButton(panelScroll, "🔄 Refresh ESP Manual", Color3.fromRGB(0,80,160), function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                local e = obj:FindFirstChild("_NavyESP")
                if e then e:Destroy() end
            end)
        end
        print("[NavyHub] ESP refresh manual")
    end)
end)

-- ============================================
-- TAB 2: TELEPORT
-- ============================================
makeTab("📍", "TP", function()
    makeLabel(panelScroll, "  ── Pulaumu ──", Color3.fromRGB(0,200,100))

    makeButton(panelScroll, "🏝️ Pulau Sendiri", Color3.fromRGB(0,110,55), function()
        local pname = plr.Name:lower()
        for _, obj in ipairs(workspace:GetChildren()) do
            if isPlayerChar(obj) then continue end
            local n = obj.Name:lower()
            if n:find(pname) then
                local part = (obj:IsA("BasePart") and obj)
                    or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                if part then safeTP(part.Position) return end
            end
        end
        for _, obj in ipairs(workspace:GetChildren()) do
            if isPlayerChar(obj) then continue end
            local n = obj.Name:lower()
            for _, kw in ipairs(ISLAND_KW) do
                if n:find(kw) then
                    local part = (obj:IsA("BasePart") and obj)
                        or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                    if part then safeTP(part.Position) return end
                end
            end
        end
        warn("[NavyHub] Pulau sendiri tidak ditemukan")
    end)

    makeButton(panelScroll, "🌊 Tengah Laut", Color3.fromRGB(0,50,120), function()
        safeTP(Vector3.new(0,0,0))
    end)

    makeDivider(panelScroll)
    makeLabel(panelScroll, "  ── Pulau Player Lain ──", Color3.fromRGB(80,140,255))

    local others = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr then table.insert(others, p) end
    end

    if #others == 0 then
        makeLabel(panelScroll, "  (Tidak ada player lain)", Color3.fromRGB(100,120,160))
    else
        for _, tp in ipairs(others) do
            local tName = tp.Name
            makeButton(panelScroll, "🏝️  " .. tName, Color3.fromRGB(0,60,130), function()
                local pos, objName = findIslandPos(tp)
                if pos then
                    safeTP(pos)
                    print("[NavyHub] TP ke pulau " .. tName .. " | " .. tostring(objName))
                else
                    warn("[NavyHub] Pulau " .. tName .. " tidak ditemukan")
                    -- SENGAJA tidak fallback ke karakter player
                end
            end)
        end
    end

    makeDivider(panelScroll)
    makeButton(panelScroll, "🔄 Refresh Player", Color3.fromRGB(20,50,100), function()
        clearPanel()
        for _, t in ipairs(tabs) do
            if t.name == "TP" then pcall(t.buildFn) break end
        end
    end)
end)

-- ============================================
-- TAB 3: INFO
-- ============================================
makeTab("ℹ️", "Info", function()
    makeLabel(panelScroll, "  ⚓ NAVY TYCOON HUB v5.0", Color3.fromRGB(0,180,255))
    makeDivider(panelScroll)
    makeLabel(panelScroll, "  👁️  ESP scan otomatis tiap 5 detik")
    makeLabel(panelScroll, "  📍 TP 80 studs di atas pulau")
    makeLabel(panelScroll, "  🏝️  TP hanya ke PULAU (bukan orang)")
    makeLabel(panelScroll, "  🔄 Klik tab = buka/tutup panel")
    makeLabel(panelScroll, "  📌 Drag tab bar = pindah GUI")
    makeDivider(panelScroll)
    makeLabel(panelScroll, "  Delta | Arceus X | Fluxus ✅")
end)

-- ============================================
-- DRAG
-- ============================================
tabBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch
    or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        STATE.dragging = true
        STATE.dragStartPos = inp.Position
        STATE.dragStartFrame = mainFrame.Position
    end
end)
tabBar.InputChanged:Connect(function(inp)
    if not STATE.dragging then return end
    if inp.UserInputType == Enum.UserInputType.Touch
    or inp.UserInputType == Enum.UserInputType.MouseMovement then
        pcall(function()
            local d = inp.Position - STATE.dragStartPos
            mainFrame.Position = UDim2.new(
                STATE.dragStartFrame.X.Scale, STATE.dragStartFrame.X.Offset + d.X,
                STATE.dragStartFrame.Y.Scale, STATE.dragStartFrame.Y.Offset + d.Y
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
        bb.Size = UDim2.new(0,150,0,46)
        bb.StudsOffset = Vector3.new(0,6,0)
        bb.MaxDistance = 3000
        bb.Parent = part

        local bg = Instance.new("Frame",bb)
        bg.Size = UDim2.new(1,0,1,0)
        bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
        bg.BackgroundTransparency = 0.3
        bg.BorderSizePixel = 0
        Instance.new("UICorner",bg).CornerRadius = UDim.new(0,6)
        local stroke = Instance.new("UIStroke",bg)
        stroke.Color = color
        stroke.Thickness = 2

        local txt = Instance.new("TextLabel",bg)
        txt.Size = UDim2.new(1,-6,0.55,0)
        txt.Position = UDim2.new(0,3,0,2)
        txt.BackgroundTransparency = 1
        txt.Text = label
        txt.TextColor3 = Color3.new(1,1,1)
        txt.TextScaled = true
        txt.Font = Enum.Font.GothamBold

        local dist = Instance.new("TextLabel",bg)
        dist.Size = UDim2.new(1,-6,0.45,0)
        dist.Position = UDim2.new(0,3,0.55,0)
        dist.BackgroundTransparency = 1
        dist.TextColor3 = Color3.fromRGB(180,210,255)
        dist.TextScaled = true
        dist.Font = Enum.Font.Gotham

        local conn
        conn = RunService.Heartbeat:Connect(function()
            if not part or not part.Parent or not hrp or not hrp.Parent then
                pcall(function() conn:Disconnect() end) return
            end
            pcall(function()
                dist.Text = math.floor((hrp.Position - part.Position).Magnitude) .. " studs"
            end)
        end)
    end)
end

local SHIP_KW = {"ship","boat","vessel","destroyer","carrier","battleship","cruiser","submarine","frigate","warship","navy","speedboat","kapal","gunboat","galleon","dreadnought"}

local function scanShips()
    if not STATE.espEnabled then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsDescendantOf(screenGui) then return end
            local n = obj.Name:lower()
            for _, kw in ipairs(SHIP_KW) do
                if n:find(kw) then
                    local part = (obj:IsA("BasePart") and obj)
                        or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                    if part and not part:FindFirstChild("_NavyESP") then
                        local isOwn = n:find(plr.Name:lower()) ~= nil
                        createShipESP(part,
                            (isOwn and "🟢 " or "🔴 ") .. obj.Name,
                            isOwn and Color3.fromRGB(0,255,100) or Color3.fromRGB(255,70,70)
                        )
                    end
                    break
                end
            end
        end)
    end
end

-- Auto scan tiap 5 detik
task.spawn(function()
    while true do
        task.wait(5)
        pcall(scanShips)
    end
end)

-- Auto refresh TP tab
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

plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = newChar:WaitForChild("HumanoidRootPart")
    hum = newChar:WaitForChild("Humanoid")
end)

print("✅ Navy Tycoon Hub v5.0 ready!")
