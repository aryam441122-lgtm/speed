--[[
    Luxy Hub - main.lua
    Modern iOS 26 inspired dark GUI for Roblox
    Features:
      - Floating, draggable window with smooth animations
      - Minimize to a draggable floating icon (re-open with a tap)
      - Speed toggle that reveals an animated slider (max 50)
      - Live updates to LocalPlayer WalkSpeed
--]]

-- Services
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")
local CoreGui           = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- Clean previous instance
if CoreGui:FindFirstChild("LuxyHub") then
    CoreGui.LuxyHub:Destroy()
end

------------------------------------------------------------
-- Theme (iOS 26 inspired dark)
------------------------------------------------------------
local Theme = {
    Background     = Color3.fromRGB(18, 18, 22),
    Surface        = Color3.fromRGB(28, 28, 33),
    SurfaceAlt     = Color3.fromRGB(38, 38, 44),
    Stroke         = Color3.fromRGB(55, 55, 62),
    Text           = Color3.fromRGB(240, 240, 245),
    SubText        = Color3.fromRGB(160, 160, 170),
    Accent         = Color3.fromRGB(0, 122, 255),   -- iOS blue
    AccentSoft     = Color3.fromRGB(10, 90, 200),
    ToggleOff      = Color3.fromRGB(60, 60, 67),
    Danger         = Color3.fromRGB(255, 69, 58),
}

local QUICK = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local SPRING = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local SMOOTH = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

------------------------------------------------------------
-- Helpers
------------------------------------------------------------
local function new(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    for _, c in ipairs(children or {}) do
        c.Parent = inst
    end
    return inst
end

local function corner(parent, r)
    return new("UICorner", { CornerRadius = UDim.new(0, r or 12), Parent = parent })
end

local function stroke(parent, color, thickness)
    return new("UIStroke", {
        Color = color or Theme.Stroke,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function padding(parent, p)
    return new("UIPadding", {
        PaddingTop = UDim.new(0, p), PaddingBottom = UDim.new(0, p),
        PaddingLeft = UDim.new(0, p), PaddingRight = UDim.new(0, p),
        Parent = parent,
    })
end

local function tween(inst, info, props)
    local t = TweenService:Create(inst, info, props)
    t:Play()
    return t
end

-- Universal drag (works for any GuiObject)
local function makeDraggable(grabFrame, moveFrame)
    moveFrame = moveFrame or grabFrame
    local dragging, dragStart, startPos
    grabFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = moveFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            moveFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

------------------------------------------------------------
-- Root ScreenGui
------------------------------------------------------------
local ScreenGui = new("ScreenGui", {
    Name = "LuxyHub",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    Parent = CoreGui,
})

------------------------------------------------------------
-- Main Window
------------------------------------------------------------
local Window = new("Frame", {
    Name = "Window",
    Size = UDim2.fromOffset(420, 320),
    Position = UDim2.new(0.5, -210, 0.5, -160),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    Parent = ScreenGui,
})
corner(Window, 18)
stroke(Window, Theme.Stroke, 1)

-- Subtle glow
new("ImageLabel", {
    Name = "Glow",
    BackgroundTransparency = 1,
    Image = "rbxassetid://5028857084",
    ImageColor3 = Theme.Accent,
    ImageTransparency = 0.85,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(24, 24, 276, 276),
    Size = UDim2.new(1, 40, 1, 40),
    Position = UDim2.new(0, -20, 0, -20),
    ZIndex = 0,
    Parent = Window,
})

-- Top bar
local TopBar = new("Frame", {
    Name = "TopBar",
    Size = UDim2.new(1, 0, 0, 44),
    BackgroundColor3 = Theme.Surface,
    BorderSizePixel = 0,
    Parent = Window,
})
corner(TopBar, 18)

-- Mask bottom corners of topbar
new("Frame", {
    Size = UDim2.new(1, 0, 0, 18),
    Position = UDim2.new(0, 0, 1, -18),
    BackgroundColor3 = Theme.Surface,
    BorderSizePixel = 0,
    Parent = TopBar,
})

local Title = new("TextLabel", {
    Name = "Title",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 18, 0, 0),
    Size = UDim2.new(1, -120, 1, 0),
    Font = Enum.Font.GothamBold,
    Text = "Luxy Hub",
    TextColor3 = Theme.Text,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TopBar,
})

local Subtitle = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 18, 0, 22),
    Size = UDim2.new(1, -120, 0, 14),
    Font = Enum.Font.Gotham,
    Text = "v1.0 • iOS Edition",
    TextColor3 = Theme.SubText,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TopBar,
})

-- Window control buttons (minimize / close)
local function makeCircleBtn(color, posX)
    local b = new("TextButton", {
        Size = UDim2.fromOffset(26, 26),
        Position = UDim2.new(1, posX, 0.5, -13),
        BackgroundColor3 = color,
        AutoButtonColor = false,
        Text = "",
        Parent = TopBar,
    })
    corner(b, 13)
    return b
