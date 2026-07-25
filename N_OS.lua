-- N_OS GUI Script v3.2 - Fly (ScriptBlock), Maps (Brookhaven + Steal a Brainrot), Targeted Player Windows
-- Place inside a LocalScript in StarterGui or StarterPlayerScripts

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local workspace = workspace
local Lighting = game:GetService("Lighting")

-- ============================================
-- GLOBAL SETTINGS
-- ============================================
local GAME_DEFAULT_WALKSPEED = 16

-- Create Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "N_OS"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Colors (Dark Theme)
local Colors = {
    Background = Color3.fromRGB(25, 25, 30),
    TopBar = Color3.fromRGB(20, 20, 25),
    Accent = Color3.fromRGB(100, 60, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Button = Color3.fromRGB(35, 35, 40),
    ButtonHover = Color3.fromRGB(45, 45, 50),
    ToggleOn = Color3.fromRGB(100, 60, 255),
    ToggleOff = Color3.fromRGB(60, 60, 65),
    InputBg = Color3.fromRGB(30, 30, 35),
    PageBtn = Color3.fromRGB(40, 40, 45),
    Close = Color3.fromRGB(255, 60, 60),
    Minimize = Color3.fromRGB(255, 180, 40),
    Success = Color3.fromRGB(50, 205, 50),
    TeleportBtn = Color3.fromRGB(70, 130, 255),
    KillBtn = Color3.fromRGB(255, 80, 80),
    PlayerListBg = Color3.fromRGB(20, 20, 25),
    MapBtn = Color3.fromRGB(34, 139, 34),
    TargetAccent = Color3.fromRGB(255, 140, 0),
    GreenAccent = Color3.fromRGB(34, 139, 34),
    GoldAccent = Color3.fromRGB(255, 215, 0),
    InvisAccent = Color3.fromRGB(138, 43, 226),
}

-- ============================================
-- UTILITY: Create a feature row (reusable factory)
-- ============================================
local function CreateFeatureRow(parent, featureName, featureType, defaultValue, extraData)
    local FeatureFrame = Instance.new("Frame")
    FeatureFrame.Name = featureName
    FeatureFrame.Size = UDim2.new(1, -10, 0, 35)
    FeatureFrame.BackgroundColor3 = Colors.Button
    FeatureFrame.BorderSizePixel = 0
    FeatureFrame.ZIndex = 1
    FeatureFrame.Parent = parent

    Instance.new("UICorner", FeatureFrame).CornerRadius = UDim.new(0, 4)

    local FeatureLabel = Instance.new("TextLabel")
    FeatureLabel.Name = "Label"
    FeatureLabel.Size = UDim2.new(0, 150, 1, 0)
    FeatureLabel.Position = UDim2.new(0, 10, 0, 0)
    FeatureLabel.BackgroundTransparency = 1
    FeatureLabel.Text = featureName
    FeatureLabel.TextColor3 = Colors.Text
    FeatureLabel.Font = Enum.Font.GothamMedium
    FeatureLabel.TextSize = 14
    FeatureLabel.TextXAlignment = Enum.TextXAlignment.Left
    FeatureLabel.ZIndex = 1
    FeatureLabel.Parent = FeatureFrame

    local result = {
        Frame = FeatureFrame,
        Label = FeatureLabel,
        state = false,
        value = defaultValue,
        extra = extraData,
        type = featureType,
    }

    if featureType == "Toggle" then
        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Name = "Toggle"
        ToggleBtn.Size = UDim2.new(0, 60, 0, 25)
        ToggleBtn.Position = UDim2.new(1, -70, 0, 5)
        ToggleBtn.BackgroundColor3 = Colors.ToggleOff
        ToggleBtn.Text = "OFF"
        ToggleBtn.TextColor3 = Colors.Text
        ToggleBtn.Font = Enum.Font.GothamBold
        ToggleBtn.TextSize = 12
        ToggleBtn.BorderSizePixel = 0
        ToggleBtn.ZIndex = 1
        ToggleBtn.Parent = FeatureFrame

        Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 12)

        result.btn = ToggleBtn

        ToggleBtn.MouseButton1Click:Connect(function()
            result.state = not result.state
            ToggleBtn.BackgroundColor3 = result.state and Colors.ToggleOn or Colors.ToggleOff
            ToggleBtn.Text = result.state and "ON" or "OFF"
            if result.onToggle then
                result.onToggle(result.state, extraData)
            end
        end)

    elseif featureType == "Value" then
        local ValueInput = Instance.new("TextBox")
        ValueInput.Name = "Value"
        ValueInput.Size = UDim2.new(0, 50, 0, 25)
        ValueInput.Position = UDim2.new(1, -140, 0, 5)
        ValueInput.BackgroundColor3 = Colors.InputBg
        ValueInput.Text = tostring(defaultValue or 0)
        ValueInput.TextColor3 = Colors.Text
        ValueInput.Font = Enum.Font.GothamMedium
        ValueInput.TextSize = 13
        ValueInput.BorderSizePixel = 0
        ValueInput.ZIndex = 1
        ValueInput.Parent = FeatureFrame

        Instance.new("UICorner", ValueInput).CornerRadius = UDim.new(0, 4)

        result.valueInput = ValueInput

        local ApplyBtn = Instance.new("TextButton")
        ApplyBtn.Name = "Apply"
        ApplyBtn.Size = UDim2.new(0, 50, 0, 25)
        ApplyBtn.Position = UDim2.new(1, -70, 0, 5)
        ApplyBtn.BackgroundColor3 = Colors.Accent
        ApplyBtn.Text = "Set"
        ApplyBtn.TextColor3 = Colors.Text
        ApplyBtn.Font = Enum.Font.GothamBold
        ApplyBtn.TextSize = 12
        ApplyBtn.BorderSizePixel = 0
        ApplyBtn.ZIndex = 1
        ApplyBtn.Parent = FeatureFrame

        Instance.new("UICorner", ApplyBtn).CornerRadius = UDim.new(0, 4)

        ApplyBtn.MouseButton1Click:Connect(function()
            local val = tonumber(ValueInput.Text)
            if val and result.onApply then
                result.onApply(val, extraData)
            end
        end)

    elseif featureType == "Players" then
        local ActionBtn = Instance.new("TextButton")
        ActionBtn.Name = "ActionBtn"
        ActionBtn.Size = UDim2.new(0, 90, 0, 25)
        ActionBtn.Position = UDim2.new(1, -100, 0, 5)
        ActionBtn.BackgroundColor3 = extraData.actionColor or Colors.Accent
        ActionBtn.Text = extraData.btnText or "Players ▼"
        ActionBtn.TextColor3 = Colors.Text
        ActionBtn.Font = Enum.Font.GothamBold
        ActionBtn.TextSize = 12
        ActionBtn.BorderSizePixel = 0
        ActionBtn.ZIndex = 1
        ActionBtn.Parent = FeatureFrame

        Instance.new("UICorner", ActionBtn).CornerRadius = UDim.new(0, 4)

        result.btn = ActionBtn

        ActionBtn.MouseButton1Click:Connect(function()
            if result.onPlayersClick then
                result.onPlayersClick(ActionBtn, extraData)
            end
        end)
    end

    return result
end

-- ============================================
-- GLOBAL PLAYER DROPDOWN (reusable)
-- ============================================
local GlobalPlayerDropdown = nil

function ShowGlobalPlayerDropdown(anchorBtn, onPlayerSelected, excludePlayer)
    if GlobalPlayerDropdown then
        GlobalPlayerDropdown:Destroy()
    end

    GlobalPlayerDropdown = Instance.new("Frame")
    GlobalPlayerDropdown.Name = "GlobalPlayerDropdown"
    GlobalPlayerDropdown.Size = UDim2.new(0, 200, 0, 0)
    GlobalPlayerDropdown.Position = UDim2.new(0, 0, 0, 0)
    GlobalPlayerDropdown.BackgroundColor3 = Colors.PlayerListBg
    GlobalPlayerDropdown.BorderSizePixel = 0
    GlobalPlayerDropdown.ClipsDescendants = true
    GlobalPlayerDropdown.ZIndex = 100
    GlobalPlayerDropdown.Parent = ScreenGui

    Instance.new("UICorner", GlobalPlayerDropdown).CornerRadius = UDim.new(0, 6)

    local DropTitle = Instance.new("TextLabel")
    DropTitle.Name = "DropTitle"
    DropTitle.Size = UDim2.new(1, 0, 0, 25)
    DropTitle.BackgroundColor3 = Colors.Accent
    DropTitle.Text = "Select Player"
    DropTitle.TextColor3 = Colors.Text
    DropTitle.Font = Enum.Font.GothamBold
    DropTitle.TextSize = 13
    DropTitle.ZIndex = 101
    DropTitle.Parent = GlobalPlayerDropdown
    Instance.new("UICorner", DropTitle).CornerRadius = UDim.new(0, 6)

    local PlayerScrolling = Instance.new("ScrollingFrame")
    PlayerScrolling.Name = "PlayerScrolling"
    PlayerScrolling.Size = UDim2.new(1, -5, 1, -30)
    PlayerScrolling.Position = UDim2.new(0, 2, 0, 28)
    PlayerScrolling.BackgroundTransparency = 1
    PlayerScrolling.BorderSizePixel = 0
    PlayerScrolling.ScrollBarThickness = 2
    PlayerScrolling.ScrollBarImageColor3 = Colors.Accent
    PlayerScrolling.ZIndex = 101
    PlayerScrolling.Parent = GlobalPlayerDropdown

    local PlayerList = Instance.new("UIListLayout")
    PlayerList.Parent = PlayerScrolling
    PlayerList.Padding = UDim.new(0, 2)
    PlayerList.SortOrder = Enum.SortOrder.LayoutOrder

    local btnPos = anchorBtn.AbsolutePosition
    local btnSize = anchorBtn.AbsoluteSize
    GlobalPlayerDropdown.Position = UDim2.new(0, btnPos.X - 100, 0, btnPos.Y + btnSize.Y + 2)

    local playerCount = 0

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= excludePlayer then
            playerCount = playerCount + 1

            local PlayerBtn = Instance.new("TextButton")
            PlayerBtn.Name = plr.Name
            PlayerBtn.Size = UDim2.new(1, -4, 0, 25)
            PlayerBtn.Position = UDim2.new(0, 2, 0, (playerCount - 1) * 27)
            PlayerBtn.BackgroundColor3 = Colors.PageBtn
            PlayerBtn.Text = plr.Name
            PlayerBtn.TextColor3 = Colors.Text
            PlayerBtn.Font = Enum.Font.GothamMedium
            PlayerBtn.TextSize = 12
            PlayerBtn.BorderSizePixel = 0
            PlayerBtn.ZIndex = 102
            PlayerBtn.Parent = PlayerScrolling

            Instance.new("UICorner", PlayerBtn).CornerRadius = UDim.new(0, 3)

            PlayerBtn.MouseButton1Click:Connect(function()
                onPlayerSelected(plr)
                if GlobalPlayerDropdown then
                    GlobalPlayerDropdown:Destroy()
                    GlobalPlayerDropdown = nil
                end
            end)

            PlayerBtn.MouseEnter:Connect(function()
                PlayerBtn.BackgroundColor3 = Colors.Accent
            end)
            PlayerBtn.MouseLeave:Connect(function()
                PlayerBtn.BackgroundColor3 = Colors.PageBtn
            end)
        end
    end

    PlayerScrolling.CanvasSize = UDim2.new(0, 0, 0, playerCount * 27)
    local listHeight = math.min(playerCount * 27, 200)
    local screenSize = workspace.CurrentCamera.ViewportSize

    if btnPos.Y + btnSize.Y + 2 + listHeight + 30 > screenSize.Y then
        GlobalPlayerDropdown.Position = UDim2.new(0, btnPos.X - 100, 0, btnPos.Y - listHeight - 30)
    end

    if btnPos.X - 100 + 200 > screenSize.X then
        GlobalPlayerDropdown.Position = UDim2.new(0, screenSize.X - 210, 0, GlobalPlayerDropdown.Position.Y.Offset)
    end

    TweenService:Create(GlobalPlayerDropdown, TweenInfo.new(0.2),
        {Size = UDim2.new(0, 200, 0, listHeight + 30)}):Play()

    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if GlobalPlayerDropdown and GlobalPlayerDropdown.Parent then
                local mousePos = UserInputService:GetMouseLocation()
                local dropdownPos = GlobalPlayerDropdown.AbsolutePosition
                local dropdownSize = GlobalPlayerDropdown.AbsoluteSize

                if mousePos.X < dropdownPos.X or mousePos.X > dropdownPos.X + dropdownSize.X or
                   mousePos.Y < dropdownPos.Y or mousePos.Y > dropdownPos.Y + dropdownSize.Y then
                    GlobalPlayerDropdown:Destroy()
                    GlobalPlayerDropdown = nil
                    UserInputService.InputBegan:Disconnect(onInputBegan)
                end
            end
        end
    end

    UserInputService.InputBegan:Connect(onInputBegan)
