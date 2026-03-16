-- ============================================
--         INFINITY HUB
--   Mirip Infinite Yield
--   Fly ikut arah kamera (geser layar)
--   Command Input | GUI Horizontal
--   Draggable | Buka/Tutup
--   Compatible: Delta, Arceus X, Fluxus
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

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
    dragging   = false,
    dragStart  = nil,
    dragFrame  = nil,
    open       = true,
}

-- Log history
local cmdHistory = {}
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
sg.Name = "InfinityHub"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder = 999
sg.Parent = plr.PlayerGui

-- ============================================
-- MAIN FRAME
-- ============================================
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 340, 0, 44)
main.Position = UDim2.new(0.5, -170, 1, -190)
main.BackgroundColor3 = Color3.fromRGB(10, 13, 22)
main.BorderSizePixel = 0
main.ClipsDescendants = false
main.AutomaticSize = Enum.AutomaticSize.Y
main.Parent = sg
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
local mStroke = Instance.new("UIStroke", main)
mStroke.Color = Color3.fromRGB(40, 80, 200)
mStroke.Thickness = 1.5

-- ============================================
-- TITLE BAR
-- ============================================
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 44)
titleBar.BackgroundColor3 = Color3.fromRGB(14, 18, 32)
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 10
titleBar.Parent = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

-- fix sudut bawah
local tbFix = Instance.new("Frame")
tbFix.Size = UDim2.new(1, 0, 0.5, 0)
tbFix.Position = UDim2.new(0, 0, 0.5, 0)
tbFix.BackgroundColor3 = Color3.fromRGB(14, 18, 32)
tbFix.BorderSizePixel = 0
tbFix.ZIndex = 10
tbFix.Parent = titleBar

local accent = Instance.new("Frame")
accent.Size = UDim2.new(1, 0, 0, 2)
accent.Position = UDim2.new(0, 0, 1, -2)
accent.BackgroundColor3 = Color3.fromRGB(50, 110, 255)
accent.BorderSizePixel = 0
accent.ZIndex = 11
accent.Parent = titleBar

-- Tab bar horizontal dalam title
local tabRow = Instance.new("Frame")
tabRow.Size = UDim2.new(1, -100, 1, -4)
tabRow.Position = UDim2.new(0, 10, 0, 2)
tabRow.BackgroundTransparency = 1
tabRow.ZIndex = 11
tabRow.Parent = titleBar

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 4)
tabLayout.Parent = tabRow

-- Toggle open/close
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 30, 0, 30)
toggleBtn.Position = UDim2.new(1, -38, 0.5, -15)
toggleBtn.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
toggleBtn.Text = "▼"
toggleBtn.TextColor3 = Color3.fromRGB(150, 180, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 12
toggleBtn.BorderSizePixel = 0
toggleBtn.AutoButtonColor = false
toggleBtn.ZIndex = 12
toggleBtn.Parent = titleBar
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 7)

-- ============================================
-- CONTENT AREA
-- ============================================
local contentWrap = Instance.new("Frame")
contentWrap.Size = UDim2.new(1, 0, 0, 0)
contentWrap.Position = UDim2.new(0, 0, 0, 44)
contentWrap.AutomaticSize = Enum.AutomaticSize.Y
contentWrap.BackgroundTransparency = 1
contentWrap.ZIndex = 5
contentWrap.Parent = main

local wrapLayout = Instance.new("UIListLayout")
wrapLayout.Padding = UDim.new(0, 0)
wrapLayout.Parent = contentWrap

-- ============================================
-- STATUS BAR (aktif fitur)
-- ============================================
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, 0, 0, 28)
statusBar.BackgroundColor3 = Color3.fromRGB(8, 11, 20)
statusBar.BorderSizePixel = 0
statusBar.ZIndex = 6
statusBar.Parent = contentWrap

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, -10, 1, 0)
statusLbl.Position = UDim2.new(0, 8, 0, 0)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "● fly:off  ● noclip:off  ● jump:off  ● god:off"
statusLbl.TextColor3 = Color3.fromRGB(100, 130, 200)
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextSize = 10
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.ZIndex = 7
statusLbl.Parent = statusBar

