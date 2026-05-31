local LoadingTick = os.clock()

local players          = game:GetService("Players")
local rs               = game:GetService("ReplicatedStorage")
local TextChatService  = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

local localplayer = players.LocalPlayer

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled


local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/rempsu/IndexMain/main/ui.lua"))()

Library:ChangeTheme("Window Background", Color3.fromRGB(18, 18, 18))
Library:ChangeTheme("Section Background", Color3.fromRGB(12, 12, 12))
Library:ChangeTheme("Element",            Color3.fromRGB(28, 28, 28))
Library:ChangeTheme("Dark Liner",         Color3.fromRGB(22, 22, 22))
Library:ChangeTheme("Text",               Color3.fromRGB(200, 200, 200))
Library:ChangeTheme("Accent",             Color3.fromRGB(220, 50, 100))
Library:ChangeTheme("Risky",              Color3.fromRGB(255, 50, 50))

local Window = Library:Window({
    Name = "index.lol beta",
    GradientTitle = {
        Enabled = true,
        Start   = Color3.fromRGB(255, 255, 255),
        Middle  = Color3.fromRGB(220, 50, 100),
        End     = Color3.fromRGB(160, 30, 80),
        Speed   = 1
    }
})

local MainTab     = Window:Page({ Name = "main",     Columns = 2 })
local SettingsTab = Window:Page({ Name = "settings", Columns = 2 })

do
    local f = Window.Items["Outline"].Instance
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.Position    = UDim2.fromScale(0.5, 0.5)
end

if isMobile then
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name            = "IndexMobileToggle"
    screenGui.ResetOnSpawn    = false
    screenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder    = 999
    screenGui.Parent          = localplayer.PlayerGui

    local btn = Instance.new("TextButton")
    btn.Size            = UDim2.fromOffset(56, 56)
    btn.Position        = UDim2.new(1, -70, 0.5, -28)
    btn.AnchorPoint     = Vector2.new(0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(220, 50, 100)
    btn.BorderSizePixel = 0
    btn.Text            = "☰"
    btn.TextColor3      = Color3.fromRGB(255, 255, 255)
    btn.TextSize        = 24
    btn.Font            = Enum.Font.GothamBold
    btn.ZIndex          = 10
    btn.Parent          = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent       = btn

    local shadow = Instance.new("ImageLabel")
    shadow.Size              = UDim2.fromOffset(66, 66)
    shadow.Position          = UDim2.fromOffset(-5, -5)
    shadow.BackgroundTransparency = 1
    shadow.Image             = "rbxassetid://5028857472"
    shadow.ImageColor3       = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType         = Enum.ScaleType.Slice
    shadow.SliceCenter       = Rect.new(24, 24, 276, 276)
    shadow.ZIndex            = 9
    shadow.Parent            = btn

    local dragging   = false
    local dragStart  = nil
    local startPos   = nil
    local TAP_THRESH = 10

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = btn.Position
        end
    end)

    btn.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            btn.Position = UDim2.fromOffset(
                startPos.X.Offset + delta.X,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            local dist  = math.abs(delta.X) + math.abs(delta.Y)
            dragging = false
            if dist < TAP_THRESH then
                local outline = Window.Items["Outline"].Instance
                outline.Visible = not outline.Visible
            end
        end
    end)
end

local selectedGunSkin   = "none"
local selectedKnifeSkin = "none"

local weaponSettings = {
    noRecoil = false,
    noSpread = false,
}

local WM_Clients   = {}
local WM_BaseRates = {}

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

local espDropdowns     = {}
local spooferTextboxes = {}

local function syncDropdownUI(flag, val)
    local d = espDropdowns[flag]
    if not d then return end
    pcall(function() d:Set(val) end)
end

local function syncSpooferTextboxUI(flag, val)
    local entry = spooferTextboxes[flag]
    if not entry or not entry.element then return end
    pcall(function() entry.element:Set(tostring(val or "")) end)
end

if _G.INDEX_gunSkinConn   then _G.INDEX_gunSkinConn:Disconnect();   _G.INDEX_gunSkinConn   = nil end
if _G.INDEX_knifeSkinConn then _G.INDEX_knifeSkinConn:Disconnect(); _G.INDEX_knifeSkinConn = nil end
if _G.INDEX_camModelConn  then _G.INDEX_camModelConn:Disconnect();  _G.INDEX_camModelConn  = nil end

