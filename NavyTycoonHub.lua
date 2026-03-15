-- ============================================
--         NOCLIP + FLY HUB
--   GUI Horizontal | Draggable | Mobile
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
    noclip    = false,
    fly       = false,
    flySpeed  = 60,
    bv        = nil,
    bg        = nil,
    dragging  = false,
    dragStart = nil,
    dragFrame = nil,
    minimized = false,
}

-- ============================================
-- HAPUS GUI LAMA
-- ============================================
pcall(function()
    local old = plr.PlayerGui:FindFirstChild("NoclipFlyHub")
    if old then old:Destroy() end
end)

-- ============================================
-- GUI ROOT
-- ============================================
local sg = Instance.new("ScreenGui")
sg.Name = "NoclipFlyHub"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder = 999
sg.Parent = plr.PlayerGui

-- MAIN FRAME - posisi bawah tengah
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 280, 0, 50)
main.Position = UDim2.new(0.5, -140, 1, -180)
main.BackgroundColor3 = Color3.fromRGB(12, 16, 28)
main.BorderSizePixel = 0
main.ClipsDescendants = false
main.Parent = sg
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Color3.fromRGB(60, 100, 220)
mainStroke.Thickness = 1.5

-- ============================================
-- TITLE BAR (drag area)
-- ============================================
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(16, 22, 38)
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 10
titleBar.Parent = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

-- Fix sudut bawah titlebar
local tbFix = Instance.new("Frame")
tbFix.Size = UDim2.new(1, 0, 0.5, 0)
tbFix.Position = UDim2.new(0, 0, 0.5, 0)
tbFix.BackgroundColor3 = Color3.fromRGB(16, 22, 38)
tbFix.BorderSizePixel = 0
tbFix.ZIndex = 10
tbFix.Parent = titleBar

-- Garis aksen
local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(1, 0, 0, 2)
accentLine.Position = UDim2.new(0, 0, 1, -2)
accentLine.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
accentLine.BorderSizePixel = 0
accentLine.ZIndex = 11
accentLine.Parent = titleBar

-- Icon + Title
local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -50, 1, 0)
titleLbl.Position = UDim2.new(0, 14, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "🚀 NOCLIP & FLY"
titleLbl.TextColor3 = Color3.fromRGB(220, 230, 255)
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextSize = 13
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 11
titleLbl.Parent = titleBar

-- Minimize / Expand button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 34, 0, 34)
minBtn.Position = UDim2.new(1, -42, 0.5, -17)
minBtn.BackgroundColor3 = Color3.fromRGB(30, 44, 70)
minBtn.Text = "▼"
minBtn.TextColor3 = Color3.fromRGB(160, 190, 255)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 13
minBtn.BorderSizePixel = 0
minBtn.AutoButtonColor = false
minBtn.ZIndex = 12
minBtn.Parent = titleBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

-- ============================================
-- CONTENT PANEL (tombol-tombol)
-- ============================================
local contentPanel = Instance.new("Frame")
contentPanel.Name = "Content"
contentPanel.Size = UDim2.new(1, 0, 0, 0)
contentPanel.Position = UDim2.new(0, 0, 0, 50)
contentPanel.AutomaticSize = Enum.AutomaticSize.Y
contentPanel.BackgroundTransparency = 1
contentPanel.ZIndex = 5
contentPanel.Parent = main

local contentLayout = Instance.new("UIListLayout")
contentLayout.FillDirection = Enum.FillDirection.Vertical
contentLayout.Padding = UDim.new(0, 6)
contentLayout.Parent = contentPanel

local contentPad = Instance.new("UIPadding")
contentPad.PaddingLeft = UDim.new(0, 10)
contentPad.PaddingRight = UDim.new(0, 10)
contentPad.PaddingTop = UDim.new(0, 8)
contentPad.PaddingBottom = UDim.new(0, 10)
contentPad.Parent = contentPanel

