--!nocheck
--[[
    ═══════════════════════════════════════════════════════════════════════════
                                  ZEN UI  v2.5.0
               A Fusion of Serotonin UI & LinoriaLib Aesthetics
    ═══════════════════════════════════════════════════════════════════════════
    Features:
      • Modern, polished Serotonin dark cyber aesthetic with glass & glow accents
      • LinoriaLib inline control attachments (Toggle:AddColorPicker & Toggle:AddKeybind)
      • LinoriaLib custom crosshair engine with complete geometry & motion controls
      • LinoriaLib active keybinds HUD & watermark banner with auto-FPS/ping
      • Multi-select dropdowns, sliders with prefix/suffix/rounding, dependency boxes
      • Built-in rich theme presets (Zen, Tokyo Night, Mint, Fatality, Cyberpunk, etc.)
      • 3D WorldModel preview mannequin mirroring live ESP targets
      • Native ESP system (Boxes, Fills, Tracers, Chams, Names, Distances, Healthbars)
      • Robust notification system with animated transitions & progress bars
      • Universal tooltips on hover across all controls
      • Universal JSON configuration & filesystem save/load support
    ═══════════════════════════════════════════════════════════════════════════
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Global / Protected GUI container
local function getGuiParent()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    local protect = (syn and syn.protect_gui) or protectgui
    if protect then
        local gui = Instance.new("Folder")
        pcall(protect, gui)
        gui.Parent = CoreGui
        return gui
    end
    local okCore, _ = pcall(function() return CoreGui.Name end)
    if okCore and CoreGui then
        return CoreGui
    end
    return LocalPlayer and LocalPlayer:WaitForChild("PlayerGui") or game:GetService("StarterGui")
end

local ZenUI = {
    Version = "2.5.0",
    Windows = {},
}

-- ─────────────────────────────────────────────────────────────────────────────
-- THEMES & PALETTES
-- ─────────────────────────────────────────────────────────────────────────────
local THEMES = {
    ["Zen"] = {
        Background = Color3.fromRGB(15, 18, 23),
        Panel      = Color3.fromRGB(19, 24, 31),
        Header     = Color3.fromRGB(16, 21, 27),
        Field      = Color3.fromRGB(26, 33, 43),
        Border     = Color3.fromRGB(40, 50, 64),
        BorderHover= Color3.fromRGB(58, 72, 92),
        Text       = Color3.fromRGB(232, 236, 241),
        Muted      = Color3.fromRGB(115, 126, 140),
        Accent     = Color3.fromRGB(20, 205, 185), -- Zen Cyan
        AccentDark = Color3.fromRGB(12, 140, 126),
        Hover      = Color3.fromRGB(29, 37, 48),
        Risk       = Color3.fromRGB(240, 78, 92),
        Success    = Color3.fromRGB(62, 208, 148),
    },
    ["Tokyo Night"] = {
        Background = Color3.fromRGB(18, 19, 29),
        Panel      = Color3.fromRGB(23, 24, 38),
        Header     = Color3.fromRGB(19, 20, 32),
        Field      = Color3.fromRGB(31, 33, 52),
        Border     = Color3.fromRGB(48, 50, 78),
        BorderHover= Color3.fromRGB(72, 75, 114),
        Text       = Color3.fromRGB(235, 237, 248),
        Muted      = Color3.fromRGB(120, 124, 160),
        Accent     = Color3.fromRGB(138, 118, 248), -- Neon Purple
        AccentDark = Color3.fromRGB(92, 75, 182),
        Hover      = Color3.fromRGB(35, 37, 59),
        Risk       = Color3.fromRGB(245, 82, 110),
        Success    = Color3.fromRGB(68, 214, 164),
    },
    ["Mint"] = {
        Background = Color3.fromRGB(16, 22, 20),
        Panel      = Color3.fromRGB(21, 29, 26),
        Header     = Color3.fromRGB(18, 25, 22),
        Field      = Color3.fromRGB(28, 40, 36),
        Border     = Color3.fromRGB(42, 60, 54),
        BorderHover= Color3.fromRGB(60, 88, 79),
        Text       = Color3.fromRGB(230, 242, 238),
        Muted      = Color3.fromRGB(112, 140, 131),
        Accent     = Color3.fromRGB(46, 213, 148), -- Emerald Mint
        AccentDark = Color3.fromRGB(30, 150, 103),
        Hover      = Color3.fromRGB(30, 44, 39),
        Risk       = Color3.fromRGB(245, 85, 95),
        Success    = Color3.fromRGB(46, 213, 148),
    },
    ["Fatality"] = {
        Background = Color3.fromRGB(22, 16, 28),
        Panel      = Color3.fromRGB(29, 20, 37),
        Header     = Color3.fromRGB(24, 17, 31),
        Field      = Color3.fromRGB(41, 28, 52),
        Border     = Color3.fromRGB(65, 44, 82),
        BorderHover= Color3.fromRGB(95, 62, 120),
        Text       = Color3.fromRGB(245, 235, 250),
        Muted      = Color3.fromRGB(145, 120, 160),
        Accent     = Color3.fromRGB(225, 25, 95), -- Fatality Crimson
        AccentDark = Color3.fromRGB(160, 15, 65),
        Hover      = Color3.fromRGB(45, 30, 58),
        Risk       = Color3.fromRGB(255, 60, 80),
        Success    = Color3.fromRGB(65, 215, 140),
    },
    ["Cyberpunk"] = {
        Background = Color3.fromRGB(17, 19, 22),
        Panel      = Color3.fromRGB(22, 25, 29),
        Header     = Color3.fromRGB(18, 21, 24),
        Field      = Color3.fromRGB(32, 36, 42),
        Border     = Color3.fromRGB(50, 56, 66),
        BorderHover= Color3.fromRGB(75, 84, 98),
        Text       = Color3.fromRGB(240, 242, 245),
        Muted      = Color3.fromRGB(130, 136, 145),
        Accent     = Color3.fromRGB(255, 185, 25), -- Cyber Amber
        AccentDark = Color3.fromRGB(190, 135, 15),
        Hover      = Color3.fromRGB(35, 40, 48),
        Risk       = Color3.fromRGB(250, 70, 80),
        Success    = Color3.fromRGB(70, 220, 130),
    },
    ["Obsidian"] = {
        Background = Color3.fromRGB(13, 13, 15),
        Panel      = Color3.fromRGB(18, 18, 21),
        Header     = Color3.fromRGB(15, 15, 17),
        Field      = Color3.fromRGB(25, 25, 30),
        Border     = Color3.fromRGB(38, 38, 46),
        BorderHover= Color3.fromRGB(58, 58, 70),
        Text       = Color3.fromRGB(235, 235, 240),
        Muted      = Color3.fromRGB(110, 110, 125),
        Accent     = Color3.fromRGB(215, 225, 240), -- Frost Ice
        AccentDark = Color3.fromRGB(140, 150, 165),
        Hover      = Color3.fromRGB(28, 28, 34),
        Risk       = Color3.fromRGB(245, 80, 90),
        Success    = Color3.fromRGB(75, 210, 150),
    },
    ["Linoria Blue"] = {
        Background = Color3.fromRGB(18, 20, 24),
        Panel      = Color3.fromRGB(24, 27, 33),
        Header     = Color3.fromRGB(20, 22, 27),
        Field      = Color3.fromRGB(32, 36, 45),
        Border     = Color3.fromRGB(48, 54, 68),
        BorderHover= Color3.fromRGB(70, 80, 100),
        Text       = Color3.fromRGB(235, 240, 245),
        Muted      = Color3.fromRGB(120, 130, 145),
        Accent     = Color3.fromRGB(35, 125, 255), -- Cobalt Blue
        AccentDark = Color3.fromRGB(22, 85, 185),
        Hover      = Color3.fromRGB(36, 42, 54),
        Risk       = Color3.fromRGB(245, 75, 85),
        Success    = Color3.fromRGB(65, 215, 140),
    },
}
ZenUI.Themes = THEMES

-- ─────────────────────────────────────────────────────────────────────────────
-- PRIMITIVE BUILDERS & UTILITIES
-- ─────────────────────────────────────────────────────────────────────────────
local function create(className, properties, parent)
    local object = Instance.new(className)
    for prop, val in pairs(properties or {}) do
        object[prop] = val
    end
    object.Parent = parent
    return object
end

local function frame(parent, name, position, size, color, border)
    return create("Frame", {
        Name = name,
        Position = position,
        Size = size,
        BackgroundColor3 = color,
        BorderSizePixel = border and 1 or 0,
        BorderColor3 = border or color,
        BorderMode = Enum.BorderMode.Inset,
    }, parent)
end

local function label(parent, name, text, position, size, color, textSize, font)
    return create("TextLabel", {
        Name = name,
        Text = text,
        Position = position,
        Size = size,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Font = font or Enum.Font.Arial,
        TextSize = textSize or 13,
        TextColor3 = color,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, parent)
end

local function button(parent, name, position, size)
    return create("TextButton", {
        Name = name,
        Position = position,
        Size = size,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, parent)
end

local function gradient(parent, top, bottom, rotation)
    return create("UIGradient", {
        Color = ColorSequence.new(top, bottom),
        Rotation = rotation or 90,
    }, parent)
end

local function stroke(parent, color, thickness)
    return create("UIStroke", {
        Color = color or Color3.fromRGB(40, 50, 64),
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        LineJoinMode = Enum.LineJoinMode.Miter,
    }, parent)
end

local function finite(val)
    return type(val) == "number" and val == val and math.abs(val) < math.huge
end

local function copyValue(val)
    if type(val) == "table" then
        local copy = {}
        for k, v in pairs(val) do
            copy[k] = copyValue(v)
        end
        return copy
    end
    return val
end

local function slug(text)
    return tostring(text or ""):gsub("[^%w_]", "")
end

local function formatNumber(val, decimals)
    if decimals and decimals > 0 then
        return string.format("%." .. decimals .. "f", val)
    else
        return tostring(math.round(val))
    end
end

-- Zen Emblem Generator (Cyber Circuit Mark)
local function drawMark(parent, color)
    local mark = frame(parent, "Mark", UDim2.fromOffset(6, 4), UDim2.fromOffset(16, 16), color)
    mark.BackgroundTransparency = 1
    local segments = {
        {7, 0, 2, 16}, {0, 7, 16, 2},
        {3, 3, 2, 2},  {11, 3, 2, 2},
        {3, 11, 2, 2}, {11, 11, 2, 2},
        {1, 5, 2, 6},  {13, 5, 2, 6},
        {5, 1, 6, 2},  {5, 13, 6, 2},
    }
    for _, rect in ipairs(segments) do
        frame(mark, "Pixel", UDim2.fromOffset(rect[1], rect[2]), UDim2.fromOffset(rect[3], rect[4]), color)
    end
    return mark
end

-- Checkerboard for Alpha Swatches
local function checker(parent)
    for y = 0, 3 do
        for x = 0, 3 do
            local cell = frame(parent, "Check", UDim2.fromScale(x / 4, y / 4), UDim2.fromScale(0.25, 0.25),
                (x + y) % 2 == 0 and Color3.fromRGB(190, 200, 205) or Color3.fromRGB(90, 105, 115))
            cell.ZIndex = parent.ZIndex
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- TOOLTIP ENGINE
-- ─────────────────────────────────────────────────────────────────────────────
local TooltipManager = {}
do
    TooltipManager.Card = nil
    TooltipManager.Text = nil
    TooltipManager.Target = nil
    TooltipManager.HoverTimer = 0
    TooltipManager.Visible = false

    function TooltipManager:Init(screenGui, theme)
        if self.Card then return end
        self.Card = frame(screenGui, "TooltipCard", UDim2.fromOffset(0, 0), UDim2.fromOffset(160, 26), theme.Panel, theme.Border)
        self.Card.Visible = false
        self.Card.ZIndex = 100
        stroke(self.Card, theme.Accent, 1)
        self.Text = label(self.Card, "Text", "", UDim2.fromOffset(8, 4), UDim2.new(1, -16, 1, -8), theme.Text, 11, Enum.Font.Arial)
        self.Text.TextWrapped = true
        self.Text.ZIndex = 101

        RunService.RenderStepped:Connect(function(dt)
            if self.Target and self.TargetText then
                self.HoverTimer += dt
                if self.HoverTimer >= 0.35 and not self.Visible then
                    self:Show()
                end
                if self.Visible then
                    self:UpdatePos()
                end
            else
                self.HoverTimer = 0
                if self.Visible then
                    self:Hide()
                end
            end
        end)
    end

    function TooltipManager:Attach(uiInstance, tipText)
        if not tipText or tipText == "" then return end
        uiInstance.MouseEnter:Connect(function()
            self.Target = uiInstance
            self.TargetText = tipText
            self.HoverTimer = 0
        end)
        uiInstance.MouseLeave:Connect(function()
            if self.Target == uiInstance then
                self.Target = nil
                self.TargetText = nil
                self:Hide()
            end
        end)
    end

    function TooltipManager:Show()
        if not self.Card or not self.TargetText then return end
        self.Visible = true
        self.Text.Text = self.TargetText
        -- Measure text bounds
        local textService = game:GetService("TextService")
        local size = textService:GetTextSize(self.TargetText, 11, Enum.Font.Arial, Vector2.new(240, 1000))
        self.Card.Size = UDim2.fromOffset(math.clamp(size.X + 16, 80, 260), size.Y + 12)
        self.Card.Visible = true
        self:UpdatePos()
    end

    function TooltipManager:UpdatePos()
        if not self.Card then return end
        local mousePos = UserInputService:GetMouseLocation()
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
        local cardW = self.Card.AbsoluteSize.X
        local cardH = self.Card.AbsoluteSize.Y
        local x = math.clamp(mousePos.X + 12, 10, viewport.X - cardW - 10)
        local y = math.clamp(mousePos.Y + 14, 10, viewport.Y - cardH - 10)
        self.Card.Position = UDim2.fromOffset(x, y)
    end

    function TooltipManager:Hide()
        self.Visible = false
        if self.Card then
            self.Card.Visible = false
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- CUSTOM CROSSHAIR ENGINE (Linoria Feature Reimagined)
-- ─────────────────────────────────────────────────────────────────────────────
local Crosshair = {}
Crosshair.__index = Crosshair

local CROSSHAIR_DEFAULTS = {
    Enabled          = false,
    Style            = "Cross", -- Cross, T-Shape, Dot, Circle, Box, Chevron
    Color            = Color3.fromRGB(20, 205, 185),
    Transparency     = 0,
    Rainbow          = false,
    Size             = 10,
    Thickness        = 2,
    Gap              = 5,
    CenterDot        = false,
    DotSize          = 2,
    DotColor         = Color3.fromRGB(20, 205, 185),
    Outline          = true,
    OutlineColor     = Color3.fromRGB(0, 0, 0),
    OutlineThickness = 1,
    Spin             = false,
    SpinSpeed        = 90, -- deg per sec
    FollowCursor     = false,
    DynamicGap       = false,
}

function Crosshair.new(parentGui, options)
    local self = setmetatable({}, Crosshair)
    self.Options = table.clone(CROSSHAIR_DEFAULTS)
    for k, v in pairs(options or {}) do
        if self.Options[k] ~= nil then self.Options[k] = v end
    end

    self.Gui = create("ScreenGui", {
        Name = "ZenCrosshairOverlay",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 9999,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, parentGui or getGuiParent())

    self.Root = create("Frame", {
        Name = "ReticleRoot",
        Size = UDim2.fromOffset(200, 200),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
    }, self.Gui)

    self.LinesContainer = create("Frame", {
        Name = "Lines",
        Size = UDim2.fromScale(1, 1),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        BackgroundTransparency = 1,
    }, self.Root)

    -- 4 Bar lines (Top, Bottom, Left, Right)
    self.Bars = {}
    for _, dir in ipairs({"Top", "Bottom", "Left", "Right"}) do
        local bar = create("Frame", {
            Name = dir,
            BackgroundColor3 = self.Options.Color,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5, 0.5),
        }, self.LinesContainer)
        local barStroke = create("UIStroke", {
            Name = "Stroke",
            Color = self.Options.OutlineColor,
            Thickness = self.Options.OutlineThickness,
            Enabled = self.Options.Outline,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }, bar)
        self.Bars[dir] = {Frame = bar, Stroke = barStroke}
    end

    -- Center Dot
    self.Dot = create("Frame", {
        Name = "CenterDot",
        BackgroundColor3 = self.Options.DotColor,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
    }, self.Root)
    self.DotStroke = create("UIStroke", {
        Name = "Stroke",
        Color = self.Options.OutlineColor,
        Thickness = self.Options.OutlineThickness,
        Enabled = self.Options.Outline,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, self.Dot)

    -- Circle reticle (for Circle style)
    self.Circle = create("Frame", {
        Name = "CircleReticle",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
    }, self.Root)
    self.CircleStroke = create("UIStroke", {
        Name = "Stroke",
        Color = self.Options.Color,
        Thickness = self.Options.Thickness,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, self.Circle)
    create("UICorner", {CornerRadius = UDim.new(1, 0)}, self.Circle)

    -- Box / Brackets reticle
    self.Box = create("Frame", {
        Name = "BoxReticle",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
    }, self.Root)
    self.BoxStroke = create("UIStroke", {
        Name = "Stroke",
        Color = self.Options.Color,
        Thickness = self.Options.Thickness,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, self.Box)

    self._spinAngle = 0
    self._rainbowHue = 0
    self._destroyed = false

    self._connection = RunService.RenderStepped:Connect(function(dt)
        self:_render(dt)
    end)

    self:_update()
    return self
end

function Crosshair:_render(dt)
    if self._destroyed or not self.Options.Enabled then
        self.Root.Visible = false
        return
    end

    self.Root.Visible = true
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)

    -- Positioning
    if self.Options.FollowCursor then
        local mousePos = UserInputService:GetMouseLocation()
        self.Root.Position = UDim2.fromOffset(mousePos.X, mousePos.Y)
    else
        self.Root.Position = UDim2.fromOffset(viewport.X / 2, viewport.Y / 2)
    end

    -- Color calculation
    local mainColor = self.Options.Color
    if self.Options.Rainbow then
        self._rainbowHue = (self._rainbowHue + dt * 0.25) % 1
        mainColor = Color3.fromHSV(self._rainbowHue, 0.85, 1)
    end

    -- Spin
    if self.Options.Spin then
        self._spinAngle = (self._spinAngle + dt * self.Options.SpinSpeed) % 360
        self.LinesContainer.Rotation = self._spinAngle
    else
        self.LinesContainer.Rotation = 0
    end

    -- Dynamic gap
    local currentGap = self.Options.Gap
    if self.Options.DynamicGap and LocalPlayer and LocalPlayer.Character then
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local speed = rootPart.AssemblyLinearVelocity.Magnitude
            currentGap = currentGap + math.clamp(speed * 0.35, 0, 20)
        end
    end

    local size = self.Options.Size
    local thickness = self.Options.Thickness
    local trans = self.Options.Transparency
    local outline = self.Options.Outline
    local outlineColor = self.Options.OutlineColor
    local outlineThick = self.Options.OutlineThickness

    -- Apply styling based on Style
    local style = self.Options.Style
    local isCross = style == "Cross"
    local isT = style == "T-Shape"
    local isDot = style == "Dot"
    local isCircle = style == "Circle"
    local isBox = style == "Box"
    local isChevron = style == "Chevron"

    -- Dot
    self.Dot.Visible = (self.Options.CenterDot or isDot)
    self.Dot.Size = UDim2.fromOffset(self.Options.DotSize, self.Options.DotSize)
    self.Dot.BackgroundColor3 = (isDot and mainColor or self.Options.DotColor)
    self.Dot.BackgroundTransparency = trans
    self.DotStroke.Enabled = outline
    self.DotStroke.Color = outlineColor
    self.DotStroke.Thickness = outlineThick

    -- Bars
    local showBars = isCross or isT or isChevron
    self.LinesContainer.Visible = showBars
    if showBars then
        -- Top
        local topBar = self.Bars["Top"]
        topBar.Frame.Visible = isCross
        if isCross then
            topBar.Frame.Size = UDim2.fromOffset(thickness, size)
            topBar.Frame.Position = UDim2.new(0.5, 0, 0.5, -(currentGap + size / 2))
            topBar.Frame.BackgroundColor3 = mainColor
            topBar.Frame.BackgroundTransparency = trans
            topBar.Stroke.Enabled = outline
            topBar.Stroke.Color = outlineColor
            topBar.Stroke.Thickness = outlineThick
        end

        -- Bottom
        local botBar = self.Bars["Bottom"]
        botBar.Frame.Visible = true
        botBar.Frame.Size = UDim2.fromOffset(thickness, size)
        botBar.Frame.Position = UDim2.new(0.5, 0, 0.5, (currentGap + size / 2))
        botBar.Frame.BackgroundColor3 = mainColor
        botBar.Frame.BackgroundTransparency = trans
        botBar.Stroke.Enabled = outline
        botBar.Stroke.Color = outlineColor
        botBar.Stroke.Thickness = outlineThick

        -- Left
        local leftBar = self.Bars["Left"]
        leftBar.Frame.Visible = true
        leftBar.Frame.Size = UDim2.fromOffset(size, thickness)
        leftBar.Frame.Position = UDim2.new(0.5, -(currentGap + size / 2), 0.5, 0)
        leftBar.Frame.BackgroundColor3 = mainColor
        leftBar.Frame.BackgroundTransparency = trans
        leftBar.Stroke.Enabled = outline
        leftBar.Stroke.Color = outlineColor
        leftBar.Stroke.Thickness = outlineThick

        -- Right
        local rightBar = self.Bars["Right"]
        rightBar.Frame.Visible = true
        rightBar.Frame.Size = UDim2.fromOffset(size, thickness)
        rightBar.Frame.Position = UDim2.new(0.5, (currentGap + size / 2), 0.5, 0)
        rightBar.Frame.BackgroundColor3 = mainColor
        rightBar.Frame.BackgroundTransparency = trans
        rightBar.Stroke.Enabled = outline
        rightBar.Stroke.Color = outlineColor
        rightBar.Stroke.Thickness = outlineThick
    end

    -- Circle Style
    self.Circle.Visible = isCircle
    if isCircle then
        local diam = (currentGap + size) * 2
        self.Circle.Size = UDim2.fromOffset(diam, diam)
        self.CircleStroke.Color = mainColor
        self.CircleStroke.Thickness = thickness
        self.CircleStroke.Transparency = trans
    end

    -- Box Style
    self.Box.Visible = isBox
    if isBox then
        local diam = (currentGap + size) * 2
        self.Box.Size = UDim2.fromOffset(diam, diam)
        self.BoxStroke.Color = mainColor
        self.BoxStroke.Thickness = thickness
        self.BoxStroke.Transparency = trans
    end
end

function Crosshair:_update()
    -- triggers internal update
end

function Crosshair:SetOptions(changes)
    for k, v in pairs(changes or {}) do
        if self.Options[k] ~= nil then
            self.Options[k] = v
        end
    end
    return self
end

function Crosshair:SetEnabled(enabled)
    self.Options.Enabled = enabled == true
    return self
end

function Crosshair:Destroy()
    if self._destroyed then return end
    self._destroyed = true
    if self._connection then
        self._connection:Disconnect()
        self._connection = nil
    end
    if self.Gui then
        self.Gui:Destroy()
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- WATERMARK BANNER (Linoria Style with Auto-Stats)
-- ─────────────────────────────────────────────────────────────────────────────
local Watermark = {}
Watermark.__index = Watermark

function Watermark.new(screenGui, theme)
    local self = setmetatable({}, Watermark)
    self.Visible = true
    self.AutoStats = true
    self.CustomText = "zen ui"

    self.Frame = frame(screenGui, "WatermarkBanner", UDim2.fromOffset(16, 16), UDim2.fromOffset(260, 26), theme.Panel, theme.Border)
    self.Frame.ZIndex = 50
    self.Frame.Active = true

    -- Top Accent Edge
    self.Accent = frame(self.Frame, "Accent", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 1), theme.Accent)
    self.Accent.ZIndex = 51

    -- Emblem Mark
    local mark = drawMark(self.Frame, theme.Accent)
    mark.Position = UDim2.fromOffset(6, 5)
    mark.ZIndex = 52

    self.Label = label(self.Frame, "Text", "zen ui | 60 fps | 20 ms", UDim2.fromOffset(28, 0), UDim2.new(1, -34, 1, 0), theme.Text, 11, Enum.Font.Code)
    self.Label.ZIndex = 52

    -- Drag support for watermark
    local dragging, dragStart, startPos
    self.Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.Frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            self.Frame.Position = UDim2.fromOffset(startPos.X.Offset + delta.X, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Auto-updater
    local fpsCount = 0
    local lastTick = tick()
    local currentFps = 60
    self._connection = RunService.RenderStepped:Connect(function()
        fpsCount += 1
        local now = tick()
        if now - lastTick >= 0.5 then
            currentFps = math.round(fpsCount / (now - lastTick))
            fpsCount = 0
            lastTick = now

            if self.Visible and self.AutoStats then
                local ping = 15
                local stat = game:GetService("Stats")
                if stat and stat.Network and stat.Network.ServerStatsItem and stat.Network.ServerStatsItem["Data Ping"] then
                    ping = math.round(stat.Network.ServerStatsItem["Data Ping"]:GetValue())
                end
                self.Label.Text = string.format("%s | %d fps | %d ms", self.CustomText, currentFps, ping)
                -- Auto-resize
                local textWidth = self.Label.TextBounds.X
                self.Frame.Size = UDim2.fromOffset(textWidth + 42, 26)
            end
        end
    end)

    return self
end

function Watermark:SetText(text)
    self.CustomText = tostring(text or "zen ui")
    self.Label.Text = self.CustomText
    local textWidth = self.Label.TextBounds.X
    self.Frame.Size = UDim2.fromOffset(textWidth + 42, 26)
end

function Watermark:SetVisibility(visible)
    self.Visible = visible == true
    self.Frame.Visible = self.Visible
end

function Watermark:SetAccent(color)
    self.Accent.BackgroundColor3 = color
    for _, child in ipairs(self.Frame:GetDescendants()) do
        if child.Name == "Pixel" then
            child.BackgroundColor3 = color
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- ACTIVE KEYBINDS HUD (Linoria Style Floating Overlay)
-- ─────────────────────────────────────────────────────────────────────────────
local KeybindList = {}
KeybindList.__index = KeybindList

function KeybindList.new(screenGui, theme)
    local self = setmetatable({}, KeybindList)
    self.Entries = {}
    self.Visible = false

    self.Frame = frame(screenGui, "KeybindsHUD", UDim2.new(1, -210, 0, 180), UDim2.fromOffset(190, 120), theme.Panel, theme.Border)
    self.Frame.ZIndex = 60
    self.Frame.Active = true
    self.Frame.Visible = false

    -- Header
    local header = frame(self.Frame, "Header", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 22), theme.Header)
    header.ZIndex = 61
    self.Accent = frame(header, "Accent", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 1), theme.Accent)
    self.Accent.ZIndex = 62

    local title = label(header, "Title", "Keybinds", UDim2.fromOffset(8, 0), UDim2.new(1, -16, 1, 0), theme.Text, 11, Enum.Font.Code)
    title.ZIndex = 62

    self.Content = create("ScrollingFrame", {
        Name = "List",
        Position = UDim2.fromOffset(6, 26),
        Size = UDim2.new(1, -12, 1, -30),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        ZIndex = 61,
    }, self.Frame)
    create("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, self.Content)

    -- Dragging
    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.Frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            self.Frame.Position = UDim2.fromOffset(startPos.X.Offset + delta.X, startPos.Y.Offset + delta.Y)
        end
    end)

    return self
end

function KeybindList:UpdateEntry(id, name, keyName, mode, active)
    local entry = self.Entries[id]
    if not entry then
        local row = create("Frame", {
            Name = slug(id),
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            ZIndex = 62,
        }, self.Content)
        local nameLabel = label(row, "Name", name, UDim2.fromOffset(0, 0), UDim2.new(0.65, 0, 1, 0), Color3.fromRGB(215, 220, 225), 11, Enum.Font.Arial)
        nameLabel.ZIndex = 63
        local stateLabel = label(row, "State", "[" .. keyName .. "]", UDim2.new(0.65, 0, 0, 0), UDim2.new(0.35, 0, 1, 0), Color3.fromRGB(130, 140, 150), 10, Enum.Font.Code)
        stateLabel.TextXAlignment = Enum.TextXAlignment.Right
        stateLabel.ZIndex = 63

        entry = {Row = row, NameLabel = nameLabel, StateLabel = stateLabel}
        self.Entries[id] = entry
    end

    local statusText = "[" .. tostring(keyName) .. "]"
    if mode == "Toggle" then
        statusText = "[" .. tostring(keyName) .. "] " .. (active and "ON" or "OFF")
    elseif mode == "Hold" then
        statusText = "[" .. tostring(keyName) .. "] " .. (active and "HOLD" or "IDLE")
    elseif mode == "Always" then
        statusText = "[ALWAYS]"
    end

    entry.NameLabel.Text = name
    entry.StateLabel.Text = statusText
    entry.StateLabel.TextColor3 = active and Color3.fromRGB(20, 205, 185) or Color3.fromRGB(120, 130, 140)

    -- Update overall frame height
    local count = 0
    for _ in pairs(self.Entries) do count += 1 end
    self.Frame.Size = UDim2.fromOffset(190, math.clamp(32 + count * 22, 54, 300))
end

function KeybindList:RemoveEntry(id)
    if self.Entries[id] then
        self.Entries[id].Row:Destroy()
        self.Entries[id] = nil
        local count = 0
        for _ in pairs(self.Entries) do count += 1 end
        self.Frame.Size = UDim2.fromOffset(190, math.clamp(32 + count * 22, 54, 300))
    end
end

function KeybindList:SetVisibility(visible)
    self.Visible = visible == true
    self.Frame.Visible = self.Visible
end

function KeybindList:SetAccent(color)
    self.Accent.BackgroundColor3 = color
end

-- ─────────────────────────────────────────────────────────────────────────────
-- NOTIFICATIONS SYSTEM
-- ─────────────────────────────────────────────────────────────────────────────
local NOTICE_TYPES = {
    Info    = {"i", Color3.fromRGB(85, 195, 230)},
    Success = {"+", Color3.fromRGB(60, 210, 150)},
    Warning = {"!", Color3.fromRGB(240, 185, 80)},
    Error   = {"x", Color3.fromRGB(240, 95, 110)},
}

-- ─────────────────────────────────────────────────────────────────────────────
-- WINDOW CLASS
-- ─────────────────────────────────────────────────────────────────────────────
local Window = {}
local Tab = {}
local Section = {}
local ESP = {}
ESP.__index = ESP
Window.__index = Window
Tab.__index = Tab
Section.__index = Section

function Window:_connect(signal, callback)
    local conn = signal:Connect(callback)
    table.insert(self._connections, conn)
    return conn
end

function Window:_accent(object, property)
    object[property] = self.Theme.Accent
    table.insert(self._accentBindings, {object, property})
end

function Window:_callback(cb, ...)
    if cb then
        local ok, err = pcall(cb, ...)
        if not ok then
            warn("[Zen UI] Callback error: " .. tostring(err))
        end
    end
end

function Window:_register(control, options, kind, validate, draw)
    local flag = options.Flag
    assert(not flag or (type(flag) == "string" and flag ~= ""), "Flag must be a non-empty string")
    assert(not flag or not self.Controls[flag], "Duplicate flag: " .. tostring(flag))

    control.Kind = kind
    control.Flag = flag
    control.Disabled = options.Disabled == true
    control.Tooltip = options.Tooltip
    control._window = self
    control._validate = validate
    control._listeners = {}
    control._draw = draw

    function control:GetValue()
        return copyValue(self.Value)
    end

    function control:SetValue(val, silent)
        assert(not self._window._destroyed, "Window has been destroyed")
        local valid, normalized = self._validate(val)
        assert(valid, "Invalid " .. self.Kind .. " value for " .. tostring(self.Flag or options.Text))
        self.Value = copyValue(normalized)
        if self.Flag then
            self._window.Flags[self.Flag] = copyValue(normalized)
        end
        self._draw(self)
        if not silent then
            self._window:_callback(options.Callback, self:GetValue())
            for _, listener in ipairs(self._listeners) do
                self._window:_callback(listener, self:GetValue())
            end
        end
        return self
    end

    function control:SetDisabled(disabled)
        self.Disabled = disabled == true
        if self.Disabled and self._window._capturing == self then
            self._window:_cancelCapture()
        end
        self._draw(self)
        return self
    end

    function control:OnChanged(listener)
        assert(type(listener) == "function", "OnChanged expects a function")
        table.insert(self._listeners, listener)
        return self
    end

    function control:AddTooltip(text)
        self.Tooltip = text
        if self.Instance then
            TooltipManager:Attach(self.Instance, text)
        end
        return self
    end

    control:SetValue(options.Default, true)
    control.Default = control:GetValue()
    table.insert(self._controls, control)
    if flag then
        self.Controls[flag] = control
    end

    if control.Tooltip and control.Instance then
        TooltipManager:Attach(control.Instance, control.Tooltip)
    end

    return control
end

function Window:_closePopup()
    if self._popup then self._pointer = nil end
    if self._popupCleanup then
        self._popupCleanup()
        self._popupCleanup = nil
    end
    if self._popup then
        self._popup:Destroy()
        self._popup = nil
    end
    self.PopupLayer.Visible = false
end

function Window:_cancelCapture()
    if self._capturing then
        self._capturing._draw(self._capturing)
    end
    self._capturing = nil
end

function Window:_openPopup(anchor, width, height)
    self:_closePopup()
    self:_cancelCapture()
    local scale = self.Scale.Scale
    local origin = self.Root.AbsolutePosition
    local pos = (anchor.AbsolutePosition - origin) / scale
    local anchorSize = anchor.AbsoluteSize / scale
    local x = math.clamp(pos.X, 4, self.Width - width - 4)
    local y = pos.Y + anchorSize.Y + 4
    if y + height > self.Height - 4 then
        y = math.max(4, pos.Y - height - 4)
    end

    self.PopupLayer.Visible = true
    local pop = frame(self.PopupLayer, "Popup", UDim2.fromOffset(x, y), UDim2.fromOffset(width, height), self.Theme.Panel, self.Theme.Border)
    pop.ZIndex = 35
    stroke(pop, self.Theme.BorderHover, 1)
    self._popup = pop

    local edge = frame(pop, "Accent", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 1), self.Theme.Accent)
    edge.ZIndex = 36
    self:_accent(edge, "BackgroundColor3")
    return pop
end

function Window:_beginPointer(input, update)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end
    self._pointer = {Input = input, Update = update, Touch = input.UserInputType == Enum.UserInputType.Touch}
    update(Vector2.new(input.Position.X, input.Position.Y))
end

function Window:_layout(center)
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    if viewport.X < 1 or viewport.Y < 1 then return end
    local insetTop, insetBottom = GuiService:GetGuiInset()
    local margin = 12
    local availH = viewport.Y - insetTop.Y - insetBottom.Y - margin * 2
    local scale = math.max(0.1, math.min(self.RequestedScale, (viewport.X - margin * 2) / self.Width, availH / self.Height))
    self.Scale.Scale = scale

    local size = Vector2.new(self.Width * scale, self.Height * scale)
    local x = self.Root.Position.X.Offset
    local y = self.Root.Position.Y.Offset
    if center then
        x = (viewport.X - size.X) / 2
        y = insetTop.Y + (viewport.Y - insetTop.Y - insetBottom.Y - size.Y) / 2
    end
    x = math.clamp(x, margin, math.max(margin, viewport.X - size.X - margin))
    y = math.clamp(y, insetTop.Y + margin, math.max(insetTop.Y + margin, viewport.Y - insetBottom.Y - size.Y - margin))
    self.Root.Position = UDim2.fromOffset(math.floor(x + 0.5), math.floor(y + 0.5))
    self:_closePopup()
end

function Window:SetScale(val)
    assert(finite(val) and val >= 0.5 and val <= 2, "Scale must be between 0.5 and 2")
    self.RequestedScale = val
    self:_layout(true)
end

function Window:SetAccent(color)
    assert(typeof(color) == "Color3", "Accent must be a Color3")
    self.Theme.Accent = color
    for i = #self._accentBindings, 1, -1 do
        local b = self._accentBindings[i]
        if b[1].Parent then
            b[1][b[2]] = color
        else
            table.remove(self._accentBindings, i)
        end
    end
    if self.Watermark then self.Watermark:SetAccent(color) end
    if self.KeybindsHUD then self.KeybindsHUD:SetAccent(color) end
end

function Window:ApplyTheme(themeOrName)
    local theme = type(themeOrName) == "string" and THEMES[themeOrName] or themeOrName
    if not theme then return end
    for k, v in pairs(theme) do
        if self.Theme[k] and typeof(v) == "Color3" then
            self.Theme[k] = v
        end
    end
    self:SetAccent(self.Theme.Accent)
    self.Main.BackgroundColor3 = self.Theme.Background
    self.Main.BorderColor3 = self.Theme.Border
    self.Body.BackgroundColor3 = self.Theme.Panel
    self.Body.BorderColor3 = self.Theme.Border
end

function Window:SetVisible(vis)
    self.Gui.Enabled = vis == true
    self:_closePopup()
    self._pointer = nil
    self:_cancelCapture()
end

function Window:SetToggleKey(key)
    assert(typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode and key ~= Enum.KeyCode.Unknown, "Toggle key must be a valid KeyCode")
    self.ToggleKey = key
end

function Window:SetPreviewVisible(vis)
    assert(self.Preview, "Enable Features.Preview when creating the window")
    self.Preview.Panel.Visible = vis == true
    self.Width = self.MainWidth + (vis and 360 or 0)
    self.Root.Size = UDim2.fromOffset(self.Width, self.Height)
    self:_layout(true)
end

function Window:SetWatermark(text)
    if self.Watermark then
        self.Watermark:SetText(text)
    end
end

function Window:SetWatermarkVisibility(vis)
    if self.Watermark then
        self.Watermark:SetVisibility(vis)
    end
end

function Window:SetKeybindsVisibility(vis)
    if self.KeybindsHUD then
        self.KeybindsHUD:SetVisibility(vis)
    end
end

function Window:CreateCrosshair(opts)
    local reticle = Crosshair.new(self.Gui, opts)
    table.insert(self._crosshairs, reticle)
    return reticle
end

function Window:OnDestroy(cb)
    assert(not self._destroyed and type(cb) == "function", "OnDestroy expects a function")
    table.insert(self._destroyCallbacks, cb)
    return self
end

function Window:SelectTab(name)
    local selected = type(name) == "table" and name or self.Tabs[name]
    assert(selected and self.Tabs[selected.Name] == selected, "Unknown tab: " .. tostring(name))
    self:_closePopup()
    self._pointer = nil
    self:_cancelCapture()
    self.ActiveTab = selected.Name
    self.Gui:SetAttribute("ActiveTab", selected.Name)

    for _, tab in ipairs(self._tabs) do
        local active = tab == selected
        tab.Page.Visible = active
        tab.Line.Visible = active
        tab.Glow.Visible = active
        tab.Seam.Visible = active
        tab.Caption.TextColor3 = active and self.Theme.Text or self.Theme.Muted
        tab.Button.BackgroundColor3 = active and self.Theme.Panel or self.Theme.Background
    end
end

-- Export Config (Serotonin + Linoria compatible)
function Window:ExportConfig()
    local values = {}
    for flag, control in pairs(self.Controls) do
        if control.Kind == "Color" then
            local v = control.Value
            values[flag] = {Color = {v.Color.R, v.Color.G, v.Color.B}, Transparency = v.Transparency}
        elseif control.Kind == "Keybind" then
            values[flag] = {Key = control.Value.Name, Mode = control.Mode}
        else
            values[flag] = control:GetValue()
        end
    end
    return HttpService:JSONEncode({Version = 2, Values = values})
end

function Window:ImportConfig(json)
    local ok, data = pcall(HttpService.JSONDecode, HttpService, json)
    if not ok or type(data) ~= "table" or type(data.Values) ~= "table" then
        return false, "Invalid JSON configuration format."
    end
    local pending = {}
    for flag, val in pairs(data.Values) do
        local control = self.Controls[flag]
        if control then
            local decoded = val
            if control.Kind == "Color" then
                if type(val) == "table" and type(val.Color) == "table" then
                    local rgb = val.Color
                    decoded = {Color = Color3.new(rgb[1], rgb[2], rgb[3]), Transparency = val.Transparency or 0}
                end
            elseif control.Kind == "Keybind" then
                if type(val) == "table" and val.Key then
                    local f, k = pcall(function() return Enum.KeyCode[val.Key] end)
                    if f then decoded = k end
                    if val.Mode then control.Mode = val.Mode end
                elseif type(val) == "string" then
                    local f, k = pcall(function() return Enum.KeyCode[val] end)
                    if f then decoded = k end
                end
            end
            local valid, norm = control._validate(decoded)
            if valid then
                table.insert(pending, {control, norm})
            end
        end
    end
    for _, item in ipairs(pending) do item[1]:SetValue(item[2], true) end
    for _, item in ipairs(pending) do item[1]:SetValue(item[2]) end
    return true
end

function Window:ResetConfig()
    for _, control in ipairs(self._controls) do
        control:SetValue(control.Default, true)
    end
    for _, control in ipairs(self._controls) do
        control:SetValue(control.Default)
    end
end

-- Filesystem Config Manager for Executors
local function getConfigFolder()
    local folder = "ZenUISettings"
    if makefolder and isfolder and not isfolder(folder) then
        pcall(makefolder, folder)
    end
    return folder
end

function Window:SaveConfig(name)
    assert(type(name) == "string" and name ~= "", "Config name required")
    if not writefile then
        return false, "writefile not supported in this environment"
    end
    local folder = getConfigFolder()
    local path = folder .. "/" .. slug(name) .. ".json"
    local data = self:ExportConfig()
    local ok, err = pcall(writefile, path, data)
    return ok, err or path
end

function Window:LoadConfig(name)
    assert(type(name) == "string" and name ~= "", "Config name required")
    if not readfile then
        return false, "readfile not supported in this environment"
    end
    local folder = getConfigFolder()
    local path = folder .. "/" .. slug(name) .. ".json"
    local ok, content = pcall(readfile, path)
    if not ok then return false, "Config file not found" end
    return self:ImportConfig(content)
end

function Window:GetConfigs()
    if not listfiles then return {} end
    local folder = getConfigFolder()
    local files = {}
    local ok, list = pcall(listfiles, folder)
    if ok and type(list) == "table" then
        for _, f in ipairs(list) do
            local clean = f:match("([^/\\]+)%.json$")
            if clean then table.insert(files, clean) end
        end
    end
    return files
end

function Window:Destroy()
    if self._destroyed then return end
    self._destroyed = true
    self:_closePopup()
    self._pointer = nil
    self:_cancelCapture()

    for _, ctrl in ipairs(table.clone(self._espControllers)) do ctrl:Destroy() end
    for _, cross in ipairs(table.clone(self._crosshairs)) do cross:Destroy() end

    if self._noticeConnection then
        self._noticeConnection:Disconnect()
        self._noticeConnection = nil
    end
    for _, n in ipairs(self._notices) do
        n.Closed = true
        if n.Instance then n.Instance:Destroy() end
    end
    table.clear(self._notices)
    if self.NotificationGui then self.NotificationGui:Destroy() end

    for _, cb in ipairs(self._destroyCallbacks) do self:_callback(cb) end
    table.clear(self._destroyCallbacks)
    for _, conn in ipairs(self._connections) do conn:Disconnect() end
    table.clear(self._connections)
    if self._cameraConnection then self._cameraConnection:Disconnect() end
    if self.Gui.Parent and not self._destroyingGui then self.Gui:Destroy() end
    table.clear(self._accentBindings)

    local idx = table.find(ZenUI.Windows, self)
    if idx then table.remove(ZenUI.Windows, idx) end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- NOTIFICATIONS IMPLEMENTATION
-- ─────────────────────────────────────────────────────────────────────────────
function Window:_noticeGui()
    if self.NotificationGui then return end
    self.NotificationGui = create("ScreenGui", {
        Name = self.Gui.Name .. "Notifications",
        ResetOnSpawn = false,
        IgnoreGuiInset = false,
        DisplayOrder = self.Gui.DisplayOrder + 1,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, self.Gui.Parent)

    local pos = self.NotificationOptions.Position
    local isBottom = pos == "BottomRight"
    self._noticeRoot = frame(self.NotificationGui, "Stack", UDim2.fromScale(1, isBottom and 1 or 0), UDim2.fromOffset(self.NotificationOptions.Width + 40, 600), self.Theme.Panel)
    self._noticeRoot.AnchorPoint = Vector2.new(1, isBottom and 1 or 0)
    self._noticeRoot.BackgroundTransparency = 1
    self._noticeScale = create("UIScale", {Scale = 1}, self._noticeRoot)
end

function Window:_showNotice(notice)
    self:_noticeGui()
    local width = self.NotificationOptions.Width
    local card = create("CanvasGroup", {
        Name = "Notification",
        Size = UDim2.fromOffset(width, 76),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        GroupTransparency = 1,
        ClipsDescendants = true,
    }, self._noticeRoot)

    notice.Instance = card
    notice.Phase = "Entering"
    notice.PhaseAge = 0
    notice.Elapsed = 0

    local cardStroke = stroke(card, self.Theme.Border, 1)
    local edge = frame(card, "Accent", UDim2.fromOffset(0, 0), UDim2.new(0, 3, 1, 0), self.Theme.Accent)
    local icon = label(card, "Icon", "", UDim2.fromOffset(12, 10), UDim2.fromOffset(18, 18), self.Theme.Accent, 15, Enum.Font.Code)
    icon.TextXAlignment = Enum.TextXAlignment.Center

    local title = label(card, "Title", "", UDim2.fromOffset(38, 9), UDim2.new(1, -68, 0, 18), self.Theme.Text, 13, Enum.Font.ArialBold or Enum.Font.Arial)
    local body = label(card, "Message", "", UDim2.fromOffset(38, 28), UDim2.new(1, -50, 0, 34), self.Theme.Muted, 12, Enum.Font.Arial)
    body.TextWrapped = true
    body.TextYAlignment = Enum.TextYAlignment.Top

    local close = button(card, "Dismiss", UDim2.new(1, -26, 0, 6), UDim2.fromOffset(20, 20))
    local closeText = label(close, "X", "×", UDim2.fromOffset(0, 0), UDim2.fromScale(1, 1), self.Theme.Muted, 16)
    closeText.TextXAlignment = Enum.TextXAlignment.Center

    local progress = frame(card, "Lifetime", UDim2.new(0, 3, 1, -2), UDim2.new(1, -3, 0, 2), self.Theme.Accent)

    notice._draw = function()
        local style = NOTICE_TYPES[notice.Options.Type] or NOTICE_TYPES.Info
        edge.BackgroundColor3 = style[2]
        icon.Text, icon.TextColor3 = style[1], style[2]
        progress.BackgroundColor3 = style[2]
        title.Text, body.Text = notice.Options.Title, notice.Options.Text
        progress.Visible = notice.Options.Duration > 0
    end

    close.Activated:Connect(function() notice:Dismiss() end)
    card.MouseEnter:Connect(function()
        notice.Hovered = true
        cardStroke.Color = self.Theme.Muted
    end)
    card.MouseLeave:Connect(function()
        notice.Hovered = false
        cardStroke.Color = self.Theme.Border
    end)
    notice:_draw()
end

function Window:_stepNotices(dt)
    if self._destroyed then return end
    local active = 0
    for _, n in ipairs(self._notices) do
        if n.Instance and not n.Closed then active += 1 end
    end
    for _, n in ipairs(self._notices) do
        if not n.Instance and not n.Closed and active < self.NotificationOptions.MaxVisible then
            self:_showNotice(n)
            active += 1
        end
    end

    local offset = 20
    local finished = {}
    for _, n in ipairs(self._notices) do
        if n.Instance and not n.Closed then
            local isBottom = self.NotificationOptions.Position == "BottomRight"
            local y = isBottom and (600 - offset - 76) or offset
            n._y = n._y and (n._y + (y - n._y) * (1 - math.exp(-dt * 22))) or y
            n.PhaseAge += dt
            local alpha = 1

            if n.Phase == "Entering" then
                alpha = math.clamp(n.PhaseAge / 0.16, 0, 1)
                if alpha == 1 then n.Phase = "Visible"; n.PhaseAge = 0 end
            elseif n.Phase == "Closing" then
                alpha = 1 - math.clamp(n.PhaseAge / 0.14, 0, 1)
                if alpha == 0 then table.insert(finished, n) end
            elseif not n.Hovered and n.Options.Duration > 0 then
                n.Elapsed += dt
                if n.Elapsed >= n.Options.Duration then n:Dismiss("Timeout") end
            end

            n.Instance.Position = UDim2.fromOffset(20 + (1 - alpha) * 16, n._y)
            n.Instance.GroupTransparency = 1 - alpha
            local frac = n.Options.Duration > 0 and (1 - math.clamp(n.Elapsed / n.Options.Duration, 0, 1)) or 1
            n.Instance.Lifetime.Size = UDim2.new(frac, -3 * frac, 0, 2)
            offset += 86
        elseif n.Closed then
            table.insert(finished, n)
        end
    end

    for _, n in ipairs(finished) do
        local idx = table.find(self._notices, n)
        if idx then table.remove(self._notices, idx) end
        n.Closed = true
        if n.Instance then n.Instance:Destroy() end
        self:_callback(n.Options.OnClose, n.Reason or "Dismissed")
    end

    if #self._notices == 0 and self._noticeConnection then
        self._noticeConnection:Disconnect()
        self._noticeConnection = nil
    end
end

function Window:Notify(options)
    assert(not self._destroyed, "Window destroyed")
    if not self.Features.Notifications then return nil end
    options = table.clone(options or {})
    options.Title = options.Title or "Notification"
    options.Text = options.Text or ""
    options.Type = options.Type or "Info"
    options.Duration = options.Duration == nil and self.NotificationOptions.Duration or options.Duration

    local notice = {Options = options, Closed = false, Phase = "Queued", Elapsed = 0, Hovered = false}
    function notice:Dismiss(reason)
        if self.Closed or self.Phase == "Closing" then return end
        self.Reason = reason or "Dismissed"
        if self.Instance then
            self.Phase = "Closing"
            self.PhaseAge = 0
        else
            self.Closed = true
        end
    end

    table.insert(self._notices, notice)
    if not self._noticeConnection then
        self._noticeConnection = RunService.RenderStepped:Connect(function(dt)
            self:_stepNotices(dt)
        end)
    end
    return notice
end

-- ─────────────────────────────────────────────────────────────────────────────
-- 3D PREVIEW ENGINE (WorldModel Mannequin)
-- ─────────────────────────────────────────────────────────────────────────────
function Window:_createPreview(title, attachDrag)
    local panel = frame(self.Root, "Preview", UDim2.fromOffset(self.MainWidth + 10, 0), UDim2.fromOffset(350, self.Height), self.Theme.Background, self.Theme.Border)
    panel.Active = true
    self:_accent(panel, "BorderColor3")

    local titlebar = button(panel, "DragHandle", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 26))
    label(titlebar, "Title", title, UDim2.fromOffset(32, 0), UDim2.new(1, -40, 1, 0), self.Theme.Text)
    for _, px in ipairs(drawMark(titlebar, self.Theme.Accent):GetChildren()) do
        self:_accent(px, "BackgroundColor3")
    end
    attachDrag(titlebar)

    local canvas = frame(panel, "Canvas", UDim2.fromOffset(8, 26), UDim2.new(1, -16, 1, -34), self.Theme.Background, self.Theme.Border)
    local target = frame(canvas, "Target", UDim2.new(0.5, -61, 0.5, -51), UDim2.fromOffset(122, 170), self.Theme.Accent)
    target.BackgroundTransparency = 1

    local viewport = create("ViewportFrame", {
        Name = "Avatar",
        Position = UDim2.fromOffset(2, 2),
        Size = UDim2.new(1, -4, 1, -4),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Ambient = Color3.fromRGB(180, 190, 195),
        LightColor = Color3.fromRGB(190, 205, 215),
        LightDirection = Vector3.new(-1, -1, -2),
        ImageColor3 = Color3.fromRGB(160, 195, 190),
    }, target)
    local world = create("WorldModel", {Name = "PreviewWorld"}, viewport)
    local cam = create("Camera", {Name = "Camera", FieldOfView = 32}, viewport)
    viewport.CurrentCamera = cam

    local tint = frame(target, "BoxFill", UDim2.fromOffset(1, 1), UDim2.new(1, -2, 1, -2), self.Theme.Accent)
    tint.BackgroundTransparency = 0.85
    tint.ZIndex = 3

    local outline = frame(target, "Box", UDim2.fromOffset(0, 0), UDim2.fromScale(1, 1), Color3.new(0, 0, 0))
    outline.BackgroundTransparency = 1
    outline.BorderSizePixel = 0
    local outStroke = stroke(outline, self.Theme.Accent, 1)
    outline.ZIndex = 4

    local name = label(target, "NameLabel", "Name", UDim2.fromOffset(-20, -21), UDim2.new(1, 40, 0, 18), Color3.new(1, 1, 1), 11)
    name.TextXAlignment = Enum.TextXAlignment.Center

    local flags = label(target, "FlagsLabel", "TARGET\nACTIVE", UDim2.new(1, 4, 0, -25), UDim2.fromOffset(80, 26), Color3.new(1, 1, 1), 8, Enum.Font.Code)
    flags.TextYAlignment = Enum.TextYAlignment.Top

    local details = label(target, "DetailsLabel", "ESP PREVIEW", UDim2.new(0, -20, 1, 4), UDim2.new(1, 40, 0, 20), Color3.new(1, 1, 1), 8, Enum.Font.Code)
    details.TextXAlignment = Enum.TextXAlignment.Center
    details.TextYAlignment = Enum.TextYAlignment.Top

    local health = frame(target, "Health", UDim2.fromOffset(-5, 94), UDim2.fromOffset(2, 76), Color3.fromRGB(220, 215, 60))
    local head = frame(target, "HeadDot", UDim2.fromScale(0.5, 0.16), UDim2.fromOffset(4, 4), Color3.fromRGB(255, 40, 60))
    head.AnchorPoint = Vector2.new(0.5, 0.5)
    head.ZIndex = 5
    head.Visible = false

    self.Preview = {
        Panel = panel, Target = target, Viewport = viewport, World = world, Camera = cam,
        Fill = tint, Box = outline, BoxStroke = outStroke, Name = name, Flags = flags,
        Details = details, Health = health, Head = head,
    }
    self:SetPreviewModel(nil)
end

function Window:SetPreviewModel(model)
    if not self.Preview then return end
    local p = self.Preview
    local clone
    if model and typeof(model) == "Instance" and model:IsA("Model") and model.Archivable then
        local ok, res = pcall(function() return model:Clone() end)
        if ok then clone = res end
    end
    if not clone then
        clone = Instance.new("Model")
        clone.Name = "Mannequin"
        local parts = {
            {"Head", Vector3.new(1.2, 1.2, 1.2), Vector3.new(0, 2, 0), Color3.fromRGB(160, 170, 175)},
            {"Torso", Vector3.new(2, 2, 1), Vector3.new(0, 0.35, 0), Color3.fromRGB(24, 34, 40)},
            {"Left Arm", Vector3.new(1, 2, 1), Vector3.new(-1.5, 0.35, 0), Color3.fromRGB(24, 34, 40)},
            {"Right Arm", Vector3.new(1, 2, 1), Vector3.new(1.5, 0.35, 0), Color3.fromRGB(24, 34, 40)},
            {"Left Leg", Vector3.new(1, 2, 1), Vector3.new(-0.5, -1.65, 0), Color3.fromRGB(90, 105, 115)},
            {"Right Leg", Vector3.new(1, 2, 1), Vector3.new(0.5, -1.65, 0), Color3.fromRGB(90, 105, 115)},
        }
        for _, pt in ipairs(parts) do
            create("Part", {Name = pt[1], Size = pt[2], Position = pt[3], Color = pt[4], Material = Enum.Material.SmoothPlastic, Anchored = true, CanCollide = false}, clone)
        end
    end

    for _, item in ipairs(clone:GetDescendants()) do
        if item:IsA("BaseScript") or item:IsA("Sound") or item:IsA("ParticleEmitter") then
            item:Destroy()
        elseif item:IsA("BasePart") then
            item.Anchored = true
            item.CanCollide = false
        elseif item:IsA("Humanoid") then
            item.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end
    end

    p.World:ClearAllChildren()
    clone.Parent = p.World
    clone:PivotTo(CFrame.new())

    local bounds, size = clone:GetBoundingBox()
    local aspect = 118 / 166
    local dist = math.max(size.Y, size.X / aspect) / (2 * math.tan(math.rad(p.Camera.FieldOfView / 2))) + size.Z / 2
    local center = bounds.Position
    p.Camera.CFrame = CFrame.lookAt(center + Vector3.new(0, 0, -dist * 1.02), center)
    p.Model = clone
end

function Window:UpdatePreview(opts)
    if not self.Preview then return end
    local p = self.Preview
    for k, obj in pairs({Box = p.Box, BoxFilled = p.Fill, Name = p.Name, Health = p.Health, HeadDot = p.Head, Flags = p.Flags, Details = p.Details}) do
        if opts[k] ~= nil then obj.Visible = opts[k] == true end
    end
    if opts.BoxColor then p.BoxStroke.Color = opts.BoxColor end
    if opts.FillColor then p.Fill.BackgroundColor3 = opts.FillColor end
    if opts.FillTransparency then p.Fill.BackgroundTransparency = opts.FillTransparency end
    if opts.NameColor then p.Name.TextColor3 = opts.NameColor end
    if opts.NameText then p.Name.Text = opts.NameText end
    if opts.FlagsText then p.Flags.Text = opts.FlagsText end
    if opts.DetailsText then p.Details.Text = opts.DetailsText end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- LIVE ESP SYSTEM
-- ─────────────────────────────────────────────────────────────────────────────
local ESP_DEFAULTS = {
    Enabled          = false,
    Box              = true,
    BoxFilled        = false,
    Name             = true,
    Health           = true,
    Distance         = true,
    Tracer           = false,
    Highlight        = false,
    ThroughWalls     = false,
    MaxDistance      = 1000,
    Color            = Color3.fromRGB(20, 205, 185),
    FillTransparency = 0.85,
    TextSize         = 12,
    TracerOrigin     = "Bottom",
    Preview          = false,
}

function Window:CreateESP(options)
    assert(not self._destroyed and self.Features.ESP, "Enable Features.ESP when creating the window")
    local controller = setmetatable({
        Window = self,
        Options = table.clone(ESP_DEFAULTS),
        Targets = {},
        _players = {},
        _destroyed = false,
    }, ESP)

    for k, v in pairs(options or {}) do
        if controller.Options[k] ~= nil then
            controller.Options[k] = v
        end
    end

    controller.Gui = create("ScreenGui", {
        Name = self.Gui.Name .. "ESP",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = math.max(0, self.Gui.DisplayOrder - 1),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, self.Gui.Parent)

    controller._raycast = RaycastParams.new()
    controller._raycast.FilterType = Enum.RaycastFilterType.Exclude
    controller._raycast.IgnoreWater = true

    table.insert(self._espControllers, controller)
    controller:_syncConnection()
    return controller
end

function ESP:_syncConnection()
    local needed = not self._destroyed and self.Options.Enabled and next(self.Targets) ~= nil
    if needed and not self._connection then
        self._connection = RunService.RenderStepped:Connect(function() self:_render() end)
    elseif not needed and self._connection then
        self._connection:Disconnect()
        self._connection = nil
    end
    if not needed then
        for _, t in pairs(self.Targets) do
            t.Frame.Visible = false
            t.Highlight.Enabled = false
        end
    end
end

function ESP:SetOptions(changes)
    assert(not self._destroyed, "ESP destroyed")
    for k, v in pairs(changes or {}) do
        if self.Options[k] ~= nil then
            self.Options[k] = v
        end
    end
    self:_syncPreview()
    self:_syncConnection()
    return self
end

function ESP:SetEnabled(enabled)
    return self:SetOptions({Enabled = enabled})
end

function ESP:_syncPreview(preferred, dist)
    if not self.Options.Preview or not self.Window.Preview then return end
    local target = preferred
    if not target or target.Removed then
        for _, c in pairs(self.Targets) do target = c; break end
    end
    if not target then return end

    local color = target.Options.Color or self.Options.Color
    self.Window:UpdatePreview({
        Box = self.Options.Box,
        BoxFilled = self.Options.BoxFilled,
        Name = self.Options.Name,
        Health = self.Options.Health,
        Details = self.Options.Distance,
        BoxColor = color,
        FillColor = color,
        FillTransparency = self.Options.FillTransparency,
        NameColor = color,
        NameText = target.Options.Name or target.Model.Name,
        DetailsText = dist and (math.round(dist) .. " studs") or "ESP PREVIEW",
    })
end

function ESP:Add(model, options)
    assert(not self._destroyed, "ESP destroyed")
    assert(typeof(model) == "Instance" and model:IsA("Model"), "ESP:Add expects a Model")
    options = options or {}
    if self.Targets[model] then
        self.Targets[model].Options = options
        return self.Targets[model]
    end

    local target = {Model = model, Options = options, Removed = false}
    target.Frame = frame(self.Gui, "Target", UDim2.fromOffset(0, 0), UDim2.fromOffset(0, 0), self.Options.Color)
    target.Frame.BackgroundTransparency = 1
    target.Frame.Visible = false

    target.Box = frame(target.Frame, "Box", UDim2.fromOffset(0, 0), UDim2.fromScale(1, 1), self.Options.Color)
    target.Box.BackgroundTransparency = 1
    target.Stroke = stroke(target.Box, self.Options.Color, 1)

    target.Fill = frame(target.Frame, "Fill", UDim2.fromOffset(1, 1), UDim2.new(1, -2, 1, -2), self.Options.Color)
    target.Fill.BackgroundTransparency = self.Options.FillTransparency

    target.Name = label(target.Frame, "Name", "", UDim2.new(0.5, -100, 0, -18), UDim2.fromOffset(200, 16), self.Options.Color, self.Options.TextSize)
    target.Name.TextXAlignment = Enum.TextXAlignment.Center

    target.Distance = label(target.Frame, "Distance", "", UDim2.new(0.5, -75, 1, 2), UDim2.fromOffset(150, 16), self.Options.Color, self.Options.TextSize)
    target.Distance.TextXAlignment = Enum.TextXAlignment.Center

    target.Health = frame(target.Frame, "Health", UDim2.fromOffset(-5, 0), UDim2.new(0, 2, 1, 0), Color3.fromRGB(15, 20, 25))
    target.HealthFill = frame(target.Health, "Fill", UDim2.fromScale(0, 1), UDim2.fromScale(1, 1), Color3.fromRGB(60, 210, 145))
    target.HealthFill.AnchorPoint = Vector2.new(0, 1)

    target.Tracer = frame(target.Frame, "Tracer", UDim2.fromOffset(0, 0), UDim2.fromOffset(0, 1), self.Options.Color)
    target.Tracer.AnchorPoint = Vector2.new(0.5, 0.5)

    target.Highlight = create("Highlight", {Name = "Chams", Adornee = model, Enabled = false}, target.Frame)

    local ctrl = self
    function target:Remove() ctrl:Remove(model) end

    target._destroyConnection = model.Destroying:Connect(function() ctrl:Remove(model) end)
    self.Targets[model] = target
    self:_syncPreview(target)
    self:_syncConnection()
    return target
end

function ESP:Remove(model)
    local target = self.Targets[model]
    if not target then return end
    self.Targets[model] = nil
    target.Removed = true
    if target._destroyConnection then target._destroyConnection:Disconnect() end
    target.Frame:Destroy()
    self:_syncPreview()
    self:_syncConnection()
end

function ESP:TrackPlayer(player, options)
    assert(not self._destroyed and typeof(player) == "Instance" and player:IsA("Player"), "TrackPlayer expects Player")
    local tracker = {Connected = true, _connections = {}}
    local ctrl = self
    local current
    local function attach(char)
        if current then ctrl:Remove(current) end
        current = char
        if char and tracker.Connected then
            ctrl:Add(char, {Name = player.DisplayName, Color = options and options.Color})
        end
    end
    function tracker:Disconnect()
        if not self.Connected then return end
        self.Connected = false
        for _, c in ipairs(self._connections) do c:Disconnect() end
        if current then ctrl:Remove(current) end
    end
    table.insert(tracker._connections, player.CharacterAdded:Connect(attach))
    table.insert(tracker._connections, player.CharacterRemoving:Connect(function()
        if current then ctrl:Remove(current); current = nil end
    end))
    attach(player.Character)
    return tracker
end

function ESP:_render()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local view = camera.ViewportSize
    local char = LocalPlayer and LocalPlayer.Character
    self._raycast.FilterDescendantsInstances = char and {char} or {}

    for model, t in pairs(self.Targets) do
        t.Frame.Visible = false
        t.Highlight.Enabled = false
        if not model:IsDescendantOf(workspace) or not model:FindFirstChildWhichIsA("BasePart", true) then
            continue
        end

        local bounds, size = model:GetBoundingBox()
        local dist = (bounds.Position - camera.CFrame.Position).Magnitude
        if dist > self.Options.MaxDistance then continue end

        if not self.Options.ThroughWalls then
            local hit = workspace:Raycast(camera.CFrame.Position, bounds.Position - camera.CFrame.Position, self._raycast)
            if hit and not hit.Instance:IsDescendantOf(model) then continue end
        end

        local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
        local inFront = true
        for x = -1, 1, 2 do
            for y = -1, 1, 2 do
                for z = -1, 1, 2 do
                    local pt = camera:WorldToViewportPoint(bounds * Vector3.new(size.X * x / 2, size.Y * y / 2, size.Z * z / 2))
                    if pt.Z <= 0.1 then inFront = false end
                    minX, minY = math.min(minX, pt.X), math.min(minY, pt.Y)
                    maxX, maxY = math.max(maxX, pt.X), math.max(maxY, pt.Y)
                end
            end
        end

        if not inFront or maxX < 0 or maxY < 0 or minX > view.X or minY > view.Y then continue end
        minX, minY = math.clamp(minX, 0, view.X), math.clamp(minY, 0, view.Y)
        maxX, maxY = math.clamp(maxX, 0, view.X), math.clamp(maxY, 0, view.Y)
        local w, h = math.max(1, maxX - minX), math.max(1, maxY - minY)
        local color = t.Options.Color or self.Options.Color

        t.Frame.Position = UDim2.fromOffset(math.round(minX), math.round(minY))
        t.Frame.Size = UDim2.fromOffset(math.round(w), math.round(h))
        t.Frame.Visible = true

        t.Box.Visible = self.Options.Box
        t.Stroke.Color = color
        t.Fill.Visible = self.Options.BoxFilled
        t.Fill.BackgroundColor3 = color
        t.Fill.BackgroundTransparency = self.Options.FillTransparency

        t.Name.Visible = self.Options.Name
        t.Name.Text = t.Options.Name or model.Name
        t.Name.TextColor3 = color

        t.Distance.Visible = self.Options.Distance
        t.Distance.Text = math.round(dist) .. " studs"
        t.Distance.TextColor3 = color

        local hum = model:FindFirstChildOfClass("Humanoid")
        t.Health.Visible = self.Options.Health and hum ~= nil
        if hum then
            local ratio = hum.MaxHealth > 0 and math.clamp(hum.Health / hum.MaxHealth, 0, 1) or 0
            t.HealthFill.Size = UDim2.fromScale(1, ratio)
            t.HealthFill.BackgroundColor3 = Color3.fromRGB(240, 80, 95):Lerp(Color3.fromRGB(60, 210, 145), ratio)
        end

        t.Tracer.Visible = self.Options.Tracer
        t.Tracer.BackgroundColor3 = color
        if self.Options.Tracer then
            local origY = self.Options.TracerOrigin == "Top" and 0 or (self.Options.TracerOrigin == "Center" and (view.Y / 2) or view.Y)
            local orig = Vector2.new(view.X / 2, origY)
            local dest = Vector2.new(minX + w / 2, maxY)
            local d = dest - orig
            local center = (orig + dest) / 2 - Vector2.new(minX, minY)
            t.Tracer.Position = UDim2.fromOffset(center.X, center.Y)
            t.Tracer.Size = UDim2.fromOffset(d.Magnitude, 1)
            t.Tracer.Rotation = math.deg(math.atan2(d.Y, d.X))
        end

        t.Highlight.Enabled = self.Options.Highlight
        t.Highlight.FillColor = color
        t.Highlight.OutlineColor = color
        t.Highlight.FillTransparency = self.Options.FillTransparency
    end
end

function ESP:Destroy()
    if self._destroyed then return end
    self._destroyed = true
    if self._connection then self._connection:Disconnect(); self._connection = nil end
    self.Gui:Destroy()
    local idx = table.find(self.Window._espControllers, self)
    if idx then table.remove(self.Window._espControllers, idx) end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- WINDOW INITIALIZER
-- ─────────────────────────────────────────────────────────────────────────────
function ZenUI.new(options)
    options = options or {}
    local player = LocalPlayer
    local self = setmetatable({}, Window)

    local features = options.Features or {}
    self.Features = {
        Preview       = features.Preview == true or (features.Preview == nil and options.Preview == true),
        ESP           = features.ESP == true,
        Notifications = features.Notifications ~= false,
        Watermark     = features.Watermark ~= false,
        KeybindsList  = features.KeybindsList ~= false,
        Crosshair     = features.Crosshair ~= false,
    }

    self.NotificationOptions = table.clone(options.Notifications or {})
    local n = self.NotificationOptions
    n.Duration = n.Duration or 5
    n.MaxVisible = n.MaxVisible or 4
    n.Width = n.Width or 310
    n.Position = n.Position or "BottomRight"

    -- Apply Theme
    local baseThemeName = options.ThemeName or "Zen"
    self.Theme = table.clone(THEMES[baseThemeName] or THEMES["Zen"])
    for k, v in pairs(options.Theme or {}) do
        if self.Theme[k] and typeof(v) == "Color3" then
            self.Theme[k] = v
        end
    end

    self.Height = options.Height or 542
    self.MainWidth = options.Width or 624
    self.HasPreview = self.Features.Preview
    self.Width = self.MainWidth + (self.HasPreview and 360 or 0)
    self.RequestedScale = options.Scale or 1
    self.ToggleKey = options.ToggleKey or Enum.KeyCode.RightShift

    self._connections = {}
    self._accentBindings = {}
    self._tabs = {}
    self._controls = {}
    self._espControllers = {}
    self._crosshairs = {}
    self._destroyCallbacks = {}
    self._notices = {}
    self.Flags = {}
    self.Controls = {}
    self.Tabs = {}

    local parentGui = options.Parent or getGuiParent()
    self.Gui = create("ScreenGui", {
        Name = options.Name or "ZenUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = options.DisplayOrder or 50,
    }, parentGui)

    TooltipManager:Init(self.Gui, self.Theme)

    self.Root = frame(self.Gui, "Root", UDim2.fromOffset(0, 0), UDim2.fromOffset(self.Width, self.Height), self.Theme.Background)
    self.Root.BackgroundTransparency = 1
    self.Scale = create("UIScale", {Scale = 1}, self.Root)

    self.Main = frame(self.Root, "Main", UDim2.fromOffset(0, 0), UDim2.fromOffset(self.MainWidth, self.Height), self.Theme.Background, self.Theme.Border)
    self.Main.Active = true

    -- Accent Edge
    local edge = frame(self.Main, "AccentEdge", UDim2.new(1, -1, 0, 0), UDim2.new(0, 1, 1, 0), self.Theme.Accent)
    self:_accent(edge, "BackgroundColor3")

    -- Titlebar Handle
    local titlebar = button(self.Main, "DragHandle", UDim2.fromOffset(0, 0), UDim2.new(1, -1, 0, 26))
    titlebar.Active = true
    local winTitle = label(titlebar, "Title", options.Title or "zen ui - premium roblox interface", UDim2.fromOffset(30, 0), UDim2.new(1, -40, 1, 0), self.Theme.Text, 13)
    for _, px in ipairs(drawMark(titlebar, self.Theme.Accent):GetChildren()) do
        self:_accent(px, "BackgroundColor3")
    end

    -- Tab Bar
    self.TabBar = frame(self.Main, "Tabs", UDim2.fromOffset(6, 26), UDim2.new(1, -16, 0, 32), self.Theme.Background)
    create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder}, self.TabBar)

    -- Content Body
    self.Body = frame(self.Main, "Body", UDim2.fromOffset(6, 57), UDim2.new(1, -16, 1, -68), self.Theme.Panel, self.Theme.Border)

    -- Popups Overlay Layer
    self.PopupLayer = frame(self.Root, "Popups", UDim2.fromOffset(0, 0), UDim2.fromScale(1, 1), self.Theme.Background)
    self.PopupLayer.BackgroundTransparency = 1
    self.PopupLayer.Visible = false
    self.PopupLayer.ZIndex = 34
    local dismiss = button(self.PopupLayer, "Dismiss", UDim2.fromOffset(0, 0), UDim2.fromScale(1, 1))
    dismiss.ZIndex = 34
    self:_connect(dismiss.Activated, function() self:_closePopup() end)

    -- Window Dragging
    local function attachDrag(handle)
        self:_connect(handle.InputBegan, function(input)
            local start = Vector2.new(input.Position.X, input.Position.Y)
            local origin = Vector2.new(self.Root.Position.X.Offset, self.Root.Position.Y.Offset)
            self:_closePopup()
            self:_beginPointer(input, function(pos)
                local delta = pos - start
                local cam = workspace.CurrentCamera
                if cam then
                    local view = cam.ViewportSize
                    local top, bot = GuiService:GetGuiInset()
                    local x = math.clamp(origin.X + delta.X, 0, math.max(0, view.X - self.Width * self.Scale.Scale))
                    local y = math.clamp(origin.Y + delta.Y, top.Y, math.max(top.Y, view.Y - bot.Y - self.Height * self.Scale.Scale))
                    self.Root.Position = UDim2.fromOffset(math.round(x), math.round(y))
                end
            end)
        end)
    end
    attachDrag(titlebar)

    if self.HasPreview then
        self:_createPreview(options.PreviewTitle or "Live ESP Preview", attachDrag)
    end

    -- Input Handler
    self:_connect(UserInputService.InputChanged, function(input)
        local p = self._pointer
        if not p then return end
        if (p.Touch and input == p.Input) or (not p.Touch and input.UserInputType == Enum.UserInputType.MouseMovement) then
            p.Update(Vector2.new(input.Position.X, input.Position.Y))
        end
    end)
    self:_connect(UserInputService.InputEnded, function(input)
        local p = self._pointer
        if p and (input == p.Input or (not p.Touch and input.UserInputType == Enum.UserInputType.MouseButton1)) then
            self._pointer = nil
        end
    end)
    self:_connect(UserInputService.WindowFocusReleased, function() self._pointer = nil end)

    self:_connect(UserInputService.InputBegan, function(input, processed)
        if self._popup and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            local p, s = self._popup.AbsolutePosition, self._popup.AbsoluteSize
            local pt = input.Position
            if pt.X < p.X or pt.X > p.X + s.X or pt.Y < p.Y or pt.Y > p.Y + s.Y then
                self:_closePopup()
            end
        end

        if UserInputService:GetFocusedTextBox() then return end

        if self._capturing then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local ctrl = self._capturing
                self._capturing = nil
                if input.KeyCode ~= Enum.KeyCode.Escape then
                    ctrl:SetValue(input.KeyCode)
                else
                    ctrl._draw(ctrl)
                end
            end
            return
        end

        if processed then return end

        if input.KeyCode == self.ToggleKey then
            self:SetVisible(not self.Gui.Enabled)
            return
        end

        if input.KeyCode == Enum.KeyCode.Escape and self._popup then
            self:_closePopup()
        end

        for _, ctrl in ipairs(self._controls) do
            if ctrl.Kind == "Keybind" and not ctrl.Disabled then
                if ctrl.Mode == "Toggle" and input.KeyCode == ctrl.Value then
                    ctrl.Active = not ctrl.Active
                    ctrl:_draw(ctrl)
                    self:_callback(ctrl._pressed, ctrl.Active)
                    if self.KeybindsHUD then
                        self.KeybindsHUD:UpdateEntry(ctrl.Flag or ctrl.Instance.Name, ctrl.Text, ctrl.Value.Name, ctrl.Mode, ctrl.Active)
                    end
                elseif ctrl.Mode == "Hold" and input.KeyCode == ctrl.Value then
                    ctrl.Active = true
                    ctrl:_draw(ctrl)
                    self:_callback(ctrl._pressed, true)
                    if self.KeybindsHUD then
                        self.KeybindsHUD:UpdateEntry(ctrl.Flag or ctrl.Instance.Name, ctrl.Text, ctrl.Value.Name, ctrl.Mode, true)
                    end
                elseif ctrl.Mode == "Always" then
                    -- Always active
                elseif input.KeyCode == ctrl.Value then
                    self:_callback(ctrl._pressed)
                end
            end
        end
    end)

    -- Handle Key release for Hold keybinds
    self:_connect(UserInputService.InputEnded, function(input)
        for _, ctrl in ipairs(self._controls) do
            if ctrl.Kind == "Keybind" and not ctrl.Disabled and ctrl.Mode == "Hold" and input.KeyCode == ctrl.Value then
                ctrl.Active = false
                ctrl:_draw(ctrl)
                self:_callback(ctrl._pressed, false)
                if self.KeybindsHUD then
                    self.KeybindsHUD:UpdateEntry(ctrl.Flag or ctrl.Instance.Name, ctrl.Text, ctrl.Value.Name, ctrl.Mode, false)
                end
            end
        end
    end)

    -- Watermark & Keybinds List
    if self.Features.Watermark then
        self.Watermark = Watermark.new(self.Gui, self.Theme)
    end
    if self.Features.KeybindsList then
        self.KeybindsHUD = KeybindList.new(self.Gui, self.Theme)
    end

    local function bindCamera()
        if self._cameraConnection then self._cameraConnection:Disconnect() end
        local cam = workspace.CurrentCamera
        if cam then
            self._cameraConnection = cam:GetPropertyChangedSignal("ViewportSize"):Connect(function() self:_layout(false) end)
        end
        self:_layout(true)
    end
    self:_connect(workspace:GetPropertyChangedSignal("CurrentCamera"), bindCamera)
    self:_connect(self.Gui.Destroying, function()
        self._destroyingGui = true
        self:Destroy()
    end)
    bindCamera()

    table.insert(ZenUI.Windows, self)
    return self
end

-- ─────────────────────────────────────────────────────────────────────────────
-- TABS & SECTIONS
-- ─────────────────────────────────────────────────────────────────────────────
function Window:AddTab(name, icon)
    assert(type(name) == "string" and name ~= "" and not self.Tabs[name], "Tab names must be unique non-empty strings")
    local tab = setmetatable({Name = name, Window = self, Sections = {}}, Tab)

    tab.Button = button(self.TabBar, slug(name), UDim2.fromOffset(0, 0), UDim2.fromScale(1, 1))
    tab.Button.BackgroundTransparency = 0
    tab.Button.BackgroundColor3 = self.Theme.Background
    tab.Button.BorderSizePixel = 1
    tab.Button.BorderColor3 = self.Theme.Border
    tab.Button.BorderMode = Enum.BorderMode.Inset
    tab.Button.LayoutOrder = #self._tabs + 1

    tab.Caption = label(tab.Button, "Caption", name, UDim2.fromOffset(0, 0), UDim2.fromScale(1, 1), self.Theme.Muted)
    tab.Caption.TextXAlignment = Enum.TextXAlignment.Center

    tab.Line = frame(tab.Button, "ActiveLine", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 2), self.Theme.Accent)
    self:_accent(tab.Line, "BackgroundColor3")

    tab.Glow = frame(tab.Button, "Glow", UDim2.fromOffset(0, 2), UDim2.new(1, 0, 0, 10), self.Theme.Accent)
    self:_accent(tab.Glow, "BackgroundColor3")
    local g = gradient(tab.Glow, Color3.new(1, 1, 1), Color3.new(1, 1, 1))
    g.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.86), NumberSequenceKeypoint.new(1, 1)})

    tab.Seam = frame(tab.Button, "Seam", UDim2.new(0, 1, 1, -1), UDim2.new(1, -2, 0, 1), self.Theme.Panel)
    tab.Button.ZIndex = 3

    tab.Page = frame(self.Body, slug(name), UDim2.fromOffset(9, 10), UDim2.new(1, -18, 1, -20), self.Theme.Panel)
    tab.Page.BackgroundTransparency = 1

    tab.Columns = {}
    for i, side in ipairs({"Left", "Right"}) do
        local col = frame(tab.Page, side, UDim2.new((i - 1) * 0.5, (i - 1) * 4, 0, 0), UDim2.new(0.5, -5, 1, 0), self.Theme.Panel)
        col.BackgroundTransparency = 1
        create("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder}, col)
        tab.Columns[side] = col
    end

    self.Tabs[name] = tab
    table.insert(self._tabs, tab)

    for _, existing in ipairs(self._tabs) do
        existing.Button.Size = UDim2.new(1 / #self._tabs, 0, 1, 0)
    end

    self:_connect(tab.Button.Activated, function() self:SelectTab(name) end)
    self:_connect(tab.Button.MouseEnter, function()
        if self.ActiveTab ~= name then tab.Caption.TextColor3 = self.Theme.Text end
    end)
    self:_connect(tab.Button.MouseLeave, function()
        if self.ActiveTab ~= name then tab.Caption.TextColor3 = self.Theme.Muted end
    end)

    self:SelectTab(self.ActiveTab or name)
    return tab
end

function Tab:AddSection(options)
    if type(options) == "string" then options = {Title = options} end
    options = options or {}
    local w = self.Window
    local side = options.Side or "Left"
    assert(self.Columns[side], "Section Side must be Left or Right")

    local sec = setmetatable({Window = w, Tab = self, _order = 0}, Section)
    sec.Frame = frame(self.Columns[side], slug(options.Title or "Section"), UDim2.fromOffset(0, 0), options.Height and UDim2.new(1, 0, 0, options.Height) or UDim2.fromScale(1, 1), w.Theme.Panel, w.Theme.Border)
    sec.Frame.LayoutOrder = #self.Sections + 1

    local header = frame(sec.Frame, "Header", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 24), w.Theme.Header)
    gradient(header, Color3.fromRGB(22, 28, 35), w.Theme.Header)
    frame(header, "Divider", UDim2.new(0, 0, 1, -1), UDim2.new(1, 0, 0, 1), w.Theme.Border)

    local acc = frame(header, "Accent", UDim2.fromOffset(0, 0), UDim2.new(0, 2, 1, 0), w.Theme.Accent)
    w:_accent(acc, "BackgroundColor3")

    label(header, "Title", options.Title or "Section", UDim2.fromOffset(10, 0), UDim2.new(1, -20, 1, 0), w.Theme.Text)

    sec.Content = create("ScrollingFrame", {
        Name = "Controls",
        Position = UDim2.fromOffset(10, 25),
        Size = UDim2.new(1, -20, 1, -26),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ElasticBehavior = Enum.ElasticBehavior.Never,
    }, sec.Frame)
    create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)}, sec.Content)

    -- Auto-hiding Slim Scrollbar
    local thumb = frame(sec.Frame, "ScrollThumb", UDim2.new(1, -4, 0, 26), UDim2.fromOffset(2, 30), w.Theme.Border)
    thumb.Visible = false
    local hovering = false
    local function updateThumb()
        local winH = sec.Content.AbsoluteWindowSize.Y
        local canH = sec.Content.AbsoluteCanvasSize.Y
        local scale = w.Scale.Scale
        thumb.Visible = hovering and canH > winH + 1
        if canH > winH and winH > 0 then
            local h = math.max(16, winH * winH / canH / scale)
            local track = winH / scale - h
            thumb.Size = UDim2.fromOffset(2, h)
            thumb.Position = UDim2.new(1, -4, 0, 25 + track * sec.Content.CanvasPosition.Y / (canH - winH))
        end
    end
    w:_connect(sec.Frame.MouseEnter, function() hovering = true; updateThumb() end)
    w:_connect(sec.Frame.MouseLeave, function() hovering = false; updateThumb() end)
    w:_connect(sec.Content:GetPropertyChangedSignal("AbsoluteCanvasSize"), updateThumb)
    w:_connect(sec.Content:GetPropertyChangedSignal("AbsoluteWindowSize"), updateThumb)
    w:_connect(sec.Content:GetPropertyChangedSignal("CanvasPosition"), function() w:_closePopup(); updateThumb() end)

    table.insert(self.Sections, sec)
    return sec