local GunSkinSection   = MainTab:Section({ Name = "gun skin",   Side = 1 })
local KnifeSkinSection = MainTab:Section({ Name = "knife skin", Side = 1 })

local gunSkinNamesReal = { "None" }
for _, v in ipairs(rs.Items.Skin:GetChildren()) do table.insert(gunSkinNamesReal, v.Name) end
table.sort(gunSkinNamesReal, function(a, b)
    if a == "None" then return true end
    if b == "None" then return false end
    return a < b
end)

local knifeSkinNamesReal = { "None" }
for _, v in ipairs(rs.Items.Knife:GetChildren()) do table.insert(knifeSkinNamesReal, v.Name) end
table.sort(knifeSkinNamesReal, function(a, b)
    if a == "None" then return true end
    if b == "None" then return false end
    return a < b
end)

local GunSkinDisplayToReal   = {}
local gunSkinNamesDisplay    = {}
for _, name in ipairs(gunSkinNamesReal) do
    local disp = name:lower()
    GunSkinDisplayToReal[disp] = name
    table.insert(gunSkinNamesDisplay, disp)
end

local KnifeSkinDisplayToReal = {}
local knifeSkinNamesDisplay  = {}
for _, name in ipairs(knifeSkinNamesReal) do
    local disp = name:lower()
    KnifeSkinDisplayToReal[disp] = name
    table.insert(knifeSkinNamesDisplay, disp)
end

local function getCameraModel()
    return workspace.CurrentCamera:FindFirstChild("CameraModel")
end

local function getCurrentGun()
    local cm = getCameraModel()
    if not cm then return nil end
    for _, v in ipairs(cm:GetChildren()) do
        if rs.Weapons:FindFirstChild(v.Name) then return v end
    end
end

local function getCurrentKnife()
    local cm = getCameraModel()
    if not cm then return nil end
    for _, v in ipairs(cm:GetChildren()) do
        if rs.Items.Knife:FindFirstChild(v.Name) then return v end
    end
end

local function applyGunSkin(skinName)
    if skinName == "None" or not skinName then return end
    local gun = getCurrentGun()
    if not gun then return end
    local skinTex = rs.Items.Skin:FindFirstChild(skinName)
    if not skinTex then return end
    for _, part in ipairs(gun:GetDescendants()) do
        if part:IsA("MeshPart") then
            pcall(function() part.TextureID = skinTex.Texture end)
        end
    end
end

local ANIM_BOWIE    = { Hold="rbxassetid://17156326547",  Action="rbxassetid://17156290783",  Equip="rbxassetid://17157619507",  Inspect="rbxassetid://17223102735"  }
local ANIM_KARAMBIT = { Hold="rbxassetid://17787592077",  Action="rbxassetid://17788245247",  Equip="rbxassetid://17787596397",  Inspect="rbxassetid://17787586405"  }
local ANIM_HATCHET  = { Hold="rbxassetid://111928394361277", Action="rbxassetid://116109040176624", Equip="rbxassetid://122865148996513", Inspect="rbxassetid://130711019196442" }

local knifeAnimSets = {
    ["Deceit"]="karambit",["Karambit"]="karambit",["Geometric"]="karambit",
    ["MDRS"]="karambit",["Manifesto"]="karambit",["Qrimson Karambit"]="karambit",
    ["Black Frost"]="karambit",["Hatchet"]="hatchet",
}
local animSetMap = { karambit = ANIM_KARAMBIT, hatchet = ANIM_HATCHET }

local function applyKnifeAnims(knife, skinName)
    local setKey = knifeAnimSets[skinName]
    local animSet = (setKey and animSetMap[setKey]) or ANIM_BOWIE
    for _, anim in ipairs(knife:GetDescendants()) do
        if anim:IsA("Animation") then
            local newId = animSet[anim.Name]
            if newId then pcall(function() anim.AnimationId = newId end) end
        end
    end
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

local function applyKnifeSkin(skinName)
    if skinName == "None" or not skinName then return end
    local knife     = getCurrentKnife()
    local skinModel = rs.Items.Knife:FindFirstChild(skinName)
    if not knife or not skinModel then return end
    for _, v in ipairs(knife:GetDescendants()) do
        if v:IsA("BasePart") then v.Transparency = 1 end
    end
    local old = knife:FindFirstChild("CustomSkin")
    if old then old:Destroy() end
    local clone = skinModel:Clone()
    clone.Name = "CustomSkin"; clone.Parent = knife
    local attachTo = knife:FindFirstChild("Handle", true) or knife:FindFirstChildWhichIsA("BasePart")
    if attachTo then weldModel(clone, attachTo, CFrame.new()) end
    applyKnifeAnims(knife, skinName)