end

-- ============================================
-- CREATE MAIN FRAME
-- ============================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 440)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -220)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
MainFrame.ZIndex = 1

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- TopBar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Colors.TopBar
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0, 150, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "N_OS v3.2"
Title.TextColor3 = Colors.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Minimize Button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "Minimize"
MinimizeBtn.Size = UDim2.new(0, 30, 0, 25)
MinimizeBtn.Position = UDim2.new(1, -65, 0, 5)
MinimizeBtn.BackgroundColor3 = Colors.Minimize
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Colors.Text
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 16
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Parent = TopBar
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 4)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "Close"
CloseBtn.Size = UDim2.new(0, 30, 0, 25)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Colors.Close
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Colors.Text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

-- Page Navigation
local NavFrame = Instance.new("Frame")
NavFrame.Name = "NavFrame"
NavFrame.Size = UDim2.new(0, 130, 1, -35)
NavFrame.Position = UDim2.new(0, 0, 0, 35)
NavFrame.BackgroundColor3 = Colors.TopBar
NavFrame.BorderSizePixel = 0
NavFrame.Parent = MainFrame
Instance.new("UICorner", NavFrame).CornerRadius = UDim.new(0, 8)

-- Pages Container
local PagesContainer = Instance.new("Frame")
PagesContainer.Name = "PagesContainer"
PagesContainer.Size = UDim2.new(1, -135, 1, -35)
PagesContainer.Position = UDim2.new(0, 130, 0, 35)
PagesContainer.BackgroundTransparency = 1
PagesContainer.Parent = MainFrame
PagesContainer.ZIndex = 1

-- ============================================
-- ============================================
--  TARGETED PLAYER WINDOW FACTORY
-- ============================================
-- ============================================
local ActiveTargetedWindows = {}