end
Tab.AddGroupbox = Tab.AddSection -- LinoriaLib compatibility alias

function Section:_row(text, height)
    self._order += 1
    local row = frame(self.Content, slug(text or "Row") .. "Row", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, height), self.Window.Theme.Panel)
    row.BackgroundTransparency = 1
    row.LayoutOrder = self._order
    return row
end

function Section:AddLabel(text, options)
    options = options or {}
    local row = self:_row(text, options.Height or 22)
    local caption = label(row, "Caption", text, UDim2.fromOffset(0, 0), UDim2.fromScale(1, 1),
        options.Accent and self.Window.Theme.Accent or (options.Muted and self.Window.Theme.Muted or self.Window.Theme.Text),
        options.TextSize)
    caption.TextWrapped = options.Wrapped == true
    if options.Tooltip then TooltipManager:Attach(row, options.Tooltip) end
    return caption
end

function Section:AddSpacer(height)
    return self:_row("Spacer", height or 6)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- TOGGLES (With Linoria Chained AddColorPicker & AddKeybind)
-- ─────────────────────────────────────────────────────────────────────────────
function Section:AddToggle(options)
    options = table.clone(options)
    if options.Default == nil then options.Default = false end
    local w = self.Window
    local row = self:_row(options.Text, 24)

    -- Right accessories container for inline colorpicker / keybind
    local accessories = frame(row, "Accessories", UDim2.new(1, -90, 0, 2), UDim2.fromOffset(90, 20), w.Theme.Panel)
    accessories.BackgroundTransparency = 1
    local accLayout = create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 5),
    }, accessories)

    local hit = button(row, "Toggle", UDim2.fromOffset(0, 2), UDim2.new(1, -95, 0, 20))
    local box = frame(hit, "Box", UDim2.fromOffset(0, 2), UDim2.fromOffset(14, 14), w.Theme.Field, w.Theme.Border)
    local fill = frame(box, "Fill", UDim2.fromOffset(1, 1), UDim2.new(1, -2, 1, -2), w.Theme.Accent)
    w:_accent(fill, "BackgroundColor3")

    local caption = label(hit, "Caption", options.Text, UDim2.fromOffset(20, -1), UDim2.new(1, -20, 1, 0), w.Theme.Text)

    local control = w:_register({Instance = row, Button = hit, Text = options.Text}, options, "Toggle", function(val)
        return type(val) == "boolean", val
    end, function(c)
        fill.Visible = c.Value
        fill.BackgroundTransparency = c.Disabled and 0.6 or 0
        caption.TextColor3 = c.Value and not c.Disabled and w.Theme.Text or w.Theme.Muted
        row:SetAttribute("Value", c.Value)
    end)

    w:_connect(hit.Activated, function()
        if not control.Disabled then control:SetValue(not control.Value) end
    end)
    w:_connect(hit.MouseEnter, function()
        if not control.Disabled then box.BorderColor3 = w.Theme.Accent end
    end)
    w:_connect(hit.MouseLeave, function()
        box.BorderColor3 = w.Theme.Border
    end)

    -- Linoria Feature: Chained AddColorPicker
    function control:AddColorPicker(colOptions)
        colOptions = table.clone(colOptions)
        colOptions.Text = colOptions.Text or (options.Text .. " Color")
        colOptions.Default = colOptions.Default or Color3.new(1, 1, 1)
        local picker = w:_colorPickerInline(accessories, colOptions)
        control.ColorPicker = picker
        return control
    end

    -- Linoria Feature: Chained AddKeybind
    function control:AddKeybind(keyOptions)
        keyOptions = table.clone(keyOptions)
        keyOptions.Text = keyOptions.Text or options.Text
        local kb = w:_keybindInline(accessories, keyOptions, function(active)
            control:SetValue(active)
        end)
        control.Keybind = kb
        return control
    end

    if options.Color then
        control:AddColorPicker({Default = options.Color, Flag = options.ColorFlag, Callback = options.ColorCallback})
    end

    return control