end

local function hookCameraModel(cm)
    if _G.INDEX_gunSkinConn   then _G.INDEX_gunSkinConn:Disconnect()   end
    if _G.INDEX_knifeSkinConn then _G.INDEX_knifeSkinConn:Disconnect() end
    _G.INDEX_gunSkinConn = cm.ChildAdded:Connect(function(child)
        task.wait(0.1)
        if rs.Weapons:FindFirstChild(child.Name) then
            applyGunSkin(GunSkinDisplayToReal[selectedGunSkin] or selectedGunSkin)
        elseif rs.Items.Knife:FindFirstChild(child.Name) then
            applyKnifeSkin(KnifeSkinDisplayToReal[selectedKnifeSkin] or selectedKnifeSkin)
        end
    end)
end

local cm = getCameraModel()
if cm then hookCameraModel(cm) end

_G.INDEX_camModelConn = workspace.CurrentCamera.ChildAdded:Connect(function(child)
    if child.Name == "CameraModel" then
        task.wait(0.2)
        hookCameraModel(child)
        applyGunSkin(GunSkinDisplayToReal[selectedGunSkin] or selectedGunSkin)
        applyKnifeSkin(KnifeSkinDisplayToReal[selectedKnifeSkin] or selectedKnifeSkin)
    end
end)

local gunSkinDropdown = GunSkinSection:Dropdown({
    Name = "select skin", Flag = "gunSkinSelect", Default = "none", Items = gunSkinNamesDisplay,
    Callback = function(v)
        selectedGunSkin = v
        applyGunSkin(GunSkinDisplayToReal[v] or v)
    end
})
espDropdowns["gunSkinSelect"] = gunSkinDropdown

local knifeSkinDropdown = KnifeSkinSection:Dropdown({
    Name = "select skin", Flag = "knifeSkinSelect", Default = "none", Items = knifeSkinNamesDisplay,
    Callback = function(v)
        selectedKnifeSkin = v
        applyKnifeSkin(KnifeSkinDisplayToReal[v] or v)
    end
})
espDropdowns["knifeSkinSelect"] = knifeSkinDropdown

local WeaponModSection = MainTab:Section({ Name = "weapon mods", Side = 1 })

WeaponModSection:Toggle({
    Name = "no recoil", Flag = "noRecoil", Default = false,
    Callback = function(v) weaponSettings.noRecoil = v end
})
WeaponModSection:Toggle({
    Name = "no spread", Flag = "noSpread", Default = false,
    Callback = function(v) weaponSettings.noSpread = v end
})

local function getStats()
    local pd = localplayer:FindFirstChild("PlayerData")
    return pd and pd:FindFirstChild("Stats")
end

local function getOriginalValues()
    local _s = getStats()
    return {
        stats = {
            Credit       = _s and _s:GetAttribute("Credit"),
            Level        = _s and _s:GetAttribute("Level"),
            Kills        = _s and _s:GetAttribute("Kills"),
            Deaths       = _s and _s:GetAttribute("Deaths"),
            Damage       = _s and _s:GetAttribute("Damage"),
            RankedRating = _s and _s:GetAttribute("RankedRating"),
            RankedKills  = _s and _s:GetAttribute("RankedKills"),
            RankedDeaths = _s and _s:GetAttribute("RankedDeaths"),
        },
        username    = localplayer.Name,
        displayName = localplayer.DisplayName,
    }
end
local _originalValues = getOriginalValues()

local function makeSpooferTextbox(section, label, flag, defaultVal, callback)
    local tb = section:Textbox({
        Name        = label,
        Flag        = flag,
        Default     = tostring(defaultVal ~= nil and defaultVal or ""),
        Placeholder = "value...",
        Callback    = function(v)
            spooferValues[flag] = tostring(v)
            if type(callback) == "function" then callback(v) end
        end,
    })
    spooferTextboxes[flag] = { element = tb }
    return tb
end

