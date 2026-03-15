-- ================================================
-- 🔒 NAVY TYCOON - VAULT TELEPORTER
-- Mobile Friendly | Delta Executor
-- Fitur: Scan & TP ke Brangkas/Vault
-- ================================================

local Players      = game:GetService("Players")
local StarterGui   = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local player       = Players.LocalPlayer

-- =====================
-- NOTIFY
-- =====================
local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title, Text = text, Duration = 3
        })
    end)
end

-- =====================
-- TELEPORT
-- =====================
local function teleportTo(pos)
    pcall(function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp and pos then
            hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
        end
    end)
end

-- =====================
-- SCAN BRANGKAS
-- =====================
local function getVaults()
    local vaults = {}
    local seen = {}
    pcall(function()
        local keywords = {
            "vault","safe","chest","treasure","storage","cash",
            "money","locker","bank","deposit","crate","box","brangkas"
        }
        for _, obj in ipairs(workspace:GetDescendants()) do
            if seen[obj] then continue end
            seen[obj] = true
            local nameLow = obj.Name:lower()
            for _, kw in ipairs(keywords) do
                if nameLow:find(kw) then
                    local pos = Vector3.new(0, 10, 0)
                    if obj:IsA("BasePart") then
                        pos = obj.Position
                    else
                        local bp = obj:FindFirstChildOfClass("BasePart")
                        if bp then pos = bp.Position end
                    end
                    local owner = tostring(
                        obj:GetAttribute("Owner") or
                        obj:GetAttribute("Player") or
                        obj:GetAttribute("Team") or "?"
                    )
                    local cd = obj:FindFirstChild("ClickDetector", true)
                    local pp = obj:FindFirstChild("ProximityPrompt", true)
                    table.insert(vaults, {
                        name  = obj.Name,
                        owner = owner,
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
-- GUI
-- =====================
local function createGUI()
    pcall(function()
        local old = game.CoreGui:FindFirstChild("VaultTP")
        if old then old:Destroy() end
    end)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VaultTP"
    ScreenGui.ResetOnSpawn = false
    pcall(function() ScreenGui.Parent = game.CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = player.PlayerGui end

    -- =====================
    -- TOMBOL BUKA/TUTUP
    -- =====================
    local OpenBtn = Instance.new("TextButton")
    OpenBtn.Size = UDim2.new(0, 65, 0, 65)
    OpenBtn.Position = UDim2.new(1, -75, 1, -185)
    OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 70, 150)
    OpenBtn.Text = "🔒\nVault"
    OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    OpenBtn.Font = Enum.Font.GothamBold
    OpenBtn.TextScaled = true
    OpenBtn.ZIndex = 10
    OpenBtn.Parent = ScreenGui
    Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 16)

    -- =====================
    -- FRAME HORIZONTAL
    -- =====================
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -20, 0, 290)
    Frame.Position = UDim2.new(0, 10, 1, -310)
    Frame.BackgroundColor3 = Color3.fromRGB(12, 22, 38)
    Frame.BorderSizePixel = 0
    Frame.Visible = false
    Frame.ZIndex = 5
    Frame.Parent = ScreenGui
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 16)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(30, 100, 200)
    stroke.Thickness = 1.5
    stroke.Parent = Frame

    -- =====================
    -- TITLE BAR (drag area)
    -- =====================
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(15, 70, 150)
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 6
    TitleBar.Parent = Frame
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 16)

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -50, 1, 0)
    TitleLbl.Position = UDim2.new(0, 12, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = "🔒 Navy Vault Teleporter"
    TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextScaled = true
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.ZIndex = 7
    TitleLbl.Parent = TitleBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 34, 0, 34)
    CloseBtn.Position = UDim2.new(1, -36, 0, 3)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextScaled = true
    CloseBtn.ZIndex = 7
    CloseBtn.Parent = TitleBar
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

    -- =====================
    -- INFO & TOMBOL SCAN
    -- =====================
    local CountLbl = Instance.new("TextLabel")
    CountLbl.Size = UDim2.new(0.6, -8, 0, 28)
    CountLbl.Position = UDim2.new(0, 8, 0, 48)
    CountLbl.BackgroundTransparency = 1
    CountLbl.Text = "🔒 Vault: Belum discan"
    CountLbl.TextColor3 = Color3.fromRGB(170, 210, 255)
    CountLbl.Font = Enum.Font.GothamBold
    CountLbl.TextSize = 13
    CountLbl.TextXAlignment = Enum.TextXAlignment.Left
    CountLbl.ZIndex = 7
    CountLbl.Parent = Frame

    local ScanBtn = Instance.new("TextButton")
    ScanBtn.Size = UDim2.new(0.4, -8, 0, 34)
    ScanBtn.Position = UDim2.new(0.6, 4, 0, 44)
    ScanBtn.BackgroundColor3 = Color3.fromRGB(15, 90, 180)
    ScanBtn.Text = "🔍 Scan Vault"
    ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScanBtn.Font = Enum.Font.GothamBold
    ScanBtn.TextScaled = true
    ScanBtn.ZIndex = 7
    ScanBtn.Parent = Frame
    Instance.new("UICorner", ScanBtn).CornerRadius = UDim.new(0, 8)

    local LogLbl = Instance.new("TextLabel")
    LogLbl.Size = UDim2.new(1, -16, 0, 20)
    LogLbl.Position = UDim2.new(0, 8, 0, 82)
    LogLbl.BackgroundTransparency = 1
    LogLbl.Text = "📝 Tap Scan Vault untuk mulai"
    LogLbl.TextColor3 = Color3.fromRGB(140, 200, 140)
    LogLbl.Font = Enum.Font.Gotham
    LogLbl.TextSize = 12
    LogLbl.TextXAlignment = Enum.TextXAlignment.Left
    LogLbl.ZIndex = 7
    LogLbl.Parent = Frame

    -- =====================
    -- SCROLL HASIL VAULT (horizontal)
    -- =====================
    local VaultScroll = Instance.new("ScrollingFrame")
    VaultScroll.Size = UDim2.new(1, -16, 0, 170)
    VaultScroll.Position = UDim2.new(0, 8, 0, 108)
    VaultScroll.BackgroundTransparency = 1
    VaultScroll.ScrollBarThickness = 4
    VaultScroll.ScrollBarImageColor3 = Color3.fromRGB(30, 100, 200)
    VaultScroll.ScrollingDirection = Enum.ScrollingDirection.X
    VaultScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    VaultScroll.ZIndex = 7
    VaultScroll.Parent = Frame

    local VLayout = Instance.new("UIListLayout")
    VLayout.FillDirection = Enum.FillDirection.Horizontal
    VLayout.Padding = UDim.new(0, 8)
    VLayout.SortOrder = Enum.SortOrder.LayoutOrder
    VLayout.Parent = VaultScroll

    -- =====================
    -- SCAN LOGIC
    -- =====================
    local function doScan()
        for _, v in ipairs(VaultScroll:GetChildren()) do
            if v:IsA("Frame") then v:Destroy() end
        end
        LogLbl.Text = "📝 Scanning..."
        CountLbl.Text = "🔒 Scanning..."
        ScanBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        ScanBtn.Text = "⏳ Scanning..."

        task.spawn(function()
            local vaults = getVaults()
            ScanBtn.BackgroundColor3 = Color3.fromRGB(15, 90, 180)
            ScanBtn.Text = "🔍 Scan Vault"

            if #vaults == 0 then
                CountLbl.Text = "🔒 Tidak ada vault"
                LogLbl.Text = "📝 Coba dekati area vault dulu"
                notify("Vault", "❌ Tidak ada vault ditemukan")
                return
            end

            CountLbl.Text = "🔒 "..#vaults.." vault ditemukan"
            LogLbl.Text = "📝 Tap kartu vault untuk teleport"
            notify("Vault", "✅ "..#vaults.." vault ditemukan!")

            for i, vault in ipairs(vaults) do
                -- Kartu vault
                local card = Instance.new("Frame")
                card.Size = UDim2.new(0, 130, 1, -8)
                card.BackgroundColor3 = Color3.fromRGB(20, 40, 75)
                card.BorderSizePixel = 0
                card.ZIndex = 8
                card.LayoutOrder = i
                card.Parent = VaultScroll
                Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

                local cardStroke = Instance.new("UIStroke")
                cardStroke.Color = Color3.fromRGB(30, 80, 160)
                cardStroke.Thickness = 1
                cardStroke.Parent = card

                -- Icon
                local icon = Instance.new("TextLabel")
                icon.Size = UDim2.new(1, 0, 0, 40)
                icon.Position = UDim2.new(0, 0, 0, 8)
                icon.BackgroundTransparency = 1
                icon.Text = "🔒"
                icon.TextColor3 = Color3.fromRGB(255, 200, 50)
                icon.Font = Enum.Font.GothamBold
                icon.TextSize = 28
                icon.ZIndex = 9
                icon.Parent = card

                -- Nama vault
                local nameLbl = Instance.new("TextLabel")
                nameLbl.Size = UDim2.new(1, -8, 0, 30)
                nameLbl.Position = UDim2.new(0, 4, 0, 50)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Text = vault.name
                nameLbl.TextColor3 = Color3.fromRGB(200, 220, 255)
                nameLbl.Font = Enum.Font.GothamBold
                nameLbl.TextSize = 12
                nameLbl.TextWrapped = true
                nameLbl.ZIndex = 9
                nameLbl.Parent = card

                -- Owner
                local ownerLbl = Instance.new("TextLabel")
                ownerLbl.Size = UDim2.new(1, -8, 0, 22)
                ownerLbl.Position = UDim2.new(0, 4, 0, 82)
                ownerLbl.BackgroundTransparency = 1
                ownerLbl.Text = "👤 "..vault.owner
                ownerLbl.TextColor3 = Color3.fromRGB(140, 170, 220)
                ownerLbl.Font = Enum.Font.Gotham
                ownerLbl.TextSize = 11
                ownerLbl.TextWrapped = true
                ownerLbl.ZIndex = 9
                ownerLbl.Parent = card

                -- Posisi
                local posLbl = Instance.new("TextLabel")
                posLbl.Size = UDim2.new(1, -8, 0, 20)
                posLbl.Position = UDim2.new(0, 4, 0, 106)
                posLbl.BackgroundTransparency = 1
                posLbl.Text = string.format("📍 %.0f, %.0f, %.0f", vault.pos.X, vault.pos.Y, vault.pos.Z)
                posLbl.TextColor3 = Color3.fromRGB(120, 150, 190)
                posLbl.Font = Enum.Font.Gotham
                posLbl.TextSize = 10
                posLbl.ZIndex = 9
                posLbl.Parent = card

                -- Tombol TP
                local tpBtn = Instance.new("TextButton")
                tpBtn.Size = UDim2.new(1, -8, 0, 30)
                tpBtn.Position = UDim2.new(0, 4, 1, -34)
                tpBtn.BackgroundColor3 = Color3.fromRGB(15, 90, 180)
                tpBtn.Text = "📍 Teleport"
                tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                tpBtn.Font = Enum.Font.GothamBold
                tpBtn.TextScaled = true
                tpBtn.ZIndex = 9
                tpBtn.Parent = card
                Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 8)

                tpBtn.MouseButton1Click:Connect(function()
                    teleportTo(vault.pos)
                    -- Coba klik vault
                    if vault.cd then pcall(function() fireclickdetector(vault.cd) end) end
                    if vault.pp then pcall(function() fireproximityprompt(vault.pp) end) end
                    LogLbl.Text = "📝 TP ke "..vault.name.." — "..os.date("%H:%M:%S")
                    notify("Vault", "🔒 TP ke "..vault.name)
                    -- Highlight kartu yang dipilih
                    cardStroke.Color = Color3.fromRGB(100, 200, 100)
                    cardStroke.Thickness = 2
                    task.delay(2, function()
                        pcall(function()
                            cardStroke.Color = Color3.fromRGB(30, 80, 160)
                            cardStroke.Thickness = 1
                        end)
                    end)
                end)
            end

            VaultScroll.CanvasSize = UDim2.new(0, VLayout.AbsoluteContentSize.X + 16, 0, 0)
        end)
    end

    VLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        VaultScroll.CanvasSize = UDim2.new(0, VLayout.AbsoluteContentSize.X + 16, 0, 0)
    end)

    ScanBtn.MouseButton1Click:Connect(doScan)

    -- =====================
    -- DRAG GUI
    -- =====================
    local dragging = false
    local dragStart, startPos

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or
           input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging then
            if input.UserInputType == Enum.UserInputType.Touch or
               input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                Frame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or
           input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- =====================
    -- OPEN / CLOSE
    -- =====================
    OpenBtn.MouseButton1Click:Connect(function()
        Frame.Visible = not Frame.Visible
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        Frame.Visible = false
    end)

    -- Auto buka
    Frame.Visible = true
end

createGUI()
notify("Vault TP", "✅ Loaded! Tap 🔒 Vault")
print("✅ Navy Vault Teleporter loaded!")