end

-- ─────────────────────────────────────────────────────────────────────────────
-- SLIDERS (With Prefix, Suffix, Rounding & Manual Input)
-- ─────────────────────────────────────────────────────────────────────────────
function Section:AddSlider(options)
    options = table.clone(options)
    local w = self.Window
    local min, max, step = options.Min or 0, options.Max or 100, options.Step or 1
    assert(finite(min) and finite(max) and finite(step) and max > min and step > 0, "Slider requires finite Min < Max and Step > 0")
    options.Default = options.Default or min
    local decimals = options.Decimals or options.Rounding or 0
    local prefix = options.Prefix or ""
    local suffix = options.Suffix or ""

    local row = self:_row(options.Text, 42)
    local caption = label(row, "Caption", options.Text, UDim2.fromOffset(0, 0), UDim2.new(1, -70, 0, 18), w.Theme.Muted)

    local valBox = create("TextBox", {
        Name = "Value",
        Position = UDim2.new(1, -70, 0, 0),
        Size = UDim2.fromOffset(70, 18),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Font = Enum.Font.Code,
        TextSize = 11,
        TextColor3 = w.Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Right,
        Text = "",
    }, row)

    local track = frame(row, "Track", UDim2.fromOffset(0, 20), UDim2.new(1, 0, 0, 14), w.Theme.Field, w.Theme.Border)
    local fill = frame(track, "Fill", UDim2.fromOffset(1, 1), UDim2.new(0, 0, 1, -2), w.Theme.Accent)
    w:_accent(fill, "BackgroundColor3")

    local hit = button(row, "Slider", UDim2.fromOffset(0, 18), UDim2.new(1, 0, 0, 20))

    local control = w:_register({Instance = row}, options, "Slider", function(val)
        if not finite(val) then return false end
        local clamped = math.clamp(val, min, max)
        local stepped = min + math.round((clamped - min) / step) * step
        return true, math.clamp(stepped, min, max)
    end, function(c)
        local frac = (c.Value - min) / (max - min)
        fill.Size = UDim2.new(frac, -2 * frac, 1, -2)
        valBox.Text = prefix .. formatNumber(c.Value, decimals) .. suffix
        valBox.TextEditable = not c.Disabled
        fill.BackgroundTransparency = c.Disabled and 0.65 or 0
        caption.TextTransparency = c.Disabled and 0.4 or 0
        row:SetAttribute("Value", c.Value)
    end)

    w:_connect(hit.InputBegan, function(input)
        if control.Disabled then return end
        local startX, width = track.AbsolutePosition.X, math.max(1, track.AbsoluteSize.X)
        w:_beginPointer(input, function(pos)
            if control.Disabled then return end
            local frac = math.clamp((pos.X - startX) / width, 0, 1)
            control:SetValue(min + frac * (max - min))
        end)
    end)

    w:_connect(valBox.Focused, function()
        valBox.Text = formatNumber(control.Value, decimals)
    end)
    w:_connect(valBox.FocusLost, function()
        local num = tonumber(valBox.Text)
        if finite(num) and not control.Disabled then
            control:SetValue(num)
        else
            control._draw(control)
        end
    end)

    return control
