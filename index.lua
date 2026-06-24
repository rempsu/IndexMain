if not WYNF_OBFUSCATED then
    WYNF_NO_VIRTUALIZE = function(fn) return fn end
    WYNF_JIT           = function(fn) return fn end
    WYNF_JIT_MAX       = function(fn) return fn end
    WYNF_SECURE_CALL   = function(fn) return fn end
    WYNF_ENC_STRING    = function(s)  return s   end
    WYNF_ENC_NUM       = function(n)  return n   end
    WYNF_CRASH         = function()   error("crash") end
end

if not LPH_OBFUSCATED then
    LPH_JIT            = function(Function) return Function end
    LPH_JIT_MAX        = function(Function) return Function end
    LPH_NO_VIRTUALIZE  = function(Function) return Function end
    LPH_NO_UPVALUES    = function(Function) return function(...) return Function(...) end end
    LPH_ENCSTR         = function(String) return String end
    LPH_ENCNUM         = function(Number) return Number end
    LPH_CRASH          = function() return print("crash >:(") end
end

local LoadingTick = os.clock()

local players      = game:GetService("Players")
local runservice   = game:GetService("RunService")
local userinput    = game:GetService("UserInputService")
local Lighting     = game:GetService("Lighting")
local rs           = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local localplayer = players.LocalPlayer
local playergui   = localplayer:WaitForChild("PlayerGui")

local mathClamp   = math.clamp
local mathFloor   = math.floor
local mathCos     = math.cos
local mathSin     = math.sin
local mathHuge    = math.huge
local mathAtan2   = math.atan2
local mathRad     = math.rad
local mathTan     = math.tan
local taskSpawn   = task.spawn
local taskDelay   = task.delay
local taskWait    = task.wait
local pcallRef    = pcall
local pairsRef    = pairs
local ipairsRef   = ipairs

-- mobile detection
local isMobile = userinput.TouchEnabled and not userinput.KeyboardEnabled

-- game support check

local gameSupported = (function()
    local ok, result = pcall(function()
        return rs:FindFirstChild("Items") ~= nil
            and rs.Items:FindFirstChild("Skin") ~= nil
            and rs.Items:FindFirstChild("Knife") ~= nil
            and rs:FindFirstChild("Weapons") ~= nil
    end)
    return ok and result
end)()

-- spoofer support check

local _PlayerData = localplayer:FindFirstChild("PlayerData")
local _Stats      = _PlayerData and _PlayerData:FindFirstChild("Stats")
local _Gang       = _PlayerData and _PlayerData:FindFirstChild("Gang")

local spooferSupported = (_PlayerData ~= nil)

-- device event
local DeviceEvent = (function()
    local ge = rs:FindFirstChild("GameEvents")
    if ge then return ge:FindFirstChild("DeviceUpdate") end
    return nil
end)()

-- scoot library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/rempsu/IndexMain/refs/heads/main/uilib"))()

-- sesnsory esp
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/rempsu/IndexMain/refs/heads/main/sensoryesp"))()

-- settings tables
local staffDetectorEnabled = true

local hitSettings = {
    notifyEnabled  = true,
    notifyDuration = 3,
}

local weaponSettings = {
    noRecoil     = false,
    noSpread     = false,
    fireRate     = false,
    fireRateMult = 2,
}

local hitmarkerSettings = {
    enabled   = false,
    duration  = 0.5,
    color     = Color3.fromRGB(255, 50, 50),
    killColor = Color3.fromRGB(255, 200, 0),
}

local hitIndicatorSettings = {
    enabled = false,
}

local movSettings = {
    cfrmSpeed    = false,
    cfrmSpeedVal = 27,
    velSpeed     = false,
    velSpeedVal  = 30,
    flyEnabled   = false,
    flySpeed     = 5,
    noclip       = false,
    bhop         = false,
}

local startNoclip, startBhop

local NOCLIP_PARTS = {
    HumanoidRootPart=true, Head=true, Torso=true,
    ["Left Arm"]=true, ["Right Arm"]=true, ["Left Leg"]=true, ["Right Leg"]=true,
    UpperTorso=true, LowerTorso=true,
    LeftUpperArm=true, RightUpperArm=true, LeftLowerArm=true, RightLowerArm=true,
    LeftHand=true, RightHand=true,
    LeftUpperLeg=true, RightUpperLeg=true, LeftLowerLeg=true, RightLowerLeg=true,
    LeftFoot=true, RightFoot=true,
}

local manipSettings = {
    enabled  = false,
    fov      = 200,
    strength = 1,
}

local autoShootSettings = {
    enabled  = false,
    vischeck = true,
    delay    = 0.1,
}

local silentSettings = {
    enabled    = false,
    teamcheck  = true,
    vischeck   = false,
    fov        = 130,
    targetpart = "head",
}

local viewmodelSettings = {
    enabled = false,
    x       = 0,
    y       = 0,
    z       = 0,
}

local ambientSettings = {
    enabled    = false,
    color      = Color3.fromRGB(255, 255, 255),
    brightness = 1,
}

-- crosshair settings
local crosshairSettings = {
    enabled   = false,
    size      = 10,
    gap       = 4,
    thickness = 2,
    color     = Color3.fromRGB(255, 255, 255),
    dot       = false,
    spin      = false,
    spinSpeed = 2,
    sizeAnim  = false,
    sizeMin   = 6,
    sizeMax   = 14,
    sizeSpeed = 20,
}

local watchedUsers = {
    [128547037]  = "tester",
    [1089888905] = "tester",
    [4269359593] = "tester",
    [4621670832] = "tester",
    [411845421]  = "tester",
    [1066505679] = "tester",
    [550183999]  = "tester",
    [7032328813] = "tester",
    [7660433176] = "tester",
    [1932714775] = "tester",
    [644109069]  = "tester",
    [8300163915] = "tester",
    [1885942346] = "tester",
    [94409100]   = "moderator",
    [7017152868] = "moderator",
    [70838151]   = "moderator",
    [4323561112] = "moderator",
    [1474440307] = "moderator",
    [2469896978] = "moderator",
    [1475316060] = "developer",
    [22502596]   = "head admin",
    [544645921]  = "founder",
}

local detectedUsers = {}

-- sounds
local AllSounds = {
    ["default"]   = "160432334",
    ["dink"]      = "988593556",
    ["tf2"]       = "8255306220",
    ["gamesense"] = "4817809188",
    ["rust"]      = "1255040462",
    ["neverlose"] = "8726881116",
    ["bubble"]    = "198598793",
    ["bubble2"]   = "132948338000932",
    ["quake"]     = "1455817260",
    ["among-us"]  = "7227567562",
    ["ding"]      = "72656167409567",
    ["minecraft"] = "6361963422",
    ["blackout"]  = "3748776946",
    ["osu"]       = "7151989073",
    ["paintball"] = "117404476273393",
    ["key"]       = "140134596265975",
    ["hit"]       = "133749572213659",
    ["bamboo"]    = "123464486116204",
    ["skeet"]     = "80534344648365",
    ["critical"]  = "13471740561",
    ["sonicexe"]  = "137584754609456",
    ["hint"]      = "134763632925481",
    ["slap"]      = "121788398947572",
    ["bell"]      = "124010691633262",
}

local HitSounds  = AllSounds
local KillSounds = AllSounds

local soundSettings = {
    hitSoundEnabled  = true,
    killSoundEnabled = true,
    currentHitSound  = "default",
    currentKillSound = "default",
    hitVolume        = 0.5,
    killVolume       = 0.5,
}

local mutedConnections          = {}
local characterAddedConnections = {}
local activeSounds              = {}

local PlaySound = WYNF_NO_VIRTUALIZE(function(soundId, volume)
    if not soundId or soundId == "" then return end
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundId
    sound.Volume  = volume
    sound.Parent  = workspace.CurrentCamera
    sound:Play()
    activeSounds[sound] = true
    sound.Ended:Connect(function() activeSounds[sound] = nil end)
    game:GetService("Debris"):AddItem(sound, 3)
end)

local REAL_HITMARKER_ID    = "rbxassetid://" .. WYNF_ENC_STRING("76962155018")
local descendantConnection = nil

local muteSound = WYNF_NO_VIRTUALIZE(function(sound)
    if not sound:IsA("Sound") then return end
    if not (soundSettings.hitSoundEnabled or soundSettings.killSoundEnabled) then return end
    if tostring(sound.SoundId) == REAL_HITMARKER_ID or sound.Name == "HitMarker" or sound.Name == "Hit" then
        sound.Volume = 0
        if not mutedConnections[sound] then
            mutedConnections[sound] = sound:GetPropertyChangedSignal("Volume"):Connect(function()
                if soundSettings.hitSoundEnabled or soundSettings.killSoundEnabled then
                    sound.Volume = 0
                end
            end)
        end
    end
end)

local function MuteGameHitSounds()
    if descendantConnection then
        descendantConnection:Disconnect()
        descendantConnection = nil
    end
    for _, v in ipairs(workspace:GetDescendants()) do muteSound(v) end
    descendantConnection = game.DescendantAdded:Connect(muteSound)
end

local FIRE_LINGER_SECONDS = 0.6
local recentTargets       = {}

local resolvePlayerFromDescendant = WYNF_SECURE_CALL(function(inst)
    local current = inst
    while current and current ~= workspace do
        local parent = current.Parent
        if parent == workspace then
            for _, p in pairs(players:GetPlayers()) do
                if p.Character == current then return p end
            end
            return nil
        end
        current = parent
    end
    return nil
end)

local hitmarkerWatcher = nil
local FlashHitmarker   = nil
local WM_Clients       = {}

local function SetupHitDetection()
    local lastHitTime  = 0
    local lastKillTime = 0
    local COOLDOWN     = 0.15

    local function onHitSoundAdded(sound)
        if not sound:IsA("Sound") then return end
        if sound.Name ~= "HitMarker" and sound.Name ~= "Hit" then return end
        if not sound:IsDescendantOf(workspace) then return end
        if sound.Parent == workspace then return end

        sound.Volume = 0
        if not mutedConnections[sound] then
            mutedConnections[sound] = sound:GetPropertyChangedSignal("Volume"):Connect(function()
                sound.Volume = 0
            end)
        end

        local hitPlayer = resolvePlayerFromDescendant(sound)
        if not hitPlayer then return end

        local expiry = recentTargets[hitPlayer]
        if not expiry or tick() > expiry then return end

        task.defer(function()
            local now    = tick()
            local isKill = false
            if hitPlayer.Character then
                local hum = hitPlayer.Character:FindFirstChildOfClass("Humanoid")
                isKill = hum ~= nil and hum.Health <= 0
            end

            if hitSettings.notifyEnabled then
                task.spawn(function()
                    pcall(function()
                        local lc   = localplayer.Character
                        local lhrp = lc and lc:FindFirstChild("HumanoidRootPart")
                        local ehrp = hitPlayer.Character and hitPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local dist = (lhrp and ehrp) and math.floor((lhrp.Position - ehrp.Position).Magnitude / 3) or 0
                        local msg  = isKill
                            and ("killed " .. hitPlayer.Name .. " [" .. dist .. "m]")
                            or  ("hit "    .. hitPlayer.Name .. " [" .. dist .. "m]")
                        Library:Notification("Hit", msg, 3)
                    end)
                end)
            end

            pcall(function()
                local dmg = nil
                for _, wc in pairs(WM_Clients or {}) do
                    dmg = wc.TorsoDamage or wc.BodyDamage
                    break
                end
                FlashHitmarker(hitPlayer, isKill, dmg)
            end)

            if isKill then
                if now - lastKillTime >= COOLDOWN then
                    lastKillTime = now
                    if soundSettings.killSoundEnabled then
                        PlaySound(KillSounds[soundSettings.currentKillSound], soundSettings.killVolume)
                    end
                end
            else
                if now - lastHitTime >= COOLDOWN then
                    lastHitTime = now
                    if soundSettings.hitSoundEnabled then
                        PlaySound(HitSounds[soundSettings.currentHitSound], soundSettings.hitVolume)
                    end
                end
            end
        end)
    end

    hitmarkerWatcher = workspace.DescendantAdded:Connect(onHitSoundAdded)
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Sound") and (v.Name == "HitMarker" or v.Name == "Hit") then
            onHitSoundAdded(v)
        end
    end

    if localplayer.Character then MuteGameHitSounds() end
    table.insert(characterAddedConnections, localplayer.CharacterAdded:Connect(MuteGameHitSounds))
end

-- aimbot settings
local settings = {
    espteamcheck = true,
    aimenable    = false,
    aimmode      = "hold",
    aimkey       = Enum.KeyCode.Q,
    aimpart      = "head",
    aimteamcheck = true,
    wallcheck    = false,
    aimfov       = 150,
    aimsmoothing = 0.25,
    showfov      = true,
    fovcolor     = Color3.fromRGB(255, 255, 255),
    priority     = "closest to crosshair",
}

-- wallcheck raycast params
local wallCheckParams = RaycastParams.new()
wallCheckParams.FilterType = Enum.RaycastFilterType.Exclude

local function isVisible(targetPart)
    local char = localplayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetPart then return false end
    wallCheckParams.FilterDescendantsInstances = { char }
    local origin    = hrp.Position
    local direction = targetPart.Position - origin
    local result    = workspace:Raycast(origin, direction, wallCheckParams)
    if not result then return true end
    return result.Instance and result.Instance:IsDescendantOf(targetPart.Parent)
end

local aim_toggled = false
local esp_conn    = nil
local unloading   = false
local flyConn     = nil
local noclipConn  = nil
local bhopConn    = nil
local cfrmConn    = nil
local velConn     = nil
local knifebotActive = false

local function stopFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    local char = localplayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hrp then hrp.Anchored = false end
    if hum then hum.PlatformStand = false end
end

local function startFly()
    stopFly()
    local char = localplayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    hum.PlatformStand = true
    flyConn = runservice.Heartbeat:Connect(function()
        if not movSettings.flyEnabled then stopFly(); return end
        local cam   = workspace.CurrentCamera
        local speed = movSettings.flySpeed
        local cf    = cam.CFrame
        local vel   = Vector3.new()
        if userinput:IsKeyDown(Enum.KeyCode.W) then vel = vel + cf.LookVector end
        if userinput:IsKeyDown(Enum.KeyCode.S) then vel = vel - cf.LookVector end
        if userinput:IsKeyDown(Enum.KeyCode.A) then vel = vel - cf.RightVector end
        if userinput:IsKeyDown(Enum.KeyCode.D) then vel = vel + cf.RightVector end
        if userinput:IsKeyDown(Enum.KeyCode.Space)     then vel = vel + Vector3.new(0,1,0) end
        if userinput:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.new(0,1,0) end
        if vel.Magnitude > 0 then hrp.CFrame = hrp.CFrame + vel.Unit * (speed * 0.1) end
        hrp.AssemblyLinearVelocity = Vector3.new()
    end)
end

-- fov circles
local FOV_DOTS    = 48
local fov_dots    = {}
local sa_fov_dots = {}
for i = 1, FOV_DOTS do
    local d = Drawing.new("Circle")
    d.Filled=true; d.Radius=2; d.NumSides=8; d.Visible=false; fov_dots[i]=d
    setstreamproof(d, true)
    local s = Drawing.new("Circle")
    s.Filled=true; s.Radius=2; s.NumSides=8; s.Visible=false; sa_fov_dots[i]=s
    setstreamproof(s, true)
end
local fov_solid    = Drawing.new("Circle")
fov_solid.Filled=false; fov_solid.Thickness=1; fov_solid.NumSides=64; fov_solid.Visible=false
setstreamproof(fov_solid, true)
local sa_fov_solid = Drawing.new("Circle")
sa_fov_solid.Filled=false; sa_fov_solid.Thickness=1; sa_fov_solid.NumSides=64; sa_fov_solid.Visible=false
setstreamproof(sa_fov_solid, true)

local fovCircleSettings = {
    dotted=true, animated=true, speed=1,
    saDotted=true, saAnimated=true, saSpeed=1,
    saEnabled=true, saColor=Color3.fromRGB(100,200,255),
}
local _fovAngle   = 0
local _saFovAngle = 0
local fov_circle  = { Visible=false }

local resolve_key = WYNF_NO_VIRTUALIZE(function(key)
    if typeof(key) == "EnumItem" then return key end
    if type(key) == "string" then
        local stripped = key:match("%.([^%.]+)$") or key
        local ok1, r1 = pcall(function() return Enum.KeyCode[stripped] end)
        if ok1 and typeof(r1) == "EnumItem" then return r1 end
        local ok2, r2 = pcall(function() return Enum.UserInputType[stripped] end)
        if ok2 and typeof(r2) == "EnumItem" then return r2 end
    end
    return nil
end)

local is_key_down = WYNF_NO_VIRTUALIZE(function()
    local key = resolve_key(settings.aimkey)
    if not key then return false end
    if key.EnumType == Enum.KeyCode then return userinput:IsKeyDown(key) end
    if key.EnumType == Enum.UserInputType then return userinput:IsMouseButtonPressed(key) end
    return false
end)

local input_matches_aimkey = WYNF_NO_VIRTUALIZE(function(input)
    local key = resolve_key(settings.aimkey)
    if not key then return false end
    if key.EnumType == Enum.KeyCode then return input.KeyCode == key end
    if key.EnumType == Enum.UserInputType then return input.UserInputType == key end
    return false
end)

-- script window
local Window = Library:Window({
    Name = "index.lol",
    Logo = "120474185165700",
})

-- menu blur and snow hooks
local menuBlurEnabled = false
local menuSnowEnabled = false
local menuBlurEffect  = nil
local menuSnowGui     = nil
local menuSnowThread  = nil

local Watermark = Library:Watermark("index.lol")

local _wmLabel  = nil
local _wmFrames = 0
local _wmLast   = 0
local _wmFPS    = 0

