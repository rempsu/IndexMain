local UserInputService = game:GetService("UserInputService")

local function buildUI(parent, settings, toggleKey)
    local uivisible = true
    local previous_mouse_behavior = UserInputService.MouseBehavior
    local previous_mouse_icon = UserInputService.MouseIconEnabled

    -- ─── palette (samet.exe dark theme) ───────────────────────────
    local c = {
        WindowBg      = Color3.fromRGB(43,  43,  43),
        Inline        = Color3.fromRGB(12,  12,  12),
        SectionBg     = Color3.fromRGB(19,  19,  19),
        Element       = Color3.fromRGB(63,  63,  63),
        Border        = Color3.fromRGB(68,  68,  68),
        Outline       = Color3.fromRGB(0,   0,   0),
        DarkLiner     = Color3.fromRGB(56,  56,  56),
        Text          = Color3.fromRGB(180, 180, 180),
        Accent        = Color3.fromRGB(31,  226, 130),
        Risky         = Color3.fromRGB(255, 50,  50),
    }

    -- ─── helpers ──────────────────────────────────────────────────
    local function inst(cls, props)
        local o = Instance.new(cls)
        for k, v in pairs(props) do o[k] = v end
        return o
    end

    local function stroke(parent, color)
        return inst("UIStroke", {
            Parent           = parent,
            Color            = color or c.Border,
            Thickness        = 1,
            ApplyStrokeMode  = Enum.ApplyStrokeMode.Border,
            LineJoinMode     = Enum.LineJoinMode.Miter,
        })
    end

    local function gradient90(parent, bright, dark)
        return inst("UIGradient", {
            Parent   = parent,
            Rotation = 90,
            Color    = ColorSequence.new{
                ColorSequenceKeypoint.new(0, bright or Color3.fromRGB(255,255,255)),
                ColorSequenceKeypoint.new(1, dark   or Color3.fromRGB(127,127,127)),
            },
        })
    end

    local function tween(obj, props, t)
        game:GetService("TweenService"):Create(
            obj,
            TweenInfo.new(t or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            props
        ):Play()
    end

    -- ─── root ScreenGui ───────────────────────────────────────────
    local screen = inst("ScreenGui", {
        Parent         = parent,
        Name           = "index.lol",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        IgnoreGuiInset = true,
    })

    local function setVisible(v)
        screen.Enabled = v
        if v then
            UserInputService.MouseBehavior    = Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled = true
        else
            UserInputService.MouseBehavior    = previous_mouse_behavior
            UserInputService.MouseIconEnabled = previous_mouse_icon
        end
        uivisible = v
    end

    -- ─── outer outline frame ──────────────────────────────────────
    local outline = inst("Frame", {
        Parent            = screen,
        AnchorPoint       = Vector2.new(0.5, 0.5),
        Position          = UDim2.new(0.5, 0, 0.5, 0),
        Size              = UDim2.new(0, 220, 0, 0),   -- width fixed, height auto
        AutomaticSize     = Enum.AutomaticSize.Y,
        BackgroundColor3  = c.WindowBg,
        BorderSizePixel   = 2,
        BorderColor3      = c.Outline,
    })
    stroke(outline, c.Border)

    -- inner inline panel
    local inlinePanel = inst("Frame", {
        Parent           = outline,
        Position         = UDim2.new(0, 5, 0, 5),
        Size             = UDim2.new(1, -10, 1, -10),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = c.Inline,
        BorderSizePixel  = 2,
        BorderColor3     = c.Border,
    })
    stroke(inlinePanel, c.Outline)

    inst("UIListLayout", {
        Parent        = inlinePanel,
        SortOrder     = Enum.SortOrder.LayoutOrder,
        Padding       = UDim.new(0, 0),
    })

    -- top accent liner
    local liner = inst("Frame", {
        Parent           = inlinePanel,
        Size             = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = c.Accent,
        BorderSizePixel  = 0,
        LayoutOrder      = 0,
        ZIndex           = 2,
    })
    gradient90(liner)

    -- ─── dragging ─────────────────────────────────────────────────
    do
        local dragging, dragStart, startPos
        outline.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging  = true
                dragStart = input.Position
                startPos  = outline.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local d = input.Position - dragStart
                tween(outline, {
                    Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + d.X,
                        startPos.Y.Scale, startPos.Y.Offset + d.Y
                    )
                }, 0.15)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    -- ─── title row ────────────────────────────────────────────────
    local titleRow = inst("Frame", {
        Parent           = inlinePanel,
        Size             = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        LayoutOrder      = 1,
    })
    inst("TextLabel", {
        Parent               = titleRow,
        Text                 = "index.lol",
        Font                 = Enum.Font.GothamBold,
        TextSize             = 11,
        TextColor3           = c.Text,
        BackgroundTransparency = 1,
        Size                 = UDim2.new(1, 0, 1, 0),
        TextXAlignment       = Enum.TextXAlignment.Center,
        BorderSizePixel      = 0,
    })

    -- thin divider under title
    inst("Frame", {
        Parent           = inlinePanel,
        Size             = UDim2.new(1, -16, 0, 1),
        Position         = UDim2.new(0, 8, 0, 0),
        BackgroundColor3 = c.Border,
        BorderSizePixel  = 0,
        LayoutOrder      = 2,
    })

    -- ─── section builder ──────────────────────────────────────────
    local function makeSection(name, order)
        local sec = inst("Frame", {
            Parent           = inlinePanel,
            Size             = UDim2.new(1, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            BackgroundColor3 = c.SectionBg,
            BorderSizePixel  = 2,
            BorderColor3     = c.Outline,
            LayoutOrder      = order,
        })
        stroke(sec, c.Border)

        -- section accent top bar
        local secLiner = inst("Frame", {
            Parent           = sec,
            Size             = UDim2.new(0, 0, 0, 2),  -- auto X
            AutomaticSize    = Enum.AutomaticSize.X,
            Position         = UDim2.new(0, 2, 0, -2),
            BackgroundColor3 = c.Accent,
            BorderSizePixel  = 0,
            ZIndex           = 2,
        })
        inst("UIGradient", {
            Parent       = secLiner,
            Color        = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(226,226,226)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
            },
            Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0,   0.51),
                NumberSequenceKeypoint.new(0.42, 0.77),
                NumberSequenceKeypoint.new(1,   1),
            },
        })

        -- section label
        local labelBg = inst("TextLabel", {
            Parent               = secLiner,
            Text                 = name,
            Font                 = Enum.Font.GothamBold,
            TextSize             = 10,
            TextColor3           = c.Text,
            BackgroundColor3     = c.SectionBg,
            Size                 = UDim2.new(0, 0, 0, 13),
            AutomaticSize        = Enum.AutomaticSize.X,
            Position             = UDim2.new(0, 9, 0, 0),
            BorderSizePixel      = 0,
        })
        inst("UIPadding", {
            Parent       = labelBg,
            PaddingLeft  = UDim.new(0, 3),
            PaddingRight = UDim.new(0, 4),
        })

        -- content frame inside section
        local content = inst("Frame", {
            Parent               = sec,
            BackgroundTransparency = 1,
            Position             = UDim2.new(0, 10, 0, 15),
            Size                 = UDim2.new(1, -20, 0, 0),
            AutomaticSize        = Enum.AutomaticSize.Y,
            BorderSizePixel      = 0,
        })
        inst("UIListLayout", {
            Parent    = content,
            Padding   = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        inst("UIPadding", {
            Parent        = content,
            PaddingBottom = UDim.new(0, 10),
        })

        return content
    end

    -- ─── toggle row builder ───────────────────────────────────────
    local function makeToggle(parent, label, key, order)
        local row = inst("TextButton", {
            Parent               = parent,
            Size                 = UDim2.new(1, 0, 0, 15),
            BackgroundTransparency = 1,
            BorderSizePixel      = 0,
            Text                 = "",
            AutoButtonColor      = false,
            LayoutOrder          = order,
        })

        -- indicator box (samet.exe style square indicator)
        local indicator = inst("Frame", {
            Parent           = row,
            AnchorPoint      = Vector2.new(0, 0.5),
            Position         = UDim2.new(0, 0, 0.5, 0),
            Size             = UDim2.new(0, 10, 0, 10),
            BackgroundColor3 = settings[key] and c.Accent or c.Element,
            BorderSizePixel  = 0,
        })
        stroke(indicator, c.Outline)
        gradient90(indicator)

        local lbl = inst("TextLabel", {
            Parent               = row,
            Text                 = label,
            Font                 = Enum.Font.Gotham,
            TextSize             = 12,
            TextColor3           = settings[key] and c.Accent or c.Text,
            BackgroundTransparency = 1,
            Size                 = UDim2.new(1, -18, 1, 0),
            Position             = UDim2.new(0, 18, 0, -1),
            TextXAlignment       = Enum.TextXAlignment.Left,
            BorderSizePixel      = 0,
        })

        row.MouseButton1Down:Connect(function()
            settings[key] = not settings[key]
            local on = settings[key]
            tween(indicator, { BackgroundColor3 = on and c.Accent or c.Element })
            tween(lbl,       { TextColor3       = on and c.Accent or c.Text  })
        end)

        return row
    end

    -- ─── sections & toggles ───────────────────────────────────────
    local visualsContent = makeSection("visuals", 3)
    makeToggle(visualsContent, "boxes",       "showboxes",  1)
    makeToggle(visualsContent, "weapon info", "showweapon", 2)

    -- ─── keybind section ──────────────────────────────────────────
    local keybindContent = makeSection("keybind", 4)

    local currentKey = toggleKey
    local rebinding  = false

    -- label row
    local kbRow = inst("Frame", {
        Parent               = keybindContent,
        Size                 = UDim2.new(1, 0, 0, 17),
        BackgroundTransparency = 1,
        BorderSizePixel      = 0,
        LayoutOrder          = 1,
    })
    inst("TextLabel", {
        Parent               = kbRow,
        Text                 = "toggle ui",
        Font                 = Enum.Font.Gotham,
        TextSize             = 12,
        TextColor3           = c.Text,
        BackgroundTransparency = 1,
        Size                 = UDim2.new(1, -80, 1, 0),
        TextXAlignment       = Enum.TextXAlignment.Left,
        BorderSizePixel      = 0,
    })

    -- key chip (samet.exe element button style)
    local keyChip = inst("TextButton", {
        Parent           = kbRow,
        Text             = currentKey.Name,
        Font             = Enum.Font.GothamMedium,
        TextSize         = 10,
        TextColor3       = c.Text,
        BackgroundColor3 = c.Element,
        AnchorPoint      = Vector2.new(1, 0.5),
        Position         = UDim2.new(1, 0, 0.5, 0),
        Size             = UDim2.new(0, 74, 0, 15),
        BorderSizePixel  = 0,
        AutoButtonColor  = false,
    })
    stroke(keyChip, c.Outline)
    gradient90(keyChip)

    keyChip.MouseButton1Click:Connect(function()
        if rebinding then return end
        rebinding = true
        keyChip.Text      = "press key..."
        tween(keyChip, { TextColor3 = c.Accent })

        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey        = input.KeyCode
                keyChip.Text      = currentKey.Name
                tween(keyChip, { TextColor3 = c.Text })
                rebinding = false
                conn:Disconnect()
            end
        end)
    end)

    -- ─── keybind listener (toggle UI) ─────────────────────────────
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == currentKey then
            setVisible(not uivisible)
        end
    end)

    setVisible(uivisible)

    return {
        gui          = screen,
        setVisible   = setVisible,
        getVisible   = function() return uivisible end,
        getToggleKey = function() return currentKey end,
    }
end

return buildUI