end

-- ─────────────────────────────────────────────────────────────────────────────
-- DROPDOWNS (Single-Select & Multi-Select with Search)
-- ─────────────────────────────────────────────────────────────────────────────
function Section:AddDropdown(options)
    options = table.clone(options)
    local items = table.clone(options.Options or options.Values or {})
    assert(#items > 0, "Dropdown needs at least one option")
    local isMulti = options.Multi == true
    local w = self.Window

    if isMulti then
        options.Default = type(options.Default) == "table" and options.Default or {}
    else
        options.Default = options.Default or items[1]
    end

    local row = self:_row(options.Text, 45)
    local caption = label(row, "Caption", options.Text, UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 18), w.Theme.Muted)

    local field = frame(row, "Field", UDim2.fromOffset(0, 20), UDim2.new(1, 0, 0, 22), w.Theme.Field, w.Theme.Border)
    local valLabel = label(field, "Value", "", UDim2.fromOffset(8, 0), UDim2.new(1, -26, 1, 0), w.Theme.Text, 12)
    local chevron = label(field, "Arrow", "▼", UDim2.new(1, -20, 0, 0), UDim2.fromOffset(16, 22), w.Theme.Muted, 10)
    chevron.TextXAlignment = Enum.TextXAlignment.Center

    local hit = button(field, "Open", UDim2.fromOffset(0, 0), UDim2.fromScale(1, 1))

    local function getDisplaySummary(val)
        if isMulti then
            local selected = {}
            for item, enabled in pairs(val) do
                if enabled then table.insert(selected, item) end
            end
            if #selected == 0 then return "None" end
            if #selected <= 2 then return table.concat(selected, ", ") end
            return string.format("[%d Selected]", #selected)
        end
        return tostring(val)
    end

    local control = w:_register({Instance = row, Multi = isMulti}, options, "Dropdown", function(val)
        if isMulti then
            if type(val) ~= "table" then return false end
            local normalized = {}
            for _, item in ipairs(items) do
                normalized[item] = val[item] == true
            end
            return true, normalized
        else
            return type(val) == "string" and table.find(items, val) ~= nil, val
        end
    end, function(c)
        valLabel.Text = getDisplaySummary(c.Value)
        valLabel.TextColor3 = c.Disabled and w.Theme.Muted or w.Theme.Text
        row:SetAttribute("Value", isMulti and HttpService:JSONEncode(c.Value) or c.Value)
    end)

    function control:SetValues(newItems)
        items = table.clone(newItems)
        if not isMulti and not table.find(items, self.Value) then
            self:SetValue(items[1])
        end
    end

    w:_connect(hit.Activated, function()
        if control.Disabled then return end
        local fieldW = field.AbsoluteSize.X / w.Scale.Scale
        local maxVisible = math.min(#items, 7)
        local popupH = maxVisible * 24 + 8

        local pop = w:_openPopup(field, fieldW, popupH)
        local list = create("ScrollingFrame", {
            Name = "List",
            Position = UDim2.fromOffset(2, 4),
            Size = UDim2.new(1, -4, 1, -8),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.fromOffset(0, #items * 24),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = w.Theme.Accent,
            ZIndex = 36,
        }, pop)

        for i, item in ipairs(items) do
            local choice = button(list, slug(item), UDim2.fromOffset(0, (i - 1) * 24), UDim2.new(1, 0, 0, 24))
            choice.ZIndex = 37
            choice.BackgroundColor3 = w.Theme.Field

            local isSelected = isMulti and (control.Value[item] == true) or (control.Value == item)
            choice.BackgroundTransparency = isSelected and 0.4 or 1

            local checkmark = label(choice, "Check", isSelected and "✓" or "", UDim2.fromOffset(6, 0), UDim2.fromOffset(16, 24), w.Theme.Accent, 12)
            checkmark.ZIndex = 38

            local itemLabel = label(choice, "Text", item, UDim2.fromOffset(24, 0), UDim2.new(1, -28, 1, 0), isSelected and w.Theme.Accent or w.Theme.Text, 12)
            itemLabel.ZIndex = 38

            choice.MouseEnter:Connect(function()
                choice.BackgroundTransparency = 0.2
            end)
            choice.MouseLeave:Connect(function()
                local active = isMulti and (control.Value[item] == true) or (control.Value == item)
                choice.BackgroundTransparency = active and 0.4 or 1
            end)

            choice.Activated:Connect(function()
                if control.Disabled then return end
                if isMulti then
                    local current = table.clone(control.Value)
                    current[item] = not current[item]
                    control:SetValue(current)
                    local active = current[item] == true
                    checkmark.Text = active and "✓" or ""
                    itemLabel.TextColor3 = active and w.Theme.Accent or w.Theme.Text
                    choice.BackgroundTransparency = active and 0.4 or 1
                else
                    control:SetValue(item)
                    w:_closePopup()
                end
            end)
        end
    end)

    return control
end

-- ─────────────────────────────────────────────────────────────────────────────
-- COLOR PICKERS (Full Modal with HSV Square, Hue, Alpha, Hex & Presets)
-- ─────────────────────────────────────────────────────────────────────────────
function Window:_colorPickerModal(anchor, options, control)
    local w = self
    local pop = w:_openPopup(anchor, 230, 256)
    label(pop, "Title", options.Text or "Color Picker", UDim2.fromOffset(10, 5), UDim2.new(1, -20, 0, 20), w.Theme.Text, 12, Enum.Font.Code).ZIndex = 36

    local h, s, v = control.Value.Color:ToHSV()
    local a = control.Value.Transparency or 0

    -- SV Square
    local svBox = frame(pop, "SaturationValue", UDim2.fromOffset(10, 30), UDim2.fromOffset(180, 140), Color3.fromHSV(h, 1, 1))
    svBox.ZIndex = 36
    local white = frame(svBox, "White", UDim2.fromOffset(0, 0), UDim2.fromScale(1, 1), Color3.new(1, 1, 1))
    white.ZIndex = 37
    local wg = gradient(white, Color3.new(1, 1, 1), Color3.new(1, 1, 1), 0)
    wg.Transparency = NumberSequence.new(0, 1)

    local black = frame(svBox, "Black", UDim2.fromOffset(0, 0), UDim2.fromScale(1, 1), Color3.new(0, 0, 0))
    black.ZIndex = 38
    local bg = gradient(black, Color3.new(1, 1, 1), Color3.new(1, 1, 1), 90)
    bg.Transparency = NumberSequence.new(1, 0)

    local cursor = frame(svBox, "Cursor", UDim2.fromScale(s, 1 - v), UDim2.fromOffset(6, 6), Color3.new(1, 1, 1), Color3.new(0, 0, 0))
    cursor.AnchorPoint = Vector2.new(0.5, 0.5)
    cursor.ZIndex = 40

    local svHit = button(svBox, "Drag", UDim2.fromOffset(0, 0), UDim2.fromScale(1, 1))
    svHit.ZIndex = 39

    -- Hue Slider
    local hueBar = frame(pop, "Hue", UDim2.fromOffset(198, 30), UDim2.fromOffset(18, 140), Color3.new(1, 1, 1))
    hueBar.ZIndex = 36
    local hueKeys = {}
    for i = 0, 6 do table.insert(hueKeys, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1))) end
    create("UIGradient", {Color = ColorSequence.new(hueKeys), Rotation = 90}, hueBar)
    local hueCursor = frame(hueBar, "Cursor", UDim2.fromScale(0, h), UDim2.new(1, 0, 0, 2), Color3.new(1, 1, 1))
    hueCursor.ZIndex = 38
    local hueHit = button(hueBar, "Drag", UDim2.fromOffset(-2, 0), UDim2.new(1, 4, 1, 0))
    hueHit.ZIndex = 37

    -- Alpha Slider
    local alphaBar = frame(pop, "Opacity", UDim2.fromOffset(10, 178), UDim2.fromOffset(206, 14), Color3.fromRGB(120, 130, 140))
    alphaBar.ZIndex = 36
    checker(alphaBar)
    local alphaColor = frame(alphaBar, "Tint", UDim2.fromOffset(0, 0), UDim2.fromScale(1, 1), control.Value.Color)
    alphaColor.ZIndex = 37
    local ag = gradient(alphaColor, Color3.new(1, 1, 1), Color3.new(1, 1, 1), 0)
    ag.Transparency = NumberSequence.new(0, 1)
    local alphaCursor = frame(alphaBar, "Cursor", UDim2.fromScale(a, 0), UDim2.new(0, 2, 1, 0), Color3.new(1, 1, 1))
    alphaCursor.ZIndex = 39
    local alphaHit = button(alphaBar, "Drag", UDim2.fromOffset(0, -2), UDim2.new(1, 0, 1, 4))
    alphaHit.ZIndex = 38

    -- Hex Input
    local hexBox = create("TextBox", {
        Name = "Hex",
        Position = UDim2.fromOffset(10, 202),
        Size = UDim2.fromOffset(100, 22),
        BackgroundColor3 = w.Theme.Field,
        BorderColor3 = w.Theme.Border,
        BorderSizePixel = 1,
        Font = Enum.Font.Code,
        TextSize = 11,
        TextColor3 = w.Theme.Text,
        ClearTextOnFocus = false,
        ZIndex = 36,
    }, pop)

    -- Preset Quick Swatches
    local presetColors = {
        Color3.fromRGB(240, 80, 95),  -- Red
        Color3.fromRGB(60, 210, 150), -- Green
        Color3.fromRGB(35, 125, 255), -- Blue
        Color3.fromRGB(20, 205, 185), -- Zen Cyan
        Color3.fromRGB(255, 185, 25), -- Yellow
        Color3.fromRGB(160, 90, 240), -- Purple
    }
    local swatches = frame(pop, "Presets", UDim2.fromOffset(116, 202), UDim2.fromOffset(100, 22), w.Theme.Panel)
    swatches.BackgroundTransparency = 1
    create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 3)}, swatches)

    local function refresh(commit)
        local col = Color3.fromHSV(h, s, v)
        svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        cursor.Position = UDim2.fromScale(s, 1 - v)
        hueCursor.Position = UDim2.new(0, 0, h, -h * 2)
        alphaCursor.Position = UDim2.new(a, -a * 2, 0, 0)
        alphaColor.BackgroundColor3 = col
        hexBox.Text = "#" .. col:ToHex():upper()
        if commit then
            control:SetValue({Color = col, Transparency = a})
        end
    end

    for _, pcol in ipairs(presetColors) do
        local sw = button(swatches, "P", UDim2.fromOffset(0, 0), UDim2.fromOffset(13, 20))
        sw.BackgroundColor3 = pcol
        sw.BackgroundTransparency = 0
        sw.BorderSizePixel = 1
        sw.BorderColor3 = w.Theme.Border
        sw.ZIndex = 37
        sw.Activated:Connect(function()
            h, s, v = pcol:ToHSV()
            refresh(true)
        end)
    end

    local function rel(pos, target)
        return (pos - target.AbsolutePosition) / target.AbsoluteSize
    end

    svHit.InputBegan:Connect(function(input)
        w:_beginPointer(input, function(pos)
            local pt = rel(pos, svBox)
            s, v = math.clamp(pt.X, 0, 1), 1 - math.clamp(pt.Y, 0, 1)
            refresh(true)
        end)
    end)
    hueHit.InputBegan:Connect(function(input)
        w:_beginPointer(input, function(pos)
            h = math.clamp(rel(pos, hueBar).Y, 0, 1)
            refresh(true)
        end)
    end)
    alphaHit.InputBegan:Connect(function(input)
        w:_beginPointer(input, function(pos)
            a = math.clamp(rel(pos, alphaBar).X, 0, 1)
            refresh(true)
        end)
    end)

    hexBox.FocusLost:Connect(function()
        local txt = hexBox.Text:gsub("#", "")
        if #txt == 6 and txt:match("^%x+$") then
            h, s, v = Color3.fromHex(txt):ToHSV()
            refresh(true)
        else
            refresh(false)
        end
    end)

    refresh(false)
