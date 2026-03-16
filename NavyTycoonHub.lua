-- ============================================
--         INFINITY HUB v2.0
--   Mirip Infinite Yield - Versi Lengkap
--   Fly speed 500x | ESP Player & Item
--   Command Input | GUI Horizontal
--   Draggable | Buka/Tutup
--   Compatible: Delta, Arceus X, Fluxus
-- ============================================

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting     = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local plr  = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp  = char:WaitForChild("HumanoidRootPart")
local hum  = char:WaitForChild("Humanoid")

local STATE = {
    fly        = false,
    noclip     = false,
    unlimJump  = false,
    flySpeed   = 60,
    bv         = nil,
    bg         = nil,
    flyUp      = false,
    flyDown    = false,
    speed      = 16,
    godMode    = false,
    invisible  = false,
    espPlayer  = false,
    espParts   = false,
    espTeam    = false,
    dragging   = false,
    dragStart  = nil,
    dragFrame  = nil,
    open       = true,
    spinConn   = nil,
    freecam    = false,
    fullbright = false,
}

local cmdHistory   = {}
local historyIndex = 0

-- ============================================
-- HAPUS GUI LAMA
-- ============================================
pcall(function()
    local old = plr.PlayerGui:FindFirstChild("InfinityHub")
    if old then old:Destroy() end
end)

-- ============================================
-- GUI ROOT
-- ============================================
local sg = Instance.new("ScreenGui")
sg.Name            = "InfinityHub"
sg.ResetOnSpawn    = false
sg.IgnoreGuiInset  = true
sg.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder    = 999
sg.Parent          = plr.PlayerGui

-- MAIN FRAME
local main = Instance.new("Frame")
main.Name             = "Main"
main.Size             = UDim2.new(0, 360, 0, 44)
main.Position         = UDim2.new(0.5, -180, 1, -195)
main.BackgroundColor3 = Color3.fromRGB(10, 13, 22)
main.BorderSizePixel  = 0
main.ClipsDescendants = false
main.AutomaticSize    = Enum.AutomaticSize.Y
main.Parent           = sg
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
local mStroke = Instance.new("UIStroke", main)
mStroke.Color     = Color3.fromRGB(40, 80, 200)
mStroke.Thickness = 1.5

-- TITLE BAR
local titleBar = Instance.new("Frame")
titleBar.Size             = UDim2.new(1, 0, 0, 44)
titleBar.BackgroundColor3 = Color3.fromRGB(14, 18, 32)
titleBar.BorderSizePixel  = 0
titleBar.ZIndex           = 10
titleBar.Parent           = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local tbFix = Instance.new("Frame")
tbFix.Size             = UDim2.new(1, 0, 0.5, 0)
tbFix.Position         = UDim2.new(0, 0, 0.5, 0)
tbFix.BackgroundColor3 = Color3.fromRGB(14, 18, 32)
tbFix.BorderSizePixel  = 0
tbFix.ZIndex           = 10
tbFix.Parent           = titleBar

local accent = Instance.new("Frame")
accent.Size             = UDim2.new(1, 0, 0, 2)
accent.Position         = UDim2.new(0, 0, 1, -2)
accent.BackgroundColor3 = Color3.fromRGB(50, 110, 255)
accent.BorderSizePixel  = 0
accent.ZIndex           = 11
accent.Parent           = titleBar

-- Tab row di title bar
local tabRow = Instance.new("Frame")
tabRow.Size               = UDim2.new(1, -100, 1, -4)
tabRow.Position           = UDim2.new(0, 10, 0, 2)
tabRow.BackgroundTransparency = 1
tabRow.ZIndex             = 11
tabRow.Parent             = titleBar

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection       = Enum.FillDirection.Horizontal
tabLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
tabLayout.Padding             = UDim.new(0, 4)
tabLayout.Parent              = tabRow

-- Toggle buka/tutup
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size             = UDim2.new(0, 30, 0, 30)
toggleBtn.Position         = UDim2.new(1, -38, 0.5, -15)
toggleBtn.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
toggleBtn.Text             = "▼"
toggleBtn.TextColor3       = Color3.fromRGB(150, 180, 255)
toggleBtn.Font             = Enum.Font.GothamBold
toggleBtn.TextSize         = 12
toggleBtn.BorderSizePixel  = 0
toggleBtn.AutoButtonColor  = false
toggleBtn.ZIndex           = 12
toggleBtn.Parent           = titleBar
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 7)

-- ============================================
-- CONTENT WRAPPER
-- ============================================
local contentWrap = Instance.new("Frame")
contentWrap.Size              = UDim2.new(1, 0, 0, 0)
contentWrap.Position          = UDim2.new(0, 0, 0, 44)
contentWrap.AutomaticSize     = Enum.AutomaticSize.Y
contentWrap.BackgroundTransparency = 1
contentWrap.ZIndex            = 5
contentWrap.Parent            = main

local wLayout = Instance.new("UIListLayout")
wLayout.Padding = UDim.new(0, 0)
wLayout.Parent  = contentWrap

-- ============================================
-- STATUS BAR
-- ============================================
local statusBar = Instance.new("Frame")
statusBar.Size             = UDim2.new(1, 0, 0, 26)
statusBar.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
statusBar.BorderSizePixel  = 0
statusBar.ZIndex           = 6
statusBar.Parent           = contentWrap