function CreateTargetedPlayerWindow(targetPlayer)
    if ActiveTargetedWindows[targetPlayer.Name] then
        local existing = ActiveTargetedWindows[targetPlayer.Name]
        existing.Window.ZIndex = 99
        return
    end

    local targetName = targetPlayer.Name

    local targetGui = Instance.new("ScreenGui")
    targetGui.Name = "N_OS_Target_" .. targetName
    targetGui.Parent = Player:WaitForChild("PlayerGui")
    targetGui.ResetOnSpawn = false
    targetGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local TargetWindow = Instance.new("Frame")
    TargetWindow.Name = "TargetWindow"
    TargetWindow.Size = UDim2.new(0, 520, 0, 440)
    TargetWindow.Position = UDim2.new(0.5, -260 + math.random(-60, 60), 0.5, -220 + math.random(-60, 60))
    TargetWindow.BackgroundColor3 = Colors.Background
    TargetWindow.BorderSizePixel = 0
    TargetWindow.Active = true
    TargetWindow.Draggable = true
    TargetWindow.ZIndex = 50
    TargetWindow.Parent = targetGui
    Instance.new("UICorner", TargetWindow).CornerRadius = UDim.new(0, 8)

    local TTopBar = Instance.new("Frame")
    TTopBar.Size = UDim2.new(1, 0, 0, 35)
    TTopBar.BackgroundColor3 = Colors.TargetAccent
    TTopBar.BorderSizePixel = 0
    TTopBar.Parent = TargetWindow
    Instance.new("UICorner", TTopBar).CornerRadius = UDim.new(0, 8)

    local TTitle = Instance.new("TextLabel")
    TTitle.Size = UDim2.new(1, -75, 1, 0)
    TTitle.Position = UDim2.new(0, 15, 0, 0)
    TTitle.BackgroundTransparency = 1
    TTitle.Text = "N_OS --- " .. targetName
    TTitle.TextColor3 = Colors.Text
    TTitle.Font = Enum.Font.GothamBold
    TTitle.TextSize = 15
    TTitle.TextXAlignment = Enum.TextXAlignment.Left
    TTitle.Parent = TTopBar

    local TCloseBtn = Instance.new("TextButton")
    TCloseBtn.Size = UDim2.new(0, 30, 0, 25)
    TCloseBtn.Position = UDim2.new(1, -35, 0, 5)
    TCloseBtn.BackgroundColor3 = Colors.Close
    TCloseBtn.Text = "X"
    TCloseBtn.TextColor3 = Colors.Text
    TCloseBtn.Font = Enum.Font.GothamBold
    TCloseBtn.TextSize = 16
    TCloseBtn.BorderSizePixel = 0
    TCloseBtn.Parent = TTopBar
    Instance.new("UICorner", TCloseBtn).CornerRadius = UDim.new(0, 4)

    local TMinBtn = Instance.new("TextButton")
    TMinBtn.Size = UDim2.new(0, 30, 0, 25)
    TMinBtn.Position = UDim2.new(1, -70, 0, 5)
    TMinBtn.BackgroundColor3 = Colors.Minimize
    TMinBtn.Text = "-"
    TMinBtn.TextColor3 = Colors.Text
    TMinBtn.Font = Enum.Font.GothamBold
    TMinBtn.TextSize = 16
    TMinBtn.BorderSizePixel = 0
    TMinBtn.Parent = TTopBar
    Instance.new("UICorner", TMinBtn).CornerRadius = UDim.new(0, 4)

    local TNavFrame = Instance.new("Frame")
    TNavFrame.Size = UDim2.new(0, 130, 1, -35)
    TNavFrame.Position = UDim2.new(0, 0, 0, 35)
    TNavFrame.BackgroundColor3 = Colors.TopBar
    TNavFrame.BorderSizePixel = 0
    TNavFrame.Parent = TargetWindow
    Instance.new("UICorner", TNavFrame).CornerRadius = UDim.new(0, 8)

    local TPagesContainer = Instance.new("Frame")
    TPagesContainer.Size = UDim2.new(1, -135, 1, -35)
    TPagesContainer.Position = UDim2.new(0, 130, 0, 35)
    TPagesContainer.BackgroundTransparency = 1
    TPagesContainer.Parent = TargetWindow
    TPagesContainer.ZIndex = 1

    -- ============================================
    -- TARGET PAGE 1: FEATURES
    -- ============================================
    local TPage1 = Instance.new("Frame")
    TPage1.Size = UDim2.new(1, -20, 1, -20)
    TPage1.Position = UDim2.new(0, 10, 0, 10)
    TPage1.BackgroundTransparency = 1
    TPage1.Visible = true
    TPage1.Parent = TPagesContainer

    local TFeatureScroll = Instance.new("ScrollingFrame")
    TFeatureScroll.Size = UDim2.new(1, 0, 1, 0)
    TFeatureScroll.BackgroundTransparency = 1
    TFeatureScroll.BorderSizePixel = 0
    TFeatureScroll.ScrollBarThickness = 3
    TFeatureScroll.ScrollBarImageColor3 = Colors.TargetAccent
    TFeatureScroll.CanvasSize = UDim2.new(0, 0, 0, 750)
    TFeatureScroll.Parent = TPage1

    local TFeatureList = Instance.new("UIListLayout")
    TFeatureList.Parent = TFeatureScroll
    TFeatureList.Padding = UDim.new(0, 5)
    TFeatureList.SortOrder = Enum.SortOrder.LayoutOrder

    -- Target state
    local tState = {
        flyEnabled = false,
        noclipEnabled = false,
        bv = nil,
        bg = nil,
        noclipRunning = false,
        flySpeed = 50,
        infiniteJumpConn = nil,
        godModeConn = nil,
        invisibleConn = nil,
    }

    -- Helpers
    local function getTargetChar()
        return targetPlayer.Character
    end

    local function getTargetRoot()
        local char = getTargetChar()
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    local function getTargetHumanoid()
        local char = getTargetChar()
        return char and char:FindFirstChildOfClass("Humanoid")
    end

    -- Target Fly
    local function cleanupTargetFly()
        if tState.bv and tState.bv.Parent then pcall(function() tState.bv:Destroy() end) end
        if tState.bg and tState.bg.Parent then pcall(function() tState.bg:Destroy() end) end
        tState.bv, tState.bg = nil, nil
        local hum = getTargetHumanoid()
        if hum then
            pcall(function() hum.PlatformStand = false end)
            pcall(function() hum.WalkSpeed = GAME_DEFAULT_WALKSPEED end)
        end
    end

    local function enableTargetFly(enable)
        local hrp = getTargetRoot()
        local hum = getTargetHumanoid()
        if not hrp or not hum then return end
        if not enable then cleanupTargetFly(); return end
        cleanupTargetFly()
        tState.bv = Instance.new("BodyVelocity")
        tState.bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        tState.bv.Velocity = Vector3.new(0, 0, 0)
        tState.bv.P = 9e4
        tState.bv.Parent = hrp
        tState.bg = Instance.new("BodyGyro")
        tState.bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        tState.bg.P = 9e4
        tState.bg.CFrame = hrp.CFrame
        tState.bg.Parent = hrp
        pcall(function() hum.PlatformStand = true end)
    end

    local targetFlyHeartbeat
    targetFlyHeartbeat = RunService.Heartbeat:Connect(function(dt)
        if not tState.flyEnabled then
            if tState.bv or tState.bg then cleanupTargetFly() end
            return
        end
        local hrp = getTargetRoot()
        local hum = getTargetHumanoid()
        if not hrp or not hum then return end
        if not tState.bv or not tState.bv.Parent then enableTargetFly(true) end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local camC = cam.CFrame
        local camLook = camC.LookVector
        local camRight = camC.RightVector
        local move = hum.MoveDirection or Vector3.new(0, 0, 0)
        local horizForward = Vector3.new(camLook.X, 0, camLook.Z)
        local horizRight = Vector3.new(camRight.X, 0, camRight.Z)
        if horizForward.Magnitude < 1e-6 then horizForward = Vector3.new(0, 0, 1) end
        if horizRight.Magnitude < 1e-6 then horizRight = Vector3.new(1, 0, 0) end
        horizForward = horizForward.Unit
        horizRight = horizRight.Unit
        local forwardInput = Vector3.new(move.X, 0, move.Z):Dot(horizForward)
        local rightInput = Vector3.new(move.X, 0, move.Z):Dot(horizRight)
        local dir = (camLook * forwardInput) + (camRight * rightInput)
        if dir.Magnitude < 1e-4 then
            if tState.bv and tState.bv.Parent then
                tState.bv.Velocity = tState.bv.Velocity:Lerp(Vector3.new(0, 0, 0), math.clamp(30 * dt, 0, 1))
            end
        else
            local dirUnit = dir.Unit
            local targetVel = dirUnit * tState.flySpeed
            if tState.bv and tState.bv.Parent then
                tState.bv.Velocity = tState.bv.Velocity:Lerp(targetVel, math.clamp(30 * dt, 0, 1))
            end
            if tState.bg and tState.bg.Parent then
                local yawLook = Vector3.new(camLook.X, 0, camLook.Z)
                if yawLook.Magnitude < 1e-6 then yawLook = Vector3.new(0, 0, 1) end
                tState.bg.CFrame = CFrame.new(hrp.Position, hrp.Position + yawLook)
            end
        end
    end)

    -- Target Noclip
    local function applyTargetNoclip()
        local char = getTargetChar()
        if not char then return end
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then pcall(function() v.CanCollide = false end) end
        end
    end

    local function startTargetNoclipLoop()
        if tState.noclipRunning then return end
        tState.noclipRunning = true
        spawn(function()
            while tState.noclipRunning and tState.noclipEnabled do
                applyTargetNoclip()
                task.wait(0.3)
            end
            tState.noclipRunning = false
        end)
    end

    local function stopTargetNoclip()
        tState.noclipRunning = false
        local char = getTargetChar()
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then pcall(function() v.CanCollide = true end) end
            end
        end
    end

    -- Target Invisible
    local function applyTargetInvisible()
        local char = getTargetChar()
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0.85
            end
        end
    end

    local function removeTargetInvisible()
        local char = getTargetChar()
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency > 0.5 then
                part.Transparency = 0
            end
        end
    end

    -- Build target features
    local targetFeatures = {}

    targetFeatures.Fly = CreateFeatureRow(TFeatureScroll, "Fly", "Toggle")
    targetFeatures.Fly.onToggle = function(state)
        tState.flyEnabled = state
        if state then enableTargetFly(true) else cleanupTargetFly() end
    end

    targetFeatures["No-Clip"] = CreateFeatureRow(TFeatureScroll, "No-Clip", "Toggle")
    targetFeatures["No-Clip"].onToggle = function(state)
        tState.noclipEnabled = state
        if state then startTargetNoclipLoop() else stopTargetNoclip() end
    end

    targetFeatures["Invisible"] = CreateFeatureRow(TFeatureScroll, "Invisible", "Toggle")
    targetFeatures["Invisible"].onToggle = function(state)
        if state then
            applyTargetInvisible()
            tState.invisibleConn = RunService.Heartbeat:Connect(function()
                applyTargetInvisible()
            end)
        else
            if tState.invisibleConn then
                tState.invisibleConn:Disconnect()
                tState.invisibleConn = nil
            end
            removeTargetInvisible()
        end
    end

    targetFeatures.WalkSpeed = CreateFeatureRow(TFeatureScroll, "WalkSpeed", "Value", 16)
    targetFeatures.WalkSpeed.onApply = function(val)
        local hum = getTargetHumanoid()
        if hum then hum.WalkSpeed = val end
    end

    targetFeatures.JumpPower = CreateFeatureRow(TFeatureScroll, "JumpPower", "Value", 50)
    targetFeatures.JumpPower.onApply = function(val)
        local hum = getTargetHumanoid()
        if hum then hum.JumpPower = val end
    end

    targetFeatures["Infinite Jump"] = CreateFeatureRow(TFeatureScroll, "Infinite Jump", "Toggle")
    targetFeatures["Infinite Jump"].onToggle = function(state)
        if state then
            tState.infiniteJumpConn = UserInputService.JumpRequest:Connect(function()
                local hum = getTargetHumanoid()
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        else
            if tState.infiniteJumpConn then
                tState.infiniteJumpConn:Disconnect()
                tState.infiniteJumpConn = nil
            end
        end
    end

    targetFeatures["God Mode"] = CreateFeatureRow(TFeatureScroll, "God Mode", "Toggle")
    targetFeatures["God Mode"].onToggle = function(state)
        if state then
            tState.godModeConn = RunService.Stepped:Connect(function()
                local hum = getTargetHumanoid()
                if hum then hum.Health = hum.MaxHealth end
            end)
        else
            if tState.godModeConn then
                tState.godModeConn:Disconnect()
                tState.godModeConn = nil
            end
        end
    end

    targetFeatures["Teleport to Me"] = CreateFeatureRow(TFeatureScroll, "Teleport to Me", "Toggle")
    targetFeatures["Teleport to Me"].btn.Text = "TP ▶"
    targetFeatures["Teleport to Me"].btn.BackgroundColor3 = Colors.TeleportBtn
    targetFeatures["Teleport to Me"].btn.MouseButton1Click:Connect(function()
        local targetRoot = getTargetRoot()
        local myRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and myRoot then
            targetRoot.CFrame = myRoot.CFrame + Vector3.new(0, 3, 0)
        end
    end)

    targetFeatures["Kill Player"] = CreateFeatureRow(TFeatureScroll, "Kill Player", "Toggle")
    targetFeatures["Kill Player"].btn.Text = "KILL"
    targetFeatures["Kill Player"].btn.BackgroundColor3 = Colors.KillBtn
    targetFeatures["Kill Player"].btn.MouseButton1Click:Connect(function()
        local char = getTargetChar()
        if not char then return end

        local root = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")

        if root then
            root.CFrame = CFrame.new(root.Position.X, -2000, root.Position.Z)
            root.Velocity = Vector3.new(0, -500, 0)
        end
        if head then
            head.CFrame = CFrame.new(head.Position.X, -2000, head.Position.Z)
        end
        if torso then
            torso.CFrame = CFrame.new(torso.Position.X, -2000, torso.Position.Z)
        end

        task.wait(0.1)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end

        task.wait(0.05)
        local head2 = char:FindFirstChild("Head")
        if head2 then pcall(function() head2:Destroy() end) end

        task.wait(0.05)
        if root and root.Parent then
            root.CFrame = CFrame.new(0, -5000, 0)
        end
    end)

    targetFeatures["ESP"] = CreateFeatureRow(TFeatureScroll, "ESP", "Toggle")
    targetFeatures["ESP"].onToggle = function(state)
        local char = getTargetChar()
        if char then
            local hl = char:FindFirstChild("ESP_TargetHighlight")
            if state and not hl then
                hl = Instance.new("Highlight")
                hl.Name = "ESP_TargetHighlight"
                hl.Adornee = char
                hl.FillColor = Color3.fromRGB(255, 165, 0)
                hl.OutlineColor = Color3.fromRGB(255, 165, 0)
                hl.FillTransparency = 0.5
                hl.Parent = char
            elseif not state and hl then
                hl:Destroy()
            end
        end
    end

    -- ============================================
    -- TARGET PAGE 2: EXECUTOR
    -- ============================================
    local TPage2 = Instance.new("Frame")
    TPage2.Size = UDim2.new(1, -20, 1, -20)
    TPage2.Position = UDim2.new(0, 10, 0, 10)
    TPage2.BackgroundTransparency = 1
    TPage2.Visible = false
    TPage2.Parent = TPagesContainer

    local TExecTitle = Instance.new("TextLabel")
    TExecTitle.Size = UDim2.new(1, 0, 0, 30)
    TExecTitle.BackgroundTransparency = 1
    TExecTitle.Text = "Executor → " .. targetName
    TExecTitle.TextColor3 = Colors.TargetAccent
    TExecTitle.Font = Enum.Font.GothamBold
    TExecTitle.TextSize = 14
    TExecTitle.TextXAlignment = Enum.TextXAlignment.Left
    TExecTitle.Parent = TPage2

    local TCodeInput = Instance.new("TextBox")
    TCodeInput.Size = UDim2.new(1, 0, 0, 240)
    TCodeInput.Position = UDim2.new(0, 0, 0, 35)
    TCodeInput.BackgroundColor3 = Colors.InputBg
    TCodeInput.Text = ""
    TCodeInput.TextColor3 = Colors.Text
    TCodeInput.Font = Enum.Font.Code
    TCodeInput.TextSize = 13
    TCodeInput.PlaceholderText = "-- Runs ON " .. targetName .. "\n-- Use: targetPlayer.Character.Humanoid etc."
    TCodeInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    TCodeInput.MultiLine = true
    TCodeInput.ClearTextOnFocus = false
    TCodeInput.TextXAlignment = Enum.TextXAlignment.Left
    TCodeInput.TextYAlignment = Enum.TextYAlignment.Top
    TCodeInput.BorderSizePixel = 0
    TCodeInput.Parent = TPage2
    Instance.new("UICorner", TCodeInput).CornerRadius = UDim.new(0, 4)

    local TExecBtn = Instance.new("TextButton")
    TExecBtn.Size = UDim2.new(0, 150, 0, 35)
    TExecBtn.Position = UDim2.new(0, 0, 0, 285)
    TExecBtn.BackgroundColor3 = Colors.TargetAccent
    TExecBtn.Text = "Execute on " .. targetName
    TExecBtn.TextColor3 = Colors.Text
    TExecBtn.Font = Enum.Font.GothamBold
    TExecBtn.TextSize = 11
    TExecBtn.BorderSizePixel = 0
    TExecBtn.Parent = TPage2
    Instance.new("UICorner", TExecBtn).CornerRadius = UDim.new(0, 4)

    local TClearBtn = Instance.new("TextButton")
    TClearBtn.Size = UDim2.new(0, 120, 0, 35)
    TClearBtn.Position = UDim2.new(0, 160, 0, 285)
    TClearBtn.BackgroundColor3 = Colors.Close
    TClearBtn.Text = "Clear"
    TClearBtn.TextColor3 = Colors.Text
    TClearBtn.Font = Enum.Font.GothamBold
    TClearBtn.TextSize = 14
    TClearBtn.BorderSizePixel = 0
    TClearBtn.Parent = TPage2
    Instance.new("UICorner", TClearBtn).CornerRadius = UDim.new(0, 4)

    local TStatusLabel = Instance.new("TextLabel")
    TStatusLabel.Size = UDim2.new(1, 0, 0, 20)
    TStatusLabel.Position = UDim2.new(0, 0, 0, 330)
    TStatusLabel.BackgroundTransparency = 1
    TStatusLabel.Text = ""
    TStatusLabel.TextColor3 = Colors.Success
    TStatusLabel.Font = Enum.Font.GothamMedium
    TStatusLabel.TextSize = 12
    TStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    TStatusLabel.Parent = TPage2

    TExecBtn.MouseButton1Click:Connect(function()
        local code = TCodeInput.Text
        if code ~= "" then
            local wrappedCode = "local targetPlayer = ...\n" .. code
            local success, err = pcall(function()
                local func = loadstring(wrappedCode)
                if func then func(targetPlayer) end
            end)
            if success then
                TStatusLabel.Text = "✓ Executed on " .. targetName
                TStatusLabel.TextColor3 = Colors.Success
            else
                TStatusLabel.Text = "✗ Error: " .. tostring(err)
                TStatusLabel.TextColor3 = Colors.Close
            end
        else
            TStatusLabel.Text = "✗ No code!"
            TStatusLabel.TextColor3 = Colors.Close
        end
    end)

    TClearBtn.MouseButton1Click:Connect(function()
        TCodeInput.Text = ""
        TStatusLabel.Text = ""
    end)

    -- ============================================
    -- TARGET PAGE 3: LINK
    -- ============================================
    local TPage3 = Instance.new("Frame")
    TPage3.Size = UDim2.new(1, -20, 1, -20)
    TPage3.Position = UDim2.new(0, 10, 0, 10)
    TPage3.BackgroundTransparency = 1
    TPage3.Visible = false
    TPage3.Parent = TPagesContainer

    local TLinkTitle = Instance.new("TextLabel")
    TLinkTitle.Size = UDim2.new(1, 0, 0, 30)
    TLinkTitle.BackgroundTransparency = 1
    TLinkTitle.Text = "N_OS Official Website"
    TLinkTitle.TextColor3 = Colors.Text
    TLinkTitle.Font = Enum.Font.GothamBold
    TLinkTitle.TextSize = 16
    TLinkTitle.TextXAlignment = Enum.TextXAlignment.Center
    TLinkTitle.Parent = TPage3

    local TLinkFrame = Instance.new("Frame")
    TLinkFrame.Size = UDim2.new(1, -20, 0, 50)
    TLinkFrame.Position = UDim2.new(0, 10, 0, 50)
    TLinkFrame.BackgroundColor3 = Colors.Button
    TLinkFrame.BorderSizePixel = 0
    TLinkFrame.Parent = TPage3
    Instance.new("UICorner", TLinkFrame).CornerRadius = UDim.new(0, 6)

    local TLinkText = Instance.new("TextLabel")
    TLinkText.Size = UDim2.new(1, -20, 1, 0)
    TLinkText.Position = UDim2.new(0, 10, 0, 0)
    TLinkText.BackgroundTransparency = 1
    TLinkText.Text = "https://n-os-official.netlify.app/"
    TLinkText.TextColor3 = Colors.Accent
    TLinkText.Font = Enum.Font.GothamMedium
    TLinkText.TextSize = 14
    TLinkText.TextXAlignment = Enum.TextXAlignment.Center
    TLinkText.Parent = TLinkFrame

    local TCopyBtn = Instance.new("TextButton")
    TCopyBtn.Size = UDim2.new(0, 150, 0, 35)
    TCopyBtn.Position = UDim2.new(0.5, -75, 0, 120)
    TCopyBtn.BackgroundColor3 = Colors.TargetAccent
    TCopyBtn.Text = "Copy Link"
    TCopyBtn.TextColor3 = Colors.Text
    TCopyBtn.Font = Enum.Font.GothamBold
    TCopyBtn.TextSize = 14
    TCopyBtn.BorderSizePixel = 0
    TCopyBtn.Parent = TPage3
    Instance.new("UICorner", TCopyBtn).CornerRadius = UDim.new(0, 4)

    local TCopyStatus = Instance.new("TextLabel")
    TCopyStatus.Size = UDim2.new(1, 0, 0, 25)
    TCopyStatus.Position = UDim2.new(0, 0, 0, 170)
    TCopyStatus.BackgroundTransparency = 1
    TCopyStatus.Text = "Click to copy"
    TCopyStatus.TextColor3 = Colors.Text
    TCopyStatus.Font = Enum.Font.GothamMedium
    TCopyStatus.TextSize = 12
    TCopyStatus.TextXAlignment = Enum.TextXAlignment.Center
    TCopyStatus.Parent = TPage3

    TCopyBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard("https://n-os-official.netlify.app/") end)
        TCopyStatus.Text = "✓ Copied!"
        TCopyStatus.TextColor3 = Colors.Success
        task.delay(2, function()
            TCopyStatus.Text = "Click to copy"
            TCopyStatus.TextColor3 = Colors.Text
        end)
    end)

    -- ============================================
    -- TARGET PAGE NAVIGATION
    -- ============================================
    local TPageNames = {"Features", "Executor", "Link"}
    local TPageButtons = {}

    for i = 1, 3 do
        local TPgBtn = Instance.new("TextButton")
        TPgBtn.Size = UDim2.new(1, -20, 0, 35)
        TPgBtn.Position = UDim2.new(0, 10, 0, 10 + (i - 1) * 45)
        TPgBtn.BackgroundColor3 = i == 1 and Colors.TargetAccent or Colors.PageBtn
        TPgBtn.Text = TPageNames[i]
        TPgBtn.TextColor3 = Colors.Text
        TPgBtn.Font = Enum.Font.GothamMedium
        TPgBtn.TextSize = 14
        TPgBtn.BorderSizePixel = 0
        TPgBtn.Parent = TNavFrame
        Instance.new("UICorner", TPgBtn).CornerRadius = UDim.new(0, 4)
        TPageButtons[i] = TPgBtn

        TPgBtn.MouseButton1Click:Connect(function()
            TPage1.Visible = (i == 1)
            TPage2.Visible = (i == 2)
            TPage3.Visible = (i == 3)
            for j = 1, 3 do
                TPageButtons[j].BackgroundColor3 = (j == i) and Colors.TargetAccent or Colors.PageBtn
            end
        end)
    end

    -- Window controls
    local tMinimized = false
    local tOrigSize = TargetWindow.Size

    TMinBtn.MouseButton1Click:Connect(function()
        tMinimized = not tMinimized
        if tMinimized then
            TargetWindow.Size = UDim2.new(0, 520, 0, 35)
            TPagesContainer.Visible = false
            TNavFrame.Visible = false
        else
            TargetWindow.Size = tOrigSize
            TPagesContainer.Visible = true
            TNavFrame.Visible = true
        end
    end)

    local function closeTargetWindow()
        if targetFlyHeartbeat then targetFlyHeartbeat:Disconnect() end
        cleanupTargetFly()
        stopTargetNoclip()
        if tState.infiniteJumpConn then tState.infiniteJumpConn:Disconnect() end
        if tState.godModeConn then tState.godModeConn:Disconnect() end
        if tState.invisibleConn then tState.invisibleConn:Disconnect() end
        removeTargetInvisible()
        ActiveTargetedWindows[targetName] = nil
        pcall(function() targetGui:Destroy() end)
    end

    TCloseBtn.MouseButton1Click:Connect(closeTargetWindow)

    local playerRemovingConn
    playerRemovingConn = Players.PlayerRemoving:Connect(function(plr)
        if plr == targetPlayer then
            playerRemovingConn:Disconnect()
            closeTargetWindow()
        end
    end)

    local charAddedConn
    charAddedConn = targetPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        if tState.flyEnabled then enableTargetFly(true) end
        if tState.noclipEnabled then
            applyTargetNoclip()
            startTargetNoclipLoop()
        end
        if tState.invisibleConn then applyTargetInvisible() end
        local wsInput = targetFeatures.WalkSpeed.valueInput
        if wsInput then
            local val = tonumber(wsInput.Text)
            if val then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = val end
            end
        end
        local jpInput = targetFeatures.JumpPower.valueInput
        if jpInput then
            local val = tonumber(jpInput.Text)
            if val then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.JumpPower = val end
            end
        end
        if targetFeatures["ESP"].state then
            local hl = Instance.new("Highlight")
            hl.Name = "ESP_TargetHighlight"
            hl.Adornee = char
            hl.FillColor = Color3.fromRGB(255, 165, 0)
            hl.OutlineColor = Color3.fromRGB(255, 165, 0)
            hl.FillTransparency = 0.5
            hl.Parent = char
        end
    end)

    ActiveTargetedWindows[targetName] = {
        Window = TargetWindow,
        Gui = targetGui,
        Target = targetPlayer,
        Features = targetFeatures,
        State = tState,
        CloseFunc = closeTargetWindow,
    }

    return ActiveTargetedWindows[targetName]
