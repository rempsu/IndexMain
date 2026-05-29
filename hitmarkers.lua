local createWorldHitmarker, startHitmarkerLoop = (function()
    local _hitmarkerSettings = nil
    local _activeHitmarkers  = nil
    local _recentTargets     = nil
    local _resolvePlayer     = nil
    local _runservice        = game:GetService("RunService")
    local _players           = game:GetService("Players")
    local _localplayer       = _players.LocalPlayer

    local function create(targetPlayer)
        if not _hitmarkerSettings.enabled then return end
        local char = targetPlayer and targetPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local spawnTime = tick()
        local lines     = {}

        local offsets = {
            { from = Vector2.new(-1, -1), to = Vector2.new(1, 1) },
            { from = Vector2.new(1, -1),  to = Vector2.new(-1, 1) },
        }

        for _, offset in ipairs(offsets) do
            local outline = _hitmarkerSettings.outline and Drawing.new("Line") or nil
            local line    = Drawing.new("Line")
            if outline then
                outline.Thickness = _hitmarkerSettings.thickness + 2
                outline.Color     = _hitmarkerSettings.outlineColor
                outline.Visible   = false
                outline.ZIndex    = 1
            end
            line.Thickness = _hitmarkerSettings.thickness
            line.Color     = _hitmarkerSettings.color
            line.Visible   = false
            line.ZIndex    = 2
            table.insert(lines, { line = line, outline = outline, offset = offset })
        end

        local id = tostring(spawnTime) .. tostring(math.random())
        _activeHitmarkers[id] = {
            lines  = lines,
            player = targetPlayer,
            hrp    = hrp,
            spawn  = spawnTime,
        }
    end

    local function startLoop(unloadingRef)
        _runservice.RenderStepped:Connect(function()
            if unloadingRef() then return end
            local cam  = workspace.CurrentCamera
            local now  = tick()
            local size = _hitmarkerSettings.size

            for id, hm in pairs(_activeHitmarkers) do
                local elapsed  = now - hm.spawn
                local duration = _hitmarkerSettings.duration

                if elapsed > duration then
                    for _, entry in ipairs(hm.lines) do
                        entry.line.Visible = false
                        pcall(function() entry.line:Remove() end)
                        if entry.outline then
                            entry.outline.Visible = false
                            pcall(function() entry.outline:Remove() end)
                        end
                    end
                    _activeHitmarkers[id] = nil
                    continue
                end

                local hrp = hm.hrp
                if not hrp or not hrp.Parent then
                    local char2 = hm.player and hm.player.Character
                    hrp = char2 and char2:FindFirstChild("HumanoidRootPart")
                    if not hrp then
                        for _, entry in ipairs(hm.lines) do
                            entry.line.Visible = false
                            if entry.outline then entry.outline.Visible = false end
                        end
                        continue
                    end
                    hm.hrp = hrp
                end

                local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.5, 0))
                local sp    = Vector2.new(screenPos.X, screenPos.Y)
                local alpha = _hitmarkerSettings.fadeOut and (1 - (elapsed / duration)) or 1

                for _, entry in ipairs(hm.lines) do
                    local from = sp + entry.offset.from * size
                    local to   = sp + entry.offset.to   * size
                    entry.line.From         = from
                    entry.line.To           = to
                    entry.line.Visible      = onScreen
                    entry.line.Transparency = 1 - alpha
                    entry.line.Color        = _hitmarkerSettings.color
                    if entry.outline then
                        entry.outline.From         = from
                        entry.outline.To           = to
                        entry.outline.Visible      = onScreen
                        entry.outline.Transparency = 1 - alpha
                    end
                end
            end
        end)

        workspace.DescendantAdded:Connect(function(sound)
            if not sound:IsA("Sound") then return end
            if sound.Name ~= "HitMarker" and sound.Name ~= "Hit" then return end
            if not sound:IsDescendantOf(workspace) then return end
            if sound.Parent == workspace then return end
            local hitPlayer = _resolvePlayer(sound)
            if not hitPlayer or hitPlayer == _localplayer then return end
            local expiry = _recentTargets[hitPlayer]
            if not expiry or tick() > expiry then return end
            create(hitPlayer)
        end)
    end

    return function(cfg)
        _hitmarkerSettings = cfg.hitmarkerSettings
        _activeHitmarkers  = cfg.activeHitmarkers
        _recentTargets     = cfg.recentTargets
        _resolvePlayer     = cfg.resolvePlayer
        startLoop(cfg.isUnloading)
        return create
    end
end)()

return createWorldHitmarker, startHitmarkerLoop
