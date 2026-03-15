-- ============================================
--         NAVY TYCOON HUB v3.0
--   ESP Kapal + Speed Boat + Teleport Pulau
--   Compatible: Delta, Arceus X, Fluxus
--   By: Claude (Anthropic)
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")
local mouse = plr:GetMouse()

local STATE = {
    espEnabled    = false,
    enemyHighlight = false,
    friendHighlight = false,
    speedBoat     = false,
    boatSpeed     = 100,
    dragging      = false,
    dragOffset    = Vector2.zero,
}

-- ============================================
-- HAPUS GUI LAMA (anti error re-execute)
-- ============================================
pcall(function()
    local old = plr.PlayerGui:FindFirstChild("NavyHub")
    if old then old:Destroy() end
end)

-- ============================================
-- GUI SETUP
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NavyHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = plr.PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 440)
mainFrame.Position = UDim2.new(0, 20, 0.5, -220)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 15, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(15, 25, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

-- Fix sudut bawah titlebar
local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0.5, 0)
titleFix.Position = UDim2.new(0, 0, 0.5, 0)
titleFix.BackgroundColor3 = Color3.fromRGB(15, 25, 45)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

-- Garis aksen biru
local accent = Instance.new("Frame")
accent.Size = UDim2.new(1, 0, 0, 2)
accent.Position = UDim2.new(0, 0, 1, -2)
accent.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
accent.BorderSizePixel = 0
accent.Parent = titleBar

local titleTxt = Instance.new("TextLabel")
titleTxt.Size = UDim2.new(1, -50, 1, 0)
titleTxt.Position = UDim2.new(0, 12, 0, 0)
titleTxt.BackgroundTransparency = 1
titleTxt.Text = "⚓ NAVY TYCOON HUB"
titleTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
titleTxt.Font = Enum.Font.GothamBold
titleTxt.TextSize = 14
titleTxt.TextXAlignment = Enum.TextXAlignment.Left
titleTxt.Parent = titleBar

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -38, 0, 7)
minBtn.BackgroundColor3 = Color3.fromRGB(30, 50, 80)
minBtn.Text = "—"
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.BorderSizePixel = 0
minBtn.Parent = titleBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

-- Content Area
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, 0, 1, -45)
content.Position = UDim2.new(0, 0, 0, 45)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 3
content.ScrollBarImageColor3 = Color3.fromRGB(0, 120, 255)
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.Parent = content

local cPad = Instance.new("UIPadding")
cPad.PaddingLeft = UDim.new(0, 10)
cPad.PaddingRight = UDim.new(0, 10)
cPad.PaddingTop = UDim.new(0, 8)
cPad.PaddingBottom = UDim.new(0, 8)
cPad.Parent = content

-- ============================================
-- HELPER: FOLDER / SECTION
-- ============================================
local function makeFolder(name, icon)
    local folder = Instance.new("Frame")
    folder.Size = UDim2.new(1, 0, 0, 32)
    folder.BackgroundColor3 = Color3.fromRGB(20, 35, 60)
    folder.BorderSizePixel = 0
    folder.Parent = content
    Instance.new("UICorner", folder).CornerRadius = UDim.new(0, 7)

    local folderTxt = Instance.new("TextLabel")
    folderTxt.Size = UDim2.new(1, -30, 1, 0)
    folderTxt.Position = UDim2.new(0, 10, 0, 0)
    folderTxt.BackgroundTransparency = 1
    folderTxt.Text = icon .. "  " .. name
    folderTxt.TextColor3 = Color3.fromRGB(0, 150, 255)
    folderTxt.Font = Enum.Font.GothamBold
    folderTxt.TextSize = 13
    folderTxt.TextXAlignment = Enum.TextXAlignment.Left
    folderTxt.Parent = folder

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -26, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Color3.fromRGB(80, 120, 180)
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 11
    arrow.Parent = folder

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundColor3 = Color3.fromRGB(15, 25, 45)
    container.BorderSizePixel = 0
    container.Parent = content
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 7)

    local cLayout = Instance.new("UIListLayout")
    cLayout.Padding = UDim.new(0, 5)
    cLayout.Parent = container

    local cp = Instance.new("UIPadding")
    cp.PaddingLeft = UDim.new(0, 8)
    cp.PaddingRight = UDim.new(0, 8)
    cp.PaddingTop = UDim.new(0, 6)
    cp.PaddingBottom = UDim.new(0, 6)
    cp.Parent = container

    local collapsed = false
    folder.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            collapsed = not collapsed
            container.Visible = not collapsed
            arrow.Text = collapsed and "▶" or "▼"
        end
    end)

    return container
