--[[
    Luxy Hub - main.lua
    Modern deep dark GUI for Roblox

    Features:
      - Floating, draggable window with smooth animations
      - Minimize to a draggable floating icon (tap to reopen)
      - Speed control (locked — in development)
      - Real Anti AFK with random in-place movement loop + manual Test
--]]


-- Services
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")
local CoreGui           = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Clean previous instance
if CoreGui:FindFirstChild("LuxyHub") then
    CoreGui.LuxyHub:Destroy()
end

------------------------------------------------------------
-- Theme (deep dark)
------------------------------------------------------------
local Theme = {
    Background     = Color3.fromRGB(10, 10, 13),
    BackgroundAlt  = Color3.fromRGB(14, 14, 18),
    Surface        = Color3.fromRGB(20, 20, 26),
    SurfaceAlt     = Color3.fromRGB(28, 28, 34),
    SurfaceHigh    = Color3.fromRGB(34, 34, 40),
    Stroke         = Color3.fromRGB(46, 46, 54),
    StrokeSoft     = Color3.fromRGB(34, 34, 42),
    Text           = Color3.fromRGB(245, 245, 250),
    SubText        = Color3.fromRGB(150, 150, 162),
    Muted          = Color3.fromRGB(96, 96, 108),
    Accent         = Color3.fromRGB(88, 132, 255),
    AccentSoft     = Color3.fromRGB(58, 96, 210),
    AccentDeep     = Color3.fromRGB(40, 70, 170),
    Success        = Color3.fromRGB(48, 209, 88),
    Warning        = Color3.fromRGB(255, 159, 10),
    Danger         = Color3.fromRGB(255, 69, 58),
    ToggleOff      = Color3.fromRGB(50, 50, 58),
    Disabled       = Color3.fromRGB(70, 70, 80),
}

local QUICK  = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local SPRING = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local SMOOTH = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

------------------------------------------------------------
-- Helpers
------------------------------------------------------------
local function new(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = inst end
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

local function padding(parent, t, r, b, l)
    r = r or t; b = b or t; l = l or t
    return new("UIPadding", {
        PaddingTop = UDim.new(0, t), PaddingBottom = UDim.new(0, b),
        PaddingLeft = UDim.new(0, l), PaddingRight = UDim.new(0, r),
        Parent = parent,
    })
end

local function tween(inst, info, props)
    local t = TweenService:Create(inst, info, props); t:Play(); return t
end

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
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
local WIN_W, WIN_H = 580, 460

local Window = new("Frame", {
    Name = "Window",
    Size = UDim2.fromOffset(WIN_W, WIN_H),
    Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    Parent = ScreenGui,
})
corner(Window, 26)
stroke(Window, Theme.Stroke, 1)

-- Soft glow
new("ImageLabel", {
    Name = "Glow",
    BackgroundTransparency = 1,
    Image = "rbxassetid://5028857084",
    ImageColor3 = Theme.Accent,
    ImageTransparency = 0.86,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(24, 24, 276, 276),
    Size = UDim2.new(1, 48, 1, 48),
    Position = UDim2.new(0, -24, 0, -24),
    ZIndex = 0,
    Parent = Window,
})

------------------------------------------------------------
-- Top Bar (taller, richer)
------------------------------------------------------------
local TopBar = new("Frame", {
    Name = "TopBar",
    Size = UDim2.new(1, 0, 0, 64),
    BackgroundColor3 = Theme.BackgroundAlt,
    BorderSizePixel = 0,
    Parent = Window,
})
corner(TopBar, 26)

-- mask bottom corners
new("Frame", {
    Size = UDim2.new(1, 0, 0, 28),
    Position = UDim2.new(0, 0, 1, -28),
    BackgroundColor3 = Theme.BackgroundAlt,
    BorderSizePixel = 0,
    Parent = TopBar,
})

-- bottom hairline
new("Frame", {
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = Theme.StrokeSoft,
    BorderSizePixel = 0,
    Parent = TopBar,
})

-- Brand badge (logo square)
local Brand = new("Frame", {
    Size = UDim2.fromOffset(36, 36),
    Position = UDim2.new(0, 16, 0.5, -18),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0,
    Parent = TopBar,
})
corner(Brand, 14)
new("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    Font = Enum.Font.GothamBold,
    Text = "L",
    TextColor3 = Color3.fromRGB(255,255,255),
    TextSize = 18,
    Parent = Brand,
})