end

-- ============================================
-- ============================================
--  MAIN GUI: PAGE 1 - FEATURES (self)
-- ============================================
-- ============================================
local Page1 = Instance.new("Frame")
Page1.Name = "Page1"
Page1.Size = UDim2.new(1, -20, 1, -20)
Page1.Position = UDim2.new(0, 10, 0, 10)
Page1.BackgroundTransparency = 1
Page1.Visible = true
Page1.Parent = PagesContainer
Page1.ZIndex = 1

local FeatureScroll = Instance.new("ScrollingFrame")
FeatureScroll.Name = "FeatureScroll"
FeatureScroll.Size = UDim2.new(1, 0, 1, 0)
FeatureScroll.BackgroundTransparency = 1
FeatureScroll.BorderSizePixel = 0
FeatureScroll.ScrollBarThickness = 3
FeatureScroll.ScrollBarImageColor3 = Colors.Accent
FeatureScroll.CanvasSize = UDim2.new(0, 0, 0, 1000)
FeatureScroll.ZIndex = 1
FeatureScroll.Parent = Page1

local FeatureList = Instance.new("UIListLayout")
FeatureList.Parent = FeatureScroll
FeatureList.Padding = UDim.new(0, 5)
FeatureList.SortOrder = Enum.SortOrder.LayoutOrder

-- ============================================
-- SELF FLY SYSTEM
-- ============================================
local flyEnabled = false
local selfBv, selfBg
local flySpeedValue = 50
local invisibleEnabled = false
local selfInvisibleConn = nil

local function cleanupSelfFly()
    if selfBv and selfBv.Parent then pcall(function() selfBv:Destroy() end) end
    if selfBg and selfBg.Parent then pcall(function() selfBg:Destroy() end) end
    selfBv, selfBg = nil, nil
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function() hum.PlatformStand = false end)
        pcall(function() hum.WalkSpeed = GAME_DEFAULT_WALKSPEED end)
    end
end

local function enableSelfFly(enable)
    local char = Player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    if not enable then cleanupSelfFly(); return end
    cleanupSelfFly()
    selfBv = Instance.new("BodyVelocity")
    selfBv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    selfBv.Velocity = Vector3.new(0, 0, 0)
    selfBv.P = 9e4
    selfBv.Parent = hrp
    selfBg = Instance.new("BodyGyro")
    selfBg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    selfBg.P = 9e4
    selfBg.CFrame = hrp.CFrame
    selfBg.Parent = hrp
    pcall(function() hum.PlatformStand = true end)
end

local function applySelfInvisible()
    local char = Player.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0.85
        end
    end
end

local function removeSelfInvisible()
    local char = Player.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency > 0.5 then
            part.Transparency = 0
        end
    end
end

RunService.Heartbeat:Connect(function(dt)
    if not flyEnabled then
        if selfBv or selfBg then cleanupSelfFly() end
        return
    end
    local char = Player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    local cam = workspace.CurrentCamera
    if not hrp or not hum or not cam then return end
    if not selfBv or not selfBg or not selfBv.Parent then enableSelfFly(true) end
    local camC = cam.CFrame
    local camLook = camC.LookVector
    local camRight = camC.RightVector
    local move = hum.MoveDirection or Vector3.new(0, 0, 0)
    local horizForward = Vector3.new(camLook.X, 0, camLook.Z)
    local horizRight = Vector3.new(camRight.X, 0, camRight.Z)
    if horizForward.Magnitude < 1e-6 then horizForward = Vector3.new(0, 0, 1) end
    if horizRight.Magnitude < 1e-6 then horizRight = Vector3.new(1, 0, 0) end
    horizForward = horizForward.Unit
    horizRight = horizRight.Unit
    local forwardInput = Vector3.new(move.X, 0, move.Z):Dot(horizForward)
    local rightInput = Vector3.new(move.X, 0, move.Z):Dot(horizRight)
    local dir = (camLook * forwardInput) + (camRight * rightInput)
    if dir.Magnitude < 1e-4 then
        if selfBv and selfBv.Parent then
            selfBv.Velocity = selfBv.Velocity:Lerp(Vector3.new(0, 0, 0), math.clamp(30 * dt, 0, 1))
        end
    else
        local dirUnit = dir.Unit
        local targetVel = dirUnit * flySpeedValue
        if selfBv and selfBv.Parent then
            selfBv.Velocity = selfBv.Velocity:Lerp(targetVel, math.clamp(30 * dt, 0, 1))
        end
        if selfBg and selfBg.Parent then
            local yawLook = Vector3.new(camLook.X, 0, camLook.Z)
            if yawLook.Magnitude < 1e-6 then yawLook = Vector3.new(0, 0, 1) end
            selfBg.CFrame = CFrame.new(hrp.Position, hrp.Position + yawLook)
        end
    end
end)

function ToggleFly(enabled)
    flyEnabled = enabled
    if enabled then enableSelfFly(true) else cleanupSelfFly() end
end

-- Self No-Clip
local noclipEnabled = false
local noclipLoopRunning = false

function ToggleNoClip(enabled)
    noclipEnabled = enabled
    if enabled then
        if noclipLoopRunning then return end
        noclipLoopRunning = true
        spawn(function()
            while noclipLoopRunning and noclipEnabled do
                local c = Player.Character
                if c then
                    for _, v in pairs(c:GetDescendants()) do
                        if v:IsA("BasePart") then pcall(function() v.CanCollide = false end) end
                    end
                end
                task.wait(0.3)
            end
            noclipLoopRunning = false
        end)
    else
        noclipLoopRunning = false
        local c = Player.Character
        if c then
            for _, v in pairs(c:GetDescendants()) do
                if v:IsA("BasePart") then pcall(function() v.CanCollide = true end) end
            end
        end
    end
end

-- Self Feature Rows
local SelfFeatures = {}

SelfFeatures.Fly = CreateFeatureRow(FeatureScroll, "Fly", "Toggle")
SelfFeatures.Fly.onToggle = function(state) ToggleFly(state) end

SelfFeatures["No-Clip"] = CreateFeatureRow(FeatureScroll, "No-Clip", "Toggle")
SelfFeatures["No-Clip"].onToggle = function(state) ToggleNoClip(state) end

SelfFeatures["Invisible"] = CreateFeatureRow(FeatureScroll, "Invisible", "Toggle")
SelfFeatures["Invisible"].onToggle = function(state)
    invisibleEnabled = state
    if state then
        applySelfInvisible()
        selfInvisibleConn = RunService.Heartbeat:Connect(function()
            applySelfInvisible()
        end)
    else
        if selfInvisibleConn then
            selfInvisibleConn:Disconnect()
            selfInvisibleConn = nil
        end
        removeSelfInvisible()
    end
end

SelfFeatures.ESP = CreateFeatureRow(FeatureScroll, "ESP", "Toggle")
SelfFeatures.ESP.onToggle = function(state)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            local char = plr.Character
            if char then
                local hl = char:FindFirstChild("ESP_Highlight")
                if state and not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "ESP_Highlight"
                    hl.Adornee = char
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 0, 0)
                    hl.FillTransparency = 0.5
                    hl.Parent = char
                elseif not state and hl then
                    hl:Destroy()
                end
            end
        end
    end
end

SelfFeatures.Teleport = CreateFeatureRow(FeatureScroll, "Teleport", "Players", nil, {
    actionColor = Colors.TeleportBtn,
    btnText = "Players ▼",
})
SelfFeatures.Teleport.onPlayersClick = function(btn)
    ShowGlobalPlayerDropdown(btn, function(plr)
        local myRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        local targetRoot = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if myRoot and targetRoot then
            myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
        end
    end, Player)
end