end

local CloseBtn    = makeCircleBtn(Theme.Danger, -36)
local MinimizeBtn = makeCircleBtn(Color3.fromRGB(255, 159, 10), -70)

-- Content area
local Content = new("Frame", {
    Name = "Content",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 44),
    Size = UDim2.new(1, 0, 1, -44),
    Parent = Window,
})
padding(Content, 16)

local List = new("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    Parent = Content,
})
new("UIListLayout", {
    Padding = UDim.new(0, 12),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = List,
})

------------------------------------------------------------
-- Section: Movement
------------------------------------------------------------
local SectionLabel = new("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 18),
    Font = Enum.Font.GothamMedium,
    Text = "MOVEMENT",
    TextColor3 = Theme.SubText,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    LayoutOrder = 1,
    Parent = List,
})

------------------------------------------------------------
-- Toggle Card (Speed)  -- collapsible card containing slider
------------------------------------------------------------
local SpeedCard = new("Frame", {
    Name = "SpeedCard",
    BackgroundColor3 = Theme.Surface,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 56),
    ClipsDescendants = true,
    LayoutOrder = 2,
    Parent = List,
})
corner(SpeedCard, 14)
stroke(SpeedCard, Theme.Stroke, 1)

local Row = new("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 56),
    Parent = SpeedCard,
})

new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 16, 0, 0),
    Size = UDim2.new(1, -90, 0, 30),
    AnchorPoint = Vector2.new(0, 0),
    Font = Enum.Font.GothamMedium,
    Text = "Speed",
    TextColor3 = Theme.Text,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    Position = UDim2.new(0, 16, 0, 10),
    Parent = Row,
})

local Hint = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 16, 0, 30),
    Size = UDim2.new(1, -90, 0, 16),
    Font = Enum.Font.Gotham,
    Text = "Boost your walk speed",
    TextColor3 = Theme.SubText,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Row,
})

-- iOS toggle switch
local Switch = new("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -14, 0.5, 0),
    Size = UDim2.fromOffset(48, 28),
    BackgroundColor3 = Theme.ToggleOff,
    AutoButtonColor = false,
    Text = "",
    Parent = Row,
})
corner(Switch, 14)

local Knob = new("Frame", {
    Size = UDim2.fromOffset(24, 24),
    Position = UDim2.fromOffset(2, 2),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BorderSizePixel = 0,
    Parent = Switch,
})
corner(Knob, 12)

-- Slider area (hidden initially)
local SliderArea = new("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 56),
    Size = UDim2.new(1, 0, 0, 50),
    Parent = SpeedCard,
})

local ValueLabel = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -56, 0, 4),
    Size = UDim2.fromOffset(40, 18),
    Font = Enum.Font.GothamBold,
    Text = "16",
    TextColor3 = Theme.Text,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Right,
    Parent = SliderArea,
})

local SliderTrack = new("Frame", {
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 16, 0, 30),
    Size = UDim2.new(1, -32, 0, 6),
    BackgroundColor3 = Theme.SurfaceAlt,
    BorderSizePixel = 0,
    Parent = SliderArea,
})
corner(SliderTrack, 3)

local SliderFill = new("Frame", {
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0,
    Parent = SliderTrack,
})
corner(SliderFill, 3)

local SliderKnob = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0, 0, 0.5, 0),
    Size = UDim2.fromOffset(18, 18),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BorderSizePixel = 0,
    ZIndex = 2,
    Parent = SliderTrack,
})
corner(SliderKnob, 9)

------------------------------------------------------------
-- Speed State
------------------------------------------------------------
local DEFAULT_SPEED = 16
local MAX_SPEED     = 50
local MIN_SPEED     = 16

local speedEnabled  = false
local currentSpeed  = DEFAULT_SPEED

local function getHumanoid()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChildOfClass("Humanoid")
end

local function applySpeed()
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = speedEnabled and currentSpeed or DEFAULT_SPEED
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    applySpeed()
end)

local function setSliderValue(value, animated)
    value = math.clamp(math.floor(value + 0.5), MIN_SPEED, MAX_SPEED)
    currentSpeed = value
    ValueLabel.Text = tostring(value)
    local alpha = (value - MIN_SPEED) / (MAX_SPEED - MIN_SPEED)
    local info = animated and QUICK or TweenInfo.new(0)
    tween(SliderFill, info, { Size = UDim2.new(alpha, 0, 1, 0) })
    tween(SliderKnob, info, { Position = UDim2.new(alpha, 0, 0.5, 0) })
    if speedEnabled then applySpeed() end
end

setSliderValue(DEFAULT_SPEED, false)

-- Slider drag
local sliderDragging = false
local function updateSliderFromInput(input)
    local rel = (input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X
    rel = math.clamp(rel, 0, 1)
    setSliderValue(MIN_SPEED + rel * (MAX_SPEED - MIN_SPEED), true)
end

SliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
        updateSliderFromInput(input)
    end
end)
SliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        updateSliderFromInput(input)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)