end

function Window:_colorPickerInline(parent, options)
    local w = self
    local swatch = frame(parent, "InlineSwatch", UDim2.fromOffset(0, 0), UDim2.fromOffset(16, 14), w.Theme.Field, w.Theme.Border)
    swatch.LayoutOrder = 10
    checker(swatch)

    local tint = frame(swatch, "Tint", UDim2.fromOffset(0, 0), UDim2.fromScale(1, 1), Color3.new(1, 1, 1))
    tint.ZIndex = 2

    local hit = button(swatch, "Open", UDim2.fromOffset(-2, -2), UDim2.new(1, 4, 1, 4))
    hit.ZIndex = 3

    local control = w:_register({Instance = swatch}, options, "Color", function(val)
        if typeof(val) == "Color3" then val = {Color = val, Transparency = 0} end
        if type(val) ~= "table" or typeof(val.Color) ~= "Color3" or not finite(val.Transparency) then return false end
        return true, {Color = val.Color, Transparency = math.clamp(val.Transparency, 0, 1)}
    end, function(c)
        tint.BackgroundColor3 = c.Value.Color
        tint.BackgroundTransparency = c.Value.Transparency
    end)

    w:_connect(hit.Activated, function()
        if control.Disabled then return end
        w:_colorPickerModal(swatch, options, control)
    end)

    return control