SelfFeatures["Kill Player"] = CreateFeatureRow(FeatureScroll, "Kill Player", "Players", nil, {
    actionColor = Colors.KillBtn,
    btnText = "Players ▼",
})
SelfFeatures["Kill Player"].onPlayersClick = function(btn)
    ShowGlobalPlayerDropdown(btn, function(plr)
        local char = plr.Character
        if not char then return end

        local root = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")

        if root then
            root.CFrame = CFrame.new(root.Position.X, -2000, root.Position.Z)
            root.Velocity = Vector3.new(0, -500, 0)
        end
        if head then
            head.CFrame = CFrame.new(head.Position.X, -2000, head.Position.Z)
        end
        if torso then
            torso.CFrame = CFrame.new(torso.Position.X, -2000, torso.Position.Z)
        end

        task.wait(0.1)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end

        task.wait(0.05)
        local head2 = char:FindFirstChild("Head")
        if head2 then pcall(function() head2:Destroy() end) end

        task.wait(0.05)
        if root and root.Parent then
            root.CFrame = CFrame.new(0, -5000, 0)
        end
    end, Player)
end

SelfFeatures.WalkSpeed = CreateFeatureRow(FeatureScroll, "WalkSpeed", "Value", 16)
SelfFeatures.WalkSpeed.onApply = function(val)
    local char = Player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end
end

SelfFeatures.JumpPower = CreateFeatureRow(FeatureScroll, "JumpPower", "Value", 50)
SelfFeatures.JumpPower.onApply = function(val)
    local char = Player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = val end
    end
end

local infiniteJumpConnection = nil
SelfFeatures["Infinite Jump"] = CreateFeatureRow(FeatureScroll, "Infinite Jump", "Toggle")
SelfFeatures["Infinite Jump"].onToggle = function(state)
    if state then
        infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            local char = Player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    else
        if infiniteJumpConnection then infiniteJumpConnection:Disconnect(); infiniteJumpConnection = nil end
    end
end

SelfFeatures.FullBright = CreateFeatureRow(FeatureScroll, "FullBright", "Toggle")
SelfFeatures.FullBright.onToggle = function(state)
    if state then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        Lighting.FogEnd = 10000
        Lighting.GlobalShadows = true
    end
end

SelfFeatures["FPS Unlock"] = CreateFeatureRow(FeatureScroll, "FPS Unlock", "Toggle")
SelfFeatures["FPS Unlock"].onToggle = function(state)
    if state then pcall(function() setfpscap(9999) end)
    else pcall(function() setfpscap(60) end) end
end

-- ============================================
-- MAPS SECTION
-- ============================================
local MapsSectionLabel = Instance.new("Frame")
MapsSectionLabel.Size = UDim2.new(1, -10, 0, 35)
MapsSectionLabel.BackgroundColor3 = Colors.Accent
MapsSectionLabel.BorderSizePixel = 0
MapsSectionLabel.Parent = FeatureScroll
Instance.new("UICorner", MapsSectionLabel).CornerRadius = UDim.new(0, 4)

local MapsTitle = Instance.new("TextLabel")
MapsTitle.Size = UDim2.new(1, 0, 1, 0)
MapsTitle.BackgroundTransparency = 1
MapsTitle.Text = "📍 Maps"
MapsTitle.TextColor3 = Colors.Text
MapsTitle.Font = Enum.Font.GothamBold
MapsTitle.TextSize = 15
MapsTitle.TextXAlignment = Enum.TextXAlignment.Left
MapsTitle.Parent = MapsSectionLabel

local MapList = {
    {Name = "Brookhaven 🏡RP"},
    {Name = "Steal a Brainrot 🧠"},
}

for _, map in ipairs(MapList) do
    local MapFrame = Instance.new("Frame")
    MapFrame.Size = UDim2.new(1, -10, 0, 40)
    MapFrame.BackgroundColor3 = Colors.Button
    MapFrame.BorderSizePixel = 0
    MapFrame.Parent = FeatureScroll
    Instance.new("UICorner", MapFrame).CornerRadius = UDim.new(0, 4)

    local MapLabel = Instance.new("TextLabel")
    MapLabel.Size = UDim2.new(1, -20, 1, 0)
    MapLabel.Position = UDim2.new(0, 10, 0, 0)
    MapLabel.BackgroundTransparency = 1
    MapLabel.Text = map.Name
    MapLabel.TextColor3 = Colors.Text
    MapLabel.Font = Enum.Font.GothamMedium
    MapLabel.TextSize = 14
    MapLabel.TextXAlignment = Enum.TextXAlignment.Left
    MapLabel.Parent = MapFrame

    local MapArrow = Instance.new("TextLabel")
    MapArrow.Size = UDim2.new(0, 30, 1, 0)
    MapArrow.Position = UDim2.new(1, -30, 0, 0)
    MapArrow.BackgroundTransparency = 1
    MapArrow.Text = "▶"
    MapArrow.TextColor3 = Colors.Accent
    MapArrow.Font = Enum.Font.GothamBold
    MapArrow.TextSize = 16
    MapArrow.TextXAlignment = Enum.TextXAlignment.Center
    MapArrow.Parent = MapFrame

    MapFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if map.Name == "Brookhaven 🏡RP" then
                OpenBrookhavenWindow()
            elseif map.Name == "Steal a Brainrot 🧠" then
                OpenBrainrotWindow()
            end
        end
    end)
end

-- ============================================
-- BROOKHAVEN COMMANDS WINDOW
-- ============================================
local BrookhavenWindow = nil
local godModeConnection = nil
local antiAFKConnection = nil

function OpenBrookhavenWindow()
    if BrookhavenWindow then BrookhavenWindow:Destroy(); BrookhavenWindow = nil end

    BrookhavenWindow = Instance.new("Frame")
    BrookhavenWindow.Size = UDim2.new(0, 320, 0, 380)
    BrookhavenWindow.Position = UDim2.new(0.5, 280, 0.5, -190)
    BrookhavenWindow.BackgroundColor3 = Colors.Background
    BrookhavenWindow.BorderSizePixel = 0
    BrookhavenWindow.Active = true
    BrookhavenWindow.Draggable = true
    BrookhavenWindow.ZIndex = 50
    BrookhavenWindow.Parent = ScreenGui
    Instance.new("UICorner", BrookhavenWindow).CornerRadius = UDim.new(0, 8)

    local BWTopBar = Instance.new("Frame")
    BWTopBar.Size = UDim2.new(1, 0, 0, 35)
    BWTopBar.BackgroundColor3 = Colors.TopBar
    BWTopBar.BorderSizePixel = 0
    BWTopBar.Parent = BrookhavenWindow
    Instance.new("UICorner", BWTopBar).CornerRadius = UDim.new(0, 8)

    local BWTitle = Instance.new("TextLabel")
    BWTitle.Size = UDim2.new(1, -40, 1, 0)
    BWTitle.Position = UDim2.new(0, 15, 0, 0)
    BWTitle.BackgroundTransparency = 1
    BWTitle.Text = "🏡 Brookhaven RP"
    BWTitle.TextColor3 = Colors.Text
    BWTitle.Font = Enum.Font.GothamBold
    BWTitle.TextSize = 14
    BWTitle.TextXAlignment = Enum.TextXAlignment.Left
    BWTitle.Parent = BWTopBar

    local BWCloseBtn = Instance.new("TextButton")
    BWCloseBtn.Size = UDim2.new(0, 28, 0, 24)
    BWCloseBtn.Position = UDim2.new(1, -34, 0, 5)
    BWCloseBtn.BackgroundColor3 = Colors.Close
    BWCloseBtn.Text = "X"
    BWCloseBtn.TextColor3 = Colors.Text
    BWCloseBtn.Font = Enum.Font.GothamBold
    BWCloseBtn.TextSize = 14
    BWCloseBtn.BorderSizePixel = 0
    BWCloseBtn.Parent = BWTopBar
    Instance.new("UICorner", BWCloseBtn).CornerRadius = UDim.new(0, 4)
    BWCloseBtn.MouseButton1Click:Connect(function()
        BrookhavenWindow:Destroy(); BrookhavenWindow = nil
    end)

    local BWContent = Instance.new("ScrollingFrame")
    BWContent.Size = UDim2.new(1, -10, 1, -45)
    BWContent.Position = UDim2.new(0, 5, 0, 40)
    BWContent.BackgroundTransparency = 1
    BWContent.BorderSizePixel = 0
    BWContent.ScrollBarThickness = 3
    BWContent.ScrollBarImageColor3 = Colors.Accent
    BWContent.CanvasSize = UDim2.new(0, 0, 0, 750)
    BWContent.ZIndex = 51
    BWContent.Parent = BrookhavenWindow

    local BWLay = Instance.new("UIListLayout")
    BWLay.Parent = BWContent
    BWLay.Padding = UDim.new(0, 6)
    BWLay.SortOrder = Enum.SortOrder.LayoutOrder

    local locations = {
        ["Town Hall"] = Vector3.new(0, 5, 0),
        ["Police Station"] = Vector3.new(-80, 5, -60),
        ["Hospital"] = Vector3.new(80, 5, -60),
        ["School"] = Vector3.new(-150, 5, 120),
        ["Bank"] = Vector3.new(0, 5, -120),
        ["Gas Station"] = Vector3.new(150, 5, 0),
        ["Church"] = Vector3.new(-40, 5, 80),
        ["Grocery Store"] = Vector3.new(100, 5, 80),
    }

    local commands = {
        {cat = "🏠 House Teleports", items = {
            "Teleport to My House", "Teleport to Town Hall", "Teleport to Police Station",
            "Teleport to Hospital", "Teleport to School", "Teleport to Bank",
            "Teleport to Gas Station", "Teleport to Church", "Teleport to Grocery Store"
        }},
        {cat = "🚗 Vehicle Commands", items = {
            "Get Car", "Get Sports Car", "Get Motorcycle", "Get Helicopter",
            "Repair Vehicle", "Delete Vehicle"
        }},
        {cat = "💰 Money & Items", items = {"Auto Farm Money", "Give All Tools"}},
        {cat = "👤 Player Mods", items = {"God Mode", "Invisible", "Anti AFK"}},
    }

    local function runCmd(cmd)
        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if cmd == "Teleport to My House" then
            if root then root.CFrame = CFrame.new(Vector3.new(60, 5, 100)) end
        elseif locations[cmd:gsub("Teleport to ", "")] then
            local pos = locations[cmd:gsub("Teleport to ", "")]
            if root then root.CFrame = CFrame.new(pos) end
        elseif cmd:find("Get") then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChildOfClass("VehicleSeat") then
                    local seat = obj:FindFirstChildOfClass("VehicleSeat")
                    if root and seat then root.CFrame = seat.CFrame + Vector3.new(0, 3, 0); break end
                end
            end
        elseif cmd == "Repair Vehicle" then
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = hum.MaxHealth end
        elseif cmd == "Delete Vehicle" then
            local seat = char and char:FindFirstChildOfClass("VehicleSeat")
            if seat and seat.Parent then seat.Parent:Destroy() end
        elseif cmd == "Auto Farm Money" then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Part") or obj:IsA("MeshPart") then
                    if obj.Name:lower():find("money") or obj.Name:lower():find("coin") or obj.Name:lower():find("dollar") then
                        if root then root.CFrame = obj.CFrame + Vector3.new(0, 3, 0); task.wait(0.2) end
                    end
                end
            end
        elseif cmd == "Give All Tools" then
            local tools = {}
            local function collect(p)
                for _, o in ipairs(p:GetChildren()) do
                    if o:IsA("Tool") then table.insert(tools, o:Clone()) end
                    collect(o)
                end
            end
            for _, p in ipairs({game:GetService("ReplicatedStorage"), game:GetService("ServerStorage"), game:GetService("StarterPack")}) do
                pcall(function() collect(p) end)
            end
            local bp = Player:FindFirstChild("Backpack")
            if bp then for _, t in ipairs(tools) do pcall(function() t.Parent = bp end) end end
        elseif cmd == "God Mode" then
            if godModeConnection then godModeConnection:Disconnect(); godModeConnection = nil; return end
            godModeConnection = RunService.Stepped:Connect(function()
                local c = Player.Character
                if c then local h = c:FindFirstChildOfClass("Humanoid"); if h then h.Health = h.MaxHealth end end
            end)
        elseif cmd == "Invisible" then
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.Transparency = p.Transparency == 0 and 0.85 or 0 end
                end
            end
        elseif cmd == "Anti AFK" then
            if antiAFKConnection then antiAFKConnection:Disconnect(); antiAFKConnection = nil; return end
            antiAFKConnection = RunService.Heartbeat:Connect(function()
                pcall(function() game:GetService("VirtualUser"):CaptureController(); game:GetService("VirtualUser"):ClickButton2(Vector2.new()) end)
            end)
        end
    end

    for _, cat in ipairs(commands) do
        local hdr = Instance.new("Frame")
        hdr.Size = UDim2.new(1, -10, 0, 28)
        hdr.BackgroundColor3 = Colors.Accent
        hdr.BorderSizePixel = 0
        hdr.Parent = BWContent
        Instance.new("UICorner", hdr).CornerRadius = UDim.new(0, 4)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -10, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = cat.cat
        lbl.TextColor3 = Colors.Text
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = hdr

        for _, cmd in ipairs(cat.items) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 35)
            btn.BackgroundColor3 = Colors.Button
            btn.Text = cmd
            btn.TextColor3 = Colors.Text
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 13
            btn.BorderSizePixel = 0
            btn.Parent = BWContent
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            btn.MouseButton1Click:Connect(function() pcall(function() runCmd(cmd) end) end)
        end
    end