local function updateStatus()
    local parts = {}
    table.insert(parts, (STATE.fly and "● fly:ON" or "● fly:off"))
    table.insert(parts, (STATE.noclip and "● noclip:ON" or "● noclip:off"))
    table.insert(parts, (STATE.unlimJump and "● jump:ON" or "● jump:off"))
    table.insert(parts, (STATE.godMode and "● god:ON" or "● god:off"))
    table.insert(parts, (STATE.invisible and "● invis:ON" or "● invis:off"))
    statusLbl.Text = table.concat(parts, "  ")
end

-- ============================================
-- LOG / OUTPUT AREA
-- ============================================
local logFrame = Instance.new("Frame")
logFrame.Size = UDim2.new(1, 0, 0, 90)
logFrame.BackgroundColor3 = Color3.fromRGB(6, 9, 18)
logFrame.BorderSizePixel = 0
logFrame.ZIndex = 6
logFrame.Parent = contentWrap

local logScroll = Instance.new("ScrollingFrame")
logScroll.Size = UDim2.new(1, -6, 1, -6)
logScroll.Position = UDim2.new(0, 3, 0, 3)
logScroll.BackgroundTransparency = 1
logScroll.ScrollBarThickness = 2
logScroll.ScrollBarImageColor3 = Color3.fromRGB(50, 80, 180)
logScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
logScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
logScroll.ZIndex = 7
logScroll.Parent = logFrame

local logLayout = Instance.new("UIListLayout")
logLayout.Padding = UDim.new(0, 1)
logLayout.SortOrder = Enum.SortOrder.LayoutOrder
logLayout.Parent = logScroll

local logPad = Instance.new("UIPadding")
logPad.PaddingLeft = UDim.new(0, 4)
logPad.PaddingTop = UDim.new(0, 2)
logPad.Parent = logScroll

local logCount = 0

local function addLog(text, color)
    logCount = logCount + 1
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -8, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = "> " .. text
    lbl.TextColor3 = color or Color3.fromRGB(140, 200, 255)
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = logCount
    lbl.ZIndex = 8
    lbl.Parent = logScroll
    -- Auto scroll ke bawah
    task.wait()
    logScroll.CanvasPosition = Vector2.new(0, logScroll.AbsoluteCanvasSize.Y)
end

-- ============================================
-- FLY NAIK/TURUN BUTTONS
-- ============================================
local flyBtnFrame = Instance.new("Frame")
flyBtnFrame.Size = UDim2.new(1, 0, 0, 44)
flyBtnFrame.BackgroundColor3 = Color3.fromRGB(8, 11, 20)
flyBtnFrame.BorderSizePixel = 0
flyBtnFrame.ZIndex = 6
flyBtnFrame.Parent = contentWrap

local flyBtnLayout = Instance.new("UIListLayout")
flyBtnLayout.FillDirection = Enum.FillDirection.Horizontal
flyBtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
flyBtnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
flyBtnLayout.Padding = UDim.new(0, 6)
flyBtnLayout.Parent = flyBtnFrame

local flyInfoLbl = Instance.new("TextLabel")
flyInfoLbl.Size = UDim2.new(0, 90, 0, 34)
flyInfoLbl.BackgroundTransparency = 1
flyInfoLbl.Text = "✈️ Fly Control"
flyInfoLbl.TextColor3 = Color3.fromRGB(120, 160, 255)
flyInfoLbl.Font = Enum.Font.GothamBold
flyInfoLbl.TextSize = 11
flyInfoLbl.ZIndex = 7
flyInfoLbl.Parent = flyBtnFrame