end

function Section:AddColorPicker(options)
    options = table.clone(options)
    if typeof(options.Default) == "Color3" then
        options.Default = {Color = options.Default, Transparency = 0}
    end
    options.Default = options.Default or {Color = Color3.new(1, 1, 1), Transparency = 0}

    local row = self:_row(options.Text, 24)
    label(row, "Caption", options.Text, UDim2.fromOffset(0, 0), UDim2.new(1, -30, 1, 0), self.Window.Theme.Text)
    return self.Window:_colorPickerInline(row, options)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- KEYBINDS (Inline & Section Levels with Linoria Modes: Toggle/Hold/Always)
-- ─────────────────────────────────────────────────────────────────────────────
function Window:_keybindInline(parent, options, onActiveStateChanged)
    local w = self
    options = table.clone(options)
    options.Default = options.Default or Enum.KeyCode.RightShift
    local mode = options.Mode or "Toggle" -- Toggle, Hold, Always

    local hit = button(parent, "InlineKeybind", UDim2.fromOffset(0, 0), UDim2.fromOffset(48, 16))
    hit.LayoutOrder = 5
    hit.BackgroundTransparency = 0
    hit.BackgroundColor3 = w.Theme.Field
    hit.BorderSizePixel = 1
    hit.BorderColor3 = w.Theme.Border

    local text = label(hit, "Key", "", UDim2.fromOffset(0, 0), UDim2.fromScale(1, 1), w.Theme.Muted, 10, Enum.Font.Code)
    text.TextXAlignment = Enum.TextXAlignment.Center

    local control = w:_register({
        Instance = hit,
        Mode = mode,
        Active = false,
        _pressed = options.Callback or options.OnPressed or onActiveStateChanged,
        Text = options.Text or "Keybind",
    }, options, "Keybind", function(val)
        return typeof(val) == "EnumItem" and val.EnumType == Enum.KeyCode and val ~= Enum.KeyCode.Unknown, val
    end, function(c)
        text.Text = "[" .. c.Value.Name .. "]"
        text.TextColor3 = c.Active and w.Theme.Accent or w.Theme.Muted
        if w.KeybindsHUD then
            w.KeybindsHUD:UpdateEntry(c.Flag or c.Instance.Name, c.Text, c.Value.Name, c.Mode, c.Active)
        end
    end)

    w:_connect(hit.Activated, function()
        if control.Disabled then return end
        if w._capturing then w._capturing._draw(w._capturing) end
        w._capturing = control
        text.Text = "..."
        text.TextColor3 = w.Theme.Accent
    end)

    -- Right-click on keybind toggles Mode (Toggle -> Hold -> Always)
    w:_connect(hit.MouseButton2Click, function()
        if control.Disabled then return end
        if control.Mode == "Toggle" then
            control.Mode = "Hold"
        elseif control.Mode == "Hold" then
            control.Mode = "Always"
            control.Active = true
            w:_callback(control._pressed, true)
        else
            control.Mode = "Toggle"
            control.Active = false
            w:_callback(control._pressed, false)
        end
        control:_draw(control)
    end)

    return control