local StatsSection  = MainTab:Section({ Name = "stats spoofer", Side = 2 })
local PlayerSection = MainTab:Section({ Name = "user spoofer",  Side = 1 })

local function makeStatTextbox(section, label, flag, attrName)
    local _s = getStats()
    makeSpooferTextbox(section, label, flag, tostring(_s and _s:GetAttribute(attrName) or ""), function(v)
        local stats = getStats()
        if not stats then return end
        local num = tonumber(v)
        if num then pcall(function() stats:SetAttribute(attrName, num) end) end
    end)
end

makeStatTextbox(StatsSection, "credit",        "statCredit",       "Credit")
makeStatTextbox(StatsSection, "level",         "statLevel",        "Level")
makeStatTextbox(StatsSection, "kills",         "statKills",        "Kills")
makeStatTextbox(StatsSection, "deaths",        "statDeaths",       "Deaths")
makeStatTextbox(StatsSection, "damage",        "statDamage",       "Damage")
makeStatTextbox(StatsSection, "ranked rating", "statRankedRating", "RankedRating")
makeStatTextbox(StatsSection, "ranked kills",  "statRankedKills",  "RankedKills")
makeStatTextbox(StatsSection, "ranked deaths", "statRankedDeaths", "RankedDeaths")

local function updateChatHook()
    TextChatService.OnIncomingMessage = function(msg)
        local props = Instance.new("TextChatMessageProperties")
        if msg.TextSource and msg.TextSource.UserId == localplayer.UserId then
            local name = spooferValues.playerDisplay ~= "" and spooferValues.playerDisplay or localplayer.DisplayName
            props.PrefixText = name .. ": "
        end
        return props
    end
end

makeSpooferTextbox(PlayerSection, "username",     "playerUsername", localplayer.Name, function(v)
    if v ~= "" then pcall(function() localplayer.Name = v end) end
end)
makeSpooferTextbox(PlayerSection, "display name", "playerDisplay",  localplayer.DisplayName, function(v)
    if v ~= "" then pcall(function() localplayer.DisplayName = v end) end
    updateChatHook()
end)


local MenuSection   = SettingsTab:Section({ Name = "menu",    Side = 1 })
local ConfigSection = SettingsTab:Section({ Name = "configs", Side = 2 })

if not isMobile then
    MenuSection:Toggle({
        Name = "menu keybind", Flag = "MenuKeybindToggle", Default = false,
    }):Keybind({
        Name = "menu keybind", Flag = "MenuKeybind", Default = Enum.KeyCode.RightShift, Mode = "Toggle",
        Callback = function()
            local flagData = Library.Flags["MenuKeybind"]
            if flagData and flagData.Key then Library.MenuKeybind = flagData.Key end
        end
    })
end

local WatermarkSection = SettingsTab:Section({ Name = "watermark", Side = 1 })

local showName          = true
local showUser          = true
local showFps           = true
local showUptime        = true
local userWatermarkMode = "username"

WatermarkSection:Toggle({
    Name = "show name", Flag = "wmShowName", Default = true,
    Callback = function(v) showName = v end
})
WatermarkSection:Toggle({
    Name = "show user", Flag = "wmShowUser", Default = true,
    Callback = function(v) showUser = v end
})
WatermarkSection:Dropdown({
    Name = "user mode", Flag = "wmUserMode", Default = "username",
    Items = { "username", "display name" },
    Callback = function(v) userWatermarkMode = v end
})
espDropdowns["wmUserMode"] = WatermarkSection
WatermarkSection:Toggle({
    Name = "show fps", Flag = "wmShowFps", Default = true,
    Callback = function(v) showFps = v end
})
WatermarkSection:Toggle({
    Name = "show uptime", Flag = "wmShowUptime", Default = true,
    Callback = function(v) showUptime = v end
})

MenuSection:Button({
    Name = "unload", Risky = true,
    Callback = function()
        local _s = getStats()
        if _s then
            for attr, val in pairs(_originalValues.stats) do
                if val ~= nil then pcall(function() _s:SetAttribute(attr, val) end) end
            end
        end
        pcall(function() localplayer.Name        = _originalValues.username    end)
        pcall(function() localplayer.DisplayName = _originalValues.displayName end)

        if _G.INDEX_gunSkinConn   then _G.INDEX_gunSkinConn:Disconnect()   end
        if _G.INDEX_knifeSkinConn then _G.INDEX_knifeSkinConn:Disconnect() end
        if _G.INDEX_camModelConn  then _G.INDEX_camModelConn:Disconnect()  end
        if fpsConn then fpsConn:Disconnect() end

        local mobileGui = localplayer.PlayerGui:FindFirstChild("IndexMobileToggle")
        if mobileGui then mobileGui:Destroy() end

        TextChatService.OnIncomingMessage = nil
        Library:Unload()
    end
})