local upBtn = Instance.new("TextButton")
upBtn.Size = UDim2.new(0, 70, 0, 32)
upBtn.BackgroundColor3 = Color3.fromRGB(0, 90, 200)
upBtn.Text = "⬆ NAIK"
upBtn.TextColor3 = Color3.new(1,1,1)
upBtn.Font = Enum.Font.GothamBold
upBtn.TextSize = 11
upBtn.BorderSizePixel = 0
upBtn.AutoButtonColor = false
upBtn.ZIndex = 8
upBtn.Parent = flyBtnFrame
Instance.new("UICorner", upBtn).CornerRadius = UDim.new(0, 7)

local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.new(0, 70, 0, 32)
downBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 160)
downBtn.Text = "⬇ TURUN"
downBtn.TextColor3 = Color3.new(1,1,1)
downBtn.Font = Enum.Font.GothamBold
downBtn.TextSize = 11
downBtn.BorderSizePixel = 0
downBtn.AutoButtonColor = false
downBtn.ZIndex = 8
downBtn.Parent = flyBtnFrame
Instance.new("UICorner", downBtn).CornerRadius = UDim.new(0, 7)

-- Hold naik/turun
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
-- COMMAND INPUT BAR
-- ============================================
local inputBar = Instance.new("Frame")
inputBar.Size = UDim2.new(1, 0, 0, 44)
inputBar.BackgroundColor3 = Color3.fromRGB(8, 11, 20)
inputBar.BorderSizePixel = 0
inputBar.ZIndex = 6
inputBar.Parent = contentWrap

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -86, 0, 30)
inputBox.Position = UDim2.new(0, 8, 0.5, -15)
inputBox.BackgroundColor3 = Color3.fromRGB(16, 22, 40)
inputBox.PlaceholderText = "Ketik command... (contoh: fly, speed 100)"
inputBox.PlaceholderColor3 = Color3.fromRGB(70, 90, 140)
inputBox.Text = ""
inputBox.TextColor3 = Color3.fromRGB(200, 220, 255)
inputBox.Font = Enum.Font.Code
inputBox.TextSize = 11
inputBox.BorderSizePixel = 0
inputBox.ClearTextOnFocus = false
inputBox.ZIndex = 8
inputBox.Parent = inputBar
Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 7)
local iStroke = Instance.new("UIStroke", inputBox)
iStroke.Color = Color3.fromRGB(40, 70, 160)
iStroke.Thickness = 1

local sendBtn = Instance.new("TextButton")
sendBtn.Size = UDim2.new(0, 66, 0, 30)
sendBtn.Position = UDim2.new(1, -74, 0.5, -15)
sendBtn.BackgroundColor3 = Color3.fromRGB(0, 90, 210)
sendBtn.Text = "▶ Run"
sendBtn.TextColor3 = Color3.new(1,1,1)
sendBtn.Font = Enum.Font.GothamBold
sendBtn.TextSize = 12
sendBtn.BorderSizePixel = 0
sendBtn.AutoButtonColor = false
sendBtn.ZIndex = 8
sendBtn.Parent = inputBar
Instance.new("UICorner", sendBtn).CornerRadius = UDim.new(0, 7)

-- ============================================
-- QUICK COMMAND BUTTONS
-- ============================================
local quickFrame = Instance.new("Frame")
quickFrame.Size = UDim2.new(1, 0, 0, 38)
quickFrame.BackgroundColor3 = Color3.fromRGB(8, 11, 20)
quickFrame.BorderSizePixel = 0
quickFrame.ZIndex = 6
quickFrame.Parent = contentWrap

local qLayout = Instance.new("UIListLayout")
qLayout.FillDirection = Enum.FillDirection.Horizontal
qLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
qLayout.VerticalAlignment = Enum.VerticalAlignment.Center
qLayout.Padding = UDim.new(0, 4)
qLayout.Parent = quickFrame

local qPad = Instance.new("UIPadding")
qPad.PaddingLeft = UDim.new(0, 6)
qPad.PaddingRight = UDim.new(0, 6)
qPad.Parent = quickFrame

local quickCmds = {
    {"fly",     "✈️"},
    {"noclip",  "👻"},
    {"jump",    "🦘"},
    {"god",     "⚡"},
    {"reset",   "🔄"},
    {"invis",   "🌫️"},
}