local statusLbl = Instance.new("TextLabel")
statusLbl.Size               = UDim2.new(1, -10, 1, 0)
statusLbl.Position           = UDim2.new(0, 6, 0, 0)
statusLbl.BackgroundTransparency = 1
statusLbl.Text               = "fly:off  noclip:off  god:off  esp:off"
statusLbl.TextColor3         = Color3.fromRGB(80, 120, 200)
statusLbl.Font               = Enum.Font.Code
statusLbl.TextSize           = 10
statusLbl.TextXAlignment     = Enum.TextXAlignment.Left
statusLbl.ZIndex             = 7
statusLbl.Parent             = statusBar

local function updateStatus()
    local t = {}
    table.insert(t, STATE.fly        and "✈fly:ON"     or "fly:off")
    table.insert(t, STATE.noclip     and "👻clip:ON"   or "clip:off")
    table.insert(t, STATE.godMode    and "⚡god:ON"    or "god:off")
    table.insert(t, STATE.unlimJump  and "🦘jump:ON"   or "jump:off")
    table.insert(t, STATE.espPlayer  and "👁esp:ON"    or "esp:off")
    table.insert(t, STATE.invisible  and "🌫invis:ON"  or "")
    table.insert(t, STATE.fullbright and "☀fb:ON"      or "")
    -- filter kosong
    local f = {}
    for _, s in ipairs(t) do if s ~= "" then table.insert(f, s) end end
    statusLbl.Text = table.concat(f, "  ")
end

-- ============================================
-- LOG AREA
-- ============================================
local logFrame = Instance.new("Frame")
logFrame.Size             = UDim2.new(1, 0, 0, 88)
logFrame.BackgroundColor3 = Color3.fromRGB(6, 8, 16)
logFrame.BorderSizePixel  = 0
logFrame.ZIndex           = 6
logFrame.Parent           = contentWrap

local logScroll = Instance.new("ScrollingFrame")
logScroll.Size                 = UDim2.new(1, -6, 1, -4)
logScroll.Position             = UDim2.new(0, 3, 0, 2)
logScroll.BackgroundTransparency = 1
logScroll.ScrollBarThickness   = 2
logScroll.ScrollBarImageColor3 = Color3.fromRGB(40, 80, 180)
logScroll.CanvasSize           = UDim2.new(0, 0, 0, 0)
logScroll.AutomaticCanvasSize  = Enum.AutomaticSize.Y
logScroll.ZIndex               = 7
logScroll.Parent               = logFrame

local logInner = Instance.new("UIListLayout")
logInner.Padding   = UDim.new(0, 1)
logInner.SortOrder = Enum.SortOrder.LayoutOrder
logInner.Parent    = logScroll

local logPad = Instance.new("UIPadding")
logPad.PaddingLeft = UDim.new(0, 4)
logPad.PaddingTop  = UDim.new(0, 2)
logPad.Parent      = logScroll

local logCount = 0

local function log(text, color)
    logCount += 1
    local lbl = Instance.new("TextLabel")
    lbl.Size             = UDim2.new(1, -8, 0, 15)
    lbl.BackgroundTransparency = 1
    lbl.Text             = "> " .. text
    lbl.TextColor3       = color or Color3.fromRGB(130, 190, 255)
    lbl.Font             = Enum.Font.Code
    lbl.TextSize         = 11
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.LayoutOrder      = logCount
    lbl.ZIndex           = 8
    lbl.Parent           = logScroll
    task.wait()
    pcall(function()
        logScroll.CanvasPosition = Vector2.new(0, logScroll.AbsoluteCanvasSize.Y)
    end)
end

-- ============================================
-- FLY NAIK/TURUN BUTTONS
-- ============================================
local flyCtrl = Instance.new("Frame")
flyCtrl.Size             = UDim2.new(1, 0, 0, 42)
flyCtrl.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
flyCtrl.BorderSizePixel  = 0
flyCtrl.ZIndex           = 6
flyCtrl.Parent           = contentWrap

local fcLayout = Instance.new("UIListLayout")
fcLayout.FillDirection      = Enum.FillDirection.Horizontal
fcLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
fcLayout.VerticalAlignment  = Enum.VerticalAlignment.Center
fcLayout.Padding            = UDim.new(0, 6)
fcLayout.Parent             = flyCtrl

local flyInfoLbl = Instance.new("TextLabel")
flyInfoLbl.Size               = UDim2.new(0, 100, 0, 32)
flyInfoLbl.BackgroundTransparency = 1
flyInfoLbl.Text               = "✈️ Fly Control"
flyInfoLbl.TextColor3         = Color3.fromRGB(100, 160, 255)
flyInfoLbl.Font               = Enum.Font.GothamBold
flyInfoLbl.TextSize           = 11
flyInfoLbl.ZIndex             = 7
flyInfoLbl.Parent             = flyCtrl

-- Speed display
local flySpeedLbl = Instance.new("TextLabel")
flySpeedLbl.Size               = UDim2.new(0, 74, 0, 32)
flySpeedLbl.BackgroundTransparency = 1
flySpeedLbl.Text               = "⚡" .. STATE.flySpeed
flySpeedLbl.TextColor3         = Color3.fromRGB(200, 220, 255)
flySpeedLbl.Font               = Enum.Font.GothamBold
flySpeedLbl.TextSize           = 12
flySpeedLbl.ZIndex             = 7
flySpeedLbl.Parent             = flyCtrl

local function makeFlyBtn(label, color)
    local b = Instance.new("TextButton")
    b.Size             = UDim2.new(0, 62, 0, 30)
    b.BackgroundColor3 = color
    b.Text             = label
    b.TextColor3       = Color3.new(1,1,1)
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 11
    b.BorderSizePixel  = 0
    b.AutoButtonColor  = false
    b.ZIndex           = 8
    b.Parent           = flyCtrl
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    return b
end