end

-- ============================================
-- STEAL A BRAINROT COMMANDS WINDOW
-- ============================================
local BrainrotWindow = nil

function OpenBrainrotWindow()
    if BrainrotWindow then
        BrainrotWindow:Destroy()
        BrainrotWindow = nil
    end

    BrainrotWindow = Instance.new("Frame")
    BrainrotWindow.Size = UDim2.new(0, 320, 0, 380)
    BrainrotWindow.Position = UDim2.new(0.5, 280, 0.5, -190)
    BrainrotWindow.BackgroundColor3 = Colors.Background
    BrainrotWindow.BorderSizePixel = 0
    BrainrotWindow.Active = true
    BrainrotWindow.Draggable = true
    BrainrotWindow.ZIndex = 50
    BrainrotWindow.Parent = ScreenGui
    Instance.new("UICorner", BrainrotWindow).CornerRadius = UDim.new(0, 8)

    -- Top bar
    local BrTopBar = Instance.new("Frame")
    BrTopBar.Size = UDim2.new(1, 0, 0, 35)
    BrTopBar.BackgroundColor3 = Colors.TopBar
    BrTopBar.BorderSizePixel = 0
    BrTopBar.Parent = BrainrotWindow
    Instance.new("UICorner", BrTopBar).CornerRadius = UDim.new(0, 8)

    local BrTitle = Instance.new("TextLabel")
    BrTitle.Size = UDim2.new(1, -40, 1, 0)
    BrTitle.Position = UDim2.new(0, 15, 0, 0)
    BrTitle.BackgroundTransparency = 1
    BrTitle.Text = "🧠 Steal a Brainrot"
    BrTitle.TextColor3 = Colors.Text
    BrTitle.Font = Enum.Font.GothamBold
    BrTitle.TextSize = 14
    BrTitle.TextXAlignment = Enum.TextXAlignment.Left
    BrTitle.Parent = BrTopBar

    local BrCloseBtn = Instance.new("TextButton")
    BrCloseBtn.Size = UDim2.new(0, 28, 0, 24)
    BrCloseBtn.Position = UDim2.new(1, -34, 0, 5)
    BrCloseBtn.BackgroundColor3 = Colors.Close
    BrCloseBtn.Text = "X"
    BrCloseBtn.TextColor3 = Colors.Text
    BrCloseBtn.Font = Enum.Font.GothamBold
    BrCloseBtn.TextSize = 14
    BrCloseBtn.BorderSizePixel = 0
    BrCloseBtn.Parent = BrTopBar
    Instance.new("UICorner", BrCloseBtn).CornerRadius = UDim.new(0, 4)
    BrCloseBtn.MouseButton1Click:Connect(function()
        BrainrotWindow:Destroy()
        BrainrotWindow = nil
    end)

    -- Content
    local BrContent = Instance.new("ScrollingFrame")
    BrContent.Size = UDim2.new(1, -10, 1, -45)
    BrContent.Position = UDim2.new(0, 5, 0, 40)
    BrContent.BackgroundTransparency = 1
    BrContent.BorderSizePixel = 0
    BrContent.ScrollBarThickness = 3
    BrContent.ScrollBarImageColor3 = Colors.Accent
    BrContent.CanvasSize = UDim2.new(0, 0, 0, 420)
    BrContent.ZIndex = 51
    BrContent.Parent = BrainrotWindow

    local BrLay = Instance.new("UIListLayout")
    BrLay.Parent = BrContent
    BrLay.Padding = UDim.new(0, 6)
    BrLay.SortOrder = Enum.SortOrder.LayoutOrder

    -- ============================================
    -- 1) SPAWN FOR BRAINROTS
    -- ============================================
    local spawnHeader = Instance.new("Frame")
    spawnHeader.Size = UDim2.new(1, -10, 0, 28)
    spawnHeader.BackgroundColor3 = Colors.GreenAccent
    spawnHeader.BorderSizePixel = 0
    spawnHeader.Parent = BrContent
    Instance.new("UICorner", spawnHeader).CornerRadius = UDim.new(0, 4)

    local spawnLabel = Instance.new("TextLabel")
    spawnLabel.Size = UDim2.new(1, -10, 1, 0)
    spawnLabel.Position = UDim2.new(0, 10, 0, 0)
    spawnLabel.BackgroundTransparency = 1
    spawnLabel.Text = "🧠 Spawn for Brainrots"
    spawnLabel.TextColor3 = Colors.Text
    spawnLabel.Font = Enum.Font.GothamBold
    spawnLabel.TextSize = 13
    spawnLabel.TextXAlignment = Enum.TextXAlignment.Left
    spawnLabel.Parent = spawnHeader

    local spawnBtn = Instance.new("TextButton")
    spawnBtn.Size = UDim2.new(1, -10, 0, 45)
    spawnBtn.BackgroundColor3 = Colors.Button
    spawnBtn.Text = "Teleport to Brainrot Spawns"
    spawnBtn.TextColor3 = Colors.Text
    spawnBtn.Font = Enum.Font.GothamMedium
    spawnBtn.TextSize = 13
    spawnBtn.BorderSizePixel = 0
    spawnBtn.Parent = BrContent
    Instance.new("UICorner", spawnBtn).CornerRadius = UDim.new(0, 4)

    spawnBtn.MouseButton1Click:Connect(function()
        local char = Player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local spawnsFound = 0

        -- Find brainrot spawn pads / eggs / nests
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Part") or obj:IsA("MeshPart") then
                local nameLower = obj.Name:lower()
                local parentName = obj.Parent and obj.Parent.Name:lower() or ""
                if nameLower:find("spawn") or nameLower:find("pad") or nameLower:find("egg")
                    or nameLower:find("brainrot") or nameLower:find("nest")
                    or parentName:find("spawn") or parentName:find("brainrot") then
                    spawnsFound = spawnsFound + 1
                    root.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.3)
                end
            end
        end

        -- Also check models
        for _, model in ipairs(workspace:GetDescendants()) do
            if model:IsA("Model") then
                local modelName = model.Name:lower()
                if modelName:find("brainrot") or modelName:find("spawn") then
                    local primary = model.PrimaryPart
                    if primary then
                        spawnsFound = spawnsFound + 1
                        root.CFrame = primary.CFrame + Vector3.new(0, 3, 0)
                        task.wait(0.3)
                    end
                end
            end
        end

        -- Fallback: green/lime parts
        if spawnsFound == 0 then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Part") and (obj.BrickColor.Name == "Bright green" or obj.BrickColor.Name == "Lime green") then
                    spawnsFound = spawnsFound + 1
                    root.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.2)
                end
            end
        end
    end)

    -- ============================================
    -- 2) AUTO LOCK BASE
    -- ============================================
    local lockHeader = Instance.new("Frame")
    lockHeader.Size = UDim2.new(1, -10, 0, 28)
    lockHeader.BackgroundColor3 = Colors.TargetAccent
    lockHeader.BorderSizePixel = 0
    lockHeader.Parent = BrContent
    Instance.new("UICorner", lockHeader).CornerRadius = UDim.new(0, 4)

    local lockLabel = Instance.new("TextLabel")
    lockLabel.Size = UDim2.new(1, -10, 1, 0)
    lockLabel.Position = UDim2.new(0, 10, 0, 0)
    lockLabel.BackgroundTransparency = 1
    lockLabel.Text = "🔒 Auto Lock Base"
    lockLabel.TextColor3 = Colors.Text
    lockLabel.Font = Enum.Font.GothamBold
    lockLabel.TextSize = 13
    lockLabel.TextXAlignment = Enum.TextXAlignment.Left
    lockLabel.Parent = lockHeader

    local lockBtn = Instance.new("TextButton")
    lockBtn.Size = UDim2.new(1, -10, 0, 45)
    lockBtn.BackgroundColor3 = Colors.Button
    lockBtn.Text = "🔒 Toggle Auto Lock (OFF)"
    lockBtn.TextColor3 = Colors.Text
    lockBtn.Font = Enum.Font.GothamMedium
    lockBtn.TextSize = 13
    lockBtn.BorderSizePixel = 0
    lockBtn.Parent = BrContent
    Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(0, 4)

    local autoLockEnabled = false
    local autoLockConnection = nil

    lockBtn.MouseButton1Click:Connect(function()
        autoLockEnabled = not autoLockEnabled
        if autoLockEnabled then
            lockBtn.Text = "🔒 Auto Lock (ON)"
            lockBtn.BackgroundColor3 = Colors.GreenAccent

            autoLockConnection = RunService.Heartbeat:Connect(function()
                pcall(function()
                    for _, v in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                        if v:IsA("RemoteEvent") then
                            local evName = v.Name:lower()
                            if evName:find("lock") or evName:find("base") or evName:find("door") or evName:find("togglelock") then
                                v:FireServer()
                            end
                        end
                    end

                    local char = Player.Character
                    if char then
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root then
                            for _, obj in ipairs(workspace:GetDescendants()) do
                                if obj:IsA("ProximityPrompt") then
                                    local promptName = obj.Name:lower()
                                    if promptName:find("lock") or promptName:find("base") then
                                        if obj.Parent and obj.Parent:IsA("BasePart") then
                                            root.CFrame = obj.Parent.CFrame + Vector3.new(0, 2, 0)
                                        end
                                        pcall(function() obj:InputHoldBegin() end)
                                    end
                                end
                            end
                        end
                    end
                end)
            end)
        else
            lockBtn.Text = "🔒 Toggle Auto Lock (OFF)"
            lockBtn.BackgroundColor3 = Colors.Button
            if autoLockConnection then
                autoLockConnection:Disconnect()
                autoLockConnection = nil
            end
        end
    end)

    -- ============================================
    -- 3) AUTO TAKE MONEY
    -- ============================================
    local moneyHeader = Instance.new("Frame")
    moneyHeader.Size = UDim2.new(1, -10, 0, 28)
    moneyHeader.BackgroundColor3 = Colors.GoldAccent
    moneyHeader.BorderSizePixel = 0
    moneyHeader.Parent = BrContent
    Instance.new("UICorner", moneyHeader).CornerRadius = UDim.new(0, 4)

    local moneyLabel = Instance.new("TextLabel")
    moneyLabel.Size = UDim2.new(1, -10, 1, 0)
    moneyLabel.Position = UDim2.new(0, 10, 0, 0)
    moneyLabel.BackgroundTransparency = 1
    moneyLabel.Text = "💰 Auto Take Money"
    moneyLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    moneyLabel.Font = Enum.Font.GothamBold
    moneyLabel.TextSize = 13
    moneyLabel.TextXAlignment = Enum.TextXAlignment.Left
    moneyLabel.Parent = moneyHeader

    local moneyBtn = Instance.new("TextButton")
    moneyBtn.Size = UDim2.new(1, -10, 0, 45)
    moneyBtn.BackgroundColor3 = Colors.Button
    moneyBtn.Text = "Auto Collect All Money"
    moneyBtn.TextColor3 = Colors.Text
    moneyBtn.Font = Enum.Font.GothamMedium
    moneyBtn.TextSize = 13
    moneyBtn.BorderSizePixel = 0
    moneyBtn.Parent = BrContent
    Instance.new("UICorner", moneyBtn).CornerRadius = UDim.new(0, 4)

    moneyBtn.MouseButton1Click:Connect(function()
        local char = Player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Part") or obj:IsA("MeshPart") then
                local objName = obj.Name:lower()
                local parentName = obj.Parent and obj.Parent.Name:lower() or ""
                if objName:find("money") or objName:find("cash") or objName:find("coin")
                    or objName:find("dollar") or objName:find("gem") or objName:find("reward")
                    or parentName:find("money") or parentName:find("cash") then
                    root.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.15)
                    if obj.CanTouch then
                        pcall(function()
                            firetouchinterest(obj, root, 0)
                            firetouchinterest(obj, root, 1)
                        end)
                    end
                end
            end
        end

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Tool") then
                local toolName = obj.Name:lower()
                if toolName:find("money") or toolName:find("cash") or toolName:find("coin") then
                    if obj.Handle then
                        root.CFrame = obj.Handle.CFrame + Vector3.new(0, 3, 0)
                        task.wait(0.1)
                    end
                end
            end
        end

        for _, v in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if v:IsA("RemoteEvent") then
                local evName = v.Name:lower()
                if evName:find("money") or evName:find("cash") or evName:find("collect") or evName:find("claim") then
                    pcall(function() v:FireServer() end)
                end
            end
        end
    end)

    -- ============================================
    -- 4) TELEPORT TO MY BASE
    -- ============================================
    local baseHeader = Instance.new("Frame")
    baseHeader.Size = UDim2.new(1, -10, 0, 28)
    baseHeader.BackgroundColor3 = Colors.Accent
    baseHeader.BorderSizePixel = 0
    baseHeader.Parent = BrContent
    Instance.new("UICorner", baseHeader).CornerRadius = UDim.new(0, 4)

    local baseLabel = Instance.new("TextLabel")
    baseLabel.Size = UDim2.new(1, -10, 1, 0)
    baseLabel.Position = UDim2.new(0, 10, 0, 0)
    baseLabel.BackgroundTransparency = 1
    baseLabel.Text = "🏠 Teleport to My Base"
    baseLabel.TextColor3 = Colors.Text
    baseLabel.Font = Enum.Font.GothamBold
    baseLabel.TextSize = 13
    baseLabel.TextXAlignment = Enum.TextXAlignment.Left
    baseLabel.Parent = baseHeader

    local baseBtn = Instance.new("TextButton")
    baseBtn.Size = UDim2.new(1, -10, 0, 45)
    baseBtn.BackgroundColor3 = Colors.Button
    baseBtn.Text = "🏠 Teleport to My Base"
    baseBtn.TextColor3 = Colors.Text
    baseBtn.Font = Enum.Font.GothamMedium
    baseBtn.TextSize = 13
    baseBtn.BorderSizePixel = 0
    baseBtn.Parent = BrContent
    Instance.new("UICorner", baseBtn).CornerRadius = UDim.new(0, 4)

    baseBtn.MouseButton1Click:Connect(function()
        local char = Player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local found = false

        -- Method 1: Owner attribute
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Part") or obj:IsA("Model") then
                if obj:GetAttribute("Owner") == Player.Name or obj:GetAttribute("owner") == Player.Name then
                    local target = obj:IsA("Model") and obj.PrimaryPart or obj
                    if target then
                        root.CFrame = target.CFrame + Vector3.new(0, 3, 0)
                        found = true
                        break
                    end
                end
            end
        end

        -- Method 2: Base/Plot/Home objects
        if not found then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Part") or obj:IsA("Model") then
                    local objName = obj.Name:lower()
                    if objName:find("base") or objName:find("plot") or objName:find("home") or objName:find("house") then
                        local target = obj:IsA("Model") and obj.PrimaryPart or obj
                        if target then
                            root.CFrame = target.CFrame + Vector3.new(0, 3, 0)
                            found = true
                            break
                        end
                    end
                end
            end
        end

        -- Method 3: Player name StringValue
        if not found then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local ownerTag = obj:FindFirstChild("Owner")
                    if ownerTag and ownerTag:IsA("StringValue") and ownerTag.Value == Player.Name then
                        root.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                        found = true
                        break
                    end
                end
            end
        end

        -- Method 4: SpawnLocation fallback
        if not found then
            local spawnLocation = workspace:FindFirstChild("SpawnLocation")
            if spawnLocation then
                root.CFrame = spawnLocation.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end)

    -- ============================================
    -- 5) INVISIBLE
    -- ============================================
    local invisHeader = Instance.new("Frame")
    invisHeader.Size = UDim2.new(1, -10, 0, 28)
    invisHeader.BackgroundColor3 = Colors.InvisAccent
    invisHeader.BorderSizePixel = 0
    invisHeader.Parent = BrContent
    Instance.new("UICorner", invisHeader).CornerRadius = UDim.new(0, 4)

    local invisLabel = Instance.new("TextLabel")
    invisLabel.Size = UDim2.new(1, -10, 1, 0)
    invisLabel.Position = UDim2.new(0, 10, 0, 0)
    invisLabel.BackgroundTransparency = 1
    invisLabel.Text = "👻 Invisible Mode"
    invisLabel.TextColor3 = Colors.Text
    invisLabel.Font = Enum.Font.GothamBold
    invisLabel.TextSize = 13
    invisLabel.TextXAlignment = Enum.TextXAlignment.Left
    invisLabel.Parent = invisHeader

    local invisBtn = Instance.new("TextButton")
    invisBtn.Size = UDim2.new(1, -10, 0, 45)
    invisBtn.BackgroundColor3 = Colors.Button
    invisBtn.Text = "👻 Toggle Invisible (OFF)"
    invisBtn.TextColor3 = Colors.Text
    invisBtn.Font = Enum.Font.GothamMedium
    invisBtn.TextSize = 13
    invisBtn.BorderSizePixel = 0
    invisBtn.Parent = BrContent
    Instance.new("UICorner", invisBtn).CornerRadius = UDim.new(0, 4)

    local brInvisEnabled = false
    local brInvisConn = nil

    invisBtn.MouseButton1Click:Connect(function()
        brInvisEnabled = not brInvisEnabled
        if brInvisEnabled then
            invisBtn.Text = "👻 Invisible (ON)"
            invisBtn.BackgroundColor3 = Colors.InvisAccent

            -- Apply invisibility immediately
            local char = Player.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 0.85
                    end
                end
            end

            -- Keep applying via heartbeat (for respawn/new parts)
            brInvisConn = RunService.Heartbeat:Connect(function()
                local c = Player.Character
                if c then
                    for _, part in ipairs(c:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Transparency = 0.85
                        end
                    end
                end
            end)

            -- Also try firing invisibility-related remote events
            for _, v in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                if v:IsA("RemoteEvent") then
                    local evName = v.Name:lower()
                    if evName:find("invis") or evName:find("cloak") or evName:find("ghost") or evName:find("stealth") then
                        pcall(function() v:FireServer() end)
                    end
                end
            end
        else
            invisBtn.Text = "👻 Toggle Invisible (OFF)"
            invisBtn.BackgroundColor3 = Colors.Button
            if brInvisConn then
                brInvisConn:Disconnect()
                brInvisConn = nil
            end
            -- Restore visibility
            local char = Player.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Transparency > 0.5 then
                        part.Transparency = 0
                    end
                end
            end
        end
    end)
end

-- ============================================
-- PAGE 2: PLAYERS (Server Player List)
-- ============================================
local Page2 = Instance.new("Frame")
Page2.Name = "Page2"
Page2.Size = UDim2.new(1, -20, 1, -20)
Page2.Position = UDim2.new(0, 10, 0, 10)
Page2.BackgroundTransparency = 1
Page2.Visible = false
Page2.Parent = PagesContainer
Page2.ZIndex = 1

local PlayersTitle = Instance.new("TextLabel")
PlayersTitle.Size = UDim2.new(1, 0, 0, 30)
PlayersTitle.BackgroundTransparency = 1
PlayersTitle.Text = "👥 Server Players"
PlayersTitle.TextColor3 = Colors.Text
PlayersTitle.Font = Enum.Font.GothamBold
PlayersTitle.TextSize = 16
PlayersTitle.TextXAlignment = Enum.TextXAlignment.Left
PlayersTitle.Parent = Page2

local PlayersSubtitle = Instance.new("TextLabel")
PlayersSubtitle.Size = UDim2.new(1, 0, 0, 20)
PlayersSubtitle.Position = UDim2.new(0, 0, 0, 32)
PlayersSubtitle.BackgroundTransparency = 1
PlayersSubtitle.Text = "Click a player to open their targeted N_OS window"
PlayersSubtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
PlayersSubtitle.Font = Enum.Font.Gotham
PlayersSubtitle.TextSize = 11
PlayersSubtitle.TextXAlignment = Enum.TextXAlignment.Left
PlayersSubtitle.Parent = Page2

local PlayerListScroll = Instance.new("ScrollingFrame")
PlayerListScroll.Size = UDim2.new(1, 0, 1, -60)
PlayerListScroll.Position = UDim2.new(0, 0, 0, 55)
PlayerListScroll.BackgroundTransparency = 1
PlayerListScroll.BorderSizePixel = 0
PlayerListScroll.ScrollBarThickness = 3
PlayerListScroll.ScrollBarImageColor3 = Colors.Accent
PlayerListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerListScroll.Parent = Page2

local PlayerListLayout = Instance.new("UIListLayout")
PlayerListLayout.Parent = PlayerListScroll
PlayerListLayout.Padding = UDim.new(0, 4)
PlayerListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0, 80, 0, 28)
RefreshBtn.Position = UDim2.new(1, -90, 0, 2)
RefreshBtn.BackgroundColor3 = Colors.Accent
RefreshBtn.Text = "🔄 Refresh"
RefreshBtn.TextColor3 = Colors.Text
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.TextSize = 11
RefreshBtn.BorderSizePixel = 0
RefreshBtn.Parent = Page2
Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 4)