for _, qc in ipairs(quickCmds) do
    local cmd, icon = qc[1], qc[2]
    local qBtn = Instance.new("TextButton")
    qBtn.Size = UDim2.new(0, 46, 0, 28)
    qBtn.BackgroundColor3 = Color3.fromRGB(20, 30, 55)
    qBtn.Text = icon .. "\n" .. cmd
    qBtn.TextColor3 = Color3.fromRGB(160, 190, 255)
    qBtn.Font = Enum.Font.GothamBold
    qBtn.TextSize = 8
    qBtn.BorderSizePixel = 0
    qBtn.AutoButtonColor = false
    qBtn.ZIndex = 8
    qBtn.Parent = quickFrame
    Instance.new("UICorner", qBtn).CornerRadius = UDim.new(0, 7)

    qBtn.MouseButton1Click:Connect(function()
        inputBox.Text = cmd
        TweenService:Create(qBtn, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(0, 70, 180)
        }):Play()
        task.wait(0.15)
        TweenService:Create(qBtn, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(20, 30, 55)
        }):Play()
    end)
end

-- ============================================
-- TAB BUTTONS di title bar
-- ============================================
local function makeTabBtn(label)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 54, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(20, 30, 55)
    btn.Text = label
    btn.TextColor3 = Color3.fromRGB(140, 170, 230)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.ZIndex = 12
    btn.Parent = tabRow
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local tabHelp = makeTabBtn("❓ Help")
local tabClear = makeTabBtn("🗑 Clear")