local Title = new("TextLabel", {
    Name = "Title",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 62, 0, 12),
    Size = UDim2.new(1, -200, 0, 20),
    Font = Enum.Font.GothamBold,
    Text = "Luxy Hub",
    TextColor3 = Theme.Text,
    TextSize = 18,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TopBar,
})

local Subtitle = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 62, 0, 32),
    Size = UDim2.new(1, -200, 0, 16),
    Font = Enum.Font.Gotham,
    Text = "Premium Roblox Utility",
    TextColor3 = Theme.SubText,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TopBar,
})

-- Version pill
local VersionPill = new("Frame", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -96, 0.5, 0),
    Size = UDim2.fromOffset(70, 24),
    BackgroundColor3 = Theme.SurfaceAlt,
    BorderSizePixel = 0,
    Parent = TopBar,
})
corner(VersionPill, 14)
stroke(VersionPill, Theme.Stroke, 1)
new("Frame", {
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 8, 0.5, 0),
    Size = UDim2.fromOffset(6, 6),
    BackgroundColor3 = Theme.Success,
    BorderSizePixel = 0,
    Parent = VersionPill,
}, {}).Parent = VersionPill
local vDot = VersionPill:FindFirstChildOfClass("Frame")
if vDot then corner(vDot, 3) end
new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 20, 0, 0),
    Size = UDim2.new(1, -22, 1, 0),
    Font = Enum.Font.GothamMedium,
    Text = "v1.1",
    TextColor3 = Theme.Text,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = VersionPill,
})

-- Window control buttons
local function makeCircleBtn(color, posX, glyph)
    local b = new("TextButton", {
        Size = UDim2.fromOffset(22, 22),
        Position = UDim2.new(1, posX, 0.5, -11),
        BackgroundColor3 = color,
        AutoButtonColor = false,
        Text = glyph or "",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(0,0,0),
        TextTransparency = 0.4,
        Parent = TopBar,
    })
    corner(b, 11)
    return b
end

local CloseBtn    = makeCircleBtn(Theme.Danger, -28, "")
local MinimizeBtn = makeCircleBtn(Theme.Warning, -56, "")

------------------------------------------------------------
-- Content
------------------------------------------------------------
local Content = new("ScrollingFrame", {
    Name = "Content",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, 64),
    Size = UDim2.new(1, 0, 1, -92),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Theme.Stroke,
    Parent = Window,
})
padding(Content, 18)

local List = new("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    Parent = Content,
})
new("UIListLayout", {
    Padding = UDim.new(0, 14),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = List,
})

local function sectionLabel(text, order)
    return new("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = text,
        TextColor3 = Theme.Muted,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = order,
        Parent = List,
    })
end

------------------------------------------------------------
-- Generic Feature Card builder
------------------------------------------------------------
-- Returns { card, switch, knob, body, setEnabled(state, animated) }
local function makeFeatureCard(opts)
    local card = new("Frame", {
        Name = opts.name or "Card",
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 86),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = opts.order or 1,
        Parent = List,
    })
    corner(card, 20)
    stroke(card, Theme.StrokeSoft, 1)

    local header = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 86),
        Parent = card,
    })

    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0, 14),
        Size = UDim2.new(1, -150, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = opts.title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
    })

    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0, 38),
        Size = UDim2.new(1, -150, 0, 36),
        Font = Enum.Font.Gotham,
        Text = opts.description,
        TextColor3 = Theme.SubText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = header,
    })

    -- Status badge (top-right, above switch)
    local badge
    if opts.badge then
        badge = new("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -14, 0, 12),
            Size = UDim2.fromOffset(110, 18),
            BackgroundColor3 = opts.badgeColor or Theme.SurfaceHigh,
            BorderSizePixel = 0,
            Parent = header,
        })
        corner(badge, 12)
        new("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = opts.badge,
            TextColor3 = opts.badgeTextColor or Theme.Warning,
            TextSize = 9,
            Parent = badge,
        })
    end

    local switch, knob
    if not opts.noSwitch then
        switch = new("TextButton", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -14, 0, badge and 36 or 14),
            Size = UDim2.fromOffset(46, 26),
            BackgroundColor3 = opts.disabled and Theme.Disabled or Theme.ToggleOff,
            AutoButtonColor = false,
            Text = "",
            Active = not opts.disabled,
            Parent = header,
        })
        corner(switch, 13)
        knob = new("Frame", {
            Size = UDim2.fromOffset(22, 22),
            Position = UDim2.fromOffset(2, 2),
            BackgroundColor3 = Color3.fromRGB(220,220,225),
            BorderSizePixel = 0,
            Parent = switch,
        })
        corner(knob, 11)
    end

    return card, header, switch, knob