local upBtn    = makeFlyBtn("⬆ NAIK",   Color3.fromRGB(0, 90, 200))
local downBtn  = makeFlyBtn("⬇ TURUN",  Color3.fromRGB(80, 30, 160))
local resetBtn = makeFlyBtn("⏹ RESET",  Color3.fromRGB(180, 30, 30))

upBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then
        STATE.flyUp = true
    end
end)
upBtn.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then
        STATE.flyUp = false
    end
end)
downBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then
        STATE.flyDown = true
    end
end)
downBtn.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then
        STATE.flyDown = false
    end
end)

-- ============================================
-- RESET ALL FUNCTION
-- Matikan semua fitur aktif sekaligus
-- ============================================
local function resetAll()
    -- Matikan Fly
    if STATE.fly then
        STATE.fly = false
        STATE.flyUp = false
        STATE.flyDown = false
        pcall(function()
            hum.PlatformStand = false
            if STATE.bv then STATE.bv:Destroy() STATE.bv = nil end
            if STATE.bg then STATE.bg:Destroy() STATE.bg = nil end
        end)
    end

    -- Matikan Noclip
    if STATE.noclip then
        STATE.noclip = false
        pcall(function()
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end)
    end

    -- Matikan God Mode
    if STATE.godMode then
        STATE.godMode = false
        pcall(function()
            hum.MaxHealth = 100
            hum.Health    = 100
        end)
    end

    -- Matikan Infinite Jump
    if STATE.unlimJump then
        STATE.unlimJump = false
    end

    -- Matikan Invisible
    if STATE.invisible then
        STATE.invisible = false
        pcall(function()
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Transparency = p.Name == "HumanoidRootPart" and 1 or 0
                elseif p:IsA("Decal") then
                    p.Transparency = 0
                end
            end
        end)
    end

    -- Matikan Spin
    if STATE.spinConn then
        pcall(function() STATE.spinConn:Disconnect() end)
        STATE.spinConn = nil
    end

    -- Reset WalkSpeed & JumpPower ke default
    pcall(function()
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end)
    STATE.speed = 16

    -- Hapus semua BodyVelocity _InfJumpBV yang mungkin tersisa
    pcall(function()
        for _, v in ipairs(hrp:GetChildren()) do
            if v.Name == "_InfJumpBV" then v:Destroy() end
        end
    end)

    log("⏹ RESET ALL — semua fitur dimatikan", Color3.fromRGB(255, 100, 100))
    updateStatus()
end

resetBtn.MouseButton1Click:Connect(function()
    -- Animasi tombol
    TweenService:Create(resetBtn, TweenInfo.new(0.08), {
        BackgroundColor3 = Color3.fromRGB(80, 10, 10)
    }):Play()
    task.wait(0.15)
    TweenService:Create(resetBtn, TweenInfo.new(0.08), {
        BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    }):Play()
    resetAll()
end)

-- ============================================
-- COMMAND INPUT BAR
-- ============================================
local inputBar = Instance.new("Frame")
inputBar.Size             = UDim2.new(1, 0, 0, 44)
inputBar.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
inputBar.BorderSizePixel  = 0
inputBar.ZIndex           = 6
inputBar.Parent           = contentWrap

local inputBox = Instance.new("TextBox")
inputBox.Size                = UDim2.new(1, -88, 0, 30)
inputBox.Position            = UDim2.new(0, 8, 0.5, -15)
inputBox.BackgroundColor3    = Color3.fromRGB(16, 22, 40)
inputBox.PlaceholderText     = "Ketik command... (help = daftar lengkap)"
inputBox.PlaceholderColor3   = Color3.fromRGB(60, 85, 140)
inputBox.Text                = ""
inputBox.TextColor3          = Color3.fromRGB(200, 220, 255)
inputBox.Font                = Enum.Font.Code
inputBox.TextSize            = 11
inputBox.BorderSizePixel     = 0
inputBox.ClearTextOnFocus    = false
inputBox.ZIndex              = 8
inputBox.Parent              = inputBar
Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 7)
local iStroke = Instance.new("UIStroke", inputBox)
iStroke.Color     = Color3.fromRGB(40, 70, 160)
iStroke.Thickness = 1

local sendBtn = Instance.new("TextButton")
sendBtn.Size             = UDim2.new(0, 68, 0, 30)
sendBtn.Position         = UDim2.new(1, -76, 0.5, -15)
sendBtn.BackgroundColor3 = Color3.fromRGB(0, 90, 210)
sendBtn.Text             = "▶ Run"
sendBtn.TextColor3       = Color3.new(1,1,1)
sendBtn.Font             = Enum.Font.GothamBold
sendBtn.TextSize         = 12
sendBtn.BorderSizePixel  = 0
sendBtn.AutoButtonColor  = false
sendBtn.ZIndex           = 8
sendBtn.Parent           = inputBar
Instance.new("UICorner", sendBtn).CornerRadius = UDim.new(0, 7)

-- ============================================
-- QUICK BUTTONS
-- ============================================
local quickFrame = Instance.new("Frame")
quickFrame.Size             = UDim2.new(1, 0, 0, 38)
quickFrame.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
quickFrame.BorderSizePixel  = 0
quickFrame.ZIndex           = 6
quickFrame.Parent           = contentWrap

local qLayout = Instance.new("UIListLayout")
qLayout.FillDirection       = Enum.FillDirection.Horizontal
qLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
qLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
qLayout.Padding             = UDim.new(0, 3)
qLayout.Parent              = quickFrame

local qPad = Instance.new("UIPadding")
qPad.PaddingLeft  = UDim.new(0, 4)
qPad.PaddingRight = UDim.new(0, 4)
qPad.Parent       = quickFrame