end

function Section:AddKeybind(options)
    options = table.clone(options)
    local row = self:_row(options.Text, 24)
    label(row, "Caption", options.Text, UDim2.fromOffset(0, 0), UDim2.new(1, -60, 1, 0), self.Window.Theme.Text)
    return self.Window:_keybindInline(row, options)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- BUTTONS (Single & Dual Buttons Linoria Style)
-- ─────────────────────────────────────────────────────────────────────────────
function Section:AddButton(options)
    local w = self.Window
    local row = self:_row(options.Text or "Button", 28)

    local hit = button(row, "Btn", UDim2.fromOffset(0, 2), UDim2.new(1, 0, 0, 22))
    hit.BackgroundTransparency = 0
    hit.BackgroundColor3 = w.Theme.Field
    hit.BorderSizePixel = 1
    hit.BorderColor3 = w.Theme.Border

    local caption = label(hit, "Caption", options.Text, UDim2.fromOffset(0, 0), UDim2.fromScale(1, 1), w.Theme.Text, 12)
    caption.TextXAlignment = Enum.TextXAlignment.Center

    local control = {Instance = row, Disabled = options.Disabled == true}
    function control:SetDisabled(val)
        self.Disabled = val == true
        caption.TextColor3 = self.Disabled and w.Theme.Muted or w.Theme.Text
    end

    w:_connect(hit.Activated, function()
        if not control.Disabled then w:_callback(options.Callback or options.Func) end
    end)
    w:_connect(hit.MouseEnter, function()
        if not control.Disabled then hit.BorderColor3 = w.Theme.Accent end
    end)
    w:_connect(hit.MouseLeave, function()
        hit.BorderColor3 = w.Theme.Border
    end)

    return control