end

------------------------------------------------------------
-- MOVEMENT SECTION
------------------------------------------------------------
sectionLabel("MOVEMENT", 1)

-- Speed card (LOCKED — In Development)
local speedCard, speedHeader, speedSwitch, speedKnob = makeFeatureCard({
    name        = "SpeedCard",
    title       = "Speed",
    description = "Boost your walk speed in-game. Currently unavailable while we polish stability.",
    badge       = "IN DEVELOPMENT",
    badgeColor  = Color3.fromRGB(60, 45, 20),
    badgeTextColor = Theme.Warning,
    disabled    = true,
    order       = 2,
})

-- Disabled-look slider (visible but not interactive)
local sliderArea = new("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 86),
    Size = UDim2.new(1, 0, 0, 44),
    Parent = speedCard,
})
local sliderTrack = new("Frame", {
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 16, 0, 22),
    Size = UDim2.new(1, -76, 0, 6),
    BackgroundColor3 = Theme.SurfaceAlt,
    BorderSizePixel = 0,
    Parent = sliderArea,
})
corner(sliderTrack, 6)
local sliderFill = new("Frame", {
    Size = UDim2.new(0.35, 0, 1, 0),
    BackgroundColor3 = Theme.Disabled,
    BorderSizePixel = 0,
    Parent = sliderTrack,
})
corner(sliderFill, 6)
local sliderKnob = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.35, 0, 0.5, 0),
    Size = UDim2.fromOffset(16, 16),
    BackgroundColor3 = Color3.fromRGB(140,140,148),
    BorderSizePixel = 0,
    ZIndex = 2,
    Parent = sliderTrack,
})
corner(sliderKnob, 10)
new("TextLabel", {
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -16, 0, 22),
    Size = UDim2.fromOffset(44, 18),
    Font = Enum.Font.GothamBold,
    Text = "—",
    TextColor3 = Theme.Muted,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Right,
    Parent = sliderArea,
})
speedCard.Size = UDim2.new(1, 0, 0, 86 + 44 + 8)

-- Click-on-disabled feedback
speedSwitch.MouseButton1Click:Connect(function()
    tween(speedSwitch, QUICK, { BackgroundColor3 = Color3.fromRGB(90, 70, 30) })
    task.delay(0.2, function()
        tween(speedSwitch, QUICK, { BackgroundColor3 = Theme.Disabled })
    end)
end)

------------------------------------------------------------
-- AUTOMATION SECTION
------------------------------------------------------------
sectionLabel("AUTOMATION", 3)

local afkCard, afkHeader, afkSwitch, afkKnob = makeFeatureCard({
    name        = "AntiAfkCard",
    title       = "Real Anti AFK",
    description = "Smart idle watcher. After you stand still for ~17 minutes it smoothly walks 5 steps in a circle, spins around twice, and glides back to your exact spot.",
    order       = 4,
})

-- Test button row inside the card
local afkExtras = new("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 86),
    Size = UDim2.new(1, 0, 0, 52),
    Parent = afkCard,
})

local TestBtn = new("TextButton", {
    Position = UDim2.new(0, 16, 0, 8),
    Size = UDim2.new(0, 110, 0, 32),
    BackgroundColor3 = Theme.SurfaceHigh,
    AutoButtonColor = false,
    Text = "▶  Run Test",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = Theme.Text,
    Parent = afkExtras,
})
corner(TestBtn, 16)
stroke(TestBtn, Theme.Stroke, 1)

local StatusLabel = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 138, 0, 8),
    Size = UDim2.new(1, -156, 0, 32),
    Font = Enum.Font.Gotham,
    Text = "Idle",
    TextColor3 = Theme.SubText,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = afkExtras,
})

afkCard.Size = UDim2.new(1, 0, 0, 86 + 52 + 8)

------------------------------------------------------------
-- Footer (credits)
------------------------------------------------------------
local Footer = new("Frame", {
    Name = "Footer",
    Size = UDim2.new(1, 0, 0, 28),
    Position = UDim2.new(0, 0, 1, -28),
    BackgroundColor3 = Theme.BackgroundAlt,
    BorderSizePixel = 0,
    Parent = Window,
})
new("Frame", {
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = Theme.StrokeSoft,
    BorderSizePixel = 0,
    Parent = Footer,
})
-- mask top corners only matter at bottom; we keep simple
new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 16, 0, 0),
    Size = UDim2.new(0.5, -16, 1, 0),
    Font = Enum.Font.GothamMedium,
    Text = "Luxy Hub",
    TextColor3 = Theme.Text,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Footer,
})
new("TextLabel", {
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -16, 0, 0),
    Size = UDim2.new(0.5, -16, 1, 0),
    Font = Enum.Font.Gotham,
    Text = "© 2025 • Crafted by Luxy",
    TextColor3 = Theme.SubText,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Right,
    Parent = Footer,
})