local function RefreshPlayerList()
    for _, child in ipairs(PlayerListScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local playerCount = 0

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            playerCount = playerCount + 1

            local PEntry = Instance.new("Frame")
            PEntry.Name = plr.Name
            PEntry.Size = UDim2.new(1, -10, 0, 45)
            PEntry.BackgroundColor3 = Colors.Button
            PEntry.BorderSizePixel = 0
            PEntry.Parent = PlayerListScroll
            Instance.new("UICorner", PEntry).CornerRadius = UDim.new(0, 6)

            local PIcon = Instance.new("Frame")
            PIcon.Size = UDim2.new(0, 35, 0, 35)
            PIcon.Position = UDim2.new(0, 5, 0, 5)
            PIcon.BackgroundColor3 = Colors.Accent
            PIcon.BorderSizePixel = 0
            PIcon.Parent = PEntry
            Instance.new("UICorner", PIcon).CornerRadius = UDim.new(0, 17)

            local PIconText = Instance.new("TextLabel")
            PIconText.Size = UDim2.new(1, 0, 1, 0)
            PIconText.BackgroundTransparency = 1
            PIconText.Text = plr.Name:sub(1, 1):upper()
            PIconText.TextColor3 = Colors.Text
            PIconText.Font = Enum.Font.GothamBold
            PIconText.TextSize = 16
            PIconText.Parent = PIcon

            local PName = Instance.new("TextLabel")
            PName.Size = UDim2.new(0, 180, 1, 0)
            PName.Position = UDim2.new(0, 50, 0, 0)
            PName.BackgroundTransparency = 1
            PName.Text = plr.Name
            PName.TextColor3 = Colors.Text
            PName.Font = Enum.Font.GothamBold
            PName.TextSize = 14
            PName.TextXAlignment = Enum.TextXAlignment.Left
            PName.Parent = PEntry

            local POpenBtn = Instance.new("TextButton")
            POpenBtn.Size = UDim2.new(0, 80, 0, 28)
            POpenBtn.Position = UDim2.new(1, -90, 0, 8)
            POpenBtn.BackgroundColor3 = Colors.TargetAccent
            POpenBtn.Text = "Open N_OS"
            POpenBtn.TextColor3 = Colors.Text
            POpenBtn.Font = Enum.Font.GothamBold
            POpenBtn.TextSize = 11
            POpenBtn.BorderSizePixel = 0
            POpenBtn.Parent = PEntry
            Instance.new("UICorner", POpenBtn).CornerRadius = UDim.new(0, 4)

            POpenBtn.MouseButton1Click:Connect(function()
                CreateTargetedPlayerWindow(plr)
            end)

            PEntry.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    CreateTargetedPlayerWindow(plr)
                end
            end)
        end
    end

    PlayerListScroll.CanvasSize = UDim2.new(0, 0, 0, playerCount * 49)