------------------------------------------------------------
-- Toggle behavior (expand/collapse card)
------------------------------------------------------------
local COLLAPSED_H = 56
local EXPANDED_H  = 56 + 50

local function setSpeedEnabled(state)
    speedEnabled = state
    if state then
        tween(Switch, QUICK, { BackgroundColor3 = Theme.Accent })
        tween(Knob, SPRING, { Position = UDim2.fromOffset(22, 2) })
        tween(SpeedCard, SMOOTH, { Size = UDim2.new(1, 0, 0, EXPANDED_H) })
    else
        tween(Switch, QUICK, { BackgroundColor3 = Theme.ToggleOff })
        tween(Knob, SPRING, { Position = UDim2.fromOffset(2, 2) })
        tween(SpeedCard, SMOOTH, { Size = UDim2.new(1, 0, 0, COLLAPSED_H) })
    end
    applySpeed()
end

Switch.MouseButton1Click:Connect(function()
    setSpeedEnabled(not speedEnabled)
end)

------------------------------------------------------------
-- Footer credit
------------------------------------------------------------
new("TextLabel", {
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -8),
    Size = UDim2.new(1, -32, 0, 14),
    Font = Enum.Font.Gotham,
    Text = "Luxy Hub • Crafted with care",
    TextColor3 = Theme.SubText,
    TextSize = 10,
    Parent = Window,
})

------------------------------------------------------------
-- Floating Icon (shown when minimized)
------------------------------------------------------------
local FloatIcon = new("ImageButton", {
    Name = "FloatIcon",
    Size = UDim2.fromOffset(52, 52),
    Position = UDim2.new(0, 24, 0.5, -26),
    BackgroundColor3 = Theme.Surface,
    AutoButtonColor = false,
    Visible = false,
    Image = "",
    Parent = ScreenGui,
})
corner(FloatIcon, 26)
stroke(FloatIcon, Theme.Stroke, 1)

new("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    Font = Enum.Font.GothamBold,
    Text = "L",
    TextColor3 = Theme.Accent,
    TextSize = 24,
    Parent = FloatIcon,
})

-- Subtle pulsing ring
local Ring = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Parent = FloatIcon,
})
corner(Ring, 26)
local ringStroke = stroke(Ring, Theme.Accent, 2)
ringStroke.Transparency = 0.4

task.spawn(function()
    while ScreenGui.Parent do
        tween(Ring, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            { Size = UDim2.new(1.25, 0, 1.25, 0) })
        tween(ringStroke, TweenInfo.new(1.2), { Transparency = 1 })
        task.wait(1.2)
        Ring.Size = UDim2.new(1, 0, 1, 0)
        ringStroke.Transparency = 0.4
    end
end)

------------------------------------------------------------
-- Minimize / Restore / Close
------------------------------------------------------------
local function setWindowVisible(visible)
    if visible then
        Window.Visible = true
        Window.Size = UDim2.fromOffset(0, 0)
        Window.BackgroundTransparency = 1
        local targetSize = UDim2.fromOffset(420, 320)
        tween(Window, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Size = targetSize, BackgroundTransparency = 0 })
        FloatIcon.Visible = false
    else
        tween(Window, SMOOTH, { Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1 })
        task.delay(0.25, function()
            Window.Visible = false
            FloatIcon.Visible = true
            FloatIcon.Size = UDim2.fromOffset(0, 0)
            tween(FloatIcon, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { Size = UDim2.fromOffset(52, 52) })
        end)
    end
end

MinimizeBtn.MouseButton1Click:Connect(function()
    setWindowVisible(false)
end)

CloseBtn.MouseButton1Click:Connect(function()
    tween(Window, SMOOTH, { Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1 })
    task.delay(0.25, function()
        ScreenGui:Destroy()
    end)
end)

-- Tap on icon to restore (but not when dragged)
local iconPressStart
FloatIcon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        iconPressStart = { time = tick(), pos = input.Position }
    end
end)
FloatIcon.InputEnded:Connect(function(input)
    if iconPressStart and (input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch) then
        local dt = tick() - iconPressStart.time
        local delta = (input.Position - iconPressStart.pos).Magnitude
        if dt < 0.3 and delta < 6 then
            setWindowVisible(true)
        end
        iconPressStart = nil
    end
end)

------------------------------------------------------------
-- Dragging
------------------------------------------------------------
makeDraggable(TopBar, Window)
makeDraggable(FloatIcon, FloatIcon)

------------------------------------------------------------
-- Intro animation
------------------------------------------------------------
Window.Size = UDim2.fromOffset(0, 0)
Window.BackgroundTransparency = 1
tween(Window, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    { Size = UDim2.fromOffset(420, 320), BackgroundTransparency = 0 })

-- Keep speed applied on respawn
RunService.Heartbeat:Connect(function()
    if speedEnabled then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= currentSpeed then
            hum.WalkSpeed = currentSpeed
        end
    end
end)