local function findWatermarkLabel()
    for _, obj in ipairs(game:GetService("CoreGui"):GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Text:find("index%.lol") then
            _wmLabel = obj
            return
        end
    end
end
findWatermarkLabel()

runservice.RenderStepped:Connect(function() _wmFrames = _wmFrames + 1 end)

runservice.Heartbeat:Connect(function()
    local now = tick()
    if now - _wmLast < 1 then return end
    _wmFPS    = _wmFrames
    _wmFrames = 0
    _wmLast   = now
    local ping = 0
    pcall(function()
        ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    if not _wmLabel or not _wmLabel.Parent then
        findWatermarkLabel()
    end
    if _wmLabel then
        _wmLabel.Text = string.format("index.lol  |  %s  |  %d fps  |  %d ms",
            localplayer.Name, _wmFPS, ping)
    end
end)
local KeybindList = Library:KeybindList()
KeybindList:SetVisibility(true)

-- ui pages
local AimbotTab      = Window:Page({ Name = "combat",      Columns = 2 })
local VisualsTab     = Window:Page({ Name = "visuals",     Columns = 2 })
local MovementTab    = Window:Page({ Name = "movement",    Columns = 2 })
local MiscTab        = Window:Page({ Name = "misc",        Columns = 2 })
local WorldTab       = Window:Page({ Name = "world",       Columns = 2 })
local SkinchangerTab = Window:Page({ Name = "skins",       Columns = 2 })
local CrosshairTab   = Window:Page({ Name = "crosshair",   Columns = 2 })
local SpooferTab     = Window:Page({ Name = "spoofer",     Columns = 2 })
local SettingsTab    = Window:Page({ Name = "settings",    Columns = 2 })

-- esp init
local espInstance = ESP:Load({
    Enabled       = true,
    Players       = true,
    LocalPlayer   = false,
    LimitFPS      = 70,
    DynamicBoxes  = false,
    Boxes         = true,
    BoxType       = "Normal",
    BoxColor      = Color3.fromRGB(255, 255, 255),
    BoxThickness  = 1,
    Outlines      = { Enabled = true, Color = Color3.fromRGB(0, 0, 0), Thickness = 1 },
    BoxFill = {
        Enabled      = true,
        Color        = Color3.fromRGB(255, 255, 255),
        Transparency = 0.9,
        Gradient = {
            Enabled   = true,
            Color1    = Color3.fromRGB(180, 255, 255),
            Color2    = Color3.fromRGB(0, 255, 255),
            Color3    = Color3.fromRGB(0, 120, 255),
            Rotation  = 0,
            Animated  = true,
            Speed     = 64,
            Direction = "Right",
        }
    },
    HealthBar = {
        Enabled                 = true,
        Position                = "Left",
        SideGap                 = 2,
        Width                   = 2,
        ShowText                = true,
        TextFollowBar           = true,
        HideWhenFullHP          = true,
        FollowGradientColorText = true,
        Outline  = { Enabled = true, Color = Color3.fromRGB(0, 0, 0) },
        Gradient = {
            Enabled = true,
            Color1  = Color3.fromRGB(0, 255, 0),
            Color2  = Color3.fromRGB(255, 255, 0),
            Color3  = Color3.fromRGB(255, 0, 0),
        }
    },
    Names       = true,
    TextSize    = 12,
    TextColor   = Color3.fromRGB(255, 255, 255),
    TextOutline = true,
    TextGap     = 3,
    Font        = "Proggy Clean",
    TeamIndicator = {
        Enabled      = true,
        Position     = "Right",
        UseTeamColor = true,
        Compact      = true,
        TextSize     = 10,
    },
    FriendlyIndicator = {
        Enabled      = true,
        Position     = "Right",
        CheckTeam    = true,
        CheckFriends = true,
        Text         = "[f]",
        Color        = Color3.fromRGB(0, 255, 0),
    },
    Weapon = {
        Enabled         = true,
        Gap             = 1,
        UseToolFallback = true,
    },
    Flags = {
        Enabled  = true,
        Position = "Right",
        SideGap  = 4,
        TextGap  = 2,
        Font     = "Smallest Pixel-7",
        TextSize = 9,
        Options  = { Idle = false, Moving = true, Jumping = true, Swimming = true },
        Colors   = {
            Idle     = Color3.fromRGB(255, 255, 255),
            Moving   = Color3.fromRGB(255, 255, 255),
            Jumping  = Color3.fromRGB(255, 255, 255),
            Swimming = Color3.fromRGB(65, 65, 255),
        }
    },
    Skeleton = {
        Enabled      = false,
        Color        = Color3.fromRGB(255, 255, 255),
        Outline      = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        Thickness    = 1,
    },
    Distance = {
        Enabled       = true,
        Unit          = "Meters",
        StudsPerMeter = 3,
        Ending        = "",
        Gap           = 3,
    },
    Chams = {
        Enabled = true,
        Type    = "Highlight",
        Highlight = {
            FillColor           = Color3.fromRGB(255, 255, 255),
            FillTransparency    = 1,
            OutlineColor        = Color3.fromRGB(255, 255, 255),
            OutlineTransparency = 0,
            VisibleCheck        = false,
        },
        Adornment = {
            Color        = Color3.fromRGB(59, 144, 204),
            VisibleColor = Color3.fromRGB(59, 204, 90),
            Transparency = 0.7,
            AlwaysOnTop  = true,
            VisibleCheck = false,
        },
        MeshChams = {
            FillColor           = Color3.fromRGB(59, 144, 204),
            FillTransparency    = 0.6,
            OutlineColor        = Color3.fromRGB(255, 255, 255),
            OutlineTransparency = 0,
            VisibleCheck        = false,
        },
    },
    TeamCheck   = true,
    Keybind     = { Enabled = false },
    Directories = {},
})

local espCfg = espInstance:GetConfig()

-- visuals tab
local ESPSection   = VisualsTab:Section({ Name = "esp",    Side = 1 })
local ChamSection  = VisualsTab:Section({ Name = "chams",  Side = 1 })
local ColorSection = VisualsTab:Section({ Name = "colors", Side = 2 })
local BoxSection   = VisualsTab:Section({ Name = "box",    Side = 2 })

ESPSection:Toggle({ Name = "enabled",        Flag = "espEnabled",   Default = true,  Callback = function(v) espCfg.Enabled               = v end })
ESPSection:Toggle({ Name = "boxes",          Flag = "espBoxes",     Default = true,  Callback = function(v) espCfg.Boxes                 = v end })
ESPSection:Toggle({ Name = "names",          Flag = "espNames",     Default = true,  Callback = function(v) espCfg.Names                 = v end })
ESPSection:Toggle({ Name = "health bar",     Flag = "espHealth",    Default = true,  Callback = function(v) espCfg.HealthBar.Enabled     = v end })
ESPSection:Toggle({ Name = "distance",       Flag = "espDistance",  Default = true,  Callback = function(v) espCfg.Distance.Enabled      = v end })
ESPSection:Toggle({ Name = "weapon",         Flag = "espWeapon",    Default = true,  Callback = function(v) espCfg.Weapon.Enabled        = v end })
ESPSection:Toggle({ Name = "flags",          Flag = "espFlags",     Default = true,  Callback = function(v) espCfg.Flags.Enabled         = v end })
ESPSection:Toggle({ Name = "skeleton",       Flag = "espSkeleton",  Default = false, Callback = function(v) espCfg.Skeleton.Enabled      = v end })
ESPSection:Toggle({ Name = "box fill",       Flag = "espBoxFill",   Default = true,  Callback = function(v) espCfg.BoxFill.Enabled       = v end })
ESPSection:Toggle({ Name = "team indicator", Flag = "espTeamInd",   Default = true,  Callback = function(v) espCfg.TeamIndicator.Enabled = v end })
ESPSection:Toggle({ Name = "team check",     Flag = "espTeamCheck", Default = true,  Callback = function(v) espCfg.TeamCheck             = v end })
ESPSection:Dropdown({
    Name = "box type", Flag = "espBoxType", Default = "Normal",
    Items = { "Normal", "Corner", "Circle" },
    Callback = function(v) espCfg.BoxType = v end
})
ESPSection:Slider({
    Name = "max distance", Flag = "espMaxDist", Default = 1000, Min = 50, Max = 2000,
    Callback = function(v) espCfg.MaxDistance = v end
})

ChamSection:Toggle({ Name = "chams", Flag = "espChams", Default = true, Callback = function(v) espCfg.Chams.Enabled = v end })
ChamSection:Dropdown({
    Name = "cham type", Flag = "espChamType", Default = "Highlight",
    Items = { "Highlight", "Adornment" },
    Callback = function(v) espCfg.Chams.Type = v end
})
ChamSection:Slider({
    Name = "fill transparency", Flag = "espChamFill", Default = 60, Min = 0, Max = 100,
    Callback = function(v)
        espCfg.Chams.Highlight.FillTransparency = v / 100
        espCfg.Chams.Adornment.Transparency     = v / 100
    end
})

ColorSection:Label("box color"):Colorpicker({
    Flag = "espBoxColor", Default = Color3.fromRGB(255, 255, 255),
    Callback = function(c) espCfg.BoxColor = c end
})
ColorSection:Label("text color"):Colorpicker({
    Flag = "espTextColor", Default = Color3.fromRGB(255, 255, 255),
    Callback = function(c) espCfg.TextColor = c end
})
ColorSection:Label("health low"):Colorpicker({
    Flag = "espHealthLow", Default = Color3.fromRGB(255, 50, 50),
    Callback = function(c)
        if espCfg.HealthBar and espCfg.HealthBar.Gradient then
            espCfg.HealthBar.Gradient.Color3 = c
        end
    end
})
ColorSection:Label("health high"):Colorpicker({
    Flag = "espHealthHigh", Default = Color3.fromRGB(50, 255, 50),
    Callback = function(c)
        if espCfg.HealthBar and espCfg.HealthBar.Gradient then
            espCfg.HealthBar.Gradient.Color1 = c
        end
    end
})
ColorSection:Label("cham color"):Colorpicker({
    Flag = "espChamColor", Default = Color3.fromRGB(59, 144, 204),
    Callback = function(c)
        espCfg.Chams.Highlight.OutlineColor = c
        espCfg.Chams.Adornment.Color        = c
    end
})
ColorSection:Label("skel color"):Colorpicker({
    Flag = "espSkelColor", Default = Color3.fromRGB(255, 255, 255),
    Callback = function(c) espCfg.Skeleton.Color = c end
})
BoxSection:Label("box fill color"):Colorpicker({
    Flag = "espBoxFillColor", Default = Color3.fromRGB(0, 200, 255),
    Callback = function(c)
        espCfg.BoxFill.Color = c
        if espCfg.BoxFill.Gradient then
            espCfg.BoxFill.Gradient.Color1 = c
            espCfg.BoxFill.Gradient.Color2 = c
            espCfg.BoxFill.Gradient.Color3 = c
        end
    end
})
BoxSection:Toggle({ Name = "animate gradient", Flag = "gradAnim", Default = true, Callback = function(v) espCfg.BoxFill.Gradient.Animated = v end })

-- combat tab
local AimSection     = AimbotTab:Section({ Name = "aimbot",       Side = 1 })
local SilentSection  = AimbotTab:Section({ Name = "silent aim",   Side = 2 })
local WeaponSection  = AimbotTab:Section({ Name = "weapon mods",  Side = 1 })
local WeaponSection2 = AimbotTab:Section({ Name = "hitmarker",    Side = 2 })
local AutoSection    = AimbotTab:Section({ Name = "triggerbot",   Side = 1 })

local aimToggle = AimSection:Toggle({
    Name = "enabled", Flag = "aimenable", Default = settings.aimenable,
    Callback = function(v) settings.aimenable = v; if not v then aim_toggled = false end end
})
AimSection:Dropdown({
    Name = "mode", Flag = "aimmode", Default = "hold",
    Items = { "hold", "toggle", "always" },
    Callback = function(v) settings.aimmode = v; aim_toggled = false end
})
local aimKeyLabel = AimSection:Label("aim key")
local aimKeybind  = aimKeyLabel:Keybind({
    Flag = "aimkey", Default = settings.aimkey, Mode = "Hold",
    Callback = function()
        local flagData = Library.Flags["aimkey"]
        if flagData and flagData.Key then
            local resolved = resolve_key(flagData.Key)
            if resolved then settings.aimkey = resolved end
        end
    end
})
AimSection:Dropdown({
    Name = "target part", Flag = "aimpart", Default = "head",
    Items = { "head", "upper torso", "humanoidrootpart" },
    Callback = function(v) settings.aimpart = v end
})
AimSection:Toggle({
    Name = "team check", Flag = "aimteamcheck", Default = settings.aimteamcheck,
    Callback = function(v) settings.aimteamcheck = v end
})
AimSection:Toggle({
    Name = "wall check (buggy)", Flag = "aimwallcheck", Default = settings.wallcheck,
    Callback = function(v) settings.wallcheck = v end
})
AimSection:Dropdown({
    Name = "target priority", Flag = "aimPriority", Default = "closest to crosshair",
    Items = { "closest to crosshair", "lowest health", "closest distance" },
    Callback = function(v) settings.priority = v end
})
AimSection:Slider({ Name = "fov",       Flag = "aimfov",       Default = settings.aimfov,                         Min = 10, Max = 800, Callback = function(v) settings.aimfov       = v       end })
AimSection:Slider({ Name = "smoothing", Flag = "aimsmoothing", Default = math.floor(settings.aimsmoothing * 100), Min = 0,  Max = 95,  Callback = function(v) settings.aimsmoothing = v / 100 end })
AimSection:Toggle({ Name = "show fov circle", Flag = "showfov",    Default = settings.showfov, Callback = function(v) settings.showfov = v end })
AimSection:Toggle({ Name = "dotted",          Flag = "fovDotted",  Default = true, Callback = function(v) fovCircleSettings.dotted   = v end })
AimSection:Toggle({ Name = "animated",        Flag = "fovAnim",    Default = true, Callback = function(v) fovCircleSettings.animated = v end })
AimSection:Slider({ Name = "anim speed",      Flag = "fovSpeed",   Default = 5, Min=1, Max=20, Callback = function(v) fovCircleSettings.speed = v/5 end })
AimSection:Label("fov color"):Colorpicker({
    Flag = "fovcolor", Default = settings.fovcolor,
    Callback = function(c) settings.fovcolor = c end
})

local silentToggle = SilentSection:Toggle({ Name = "enabled", Flag = "silentEnabled", Default = false, Callback = function(v) silentSettings.enabled = v end })
silentToggle:Keybind({ Flag = "silentBind", Default = "None", Mode = "Toggle",
    Callback = function(v) silentToggle:Set(v) end })
SilentSection:Toggle({ Name = "team check",    Flag = "silentTeam", Default = true,  Callback = function(v) silentSettings.teamcheck = v end })
SilentSection:Toggle({ Name = "wall check (buggy)", Flag = "silentVis",  Default = false, Callback = function(v) silentSettings.vischeck  = v end })
SilentSection:Dropdown({
    Name = "target part", Flag = "silentPart", Default = "head",
    Items = { "head", "humanoidrootpart", "uppertorso" },
    Callback = function(v) silentSettings.targetpart = v end
})
SilentSection:Slider({ Name = "fov", Flag = "silentFov", Default = 130, Min = 10, Max = 800, Callback = function(v) silentSettings.fov = v end })
SilentSection:Toggle({ Name = "show fov circle", Flag = "saShowFov",  Default = true, Callback = function(v) fovCircleSettings.saEnabled  = v end })
SilentSection:Toggle({ Name = "dotted",          Flag = "saDotted",   Default = true, Callback = function(v) fovCircleSettings.saDotted   = v end })
SilentSection:Toggle({ Name = "animated",        Flag = "saAnim",     Default = true, Callback = function(v) fovCircleSettings.saAnimated = v end })
SilentSection:Slider({ Name = "anim speed",      Flag = "saFovSpeed", Default = 5, Min=1, Max=20, Callback = function(v) fovCircleSettings.saSpeed = v/5 end })
SilentSection:Label("fov color"):Colorpicker({ Flag="saFovColor", Default=Color3.fromRGB(100,200,255),
    Callback=function(c) fovCircleSettings.saColor=c end })

local noRecoilToggle = WeaponSection:Toggle({ Name = "no recoil",  Flag = "noRecoil", Default = false, Callback = function(v) weaponSettings.noRecoil = v end })
noRecoilToggle:Keybind({ Flag = "noRecoilBind", Default = "None", Mode = "Toggle", Callback = function(v) noRecoilToggle:Set(v) end })
local noSpreadToggle = WeaponSection:Toggle({ Name = "no spread",  Flag = "noSpread", Default = false, Callback = function(v) weaponSettings.noSpread = v end })
noSpreadToggle:Keybind({ Flag = "noSpreadBind", Default = "None", Mode = "Toggle", Callback = function(v) noSpreadToggle:Set(v) end })
local rapidFireToggle = WeaponSection:Toggle({ Name = "rapid fire", Flag = "fireRate", Default = false, Callback = function(v) weaponSettings.fireRate = v end })
rapidFireToggle:Keybind({ Flag = "rapidFireBind", Default = "None", Mode = "Toggle", Callback = function(v) rapidFireToggle:Set(v) end })
WeaponSection:Slider({ Name = "firerate multiplier", Flag = "fireRateMult", Default = 2, Min = 1, Max = 10, Callback = function(v) weaponSettings.fireRateMult = v end })

WeaponSection2:Toggle({ Name = "hitmarker",     Flag = "hitmarkerEnabled", Default = false, Callback = function(v) hitmarkerSettings.enabled = v end })
WeaponSection2:Toggle({ Name = "hit indicator", Flag = "hitIndicator",     Default = false, Callback = function(v) hitIndicatorSettings.enabled = v end })
WeaponSection2:Label("hit color"):Colorpicker({
    Flag = "hitmarkerColor", Default = Color3.fromRGB(255, 50, 50),
    Callback = function(c) hitmarkerSettings.color = c end
})
WeaponSection2:Label("kill color"):Colorpicker({
    Flag = "hitmarkerKillColor", Default = Color3.fromRGB(255, 200, 0),
    Callback = function(c) hitmarkerSettings.killColor = c end
})
WeaponSection2:Slider({ Name = "duration", Flag = "hitmarkerDuration", Default = 50, Min = 10, Max = 200, Callback = function(v) hitmarkerSettings.duration = v / 100 end })

local autoToggle = AutoSection:Toggle({ Name = "enabled", Flag = "autoShootEnabled", Default = false, Callback = function(v) autoShootSettings.enabled = v end })
autoToggle:Keybind({ Flag = "autoBind", Default = "None", Mode = "Toggle",
    Callback = function(v) autoToggle:Set(v) end })
AutoSection:Toggle({ Name = "visible check", Flag = "autoShootVis",   Default = true, Callback = function(v) autoShootSettings.vischeck = v end })
AutoSection:Slider({ Name = "shoot delay",   Flag = "autoShootDelay", Default = 10,   Min = 1, Max = 100, Callback = function(v) autoShootSettings.delay = v / 100 end })

-- crosshair tab
do
local CHSection   = CrosshairTab:Section({ Name = "crosshair", Side = 1 })
local LogoSection = CrosshairTab:Section({ Name = "hud logo",  Side = 2 })

local _chLines  = {}
local _chDot    = Drawing.new("Circle")
_chDot.Filled   = true; _chDot.Radius = 2; _chDot.NumSides = 8; _chDot.Visible = false

for i = 1, 4 do
    local l = Drawing.new("Line")
    l.Thickness = 2; l.Color = Color3.new(1,1,1); l.Visible = false; l.ZIndex = 10
    _chLines[i] = l
    setstreamproof(l, true)
end
setstreamproof(_chDot, true)

local _chAngle   = 0
local _chSizeCur = 10
local _chSizeDir = 1

runservice.RenderStepped:Connect(function(dt)
    if not crosshairSettings.enabled then
        for _, l in ipairs(_chLines) do l.Visible = false end
        _chDot.Visible = false
        return
    end
    local cam    = workspace.CurrentCamera
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local col    = crosshairSettings.color
    local thick  = crosshairSettings.thickness
    if crosshairSettings.spin then
        _chAngle = _chAngle + crosshairSettings.spinSpeed * dt
    else
        _chAngle = 0
    end
    if crosshairSettings.sizeAnim then
        _chSizeCur = _chSizeCur + _chSizeDir * crosshairSettings.sizeSpeed * dt
        if _chSizeCur >= crosshairSettings.sizeMax then
            _chSizeCur = crosshairSettings.sizeMax; _chSizeDir = -1
        elseif _chSizeCur <= crosshairSettings.sizeMin then
            _chSizeCur = crosshairSettings.sizeMin; _chSizeDir = 1
        end
    else
        _chSizeCur = crosshairSettings.size
    end
    local size = _chSizeCur
    local gap  = crosshairSettings.gap
    local cos  = math.cos(_chAngle)
    local sin  = math.sin(_chAngle)
    local dirs = {
        Vector2.new( cos,  sin),
        Vector2.new(-cos, -sin),
        Vector2.new(-sin,  cos),
        Vector2.new( sin, -cos),
    }
    for i, dir in ipairs(dirs) do
        _chLines[i].From      = center + dir * gap
        _chLines[i].To        = center + dir * (gap + size)
        _chLines[i].Thickness = thick
        _chLines[i].Color     = col
        _chLines[i].Visible   = true
    end
    _chDot.Position = center
    _chDot.Color    = col
    _chDot.Visible  = crosshairSettings.dot
end)

CHSection:Toggle({ Name = "enabled", Flag = "chEnabled", Default = false,
    Callback = function(v)
        crosshairSettings.enabled = v
        pcall(function()
            local ch = localplayer.PlayerGui:FindFirstChild("Crosshair")
            if ch then ch.Enabled = not v end
        end)
    end
})
CHSection:Toggle({ Name = "center dot", Flag = "chDot",       Default = false, Callback = function(v) crosshairSettings.dot       = v end })
CHSection:Toggle({ Name = "spin",       Flag = "chSpin",      Default = false, Callback = function(v) crosshairSettings.spin      = v end })
CHSection:Slider({ Name = "spin speed", Flag = "chSpinSpeed", Default = 20, Min = 1, Max = 100, Callback = function(v) crosshairSettings.spinSpeed = v / 10 end })
CHSection:Toggle({ Name = "size anim",  Flag = "chSizeAnim",  Default = false, Callback = function(v) crosshairSettings.sizeAnim  = v end })
CHSection:Slider({ Name = "size min",   Flag = "chSizeMin",   Default = 6,  Min = 1, Max = 50,  Callback = function(v) crosshairSettings.sizeMin   = v end })
CHSection:Slider({ Name = "size max",   Flag = "chSizeMax",   Default = 14, Min = 1, Max = 50,  Callback = function(v) crosshairSettings.sizeMax   = v end })
CHSection:Slider({ Name = "size speed", Flag = "chSizeSpeed", Default = 50, Min = 1, Max = 100, Callback = function(v) crosshairSettings.sizeSpeed = v * 0.5 end })
CHSection:Slider({ Name = "size",       Flag = "chSize",      Default = 10, Min = 1, Max = 50,  Callback = function(v) crosshairSettings.size      = v end })
CHSection:Slider({ Name = "gap",        Flag = "chGap",       Default = 4,  Min = 0, Max = 20,  Callback = function(v) crosshairSettings.gap       = v end })
CHSection:Slider({ Name = "thickness",  Flag = "chThickness", Default = 2,  Min = 1, Max = 8,   Callback = function(v) crosshairSettings.thickness = v end })
CHSection:Label("color"):Colorpicker({
    Flag = "chColor", Default = Color3.fromRGB(255, 255, 255),
    Callback = function(c) crosshairSettings.color = c end
})

local logoHudEnabled = false
local logoHudGui     = nil

local function removeLogoHud()
    if logoHudGui and logoHudGui.Parent then logoHudGui:Destroy(); logoHudGui = nil end
end

local function createLogoHud()
    removeLogoHud()
    logoHudGui = Instance.new("ScreenGui")
    logoHudGui.Name           = "INDEX_LogoHUD"
    logoHudGui.IgnoreGuiInset = true
    logoHudGui.ResetOnSpawn   = false
    logoHudGui.DisplayOrder   = 999
    pcall(function() if syn then syn.protect_gui(logoHudGui) end end)
    logoHudGui.Parent = game:GetService("CoreGui")
    local container = Instance.new("Frame")
    container.BackgroundTransparency = 1
    container.AnchorPoint = Vector2.new(0.5, 0)
    container.Position    = UDim2.new(0.5, 0, 0.5, 10)
    container.Size        = UDim2.fromOffset(200, 130)
    container.ZIndex      = 10
    container.Parent      = logoHudGui
    local glow = Instance.new("ImageLabel")
    glow.Image                  = "rbxassetid://120474185165700"
    glow.Size                   = UDim2.fromOffset(90, 90)
    glow.AnchorPoint            = Vector2.new(0.5, 0)
    glow.Position               = UDim2.new(0.5, 0, 0, -10)
    glow.BackgroundTransparency = 1
    glow.ImageTransparency      = 0.72
    glow.ScaleType              = Enum.ScaleType.Fit
    glow.ZIndex                 = 9
    glow.Parent                 = container
    local img = Instance.new("ImageLabel")
    img.Image                  = "rbxassetid://120474185165700"
    img.Size                   = UDim2.fromOffset(70, 70)
    img.AnchorPoint            = Vector2.new(0.5, 0)
    img.Position               = UDim2.new(0.5, 0, 0, 2)
    img.BackgroundTransparency = 1
    img.ScaleType              = Enum.ScaleType.Fit
    img.ZIndex                 = 10
    img.Parent                 = container
    local lbl = Instance.new("TextLabel")
    lbl.Text                   = "index.lol"
    lbl.Size                   = UDim2.new(1, 0, 0, 18)
    lbl.AnchorPoint            = Vector2.new(0.5, 0)
    lbl.Position               = UDim2.new(0.5, 0, 0, 76)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3             = Color3.fromRGB(220, 50, 100)
    lbl.TextSize               = 18
    lbl.Font                   = Enum.Font.Oswald
    lbl.TextXAlignment         = Enum.TextXAlignment.Center
    lbl.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
    lbl.TextStrokeTransparency = 0.3
    lbl.ZIndex                 = 10
    lbl.Parent                 = container
    local sub = Instance.new("TextLabel")
    sub.Text                   = "jailbird"
    sub.Size                   = UDim2.new(1, 0, 0, 14)
    sub.AnchorPoint            = Vector2.new(0.5, 0)
    sub.Position               = UDim2.new(0.5, 0, 0, 98)
    sub.BackgroundTransparency = 1
    sub.TextColor3             = Color3.fromRGB(130, 130, 130)
    sub.TextSize               = 12
    sub.Font                   = Enum.Font.Gotham
    sub.TextXAlignment         = Enum.TextXAlignment.Center
    sub.ZIndex                 = 10
    sub.Parent                 = container
end

LogoSection:Toggle({ Name = "show hud logo", Flag = "logoHud", Default = false,
    Callback = function(v)
        logoHudEnabled = v
        if v then createLogoHud() else removeLogoHud() end
    end
})
LogoSection:Label("logo sits below your crosshair")

end

-- world tab
local SoundSection   = WorldTab:Section({ Name = "sounds",     Side = 1 })
local SkySection     = WorldTab:Section({ Name = "skybox",     Side = 1 })
local VMSection      = WorldTab:Section({ Name = "viewmodel",  Side = 1 })
local AtmSection     = WorldTab:Section({ Name = "atmosphere", Side = 2 })
local AmbientSection = WorldTab:Section({ Name = "ambient",    Side = 2 })

local hitSoundOptions = {}
for name in pairs(HitSounds) do table.insert(hitSoundOptions, name) end
table.sort(hitSoundOptions)

SoundSection:Toggle({
    Name = "enable hit sounds", Flag = "hitSoundEnabled", Default = true,
    Callback = function(v)
        soundSettings.hitSoundEnabled = v
        if not v then
            for _, s in ipairs(game:GetDescendants()) do
                if s:IsA("Sound") and s.Name == "HitMarker" then s.Volume = 1 end
            end
        end
    end
})
SoundSection:Dropdown({ Name = "hit sound",  Flag = "hitSound",  Items = hitSoundOptions, Default = "default", Callback = function(v) soundSettings.currentHitSound  = v end })
SoundSection:Slider({  Name = "hit volume",  Flag = "hitVolume", Min = 0, Max = 100, Default = 50,            Callback = function(v) soundSettings.hitVolume         = v / 100 end })
SoundSection:Button():Add("test hit sound", function()
    if soundSettings.hitSoundEnabled then
        PlaySound(HitSounds[soundSettings.currentHitSound], soundSettings.hitVolume)
    end
end)

local killSoundOptions = {}
for name in pairs(KillSounds) do table.insert(killSoundOptions, name) end
table.sort(killSoundOptions)

SoundSection:Toggle({ Name = "enable kill sounds", Flag = "killSoundEnabled", Default = true, Callback = function(v) soundSettings.killSoundEnabled = v end })
SoundSection:Dropdown({ Name = "kill sound",  Flag = "killSound",  Items = killSoundOptions, Default = "default", Callback = function(v) soundSettings.currentKillSound = v end })
SoundSection:Slider({  Name = "kill volume",  Flag = "killVolume", Min = 0, Max = 100, Default = 50,             Callback = function(v) soundSettings.killVolume        = v / 100 end })
SoundSection:Button():Add("test kill sound", function()
    if soundSettings.killSoundEnabled then
        PlaySound(KillSounds[soundSettings.currentKillSound], soundSettings.killVolume)
    end
end)

local skyboxes = {
    ["galaxy"]        = { "15125283003","15125281008","15125277539","15125279325","15125274388","15125275800" },
    ["vaporwave"]     = { "1417494030","1417494146","1417494253","1417494402","1417494499","1417494643" },
    ["redshift"]      = { "401664839","401664862","401664960","401664881","401664901","401664936" },
    ["desert"]        = { "1013852","1013853","1013850","1013851","1013849","1013854" },
    ["blaze"]         = { "150939022","150939038","150939047","150939056","150939063","150939082" },
    ["among us"]      = { "5752463190","5752463190","5752463190","5752463190","5752463190","5752463190" },
    ["space wave"]    = { "1233158420","1233158838","1233157105","1233157640","1233157995","1233159158" },
    ["turquoise"]     = { "47974894","47974690","47974821","47974776","47974859","47974909" },
    ["dark night"]    = { "6285719338","6285721078","6285722964","6285724682","6285726335","6285730635" },
    ["bright pink"]   = { "271042516","271077243","271042556","271042310","271042467","271077958" },
    ["oblivion lost"] = { "5103110171","5102993828","5103111020","5103112417","5103113734","5102993828" },
    ["setting sun"]   = { "626460377","626460216","626460513","626473032","626458639","626460625" },
}

local skyboxKeys = {}
for k in next, skyboxes do table.insert(skyboxKeys, k) end
table.sort(skyboxKeys)

local currentSkyboxName = "galaxy"
local skyboxEnabled     = false

local applySkybox = WYNF_NO_VIRTUALIZE(function(name)
    local ids = skyboxes[name]
    if not ids then return end
    local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky")
    sky.Name     = "INDEX_SKY"; sky.Parent = Lighting
    sky.SkyboxBk = "rbxassetid://" .. ids[1]
    sky.SkyboxDn = "rbxassetid://" .. ids[2]
    sky.SkyboxFt = "rbxassetid://" .. ids[3]
    sky.SkyboxLf = "rbxassetid://" .. ids[4]
    sky.SkyboxRt = "rbxassetid://" .. ids[5]
    sky.SkyboxUp = "rbxassetid://" .. ids[6]
end)

local function removeSkybox()
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if sky and sky.Name == "INDEX_SKY" then sky:Destroy() end
end

SkySection:Toggle({
    Name = "enabled", Flag = "skyboxEnabled", Default = false,
    Callback = function(v) skyboxEnabled = v; if v then applySkybox(currentSkyboxName) else removeSkybox() end end
})
SkySection:Dropdown({
    Name = "preset", Flag = "skyboxPreset", Default = "galaxy", Items = skyboxKeys,
    Callback = function(v) currentSkyboxName = v; if skyboxEnabled then applySkybox(v) end end
})

local originalAtmosphere = nil
local atmosphereEnabled  = false

local function getOrCreateAtmosphere()
    local atm = Lighting:FindFirstChildOfClass("Atmosphere")
    if not atm then atm = Instance.new("Atmosphere"); atm.Parent = Lighting end
    return atm
end

local function cacheAtmosphere()
    if originalAtmosphere then return end
    local atm = Lighting:FindFirstChildOfClass("Atmosphere")
    if atm then
        originalAtmosphere = { Density=atm.Density, Offset=atm.Offset, Color=atm.Color, Decay=atm.Decay, Glare=atm.Glare, Haze=atm.Haze }
    else
        originalAtmosphere = { Density=0.395, Offset=0, Color=Color3.fromRGB(199,199,199), Decay=Color3.fromRGB(90,75,67), Glare=0, Haze=0 }
    end
end

AtmSection:Toggle({
    Name = "custom atmosphere", Flag = "atmEnabled", Default = false,
    Callback = function(v)
        atmosphereEnabled = v
        if v then cacheAtmosphere()
        else
            local atm = Lighting:FindFirstChildOfClass("Atmosphere")
            if atm and originalAtmosphere then
                atm.Density = originalAtmosphere.Density
                atm.Offset  = originalAtmosphere.Offset
                atm.Glare   = originalAtmosphere.Glare
                atm.Haze    = originalAtmosphere.Haze
            end
        end
    end
})
AtmSection:Slider({ Name = "density", Flag = "atmDensity", Default = 40, Min = 0, Max = 100, Callback = function(v) if not atmosphereEnabled then return end; getOrCreateAtmosphere().Density = v/100 end })
AtmSection:Slider({ Name = "offset",  Flag = "atmOffset",  Default = 0,  Min = 0, Max = 100, Callback = function(v) if not atmosphereEnabled then return end; getOrCreateAtmosphere().Offset  = v/100 end })
AtmSection:Slider({ Name = "haze",    Flag = "atmHaze",    Default = 0,  Min = 0, Max = 100, Callback = function(v) if not atmosphereEnabled then return end; getOrCreateAtmosphere().Haze    = v/10  end })
AtmSection:Slider({ Name = "glare",   Flag = "atmGlare",   Default = 0,  Min = 0, Max = 100, Callback = function(v) if not atmosphereEnabled then return end; getOrCreateAtmosphere().Glare   = v/100 end })

local defaultAmbient    = game:GetService("Lighting").Ambient
local defaultBrightness = game:GetService("Lighting").Brightness

-- menu blur and snow
function setMenuBlur(enabled)
    if enabled then
        if not menuBlurEffect then
            menuBlurEffect = Instance.new("BlurEffect")
            menuBlurEffect.Size = 0
            menuBlurEffect.Parent = workspace.CurrentCamera
        end
        TweenService:Create(
            menuBlurEffect,
            TweenInfo.new(0.33, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            { Size = 20 }
        ):Play()
    else
        if menuBlurEffect then
            local t = TweenService:Create(
                menuBlurEffect,
                TweenInfo.new(0.33, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                { Size = 0 }
            )
            t:Play()
            t.Completed:Connect(function()
                if menuBlurEffect then
                    menuBlurEffect:Destroy()
                    menuBlurEffect = nil
                end
            end)
        end
    end
end

local _snowActive = false

function stopMenuSnow()
    _snowActive = false
    menuSnowThread = nil
    if menuSnowGui and menuSnowGui.Parent then
        menuSnowGui:Destroy()
        menuSnowGui = nil
    end
end

function startMenuSnow()
    if menuSnowGui and menuSnowGui.Parent then return end
    _snowActive = true
    menuSnowGui = Instance.new("ScreenGui")
    menuSnowGui.Name           = "INDEX_SnowOverlay"
    menuSnowGui.ResetOnSpawn   = false
    menuSnowGui.DisplayOrder   = 998
    menuSnowGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    menuSnowGui.Parent         = localplayer.PlayerGui

    local holder = Instance.new("Frame")
    holder.Size                   = UDim2.fromScale(1, 1)
    holder.BackgroundTransparency = 1
    holder.ClipsDescendants       = true
    holder.BorderSizePixel        = 0
    holder.Parent                 = menuSnowGui

    local SNOW_ASSET = "http://www.roblox.com/asset/?id=6871196088"

    menuSnowThread = coroutine.create(function()
        while menuSnowEnabled do
            local w = holder.AbsoluteSize.X
            local h = holder.AbsoluteSize.Y
            if w > 0 and h > 0 then
                local sz       = math.random(5, 8)
                local spawnX   = math.random(0, math.max(0, w - sz))
                local duration = math.random(20, 40) / 10
                local swayX    = math.random(-18, 18)
                local flake = Instance.new("ImageLabel")
                flake.Name                   = "\0"
                flake.BackgroundTransparency = 1
                flake.Image                  = SNOW_ASSET
                flake.Size                   = UDim2.fromOffset(sz, sz)
                flake.Position               = UDim2.new(0, spawnX, 0, -10)
                flake.Parent                 = holder
                TweenService:Create(
                    flake,
                    TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                    {
                        Position          = UDim2.new(0, spawnX + swayX, 0, h + 10),
                        ImageTransparency = 1
                    }
                ):Play()
                game:GetService("Debris"):AddItem(flake, duration + 0.2)
            end
            task.wait(0.1)
        end
    end)
    coroutine.resume(menuSnowThread)
end

local _origSetOpen = Window.SetOpen
Window.SetOpen = function(self, bool)
    _origSetOpen(self, bool)
    if bool then
        if menuBlurEnabled then setMenuBlur(true) end
        if menuSnowEnabled then startMenuSnow()   end
    else
        setMenuBlur(false)
        stopMenuSnow()
    end
end

AmbientSection:Toggle({
    Name = "ambient", Flag = "ambientEnabled", Default = false,
    Callback = function(v)
        ambientSettings.enabled = v
        local lighting = game:GetService("Lighting")
        if not v then
            lighting.Ambient    = defaultAmbient
            lighting.Brightness = defaultBrightness
        else
            lighting.Ambient    = ambientSettings.color
            lighting.Brightness = ambientSettings.brightness
        end
    end
})
AmbientSection:Label("color"):Colorpicker({
    Flag = "ambientColor", Default = Color3.fromRGB(255, 255, 255),
    Callback = function(c)
        ambientSettings.color = c
        if ambientSettings.enabled then game:GetService("Lighting").Ambient = c end
    end
})
AmbientSection:Slider({
    Name = "brightness", Flag = "ambientBrightness", Default = 50, Min = 0, Max = 200,
    Callback = function(v)
        ambientSettings.brightness = v / 50
        if ambientSettings.enabled then game:GetService("Lighting").Brightness = ambientSettings.brightness end
    end
})

-- res changer
local resSettings = {
    enabled            = false,
    horizontal_stretch = 100,
    vertical_stretch   = 100,
}

local ResSection = WorldTab:Section({ Name = "resolution changer", Side = 2 })

ResSection:Toggle({
    Name = "enabled", Flag = "resEnabled", Default = false,
    Callback = function(v) resSettings.enabled = v end
})
ResSection:Slider({
    Name = "horizontal stretch", Flag = "resHStretch", Default = 100, Min = 10, Max = 100,
    Callback = function(v) resSettings.horizontal_stretch = v end
})
ResSection:Slider({
    Name = "vertical stretch", Flag = "resVStretch", Default = 100, Min = 10, Max = 100,
    Callback = function(v) resSettings.vertical_stretch = v end
})

local _resPrevCFrame = nil

runservice.RenderStepped:Connect(function()
    if not resSettings.enabled then
        _resPrevCFrame = nil
        return
    end
    local cam = workspace.CurrentCamera
    local cf  = cam.CFrame
    if _resPrevCFrame and cf == _resPrevCFrame then return end
    local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cf:GetComponents()
    local h = resSettings.horizontal_stretch / 100
    local v = resSettings.vertical_stretch   / 100
    _resPrevCFrame = CFrame.new(X, Y, Z, R00*h, R01*v, R02, R10, R11*v, R12, R20*h, R21*v, R22)
    cam.CFrame     = _resPrevCFrame
end)

VMSection:Toggle({ Name = "enabled", Flag = "vmEnabled", Default = false, Callback = function(v) viewmodelSettings.enabled = v end })
VMSection:Slider({ Name = "x", Flag = "vmX", Default = 0, Min = -3, Max = 3, Callback = function(v) viewmodelSettings.x = v end })
VMSection:Slider({ Name = "y", Flag = "vmY", Default = 0, Min = -3, Max = 3, Callback = function(v) viewmodelSettings.y = v end })
VMSection:Slider({ Name = "z", Flag = "vmZ", Default = 0, Min = -3, Max = 3, Callback = function(v) viewmodelSettings.z = v end })

-- skin changer
if _G.INDEX_gunSkinConn   then _G.INDEX_gunSkinConn:Disconnect();   _G.INDEX_gunSkinConn   = nil end
if _G.INDEX_knifeSkinConn then _G.INDEX_knifeSkinConn:Disconnect(); _G.INDEX_knifeSkinConn = nil end
if _G.INDEX_camModelConn  then _G.INDEX_camModelConn:Disconnect();  _G.INDEX_camModelConn  = nil end

local selectedGunSkin   = "none"
local selectedKnifeSkin = "none"

do
if gameSupported then
    local GunSkinSection   = SkinchangerTab:Section({ Name = "gun skin",   Side = 1 })
    local KnifeSkinSection = SkinchangerTab:Section({ Name = "knife skin", Side = 2 })

    local gunSkinNamesReal = { "none" }
    for _, v in ipairs(rs.Items.Skin:GetChildren()) do table.insert(gunSkinNamesReal, v.Name:lower()) end
    table.sort(gunSkinNamesReal, function(a, b)
        if a == "none" then return true end
        if b == "none" then return false end
        return a < b
    end)

    local GunSkinRealNames = {}
    for _, v in ipairs(rs.Items.Skin:GetChildren()) do GunSkinRealNames[v.Name:lower()] = v.Name end

    local knifeSkinNamesReal = { "none" }
    for _, v in ipairs(rs.Items.Knife:GetChildren()) do table.insert(knifeSkinNamesReal, v.Name:lower()) end
    table.sort(knifeSkinNamesReal, function(a, b)
        if a == "none" then return true end
        if b == "none" then return false end
        return a < b
    end)

    local KnifeSkinRealNames = {}
    for _, v in ipairs(rs.Items.Knife:GetChildren()) do KnifeSkinRealNames[v.Name:lower()] = v.Name end

    local function getCameraModel() return workspace.CurrentCamera:FindFirstChild("CameraModel") end

    local function getCurrentGun()
        local cm = getCameraModel()
        if not cm then return nil end
        for _, v in ipairs(cm:GetChildren()) do
            if rs.Weapons:FindFirstChild(v.Name) then return v end
        end
        return nil
    end

    local function getCurrentKnife()
        local cm = getCameraModel()
        if not cm then return nil end
        for _, v in ipairs(cm:GetChildren()) do
            if rs.Items.Knife:FindFirstChild(v.Name) then return v end
        end
        return nil
    end

    local function applyGunSkin(skinDisplayName)
        if skinDisplayName == "none" or skinDisplayName == nil then return end
        local realName = GunSkinRealNames[skinDisplayName] or skinDisplayName
        local gun      = getCurrentGun()
        if not gun then return end
        local skinTex = rs.Items.Skin:FindFirstChild(realName)
        if not skinTex then return end
        for _, part in ipairs(gun:GetDescendants()) do
            if part:IsA("MeshPart") then pcall(function() part.TextureID = skinTex.Texture end) end
        end
    end

    local ANIM_BOWIE    = { Hold="rbxassetid://17156326547", Action="rbxassetid://17156290783", Equip="rbxassetid://17157619507", Inspect="rbxassetid://17223102735" }
    local ANIM_KARAMBIT = { Hold="rbxassetid://17787592077", Action="rbxassetid://17788245247", Equip="rbxassetid://17787596397", Inspect="rbxassetid://17787586405" }
    local ANIM_HATCHET  = { Hold="rbxassetid://111928394361277", Action="rbxassetid://116109040176624", Equip="rbxassetid://122865148996513", Inspect="rbxassetid://130711019196442" }

    local knifeAnimSets = {
        ["deceit"]="KARAMBIT",["karambit"]="KARAMBIT",["geometric"]="KARAMBIT",
        ["mdrs"]="KARAMBIT",["manifesto"]="KARAMBIT",["qrimson karambit"]="KARAMBIT",
        ["black frost"]="KARAMBIT",["hatchet"]="HATCHET",
    }

    local knifeOffsets = {}
    local knifeNames = {
        "aurora glacier","bayonet","black frost","bowie knife","carbon monsterized",
        "cardboard bowie","crow bayonet","deceit","draconic","etherial","faded",
        "faded sunset","geometric","gold ka-bar","hatchet","ka-bar","karambit",
        "mdrs","manifesto","midnight operator bowie","nebula","oof bowie",
        "pumpkin shade bowie","qrimson karambit","skeletal bowie","slate bayonet","smiley knife",
    }
    for _, n in ipairs(knifeNames) do
        knifeOffsets[n] = { rotation = CFrame.Angles(0,0,0), position = CFrame.new(0,0,0) }
    end

    local function weldModel(model, target, offset)
        offset = offset or CFrame.new()
        local primaryPart = model:FindFirstChild("Handle", true) or model:FindFirstChildWhichIsA("BasePart")
        if not primaryPart then return end
        local primaryWorldCF = primaryPart.CFrame
        for _, part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = false; part.CanCollide = false
                if part == primaryPart then continue end
                local weld = Instance.new("Weld")
                weld.Part0 = target; weld.Part1 = part
                weld.C0 = offset * primaryWorldCF:ToObjectSpace(part.CFrame)
                weld.C1 = CFrame.new(); weld.Parent = part
            end
        end
        local pw = Instance.new("Weld")
        pw.Part0 = target; pw.Part1 = primaryPart
        pw.C0 = offset; pw.C1 = CFrame.new(); pw.Parent = primaryPart
        primaryPart.Anchored = false; primaryPart.CanCollide = false
    end

    local function applyKnifeAnims(knife, skinDisplayName)
        local setName = knifeAnimSets[skinDisplayName]
        local animSet = setName == "KARAMBIT" and ANIM_KARAMBIT or setName == "HATCHET" and ANIM_HATCHET or ANIM_BOWIE
        for _, anim in ipairs(knife:GetDescendants()) do
            if anim:IsA("Animation") then
                local newId = animSet[anim.Name]
                if newId then pcall(function() anim.AnimationId = newId end) end
            end
        end
    end

    local function applyKnifeSkin(skinDisplayName)
        if skinDisplayName == "none" or skinDisplayName == nil then return end
        local realName  = KnifeSkinRealNames[skinDisplayName] or skinDisplayName
        local knife     = getCurrentKnife()
        local skinModel = rs.Items.Knife:FindFirstChild(realName)
        if not knife or not skinModel then return end
        for _, v in ipairs(knife:GetDescendants()) do
            if v:IsA("BasePart") then v.Transparency = 1 end
        end
        local old = knife:FindFirstChild("CustomSkin")
        if old then old:Destroy() end
        local clone = skinModel:Clone()
        clone.Name = "CustomSkin"; clone.Parent = knife
        local attachTo = knife:FindFirstChild("Handle", true) or knife:FindFirstChildWhichIsA("BasePart")
        if attachTo then
            local offset = knifeOffsets[skinDisplayName]
            local cf     = offset and (offset.position * offset.rotation) or CFrame.new()
            weldModel(clone, attachTo, cf)
        end
        applyKnifeAnims(knife, skinDisplayName)
    end

    local function hookCameraModel(cm)
        if _G.INDEX_gunSkinConn   then _G.INDEX_gunSkinConn:Disconnect()   end
        if _G.INDEX_knifeSkinConn then _G.INDEX_knifeSkinConn:Disconnect() end
        _G.INDEX_gunSkinConn = cm.ChildAdded:Connect(function(child)
            task.wait(0.1)
            if rs.Weapons:FindFirstChild(child.Name) then applyGunSkin(selectedGunSkin)
            elseif rs.Items.Knife:FindFirstChild(child.Name) then applyKnifeSkin(selectedKnifeSkin) end
        end)
    end

    local cm = getCameraModel()
    if cm then hookCameraModel(cm) end

    _G.INDEX_camModelConn = workspace.CurrentCamera.ChildAdded:Connect(function(child)
        if child.Name == "CameraModel" then
            task.wait(0.2)
            hookCameraModel(child)
            applyGunSkin(selectedGunSkin)
            applyKnifeSkin(selectedKnifeSkin)
        end
    end)

    local gunSkinDropdown = GunSkinSection:Dropdown({
        Name = "select skin", Flag = "gunSkinSelect", Default = "none", Items = gunSkinNamesReal,
        Callback = function(v) selectedGunSkin = v; applyGunSkin(v) end
    })
    GunSkinSection:Textbox({
        Name = "search", Flag = "gunSkinSearch", Default = "", Placeholder = "type to filter...",
        Callback = function(v)
            local q = v:lower()
            local filtered = {}
            for _, name in ipairs(gunSkinNamesReal) do
                if q == "" or name:lower():find(q, 1, true) then table.insert(filtered, name) end
            end
            gunSkinDropdown:Refresh(filtered)
        end
    })

    local knifeSkinDropdown = KnifeSkinSection:Dropdown({
        Name = "select skin", Flag = "knifeSkinSelect", Default = "none", Items = knifeSkinNamesReal,
        Callback = function(v) selectedKnifeSkin = v; applyKnifeSkin(v) end
    })
    KnifeSkinSection:Textbox({
        Name = "search", Flag = "knifeSkinSearch", Default = "", Placeholder = "type to filter...",
        Callback = function(v)
            local q = v:lower()
            local filtered = {}
            for _, name in ipairs(knifeSkinNamesReal) do
                if q == "" or name:lower():find(q, 1, true) then table.insert(filtered, name) end
            end
            knifeSkinDropdown:Refresh(filtered)
        end
    })
else
    local UnsupportedSection = SkinchangerTab:Section({ Name = "skin changer", Side = 1 })
    UnsupportedSection:Label("not supported in this game")
end
end

-- spoofer tab
local originalStats = {
    Credit       = _Stats and _Stats:GetAttribute("Credit"),
    Level        = _Stats and _Stats:GetAttribute("Level"),
    Kills        = _Stats and _Stats:GetAttribute("Kills"),
    Deaths       = _Stats and _Stats:GetAttribute("Deaths"),
    Damage       = _Stats and _Stats:GetAttribute("Damage"),
    RankedRating = _Stats and _Stats:GetAttribute("RankedRating"),
    RankedKills  = _Stats and _Stats:GetAttribute("RankedKills"),
    RankedDeaths = _Stats and _Stats:GetAttribute("RankedDeaths"),
}
local originalUsername    = localplayer.Name
local originalDisplayName = localplayer.DisplayName

local spooferValues = {
    statCredit       = "",
    statLevel        = "",
    statKills        = "",
    statDeaths       = "",
    statDamage       = "",
    statRankedRating = "",
    statRankedKills  = "",
    statRankedDeaths = "",
    playerUsername   = "",
    playerDisplay    = "",
}

do
if spooferSupported then
    local SpooferStatsSection  = SpooferTab:Section({ Name = "stats",  Side = 1 })
    local SpooferPlayerSection = SpooferTab:Section({ Name = "player", Side = 2 })

    local function applyStatAttribute(key, value)
        if not _Stats then return end
        local val = tonumber(value)
        if val then pcall(function() _Stats:SetAttribute(key, val) end) end
    end

    local function applyPlayerField(field, value)
        if value == "" then return end
        if field == "Name"        then pcall(function() localplayer.Name        = value end) end
        if field == "DisplayName" then pcall(function() localplayer.DisplayName = value end) end
    end

    SpooferStatsSection:Textbox({ Name = "credit",        Flag = "statCredit",       Default = "", Placeholder = tostring(_Stats and _Stats:GetAttribute("Credit")       or "???"), Callback = function(v) spooferValues.statCredit       = v; applyStatAttribute("Credit",       v) end })
    SpooferStatsSection:Textbox({ Name = "level",         Flag = "statLevel",        Default = "", Placeholder = tostring(_Stats and _Stats:GetAttribute("Level")        or "???"), Callback = function(v) spooferValues.statLevel        = v; applyStatAttribute("Level",        v) end })
    SpooferStatsSection:Textbox({ Name = "kills",         Flag = "statKills",        Default = "", Placeholder = tostring(_Stats and _Stats:GetAttribute("Kills")        or "???"), Callback = function(v) spooferValues.statKills        = v; applyStatAttribute("Kills",        v) end })
    SpooferStatsSection:Textbox({ Name = "deaths",        Flag = "statDeaths",       Default = "", Placeholder = tostring(_Stats and _Stats:GetAttribute("Deaths")       or "???"), Callback = function(v) spooferValues.statDeaths       = v; applyStatAttribute("Deaths",       v) end })
    SpooferStatsSection:Textbox({ Name = "damage",        Flag = "statDamage",       Default = "", Placeholder = tostring(_Stats and _Stats:GetAttribute("Damage")       or "???"), Callback = function(v) spooferValues.statDamage       = v; applyStatAttribute("Damage",       v) end })
    SpooferStatsSection:Textbox({ Name = "ranked rating", Flag = "statRankedRating", Default = "", Placeholder = tostring(_Stats and _Stats:GetAttribute("RankedRating") or "???"), Callback = function(v) spooferValues.statRankedRating = v; applyStatAttribute("RankedRating", v) end })
    SpooferStatsSection:Textbox({ Name = "ranked kills",  Flag = "statRankedKills",  Default = "", Placeholder = tostring(_Stats and _Stats:GetAttribute("RankedKills")  or "???"), Callback = function(v) spooferValues.statRankedKills  = v; applyStatAttribute("RankedKills",  v) end })
    SpooferStatsSection:Textbox({ Name = "ranked deaths", Flag = "statRankedDeaths", Default = "", Placeholder = tostring(_Stats and _Stats:GetAttribute("RankedDeaths") or "???"), Callback = function(v) spooferValues.statRankedDeaths = v; applyStatAttribute("RankedDeaths", v) end })

    SpooferPlayerSection:Textbox({ Name = "username",     Flag = "playerUsername", Default = "", Placeholder = localplayer.Name,        Callback = function(v) spooferValues.playerUsername = v; applyPlayerField("Name",        v) end })
    SpooferPlayerSection:Textbox({ Name = "display name", Flag = "playerDisplay",  Default = "", Placeholder = localplayer.DisplayName, Callback = function(v) spooferValues.playerDisplay  = v; applyPlayerField("DisplayName", v) end })
else
    local SpooferUnsupportedSection = SpooferTab:Section({ Name = "spoofer", Side = 1 })
    SpooferUnsupportedSection:Label("not supported in this game")
end
end

-- staff detector
local detectPlayer = WYNF_SECURE_CALL(function(player)
    if not staffDetectorEnabled then return end
    if detectedUsers[player.UserId] then return end
    local role = watchedUsers[player.UserId]
    if role then
        detectedUsers[player.UserId] = true
        Library:Notification(
            string.format("%s detected: %s", role, player.Name),
            string.format("user id: %d", player.UserId),
            10
        )
    end
end)

-- autoqueue
local autoQueueSettings = {
    enabled  = false,
    gamemode = "Casual",
}

local autoQueueThread = nil

local function stopAutoQueue()
    autoQueueSettings.enabled = false
    autoQueueThread = nil
end

local function startAutoQueue()
    stopAutoQueue()
    autoQueueSettings.enabled = true
    autoQueueThread = task.spawn(function()
        while autoQueueSettings.enabled do
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Events.QueueGamemode
                Event:FireServer(autoQueueSettings.gamemode)
            end)
            task.wait(5)
        end
    end)
end

-- config system
local CONFIG_FOLDER = "index.lol/configs"
local CONFIG_EXT    = ".json"
local AUTOLOAD_FILE = "index.lol/autoload.json"

if not isfolder("index.lol")   then makefolder("index.lol")   end
if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end

local function getConfigPath(name) return CONFIG_FOLDER .. "/" .. name .. CONFIG_EXT end

local function serializeColor(c)
    if typeof(c) ~= "Color3" then return { r=1, g=1, b=1 } end
    return { r=c.R, g=c.G, b=c.B }
end
local function deserializeColor(t)
    if type(t) ~= "table" then return Color3.new(1,1,1) end
    return Color3.new(t.r or 1, t.g or 1, t.b or 1)
end

local function getFlagColor(flag, fallback)
    local f = Library.Flags[flag]
    if typeof(f) == "Color3" then return f end
    return fallback or Color3.new(1,1,1)
end

local function getFlagNum(flag, fallback)
    local f = Library.Flags[flag]
    if type(f) == "number" then return f end
    return fallback or 0
end

local function buildConfig()
    local atmDensityVal = getFlagNum("atmDensity", 40)
    local atmOffsetVal  = getFlagNum("atmOffset",  0)
    local atmHazeVal    = getFlagNum("atmHaze",    0)
    local atmGlareVal   = getFlagNum("atmGlare",   0)

    local function getKeybindKey(flag)
        local f = Library.Flags[flag]
        if f == nil then return { Key = "None", Mode = "Toggle" } end
        if type(f) == "table" and f.Key then
            return { Key = tostring(f.Key), Mode = f.Mode or "Toggle" }
        end
        return { Key = "None", Mode = "Toggle" }
    end

    return {
        -- aimbot stuff
        aimenable        = settings.aimenable,
        aimPriority      = settings.priority,
        aimmode          = settings.aimmode,
        aimkey           = tostring(settings.aimkey),
        aimpart          = settings.aimpart,
        aimteamcheck     = settings.aimteamcheck,
        aimwallcheck     = settings.wallcheck,
        aimfov           = settings.aimfov,
        aimsmoothing     = settings.aimsmoothing,
        showfov          = settings.showfov,
        fovcolor         = serializeColor(settings.fovcolor),
        -- weapon stuff
        noRecoil         = weaponSettings.noRecoil,
        noSpread         = weaponSettings.noSpread,
        fireRate         = weaponSettings.fireRate,
        fireRateMult     = weaponSettings.fireRateMult,
        -- hitmarker stuff
        hitmarkerEnabled   = hitmarkerSettings.enabled,
        hitmarkerDuration  = hitmarkerSettings.duration * 100,
        hitmarkerColor     = serializeColor(hitmarkerSettings.color),
        hitmarkerKillColor = serializeColor(hitmarkerSettings.killColor),
        hitIndicator       = hitIndicatorSettings.enabled,
        -- triggerbot stuff
        autoShootEnabled = autoShootSettings.enabled,
        autoShootVis     = autoShootSettings.vischeck,
        autoShootDelay   = autoShootSettings.delay * 100,
        -- silentaim stuff
        silentEnabled    = silentSettings.enabled,
        silentTeamcheck  = silentSettings.teamcheck,
        silentVischeck   = silentSettings.vischeck,
        silentFov        = silentSettings.fov,
        silentPart       = silentSettings.targetpart,
        saShowFov        = fovCircleSettings.saEnabled,
        saDotted         = fovCircleSettings.saDotted,
        saAnimated       = fovCircleSettings.saAnimated,
        saSpeed          = fovCircleSettings.saSpeed * 5,
        fovSpeed         = fovCircleSettings.speed * 5,
        saFovColor       = serializeColor(fovCircleSettings.saColor),
        -- esp stuff
        espEnabled       = espCfg.Enabled,
        espBoxes         = espCfg.Boxes,
        espNames         = espCfg.Names,
        espHealth        = espCfg.HealthBar.Enabled,
        espDistance      = espCfg.Distance.Enabled,
        espWeapon        = espCfg.Weapon.Enabled,
        espFlags         = espCfg.Flags.Enabled,
        espSkeleton      = espCfg.Skeleton.Enabled,
        espBoxFill       = espCfg.BoxFill.Enabled,
        espTeamInd       = espCfg.TeamIndicator.Enabled,
        espChams         = espCfg.Chams.Enabled,
        espTeamCheck     = espCfg.TeamCheck,
        espBoxType       = espCfg.BoxType,
        espChamType      = espCfg.Chams.Type,
        espMaxDist       = getFlagNum("espMaxDist", 1000),
        espChamFill      = getFlagNum("espChamFill", 60),
        gradAnim         = espCfg.BoxFill.Gradient.Animated,
        espBoxColor      = serializeColor(espCfg.BoxColor),
        espTextColor     = serializeColor(espCfg.TextColor),
        espChamColor     = serializeColor(espCfg.Chams.Highlight.OutlineColor),
        espSkelColor     = serializeColor(espCfg.Skeleton.Color),
        espBoxFillColor  = serializeColor(espCfg.BoxFill.Color),
        espHealthLow     = serializeColor(espCfg.HealthBar.Gradient.Color3),
        espHealthHigh    = serializeColor(espCfg.HealthBar.Gradient.Color1),
        -- sounds stuff
        hitSoundEnabled  = soundSettings.hitSoundEnabled,
        killSoundEnabled = soundSettings.killSoundEnabled,
        currentHitSound  = soundSettings.currentHitSound,
        currentKillSound = soundSettings.currentKillSound,
        hitVolume        = soundSettings.hitVolume * 100,
        killVolume       = soundSettings.killVolume * 100,
        -- world stuff
        skyboxEnabled    = skyboxEnabled,
        skyboxPreset     = currentSkyboxName,
        atmEnabled       = atmosphereEnabled,
        atmDensity       = atmDensityVal,
        atmOffset        = atmOffsetVal,
        atmHaze          = atmHazeVal,
        atmGlare         = atmGlareVal,
        ambientEnabled    = ambientSettings.enabled,
        ambientColor      = serializeColor(ambientSettings.color),
        ambientBrightness = ambientSettings.brightness * 50,
        -- viewmodel stuff
        vmEnabled        = viewmodelSettings.enabled,
        vmX              = viewmodelSettings.x,
        vmY              = viewmodelSettings.y,
        vmZ              = viewmodelSettings.z,
        -- resolutrion stuff
        resEnabled   = resSettings.enabled,
        resHStretch  = resSettings.horizontal_stretch,
        resVStretch  = resSettings.vertical_stretch,
        -- movement stuff
        cfrmSpeed        = movSettings.cfrmSpeed,
        cfrmSpeedVal     = movSettings.cfrmSpeedVal,
        velSpeed         = movSettings.velSpeed,
        velSpeedVal      = movSettings.velSpeedVal,
        flyEnabled       = movSettings.flyEnabled,
        flySpeed         = movSettings.flySpeed,
        noclip           = movSettings.noclip,
        bhop             = movSettings.bhop,
        jumpPower        = getFlagNum("jumpPower", 7),
        walkSpeed        = getFlagNum("walkSpeed", 16),
        -- skins stuff
        selectedGunSkin   = selectedGunSkin,
        selectedKnifeSkin = selectedKnifeSkin,
        -- spoofer stuff
        spooferStatCredit       = spooferValues.statCredit,
        spooferStatLevel        = spooferValues.statLevel,
        spooferStatKills        = spooferValues.statKills,
        spooferStatDeaths       = spooferValues.statDeaths,
        spooferStatDamage       = spooferValues.statDamage,
        spooferStatRankedRating = spooferValues.statRankedRating,
        spooferStatRankedKills  = spooferValues.statRankedKills,
        spooferStatRankedDeaths = spooferValues.statRankedDeaths,
        spooferPlayerUsername   = spooferValues.playerUsername,
        spooferPlayerDisplay    = spooferValues.playerDisplay,
        -- ui stuff
        accentColor       = serializeColor(Library.Theme and Library.Theme.Accent or Color3.fromRGB(255,255,255)),
        watermarkVisible  = Library.Flags["WatermarkVisible"],
        keybindVisible    = Library.Flags["KeybindListVisible"],
        staffDetector     = staffDetectorEnabled,
        hitNotify         = hitSettings.notifyEnabled,
        hitNotifyDuration = hitSettings.notifyDuration,
        -- autoqueue
        autoQueueEnabled = autoQueueSettings.enabled,
        autoQueueMode    = autoQueueSettings.gamemode,
        -- crosshair stuff
        chEnabled   = crosshairSettings.enabled,
        chDot       = crosshairSettings.dot,
        chSpin      = crosshairSettings.spin,
        chSpinSpeed = getFlagNum("chSpinSpeed", 20),
        chSizeAnim  = crosshairSettings.sizeAnim,
        chSizeMin   = getFlagNum("chSizeMin", 6),
        chSizeMax   = getFlagNum("chSizeMax", 14),
        chSizeSpeed = getFlagNum("chSizeSpeed", 50),
        chSize      = getFlagNum("chSize", 10),
        chGap       = getFlagNum("chGap", 4),
        chThickness = getFlagNum("chThickness", 2),
        chColor     = serializeColor(crosshairSettings.color),
        -- keybinds stuff
        noRecoilBind  = getKeybindKey("noRecoilBind"),
        noSpreadBind  = getKeybindKey("noSpreadBind"),
        rapidFireBind = getKeybindKey("rapidFireBind"),
        silentBind    = getKeybindKey("silentBind"),
        autoBind      = getKeybindKey("autoBind"),
        cfrmSpeedBind = getKeybindKey("cfrmSpeedBind"),
        velSpeedBind  = getKeybindKey("velSpeedBind"),
        flyBind       = getKeybindKey("flyBind"),
        noclipBind    = getKeybindKey("noclipBind"),
        bhopBind      = getKeybindKey("bhopBind"),
        knifebotBind  = getKeybindKey("knifebotBind"),
        MenuKeybind   = getKeybindKey("MenuKeybind"),
    }
end

local function listConfigs()
    local files = listfiles(CONFIG_FOLDER)
    local names = {}
    for _, path in ipairs(files) do
        local name = path:match("([^/\\]+)" .. CONFIG_EXT .. "$")
        if name then table.insert(names, name) end
    end
    table.sort(names)
    return names
end

local function saveConfig(name)
    if name == "" then return false end
    writefile(getConfigPath(name), game:GetService("HttpService"):JSONEncode(buildConfig()))
    return true
end

local function loadConfig(name)
    local path = getConfigPath(name)
    if not isfile(path) then return false end
    local ok, r = pcall(function() return game:GetService("HttpService"):JSONDecode(readfile(path)) end)
    if not ok or not r then return false end

    local function applyFlag(flag, value)
        pcall(function()
            local setter = Library.SetFlags and Library.SetFlags[flag]
            if setter then setter(value) end
        end)
    end

    -- keybinds
    local keybindFlags = {
        "noRecoilBind", "noSpreadBind", "rapidFireBind", "silentBind",
        "autoBind", "cfrmSpeedBind", "velSpeedBind", "flyBind",
        "noclipBind", "bhopBind", "knifebotBind", "MenuKeybind",
    }
    for _, flag in ipairs(keybindFlags) do
        if r[flag] ~= nil then
            local data = r[flag]
            if type(data) == "string" then data = { Key = data, Mode = "Toggle" } end
            applyFlag(flag, data)
        end
    end

    -- aimbot
    if r.aimenable    ~= nil then settings.aimenable    = r.aimenable;    applyFlag("aimenable",    r.aimenable)    end
    if r.aimPriority  ~= nil then settings.priority     = r.aimPriority;  applyFlag("aimPriority",  r.aimPriority)  end
    if r.aimmode      ~= nil then settings.aimmode      = r.aimmode;      applyFlag("aimmode",      r.aimmode)      end
    if r.aimpart      ~= nil then settings.aimpart      = r.aimpart;      applyFlag("aimpart",      r.aimpart)      end
    if r.aimteamcheck ~= nil then settings.aimteamcheck = r.aimteamcheck; applyFlag("aimteamcheck", r.aimteamcheck) end
    if r.aimwallcheck ~= nil then settings.wallcheck    = r.aimwallcheck; applyFlag("aimwallcheck", r.aimwallcheck) end
    if r.aimfov       ~= nil then settings.aimfov       = r.aimfov;       applyFlag("aimfov",       r.aimfov)       end
    if r.aimsmoothing ~= nil then settings.aimsmoothing = r.aimsmoothing; applyFlag("aimsmoothing", math.floor(r.aimsmoothing * 100)) end
    if r.showfov      ~= nil then settings.showfov      = r.showfov;      applyFlag("showfov",      r.showfov)      end
    if r.fovcolor     ~= nil then settings.fovcolor = deserializeColor(r.fovcolor); applyFlag("fovcolor", settings.fovcolor) end
    if r.aimkey ~= nil then
        local keyData = type(r.aimkey) == "table" and r.aimkey or { Key = r.aimkey, Mode = "Hold" }
        applyFlag("aimkey", keyData)
        local resolved = resolve_key(keyData.Key)
        if resolved then settings.aimkey = resolved end
    end

    -- weapon mods
    if r.noRecoil     ~= nil then weaponSettings.noRecoil     = r.noRecoil;     applyFlag("noRecoil",     r.noRecoil)     end
    if r.noSpread     ~= nil then weaponSettings.noSpread     = r.noSpread;     applyFlag("noSpread",     r.noSpread)     end
    if r.fireRate     ~= nil then weaponSettings.fireRate     = r.fireRate;     applyFlag("fireRate",     r.fireRate)     end
    if r.fireRateMult ~= nil then weaponSettings.fireRateMult = r.fireRateMult; applyFlag("fireRateMult", r.fireRateMult) end

    -- hitmarker
    if r.hitmarkerEnabled   ~= nil then hitmarkerSettings.enabled   = r.hitmarkerEnabled;        applyFlag("hitmarkerEnabled",  r.hitmarkerEnabled)   end
    if r.hitmarkerDuration  ~= nil then hitmarkerSettings.duration  = r.hitmarkerDuration / 100; applyFlag("hitmarkerDuration", r.hitmarkerDuration)  end
    if r.hitmarkerColor     ~= nil then hitmarkerSettings.color     = deserializeColor(r.hitmarkerColor);     applyFlag("hitmarkerColor",     hitmarkerSettings.color)     end
    if r.hitmarkerKillColor ~= nil then hitmarkerSettings.killColor = deserializeColor(r.hitmarkerKillColor); applyFlag("hitmarkerKillColor", hitmarkerSettings.killColor) end
    if r.hitIndicator       ~= nil then hitIndicatorSettings.enabled = r.hitIndicator; applyFlag("hitIndicator", r.hitIndicator) end

    -- triggerbot
    if r.autoShootEnabled ~= nil then autoShootSettings.enabled  = r.autoShootEnabled;     applyFlag("autoShootEnabled", r.autoShootEnabled) end
    if r.autoShootVis     ~= nil then autoShootSettings.vischeck = r.autoShootVis;         applyFlag("autoShootVis",     r.autoShootVis)     end
    if r.autoShootDelay   ~= nil then autoShootSettings.delay    = r.autoShootDelay / 100; applyFlag("autoShootDelay",   r.autoShootDelay)   end

    -- silent aim
    if r.silentEnabled   ~= nil then silentSettings.enabled    = r.silentEnabled;   applyFlag("silentEnabled", r.silentEnabled)   end
    if r.silentTeamcheck ~= nil then silentSettings.teamcheck  = r.silentTeamcheck; applyFlag("silentTeam",    r.silentTeamcheck) end
    if r.silentVischeck  ~= nil then silentSettings.vischeck   = r.silentVischeck;  applyFlag("silentVis",     r.silentVischeck)  end
    if r.silentFov       ~= nil then silentSettings.fov        = r.silentFov;       applyFlag("silentFov",     r.silentFov)       end
    if r.silentPart      ~= nil then silentSettings.targetpart = r.silentPart;      applyFlag("silentPart",    r.silentPart)      end
    -- SA fov circle
    if r.saShowFov  ~= nil then fovCircleSettings.saEnabled  = r.saShowFov;   applyFlag("saShowFov",  r.saShowFov)  end
    if r.saDotted   ~= nil then fovCircleSettings.saDotted   = r.saDotted;    applyFlag("saDotted",   r.saDotted)   end
    if r.saAnimated ~= nil then fovCircleSettings.saAnimated = r.saAnimated;  applyFlag("saAnim",     r.saAnimated) end
    if r.saSpeed    ~= nil then fovCircleSettings.saSpeed    = r.saSpeed / 5; applyFlag("saFovSpeed", r.saSpeed)    end
    if r.fovSpeed   ~= nil then fovCircleSettings.speed = r.fovSpeed / 5; applyFlag("fovSpeed", r.fovSpeed) end
    if r.saFovColor ~= nil then
        local c = deserializeColor(r.saFovColor)
        fovCircleSettings.saColor = c
        applyFlag("saFovColor", c)
    end

    -- esp
    if r.espEnabled   ~= nil then espCfg.Enabled               = r.espEnabled;   applyFlag("espEnabled",   r.espEnabled)   end
    if r.espBoxes     ~= nil then espCfg.Boxes                 = r.espBoxes;     applyFlag("espBoxes",     r.espBoxes)     end
    if r.espNames     ~= nil then espCfg.Names                 = r.espNames;     applyFlag("espNames",     r.espNames)     end
    if r.espHealth    ~= nil then espCfg.HealthBar.Enabled     = r.espHealth;    applyFlag("espHealth",    r.espHealth)    end
    if r.espDistance  ~= nil then espCfg.Distance.Enabled      = r.espDistance;  applyFlag("espDistance",  r.espDistance)  end
    if r.espWeapon    ~= nil then espCfg.Weapon.Enabled        = r.espWeapon;    applyFlag("espWeapon",    r.espWeapon)    end
    if r.espFlags     ~= nil then espCfg.Flags.Enabled         = r.espFlags;     applyFlag("espFlags",     r.espFlags)     end
    if r.espSkeleton  ~= nil then espCfg.Skeleton.Enabled      = r.espSkeleton;  applyFlag("espSkeleton",  r.espSkeleton)  end
    if r.espBoxFill   ~= nil then espCfg.BoxFill.Enabled       = r.espBoxFill;   applyFlag("espBoxFill",   r.espBoxFill)   end
    if r.espTeamInd   ~= nil then espCfg.TeamIndicator.Enabled = r.espTeamInd;   applyFlag("espTeamInd",   r.espTeamInd)   end
    if r.espChams     ~= nil then espCfg.Chams.Enabled         = r.espChams;     applyFlag("espChams",     r.espChams)     end
    if r.espTeamCheck ~= nil then espCfg.TeamCheck             = r.espTeamCheck; applyFlag("espTeamCheck", r.espTeamCheck) end
    if r.espBoxType   ~= nil then espCfg.BoxType               = r.espBoxType;   applyFlag("espBoxType",   r.espBoxType)   end
    if r.espChamType  ~= nil then espCfg.Chams.Type            = r.espChamType;  applyFlag("espChamType",  r.espChamType)  end
    if r.espMaxDist   ~= nil then espCfg.MaxDistance           = r.espMaxDist;   applyFlag("espMaxDist",   r.espMaxDist)   end
    if r.gradAnim     ~= nil then espCfg.BoxFill.Gradient.Animated = r.gradAnim; applyFlag("gradAnim",     r.gradAnim)     end
    if r.espChamFill  ~= nil then
        espCfg.Chams.Highlight.FillTransparency = r.espChamFill / 100
        espCfg.Chams.Adornment.Transparency     = r.espChamFill / 100
        applyFlag("espChamFill", r.espChamFill)
    end
    if r.espBoxColor     ~= nil then local c = deserializeColor(r.espBoxColor);     espCfg.BoxColor                     = c; applyFlag("espBoxColor",     c) end
    if r.espTextColor    ~= nil then local c = deserializeColor(r.espTextColor);    espCfg.TextColor                    = c; applyFlag("espTextColor",    c) end
    if r.espSkelColor    ~= nil then local c = deserializeColor(r.espSkelColor);    espCfg.Skeleton.Color               = c; applyFlag("espSkelColor",    c) end
    if r.espChamColor    ~= nil then
        local c = deserializeColor(r.espChamColor)
        espCfg.Chams.Highlight.OutlineColor = c
        espCfg.Chams.Adornment.Color        = c
        applyFlag("espChamColor", c)
    end
    if r.espBoxFillColor ~= nil then
        local c = deserializeColor(r.espBoxFillColor)
        espCfg.BoxFill.Color = c
        if espCfg.BoxFill.Gradient then
            espCfg.BoxFill.Gradient.Color1 = c
            espCfg.BoxFill.Gradient.Color2 = c
            espCfg.BoxFill.Gradient.Color3 = c
        end
        applyFlag("espBoxFillColor", c)
    end
    if r.espHealthLow  ~= nil then
        local c = deserializeColor(r.espHealthLow)
        if espCfg.HealthBar and espCfg.HealthBar.Gradient then espCfg.HealthBar.Gradient.Color3 = c end
        applyFlag("espHealthLow", c)
    end
    if r.espHealthHigh ~= nil then
        local c = deserializeColor(r.espHealthHigh)
        if espCfg.HealthBar and espCfg.HealthBar.Gradient then espCfg.HealthBar.Gradient.Color1 = c end
        applyFlag("espHealthHigh", c)
    end

    -- sounds
    if r.hitSoundEnabled  ~= nil then soundSettings.hitSoundEnabled  = r.hitSoundEnabled;  applyFlag("hitSoundEnabled",  r.hitSoundEnabled)  end
    if r.killSoundEnabled ~= nil then soundSettings.killSoundEnabled = r.killSoundEnabled; applyFlag("killSoundEnabled", r.killSoundEnabled) end
    if r.currentHitSound  ~= nil then soundSettings.currentHitSound  = r.currentHitSound;  applyFlag("hitSound",         r.currentHitSound)  end
    if r.currentKillSound ~= nil then soundSettings.currentKillSound = r.currentKillSound; applyFlag("killSound",        r.currentKillSound) end
    if r.hitVolume        ~= nil then soundSettings.hitVolume        = r.hitVolume / 100;  applyFlag("hitVolume",        r.hitVolume)        end
    if r.killVolume       ~= nil then soundSettings.killVolume       = r.killVolume / 100; applyFlag("killVolume",       r.killVolume)       end

    -- world
    if r.skyboxPreset  ~= nil then currentSkyboxName = r.skyboxPreset; applyFlag("skyboxPreset", r.skyboxPreset) end
    if r.skyboxEnabled ~= nil then
        skyboxEnabled = r.skyboxEnabled; applyFlag("skyboxEnabled", r.skyboxEnabled)
        if skyboxEnabled then applySkybox(currentSkyboxName) else removeSkybox() end
    end
    if r.atmEnabled ~= nil then
        atmosphereEnabled = r.atmEnabled; applyFlag("atmEnabled", r.atmEnabled)
        if atmosphereEnabled then cacheAtmosphere() end
    end
    if r.atmDensity ~= nil then applyFlag("atmDensity", r.atmDensity); if atmosphereEnabled then getOrCreateAtmosphere().Density = r.atmDensity / 100 end end
    if r.atmOffset  ~= nil then applyFlag("atmOffset",  r.atmOffset);  if atmosphereEnabled then getOrCreateAtmosphere().Offset  = r.atmOffset  / 100 end end
    if r.atmHaze    ~= nil then applyFlag("atmHaze",    r.atmHaze);    if atmosphereEnabled then getOrCreateAtmosphere().Haze    = r.atmHaze    / 10  end end
    if r.atmGlare   ~= nil then applyFlag("atmGlare",   r.atmGlare);   if atmosphereEnabled then getOrCreateAtmosphere().Glare   = r.atmGlare   / 100 end end
    if r.ambientEnabled ~= nil then ambientSettings.enabled = r.ambientEnabled; applyFlag("ambientEnabled", r.ambientEnabled) end
    if r.ambientColor ~= nil then
        local c = deserializeColor(r.ambientColor)
        ambientSettings.color = c
        applyFlag("ambientColor", c)
        if ambientSettings.enabled then game:GetService("Lighting").Ambient = c end
    end
    if r.ambientBrightness ~= nil then
        ambientSettings.brightness = r.ambientBrightness / 50
        applyFlag("ambientBrightness", r.ambientBrightness)
        if ambientSettings.enabled then game:GetService("Lighting").Brightness = ambientSettings.brightness end
    end

    -- viewmodel
    if r.vmEnabled ~= nil then viewmodelSettings.enabled = r.vmEnabled; applyFlag("vmEnabled", r.vmEnabled) end
    if r.vmX       ~= nil then viewmodelSettings.x       = r.vmX;       applyFlag("vmX",       r.vmX)       end
    if r.vmY       ~= nil then viewmodelSettings.y       = r.vmY;       applyFlag("vmY",       r.vmY)       end
    if r.vmZ       ~= nil then viewmodelSettings.z       = r.vmZ;       applyFlag("vmZ",       r.vmZ)       end

    -- resolution
    if r.resEnabled  ~= nil then resSettings.enabled            = r.resEnabled;  applyFlag("resEnabled",  r.resEnabled)  end
    if r.resHStretch ~= nil then resSettings.horizontal_stretch = r.resHStretch; applyFlag("resHStretch", r.resHStretch) end
    if r.resVStretch ~= nil then resSettings.vertical_stretch   = r.resVStretch; applyFlag("resVStretch", r.resVStretch) end

    -- movement
    if r.cfrmSpeed    ~= nil then movSettings.cfrmSpeed    = r.cfrmSpeed;    applyFlag("cfrmSpeed",    r.cfrmSpeed)    end
    if r.cfrmSpeedVal ~= nil then movSettings.cfrmSpeedVal = r.cfrmSpeedVal; applyFlag("cfrmSpeedVal", r.cfrmSpeedVal) end
    if r.velSpeed     ~= nil then movSettings.velSpeed     = r.velSpeed;     applyFlag("velSpeed",     r.velSpeed)     end
    if r.velSpeedVal  ~= nil then movSettings.velSpeedVal  = r.velSpeedVal;  applyFlag("velSpeedVal",  r.velSpeedVal)  end
    if r.flyEnabled   ~= nil then
        movSettings.flyEnabled = r.flyEnabled; applyFlag("flyEnabled", r.flyEnabled)
        if r.flyEnabled then startFly() else stopFly() end
    end
    if r.flySpeed ~= nil then movSettings.flySpeed = r.flySpeed; applyFlag("flySpeed", r.flySpeed) end
    if r.noclip ~= nil then
        movSettings.noclip = r.noclip; applyFlag("noclip", r.noclip)
        if r.noclip then startNoclip() end
    end
    if r.bhop ~= nil then
        movSettings.bhop = r.bhop; applyFlag("bhop", r.bhop)
        if r.bhop then startBhop() end
    end
    if r.jumpPower ~= nil then
        applyFlag("jumpPower", r.jumpPower)
        local char = localplayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpHeight = r.jumpPower end
    end
    if r.walkSpeed ~= nil then
        applyFlag("walkSpeed", r.walkSpeed)
        local char = localplayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = r.walkSpeed end
    end

    -- skins
    if r.selectedGunSkin   ~= nil then selectedGunSkin   = r.selectedGunSkin;   applyFlag("gunSkinSelect",   r.selectedGunSkin)   end
    if r.selectedKnifeSkin ~= nil then selectedKnifeSkin = r.selectedKnifeSkin; applyFlag("knifeSkinSelect", r.selectedKnifeSkin) end

    -- spoofer
    local spooferMap = {
        { cfg="spooferStatCredit",       key="statCredit"       },
        { cfg="spooferStatLevel",        key="statLevel"        },
        { cfg="spooferStatKills",        key="statKills"        },
        { cfg="spooferStatDeaths",       key="statDeaths"       },
        { cfg="spooferStatDamage",       key="statDamage"       },
        { cfg="spooferStatRankedRating", key="statRankedRating" },
        { cfg="spooferStatRankedKills",  key="statRankedKills"  },
        { cfg="spooferStatRankedDeaths", key="statRankedDeaths" },
        { cfg="spooferPlayerUsername",   key="playerUsername"   },
        { cfg="spooferPlayerDisplay",    key="playerDisplay"    },
    }
    for _, entry in ipairs(spooferMap) do
        if r[entry.cfg] ~= nil then
            local val = tostring(r[entry.cfg])
            spooferValues[entry.key] = val
            applyFlag(entry.key, val)
        end
    end

    -- ui
    if r.accentColor      ~= nil then local c = deserializeColor(r.accentColor); pcall(function() Library:ChangeTheme("Accent", c) end); applyFlag("AccentColor", c) end
    if r.watermarkVisible ~= nil then applyFlag("WatermarkVisible",   r.watermarkVisible); Watermark:SetVisibility(r.watermarkVisible)   end
    if r.keybindVisible   ~= nil then applyFlag("KeybindListVisible", r.keybindVisible);   KeybindList:SetVisibility(r.keybindVisible)   end
    if r.staffDetector    ~= nil then staffDetectorEnabled = r.staffDetector; applyFlag("staffDetector", r.staffDetector) end
    if r.hitNotify        ~= nil then hitSettings.notifyEnabled   = r.hitNotify;         applyFlag("hitNotify",         r.hitNotify)        end
    if r.hitNotifyDuration ~= nil then hitSettings.notifyDuration = r.hitNotifyDuration; applyFlag("hitNotifyDuration", r.hitNotifyDuration) end

    -- autoqueue
    if r.autoQueueMode    ~= nil then autoQueueSettings.gamemode = r.autoQueueMode; applyFlag("autoQueueMode", r.autoQueueMode) end
    if r.autoQueueEnabled ~= nil then
        if r.autoQueueEnabled then startAutoQueue() else stopAutoQueue() end
        applyFlag("autoQueueEnabled", r.autoQueueEnabled)
    end

    -- crosshair
    if r.chEnabled  ~= nil then crosshairSettings.enabled  = r.chEnabled;  applyFlag("chEnabled",  r.chEnabled)  end
    if r.chDot      ~= nil then crosshairSettings.dot      = r.chDot;      applyFlag("chDot",      r.chDot)      end
    if r.chSpin     ~= nil then crosshairSettings.spin     = r.chSpin;     applyFlag("chSpin",     r.chSpin)     end
    if r.chSizeAnim ~= nil then crosshairSettings.sizeAnim = r.chSizeAnim; applyFlag("chSizeAnim", r.chSizeAnim) end
    if r.chSpinSpeed ~= nil then crosshairSettings.spinSpeed = r.chSpinSpeed / 10; applyFlag("chSpinSpeed", r.chSpinSpeed) end
    if r.chSizeMin  ~= nil then crosshairSettings.sizeMin  = r.chSizeMin;  applyFlag("chSizeMin",  r.chSizeMin)  end
    if r.chSizeMax  ~= nil then crosshairSettings.sizeMax  = r.chSizeMax;  applyFlag("chSizeMax",  r.chSizeMax)  end
    if r.chSizeSpeed ~= nil then crosshairSettings.sizeSpeed = r.chSizeSpeed * 0.5; applyFlag("chSizeSpeed", r.chSizeSpeed) end
    if r.chSize     ~= nil then crosshairSettings.size     = r.chSize;     applyFlag("chSize",     r.chSize)     end
    if r.chGap      ~= nil then crosshairSettings.gap      = r.chGap;      applyFlag("chGap",      r.chGap)      end
    if r.chThickness ~= nil then crosshairSettings.thickness = r.chThickness; applyFlag("chThickness", r.chThickness) end
    if r.chColor    ~= nil then
        local c = deserializeColor(r.chColor)
        crosshairSettings.color = c
        applyFlag("chColor", c)
    end

    return true
end

local function deleteConfig(name)
    local path = getConfigPath(name)
    if isfile(path) then delfile(path); return true end
    return false
end

local function getAutoloadName()
    if not isfile(AUTOLOAD_FILE) then return nil end
    local ok, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile(AUTOLOAD_FILE))
    end)
    if ok and data and type(data.config) == "string" then return data.config end
    return nil
end

local function setAutoload(name)
    writefile(AUTOLOAD_FILE, game:GetService("HttpService"):JSONEncode({ config = name }))
end

local function clearAutoload()
    if isfile(AUTOLOAD_FILE) then delfile(AUTOLOAD_FILE) end
end

do -- settings
local MenuSection    = SettingsTab:Section({ Name = "menu",          Side = 1 })
local ConfigSection  = SettingsTab:Section({ Name = "configs",       Side = 1 })
local DisplaySection = SettingsTab:Section({ Name = "display",       Side = 2 })
local UIColorSection = SettingsTab:Section({ Name = "ui color",      Side = 2 })
local EffectsSection = SettingsTab:Section({ Name = "cool ui stuff", Side = 2 })
local HitLogSection  = SettingsTab:Section({ Name = "hit log",       Side = 2 })

EffectsSection:Toggle({
    Name = "background blur", Default = false,
    Callback = function(v)
        menuBlurEnabled = v
        if Window.IsOpen then setMenuBlur(v) end
    end
})

EffectsSection:Toggle({
    Name = "background snow", Default = false,
    Callback = function(v)
        menuSnowEnabled = v
        if v and Window.IsOpen then startMenuSnow()
        elseif not v then stopMenuSnow() end
    end
})

if not isMobile then
    MenuSection:Label("menu keybind"):Keybind({
        Flag = "MenuKeybind", Default = Enum.KeyCode.RightShift, Mode = "Toggle",
        Callback = function()
            local flagData = Library.Flags["MenuKeybind"]
            if flagData and flagData.Key then Library.MenuKeybind = flagData.Key end
        end
    })
end

DisplaySection:Toggle({ Name = "watermark",    Flag = "WatermarkVisible",   Default = true, Callback = function(v) Watermark:SetVisibility(v)   end })
DisplaySection:Toggle({ Name = "keybind list", Flag = "KeybindListVisible", Default = true, Callback = function(v) KeybindList:SetVisibility(v) end })
DisplaySection:Toggle({
    Name = "staff detector", Flag = "staffDetector", Default = true,
    Callback = function(v)
        staffDetectorEnabled = v
        if v then
            table.clear(detectedUsers)
            for _, player in ipairs(players:GetPlayers()) do detectPlayer(player) end
        end
    end
})

DisplaySection:Button():Add("unload", function()
    unloading = true
    resSettings.enabled = false
    _resPrevCFrame = nil

    menuBlurEnabled = false
    menuSnowEnabled = false
    setMenuBlur(false)
    stopMenuSnow()

    knifebotActive = false

    stopAutoQueue()

    table.clear(recentTargets)

    movSettings.cfrmSpeed  = false
    movSettings.velSpeed   = false
    movSettings.noclip     = false
    movSettings.bhop       = false
    movSettings.flyEnabled = false

    if cfrmConn   then cfrmConn:Disconnect();   cfrmConn   = nil end
    if velConn    then velConn:Disconnect();    velConn    = nil end
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    if bhopConn   then bhopConn:Disconnect();   bhopConn   = nil end
    stopFly()

    local char = localplayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hum then
        pcall(function() hum.WalkSpeed     = 16  end)
        pcall(function() hum.JumpHeight    = 7.2 end)
        pcall(function() hum.PlatformStand = false end)
    end
    if hrp then
        pcall(function() hrp.Anchored = false end)
        pcall(function() hrp.AssemblyLinearVelocity = Vector3.new() end)
    end
    if char then
        for _, p in ipairs(char:GetChildren()) do
            if p:IsA("BasePart") and NOCLIP_PARTS[p.Name] then
                pcall(function() p.CanCollide = true end)
            end
        end
    end

    -- restore spoofer
    if spooferSupported then
        if _Stats then
            pcall(function() _Stats:SetAttribute("Credit",       originalStats.Credit)       end)
            pcall(function() _Stats:SetAttribute("Level",        originalStats.Level)        end)
            pcall(function() _Stats:SetAttribute("Kills",        originalStats.Kills)        end)
            pcall(function() _Stats:SetAttribute("Deaths",       originalStats.Deaths)       end)
            pcall(function() _Stats:SetAttribute("Damage",       originalStats.Damage)       end)
            pcall(function() _Stats:SetAttribute("RankedRating", originalStats.RankedRating) end)
            pcall(function() _Stats:SetAttribute("RankedKills",  originalStats.RankedKills)  end)
            pcall(function() _Stats:SetAttribute("RankedDeaths", originalStats.RankedDeaths) end)
        end
        pcall(function() localplayer.Name        = originalUsername    end)
        pcall(function() localplayer.DisplayName = originalDisplayName end)
    end

    -- restore lighting/world
    removeSkybox()
    if originalAtmosphere then
        local atm = Lighting:FindFirstChildOfClass("Atmosphere")
        if atm then
            pcall(function() atm.Density = originalAtmosphere.Density end)
            pcall(function() atm.Offset  = originalAtmosphere.Offset  end)
            pcall(function() atm.Glare   = originalAtmosphere.Glare   end)
            pcall(function() atm.Haze    = originalAtmosphere.Haze    end)
        end
    end
    pcall(function() game:GetService("Lighting").Ambient    = defaultAmbient    end)
    pcall(function() game:GetService("Lighting").Brightness = defaultBrightness end)

    -- restore weapon mods
    for v in pairs(WM_Clients) do
        if WM_BaseRates[v] then
            pcall(function() v.FireRate = WM_BaseRates[v] end)
            WM_BaseRates[v] = nil
        end
    end

    -- esp/drawings
    ESP:Unload()
    if esp_conn then esp_conn:Disconnect(); esp_conn = nil end
    for i = 1, FOV_DOTS do
        pcall(function() fov_dots[i].Visible    = false; fov_dots[i]:Remove()    end)
        pcall(function() sa_fov_dots[i].Visible = false; sa_fov_dots[i]:Remove() end)
    end
    pcall(function() fov_solid:Remove()    end)
    pcall(function() sa_fov_solid:Remove() end)
    for _, l in ipairs(_chLines) do pcall(function() l:Remove() end) end
    pcall(function() _chDot:Remove() end)
    pcall(removeLogoHud)

    -- skin changer
    if _G.INDEX_gunSkinConn   then _G.INDEX_gunSkinConn:Disconnect();   _G.INDEX_gunSkinConn   = nil end
    if _G.INDEX_knifeSkinConn then _G.INDEX_knifeSkinConn:Disconnect(); _G.INDEX_knifeSkinConn = nil end
    if _G.INDEX_camModelConn  then _G.INDEX_camModelConn:Disconnect();  _G.INDEX_camModelConn  = nil end

    -- sound connections
    for sound in pairs(activeSounds) do pcall(function() sound:Stop(); sound:Destroy() end) end
    table.clear(activeSounds)
    for _, conn in ipairs(characterAddedConnections) do pcall(function() conn:Disconnect() end) end
    table.clear(characterAddedConnections)
    for _, conn in pairs(mutedConnections) do pcall(function() conn:Disconnect() end) end
    table.clear(mutedConnections)
    if descendantConnection then descendantConnection:Disconnect(); descendantConnection = nil end
    if hitmarkerWatcher     then hitmarkerWatcher:Disconnect();     hitmarkerWatcher     = nil end

    -- silentaim hook
    if SA_OldNamecall then
        pcall(function() hookmetamethod(game, "__namecall", SA_OldNamecall) end)
        SA_OldNamecall = nil
    end

    -- viewmodel
    runservice:UnbindFromRenderStep("VMOffset")

    -- mobile ui
    local mobileGui = localplayer.PlayerGui:FindFirstChild("IndexMobileToggle")
    if mobileGui then mobileGui:Destroy() end

    Library:Unload()
end)

UIColorSection:Label("accent color"):Colorpicker({
    Flag = "AccentColor", Default = Library.Theme and Library.Theme.Accent or Color3.fromRGB(255,255,255),
    Callback = function(c) Library:ChangeTheme("Accent", c) end
})

HitLogSection:Toggle({ Name = "hit notification", Flag = "hitNotify",         Default = true, Callback = function(v) hitSettings.notifyEnabled  = v end })
HitLogSection:Slider({ Name = "notify duration",  Flag = "hitNotifyDuration", Min = 1, Max = 10, Default = 3, Callback = function(v) hitSettings.notifyDuration = v end })

local configNameInput = ""
local selectedConfig  = ""

local cfgDropdown = ConfigSection:Dropdown({
    Name = "select", Flag = "configSelect", Default = nil,
    Items = listConfigs(),
    Callback = function(v) selectedConfig = v or "" end
})

local function refreshDropdown()
    cfgDropdown:Refresh(listConfigs())
    selectedConfig = ""
end

ConfigSection:Textbox({
    Name = "config name", Flag = "configNameInput", Default = "", Placeholder = "name...",
    Callback = function(v) configNameInput = v end
})
ConfigSection:Button():Add("save", function()
    local name = (configNameInput ~= "" and configNameInput or "default"):gsub("[/\\%.%s]", "_")
    if saveConfig(name) then refreshDropdown(); Library:Notification("saved", name, 4) end
end)
ConfigSection:Button():Add("load", function()
    if selectedConfig == "" then Library:Notification("error", "select a config first", 3); return end
    if loadConfig(selectedConfig) then Library:Notification("loaded", selectedConfig, 4)
    else Library:Notification("error", "failed to load config", 3) end
end)
ConfigSection:Button():Add("delete", function()
    if selectedConfig == "" then Library:Notification("error", "select a config first", 3); return end
    local name = selectedConfig
    if deleteConfig(name) then
        if getAutoloadName() == name then clearAutoload() end
        refreshDropdown()
        Library:Notification("deleted", name, 4)
    else
        Library:Notification("error", "config not found", 3)
    end
end)
ConfigSection:Button():Add("refresh", function()
    refreshDropdown()
    Library:Notification("refreshed", #listConfigs() .. " config(s) found", 3)
end)
ConfigSection:Button():Add("set as autoload", function()
    if selectedConfig == "" then Library:Notification("error", "select a config first", 3); return end
    setAutoload(selectedConfig)
    Library:Notification("autoload", selectedConfig .. " will load on next inject", 4)
end)
ConfigSection:Button():Add("clear autoload", function()
    clearAutoload()
    Library:Notification("autoload", "autoload cleared", 3)
end)

end -- settings

do -- movement
local SpeedSection    = MovementTab:Section({ Name = "speed",    Side = 1 })
local FlySection      = MovementTab:Section({ Name = "fly",      Side = 1 })
local TeleportSection = MovementTab:Section({ Name = "teleport", Side = 2 })
local MiscMovSection  = MovementTab:Section({ Name = "misc",     Side = 2 })

flyConn    = nil
noclipConn = nil
bhopConn   = nil
cfrmConn   = nil

local function startCFrmSpeed()
    if cfrmConn then cfrmConn:Disconnect() end
    cfrmConn = runservice.Heartbeat:Connect(function()
        if not movSettings.cfrmSpeed then return end
        local char = localplayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        local dir = hum.MoveDirection
        if dir.Magnitude > 0 then hrp.CFrame = hrp.CFrame + dir * movSettings.cfrmSpeedVal * 0.01 end
    end)
end
startCFrmSpeed()

velConn = nil
local function startVelSpeed()
    if velConn then velConn:Disconnect() end
    velConn = runservice.Heartbeat:Connect(function()
        if not movSettings.velSpeed then return end
        local char = localplayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        local dir = hum.MoveDirection
        if dir.Magnitude > 0 then hrp.AssemblyLinearVelocity = dir * movSettings.velSpeedVal end
    end)
end
startVelSpeed()

local cfrmToggle = SpeedSection:Toggle({
    Name = "cframe speed", Flag = "cfrmSpeed", Default = false,
    Callback = function(v) movSettings.cfrmSpeed = v end
})
cfrmToggle:Keybind({ Flag = "cfrmSpeedBind", Default = "None", Mode = "Toggle", Callback = function(v) cfrmToggle:Set(v) end })
SpeedSection:Slider({ Name = "cframe speed value", Flag = "cfrmSpeedVal", Default = 27, Min = 1, Max = 300, Callback = function(v) movSettings.cfrmSpeedVal = v end })

local velToggle = SpeedSection:Toggle({
    Name = "velocity speed", Flag = "velSpeed", Default = false,
    Callback = function(v) movSettings.velSpeed = v end
})
velToggle:Keybind({ Flag = "velSpeedBind", Default = "None", Mode = "Toggle", Callback = function(v) velToggle:Set(v) end })
SpeedSection:Slider({ Name = "velocity speed value", Flag = "velSpeedVal", Default = 30, Min = 1, Max = 300, Callback = function(v) movSettings.velSpeedVal = v end })

local flyToggle = FlySection:Toggle({
    Name = "enabled", Flag = "flyEnabled", Default = false,
    Callback = function(v) movSettings.flyEnabled = v; if v then startFly() else stopFly() end end
})
flyToggle:Keybind({ Flag = "flyBind", Default = "None", Mode = "Toggle", Callback = function(v) flyToggle:Set(v) end })
FlySection:Slider({ Name = "speed", Flag = "flySpeed", Default = 5, Min = 1, Max = 100, Callback = function(v) movSettings.flySpeed = v end })

localplayer.CharacterAdded:Connect(function()
    if movSettings.flyEnabled then task.wait(0.5); startFly() end
end)

local function getPlayerList()
    local list = {}
    for _, p in ipairs(players:GetPlayers()) do
        if p ~= localplayer then table.insert(list, p.Name) end
    end
    return list
end

local tpPlayerDropdown = TeleportSection:Dropdown({
    Name = "player", Flag = "tpTarget", Default = nil,
    Items = getPlayerList(), Callback = function() end
})
TeleportSection:Button():Add("teleport to player", function()
    local target = Library.Flags["tpTarget"]
    if not target or target == "" then Library:Notification("teleport", "select a player first", 3); return end
    local targetPlayer = players:FindFirstChild(target)
    local char  = localplayer.Character
    local hrp   = char and char:FindFirstChild("HumanoidRootPart")
    local tchar = targetPlayer and targetPlayer.Character
    local thrp  = tchar and tchar:FindFirstChild("HumanoidRootPart")
    if hrp and thrp then hrp.CFrame = thrp.CFrame + Vector3.new(0, 3, 0)
    else Library:Notification("teleport", "player not found", 3) end
end)
TeleportSection:Button():Add("refresh list", function() tpPlayerDropdown:Refresh(getPlayerList()) end)

startNoclip = function()
    if noclipConn then noclipConn:Disconnect() end
    noclipConn = runservice.Stepped:Connect(function()
        if not movSettings.noclip then noclipConn:Disconnect(); noclipConn = nil; return end
        local char = localplayer.Character
        if not char then return end
        for _, p in ipairs(char:GetChildren()) do
            if p:IsA("BasePart") and NOCLIP_PARTS[p.Name] then p.CanCollide = false end
        end
    end)
end

local noclipToggle = MiscMovSection:Toggle({
    Name = "noclip", Flag = "noclip", Default = false,
    Callback = function(v)
        movSettings.noclip = v
        if v then startNoclip()
        else
            local char = localplayer.Character
            if char then
                for _, p in ipairs(char:GetChildren()) do
                    if p:IsA("BasePart") and NOCLIP_PARTS[p.Name] then p.CanCollide = true end
                end
            end
        end
    end
})
noclipToggle:Keybind({ Flag = "noclipBind", Default = "None", Mode = "Toggle", Callback = function(v) noclipToggle:Set(v) end })

startBhop = function()
    if bhopConn then bhopConn:Disconnect() end
    bhopConn = runservice.Stepped:Connect(function()
        if not movSettings.bhop then bhopConn:Disconnect(); bhopConn = nil; return end
        local char = localplayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end
        if hum.FloorMaterial ~= Enum.Material.Air then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local bhopToggle = MiscMovSection:Toggle({
    Name = "bunny hop", Flag = "bhop", Default = false,
    Callback = function(v) movSettings.bhop = v; if v then startBhop() end end
})
bhopToggle:Keybind({ Flag = "bhopBind", Default = "None", Mode = "Toggle", Callback = function(v) bhopToggle:Set(v) end })

MiscMovSection:Slider({
    Name = "jump power", Flag = "jumpPower", Default = 7, Min = 0, Max = 300,
    Callback = function(v)
        local char = localplayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpHeight = v end
    end
})
MiscMovSection:Slider({
    Name = "walk speed", Flag = "walkSpeed", Default = 16, Min = 0, Max = 300,
    Callback = function(v)
        local char = localplayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
})

end -- movement

do -- misc

local KillAllSection    = MiscTab:Section({ Name = "knifebot",   Side = 1 })
local AutoQueueSection  = MiscTab:Section({ Name = "autoqueue",  Side = 1 })
local DeviceSpoofSection = MiscTab:Section({ Name = "device",    Side = 2 })
local PromoMiscSection  = MiscTab:Section({ Name = "promocodes", Side = 2 })

local killAllToggle = KillAllSection:Toggle({
    Name = "knifebot", Flag = "knifebotEnabled", Default = false,
    Callback = function(v)
        knifebotActive = v
        if v then
            task.spawn(function()
                while knifebotActive do
                    task.wait()
                    for _, target in ipairs(players:GetPlayers()) do
                        if target ~= localplayer
                        and target.Team ~= localplayer.Team
                        and target.Character
                        and target.Character:FindFirstChild("HumanoidRootPart") then
                            local lhrp = localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart")
                            if lhrp then
                                pcall(function() lhrp.CFrame = target.Character.HumanoidRootPart.CFrame end)
                                pcall(function()
                                    rs:WaitForChild("GameEvents"):WaitForChild("Damage"):FireServer(target, 200, "Bayonet", {
                                        ["Normal"]        = Vector3.new(0, 0, 0),
                                        ["Direction"]     = Vector3.zAxis,
                                        ["StartPosition"] = target.Character.HumanoidRootPart.Position,
                                        ["Instance"]      = target.Character.Head,
                                        ["Material"]      = Enum.Material.Plastic,
                                        ["EndPosition"]   = target.Character.HumanoidRootPart.Position,
                                    })
                                end)
                            end
                        end
                    end
                end
            end)
        end
    end,
})
killAllToggle:Keybind({ Flag = "knifebotBind", Default = "None", Mode = "Toggle", Callback = function(v) killAllToggle:Set(v) end })

local autoQueueToggle = AutoQueueSection:Toggle({
    Name = "enabled", Flag = "autoQueueEnabled", Default = false,
    Callback = function(v)
        if v then startAutoQueue() else stopAutoQueue() end
    end
})
autoQueueToggle:Keybind({ Flag = "autoQueueBind", Default = "None", Mode = "Toggle",
    Callback = function(v) autoQueueToggle:Set(v) end })
AutoQueueSection:Dropdown({
    Name = "gamemode", Flag = "autoQueueMode", Default = "Casual",
    Items = { "Casual", "Ranked" },
    Callback = function(v)
        autoQueueSettings.gamemode = v
    end
})

-- device spoofer
local currentDevice = "Computer"
local deviceMap = { ["mobile"]="Mobile", ["computer"]="Computer", ["console"]="Console" }

if DeviceEvent then
    DeviceSpoofSection:Dropdown({
        Name = "device spoofer", Flag = "deviceMode", Default = "computer",
        Items = { "mobile", "computer", "console" },
        Callback = function(v)
            currentDevice = deviceMap[v]
            pcall(function() DeviceEvent:FireServer(currentDevice) end)
        end
    })
    localplayer.CharacterAdded:Connect(function()
        task.wait(0.3)
        pcall(function() DeviceEvent:FireServer(currentDevice) end)
    end)
else
    DeviceSpoofSection:Label("not supported in this game")
end

-- promocodes
local promocodes = {
    "JAILBIRDELITE", "FIRSTPERSONPOSTUPDATE1", "FIRSTPERSON", "NEWGUNSOUNDS",
    "JAILBIRDIANS", "SMILEYOVERHAUL", "80KLIKESJAILBIRD", "MADDERS", "MIRAGON",
    "SERVERFIX", "S5RELEASE", "OPTIMISATION", "DEV_CONSOLE", "JAILBIRDSTARTER",
    "REMASTERED", "JAILBIRD", "MADDERSYT", "CHIVVEDYT",
}
PromoMiscSection:Button():Add("claim all codes", function()
    local Event = game:GetService("ReplicatedStorage").Events.ClaimPromocode
    local claimed = 0
    for _, code in ipairs(promocodes) do
        local ok, err = pcall(function() Event:FireServer(code) end)
        if ok then claimed = claimed + 1 end
        task.wait(0.2)
    end
    Library:Notification("promocodes", "claimed " .. claimed .. "/" .. #promocodes .. " codes", 5)
end)

end -- misc

do -- aimbot
local get_center = WYNF_NO_VIRTUALIZE(function()
    local vp = workspace.CurrentCamera.ViewportSize
    return Vector2.new(vp.X / 2, vp.Y / 2)
end)

local get_best_target = WYNF_SECURE_CALL(function(cam)
    local center      = get_center()
    local best_dist   = math.huge
    local best_part   = nil
    local best_player = nil

    for _, player in pairs(players:GetPlayers()) do
        if player == localplayer then continue end
        if settings.aimteamcheck and player.TeamColor == localplayer.TeamColor then continue end
        local char = player.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local _, hrp_vis = cam:WorldToViewportPoint(hrp.Position)
        if not hrp_vis then continue end
        local part
        for _, child in pairs(char:GetChildren()) do
            if child.Name:lower() == settings.aimpart:lower() then part = child; break end
        end
        part = part or hrp
        local s, on = cam:WorldToViewportPoint(part.Position)
        if not on then continue end
        local screenDist = (Vector2.new(s.X, s.Y) - center).Magnitude
        if screenDist > settings.aimfov then continue end
        if settings.wallcheck and not isVisible(part) then continue end
        if settings.priority == "lowest health" then
            local score = hum.Health
            if not best_player or score < best_dist then best_dist = score; best_part = part; best_player = player end
        elseif settings.priority == "closest distance" then
            local score = (cam.CFrame.Position - hrp.Position).Magnitude
            if score < best_dist then best_dist = score; best_part = part; best_player = player end
        else
            if screenDist < best_dist then best_dist = screenDist; best_part = part; best_player = player end
        end
    end
    return best_part, best_player
end)

local should_aim = WYNF_NO_VIRTUALIZE(function()
    if not settings.aimenable then return false end
    if settings.aimmode == "always" then return true end
    if settings.aimmode == "hold"   then return is_key_down() end
    if settings.aimmode == "toggle" then return aim_toggled end
    return false
end)

local move_camera_to = WYNF_SECURE_CALL(function(cam, part)
    local s      = cam:WorldToViewportPoint(part.Position)
    local center = get_center()
    local delta  = Vector2.new(s.X, s.Y) - center
    local vp     = cam.ViewportSize
    local ppr    = vp.Y / (2 * math.tan(math.rad(cam.FieldOfView) / 2))
    local factor = 1 - settings.aimsmoothing
    local yaw    = (-delta.X / ppr) * factor
    local pitch  = (-delta.Y / ppr) * factor
    local cf     = cam.CFrame
    local rot    = cf * CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0)
    cam.CFrame   = CFrame.new(cf.Position) * (rot - rot.Position)
end)

table.insert(characterAddedConnections,
    userinput.InputBegan:Connect(function(input, gpe)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local cam = workspace.CurrentCamera
            local _, targetPlayer = get_best_target(cam)
            if targetPlayer then recentTargets[targetPlayer] = tick() + FIRE_LINGER_SECONDS end
        end
    end)
)

userinput.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if settings.aimenable and settings.aimmode == "toggle" then
        if input_matches_aimkey(input) then aim_toggled = not aim_toggled end
    end
end)

esp_conn = runservice.RenderStepped:Connect(function()
    if unloading then return end
    local cam    = workspace.CurrentCamera
    local center = get_center()
    local showFov = settings.showfov and settings.aimenable
    local showSA  = fovCircleSettings.saEnabled and silentSettings.enabled
    _fovAngle   = (_fovAngle   + fovCircleSettings.speed   * 0.02) % (math.pi * 2)
    _saFovAngle = (_saFovAngle + fovCircleSettings.saSpeed * 0.02) % (math.pi * 2)

    if fovCircleSettings.dotted then
        fov_solid.Visible = false
        for i = 1, FOV_DOTS do
            local skip = (i % 2 == 0)
            local ang  = fovCircleSettings.animated
                and (i/FOV_DOTS*math.pi*2 + _fovAngle)
                or  (i/FOV_DOTS*math.pi*2)
            fov_dots[i].Position = Vector2.new(center.X+math.cos(ang)*settings.aimfov, center.Y+math.sin(ang)*settings.aimfov)
            fov_dots[i].Color    = settings.fovcolor
            fov_dots[i].Visible  = showFov and skip
        end
    else
        for i=1,FOV_DOTS do fov_dots[i].Visible=false end
        fov_solid.Position=center; fov_solid.Radius=settings.aimfov
        fov_solid.Color=settings.fovcolor; fov_solid.Visible=showFov
    end

    if fovCircleSettings.saDotted then
        sa_fov_solid.Visible = false
        for i = 1, FOV_DOTS do
            local skip = (i % 2 == 0)
            local ang  = fovCircleSettings.saAnimated
                and (i/FOV_DOTS*math.pi*2 + _saFovAngle)
                or  (i/FOV_DOTS*math.pi*2)
            sa_fov_dots[i].Position = Vector2.new(center.X+math.cos(ang)*silentSettings.fov, center.Y+math.sin(ang)*silentSettings.fov)
            sa_fov_dots[i].Color    = fovCircleSettings.saColor
            sa_fov_dots[i].Visible  = showSA and skip
        end
    else
        for i=1,FOV_DOTS do sa_fov_dots[i].Visible=false end
        sa_fov_solid.Position=center; sa_fov_solid.Radius=silentSettings.fov
        sa_fov_solid.Color=fovCircleSettings.saColor; sa_fov_solid.Visible=showSA
    end

    if should_aim() then
        local target = get_best_target(cam)
        if target then move_camera_to(cam, target) end
    end
end)

end -- aimbot

do -- hitmarker+rest

FlashHitmarker = function(hitPlayer, isKill, damage)
    local char = hitPlayer and hitPlayer.Character
    if not char then return end

    if hitmarkerSettings.enabled then
        task.spawn(function()
            local col = isKill and hitmarkerSettings.killColor or hitmarkerSettings.color
            local hl  = Instance.new("Highlight")
            hl.FillColor           = col
            hl.OutlineColor        = col
            hl.FillTransparency    = 0.2
            hl.OutlineTransparency = 0
            hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Adornee             = char
            hl.Parent              = workspace
            local dur   = hitmarkerSettings.duration
            local start = tick()
            local conn
            conn = runservice.RenderStepped:Connect(function()
                local t = math.clamp((tick() - start) / dur, 0, 1)
                hl.FillTransparency    = 0.2 + 0.8 * t
                hl.OutlineTransparency = t
                if t >= 1 then hl:Destroy(); conn:Disconnect() end
            end)
        end)
    end

    if hitIndicatorSettings.enabled then
        task.spawn(function()
            local head = char:FindFirstChild("Head")
            if not head then return end
            local dmgText = damage and tostring(damage) or (isKill and "kill" or "hit")
            local col = isKill and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 50, 50)
            local bb = Instance.new("BillboardGui")
            bb.AlwaysOnTop = true
            bb.Size        = UDim2.new(0, 60, 0, 30)
            bb.StudsOffset = Vector3.new(math.random(-1, 1), 3, 0)
            bb.Parent      = head
            local lbl = Instance.new("TextLabel", bb)
            lbl.Size                   = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text                   = dmgText
            lbl.TextColor3             = col
            lbl.TextStrokeColor3       = Color3.new(0, 0, 0)
            lbl.TextStrokeTransparency = 0
            lbl.Font                   = Enum.Font.GothamBold
            lbl.TextSize               = 18
            local rise = 0
            local conn
            conn = runservice.RenderStepped:Connect(function(dt)
                rise = rise + dt * 2.5
                bb.StudsOffset = Vector3.new(bb.StudsOffset.X, 3 + rise, 0)
                local t = math.clamp(rise / 1.5, 0, 1)
                lbl.TextTransparency       = t
                lbl.TextStrokeTransparency = t
                if t >= 1 then bb:Destroy(); conn:Disconnect() end
            end)
        end)
    end
end

-- viewmodel offset

local vmCurrentCF = CFrame.new(0, 0, 0)

runservice:BindToRenderStep("VMOffset", Enum.RenderPriority.Camera.Value + 1, function(dt)
    if not viewmodelSettings.enabled then return end
    local cm = workspace.CurrentCamera:FindFirstChild("CameraModel")
    if not cm then return end
    local anim = cm:FindFirstChild("Anim")
    if not anim then return end
    local baseMotor = anim:FindFirstChild("Base")
    if not baseMotor or not baseMotor:IsA("Motor6D") then return end
    local targetCF = CFrame.new(viewmodelSettings.x, viewmodelSettings.y, viewmodelSettings.z)
    vmCurrentCF = vmCurrentCF:Lerp(targetCF, math.min(dt * 15, 1))
    baseMotor.C0 = baseMotor.C0 * vmCurrentCF
end)

-- silent aim

local SA_Camera = workspace.CurrentCamera
local VIM       = game:GetService("VirtualInputManager")

local function SA_GetClosestPlayer()
    local Closest, ClosestDist = nil, silentSettings.fov
    for _, Player in next, players:GetPlayers() do
        if Player == localplayer then continue end
        if silentSettings.teamcheck and Player.Team == localplayer.Team then continue end
        local char = Player.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local sp, onScreen = SA_Camera:WorldToScreenPoint(hrp.Position)
        if not onScreen then continue end
        local dist = (userinput:GetMouseLocation() - Vector2.new(sp.X, sp.Y)).Magnitude
        if dist < ClosestDist then
            if silentSettings.vischeck and not isVisible(hrp) then continue end
            ClosestDist = dist
            local targetChild = char:FindFirstChild(silentSettings.targetpart)
            if not targetChild then
                for _, c in ipairs(char:GetChildren()) do
                    if c.Name:lower() == silentSettings.targetpart then targetChild = c; break end
                end
            end
            Closest = targetChild or hrp
        end
    end
    return Closest
end

local SA_CachedTarget = nil
local SA_CachedHRPPos = nil
local SA_LastHB       = 0
local SA_LastShot     = 0
local SA_VisParams    = RaycastParams.new()
SA_VisParams.FilterType = Enum.RaycastFilterType.Exclude

local function SA_IsVisible(hrp, target)
    local char = localplayer.Character
    SA_VisParams.FilterDescendantsInstances = { char }
    local dir = target.Position - hrp.Position
    if dir.Magnitude == 0 then return false end
    local result = workspace:Raycast(hrp.Position, dir.Unit * dir.Magnitude, SA_VisParams)
    return not result or (result.Instance and result.Instance:IsDescendantOf(target.Parent))
end

runservice.Heartbeat:Connect(function()
    local now = tick()
    if now - SA_LastHB < 0.016 then return end
    SA_LastHB = now
    local char = localplayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    SA_CachedHRPPos = hrp and hrp.Position or nil
    if silentSettings.enabled or autoShootSettings.enabled then
        SA_CachedTarget = SA_GetClosestPlayer()
    else
        SA_CachedTarget = nil
    end
    if autoShootSettings.enabled and SA_CachedTarget and hrp then
        local canShoot = true
        if autoShootSettings.vischeck then canShoot = SA_IsVisible(hrp, SA_CachedTarget) end
        if canShoot and (now - SA_LastShot) >= autoShootSettings.delay then
            SA_LastShot = now
            pcall(function() VIM:SendMouseButtonEvent(0, 0, 0, true,  game, 1) end)
            task.delay(0.05, function()
                pcall(function() VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1) end)
            end)
        end
    end
end)