------------------------------------------------------------
-- Floating Icon (minimized state)
------------------------------------------------------------
local FloatIcon = new("ImageButton", {
    Name = "FloatIcon",
    Size = UDim2.fromOffset(54, 54),
    Position = UDim2.new(0, 24, 0.5, -27),
    BackgroundColor3 = Theme.Surface,
    AutoButtonColor = false,
    Visible = false,
    Image = "",
    Parent = ScreenGui,
})
corner(FloatIcon, 27)
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

local Ring = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Parent = FloatIcon,
})
corner(Ring, 27)
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
        tween(Window, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Size = UDim2.fromOffset(WIN_W, WIN_H), BackgroundTransparency = 0 })
        FloatIcon.Visible = false
    else
        tween(Window, SMOOTH, { Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1 })
        task.delay(0.25, function()
            Window.Visible = false
            FloatIcon.Visible = true
            FloatIcon.Size = UDim2.fromOffset(0, 0)
            tween(FloatIcon, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { Size = UDim2.fromOffset(54, 54) })
        end)
    end
end

MinimizeBtn.MouseButton1Click:Connect(function() setWindowVisible(false) end)
CloseBtn.MouseButton1Click:Connect(function()
    tween(Window, SMOOTH, { Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1 })
    task.delay(0.25, function() ScreenGui:Destroy() end)
end)

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
        if dt < 0.3 and delta < 6 then setWindowVisible(true) end
        iconPressStart = nil
    end
end)

makeDraggable(TopBar, Window)
makeDraggable(FloatIcon, FloatIcon)

------------------------------------------------------------
-- Anti-AFK logic
------------------------------------------------------------
local IDLE_THRESHOLD = 17 * 60   -- 17 minutes of being stopped before auto-routine
local STOP_GRACE     = 30         -- wait 30s of stillness before the idle clock starts
local MOVE_EPSILON   = 2          -- studs: any movement > this resets the idle clock

local antiAfkEnabled = false
local isPerforming   = false      -- true while routine (auto or test) is running
local suppressMonitor = false     -- ignore position changes while routine runs
local stoppedSince   = nil        -- tick() when player first became still (nil = currently moving)
local lastPos        = nil

local function getCharacter()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hum and hrp and hum.Health > 0 then return char, hum, hrp end
    return nil
end

local function setStatus(text, color)
    StatusLabel.Text = text
    StatusLabel.TextColor3 = color or Theme.SubText
end