tabClear.MouseButton1Click:Connect(function()
    for _, c in ipairs(logScroll:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end
    logCount = 0
    addLog("Log dibersihkan.", Color3.fromRGB(100, 130, 200))
end)

tabHelp.MouseButton1Click:Connect(function()
    addLog("=== DAFTAR COMMAND ===", Color3.fromRGB(255, 220, 50))
    addLog("fly / fly off", Color3.fromRGB(100, 200, 255))
    addLog("noclip / noclip off", Color3.fromRGB(100, 200, 255))
    addLog("speed [angka]  contoh: speed 50", Color3.fromRGB(100, 200, 255))
    addLog("jump / jump off", Color3.fromRGB(100, 200, 255))
    addLog("god / god off", Color3.fromRGB(100, 200, 255))
    addLog("invis / invis off", Color3.fromRGB(100, 200, 255))
    addLog("reset", Color3.fromRGB(100, 200, 255))
    addLog("tp [nama player]", Color3.fromRGB(100, 200, 255))
    addLog("bring [nama player]", Color3.fromRGB(100, 200, 255))
    addLog("flingspeed [angka]", Color3.fromRGB(100, 200, 255))
    addLog("jumppower [angka]", Color3.fromRGB(100, 200, 255))
    addLog("sit", Color3.fromRGB(100, 200, 255))
    addLog("spin", Color3.fromRGB(100, 200, 255))
    addLog("spin off", Color3.fromRGB(100, 200, 255))
    addLog("chat [pesan]", Color3.fromRGB(100, 200, 255))
    addLog("time [0-24]", Color3.fromRGB(100, 200, 255))
    addLog("freecam / freecam off", Color3.fromRGB(100, 200, 255))
    addLog("clear  (bersihkan log)", Color3.fromRGB(100, 200, 255))
end)

-- ============================================
-- COMMAND ENGINE
-- ============================================
local spinConn = nil

local function enableFly()
    if STATE.fly then return end
    STATE.fly = true
    pcall(function()
        if STATE.bv then STATE.bv:Destroy() end
        if STATE.bg then STATE.bg:Destroy() end
        hum.PlatformStand = true
        STATE.bv = Instance.new("BodyVelocity")
        STATE.bv.Velocity = Vector3.zero
        STATE.bv.MaxForce = Vector3.new(1e9,1e9,1e9)
        STATE.bv.Parent = hrp
        STATE.bg = Instance.new("BodyGyro")
        STATE.bg.MaxTorque = Vector3.new(1e9,1e9,1e9)
        STATE.bg.P = 9000
        STATE.bg.D = 100
        STATE.bg.CFrame = hrp.CFrame
        STATE.bg.Parent = hrp
    end)
    addLog("Fly ON ✈️ — geser layar untuk arahkan", Color3.fromRGB(100, 220, 255))
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
    addLog("Fly OFF", Color3.fromRGB(200, 100, 100))
end

local function runCommand(raw)
    local input = raw:lower():match("^%s*(.-)%s*$")
    if input == "" then return end

    table.insert(cmdHistory, 1, raw)
    if #cmdHistory > 20 then table.remove(cmdHistory) end
    historyIndex = 0

    -- FLY
    if input == "fly" then
        enableFly()

    elseif input == "fly off" or input == "unfly" then
        disableFly()

    -- NOCLIP
    elseif input == "noclip" then
        STATE.noclip = true
        addLog("Noclip ON 👻", Color3.fromRGB(200, 100, 255))

    elseif input == "noclip off" then
        STATE.noclip = false
        pcall(function()
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end)
        addLog("Noclip OFF", Color3.fromRGB(200, 100, 100))

    -- SPEED
    elseif input:sub(1,5) == "speed" then
        local val = tonumber(input:match("speed%s+(%d+)"))
        if val then
            STATE.speed = val
            pcall(function() hum.WalkSpeed = val end)
            addLog("Speed = " .. val, Color3.fromRGB(100, 255, 180))
        else
            addLog("Contoh: speed 50", Color3.fromRGB(255, 180, 80))
        end

    -- JUMP POWER
    elseif input:sub(1,9) == "jumppower" then
        local val = tonumber(input:match("jumppower%s+(%d+)"))
        if val then
            pcall(function() hum.JumpPower = val end)
            addLog("JumpPower = " .. val, Color3.fromRGB(100, 255, 180))
        else
            addLog("Contoh: jumppower 100", Color3.fromRGB(255, 180, 80))
        end

    -- UNLIMITED JUMP
    elseif input == "jump" then
        STATE.unlimJump = true
        addLog("Unlimited Jump ON 🦘", Color3.fromRGB(100, 255, 150))

    elseif input == "jump off" then
        STATE.unlimJump = false
        addLog("Unlimited Jump OFF", Color3.fromRGB(200, 100, 100))

    -- GOD MODE
    elseif input == "god" then
        STATE.godMode = true
        pcall(function()
            hum.MaxHealth = math.huge
            hum.Health = math.huge
        end)
        addLog("God Mode ON ⚡", Color3.fromRGB(255, 220, 50))

    elseif input == "god off" then
        STATE.godMode = false
        pcall(function()
            hum.MaxHealth = 100
            hum.Health = 100
        end)
        addLog("God Mode OFF", Color3.fromRGB(200, 100, 100))

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
        addLog("Invisible ON 🌫️", Color3.fromRGB(180, 180, 255))

    elseif input == "invis off" or input == "visible" then
        STATE.invisible = false
        pcall(function()
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Transparency = 0
                elseif p:IsA("Decal") then
                    p.Transparency = 0
                end
            end
            -- Restore HRP transparency
            local h = char:FindFirstChild("HumanoidRootPart")
            if h then h.Transparency = 1 end
        end)
        addLog("Visible ON", Color3.fromRGB(100, 255, 180))

    -- RESET
    elseif input == "reset" then
        pcall(function() hum.Health = 0 end)
        addLog("Respawn...", Color3.fromRGB(255, 150, 50))

    -- TELEPORT
    elseif input:sub(1,2) == "tp" then
        local name = input:match("tp%s+(.+)")
        if name then
            local found = nil
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name:lower():find(name:lower()) and p ~= plr then
                    found = p
                    break
                end
            end
            if found and found.Character then
                local th = found.Character:FindFirstChild("HumanoidRootPart")
                if th then
                    hrp.CFrame = th.CFrame + Vector3.new(0, 3, 0)
                    addLog("TP ke " .. found.Name, Color3.fromRGB(100, 255, 180))
                end
            else
                addLog("Player tidak ditemukan: " .. name, Color3.fromRGB(255, 100, 100))
            end
        else
            addLog("Contoh: tp namaplayer", Color3.fromRGB(255, 180, 80))
        end

    -- BRING
    elseif input:sub(1,5) == "bring" then
        local name = input:match("bring%s+(.+)")
        if name then
            local found = nil
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name:lower():find(name:lower()) and p ~= plr then
                    found = p break
                end
            end
            if found and found.Character then
                local th = found.Character:FindFirstChild("HumanoidRootPart")
                if th then
                    th.CFrame = hrp.CFrame + Vector3.new(3, 0, 0)
                    addLog("Bring " .. found.Name, Color3.fromRGB(100, 255, 180))
                end
            else
                addLog("Player tidak ditemukan: " .. name, Color3.fromRGB(255,100,100))
            end
        else
            addLog("Contoh: bring namaplayer", Color3.fromRGB(255,180,80))
        end

    -- SIT
    elseif input == "sit" then
        pcall(function() hum.Sit = true end)
        addLog("Sit 🪑", Color3.fromRGB(200,200,255))

    -- SPIN
    elseif input == "spin" then
        if spinConn then pcall(function() spinConn:Disconnect() end) end
        spinConn = RunService.Heartbeat:Connect(function()
            pcall(function()
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(10), 0)
            end)
        end)
        addLog("Spin ON 🌀", Color3.fromRGB(200,200,255))

    elseif input == "spin off" then
        if spinConn then
            pcall(function() spinConn:Disconnect() end)
            spinConn = nil
        end
        addLog("Spin OFF", Color3.fromRGB(200,100,100))

    -- CHAT
    elseif input:sub(1,4) == "chat" then
        local msg = raw:match("[Cc]hat%s+(.+)")
        if msg then
            pcall(function()
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
            end)
            addLog("Chat: " .. msg, Color3.fromRGB(200,255,200))
        else
            addLog("Contoh: chat halo semua!", Color3.fromRGB(255,180,80))
        end

    -- TIME
    elseif input:sub(1,4) == "time" then
        local val = tonumber(input:match("time%s+(%d+)"))
        if val then
            pcall(function()
                game:GetService("Lighting").TimeOfDay = val .. ":00:00"
            end)
            addLog("Time = " .. val .. ":00", Color3.fromRGB(255,220,100))
        else
            addLog("Contoh: time 12", Color3.fromRGB(255,180,80))
        end

    -- FLING SPEED
    elseif input:sub(1,10) == "flingspeed" then
        local val = tonumber(input:match("flingspeed%s+(%d+)"))
        if val then
            STATE.speed = val
            pcall(function() hum.WalkSpeed = val end)
            addLog("FlingSpeed = " .. val .. " ⚠️ awas flying!", Color3.fromRGB(255,150,50))
        else
            addLog("Contoh: flingspeed 200", Color3.fromRGB(255,180,80))
        end

    -- FREECAM
    elseif input == "freecam" then
        pcall(function()
            local cam = workspace.CurrentCamera
            cam.CameraType = Enum.CameraType.Scriptable
        end)
        addLog("Freecam ON 📷", Color3.fromRGB(200,200,255))

    elseif input == "freecam off" then
        pcall(function()
            local cam = workspace.CurrentCamera
            cam.CameraType = Enum.CameraType.Custom
        end)
        addLog("Freecam OFF", Color3.fromRGB(200,100,100))

    -- CLEAR LOG
    elseif input == "clear" then
        for _, c in ipairs(logScroll:GetChildren()) do
            if c:IsA("TextLabel") then c:Destroy() end
        end
        logCount = 0
        addLog("Log dibersihkan.", Color3.fromRGB(100,130,200))

    else
        addLog("Command tidak dikenal: " .. input, Color3.fromRGB(255, 100, 100))
        addLog("Ketik 'help' untuk daftar command", Color3.fromRGB(150,150,200))
    end

    updateStatus()