-- weapon mod
local WM_BaseRates = setmetatable({}, { __mode = "k" })
local WM_Clients   = setmetatable({}, { __mode = "k" })

local WM_FOUND_COUNT  = 0
local WM_MAX_CLIENTS  = 4
local WM_lastScanTick = 0
local WM_SCAN_COOLDOWN = 0.5

local function WM_Search()
    local now = tick()
    if now - WM_lastScanTick < WM_SCAN_COOLDOWN then return end
    WM_lastScanTick = now

    WM_FOUND_COUNT = 0
    for _, v in getgc(true) do
        if type(v) == "table" then
            local fr = rawget(v, "FireRate")
            local vr = rawget(v, "VRecoil")
            if fr ~= nil and vr ~= nil then
                WM_Clients[v] = true
                WM_FOUND_COUNT += 1
                if WM_FOUND_COUNT >= WM_MAX_CLIENTS then
                    break
                end
            end
        end
    end
end

local function WM_InitialScan()
    for _ = 1, 20 do
        WM_Search()
        if next(WM_Clients) then return end
        task.wait(1)
    end
end
task.spawn(WM_InitialScan)

localplayer.CharacterAdded:Connect(function()
    task.wait(1)
    table.clear(WM_BaseRates)
    WM_Search()
end)

runservice.Heartbeat:Connect(function()
    if not next(WM_Clients) then return end
    for v in pairs(WM_Clients) do
        if weaponSettings.noRecoil then
            pcall(function()
                v.VRecoil = 0; v.HRecoil = 0; v.RecoilPower = 0; v.RecoilPunch = 0
                v.VPunchBase = 0; v.HPunchBase = 0; v.DPunchBase = 0; v.RecoilPowerStepAmount = 0
            end)
        end
        if weaponSettings.noSpread then
            pcall(function()
                v.MaxSpread = 0; v.MinSpread = 0; v.AimInaccuracyStepAmount = 0; v.MaxSway = 0
            end)
        end
        if weaponSettings.fireRate then
            pcall(function()
                local rate = tonumber(v.FireRate)
                if not rate then return end
                if not WM_BaseRates[v] then WM_BaseRates[v] = rate end
                v.FireRate = WM_BaseRates[v] * math.max(weaponSettings.fireRateMult, 1)
                v.FireMode = "Auto"
            end)
        else
            if WM_BaseRates[v] then
                pcall(function() v.FireRate = WM_BaseRates[v] end)
                WM_BaseRates[v] = nil
            end
        end
    end
end)

