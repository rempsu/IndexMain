local UserInputService = game:GetService("UserInputService")

local function buildUI(parent, settings, toggleKey)
    local uivisible = true
    local previous_mouse_behavior = UserInputService.MouseBehavior
    local previous_mouse_icon = UserInputService.MouseIconEnabled

    local c = {
        BG         = Color3.fromRGB(18, 18, 18),
        Surface    = Color3.fromRGB(26, 26, 26),
        Elevated   = Color3.fromRGB(34, 34, 34),
        Border     = Color3.fromRGB(50, 50, 50),
        TextPrimary   = Color3.fromRGB(240, 240, 240),
        TextSecondary = Color3.fromRGB(140, 140, 140),
        Accent     = Color3.fromRGB(80, 180, 120),
        ToggleOff  = Color3.fromRGB(55, 55, 55),
    }

    local function corner(parent, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 8)
        c.Parent = parent
        return c
    end

    local function stroke(parent, color, thickness)
        local s = Instance.new("UIStroke")
        s.Color = color or c.Border
        s.Thickness = thickness or 1
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent = parent
        return s
    end

    local function set_ui_visible(visible)
        panel.Visible = visible
        if visible then
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled = true
        else
            UserInputService.MouseBehavior = previous_mouse_behavior
            UserInputService.MouseIconEnabled = previous_mouse_icon
        end
        uivisible = visible
    end

    local function section(title, order)
        local s = Instance.new("Frame")
        s.Name = title .. " section"
        s.Size = UDim2.new(1, 0, 0, 0)
        s.AutomaticSize = Enum.AutomaticSize.Y
        s.BackgroundTransparency = 1
        s.BorderSizePixel = 0
        s.LayoutOrder = order
        s.Parent = panel

        local spad = Instance.new("UIPadding")
        spad.PaddingLeft = UDim.new(0, 16)
        spad.PaddingRight = UDim.new(0, 16)
        spad.PaddingTop = UDim.new(0, 14)
        spad.PaddingBottom = UDim.new(0, 4)
        spad.Parent = s

        local slayout = Instance.new("UIListLayout")
        slayout.SortOrder = Enum.SortOrder.LayoutOrder
        slayout.Padding = UDim.new(0, 4)
        slayout.Parent = s

        local slabel = Instance.new("TextLabel")
        slabel.Text = title
        slabel.TextSize = 10
        slabel.Font = Enum.Font.GothamBold
        slabel.TextColor3 = c.TextSecondary
        slabel.BackgroundTransparency = 1
        slabel.TextXAlignment = Enum.TextXAlignment.Left
        slabel.Size = UDim2.new(1, 0, 0, 16)
        slabel.LayoutOrder = 0
        slabel.Parent = s

        local div = Instance.new("Frame")
        div.Size = UDim2.new(1, 0, 0, 1)
        div.BackgroundColor3 = c.Border
        div.BorderSizePixel = 0
        div.LayoutOrder = 0
        div.Parent = s

        return s
    end

    local current_toggle_key = toggleKey

    local function toggleRow(parent, text, key, order)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 36)
        row.BackgroundTransparency = 1
        row.BorderSizePixel = 0
        row.LayoutOrder = order
        row.Parent = parent

        local row_label = Instance.new("TextLabel")
        row_label.Text = text
        row_label.TextSize = 13
        row_label.Font = Enum.Font.Gotham
        row_label.TextColor3 = c.TextPrimary
        row_label.BackgroundTransparency = 1
        row_label.TextXAlignment = Enum.TextXAlignment.Left
        row_label.Size = UDim2.new(1, -50, 1, 0)
        row_label.Parent = row

        local track = Instance.new("Frame")
        track.Size = UDim2.new(0, 36, 0, 20)
        track.Position = UDim2.new(1, -36, 0.5, -10)
        track.BackgroundColor3 = settings[key] and c.Accent or c.ToggleOff
        track.BorderSizePixel = 0
        track.Parent = row
        corner(track, 10)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.Position = settings[key]
            and UDim2.new(1, -17, 0.5, -7)
            or UDim2.new(0, 3, 0.5, -7)
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        knob.BorderSizePixel = 0
        knob.Parent = track
        corner(knob, 7)

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = row

        btn.MouseButton1Click:Connect(function()
            settings[key] = not settings[key]
            local on = settings[key]
            track.BackgroundColor3 = on and c.Accent or c.ToggleOff
            knob.Position = on
                and UDim2.new(1, -17, 0.5, -7)
                or UDim2.new(0, 3, 0.5, -7)
        end)

        return row
    end

    local screen_gui = Instance.new("ScreenGui")
    screen_gui.Name = "index.lol"
    screen_gui.ResetOnSpawn = false
    screen_gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen_gui.Parent = parent

    local panel = Instance.new("Frame")
    panel.Name = "panel"
    panel.Size = UDim2.new(0, 260, 0, 320)
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.new(0.5, 0, 0.5, 0)
    panel.BackgroundColor3 = c.Surface
    panel.BorderSizePixel = 0
    panel.Parent = screen_gui
    corner(panel, 12)
    stroke(panel, c.Border, 1)

    do
        local dragging, dragStart, startPos
        panel.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = panel.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                panel.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 0)
    layout.Parent = panel

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 0)
    padding.PaddingRight = UDim.new(0, 0)
    padding.Parent = panel

    local header = Instance.new("Frame")
    header.Name = "header"
    header.Size = UDim2.new(1, 0, 0, 48)
    header.BackgroundColor3 = c.BG
    header.BorderSizePixel = 0
    header.LayoutOrder = 0
    header.Parent = panel
    corner(header, 12)

    local header_bottom = Instance.new("Frame")
    header_bottom.Size = UDim2.new(1, 0, 0, 12)
    header_bottom.Position = UDim2.new(0, 0, 1, -12)
    header_bottom.BackgroundColor3 = c.BG
    header_bottom.BorderSizePixel = 0
    header_bottom.Parent = header

    local title_pad = Instance.new("UIPadding")
    title_pad.PaddingLeft = UDim.new(0, 16)
    title_pad.PaddingRight = UDim.new(0, 16)
    title_pad.Parent = header

    local title_label = Instance.new("TextLabel")
    title_label.Text = "index.lol"
    title_label.TextSize = 15
    title_label.Font = Enum.Font.GothamBold
    title_label.TextColor3 = c.TextPrimary
    title_label.BackgroundTransparency = 1
    title_label.TextXAlignment = Enum.TextXAlignment.Left
    title_label.Size = UDim2.new(1, -60, 1, 0)
    title_label.Parent = header

    local display_section = section("visuals", 1)
    toggleRow(display_section, "boxes", "showboxes", 1)
    toggleRow(display_section, "weapon info", "showweapon", 2)

    local key_section = section("keybind", 2)

    local key_row = Instance.new("Frame")
    key_row.Size = UDim2.new(1, 0, 0, 36)
    key_row.BackgroundTransparency = 1
    key_row.LayoutOrder = 1
    key_row.Parent = key_section

    local key_name = Instance.new("TextLabel")
    key_name.Text = "toggle ui"
    key_name.TextSize = 13
    key_name.Font = Enum.Font.Gotham
    key_name.TextColor3 = c.TextPrimary
    key_name.BackgroundTransparency = 1
    key_name.TextXAlignment = Enum.TextXAlignment.Left
    key_name.Size = UDim2.new(1, -90, 1, 0)
    key_name.Parent = key_row

    local key_chip = Instance.new("TextButton")
    key_chip.Text = current_toggle_key.Name
    key_chip.TextSize = 11
    key_chip.Font = Enum.Font.GothamMedium
    key_chip.TextColor3 = c.TextSecondary
    key_chip.BackgroundColor3 = c.Elevated
    key_chip.Size = UDim2.new(0, 84, 0, 24)
    key_chip.Position = UDim2.new(1, -84, 0.5, -12)
    key_chip.BorderSizePixel = 0
    key_chip.Parent = key_row
    corner(key_chip, 6)
    stroke(key_chip, c.Border, 1)

    local rebinding = false
    key_chip.MouseButton1Click:Connect(function()
        if rebinding then return end
        rebinding = true
        key_chip.Text = "Press key…"
        key_chip.TextColor3 = c.Accent

        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                current_toggle_key = input.KeyCode
                key_chip.Text = current_toggle_key.Name
                key_chip.TextColor3 = c.TextSecondary
                rebinding = false
                conn:Disconnect()
            end
        end)
    end)

    -- set_ui_visible is called here, AFTER panel and all UI elements are created
    set_ui_visible(uivisible)

    return {
        gui = screen_gui,
        setVisible = set_ui_visible,
        getVisible = function() return uivisible end,
        getToggleKey = function() return current_toggle_key end,
    }
end

return buildUI