local quickCmds = {
    {"fly",      "✈️"}, {"noclip",   "👻"}, {"jump",  "🦘"},
    {"god",      "⚡"}, {"esp",      "👁️"}, {"invis", "🌫️"},
    {"resetall", "⏹"},  {"fb",       "☀️"},
}

for _, qc in ipairs(quickCmds) do
    local cmd, icon = qc[1], qc[2]
    local qb = Instance.new("TextButton")
    qb.Size             = UDim2.new(0, 38, 0, 28)
    qb.BackgroundColor3 = Color3.fromRGB(18, 28, 52)
    qb.Text             = icon .. "\n" .. cmd
    qb.TextColor3       = Color3.fromRGB(150, 190, 255)
    qb.Font             = Enum.Font.GothamBold
    qb.TextSize         = 7
    qb.BorderSizePixel  = 0
    qb.AutoButtonColor  = false
    qb.ZIndex           = 8
    qb.Parent           = quickFrame
    Instance.new("UICorner", qb).CornerRadius = UDim.new(0, 6)

    qb.MouseButton1Click:Connect(function()
        inputBox.Text = cmd
        TweenService:Create(qb, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(0, 70, 180)
        }):Play()
        task.wait(0.15)
        TweenService:Create(qb, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(18, 28, 52)
        }):Play()
    end)
end

-- ============================================
-- TAB BUTTONS di title bar
-- ============================================
local function makeTabBtn(label)
    local b = Instance.new("TextButton")
    b.Size             = UDim2.new(0, 58, 0, 28)
    b.BackgroundColor3 = Color3.fromRGB(20, 30, 55)
    b.Text             = label
    b.TextColor3       = Color3.fromRGB(140, 170, 230)
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 10
    b.BorderSizePixel  = 0
    b.AutoButtonColor  = false
    b.ZIndex           = 12
    b.Parent           = tabRow
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local tabHelp  = makeTabBtn("❓ Help")
local tabClear = makeTabBtn("🗑 Clear")

tabClear.MouseButton1Click:Connect(function()
    for _, c in ipairs(logScroll:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end
    logCount = 0
    log("Log dibersihkan.", Color3.fromRGB(100,130,200))
end)

tabHelp.MouseButton1Click:Connect(function()
    log("=== SEMUA COMMAND ===", Color3.fromRGB(255,220,50))
    log("── MOVEMENT ──", Color3.fromRGB(100,200,255))
    log("fly / fly off", Color3.fromRGB(180,220,255))
    log("flyspeed [10-500]   contoh: flyspeed 200", Color3.fromRGB(180,220,255))
    log("noclip / noclip off", Color3.fromRGB(180,220,255))
    log("speed [angka]       contoh: speed 50", Color3.fromRGB(180,220,255))
    log("jumppower [angka]   contoh: jumppower 150", Color3.fromRGB(180,220,255))
    log("jump / jump off  (infinite jump = pencet berkali-kali)", Color3.fromRGB(180,220,255))
    log("sit | spin / spin off", Color3.fromRGB(180,220,255))
    log("── PLAYER ──", Color3.fromRGB(100,200,255))
    log("god / god off", Color3.fromRGB(180,220,255))
    log("invis / invis off", Color3.fromRGB(180,220,255))
    log("reset  (respawn) | resetall  (matikan semua)", Color3.fromRGB(180,220,255))
    log("tp [nama]  |  bring [nama]", Color3.fromRGB(180,220,255))
    log("fling [nama]", Color3.fromRGB(180,220,255))
    log("── ESP ──", Color3.fromRGB(100,200,255))
    log("esp / esp off", Color3.fromRGB(180,220,255))
    log("espdist [angka]     contoh: espdist 500", Color3.fromRGB(180,220,255))
    log("── WORLD ──", Color3.fromRGB(100,200,255))
    log("fb / fb off  (fullbright)", Color3.fromRGB(180,220,255))
    log("time [0-24]         contoh: time 12", Color3.fromRGB(180,220,255))
    log("freecam / freecam off", Color3.fromRGB(180,220,255))
    log("chat [pesan]", Color3.fromRGB(180,220,255))
    log("clear", Color3.fromRGB(180,220,255))
end)

-- ============================================
-- ESP SYSTEM
-- ============================================
local ESP_DIST = 1000
local espConns = {}

local function removeESP()
    for _, c in ipairs(espConns) do pcall(function() c:Disconnect() end) end
    espConns = {}
    for _, p in ipairs(Players:GetPlayers()) do
        pcall(function()
            if p ~= plr and p.Character then
                for _, obj in ipairs(p.Character:GetDescendants()) do
                    local e = obj:FindFirstChild("_IH_ESP")
                    if e then e:Destroy() end
                end
            end
        end)
    end
end

local function makeESPFor(target)
    if target == plr then return end
    pcall(function()
        local tChar = target.Character
        if not tChar then return end
        local tHrp = tChar:FindFirstChild("HumanoidRootPart")
        if not tHrp then return end
        if tHrp:FindFirstChild("_IH_ESP") then return end

        -- Highlight box
        local hl = Instance.new("SelectionBox")
        hl.Name           = "_IH_ESP_BOX"
        hl.Adornee        = tChar
        hl.Color3         = Color3.fromRGB(255, 60, 60)
        hl.LineThickness  = 0.04
        hl.SurfaceTransparency = 0.85
        hl.SurfaceColor3  = Color3.fromRGB(255, 60, 60)
        hl.Parent         = sg

        -- Billboard nama + jarak
        local bb = Instance.new("BillboardGui")
        bb.Name         = "_IH_ESP"
        bb.AlwaysOnTop  = true
        bb.Size         = UDim2.new(0, 140, 0, 44)
        bb.StudsOffset  = Vector3.new(0, 3.2, 0)
        bb.MaxDistance  = ESP_DIST
        bb.Parent       = tHrp

        local bg = Instance.new("Frame", bb)
        bg.Size                 = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3     = Color3.fromRGB(0, 0, 0)
        bg.BackgroundTransparency = 0.35
        bg.BorderSizePixel      = 0
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)
        local stroke = Instance.new("UIStroke", bg)
        stroke.Color     = Color3.fromRGB(255, 60, 60)
        stroke.Thickness = 1.5

        local nameLbl = Instance.new("TextLabel", bg)
        nameLbl.Size               = UDim2.new(1, -6, 0.52, 0)
        nameLbl.Position           = UDim2.new(0, 3, 0, 2)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text               = "👤 " .. target.Name
        nameLbl.TextColor3         = Color3.new(1, 1, 1)
        nameLbl.TextScaled         = true
        nameLbl.Font               = Enum.Font.GothamBold

        local distLbl = Instance.new("TextLabel", bg)
        distLbl.Size               = UDim2.new(1, -6, 0.48, 0)
        distLbl.Position           = UDim2.new(0, 3, 0.52, 0)
        distLbl.BackgroundTransparency = 1
        distLbl.TextColor3         = Color3.fromRGB(200, 210, 255)
        distLbl.TextScaled         = true
        distLbl.Font               = Enum.Font.Gotham

        -- Update jarak
        local conn = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not tHrp or not tHrp.Parent or not hrp or not hrp.Parent then return end
                local dist = math.floor((hrp.Position - tHrp.Position).Magnitude)
                distLbl.Text = dist .. " studs"
                -- Warna merah = dekat, hijau = jauh
                local t2 = math.clamp(dist / 200, 0, 1)
                stroke.Color  = Color3.fromRGB(
                    math.floor(255*(1-t2)),
                    math.floor(255*t2),
                    60
                )
                hl.Color3 = stroke.Color
            end)
        end)
        table.insert(espConns, conn)

        -- Cleanup kalau player leave
        target.CharacterRemoving:Connect(function()
            pcall(function()
                if bb then bb:Destroy() end
                if hl then hl:Destroy() end
            end)
        end)
    end)
