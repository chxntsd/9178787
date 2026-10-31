task.spawn(function()
    task.wait(5)
    pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        local devv = rs:FindFirstChild("devv")
        if devv then
            local remoteStorage = devv:FindFirstChild("remoteStorage")
            if remoteStorage then
                local me = remoteStorage:FindFirstChild("makeExplosion")
                if me then me:Destroy() end
            end
        end
    end)
end)

local WindUI =  loadstring(game:HttpGet("https://raw.githubusercontent.com/gycgchgyfytdttr/shenqin/refs/heads/main/ui.lua"))()
function createUI()
    local Window = WindUI:CreateWindow({
        Title = 'TeTraX',
        Icon = 'rbxassetid://4483362748',
        IconThemed = true,
        Author = "v0.1.3.6",
        Folder = 'TeTraX Farm',
        Size = UDim2.fromOffset(762, 643),
        Transparent = false,
        Theme = getCfg("theme", "Dark"),
        Resizable = true,
        SideBarWidth = 210,
        HideSearchBar = true,
        ScrollBarEnabled = true,
        User = { Enabled = true, Anonymous = false }
    })
    mainWindow = Window

    Window:SetToggleKey(Enum.KeyCode.G, true)

    Window:EditOpenButton({
        Title = "TeTraX V2",
        Icon = "rbxassetid://4483362748",
        CornerRadius = UDim.new(0, 15),
        StrokeThickness = 1,
        Draggable = true,
        OnlyMobile = false,
    })

    local BORDER_COLOR = ColorSequence.new({
        ColorSequenceKeypoint.new(0.000, Color3.fromHex("FF0000")),
        ColorSequenceKeypoint.new(0.166, Color3.fromHex("FF7F00")),
        ColorSequenceKeypoint.new(0.333, Color3.fromHex("FFFF00")),
        ColorSequenceKeypoint.new(0.500, Color3.fromHex("00FF00")),
        ColorSequenceKeypoint.new(0.666, Color3.fromHex("00FFFF")),
        ColorSequenceKeypoint.new(0.833, Color3.fromHex("0000FF")),
        ColorSequenceKeypoint.new(0.950, Color3.fromHex("8B00FF")),
        ColorSequenceKeypoint.new(1.000, Color3.fromHex("FF0000"))
    })
    local function createRainbowBorder(window)
        local mainFrame = window.UIElements and window.UIElements.Main
        if not mainFrame then return nil end
        local existingStroke = mainFrame:FindFirstChild("RainbowStroke")
        if existingStroke then existingStroke:Destroy() end
        if not mainFrame:FindFirstChildOfClass("UICorner") then
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 16)
            corner.Parent = mainFrame
        end
        local rainbowStroke = Instance.new("UIStroke")
        rainbowStroke.Name = "RainbowStroke"
        rainbowStroke.Thickness = 2
        rainbowStroke.Color = Color3.new(1, 1, 1)
        rainbowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        rainbowStroke.LineJoinMode = Enum.LineJoinMode.Round
        rainbowStroke.Parent = mainFrame
        local glowEffect = Instance.new("UIGradient")
        glowEffect.Name = "GlowEffect"
        glowEffect.Color = BORDER_COLOR
        glowEffect.Rotation = 0
        glowEffect.Parent = rainbowStroke
        return rainbowStroke
    end
    local function startBorderAnimation(window, speed)
        local mainFrame = window.UIElements and window.UIElements.Main
        if not mainFrame then return nil end
        local rainbowStroke = mainFrame:FindFirstChild("RainbowStroke")
        if not rainbowStroke then return nil end
        local glowEffect = rainbowStroke:FindFirstChild("GlowEffect")
        if not glowEffect then return nil end
        return game:GetService("RunService").Heartbeat:Connect(function()
            if not rainbowStroke or rainbowStroke.Parent == nil then return end
            glowEffect.Rotation = (tick() * speed * 60) % 360
        end)
    end

    local borderAnimation
    local borderEnabled   = getCfg("border", true)
    local animationSpeed  = getCfg("borderSpeed", 5)
    local rainbowStroke   = createRainbowBorder(Window)
    if rainbowStroke and borderEnabled then borderAnimation = startBorderAnimation(Window, animationSpeed) end
    if rainbowStroke then rainbowStroke.Enabled = borderEnabled end

    local Tabs = {
        Ohio       = Window:Tab({ Title = '主要',     Icon = 'crosshair' }),
        Player     = Window:Tab({ Title = '玩家',     Icon = 'user' }),
        Combat     = Window:Tab({ Title = '战斗',     Icon = 'swords' }),
        Visual     = Window:Tab({ Title = '视觉',     Icon = 'eye' }),
        Money      = Window:Tab({ Title = '金钱',     Icon = 'dollar-sign' }),
        UISettings = Window:Tab({ Title = 'UI 调试',  Icon = 'settings' }),
    }

    Window:CreateTopbarButton("settings-btn", "settings", function()
        pcall(function() Tabs.UISettings:Select() end)
    end, 990)

    local function getPlayerListValues()
        local names = {"全体"}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then table.insert(names, player.Name) end
        end
        return names
    end

    local autoKillToggle, tpPlayerToggle, autoStompToggle, punchTypeDropdown

    do
        local MoveSec = Tabs.Ohio:Section({ Title = '移动', Opened = true, Collapsible = false })
        MoveSec:Slider({
            Title = '飞行速度',
            Value = { Min = 10, Max = 1000, Default = getCfg("flySpeed", 50) },
            Callback = function(v) flySpeed = v; setCfg("flySpeed", v) end
        })
        local flyToggle
        flyToggle = MoveSec:Toggle({
            Title = '飞行模式',
            Value = getCfg("fly", false),
            Callback = function(s)
                setCfg("fly", s)
                if s then startFly() else stopFly() end
            end
        })
        MoveSec:Keybind({
            Title = '飞行快捷键',
            Value = getCfg("flyKey", 'F'),
            Callback = function()
                local newState = not flying
                if newState then startFly() else stopFly() end
                setCfg("fly", newState)
                pcall(function() flyToggle:SetValue(newState) end)
            end
        })
        MoveSec:Slider({
            Title = '移动速度',
            Value = { Min = 1, Max = 1000, Default = getCfg("moveSpeed", 10) },
            Callback = function(v) currentSpeed = v; setCfg("moveSpeed", v) end
        })
        MoveSec:Toggle({
            Title = '加速', Value = getCfg("tpwalk", false),
            Callback = function(s) setCfg("tpwalk", s); if s then startTPWalk() else stopTPWalk() end end
        })

        local RoleSec = Tabs.Ohio:Section({ Title = '角色', Opened = true, Collapsible = false })
        RoleSec:Toggle({ Title = '连跳', Value = getCfg("bunnyhop", false), Callback = function(s) setCfg("bunnyhop", s); toggleBunnyHop(s) end })
        RoleSec:Toggle({ Title = '穿墙', Value = getCfg("noclip", false), Callback = function(s) setCfg("noclip", s); toggleNoClip(s) end })
        RoleSec:Toggle({ Title = '防虚空掉落', Value = getCfg("antivoid", false), Callback = function(s) setCfg("antivoid", s); toggleAntiVoid(s) end })

        local AssistSec = Tabs.Ohio:Section({ Title = '辅助', Opened = true, Collapsible = false })
        AssistSec:Toggle({
            Title = '扩大视野', Value = getCfg("fov", false),
            Callback = function(v)
                setCfg("fov", v)
                if v then
                    if not fovConnection then
                        fovConnection = RunService.Heartbeat:Connect(function()
                            workspace.CurrentCamera.FieldOfView = 120
                        end)
                    end
                else
                    if fovConnection then fovConnection:Disconnect(); fovConnection = nil end
                end
            end
        })
        AssistSec:Toggle({
            Title = '快速互动', Value = getCfg("quickinteract", false),
            Callback = function(state)
                setCfg("quickinteract", state)
                if state then
                    game.ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
                        prompt.HoldDuration = 0
                    end)
                end
            end
        })
        AssistSec:Toggle({
            Title = '反挂机',
            Value = getCfg("antiidle", true),
            Callback = function(v)
                antiIdleEnabled = v
                setCfg("antiidle", v)
            end
        })
    end

    do
        local BTSec = Tabs.Combat:Section({ Title = '子弹追踪设置', Opened = true, Collapsible = false })
        BTSec:Toggle({ Title = '启用子弹追踪', Value = getCfg("bt", false), Callback = function(s) SilentAimSettings.Enabled = s; setCfg("bt", s) end })
        BTSec:Toggle({ Title = '穿墙', Value = getCfg("btWallbang", true), Callback = function(s) SilentAimSettings.Wallbang = s; setCfg("btWallbang", s) end })
        BTSec:Dropdown({
            Title = '目标部位',
            Values = {'Head', 'HumanoidRootPart', 'Random'},
            Value = getCfg("btPart", "Head"),
            Callback = function(v) SilentAimSettings.TargetPart = v; setCfg("btPart", v) end
        })
        BTSec:Slider({
            Title = '最大距离',
            Value = { Min = 10, Max = 2000, Default = getCfg("btMaxDist", 500) },
            Callback = function(v) SilentAimSettings.MaxDistance = v; setCfg("btMaxDist", v) end
        })
        BTSec:Slider({
            Title = 'FOV圈半径',
            Value = { Min = 10, Max = 1000, Default = getCfg("btFov", 130) },
            Callback = function(v)
                SilentAimSettings.FOVRadius = v
                setCfg("btFov", v)
                FOVCircleFrame.Size = UDim2.fromOffset(v * 2, v * 2)
            end
        })
        BTSec:Toggle({
            Title = '显示FOV圈', Value = getCfg("btFovShow", false),
            Callback = function(s)
                SilentAimSettings.FOVVisible = s
                setCfg("btFovShow", s)
                FOVCircleGui.Enabled = s
            end
        })
    end

    do
        local AutoGroup = Tabs.Money:Section({ Title = '自动功能', Opened = true, Collapsible = true })
        AutoGroup:Dropdown({
            Title = '农场模式',
            Values = {'AFK', 'Normal'},
            Value = getCfg("farmMode", "Normal"),
            Callback = function(v) currentMode = v; setCfg("farmMode", v); updateIdleConnection() end
        })
        AutoGroup:Dropdown({
            Title = '挂机位置',
            Values = {'TeTraX', '宿傩', '位置1', '位置2', '位置3', '位置4', '位置5', '位置6', '位置7', '位置8', '位置9', '位置10', '位置11'},
            Value = getCfg("idlePos", 'TeTraX'),
            Callback = function(v) currentIdleName = v; setCfg("idlePos", v); updateIdleConnection() end
        })
        AutoGroup:Divider()
        AutoGroup:Toggle({ Title = '自动摧毁ATM', Value = getCfg("atm", false), Callback = function(s) FromATM = s; setCfg("atm", s) end })
        AutoGroup:Toggle({ Title = '自动偷盗银行', Value = getCfg("bank", false), Callback = function(s) FromBank = s; setCfg("bank", s) end })
        AutoGroup:Toggle({ Title = '自动收银机', Value = getCfg("cashreg", false), Callback = function(s) autoCashRegister = s; setCfg("cashreg", s) end })
        AutoGroup:Toggle({ Title = '自动炸珠宝店', Value = getCfg("gemrubble", false), Callback = function(s) autoGemRubble = s; setCfg("gemrubble", s); if not s then gemRubbleCooldown = 0 end end })
        AutoGroup:Toggle({ Title = '自动收集装甲车现金', Value = getCfg("truckcash", false), Callback = function(s) autoCollectTruckCash = s; setCfg("truckcash", s); if s then startTruckCash() end end })
        AutoGroup:Toggle({ Title = '自动珠宝店', Value = getCfg("autozbd", false), Callback = function(s) autozbd = s; setCfg("autozbd", s) end })
        AutoGroup:Toggle({ Title = '自动捡材料', Value = getCfg("pickcomp", false), Callback = function(s) autoPickComponentEnabled = s; setCfg("pickcomp", s) end })
        AutoGroup:Toggle({ Title = '自动老虎机', Value = getCfg("slot", false), Callback = function(s) autoSlotMachine = s; setCfg("slot", s); if s then startSlotMachine() end end })
        AutoGroup:Toggle({ Title = '自动挖海盗宝藏', Value = getCfg("treasure", false), Callback = function(s) treasureFarmEnabled = s; setCfg("treasure", s) end })
        AutoGroup:Toggle({ Title = '自动打开保险', Value = getCfg("autobx", false), Callback = function(s) autobx = s; setCfg("autobx", s) end })
        AutoGroup:Toggle({ Title = '开锁光环', Value = getCfg("unlock", false), Callback = function(s) autoUnlockEnabled = s; setCfg("unlock", s); if s then startUnlockAura() else stopUnlockAura() end end })
        AutoGroup:Toggle({ Title = '打扫光环', Value = getCfg("clean", false), Callback = function(s) autoCleanEnabled = s; setCfg("clean", s) end })
        AutoGroup:Toggle({ Title = '自动领取空投', Value = getCfg("airdrop", false), Callback = function(s) autoAirdropEnabled = s; setCfg("airdrop", s) end })
        AutoGroup:Toggle({ Title = '自动工作', Value = getCfg("work", false), Callback = function(s) autoWorkEnabled = s; setCfg("work", s); updateIdleConnection() end })
        AutoGroup:Toggle({ Title = '自动传回家存宝石', Value = getCfg("storegems_tp", false), Callback = function(s) autoTeleportStoreGemsEnabled = s; setCfg("storegems_tp", s) end })
        AutoGroup:Toggle({ Title = '自动租房', Value = getCfg("rent", false), Callback = function(s) autoRentHouseEnabled = s; setCfg("rent", s) end })
        AutoGroup:Toggle({ Title = '现金光环', Value = getCfg("cashaura", false), Callback = function(s) cashAuraEnabled = s; setCfg("cashaura", s); if s then startCashAura() else stopCashAura() end end })
        AutoGroup:Toggle({ Title = '物品光环', Value = getCfg("itemaura", false), Callback = function(s) itemAuraEnabled = s; setCfg("itemaura", s); if s then startItemAura() else stopItemAura() end end })
        AutoGroup:Toggle({ Title = '自动售卖全部物品', Value = getCfg("sell", false), Callback = function(Value)
            autoSellEnabled = Value
            setCfg("sell", Value)
            if autoSellTask then task.cancel(autoSellTask); autoSellTask = nil end
            if Value then startAutoSell() end
        end })
        AutoGroup:Toggle({ Title = '自动移除垃圾', Value = getCfg("remls", false), Callback = function(s) remls = s; setCfg("remls", s) end })
        AutoGroup:Toggle({ Title = '自动使用消耗品', Value = getCfg("autouse", false), Callback = function(s) autouse = s; setCfg("autouse", s) end })
        AutoGroup:Toggle({ Title = '自动制作萝莉', Value = getCfg("craft", false), Callback = function(s) autoCraftEnabled = s; setCfg("craft", s) end })
        AutoGroup:Toggle({ Title = '自动领取萝莉',  Value = getCfg("claim", false), Callback = function(s) autoClaimEnabled = s; setCfg("claim", s) end })
        AutoGroup:Toggle({ Title = '自动存放珍贵宝石', Value = getCfg("storegems", false), Callback = function(s) autoStoreGems = s; setCfg("storegems", s) end })
        AutoGroup:Toggle({ Title = '自动领取奖励', Value = getCfg("reward", false), Callback = function(s) setCfg("reward", s); if s then startAutoRewardLoop() else stopAutoRewardLoop() end end })

        local FindGroup = Tabs.Money:Section({ Title = '寻找物品', Opened = true, Collapsible = true })
        FindGroup:Toggle({ Title = '自动捡最稀有物品', Value = getCfg("rare", false), Callback = function(state)
            getgenv().AutoPickVeryRare = state
            setCfg("rare", state)
            if not state then return end
            task.spawn(function()
                waitForUI()
                local localPlayer = Players.LocalPlayer
                local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
                local rootPart = character:WaitForChild("HumanoidRootPart")
                local targetItems = {
                    "Dollar Balloon", "Heart Crossbow", "Void Gem", "Diamond",
                    "Nuclear Missile Launcher", "NextBot Grenade", "Rollie",
                    "Gold Crown", "Dark Matter Gem", "Diamond Glock",
                    "Diamond Banana Peel", "Spirit Kunai", "Kunai",
                    "Purple Lucky Block", "Snowflake Balloon", "Suitcase Nuke",
                    "Nuke Launcher", "Easter Basket", "Gold Cup",
                    "Pearl Necklace", "Treasure Map", "Spectral Scythe",
                    "Bunny Balloon", "Ghost Balloon", "Clover Balloon",
                    "Bat Balloon", "Gold Clover Balloon", "Golden Rose",
                    "Black Rose", "Heart Balloon", "Skull Balloon",
                    "Candy Cane", "Diamond Glock", "Nuke Case",
                    "Pulse Rifle", "Trident", "El Fuego"
                }
                while getgenv().AutoPickVeryRare do
                    task.wait(0.05)
                    if not getgenv().AutoPickVeryRare then break end
                    if not rootPart or not rootPart:IsDescendantOf(game) then
                        character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
                        rootPart = character:WaitForChild("HumanoidRootPart")
                    end
                    local itemFolder = workspace:FindFirstChild("Game")
                    if not itemFolder then continue end
                    local entities = itemFolder:FindFirstChild("Entities")
                    if not entities then continue end
                    local itemPickup = entities:FindFirstChild("ItemPickup")
                    if not itemPickup then continue end
                    for _, l in pairs(itemPickup:GetChildren()) do
                        if not getgenv().AutoPickVeryRare then break end
                        for _, v in pairs(l:GetChildren()) do
                            if v:IsA("MeshPart") or v:IsA("Part") then
                                local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                                if prompt and table.find(targetItems, prompt.ObjectText) then
                                    if getgenv().BlockRedCardRoom and (v.Position - getgenv().RedCardRoomPos).Magnitude <= getgenv().BlockRadius then continue end
                                    rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                                    prompt.RequiresLineOfSight = false
                                    prompt.HoldDuration = 0
                                    task.wait(0.03)
                                    if fireproximityprompt then fireproximityprompt(prompt) else firesignal(prompt.Triggered) end
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end })
        FindGroup:Toggle({ Title = '自动捡气球', Value = getCfg("balloon", false), Callback = function(state)
            getgenv().AutoPickComponent = state
            setCfg("balloon", state)
            if not state then return end
            task.spawn(function()
                waitForUI()
                local localPlayer = Players.LocalPlayer
                local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
                local rootPart = character:WaitForChild("HumanoidRootPart")
                local targetItems = {
                    "Bat Balloon", "Bunny Balloon", "Clover Balloon",
                    "Ghost Balloon", "Gold Clover Balloon", "Heart Balloon",
                    "Skull Balloon"
                }
                while getgenv().AutoPickComponent do
                    task.wait(0.05)
                    if not getgenv().AutoPickComponent then break end
                    if not rootPart or not rootPart:IsDescendantOf(game) then
                        character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
                        rootPart = character:WaitForChild("HumanoidRootPart")
                    end
                    local itemFolder = workspace:FindFirstChild("Game")
                    if not itemFolder then continue end
                    local entities = itemFolder:FindFirstChild("Entities")
                    if not entities then continue end
                    local itemPickup = entities:FindFirstChild("ItemPickup")
                    if not itemPickup then continue end
                    for _, l in pairs(itemPickup:GetChildren()) do
                        if not getgenv().AutoPickComponent then break end
                        for _, v in pairs(l:GetChildren()) do
                            if v:IsA("MeshPart") or v:IsA("Part") then
                                local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                                if prompt and table.find(targetItems, prompt.ObjectText) then
                                    if getgenv().BlockRedCardRoom and (v.Position - getgenv().RedCardRoomPos).Magnitude <= getgenv().BlockRadius then continue end
                                    rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                                    prompt.RequiresLineOfSight = false
                                    prompt.HoldDuration = 0
                                    task.wait(0.03)
                                    if fireproximityprompt then fireproximityprompt(prompt) else firesignal(prompt.Triggered) end
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end })
        FindGroup:Toggle({ Title = '自动寻找印钞机', Value = getCfg("automoney", false), Callback = function(s) automoney = s; setCfg("automoney", s) end })
        FindGroup:Toggle({ Title = '自动寻找普通宝石', Value = getCfg("autoptbs", false), Callback = function(s) autoptbs = s; setCfg("autoptbs", s) end })
        FindGroup:Toggle({ Title = '自动寻找稀有宝石', Value = getCfg("autoxybs", false), Callback = function(s) autoxybs = s; setCfg("autoxybs", s) end })
        FindGroup:Toggle({ Title = '自动寻找礼物', Value = getCfg("automoss", false), Callback = function(s) automoss = s; setCfg("automoss", s) end })
        FindGroup:Toggle({ Title = '自动寻找幸运方块', Value = getCfg("autoblock", false), Callback = function(s) autoblock = s; setCfg("autoblock", s) end })
        FindGroup:Toggle({ Title = '自动寻找红卡', Value = getCfg("card", false), Callback = function(s) card = s; setCfg("card", s) end })
    end

    do
        local KillSec = Tabs.Player:Section({ Title = '击杀', Opened = true, Collapsible = true })

        local playerDropdown = KillSec:Dropdown({
            Title = '选择目标玩家',
            Values = getPlayerListValues(),
            Value = '全体',
            Multi = false,
            Callback = function(value)
                if not value or value == '' or value == '全体' then
                    targetPlayers = {}
                else
                    targetPlayers = {}
                    if Players:FindFirstChild(value) then
                        table.insert(targetPlayers, value)
                    end
                end
            end
        })

        KillSec:Button({
            Title = '刷新玩家列表',
            Callback = function()
                local newList = getPlayerListValues()
                pcall(function()
                    if playerDropdown.Set then
                        playerDropdown:Set(newList)
                    elseif playerDropdown.SetValues then
                        playerDropdown:SetValues(newList)
                    end
                end)
            end
        })

        local killMethodInitialized = false
        local lastKillMethod        = 'Melee Kill'

        KillSec:Dropdown({
            Title = '击杀方式',
            Values = { 'Melee Kill', 'Gun Kill', 'ALL Gun Kill' },
            Value = getCfg("killMethod", 'Melee Kill'),
            Callback = function(v)
                local newV = v or 'Melee Kill'
                selectedWeapon = newV
                setCfg("killMethod", newV)

                if not killMethodInitialized then
                    killMethodInitialized = true
                    if newV == lastKillMethod then
                        return
                    end
                end
                lastKillMethod = newV

                stopPunchAura()

                if newV == 'Melee Kill' then
                    aurablade = true
                    tpplayfb = true
                    autoStomp = true
                    punchStyle = 'fists'
                    punchType = 'meleemegapunch'
                    if autoKillToggle then pcall(function() autoKillToggle:SetValue(true) end) end
                    if tpPlayerToggle then pcall(function() tpPlayerToggle:SetValue(true) end) end
                    if autoStompToggle then pcall(function() autoStompToggle:SetValue(true) end) end
                    if punchTypeDropdown then pcall(function() punchTypeDropdown:SetValue('超级拳') end) end
                    updateAuraConnection()
                    prepareWeapon()
                elseif newV == 'Gun Kill' then
                    aurablade = true
                    tpplayfb = false
                    autoStomp = false
                    punchType = 'meleemegapunch'
                    if autoKillToggle then pcall(function() autoKillToggle:SetValue(true) end) end
                    if tpPlayerToggle then pcall(function() tpPlayerToggle:SetValue(false) end) end
                    if autoStompToggle then pcall(function() autoStompToggle:SetValue(false) end) end
                    updateAuraConnection()
                    prepareWeapon()
                elseif newV == 'ALL Gun Kill' then
                    aurablade = true
                    tpplayfb = false
                    autoStomp = false
                    punchType = 'meleemegapunch'
                    allGunKillRotation = 0
                    if autoKillToggle then pcall(function() autoKillToggle:SetValue(true) end) end
                    if tpPlayerToggle then pcall(function() tpPlayerToggle:SetValue(false) end) end
                    if autoStompToggle then pcall(function() autoStompToggle:SetValue(false) end) end
                    updateAuraConnection()
                    prepareWeapon()
                end
            end
        })

        KillSec:Dropdown({
            Title = '选择枪械',
            Values = { 'Raygun', 'M4A1', 'AK47' },
            Value = getCfg("gunType", 'Raygun'),
            Callback = function(v)
                selectedGun = v or 'Raygun'
                setCfg("gunType", selectedGun)
                if selectedWeapon == 'Gun Kill' or selectedWeapon == 'ALL Gun Kill' then
                    prepareWeapon()
                end
            end
        })

        autoKillToggle = KillSec:Toggle({
            Title = '自动击杀',
            Value = getCfg("kill", false),
            Callback = function(s)
                aurablade = s
                setCfg("kill", s)
                if s then prepareWeapon() end
                updateAuraConnection()
            end
        })

        tpPlayerToggle = KillSec:Toggle({
            Title = 'TP玩家',
            Value = getCfg("tpplayer", false),
            Callback = function(s)
                tpplayfb = s
                setCfg("tpplayer", s)
                updateAuraConnection()
            end
        })

        KillSec:Slider({ Title = 'X 偏移', Value = { Min = -20, Max = 20, Default = 0 }, Callback = function(v) fbx = v end })
        KillSec:Slider({ Title = 'Y 偏移', Value = { Min = -20, Max = 20, Default = 0 }, Callback = function(v) fby = v end })
        KillSec:Slider({ Title = 'Z 偏移', Value = { Min = -20, Max = 20, Default = 0 }, Callback = function(v) fbz = v end })

        KillSec:Toggle({
            Title = '传送目标背后10万米',
            Value = getCfg("tpbehind", false),
            Callback = function(s) autoTPBehind = s; setCfg("tpbehind", s) end
        })

        KillSec:Toggle({
            Title = '枪击杀自动传送',
            Value = getCfg("gunautotp", false),
            Callback = function(s) gunKillAutoTP = s; setCfg("gunautotp", s) end
        })

        KillSec:Toggle({
            Title = '强制拿起武器',
            Value = getCfg("forceequip", false),
            Callback = function(s) forceEquipEnabled = s; setCfg("forceequip", s) end
        })

        KillSec:Toggle({
            Title = '极限射速',
            Value = getCfg("rapid", false),
            Callback = function(s) gunRapidFire = s; setCfg("rapid", s) end
        })

        KillSec:Slider({
            Title = '近战攻击范围',
            Value = { Min = 5, Max = 20, Default = getCfg("meleeRange", 20) },
            Callback = function(v)
                meleeAttackRange = v
                setCfg("meleeRange", v)
                if meleeAuraEnabled then updateKillAuraCircleRadius() end
            end
        })

        KillSec:Toggle({
            Title = '近战攻击光环',
            Value = getCfg("meleeaura", false),
            Callback = function(s)
                meleeAuraEnabled = s
                setCfg("meleeaura", s)
                if s then startKillAuraCircle() else stopKillAuraCircle() end
            end
        })

        local CombatSec = Tabs.Combat:Section({ Title = '战斗', Opened = true, Collapsible = true })

        CombatSec:Dropdown({
            Title = '口罩选择',
            Values = { '黑色头巾', '红色头巾', '蓝色头巾', '外科医生口罩', '面具' },
            Value = getCfg("maskType", '外科医生口罩'),
            Callback = function(v)
                selectedMaskType = v
                setCfg("maskType", v)
                maskAutoBuy = true
            end
        })

        CombatSec:Toggle({ Title = '自动护甲', Value = getCfg("autovest", false), Callback = function(s) autovest = s; setCfg("autovest", s) end })
        CombatSec:Toggle({ Title = '自动回血', Value = getCfg("autohealth", false), Callback = function(s) autohealth = s; setCfg("autohealth", s) end })
        CombatSec:Toggle({ Title = '自动口罩', Value = getCfg("autokz", true), Callback = function(s) autokz = s; setCfg("autokz", s) end })
        CombatSec:Toggle({
            Title = '购买后返回原地',
            Value = getCfg("returnAfterBuy", true),
            Callback = function(s) returnAfterBuy = s; setCfg("returnAfterBuy", s) end
        })
        CombatSec:Toggle({ Title = '电话骚扰', Value = getCfg("phone", false), Callback = function(s) callphone = s; setCfg("phone", s) end })
        CombatSec:Toggle({ Title = '逮捕光环', Value = getCfg("cuff", false), Callback = function(s) Auarcuff = s; setCfg("cuff", s) end })

        CombatSec:Divider()

        autoStompToggle = CombatSec:Toggle({
            Title = '踩踏光环',
            Value = getCfg("stomp", false),
            Callback = function(s) autoStomp = s; setCfg("stomp", s) end
        })

        CombatSec:Toggle({
            Title = '抓取光环',
            Value = getCfg("grab", false),
            Callback = function(s) autoGrab = s; setCfg("grab", s) end
        })

        CombatSec:Divider()

        punchTypeDropdown = CombatSec:Dropdown({
            Title = '一拳类型',
            Values = { '普通拳', '超级拳', '破甲' },
            Value = getCfg("punchType", '超级拳'),
            Callback = function(val)
                setCfg("punchType", val)
                if val == '普通拳' then
                    punchType = 'meleepunch'
                    punchStyle = 'fists'
                elseif val == '超级拳' then
                    punchType = 'meleemegapunch'
                    punchStyle = 'fists'
                elseif val == '破甲' then
                    punchType = 'meleepunch'
                    punchStyle = 'knuckles'
                end
            end
        })

        CombatSec:Toggle({
            Title = '启用一拳光环',
            Value = getCfg("punchaura", false),
            Callback = function(state)
                setCfg("punchaura", state)
                if state then
                    startPunchAura()
                else
                    stopPunchAura()
                end
            end
        })

        local AmmoSec = Tabs.Player:Section({ Title = '弹药自动购买', Opened = true, Collapsible = true })
        AmmoSec:Toggle({ Title = '击杀枪自动买弹药（M4/AK）', Value = getCfg("buyGunAmmo", false),
            Callback = function(s) autoBuyGunAmmo = s; setCfg("buyGunAmmo", s); if s then gunBuyTimer = 0 end end })
        AmmoSec:Toggle({ Title = '喷火枪自动买弹药（火焰/酸液）', Value = getCfg("buyFlameAmmo", false),
            Callback = function(s) autoBuyFlameAmmo = s; setCfg("buyFlameAmmo", s); if s then flameBuyTimer = 0 end end })
        AmmoSec:Toggle({ Title = 'RPG自动买弹药（RPG/三叉戟）', Value = getCfg("buyRPGAmmo", false),
            Callback = function(s) autoBuyRPGAmmo = s; setCfg("buyRPGAmmo", s); if s then rpgBuyTimer = 0 end end })

        local CounterSec = Tabs.Ohio:Section({ Title = '反制', Opened = true, Collapsible = true })
        CounterSec:Button({
            Title = '重新进入服务器',
            Callback = function()
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end
        })
        local toastTarget = "关闭"
        local toastTargetDropdown = CounterSec:Dropdown({
            Title = '弹窗目标',
            Values = {'关闭'},
            Value = '关闭',
            Callback = function(v) toastTarget = v end
        })
        local function refreshToastTargets()
            local names = {"关闭"}
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local ok, isFriend = pcall(function() return LocalPlayer:IsFriendsWith(player.UserId) end)
                    if not ok or not isFriend then table.insert(names, player.Name) end
                end
            end
            if toastTargetDropdown then
                pcall(function()
                    if toastTargetDropdown.SetValues then toastTargetDropdown:SetValues(names)
                    elseif toastTargetDropdown.Options then toastTargetDropdown.Options = names; toastTargetDropdown:Refresh() end
                end)
            end
        end
        task.spawn(function() while true do task.wait(0.5); refreshToastTargets() end end)
        local toastMsg, toastTime = "", 5
        CounterSec:Input({ Title = '弹窗内容', Value = '', Callback = function(v) toastMsg = v end })
        CounterSec:Input({ Title = '弹窗时长(秒)', Value = '5', Callback = function(v) toastTime = tonumber(v) or 5 end })
        CounterSec:Button({
            Title = '发送弹窗',
            Callback = function()
                if toastTarget == "关闭" then
                    loadModule("makeToast")(toastMsg, "rainbow", toastTime)
                else
                    local targetPlayer = Players:FindFirstChild(toastTarget)
                    if targetPlayer then
                        local chatService = game:GetService("Chat")
                        if chatService and chatService.Chat then
                            chatService:Chat("/msg " .. targetPlayer.Name .. " " .. toastMsg)
                        end
                        Notify("已尝试向 " .. targetPlayer.Name .. " 发送弹窗: " .. toastMsg, 3, "info")
                    else Notify("目标玩家不存在！", 2, "warning") end
                end
            end
        })
        CounterSec:Button({ Title = '通话禁音', Callback = function()
            FireServer("setAirplaneMode", true); LocalPlayer:SetAttribute('isAirplaneMode', true)
        end })
        CounterSec:Button({ Title = '不允许战斗中', Callback = function()
            local combatIndicator = require(ReplicatedStorage.devv.client.Helpers.ui.combatIndicator)
            hookfunction(combatIndicator.isInCombat, function() return false end)
            hookfunction(combatIndicator.enterCombat, function() end)
        end })
        CounterSec:Button({ Title = '不允许被抓取', Callback = function()
            local GrabHandler = require(ReplicatedStorage.devv.client.Handlers.GrabHandler)
            local oldCheck = GrabHandler.CheckValid
            GrabHandler.CheckValid = function(self, p29, p30)
                if p29 == LocalPlayer then return false end
                return oldCheck(self, p29, p30)
            end
            local oldGrab = GrabHandler.Grab
            GrabHandler.Grab = function(self, p55)
                if p55 == LocalPlayer then return end
                return oldGrab(self, p55)
            end
        end })
        CounterSec:Button({ Title = '清除树叶', Callback = function()
            for _, v in workspace:GetDescendants() do
                if v.Name == "Leaves" and v:IsA("MeshPart") then v:Destroy() end
            end
        end })
        CounterSec:Button({ Title = '反坐下', Callback = function()
            local function as(char)
                local hum = char:WaitForChild("Humanoid")
                hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                hum:GetPropertyChangedSignal("Sit"):Connect(function()
                    if hum.Sit then hum.Sit = false end
                end)
                hum.Sit = false
            end
            if LocalPlayer.Character then as(LocalPlayer.Character) end
            LocalPlayer.CharacterAdded:Connect(as)
        end })
        CounterSec:Toggle({ Title = '反布娃娃', Value = getCfg("antidoll", false), Callback = function(s) AntiDoll = s; setCfg("antidoll", s) end })
        CounterSec:Toggle({ Title = '反管理',   Value = getCfg("antiadmin", false), Callback = function(s) AntiAdmin = s; setCfg("antiadmin", s) end })

        local WeaponSec = Tabs.Ohio:Section({ Title = '武器', Opened = true, Collapsible = true })
        WeaponSec:Toggle({ Title = '静默自瞄', Value = getCfg("silentaim", false), Callback = function(s) silentaim = s; setCfg("silentaim", s) end })
        WeaponSec:Button({ Title = '全枪无后座', Callback = function()
            for _, v in game:GetDescendants() do if v:IsA("ParticleEmitter") then v:Destroy() end end
            game.DescendantAdded:Connect(function(d) if d:IsA("ParticleEmitter") then d:Destroy() end end)
            for _, v in pairs(items) do
                if v.type == "Gun" then
                    v.recoilAdd = 0; v.maxRecoil = 0
                    v.recoilDiminishFactor = 0; v.recoilFastDiminishFactor = 0
                end
            end
            for _, gun in pairs(ReplicatedStorage.devv.shared.Indicies.v3items.bin.Gun:GetChildren()) do
                if gun:IsA("ModuleScript") then
                    local t = require(gun)
                    t.recoilAdd = 0; t.maxRecoil = 0
                    t.recoilDiminishFactor = 0; t.recoilFastDiminishFactor = 0
                end
            end
        end })
        WeaponSec:Button({ Title = '全枪据点', Callback = function()
            for _, v in pairs(items) do
                if v.type == "Gun" then
                    v.baseSpread = 0; v.baseAimSpread = 0; v.spread = 0; v.aimSpread = 0
                end
            end
            for _, gun in pairs(ReplicatedStorage.devv.shared.Indicies.v3items.bin.Gun:GetChildren()) do
                if gun:IsA("ModuleScript") then
                    local t = require(gun)
                    t.baseSpread = 0; t.baseAimSpread = 0
                end
            end
        end })
        WeaponSec:Button({ Title = '全枪射速', Callback = function()
            for _, v in pairs(items) do if v.type == "Gun" then v.fireDebounce = 0 end end
            for _, gun in pairs(ReplicatedStorage.devv.shared.Indicies.v3items.bin.Gun:GetChildren()) do
                if gun:IsA("ModuleScript") then require(gun).fireDebounce = 0 end
            end
        end })
        WeaponSec:Button({ Title = '全枪瞬击', Callback = function()
            for _, v in pairs(items) do
                if v.type == "Gun" then v.speedMax = 9999; v.speedDropoff = 0; v.projectileLifetime = 9999 end
            end
            for _, gun in pairs(ReplicatedStorage.devv.shared.Indicies.v3items.bin.Gun:GetChildren()) do
                if gun:IsA("ModuleScript") then
                    local t = require(gun)
                    t.speedMax = 9999; t.speedDropoff = 0; t.projectileLifetime = 9999
                end
            end
        end })
        WeaponSec:Button({ Title = '快速换弹', Callback = function()
            for _, v in pairs(items) do if v.type == "Gun" then v.reloadTime = 0 end end
            for _, gun in pairs(ReplicatedStorage.devv.shared.Indicies.v3items.bin.Gun:GetChildren()) do
                if gun:IsA("ModuleScript") then require(gun).reloadTime = 0 end
            end
        end })

        local MsgSec = Tabs.Ohio:Section({ Title = '消息轰炸', Opened = true, Collapsible = true })
        local msgToggle
        msgToggle = MsgSec:Toggle({
            Title = '启用消息轰炸', Value = getCfg("msgspam", false),
            Callback = function(s)
                msgSpamEnabled = s
                setCfg("msgspam", s)
                if s then
                    startMsgSpam()
                else
                    if msgSpamTask then task.cancel(msgSpamTask); msgSpamTask = nil end
                end
            end
        })
        MsgSec:Dropdown({
            Title = '消息模式',
            Values = {'随机', '自定义'},
            Value = getCfg("msgMode", '随机'),
            Callback = function(v) msgSpamMode = v; setCfg("msgMode", v) end
        })
        MsgSec:Input({ Title = '自定义消息内容', Value = getCfg("msgText", '欢迎来到俄亥俄州'), Callback = function(v) customMsgText = v; setCfg("msgText", v) end })
        MsgSec:Input({
            Title = '循环间隔（秒）', Value = tostring(getCfg("msgInterval", 0.2)),
            Callback = function(v)
                local num = tonumber(v)
                msgSpamInterval = num and math.clamp(num, 0.01, 1) or 0.2
                setCfg("msgInterval", msgSpamInterval)
            end
        })
    end

    do
        local SpecialSec = Tabs.Combat:Section({ Title = '特殊攻击', Opened = true, Collapsible = false })
        SpecialSec:Slider({
            Title = '火焰/酸液攻击距离',
            Value = { Min = 1, Max = 10000, Default = getCfg("flameDist", 10000) },
            Callback = function(v) flameAttackDistance = v; setCfg("flameDist", v) end
        })
        SpecialSec:Toggle({
            Title = '火焰/酸液攻击', Value = getCfg("flame", false),
            Callback = function(s)
                flameAttackEnabled = s
                setCfg("flame", s)
                if s then startFlameAttack() end
            end
        })
        SpecialSec:Slider({
            Title = 'RPG/三叉戟攻击距离',
            Value = { Min = 1, Max = 5000, Default = getCfg("rpgDist", 100) },
            Callback = function(v) rpgAttackDistance = v; setCfg("rpgDist", v) end
        })
        SpecialSec:Slider({
            Title = 'RPG/三叉戟最低血量',
            Value = { Min = 0.1, Max = 1, Default = getCfg("rpgMinHealth", 0.3) },
            Callback = function(v) rpgMinHealth = v; setCfg("rpgMinHealth", v) end
        })
        SpecialSec:Toggle({
            Title = 'RPG/三叉戟攻击', Value = getCfg("rpg", false),
            Callback = function(s)
                rpgAttackEnabled = s
                setCfg("rpg", s)
                if s then startRPGAttack() end
            end
        })
    end

    do
        local HitboxSettings = { ENABLED = getCfg("hitbox", false), HITBOX_SIZE = getCfg("hitboxSize", 15), HITBOX_TRANSPARENCY = getCfg("hitboxAlpha", 0.7), TARGET_PART = getCfg("hitboxPart", "Head") }
        local HitboxSec = Tabs.Combat:Section({ Title = '枪械范围', Opened = true, Collapsible = true })
        HitboxSec:Toggle({
            Title = '枪械范围', Value = getCfg("hitbox", false),
            Callback = function(state)
                HitboxSettings.ENABLED = state
                setCfg("hitbox", state)
                if not state then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character then
                            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then hrp.Size = Vector3.new(2,2,1); hrp.Transparency = 1 end
                        end
                    end
                end
            end
        })
        HitboxSec:Slider({
            Title = '范围大小',
            Value = { Min = 1, Max = 50, Default = getCfg("hitboxSize", 15) },
            Callback = function(val) HitboxSettings.HITBOX_SIZE = val; setCfg("hitboxSize", val) end
        })
        HitboxSec:Slider({
            Title = '透明度',
            Value = { Min = 0, Max = 100, Default = math.floor(getCfg("hitboxAlpha", 0.7) * 100) },
            Callback = function(val) HitboxSettings.HITBOX_TRANSPARENCY = val / 100; setCfg("hitboxAlpha", val / 100) end
        })
        HitboxSec:Dropdown({
            Title = '攻击部位',
            Values = {"Head","Torso","HumanoidRootPart","UpperTorso","LowerTorso","LeftHand","RightHand","LeftFoot","RightFoot","LeftLowerArm","RightLowerArm","LeftUpperArm","RightUpperArm","LeftLowerLeg","RightLowerLeg","LeftUpperLeg","RightUpperLeg"},
            Value = getCfg("hitboxPart", "Head"),
            Callback = function(Value) HitboxSettings.TARGET_PART = Value; setCfg("hitboxPart", Value) end
        })

        local Proj = v3item.projectiles
        if Proj and Proj.hitreg then
            local oldHitreg = Proj.hitreg
            Proj.hitreg = function(self, hitPart, pos, normal, material)
                if HitboxSettings.ENABLED and self.isPlayerOwned then
                    local target, shortestDist = nil, HitboxSettings.HITBOX_SIZE
                    for _, p in ipairs(Players:GetPlayers()) do
                        local char = p ~= LocalPlayer and p.Character
                        local part = char and char:FindFirstChild(HitboxSettings.TARGET_PART)
                        if part and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                            local dist = (pos - part.Position).Magnitude
                            if dist < shortestDist then shortestDist, target = dist, part end
                        end
                    end
                    if target then hitPart, pos = target, target.Position end
                end
                return oldHitreg(self, hitPart, pos, normal, material)
            end
        end

        RunService.RenderStepped:Connect(function()
            if not uiReady then return end
            if not HitboxSettings.ENABLED then return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(HitboxSettings.HITBOX_SIZE, HitboxSettings.HITBOX_SIZE, HitboxSettings.HITBOX_SIZE)
                        hrp.Transparency = HitboxSettings.HITBOX_TRANSPARENCY
                        hrp.Color = Color3.new(1,0,0)
                        hrp.CanCollide = false
                    end
                end
            end
        end)
    end

    do
        local EspSec = Tabs.Visual:Section({ Title = 'ESP 设置', Opened = true, Collapsible = false })
        EspSec:Toggle({ Title = '开启 ESP', Value = getCfg("esp", true), Callback = function(s)
            EspConfig.Enabled = s
            setCfg("esp", s)
            if not s then for _, d in pairs(EspCache) do espHideAll(d) end end
        end })
        EspSec:Toggle({ Title = '显示玩家名', Value = getCfg("espname", true), Callback = function(s) EspConfig.ShowName = s; setCfg("espname", s) end })
        EspSec:Toggle({ Title = '显示距离',   Value = getCfg("espdist", true), Callback = function(s) EspConfig.ShowDistance = s; setCfg("espdist", s) end })
        EspSec:Toggle({ Title = '显示 HP',    Value = getCfg("esphp", true), Callback = function(s) EspConfig.ShowHealth = s; setCfg("esphp", s) end })
        EspSec:Toggle({ Title = '显示武器',   Value = getCfg("esptool", true), Callback = function(s) EspConfig.ShowTool = s; setCfg("esptool", s) end })
        EspSec:Slider({
            Title = 'ESP 最大距离',
            Value = { Min = 100, Max = 5000, Default = getCfg("espMaxDist", 1000) },
            Callback = function(v) EspConfig.MaxDistance = v; setCfg("espMaxDist", v) end
        })

        local FxSec = Tabs.Visual:Section({ Title = '攻击特效', Opened = true, Collapsible = false })
        FxSec:Toggle({
            Title = '显示白色弹道',
            Value = getCfg("trace", true),
            Callback = function(s) showTrace = s; setCfg("trace", s) end
        })
        FxSec:Toggle({
            Title = '播放命中音效',
            Value = getCfg("hitsound", true),
            Callback = function(s) showHitSound = s; setCfg("hitsound", s) end
        })
        FxSec:Toggle({
            Title = '彩虹弹道美化',
            Value = getCfg("rainbow", false),
            Callback = function(s) RAINBOW_TRACE = s; setCfg("rainbow", s) end
        })

        local HitLogSec = Tabs.Visual:Section({ Title = '命中日志', Opened = true, Collapsible = false })
        HitLogSec:Toggle({
            Title = '命中日志', Value = getCfg("hitlog", false),
            Callback = function(s) setCfg("hitlog", s); if s then StartHitLog() else StopHitLog() end end
        })

        local BypassSec = Tabs.Visual:Section({ Title = '绕过', Opened = true, Collapsible = true })
        BypassSec:Slider({
            Title = '物品栏数量',
            Value = { Min = 6, Max = 12, Default = getCfg("slots", 9) },
            Callback = function(v) loadModule("v3item").inventory.numSlots = v; setCfg("slots", v) end
        })
        BypassSec:Button({ Title = '解锁移动经销商', Callback = function()
            local Signal2 = require(ReplicatedStorage.devv.client.Helpers.remotes.Signal)
            local oldInvoke = Signal2.InvokeServer
            Signal2.InvokeServer = function(self, cmd, ...)
                if cmd == "attemptPurchase" or cmd == "attemptPurchaseAmmo" then
                    local itemName = ...
                    return oldInvoke(self, cmd, itemName, false, select(3,...))
                end
                return oldInvoke(self, cmd, ...)
            end
            LocalPlayer:SetAttribute("mobileDealer", true)
            local mobileDealer = require(ReplicatedStorage.devv.shared.Indicies.mobileDealer)
            for _, itemsList in pairs(mobileDealer) do
                for _, item in ipairs(itemsList) do item.stock = 12e12 end
            end
            table.insert(mobileDealer.Gun, { itemName = "Acid Gun", stock = 12e12 })
        end })
        BypassSec:Button({ Title = '解锁全皮肤', Callback = function()
            local skinsModule = require(ReplicatedStorage.devv.client.Helpers.ui.screens.CaseMenu.Skins)
            local state = loadModule("state")
            hookfunction(skinsModule.AttemptEquip, function(self, itemName, skinName)
                local skinToEquip = skinName
                if self:IsSkinEquipped(itemName, skinName) then skinToEquip = nil end
                state.data.equippedSkins[itemName] = skinToEquip
                loadModule("v3item").inventory.unequipAll()
                loadModule("v3item").inventory.skinUpdate(itemName, skinToEquip)
                self:_setEquipped(itemName, skinToEquip)
                return true
            end)
            local skins = loadModule("skins")
            for skinName in pairs(skins.skinData) do
                for _, itemName in pairs(skins.compatabilities.Generic) do
                    state.data.ownedSkins[itemName] = state.data.ownedSkins[itemName] or {}
                    state.data.ownedSkins[itemName][skinName] = 1
                end
            end
        end })
        BypassSec:Button({ Title = '解锁高级表情', Callback = function()
            for _, v in LocalPlayer.PlayerGui.Emotes.Frame.ScrollingFrame:GetDescendants() do
                if v.Name == "Locked" then v.Visible = false end
            end
        end })
        BypassSec:Button({ Title = '绕过火&酸伤害', Callback = function()
            local fire = ReplicatedStorage.devv.remoteStorage:FindFirstChild("fireHit")
            local acid = ReplicatedStorage.devv.remoteStorage:FindFirstChild("acidHit")
            if fire then fire:Destroy() end
            if acid then acid:Destroy() end
        end })
    end

    do
        local UISection = Tabs.UISettings:Section({ Title = '外观设置', Opened = true, Collapsible = false })
        local themes_list = {}
        for themeName in pairs(WindUI:GetThemes()) do table.insert(themes_list, themeName) end
        table.sort(themes_list)
        UISection:Dropdown({
            Title = "UI颜色(主题)",
            Values = themes_list,
            Value = getCfg("theme", "Dark"),
            Callback = function(theme) WindUI:SetTheme(theme); setCfg("theme", theme) end
        })
        UISection:Slider({
            Title = "边框流动速度",
            Value = { Min = 1, Max = 10, Default = getCfg("borderSpeed", 1) },
            Callback = function(value)
                animationSpeed = value
                setCfg("borderSpeed", value)
                if borderAnimation then borderAnimation:Disconnect(); borderAnimation = nil end
                if borderEnabled then borderAnimation = startBorderAnimation(Window, animationSpeed) end
            end
        })
        UISection:Slider({
            Title = "边框粗细",
            Value = { Min = 1, Max = 5, Default = 1.5 },
            Step = 0.5,
            Callback = function(value)
                local mainFrame = Window.UIElements and Window.UIElements.Main
                if mainFrame then
                    local rs = mainFrame:FindFirstChild("RainbowStroke")
                    if rs then rs.Thickness = value end
                end
            end
        })
        UISection:Slider({
            Title = "圆角大小",
            Value = { Min = 0, Max = 30, Default = 17 },
            Callback = function(value)
                local mainFrame = Window.UIElements and Window.UIElements.Main
                if mainFrame then
                    local corner = mainFrame:FindFirstChildOfClass("UICorner")
                    if not corner then corner = Instance.new("UICorner"); corner.Parent = mainFrame end
                    corner.CornerRadius = UDim.new(0, value)
                end
            end
        })
        UISection:Toggle({
            Title = "启用彩虹边框", Value = getCfg("border", true),
            Callback = function(value)
                borderEnabled = value
                setCfg("border", value)
                local mainFrame = Window.UIElements and Window.UIElements.Main
                if mainFrame then
                    local rs = mainFrame:FindFirstChild("RainbowStroke")
                    if rs then
                        rs.Enabled = value
                        if value and not borderAnimation then borderAnimation = startBorderAnimation(Window, animationSpeed)
                        elseif not value and borderAnimation then borderAnimation:Disconnect(); borderAnimation = nil end
                    end
                end
            end
        })

        local DebugSec = Tabs.UISettings:Section({ Title = "调试", Opened = true, Collapsible = false })
        DebugSec:Button({ Title = "销毁界面", Callback = function() Window:Destroy() end })
        DebugSec:Button({ Title = "切换界面显示", Callback = function() Window:Toggle() end })
    end

    Window:OnClose(function()
        if borderAnimation then borderAnimation:Disconnect(); borderAnimation = nil end
    end)
--lz