local CONFIG_FOLDER = "index_beta"
local CONFIG_EXT    = ".json"
if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end

local function getConfigPath(name) return CONFIG_FOLDER .. "/" .. name .. CONFIG_EXT end

local function buildConfig()
    return {
        selectedGunSkin         = selectedGunSkin,
        selectedKnifeSkin       = selectedKnifeSkin,
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
        wmShowName              = showName,
        wmShowUser              = showUser,
        wmShowFps               = showFps,
        wmShowUptime            = showUptime,
        wmUserMode              = userWatermarkMode,
    }
end

local function applyConfig(cfg)
    if cfg.selectedGunSkin then
        selectedGunSkin = cfg.selectedGunSkin
        syncDropdownUI("gunSkinSelect", selectedGunSkin)
        applyGunSkin(GunSkinDisplayToReal[selectedGunSkin] or selectedGunSkin)
    end
    if cfg.selectedKnifeSkin then
        selectedKnifeSkin = cfg.selectedKnifeSkin
        syncDropdownUI("knifeSkinSelect", selectedKnifeSkin)
        applyKnifeSkin(KnifeSkinDisplayToReal[selectedKnifeSkin] or selectedKnifeSkin)
    end

    local spooferMap = {
        spooferStatCredit       = "statCredit",
        spooferStatLevel        = "statLevel",
        spooferStatKills        = "statKills",
        spooferStatDeaths       = "statDeaths",
        spooferStatDamage       = "statDamage",
        spooferStatRankedRating = "statRankedRating",
        spooferStatRankedKills  = "statRankedKills",
        spooferStatRankedDeaths = "statRankedDeaths",
        spooferPlayerUsername   = "playerUsername",
        spooferPlayerDisplay    = "playerDisplay",
    }
    for cfgKey, spooferKey in pairs(spooferMap) do
        if cfg[cfgKey] ~= nil then
            spooferValues[spooferKey] = tostring(cfg[cfgKey])
            syncSpooferTextboxUI(spooferKey, spooferValues[spooferKey])
        end
    end

    if cfg.wmShowName    ~= nil then showName         = cfg.wmShowName   end
    if cfg.wmShowUser    ~= nil then showUser         = cfg.wmShowUser   end
    if cfg.wmShowFps     ~= nil then showFps          = cfg.wmShowFps    end
    if cfg.wmShowUptime  ~= nil then showUptime       = cfg.wmShowUptime end
    if cfg.wmUserMode    ~= nil then
        userWatermarkMode = cfg.wmUserMode
        syncDropdownUI("wmUserMode", userWatermarkMode)
    end
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

local configNameInput = ""
local selectedConfig  = ""

local cfgDropdown = ConfigSection:Dropdown({
    Name = "select", Flag = "configSelect", Default = nil,
    Items = listConfigs(), MaxSize = 100,
    Callback = function(v) selectedConfig = v end
})
espDropdowns["configSelect"] = cfgDropdown

local function refreshCfgDropdown()
    cfgDropdown:Refresh(listConfigs())
    selectedConfig = ""
end

ConfigSection:Textbox({
    Name = "config name", Flag = "configNameInput", Default = "", Placeholder = "name...",
    Callback = function(v) configNameInput = v end
})

ConfigSection:Button({
    Name = "save",
    Callback = function()
        local name = (configNameInput ~= "" and configNameInput or "default"):gsub("[/\\%.%s]", "_")
        writefile(getConfigPath(name), game:GetService("HttpService"):JSONEncode(buildConfig()))
        refreshCfgDropdown()
        Library:Notification("saved: " .. name, 3, Color3.fromRGB(220, 50, 100))
    end
})