end

local function enableESP()
    STATE.espPlayer = true
    for _, p in ipairs(Players:GetPlayers()) do
        makeESPFor(p)
    end
    Players.PlayerAdded:Connect(function(p)
        if STATE.espPlayer then
            task.wait(2)
            makeESPFor(p)
        end
    end)
    Players.PlayerRemoving:Connect(function(p)
        pcall(function()
            if p.Character then
                for _, obj in ipairs(p.Character:GetDescendants()) do
                    local e = obj:FindFirstChild("_IH_ESP")
                    if e then e:Destroy() end
                end
            end
            for _, obj in ipairs(sg:GetDescendants()) do
                if obj.Name == "_IH_ESP_BOX" and obj:IsA("SelectionBox") then
                    if obj.Adornee and obj.Adornee.Parent == p.Character then
                        obj:Destroy()
                    end
                end
            end
        end)
    end)
end

local function disableESP()
    STATE.espPlayer = false
    removeESP()
    -- Hapus semua SelectionBox
    for _, obj in ipairs(sg:GetDescendants()) do
        pcall(function()
            if obj.Name == "_IH_ESP_BOX" then obj:Destroy() end
        end)
    end
end

-- ============================================
-- FLY FUNCTIONS
-- ============================================
local function enableFly()
    if STATE.fly then return end
    STATE.fly = true
    pcall(function()
        if STATE.bv then STATE.bv:Destroy() end
        if STATE.bg then STATE.bg:Destroy() end
        hum.PlatformStand = true
        STATE.bv = Instance.new("BodyVelocity")
        STATE.bv.Velocity   = Vector3.zero
        STATE.bv.MaxForce   = Vector3.new(1e9, 1e9, 1e9)
        STATE.bv.Parent     = hrp
        STATE.bg = Instance.new("BodyGyro")
        STATE.bg.MaxTorque  = Vector3.new(1e9, 1e9, 1e9)
        STATE.bg.P          = 9000
        STATE.bg.D          = 100
        STATE.bg.CFrame     = hrp.CFrame
        STATE.bg.Parent     = hrp
    end)
    flySpeedLbl.Text = "⚡" .. STATE.flySpeed
    log("Fly ON ✈️  speed=" .. STATE.flySpeed .. "  |  geser layar utk arah", Color3.fromRGB(100,220,255))
end

local function disableFly()
    STATE.fly = false
    pcall(function()
        hum.PlatformStand = false
        if STATE.bv then STATE.bv:Destroy() STATE.bv = nil end
        if STATE.bg then STATE.bg:Destroy() STATE.bg = nil end
        STATE.flyUp = false
        STATE.flyDown = false
    end)
    log("Fly OFF", Color3.fromRGB(200,100,100))
end