-- ============================================
-- HELPER: BUAT TOGGLE ROW
-- ============================================
local function makeToggleRow(icon, label, onColor, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(20, 28, 48)
    row.BorderSizePixel = 0
    row.ZIndex = 6
    row.Parent = contentPanel
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

    -- Icon
    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(0, 34, 1, 0)
    iconLbl.Position = UDim2.new(0, 8, 0, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = icon
    iconLbl.TextColor3 = Color3.fromRGB(200, 210, 255)
    iconLbl.Font = Enum.Font.GothamBold
    iconLbl.TextSize = 18
    iconLbl.ZIndex = 7
    iconLbl.Parent = row

    -- Label
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -110, 1, 0)
    nameLbl.Position = UDim2.new(0, 48, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = label
    nameLbl.TextColor3 = Color3.fromRGB(200, 215, 255)
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 13
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 7
    nameLbl.Parent = row

    -- Status label
    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size = UDim2.new(0, 50, 0, 20)
    statusLbl.Position = UDim2.new(1, -58, 0.5, -10)
    statusLbl.BackgroundColor3 = Color3.fromRGB(40, 55, 80)
    statusLbl.Text = "OFF"
    statusLbl.TextColor3 = Color3.fromRGB(160, 170, 200)
    statusLbl.Font = Enum.Font.GothamBold
    statusLbl.TextSize = 11
    statusLbl.ZIndex = 7
    statusLbl.Parent = row
    Instance.new("UICorner", statusLbl).CornerRadius = UDim.new(0, 5)

    local isOn = false
    local tw = TweenInfo.new(0.15, Enum.EasingStyle.Quad)

    local function set(val)
        isOn = val
        if isOn then
            TweenService:Create(row, tw, {BackgroundColor3 = Color3.fromRGB(20, 38, 70)}):Play()
            TweenService:Create(statusLbl, tw, {BackgroundColor3 = onColor}):Play()
            statusLbl.Text = "ON"
            statusLbl.TextColor3 = Color3.new(1, 1, 1)
        else
            TweenService:Create(row, tw, {BackgroundColor3 = Color3.fromRGB(20, 28, 48)}):Play()
            TweenService:Create(statusLbl, tw, {BackgroundColor3 = Color3.fromRGB(40, 55, 80)}):Play()
            statusLbl.Text = "OFF"
            statusLbl.TextColor3 = Color3.fromRGB(160, 170, 200)
        end
        if callback then pcall(callback, isOn) end
    end

    -- Area klik transparan di atas segalanya
    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.AutoButtonColor = false
    clickArea.ZIndex = 9
    clickArea.Parent = row
    clickArea.MouseButton1Click:Connect(function() set(not isOn) end)

    return set
end

-- ============================================
-- HELPER: SPEED ROW
-- ============================================
local function makeSpeedRow()
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(20, 28, 48)
    row.BorderSizePixel = 0
    row.ZIndex = 6
    row.Parent = contentPanel
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(0, 34, 1, 0)
    iconLbl.Position = UDim2.new(0, 8, 0, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = "🎚️"
    iconLbl.Font = Enum.Font.GothamBold
    iconLbl.TextSize = 18
    iconLbl.ZIndex = 7
    iconLbl.Parent = row

    local speedLbl = Instance.new("TextLabel")
    speedLbl.Size = UDim2.new(0, 100, 1, 0)
    speedLbl.Position = UDim2.new(0, 48, 0, 0)
    speedLbl.BackgroundTransparency = 1
    speedLbl.Text = "Speed: " .. STATE.flySpeed
    speedLbl.TextColor3 = Color3.fromRGB(200, 215, 255)
    speedLbl.Font = Enum.Font.GothamBold
    speedLbl.TextSize = 12
    speedLbl.TextXAlignment = Enum.TextXAlignment.Left
    speedLbl.ZIndex = 7
    speedLbl.Parent = row

    local minusBtn = Instance.new("TextButton")
    minusBtn.Size = UDim2.new(0, 32, 0, 28)
    minusBtn.Position = UDim2.new(1, -76, 0.5, -14)
    minusBtn.BackgroundColor3 = Color3.fromRGB(30, 44, 70)
    minusBtn.Text = "−"
    minusBtn.TextColor3 = Color3.new(1, 1, 1)
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.TextSize = 18
    minusBtn.BorderSizePixel = 0
    minusBtn.AutoButtonColor = false
    minusBtn.ZIndex = 8
    minusBtn.Parent = row
    Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 7)

    local plusBtn = Instance.new("TextButton")
    plusBtn.Size = UDim2.new(0, 32, 0, 28)
    plusBtn.Position = UDim2.new(1, -38, 0.5, -14)
    plusBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 200)
    plusBtn.Text = "+"
    plusBtn.TextColor3 = Color3.new(1, 1, 1)
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.TextSize = 18
    plusBtn.BorderSizePixel = 0
    plusBtn.AutoButtonColor = false
    plusBtn.ZIndex = 8
    plusBtn.Parent = row
    Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 7)

    minusBtn.MouseButton1Click:Connect(function()
        STATE.flySpeed = math.max(10, STATE.flySpeed - 10)
        speedLbl.Text = "Speed: " .. STATE.flySpeed
    end)
    plusBtn.MouseButton1Click:Connect(function()
        STATE.flySpeed = math.min(300, STATE.flySpeed + 10)
        speedLbl.Text = "Speed: " .. STATE.flySpeed
    end)
end

-- ============================================
-- BUAT SEMUA TOGGLE
-- ============================================