-- silentaim hook

local SA_OldNamecall
SA_OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local method = getnamecallmethod()
    local args   = {...}
    if not checkcaller() and method == "Raycast"
    and typeof(args[2]) == "Vector3"
    and typeof(args[3]) == "Vector3"
    and SA_CachedHRPPos
    and (args[2] - SA_CachedHRPPos).Magnitude < 50
    and silentSettings.enabled
    and SA_CachedTarget then
        args[3] = (SA_CachedTarget.Position - args[2]).Unit * 1000
        return SA_OldNamecall(unpack(args))
    end
    return SA_OldNamecall(...)
end))

end -- hitmarker + rest

-- init

SetupHitDetection()

for _, player in ipairs(players:GetPlayers()) do detectPlayer(player) end
players.PlayerAdded:Connect(detectPlayer)

if not isMobile then
    Library.MenuKeybind = tostring(Enum.KeyCode.RightShift)
end

do
    local _autoName = getAutoloadName()
    if _autoName and _autoName ~= "" then
        task.defer(function()
            task.wait(0.5)
            if loadConfig(_autoName) then
                Library:Notification("autoload", "loaded " .. _autoName, 4)
            end
        end)
    end
end

Library:Notification(
    "index.lol",
    "loaded in " .. string.format("%.4f", os.clock() - LoadingTick) .. "s",
    5
)