-- ============================================
-- COMMAND ENGINE
-- ============================================
local function runCommand(raw)
    local input = raw:lower():match("^%s*(.-)%s*$")
    if input == "" then return end
    table.insert(cmdHistory, 1, raw)
    if #cmdHistory > 30 then table.remove(cmdHistory) end
    historyIndex = 0

    -- FLY
    if input == "fly" then
        enableFly()

    elseif input == "fly off" or input == "unfly" then
        disableFly()

    -- FLY SPEED (10 - 500)
    elseif input:match("^flyspeed") then
        local val = tonumber(input:match("flyspeed%s+(%d+)"))
        if val then
            val = math.clamp(val, 10, 500)
            STATE.flySpeed = val
            flySpeedLbl.Text = "⚡" .. val
            log("FlySpeed = " .. val, Color3.fromRGB(100,255,180))
        else
            log("Contoh: flyspeed 200  (maks 500)", Color3.fromRGB(255,180,80))
        end

    -- NOCLIP
    elseif input == "noclip" then
        STATE.noclip = true
        log("Noclip ON 👻", Color3.fromRGB(200,100,255))

    elseif input == "noclip off" then
        STATE.noclip = false
        pcall(function()
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end)
        log("Noclip OFF", Color3.fromRGB(200,100,100))

    -- SPEED
    elseif input:match("^speed") then
        local val = tonumber(input:match("speed%s+(%d+)"))
        if val then
            STATE.speed = val
            pcall(function() hum.WalkSpeed = val end)
            log("WalkSpeed = " .. val, Color3.fromRGB(100,255,180))
        else
            log("Contoh: speed 50", Color3.fromRGB(255,180,80))
        end

    -- JUMP POWER
    elseif input:match("^jumppower") then
        local val = tonumber(input:match("jumppower%s+(%d+)"))
        if val then
            pcall(function() hum.JumpPower = val end)
            log("JumpPower = " .. val, Color3.fromRGB(100,255,180))
        else
            log("Contoh: jumppower 100", Color3.fromRGB(255,180,80))
        end

    -- INFINITE JUMP
    elseif input == "jump" then
        STATE.unlimJump = true
        log("Infinite Jump ON 🦘 — pencet lompat berkali-kali!", Color3.fromRGB(100,255,150))

    elseif input == "jump off" then
        STATE.unlimJump = false
        log("Infinite Jump OFF", Color3.fromRGB(200,100,100))

    -- GOD
    elseif input == "god" then
        STATE.godMode = true
        pcall(function()
            hum.MaxHealth = math.huge
            hum.Health    = math.huge
        end)
        log("God Mode ON ⚡", Color3.fromRGB(255,220,50))

    elseif input == "god off" then
        STATE.godMode = false
        pcall(function()
            hum.MaxHealth = 100
            hum.Health    = 100
        end)
        log("God Mode OFF", Color3.fromRGB(200,100,100))

    -- INVISIBLE
    elseif input == "invis" then
        STATE.invisible = true
        pcall(function()
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") or p:IsA("Decal") then
                    p.Transparency = 1
                end
            end
        end)
        log("Invisible ON 🌫️", Color3.fromRGB(180,180,255))

    elseif input == "invis off" or input == "visible" then
        STATE.invisible = false
        pcall(function()
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Transparency = p.Name == "HumanoidRootPart" and 1 or 0
                elseif p:IsA("Decal") then
                    p.Transparency = 0
                end
            end
        end)
        log("Visible ON", Color3.fromRGB(100,255,180))

    -- ESP PLAYER
    elseif input == "esp" then
        if not STATE.espPlayer then
            enableESP()
            log("ESP ON 👁️  — player highlight + jarak", Color3.fromRGB(100,255,200))
        else
            log("ESP sudah aktif. Ketik 'esp off' untuk mematikan", Color3.fromRGB(255,180,80))
        end

    elseif input == "esp off" then
        disableESP()
        log("ESP OFF", Color3.fromRGB(200,100,100))

    -- ESP DISTANCE
    elseif input:match("^espdist") then
        local val = tonumber(input:match("espdist%s+(%d+)"))
        if val then
            ESP_DIST = val
            log("ESP Distance = " .. val, Color3.fromRGB(100,255,180))
        else
            log("Contoh: espdist 500", Color3.fromRGB(255,180,80))
        end

    -- FULLBRIGHT
    elseif input == "fb" or input == "fullbright" then
        STATE.fullbright = true
        pcall(function()
            Lighting.Brightness       = 2
            Lighting.ClockTime        = 14
            Lighting.FogEnd           = 100000
            Lighting.GlobalShadows    = false
            Lighting.Ambient          = Color3.fromRGB(255,255,255)
            Lighting.OutdoorAmbient   = Color3.fromRGB(255,255,255)
        end)
        log("Fullbright ON ☀️", Color3.fromRGB(255,220,80))

    elseif input == "fb off" or input == "fullbright off" then
        STATE.fullbright = false
        pcall(function()
            Lighting.Brightness       = 1
            Lighting.ClockTime        = 14
            Lighting.FogEnd           = 100000
            Lighting.GlobalShadows    = true
            Lighting.Ambient          = Color3.fromRGB(70,70,70)
            Lighting.OutdoorAmbient   = Color3.fromRGB(140,140,140)
        end)
        log("Fullbright OFF", Color3.fromRGB(200,100,100))

    -- TIME
    elseif input:match("^time") then
        local val = tonumber(input:match("time%s+(%d+)"))
        if val then
            pcall(function() Lighting.ClockTime = val end)
            log("Time = " .. val .. ":00", Color3.fromRGB(255,220,100))
        else
            log("Contoh: time 12", Color3.fromRGB(255,180,80))
        end

    -- SIT
    elseif input == "sit" then
        pcall(function() hum.Sit = true end)
        log("Sit 🪑", Color3.fromRGB(200,200,255))

    -- SPIN
    elseif input == "spin" then
        if STATE.spinConn then pcall(function() STATE.spinConn:Disconnect() end) end
        STATE.spinConn = RunService.Heartbeat:Connect(function()
            pcall(function()
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(8), 0)
            end)
        end)
        log("Spin ON 🌀", Color3.fromRGB(200,200,255))

    elseif input == "spin off" then
        if STATE.spinConn then
            pcall(function() STATE.spinConn:Disconnect() end)
            STATE.spinConn = nil
        end
        log("Spin OFF", Color3.fromRGB(200,100,100))

    -- RESET ALL FITUR
    elseif input == "resetall" or input == "reset all" or input == "stopall" then
        resetAll()

    -- RESET (respawn)
    elseif input == "reset" then
        pcall(function() hum.Health = 0 end)
        log("Respawn...", Color3.fromRGB(255,150,50))

    -- TP
    elseif input:match("^tp ") then
        local name = input:match("^tp%s+(.+)")
        if name then
            local found
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name:lower():find(name, 1, true) and p ~= plr then
                    found = p break
                end
            end
            if found and found.Character then
                local th = found.Character:FindFirstChild("HumanoidRootPart")
                if th then
                    hrp.CFrame = th.CFrame + Vector3.new(0, 3, 0)
                    log("TP ke " .. found.Name .. " ✅", Color3.fromRGB(100,255,180))
                end
            else
                log("Player tidak ditemukan: " .. name, Color3.fromRGB(255,100,100))
            end
        end

    -- BRING
    elseif input:match("^bring ") then
        local name = input:match("^bring%s+(.+)")
        if name then
            local found
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name:lower():find(name, 1, true) and p ~= plr then
                    found = p break
                end
            end
            if found and found.Character then
                local th = found.Character:FindFirstChild("HumanoidRootPart")
                if th then
                    th.CFrame = hrp.CFrame + Vector3.new(3, 0, 0)
                    log("Bring " .. found.Name .. " ✅", Color3.fromRGB(100,255,180))
                end
            else
                log("Player tidak ditemukan: " .. name, Color3.fromRGB(255,100,100))
            end
        end

    -- FLING
    elseif input:match("^fling ") then
        local name = input:match("^fling%s+(.+)")
        if name then
            local found
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name:lower():find(name, 1, true) and p ~= plr then
                    found = p break
                end
            end
            if found and found.Character then
                local th = found.Character:FindFirstChild("HumanoidRootPart")
                if th then
                    pcall(function()
                        local bv2 = Instance.new("BodyVelocity")
                        bv2.Velocity  = Vector3.new(
                            math.random(-200,200),
                            math.random(100,300),
                            math.random(-200,200)
                        )
                        bv2.MaxForce  = Vector3.new(1e9,1e9,1e9)
                        bv2.Parent    = th
                        task.wait(0.1)
                        bv2:Destroy()
                    end)
                    log("Fling " .. found.Name .. " 💨", Color3.fromRGB(255,180,80))
                end
            else
                log("Player tidak ditemukan: " .. name, Color3.fromRGB(255,100,100))
            end
        end

    -- FREECAM
    elseif input == "freecam" then
        pcall(function()
            workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
        end)
        STATE.freecam = true
        log("Freecam ON 📷", Color3.fromRGB(200,200,255))

    elseif input == "freecam off" then
        pcall(function()
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        end)
        STATE.freecam = false
        log("Freecam OFF", Color3.fromRGB(200,100,100))

    -- CHAT
    elseif input:match("^chat ") then
        local msg = raw:match("[Cc]hat%s+(.+)")
        if msg then
            pcall(function()
                game:GetService("ReplicatedStorage")
                    .DefaultChatSystemChatEvents
                    .SayMessageRequest:FireServer(msg, "All")
            end)
            log("Chat: " .. msg, Color3.fromRGB(200,255,200))
        end

    -- CLEAR
    elseif input == "clear" then
        for _, c in ipairs(logScroll:GetChildren()) do
            if c:IsA("TextLabel") then c:Destroy() end
        end
        logCount = 0
        log("Log dibersihkan.", Color3.fromRGB(100,130,200))

    else
        log("Command tidak dikenal: " .. input, Color3.fromRGB(255,100,100))
        log("Ketik 'help' untuk daftar lengkap", Color3.fromRGB(150,150,200))
    end

    updateStatus()