-- NOCLIP toggle
makeToggleRow("👻", "Noclip", Color3.fromRGB(180, 60, 220), function(on)
    STATE.noclip = on
    if not on then
        -- Reset collision semua part
        pcall(function()
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end)
    end
end)

-- FLY toggle
makeToggleRow("✈️", "Fly", Color3.fromRGB(0, 120, 255), function(on)
    STATE.fly = on
    if on then
        pcall(function()
            hum.PlatformStand = true

            STATE.bv = Instance.new("BodyVelocity")
            STATE.bv.Name = "_FlyBV"
            STATE.bv.Velocity = Vector3.zero
            STATE.bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            STATE.bv.Parent = hrp

            STATE.bg = Instance.new("BodyGyro")
            STATE.bg.Name = "_FlyBG"
            STATE.bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            STATE.bg.P = 9000
            STATE.bg.D = 100
            STATE.bg.CFrame = hrp.CFrame
            STATE.bg.Parent = hrp
        end)
    else
        pcall(function()
            hum.PlatformStand = false
            if STATE.bv then STATE.bv:Destroy() STATE.bv = nil end
            if STATE.bg then STATE.bg:Destroy() STATE.bg = nil end
        end)
    end
end)

-- Speed row
makeSpeedRow()

-- ============================================
-- NOCLIP LOOP
-- ============================================
RunService.Stepped:Connect(function()
    if not STATE.noclip then return end
    pcall(function()
        if not char or not char.Parent then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end)

-- ============================================
-- FLY LOOP
-- ============================================
RunService.Heartbeat:Connect(function()
    if not STATE.fly or not STATE.bv or not STATE.bg then return end
    pcall(function()
        if not hrp or not hrp.Parent then return end

        local cam = workspace.CurrentCamera
        local dir = Vector3.zero

        -- Mobile: pakai arah kamera + joystick
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            -- Gerak horizontal sesuai joystick
            dir = dir + Vector3.new(moveDir.X, 0, moveDir.Z)
        end

        -- Naik / turun: cek tombol keyboard (PC) atau tombol jump/crouch
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            dir = dir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or
           UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
            dir = dir - Vector3.new(0, 1, 0)
        end

        -- Di mobile, gunakan jump button = naik
        if hum.Jump then
            -- handled by MoveDirection
        end

        -- Kalau joystick bergerak, ikuti arah kamera
        if moveDir.Magnitude > 0 then
            local camFlat = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
            if camFlat.Magnitude > 0 then
                local forward = camFlat.Unit
                local right = cam.CFrame.RightVector
                right = Vector3.new(right.X, 0, right.Z)
                if right.Magnitude > 0 then right = right.Unit end
                dir = (forward * -moveDir.Z) + (right * moveDir.X)
                if dir.Magnitude > 0 then dir = dir.Unit end
            end
        end

        -- Tambah naik/turun dari keyboard
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            dir = dir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            dir = dir - Vector3.new(0, 1, 0)
        end

        STATE.bv.Velocity = dir * STATE.flySpeed
        STATE.bg.CFrame = CFrame.new(Vector3.zero, cam.CFrame.LookVector)
    end)
end)

-- ============================================
-- MINIMIZE / EXPAND
-- ============================================
minBtn.MouseButton1Click:Connect(function()
    STATE.minimized = not STATE.minimized
    contentPanel.Visible = not STATE.minimized
    main.Size = STATE.minimized
        and UDim2.new(0, 280, 0, 50)
        or  UDim2.new(0, 280, 0, 50) -- AutomaticSize handles height
    main.AutomaticSize = STATE.minimized
        and Enum.AutomaticSize.None
        or  Enum.AutomaticSize.Y
    minBtn.Text = STATE.minimized and "▲" or "▼"

    TweenService:Create(accentLine, TweenInfo.new(0.2), {
        BackgroundColor3 = STATE.minimized
            and Color3.fromRGB(100, 100, 120)
            or  Color3.fromRGB(60, 120, 255)
    }):Play()
end)

-- Set awal AutomaticSize
main.AutomaticSize = Enum.AutomaticSize.Y

-- ============================================
-- DRAG (touch & mouse)
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
            local delta = inp.Position - STATE.dragStart
            main.Position = UDim2.new(
                STATE.dragFrame.X.Scale,
                STATE.dragFrame.X.Offset + delta.X,
                STATE.dragFrame.Y.Scale,
                STATE.dragFrame.Y.Offset + delta.Y
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

    -- Reset state
    STATE.noclip = false
    STATE.fly = false
    STATE.bv = nil
    STATE.bg = nil
end)

print("✅ Noclip & Fly Hub loaded!")
print("👻 Noclip: toggle di GUI")
print("✈️  Fly: joystick = gerak | Space = naik | Shift = turun")