end

-- ============================================
-- HELPER: TOGGLE
-- ============================================
local function makeToggle(parent, labelText, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 32)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -54, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(200, 220, 255)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 44, 0, 22)
    toggleBg.Position = UDim2.new(1, -44, 0.5, -11)
    toggleBg.BackgroundColor3 = Color3.fromRGB(40, 55, 80)
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = row
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = UDim2.new(0, 3, 0.5, -8)
    circle.BackgroundColor3 = Color3.fromRGB(100, 130, 180)
    circle.BorderSizePixel = 0
    circle.Parent = toggleBg
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local isOn = false
    local tw = TweenInfo.new(0.2, Enum.EasingStyle.Quad)

    local function set(val)
        isOn = val
        TweenService:Create(toggleBg, tw, {
            BackgroundColor3 = isOn and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(40, 55, 80)
        }):Play()
        TweenService:Create(circle, tw, {
            Position = isOn and UDim2.new(0, 25, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
            BackgroundColor3 = isOn and Color3.new(1, 1, 1) or Color3.fromRGB(100, 130, 180)
        }):Play()
        if callback then callback(isOn) end
    end

    toggleBg.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            set(not isOn)
        end
    end)

    return set
end

-- ============================================
-- HELPER: LABEL
-- ============================================
local function makeLabel(parent, text, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(120, 150, 200)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

-- ============================================
-- HELPER: BUTTON
-- ============================================
local function makeButton(parent, labelText, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = color or Color3.fromRGB(0, 80, 180)
    btn.Text = labelText
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(0, 40, 100)
        }):Play()
        task.wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.1), {
            BackgroundColor3 = color or Color3.fromRGB(0, 80, 180)
        }):Play()
        if callback then
            local ok, err = pcall(callback)
            if not ok then warn("[NavyHub] " .. tostring(err)) end
        end
    end)

    return btn
end

-- ============================================
-- STATUS BAR
-- ============================================
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, 0, 0, 26)
statusBar.BackgroundTransparency = 1
statusBar.Parent = content

local espCountLbl = Instance.new("TextLabel")
espCountLbl.Size = UDim2.new(1, 0, 1, 0)
espCountLbl.BackgroundTransparency = 1
espCountLbl.Text = "🚢 Kapal terdeteksi: 0"
espCountLbl.TextColor3 = Color3.fromRGB(0, 180, 255)
espCountLbl.Font = Enum.Font.GothamBold
espCountLbl.TextSize = 12
espCountLbl.TextXAlignment = Enum.TextXAlignment.Left
espCountLbl.Parent = statusBar

-- ============================================
-- FOLDER 1: ESP KAPAL
-- ============================================
local espFolder = makeFolder("ESP Kapal", "👁️")
makeLabel(espFolder, "  Deteksi semua kapal di map")

makeToggle(espFolder, "🚢 ESP Semua Kapal", function(on)
    STATE.espEnabled = on
    if not on then
        for _, obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                local e = obj:FindFirstChild("_NavyESP")
                if e then e:Destroy() end
            end)
        end
        espCountLbl.Text = "🚢 Kapal terdeteksi: 0"
    end
end)

makeToggle(espFolder, "🔴 Highlight Kapal Musuh", function(on)
    STATE.enemyHighlight = on
end)

makeToggle(espFolder, "🟢 Highlight Kapal Sendiri", function(on)
    STATE.friendHighlight = on
end)

makeButton(espFolder, "🔄 Refresh ESP", Color3.fromRGB(0, 80, 160), function()
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            local e = obj:FindFirstChild("_NavyESP")
            if e then e:Destroy() end
        end)
    end
end)

-- ============================================
-- FOLDER 2: SPEED BOAT
-- ============================================
local speedFolder = makeFolder("Speed Boat", "⚡")
makeLabel(speedFolder, "  Tahan W untuk boost kapal")