end

-- ============================================
-- SEND & ENTER
-- ============================================
sendBtn.MouseButton1Click:Connect(function()
    local txt = inputBox.Text
    if txt ~= "" then
        log("[CMD] " .. txt, Color3.fromRGB(200,200,80))
        runCommand(txt)
        inputBox.Text = ""
    end
end)

inputBox.FocusLost:Connect(function(enter)
    if enter then
        local txt = inputBox.Text
        if txt ~= "" then
            log("[CMD] " .. txt, Color3.fromRGB(200,200,80))
            runCommand(txt)
            inputBox.Text = ""
        end
    end
end)

-- ============================================
-- FLY LOOP - MoveDirection world space
-- ============================================
RunService.Heartbeat:Connect(function()
    if not STATE.fly then return end
    if not STATE.bv or not STATE.bv.Parent then return end
    if not STATE.bg or not STATE.bg.Parent then return end
    pcall(function()
        local cf  = workspace.CurrentCamera.CFrame
        local md  = hum.MoveDirection
        -- MoveDirection sudah world space, langsung pakai
        local dir = Vector3.new(md.X, 0, md.Z)
        if dir.Magnitude > 0 then dir = dir.Unit end

        if STATE.flyUp   then dir = dir + Vector3.new(0, 1, 0) end
        if STATE.flyDown then dir = dir - Vector3.new(0, 1, 0) end

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            dir = dir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            dir = dir - Vector3.new(0, 1, 0)
        end

        STATE.bv.Velocity  = dir * STATE.flySpeed
        STATE.bg.CFrame    = CFrame.new(Vector3.zero, cf.LookVector)
    end)
end)