end

-- ============================================
-- SEND BUTTON & ENTER KEY
-- ============================================
sendBtn.MouseButton1Click:Connect(function()
    local txt = inputBox.Text
    if txt ~= "" then
        addLog("[CMD] " .. txt, Color3.fromRGB(200, 200, 80))
        runCommand(txt)
        inputBox.Text = ""
    end
end)

inputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local txt = inputBox.Text
        if txt ~= "" then
            addLog("[CMD] " .. txt, Color3.fromRGB(200, 200, 80))
            runCommand(txt)
            inputBox.Text = ""
        end
    end
end)

-- ============================================
-- FLY LOOP - ikut arah kamera (geser layar)
-- ============================================
RunService.Heartbeat:Connect(function()
    if not STATE.fly then return end
    if not STATE.bv or not STATE.bv.Parent then return end
    if not STATE.bg or not STATE.bg.Parent then return end
    pcall(function()
        local cam = workspace.CurrentCamera
        local cf  = cam.CFrame

        -- MoveDirection sudah world space, langsung pakai
        local md  = hum.MoveDirection
        local dir = Vector3.new(md.X, 0, md.Z)
        if dir.Magnitude > 0 then dir = dir.Unit end

        -- Naik turun tombol GUI
        if STATE.flyUp   then dir = dir + Vector3.new(0, 1, 0) end
        if STATE.flyDown then dir = dir - Vector3.new(0, 1, 0) end

        -- Naik turun keyboard PC
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            dir = dir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            dir = dir - Vector3.new(0, 1, 0)
        end

        STATE.bv.Velocity = dir * STATE.flySpeed
        -- Body gyro ikut look vector kamera
        STATE.bg.CFrame = CFrame.new(Vector3.zero, cf.LookVector)
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
-- GOD MODE LOOP
-- ============================================
RunService.Heartbeat:Connect(function()
    if not STATE.godMode then return end
    pcall(function()
        if hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
    end)
end)

-- ============================================
-- UNLIMITED JUMP
-- ============================================
local jumpConn
local function connectJump()
    if jumpConn then pcall(function() jumpConn:Disconnect() end) end
    jumpConn = hum.StateChanged:Connect(function(_, new)
        if not STATE.unlimJump then return end
        pcall(function()
            if new == Enum.HumanoidStateType.Jumping
            or new == Enum.HumanoidStateType.Freefall then
                task.wait(0.1)
                hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            end
        end)
    end)
end
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
        main.Size = UDim2.new(0, 340, 0, 44)
        toggleBtn.Text = "▲"
    end
    TweenService:Create(accent, TweenInfo.new(0.2), {
        BackgroundColor3 = STATE.open
            and Color3.fromRGB(50, 110, 255)
            or  Color3.fromRGB(60, 60, 100)
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
-- RESPAWN HANDLER
-- ============================================
plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = newChar:WaitForChild("HumanoidRootPart")
    hum = newChar:WaitForChild("Humanoid")
    STATE.fly = false
    STATE.noclip = false
    STATE.flyUp = false
    STATE.flyDown = false
    STATE.bv = nil
    STATE.bg = nil
    connectJump()
    addLog("Respawn - semua fitur direset", Color3.fromRGB(255,180,50))
    updateStatus()
end)

-- ============================================
-- WELCOME
-- ============================================
addLog("=== INFINITY HUB ===", Color3.fromRGB(255, 220, 50))
addLog("Ketik 'help' untuk semua command", Color3.fromRGB(140, 190, 255))
addLog("Fly: geser layar untuk arahkan", Color3.fromRGB(140, 190, 255))
addLog("Quick cmd: tap tombol di bawah input", Color3.fromRGB(140, 190, 255))
updateStatus()
print("✅ Infinity Hub loaded!")