makeToggle(speedFolder, "⚡ Speed Boat ON", function(on)
    STATE.speedBoat = on
    if not on then
        for _, v in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if v.Name == "_NavyBoostBV" then v:Destroy() end
            end)
        end
    end
end)

local speedRow = Instance.new("Frame")
speedRow.Size = UDim2.new(1, 0, 0, 30)
speedRow.BackgroundTransparency = 1
speedRow.Parent = speedFolder

local speedLbl = Instance.new("TextLabel")
speedLbl.Size = UDim2.new(0.55, 0, 1, 0)
speedLbl.BackgroundTransparency = 1
speedLbl.Text = "Speed: " .. STATE.boatSpeed
speedLbl.TextColor3 = Color3.fromRGB(200, 220, 255)
speedLbl.Font = Enum.Font.Gotham
speedLbl.TextSize = 12
speedLbl.TextXAlignment = Enum.TextXAlignment.Left
speedLbl.Parent = speedRow

local minusBtn = Instance.new("TextButton")
minusBtn.Size = UDim2.new(0, 30, 0, 24)
minusBtn.Position = UDim2.new(0.58, 0, 0.5, -12)
minusBtn.BackgroundColor3 = Color3.fromRGB(30, 50, 80)
minusBtn.Text = "−"
minusBtn.TextColor3 = Color3.new(1, 1, 1)
minusBtn.Font = Enum.Font.GothamBold
minusBtn.TextSize = 16
minusBtn.BorderSizePixel = 0
minusBtn.Parent = speedRow
Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 5)

local plusBtn = Instance.new("TextButton")
plusBtn.Size = UDim2.new(0, 30, 0, 24)
plusBtn.Position = UDim2.new(0.58, 36, 0.5, -12)
plusBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
plusBtn.Text = "+"
plusBtn.TextColor3 = Color3.new(1, 1, 1)
plusBtn.Font = Enum.Font.GothamBold
plusBtn.TextSize = 16
plusBtn.BorderSizePixel = 0
plusBtn.Parent = speedRow
Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 5)

minusBtn.MouseButton1Click:Connect(function()
    STATE.boatSpeed = math.max(20, STATE.boatSpeed - 20)
    speedLbl.Text = "Speed: " .. STATE.boatSpeed
end)

plusBtn.MouseButton1Click:Connect(function()
    STATE.boatSpeed = math.min(500, STATE.boatSpeed + 20)
    speedLbl.Text = "Speed: " .. STATE.boatSpeed
end)

-- ============================================
-- FOLDER 3: TELEPORT
-- ============================================
local tpFolder = makeFolder("Teleport", "📍")

makeLabel(tpFolder, "  ── Pulaumu Sendiri ──", Color3.fromRGB(0, 180, 80))

makeButton(tpFolder, "🏝️ Teleport Pulau Sendiri", Color3.fromRGB(0, 100, 50), function()
    -- Cari objek di workspace yang namanya mengandung username kita
    -- atau keyword pulau/island/plot/base
    local plrName = plr.Name:lower()
    local keywords = {"island", "base", "plot", "tycoon", "pulau"}

    -- Prioritas 1: cari yang namanya ada username kita
    for _, obj in ipairs(workspace:GetDescendants()) do
        local n = obj.Name:lower()
        if n:find(plrName) then
            local part = obj:IsA("BasePart") and obj
                or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
            if part then
                hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 12, 0))
                print("[NavyHub] Teleport ke pulau sendiri: " .. obj.Name)
                return
            end
        end
    end

    -- Prioritas 2: cari keyword umum
    for _, obj in ipairs(workspace:GetDescendants()) do
        local n = obj.Name:lower()
        for _, kw in ipairs(keywords) do
            if n:find(kw) then
                local part = obj:IsA("BasePart") and obj
                    or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                if part then
                    hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 12, 0))
                    print("[NavyHub] Teleport ke: " .. obj.Name)
                    return
                end
            end
        end
    end

    warn("[NavyHub] Pulau sendiri tidak ditemukan")
end)

makeLabel(tpFolder, "  ── Pulau Player Lain ──", Color3.fromRGB(80, 120, 200))

-- Container khusus untuk tombol player (bisa di-refresh)
local playerBtnContainer = Instance.new("Frame")
playerBtnContainer.Size = UDim2.new(1, 0, 0, 0)
playerBtnContainer.AutomaticSize = Enum.AutomaticSize.Y
playerBtnContainer.BackgroundTransparency = 1
playerBtnContainer.Parent = tpFolder