-- ============================================
-- NOCLIP LOOP
-- ============================================
RunService.Stepped:Connect(function()
    if not STATE.noclip then return end
    pcall(function()
        if not char or not char.Parent then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end)

-- ============================================
-- GOD LOOP
-- ============================================
RunService.Heartbeat:Connect(function()
    if not STATE.godMode then return end
    pcall(()
        if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
    end)
end)

-- ============================================
-- INFINITE JUMP
-- Cara kerja: setiap kali Humanoid masuk state
-- Jumping atau Freefall, langsung paksa lompat lagi
-- via BodyVelocity sementara → efek seperti fly
-- ============================================
local jumpConn
local function connectJump()
    if jumpConn then pcall(function() jumpConn:Disconnect() end) end
    jumpConn = hum.StateChanged:Connect(function(_, new)
        if not STATE.unlimJump then return end
        pcall(function()
            -- Saat mulai jatuh bebas (setelah lompat pertama)
            -- langsung enable ulang state jumping
            if new == Enum.HumanoidStateType.Freefall
            or new == Enum.HumanoidStateType.Jumping then
                -- Enable state jumping lagi agar bisa lompat kapanpun
                hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end)
end

-- Loop tambahan: deteksi tombol lompat (mobile jump button & keyboard)
-- Setiap kali Space/JumpRequest ditekan saat infinite jump aktif,
-- paksa naik dengan BodyVelocity sesaat
local lastJumpTime = 0
local jumpCooldown = 0.15 -- detik antar lompatan

RunService.Heartbeat:Connect(function()
    if not STATE.unlimJump then return end
    if STATE.fly then return end -- kalau fly aktif, skip
    pcall(function()
        -- Deteksi input lompat
        local jumpPressed = UserInputService:IsKeyDown(Enum.KeyCode.Space)
            or hum.Jump

        if jumpPressed then
            local now = tick()
            if now - lastJumpTime >= jumpCooldown then
                lastJumpTime = now
                -- Paksa naik dengan BodyVelocity sementara
                local bvJump = Instance.new("BodyVelocity")
                bvJump.Name     = "_InfJumpBV"
                bvJump.Velocity = Vector3.new(
                    hrp.Velocity.X,
                    hum.JumpPower > 0 and hum.JumpPower or 50,
                    hrp.Velocity.Z
                )
                bvJump.MaxForce = Vector3.new(0, 1e9, 0)
                bvJump.Parent   = hrp

                -- Hapus setelah 0.1 detik
                task.delay(0.1, function()
                    pcall(function()
                        if bvJump and bvJump.Parent then
                            bvJump:Destroy()
                        end
                    end)
                end)

                -- Reset state agar bisa lompat lagi
                hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            end
        end
    end)
end)

connectJump()

-- ============================================
-- OPEN / CLOSE
-- ============================================
toggleBtn.MouseButton1Click:Connect(function()
    STATE.open = not STATE.open
    contentWrap.Visible = STATE.open
    if STATE.open then
        main.AutomaticSize = Enum.AutomaticSize.Y
        toggleBtn.Text = "▼"
    else
        main.AutomaticSize = Enum.AutomaticSize.None
        main.Size = UDim2.new(0, 360, 0, 44)
        toggleBtn.Text = "▲"
    end
    TweenService:Create(accent, TweenInfo.new(0.2), {
        BackgroundColor3 = STATE.open
            and Color3.fromRGB(50,110,255)
            or  Color3.fromRGB(50,50,90)
    }):Play()
end)

-- ============================================
-- DRAG
-- ============================================
titleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch
    or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        STATE.dragging = true
        STATE.dragStart = inp.Position
        STATE.dragFrame = main.Position
    end
end)
titleBar.InputChanged:Connect(function(inp)
    if not STATE.dragging then return end
    if inp.UserInputType == Enum.UserInputType.Touch
    or inp.UserInputType == Enum.UserInputType.MouseMovement then
        pcall(function()
            local d = inp.Position - STATE.dragStart
            main.Position = UDim2.new(
                STATE.dragFrame.X.Scale, STATE.dragFrame.X.Offset + d.X,
                STATE.dragFrame.Y.Scale, STATE.dragFrame.Y.Offset + d.Y
            )
        end)
    end
end)
titleBar.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch
    or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        STATE.dragging = false
    end
end)

-- ============================================
-- RESPAWN
-- ============================================
plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp  = newChar:WaitForChild("HumanoidRootPart")
    hum  = newChar:WaitForChild("Humanoid")
    STATE.fly      = false
    STATE.noclip   = false
    STATE.flyUp    = false
    STATE.flyDown  = false
    STATE.bv       = nil
    STATE.bg       = nil
    lastJumpTime   = 0
    connectJump()
    if STATE.espPlayer then
        task.wait(2)
        makeESPFor(Players.LocalPlayer)
    end
    log("Respawn — fitur direset", Color3.fromRGB(255,180,50))
    updateStatus()
end)

-- ============================================
-- WELCOME
-- ============================================
log("=== INFINITY HUB v2.0 ===", Color3.fromRGB(255,220,50))
log("Ketik 'help' untuk semua command", Color3.fromRGB(140,190,255))
log("flyspeed [10-500] untuk atur kecepatan fly", Color3.fromRGB(140,190,255))
log("esp = lihat semua player + jarak real-time", Color3.fromRGB(140,190,255))
updateStatus()
print("✅ Infinity Hub v2.0 loaded!")