end

function Section:AddButtons(list)
    local w = self.Window
    local count = #list
    local row = self:_row("ButtonGroup", 28)

    for i, item in ipairs(list) do
        local btnWidth = 1 / count
        local hit = button(row, slug(item.Text), UDim2.new((i - 1) * btnWidth, (i > 1 and 2 or 0), 0, 2), UDim2.new(btnWidth, -4, 0, 22))
        hit.BackgroundTransparency = 0
        hit.BackgroundColor3 = w.Theme.Field
        hit.BorderSizePixel = 1
        hit.BorderColor3 = w.Theme.Border

        local caption = label(hit, "Caption", item.Text, UDim2.fromOffset(0, 0), UDim2.fromScale(1, 1), w.Theme.Text, 12)
        caption.TextXAlignment = Enum.TextXAlignment.Center

        w:_connect(hit.Activated, function()
            w:_callback(item.Callback or item.Func)
        end)
        w:_connect(hit.MouseEnter, function() hit.BorderColor3 = w.Theme.Accent end)
        w:_connect(hit.MouseLeave, function() hit.BorderColor3 = w.Theme.Border end)
    end
    return row
end

-- ─────────────────────────────────────────────────────────────────────────────
-- TEXTBOXES
-- ─────────────────────────────────────────────────────────────────────────────
function Section:AddTextbox(options)
    options = table.clone(options)
    options.Default = options.Default or ""
    local w = self.Window
    local h = options.Height or 22
    local row = self:_row(options.Text, h + 24)

    label(row, "Caption", options.Text, UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 18), w.Theme.Muted)

    local field = create("TextBox", {
        Name = "Input",
        Position = UDim2.fromOffset(0, 20),
        Size = UDim2.new(1, 0, 0, h),
        BackgroundColor3 = w.Theme.Field,
        BorderColor3 = w.Theme.Border,
        BorderSizePixel = 1,
        Font = options.Multiline and Enum.Font.Code or Enum.Font.Arial,
        TextSize = 12,
        TextColor3 = w.Theme.Text,
        PlaceholderColor3 = w.Theme.Muted,
        PlaceholderText = options.Placeholder or "",
        ClearTextOnFocus = options.ClearTextOnFocus == true,
        MultiLine = options.Multiline == true,
        TextWrapped = options.Multiline == true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = options.Multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
    }, row)
    create("UIPadding", {PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6)}, field)

    local control = w:_register({Instance = row, TextBox = field}, options, "Textbox", function(val)
        return type(val) == "string", tostring(val)
    end, function(c)
        field.Text = c.Value
        field.TextEditable = not c.Disabled
        field.TextColor3 = c.Disabled and w.Theme.Muted or w.Theme.Text
    end)

    w:_connect(field.FocusLost, function()
        if not control.Disabled then
            control:SetValue(field.Text)
        else
            control._draw(control)
        end
    end)

    return control
end

-- ─────────────────────────────────────────────────────────────────────────────
-- DEPENDENCY BOXES (Linoria Style Dynamic Containers)
-- ─────────────────────────────────────────────────────────────────────────────
function Section:AddDependencyBox()
    local w = self.Window
    local sec = self
    self._order += 1

    local boxFrame = frame(self.Content, "DependencyBox", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 0), w.Theme.Panel)
    boxFrame.BackgroundTransparency = 1
    boxFrame.LayoutOrder = self._order
    boxFrame.Visible = false
    boxFrame.AutomaticSize = Enum.AutomaticSize.Y

    create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)}, boxFrame)

    local depBox = {
        Frame = boxFrame,
        Section = sec,
        _order = 0,
        Dependencies = {},
    }

    function depBox:_row(text, height)
        self._order += 1
        local r = frame(boxFrame, slug(text or "DepRow") .. "Row", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, height), w.Theme.Panel)
        r.BackgroundTransparency = 1
        r.LayoutOrder = self._order
        return r
    end

    function depBox:AddToggle(opts)
        local savedContent = sec.Content
        sec.Content = boxFrame
        local ctrl = sec:AddToggle(opts)
        sec.Content = savedContent
        return ctrl
    end

    function depBox:AddSlider(opts)
        local savedContent = sec.Content
        sec.Content = boxFrame
        local ctrl = sec:AddSlider(opts)
        sec.Content = savedContent
        return ctrl
    end

    function depBox:AddDropdown(opts)
        local savedContent = sec.Content
        sec.Content = boxFrame
        local ctrl = sec:AddDropdown(opts)
        sec.Content = savedContent
        return ctrl
    end

    function depBox:SetupDependencies(depList)
        -- depList is an array of { control, expectedValue }
        self.Dependencies = depList
        local function check()
            local allPassed = true
            for _, item in ipairs(self.Dependencies) do
                local ctrl, expected = item[1], item[2]
                if ctrl.GetValue and ctrl:GetValue() ~= expected then
                    allPassed = false
                    break
                end
            end
            boxFrame.Visible = allPassed
        end
        for _, item in ipairs(self.Dependencies) do
            item[1]:OnChanged(check)
        end
        check()
        return self
    end

    return depBox
end

-- Export ZenUI
getgenv = getgenv or function() return _G end
getgenv().ZenUI = ZenUI
getgenv().Library = ZenUI

return ZenUI