end

RefreshBtn.MouseButton1Click:Connect(RefreshPlayerList)
RefreshPlayerList()
Players.PlayerAdded:Connect(function() task.wait(0.3); RefreshPlayerList() end)
Players.PlayerRemoving:Connect(function() task.wait(0.1); RefreshPlayerList() end)

-- ============================================
-- PAGE 3: EXECUTOR
-- ============================================
local Page3 = Instance.new("Frame")
Page3.Size = UDim2.new(1, -20, 1, -20)
Page3.Position = UDim2.new(0, 10, 0, 10)
Page3.BackgroundTransparency = 1
Page3.Visible = false
Page3.Parent = PagesContainer
Page3.ZIndex = 1

local ExecTitle = Instance.new("TextLabel")
ExecTitle.Size = UDim2.new(1, 0, 0, 30)
ExecTitle.BackgroundTransparency = 1
ExecTitle.Text = "Script Executor"
ExecTitle.TextColor3 = Colors.Text
ExecTitle.Font = Enum.Font.GothamBold
ExecTitle.TextSize = 16
ExecTitle.TextXAlignment = Enum.TextXAlignment.Left
ExecTitle.Parent = Page3

local CodeInput = Instance.new("TextBox")
CodeInput.Size = UDim2.new(1, 0, 0, 240)
CodeInput.Position = UDim2.new(0, 0, 0, 35)
CodeInput.BackgroundColor3 = Colors.InputBg
CodeInput.Text = ""
CodeInput.TextColor3 = Colors.Text
CodeInput.Font = Enum.Font.Code
CodeInput.TextSize = 13
CodeInput.PlaceholderText = "-- Enter Lua code here..."
CodeInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
CodeInput.MultiLine = true
CodeInput.ClearTextOnFocus = false
CodeInput.TextXAlignment = Enum.TextXAlignment.Left
CodeInput.TextYAlignment = Enum.TextYAlignment.Top
CodeInput.BorderSizePixel = 0
CodeInput.Parent = Page3
Instance.new("UICorner", CodeInput).CornerRadius = UDim.new(0, 4)

local ExecuteBtn = Instance.new("TextButton")
ExecuteBtn.Size = UDim2.new(0, 120, 0, 35)
ExecuteBtn.Position = UDim2.new(0, 0, 0, 285)
ExecuteBtn.BackgroundColor3 = Colors.Accent
ExecuteBtn.Text = "Execute"
ExecuteBtn.TextColor3 = Colors.Text
ExecuteBtn.Font = Enum.Font.GothamBold
ExecuteBtn.TextSize = 14
ExecuteBtn.BorderSizePixel = 0
ExecuteBtn.Parent = Page3
Instance.new("UICorner", ExecuteBtn).CornerRadius = UDim.new(0, 4)

local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0, 120, 0, 35)
ClearBtn.Position = UDim2.new(0, 130, 0, 285)
ClearBtn.BackgroundColor3 = Colors.Close
ClearBtn.Text = "Clear"
ClearBtn.TextColor3 = Colors.Text
ClearBtn.Font = Enum.Font.GothamBold
ClearBtn.TextSize = 14
ClearBtn.BorderSizePixel = 0
ClearBtn.Parent = Page3
Instance.new("UICorner", ClearBtn).CornerRadius = UDim.new(0, 4)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0, 330)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextColor3 = Colors.Success
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = Page3

ExecuteBtn.MouseButton1Click:Connect(function()
    local code = CodeInput.Text
    if code ~= "" then
        local success, err = pcall(function()
            local func = loadstring(code)
            if func then func() end
        end)
        if success then
            StatusLabel.Text = "✓ Executed!"
            StatusLabel.TextColor3 = Colors.Success
        else
            StatusLabel.Text = "✗ " .. tostring(err)
            StatusLabel.TextColor3 = Colors.Close
        end
    end
end)
ClearBtn.MouseButton1Click:Connect(function() CodeInput.Text = ""; StatusLabel.Text = "" end)

-- ============================================
-- PAGE 4: LINK
-- ============================================
local Page4 = Instance.new("Frame")
Page4.Size = UDim2.new(1, -20, 1, -20)
Page4.Position = UDim2.new(0, 10, 0, 10)
Page4.BackgroundTransparency = 1
Page4.Visible = false
Page4.Parent = PagesContainer
Page4.ZIndex = 1

local LinkTitle = Instance.new("TextLabel")
LinkTitle.Size = UDim2.new(1, 0, 0, 30)
LinkTitle.BackgroundTransparency = 1
LinkTitle.Text = "N_OS Official Website"
LinkTitle.TextColor3 = Colors.Text
LinkTitle.Font = Enum.Font.GothamBold
LinkTitle.TextSize = 16
LinkTitle.TextXAlignment = Enum.TextXAlignment.Center
LinkTitle.Parent = Page4

local LinkFrame = Instance.new("Frame")
LinkFrame.Size = UDim2.new(1, -20, 0, 50)
LinkFrame.Position = UDim2.new(0, 10, 0, 50)
LinkFrame.BackgroundColor3 = Colors.Button
LinkFrame.BorderSizePixel = 0
LinkFrame.Parent = Page4
Instance.new("UICorner", LinkFrame).CornerRadius = UDim.new(0, 6)

local LinkText = Instance.new("TextLabel")
LinkText.Size = UDim2.new(1, -20, 1, 0)
LinkText.Position = UDim2.new(0, 10, 0, 0)
LinkText.BackgroundTransparency = 1
LinkText.Text = "https://n-os-official.netlify.app/"
LinkText.TextColor3 = Colors.Accent
LinkText.Font = Enum.Font.GothamMedium
LinkText.TextSize = 14
LinkText.TextXAlignment = Enum.TextXAlignment.Center
LinkText.Parent = LinkFrame

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0, 150, 0, 35)
CopyBtn.Position = UDim2.new(0.5, -75, 0, 120)
CopyBtn.BackgroundColor3 = Colors.Accent
CopyBtn.Text = "Copy Link"
CopyBtn.TextColor3 = Colors.Text
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextSize = 14
CopyBtn.BorderSizePixel = 0
CopyBtn.Parent = Page4
Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 4)

local CopyStatus = Instance.new("TextLabel")
CopyStatus.Size = UDim2.new(1, 0, 0, 25)
CopyStatus.Position = UDim2.new(0, 0, 0, 170)
CopyStatus.BackgroundTransparency = 1
CopyStatus.Text = "Click to copy"
CopyStatus.TextColor3 = Colors.Text
CopyStatus.Font = Enum.Font.GothamMedium
CopyStatus.TextSize = 12
CopyStatus.TextXAlignment = Enum.TextXAlignment.Center
CopyStatus.Parent = Page4

CopyBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard("https://n-os-official.netlify.app/") end)
    CopyStatus.Text = "✓ Copied!"; CopyStatus.TextColor3 = Colors.Success
    task.delay(2, function() CopyStatus.Text = "Click to copy"; CopyStatus.TextColor3 = Colors.Text end)
end)

-- ============================================
-- PAGE NAVIGATION (4 pages)
-- ============================================
local PageButtons = {}
local PageNames = {"Features", "Players", "Executor", "Link"}

for i = 1, 4 do
    local PageBtn = Instance.new("TextButton")
    PageBtn.Size = UDim2.new(1, -20, 0, 32)
    PageBtn.Position = UDim2.new(0, 10, 0, 10 + (i - 1) * 40)
    PageBtn.BackgroundColor3 = i == 1 and Colors.Accent or Colors.PageBtn
    PageBtn.Text = PageNames[i]
    PageBtn.TextColor3 = Colors.Text
    PageBtn.Font = Enum.Font.GothamMedium
    PageBtn.TextSize = 13
    PageBtn.BorderSizePixel = 0
    PageBtn.Parent = NavFrame
    Instance.new("UICorner", PageBtn).CornerRadius = UDim.new(0, 4)
    PageButtons[i] = PageBtn

    PageBtn.MouseButton1Click:Connect(function()
        Page1.Visible = (i == 1)
        Page2.Visible = (i == 2)
        Page3.Visible = (i == 3)
        Page4.Visible = (i == 4)
        for j = 1, 4 do
            PageButtons[j].BackgroundColor3 = (j == i) and Colors.Accent or Colors.PageBtn
        end
        if GlobalPlayerDropdown then GlobalPlayerDropdown:Destroy(); GlobalPlayerDropdown = nil end
        if i == 2 then RefreshPlayerList() end
    end)
end

-- ============================================
-- WINDOW CONTROLS
-- ============================================
local minimized = false
local originalSize = MainFrame.Size

MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 520, 0, 35)
        PagesContainer.Visible = false
        NavFrame.Visible = false
    else
        MainFrame.Size = originalSize
        PagesContainer.Visible = true
        NavFrame.Visible = true
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    cleanupSelfFly()
    removeSelfInvisible()
    noclipLoopRunning = false
    if infiniteJumpConnection then infiniteJumpConnection:Disconnect() end
    if godModeConnection then godModeConnection:Disconnect() end
    if antiAFKConnection then antiAFKConnection:Disconnect() end
    if selfInvisibleConn then selfInvisibleConn:Disconnect() end
    if autoLockConnection then autoLockConnection:Disconnect() end
    if brInvisConn then brInvisConn:Disconnect() end
    if GlobalPlayerDropdown then GlobalPlayerDropdown:Destroy() end
    if BrookhavenWindow then BrookhavenWindow:Destroy() end
    if BrainrotWindow then BrainrotWindow:Destroy() end
    for _, data in pairs(ActiveTargetedWindows) do
        pcall(function() data.CloseFunc() end)
    end
    ActiveTargetedWindows = {}
    ScreenGui:Destroy()
end)

-- Hover effects
local function AddHover(btn, defCol, hovCol)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = hovCol end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = defCol end)
end
for i = 1, 4 do
    AddHover(PageButtons[i], (i == 1) and Colors.Accent or Colors.PageBtn, Color3.fromRGB(80, 50, 200))
end
AddHover(MinimizeBtn, Colors.Minimize, Color3.fromRGB(255, 200, 60))
AddHover(CloseBtn, Colors.Close, Color3.fromRGB(255, 100, 100))
AddHover(ExecuteBtn, Colors.Accent, Color3.fromRGB(120, 80, 255))
AddHover(ClearBtn, Colors.Close, Color3.fromRGB(255, 100, 100))
AddHover(CopyBtn, Colors.Accent, Color3.fromRGB(120, 80, 255))
AddHover(RefreshBtn, Colors.Accent, Color3.fromRGB(120, 80, 255))

-- Respawn handler
Player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if flyEnabled then ToggleFly(true) end
    if noclipEnabled then ToggleNoClip(true) end
    if invisibleEnabled then applySelfInvisible() end

    local wsInput = SelfFeatures.WalkSpeed.valueInput
    if wsInput then
        local val = tonumber(wsInput.Text)
        if val then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = val end
        end
    end
    local jpInput = SelfFeatures.JumpPower.valueInput
    if jpInput then
        local val = tonumber(jpInput.Text)
        if val then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = val end
        end
    end
end)

-- ESP auto-apply for new players
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if SelfFeatures.ESP.state and not char:FindFirstChild("ESP_Highlight") then
            local hl = Instance.new("Highlight")
            hl.Name = "ESP_Highlight"
            hl.Adornee = char
            hl.FillColor = Color3.fromRGB(255, 0, 0)
            hl.OutlineColor = Color3.fromRGB(255, 0, 0)
            hl.FillTransparency = 0.5
            hl.Parent = char
        end
    end)
end)

print("[N_OS v3.2] Fully loaded!")
print("[N_OS v3.2] 4 Pages: Features | Players | Executor | Link")
print("[N_OS v3.2] Self Features: Fly, No-Clip, Invisible, ESP, Teleport, Kill, WalkSpeed, JumpPower, Inf Jump, FullBright, FPS Unlock")
print("[N_OS v3.2] Maps: Brookhaven, Steal a Brainrot (5 commands each)")
print("[N_OS v3.2] Targeted windows: 12 features per player")
print("[N_OS v3.2] Invisible: Self + Steal a Brainrot + targeted windows")
print("[N_OS v3.2] Kill = teleport under map (-2000Y + -5000Y) + health=0 + destroy head")
print("[N_OS v3.2] All FREE - no premium!")