ConfigSection:Button({
    Name = "load",
    Callback = function()
        if selectedConfig == "" then Library:Notification("select a config", 3, Color3.fromRGB(255, 80, 80)); return end
        local path = getConfigPath(selectedConfig)
        if not isfile(path) then Library:Notification("not found", 3, Color3.fromRGB(255, 80, 80)); return end
        local ok, result = pcall(function() return game:GetService("HttpService"):JSONDecode(readfile(path)) end)
        if ok and result then
            applyConfig(result)
            Library:Notification("loaded: " .. selectedConfig, 3, Color3.fromRGB(220, 50, 100))
        else
            Library:Notification("failed to load", 3, Color3.fromRGB(255, 80, 80))
        end
    end
})

ConfigSection:Button({
    Name = "delete", Risky = true,
    Callback = function()
        if selectedConfig == "" then Library:Notification("select a config", 3, Color3.fromRGB(255, 80, 80)); return end
        local path = getConfigPath(selectedConfig)
        if isfile(path) then
            delfile(path)
            local name = selectedConfig
            refreshCfgDropdown()
            Library:Notification("deleted: " .. name, 3, Color3.fromRGB(255, 80, 80))
        else
            Library:Notification("not found", 3, Color3.fromRGB(255, 80, 80))
        end
    end
})

ConfigSection:Button({
    Name = "refresh",
    Callback = function()
        refreshCfgDropdown()
        Library:Notification("refreshed: " .. #listConfigs() .. " config(s)", 3, Color3.fromRGB(220, 50, 100))
    end
})

local function WM_Search()
    local found = {}
    for _, v in getgc(true) do
        if type(v) == "table" and rawget(v, "FireRate") ~= nil and rawget(v, "VRecoil") ~= nil then
            found[v] = true
        end
    end
    WM_Clients = found
end

task.spawn(function()
    for _ = 1, 20 do
        WM_Search()
        if next(WM_Clients) then break end
        task.wait(1)
    end
    while true do
        task.wait(5)
        WM_Search()
    end
end)

RunService.Heartbeat:Connect(function()
    if not next(WM_Clients) then return end
    for v in pairs(WM_Clients) do
        if weaponSettings.noRecoil then
            pcall(function()
                v.VRecoil               = 0
                v.HRecoil               = 0
                v.RecoilPower           = 0
                v.RecoilPunch           = 0
                v.VPunchBase            = 0
                v.HPunchBase            = 0
                v.DPunchBase            = 0
                v.RecoilPowerStepAmount = 0
            end)
        end
        if weaponSettings.noSpread then
            pcall(function()
                v.MaxSpread               = 0
                v.MinSpread               = 0
                v.AimInaccuracyStepAmount = 0
                v.MaxSway                 = 0
            end)
        end
    end
end)

if not isMobile then
    Library.MenuKeybind = Enum.KeyCode.RightShift
end

updateChatHook()

-- watermark
local Watermark = Library:Watermark("index.lol beta")

local WatermarkLabel do
    for _, child in ipairs(Library.Holder.Instance:GetChildren()) do
        if child:IsA("Frame") then
            for _, v in ipairs(child:GetChildren()) do
                if v:IsA("TextLabel") and v.Text == "index.lol beta" then
                    WatermarkLabel = v
                    break
                end
            end
        end
        if WatermarkLabel then break end
    end
end

local fpsBuffer  = {}
local fpsConn

fpsConn = RunService.RenderStepped:Connect(function(dt)
    table.insert(fpsBuffer, 1 / dt)
    if #fpsBuffer > 20 then table.remove(fpsBuffer, 1) end

    local sum = 0
    for _, v in ipairs(fpsBuffer) do sum += v end
    local fps = math.floor(sum / #fpsBuffer)

    local parts = {}
    if showName then table.insert(parts, "index.lol beta") end
    if showUser then
        local name = userWatermarkMode == "display name" and localplayer.DisplayName or localplayer.Name
        table.insert(parts, name)
    end
    if showFps then table.insert(parts, fps .. " fps") end
    if showUptime then
        local elapsed = os.clock() - LoadingTick
        local mins = math.floor(elapsed / 60)
        local secs = math.floor(elapsed % 60)
        table.insert(parts, string.format("%02d:%02d", mins, secs))
    end

    local text = table.concat(parts, "  |  ")
    if WatermarkLabel then WatermarkLabel.Text = text end
    Watermark:SetVisibility(#parts > 0)
end)

Library:Notification(
    "loaded index beta in " .. string.format("%.4f", os.clock() - LoadingTick) .. "s",
    5,
    Color3.fromRGB(220, 50, 100)
)