local pBtnLayout = Instance.new("UIListLayout")
pBtnLayout.Padding = UDim.new(0, 4)
pBtnLayout.Parent = playerBtnContainer

-- Fungsi cari pulau milik player tertentu di workspace
local function findIslandOfPlayer(targetPlr)
    local targetName = targetPlr.Name:lower()
    local keywords = {"island", "base", "plot", "tycoon", "pulau"}

    -- Prioritas 1: nama objek mengandung nama player
    for _, obj in ipairs(workspace:GetDescendants()) do
        local n = obj.Name:lower()
        if n:find(targetName) then
            local part = obj:IsA("BasePart") and obj
                or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
            if part then
                return part, obj.Name
            end
        end
    end

    -- Prioritas 2: cek folder/model di workspace langsung (tycoon biasanya 1 level)
    for _, obj in ipairs(workspace:GetChildren()) do
        local n = obj.Name:lower()
        for _, kw in ipairs(keywords) do
            if n:find(kw) then
                -- Cek apakah ada attribute/value nama player di dalamnya
                local ownerVal = obj:FindFirstChild("Owner")
                    or obj:FindFirstChild("PlayerName")
                    or obj:FindFirstChild("ownerName")
                if ownerVal and tostring(ownerVal.Value):lower() == targetName then
                    local part = obj:IsA("BasePart") and obj
                        or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                    if part then
                        return part, obj.Name
                    end
                end
            end
        end
    end

    -- Prioritas 3: semua keyword island/base (fallback)
    for _, obj in ipairs(workspace:GetChildren()) do
        local n = obj.Name:lower()
        for _, kw in ipairs(keywords) do
            if n:find(kw) then
                local part = obj:IsA("BasePart") and obj
                    or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                if part then
                    return part, obj.Name
                end
            end
        end
    end

    return nil, nil
end

-- Build tombol per player
local function buildPlayerButtons()
    -- Hapus tombol lama
    for _, child in ipairs(playerBtnContainer:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end

    local otherPlayers = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr then
            table.insert(otherPlayers, p)
        end
    end

    if #otherPlayers == 0 then
        local noPlr = Instance.new("TextLabel")
        noPlr.Size = UDim2.new(1, 0, 0, 24)
        noPlr.BackgroundTransparency = 1
        noPlr.Text = "  (Tidak ada player lain)"
        noPlr.TextColor3 = Color3.fromRGB(100, 120, 160)
        noPlr.Font = Enum.Font.Gotham
        noPlr.TextSize = 11
        noPlr.TextXAlignment = Enum.TextXAlignment.Left
        noPlr.Parent = playerBtnContainer
        return
    end

    for _, targetPlr in ipairs(otherPlayers) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(0, 55, 110)
        btn.Text = "🏝️  " .. targetPlr.Name
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.BorderSizePixel = 0
        btn.Name = "_PlayerTP_" .. targetPlr.Name
        btn.Parent = playerBtnContainer
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(0, 30, 70)
            }):Play()
            task.wait(0.1)
            TweenService:Create(btn, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(0, 55, 110)
            }):Play()

            local ok, err = pcall(function()
                local part, objName = findIslandOfPlayer(targetPlr)
                if part then
                    hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 12, 0))
                    print("[NavyHub] Teleport ke pulau " .. targetPlr.Name .. " (" .. tostring(objName) .. ")")
                else
                    -- Fallback: teleport ke karakter player itu
                    local tChar = targetPlr.Character
                    if tChar then
                        local tHrp = tChar:FindFirstChild("HumanoidRootPart")
                        if tHrp then
                            hrp.CFrame = tHrp.CFrame + Vector3.new(5, 0, 0)
                            print("[NavyHub] Pulau tidak ditemukan, teleport ke posisi " .. targetPlr.Name)
                            return
                        end
                    end
                    warn("[NavyHub] Tidak bisa menemukan pulau atau posisi " .. targetPlr.Name)
                end
            end)
            if not ok then warn("[NavyHub] " .. tostring(err)) end
        end)
    end
end

-- Build awal
buildPlayerButtons()