-- Smoothly tween HumanoidRootPart along a CFrame path
local function smoothMove(hrp, targetCFrame, duration, style)
    local info = TweenInfo.new(duration, style or Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local t = TweenService:Create(hrp, info, { CFrame = targetCFrame })
    t:Play()
    t.Completed:Wait()
end

-- Routine: 5 smooth steps around a small circle, 2 full spins in place,
-- then a smooth glide back to the exact starting CFrame.
local function performRoutine(isTest)
    local char, hum, hrp = getCharacter()
    if not hum or not hrp then
        setStatus("No character", Theme.Danger)
        return
    end
    if isPerforming then return end
    isPerforming    = true
    suppressMonitor = true
    setStatus(isTest and "Testing…" or "Auto-moving…", Theme.Accent)

    local startCFrame = hrp.CFrame
    local startPos    = startCFrame.Position
    local radius      = 5
    local stepTime    = 0.55

    -- Anchor for buttery, deterministic motion (no physics jitter)
    local wasAnchored = hrp.Anchored
    hrp.Anchored = true

    -- 5 smooth steps around a circle, facing direction of travel
    for i = 1, 5 do
        if not getCharacter() then break end
        local angle  = (i / 5) * math.pi * 2
        local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
        local target = startPos + offset
        local look   = target + Vector3.new(-math.sin(angle), 0, math.cos(angle))
        smoothMove(hrp, CFrame.new(target, look), stepTime, Enum.EasingStyle.Sine)
    end

    -- Two full spins in place (smooth)
    local spinDuration = 1.6
    local spinSteps    = 48
    local baseCFrame   = CFrame.new(startPos) * (startCFrame - startCFrame.Position)
    for s = 1, spinSteps do
        if not getCharacter() then break end
        local frac  = s / spinSteps
        local angle = frac * math.pi * 4 -- 2 full rotations
        local rot   = baseCFrame * CFrame.Angles(0, angle, 0)
        local info  = TweenInfo.new(spinDuration / spinSteps, Enum.EasingStyle.Linear)
        local tw = TweenService:Create(hrp, info, { CFrame = rot })
        tw:Play()
        tw.Completed:Wait()
    end

    -- Smooth glide back to the original CFrame (position + facing)
    smoothMove(hrp, startCFrame, 0.7, Enum.EasingStyle.Quint)

    -- Restore anchor state
    local _, _, hrpEnd = getCharacter()
    if hrpEnd then hrpEnd.Anchored = wasAnchored end

    task.wait(0.2)
    suppressMonitor = false
    isPerforming    = false
    stoppedSince    = tick()
    if hrpEnd then lastPos = hrpEnd.Position end

    if antiAfkEnabled then
        setStatus("AFK 00:00 / 17:00", Theme.Success)
    else
        setStatus("Idle", Theme.SubText)
    end
end

local function formatDuration(sec)
    sec = math.max(0, math.floor(sec))
    local m = math.floor(sec / 60)
    local s = sec % 60
    return string.format("%02d:%02d", m, s)
end

-- Monitor loop. Logic:
--   * If the player moves > MOVE_EPSILON studs, reset everything (no idle counting).
--   * Once the player is still, wait STOP_GRACE seconds before the idle clock starts.
--   * After STOP_GRACE, if they stay still for IDLE_THRESHOLD more seconds → run routine.
--   * Live-updates the status label with an AFK timer (mm:ss / 17:00).
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(1)
        if antiAfkEnabled and not suppressMonitor and not isPerforming then
            local _, _, hrp = getCharacter()
            if hrp then
                if lastPos == nil then
                    lastPos = hrp.Position
                    stoppedSince = tick()
                else
                    local moved = (hrp.Position - lastPos).Magnitude
                    if moved > MOVE_EPSILON then
                        -- Movement detected → reset everything to zero
                        lastPos      = hrp.Position
                        stoppedSince = nil
                        setStatus("Active — moving", Theme.Accent)
                    else
                        if stoppedSince == nil then
                            stoppedSince = tick()
                        end
                        local elapsed = tick() - stoppedSince
                        if elapsed >= (STOP_GRACE + IDLE_THRESHOLD) then
                            task.spawn(function() performRoutine(false) end)
                        elseif elapsed < STOP_GRACE then
                            local left = math.ceil(STOP_GRACE - elapsed)
                            setStatus("Settling… " .. left .. "s", Theme.SubText)
                        else
                            local afkTime = elapsed - STOP_GRACE
                            setStatus("AFK " .. formatDuration(afkTime) .. " / 17:00", Theme.Success)
                        end
                    end
                end
            end
        end
    end
end)

-- Toggle switch behavior
local function setAntiAfk(state)
    antiAfkEnabled = state
    if state then
        tween(afkSwitch, QUICK, { BackgroundColor3 = Theme.Accent })
        tween(afkKnob, SPRING, { Position = UDim2.fromOffset(22, 2) })
        stoppedSince = nil  -- start fresh: wait for player to stand still first
        local _, _, hrp = getCharacter()
        lastPos = hrp and hrp.Position or nil
        if not isPerforming then setStatus("AFK 00:00 / 17:00", Theme.Success) end
    else
        tween(afkSwitch, QUICK, { BackgroundColor3 = Theme.ToggleOff })
        tween(afkKnob, SPRING, { Position = UDim2.fromOffset(2, 2) })
        if not isPerforming then setStatus("Idle", Theme.SubText) end
    end
end

afkSwitch.MouseButton1Click:Connect(function()
    setAntiAfk(not antiAfkEnabled)
end)

TestBtn.MouseButton1Click:Connect(function()
    if isPerforming then return end
    tween(TestBtn, QUICK, { BackgroundColor3 = Theme.AccentDeep })
    task.delay(0.15, function() tween(TestBtn, QUICK, { BackgroundColor3 = Theme.SurfaceHigh }) end)
    task.spawn(function() performRoutine(true) end)
end)

------------------------------------------------------------
-- Intro animation
------------------------------------------------------------
Window.Size = UDim2.fromOffset(0, 0)
Window.BackgroundTransparency = 1
tween(Window, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    { Size = UDim2.fromOffset(WIN_W, WIN_H), BackgroundTransparency = 0 })