-- Auto-update saat player join/leave
Players.PlayerAdded:Connect(function()
    task.wait(1)
    buildPlayerButtons()
end)
Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    buildPlayerButtons()
end)

makeButton(tpFolder, "🔄 Refresh Daftar Player", Color3.fromRGB(20, 50, 90), function()
    buildPlayerButtons()
    print("[NavyHub] Daftar player di-refresh")
end)

makeLabel(tpFolder, "  ── Lokasi Lain ──", Color3.fromRGB(80, 120, 180))

makeButton(tpFolder, "🌊 Tengah Laut (Spawn)", Color3.fromRGB(0, 40, 100), function()
    hrp.CFrame = CFrame.new(0, 10, 0)
end)

-- ============================================
-- FOLDER 4: INFO
-- ============================================
local infoFolder = makeFolder("Info & Tips", "📋")
makeLabel(infoFolder, "  ESP: auto-scan tiap 5 detik")
makeLabel(infoFolder, "  Speed Boat: tahan W saat di kapal")
makeLabel(infoFolder, "  Teleport: cari pulau by nama player")
makeLabel(infoFolder, "  Drag GUI: klik & tahan title bar")
makeLabel(infoFolder, "  Minimize: tombol — pojok kanan")

-- ============================================
-- ESP CORE FUNCTIONS
-- ============================================
local function createShipESP(part, label, color)
    pcall(function()
        local old = part:FindFirstChild("_NavyESP")
        if old then old:Destroy() end

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
                local dist = math.floor((hrp.Position - part.Position).Magnitude)
                distTxt.Text = dist .. " studs"
            end)
        end)
    end)
end

local SHIP_KEYWORDS = {
    "ship", "boat", "vessel", "destroyer", "carrier",
    "battleship", "cruiser", "submarine", "frigate",
    "warship", "navy", "speedboat", "kapal"
}

local function scanShips()
    if not STATE.espEnabled then return end
    local count = 0

    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            local nameLower = obj.Name:lower()
            local matched = false

            for _, kw in ipairs(SHIP_KEYWORDS) do
                if nameLower:find(kw) then
                    matched = true
                    break
                end
            end

            if matched then
                local part = nil
                if obj:IsA("BasePart") then
                    part = obj
                elseif obj:IsA("Model") then
                    part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                end

                if part and not part:FindFirstChild("_NavyESP") then
                    local isOwn = obj.Name:lower():find(plr.Name:lower()) ~= nil
                    local color = isOwn
                        and Color3.fromRGB(0, 255, 80)
                        or Color3.fromRGB(255, 80, 80)
                    local label = isOwn
                        and "🟢 " .. obj.Name
                        or  "🔴 " .. obj.Name

                    createShipESP(part, label, color)
                    count = count + 1
                end
            end
        end)
    end

    espCountLbl.Text = "🚢 Kapal terdeteksi: " .. count
end

-- ESP loop tiap 5 detik
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
                        local look = Vector3.new(
                            cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z
                        )
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
-- DRAG GUI
-- ============================================
titleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        STATE.dragging = true
        STATE.dragOffset = Vector2.new(
            mouse.X - mainFrame.AbsolutePosition.X,
            mouse.Y - mainFrame.AbsolutePosition.Y
        )
    end
end)

titleBar.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        STATE.dragging = false
    end
end)

RunService.RenderStepped:Connect(function()
    if STATE.dragging then
        pcall(function()
            mainFrame.Position = UDim2.new(0,
                mouse.X - STATE.dragOffset.X, 0,
                mouse.Y - STATE.dragOffset.Y)
        end)
    end
end)

-- ============================================
-- MINIMIZE
-- ============================================
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    mainFrame.Size = minimized
        and UDim2.new(0, 300, 0, 45)
        or  UDim2.new(0, 300, 0, 440)
    minBtn.Text = minimized and "▲" or "—"
end)

-- ============================================
-- RESPAWN HANDLER
-- ============================================
plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = newChar:WaitForChild("HumanoidRootPart")
    hum = newChar:WaitForChild("Humanoid")
end)

print("✅ Navy Tycoon Hub v3.0 loaded!")
print("📍 Teleport pulau: cari by nama player di workspace")
print("🚢 ESP: auto scan tiap 5 detik")
print("⚡ Speed Boat: tahan W saat naik kapal")
