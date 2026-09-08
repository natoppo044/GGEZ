local _ENV = (getgenv or getrenv or getfenv)()

local Owner = "natoppo044"
local Repository = GG

local IMPORTANT_TAGS = {
    "WorldChest", "SealedEgg", 'BerryBushStreamed', "MapEnvironmentTween", "EasterFullMoonEgg"
}

local function fetch(file)
    local URL = string.format(
        "https://raw.githubusercontent.com/%s/%s/main/%s",
        Owner, Repository, file
    )
    local ok, res = pcall(function()
        return game:HttpGet(URL)
    end)
    if not ok or type(res) ~= "string" or #res == 0 then
        warn("Fetch failed", URL)
        return function()
            return {}
        end
    end
    local ok2, fn = pcall(loadstring, res)
    if not ok2 or type(fn) ~= "function" then
        warn("Loadstring failed", URL)
        return function()
            return {}
        end
    end
    return fn()
end

local Installer = fetch("Utils/Module.luau")

local Configurations = Installer.Configurations
local Connections = Installer.Connections
local Parallels = Installer.Parallels
local Settings = Installer.Settings
local Library = Installer.Library
local Plugins = Installer.Plugins

local NewOption = Parallels.NewOption
local Connect = Connections.Connect

local Default = (function( ... )
    Configurations:Default( ... )
end)

local Module = fetch("Utils/GameModule.luau")({
    Configurations = Configurations,
    Connect = Connect,
    Settings = Settings
})

local EnemiesModule = Module.EnemiesModule
local InventoryModule = Module.Inventory
local WorkspaceModule = Module.Workspace
local CombatModule = Module.Combat
local BossesModule = Module.Bosses
local AimbotModule = Module.Aimbot
local QuestModule = Module.Quest
local OceanModule = Module.Ocean
local SkillModule = Module.Skill
local DataModule = Module.Data

local BodyVelocity = Module.BodyVelocity
local Colors = Module.Colors

local SPAWNED = Colors("Spawned",   Color3.fromRGB(0, 255, 127))
local DESPAWNED = Colors("Despawned", Color3.fromRGB(255, 0, 0))

local function AddModule(Name, Insert)
    do Module[Name] = Insert()
        return Module[Name] 
    end
end

local VirtualInputManager = game:GetService("VirtualInputManager")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService('UserInputService')
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local Lighting = game:GetService('Lighting')
local Players = game:GetService("Players")

local Remotes: Folder = ReplicatedStorage:WaitForChild("Remotes")
local Modules: Folder = ReplicatedStorage:WaitForChild("Modules")

local CommF: RemoteFunction = Remotes:WaitForChild("CommF_")
local CommE: RemoteEvent = Remotes:WaitForChild("CommE")

local Net: ModuleScript = Modules:WaitForChild("Net")

local SubmarineWorkerSpeak: RemoteFunction = Net:WaitForChild('RF/SubmarineWorkerSpeak')

local ChestModels: Folder = workspace:WaitForChild("ChestModels")
local WorldOrigin: Folder = workspace:WaitForChild("_WorldOrigin")
local Characters: Folder = workspace:WaitForChild("Characters")
local SeaBeasts: Folder = workspace:WaitForChild("SeaBeasts")
local Enemies: Folder = workspace:WaitForChild("Enemies")
local Boats: Folder = workspace:WaitForChild("Boats")
local Map: Folder = workspace:WaitForChild("Map")

local NPCs: Folder = workspace:WaitForChild('NPCs')
local ReplicatedNPCs: Folder = ReplicatedStorage:WaitForChild('NPCs')

local EnemySpawns: Folder = WorldOrigin:WaitForChild("EnemySpawns")
local Locations: Folder = WorldOrigin:WaitForChild("Locations")

local RenderStepped = RunService.RenderStepped
local Heartbeat = RunService.Heartbeat
local Stepped = RunService.Stepped

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local PlayerScripts = LocalPlayer.PlayerScripts
local Backpack = LocalPlayer.Backpack

local Data: Folder = LocalPlayer:WaitForChild("Data")

local Fragments: IntValue = Data:WaitForChild("Fragments")
local Level: IntValue = Data:WaitForChild("Level")
local Money: IntValue = Data:WaitForChild("Beli")

local Character: Model = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid: Humanoid = Character and Character:WaitForChild('Humanoid', 10)
local HumanoidRootPart: Part = Character and Character:WaitForChild('HumanoidRootPart', 10)
local Head: Part = Character and Character:WaitForChild('Head', 10)

local Executor = string.upper(if identifyexecutor then identifyexecutor() else "NULL")

local fireproximityprompt = fireproximityprompt or function( ... ) return ... end
local fireclickdetector = fireclickdetector or function( ... ) return ... end
local firetouchinterest = firetouchinterest or function( ... ) return ... end

do
    if Executor == "XENO" then
        local Warn = Instance.new("Message") do
            Warn.Parent = workspace
            Warn.Text = "Warning : Antigravity Model has been Dectect [ Xeno ]\nMost options will not working."

            delay(10, function()
                Warn:Destroy()
            end)
        end
    end
end

do Connect(LocalPlayer.CharacterAdded, function(v)
        Character = v
        Head = v:WaitForChild('Head', 10)
        Humanoid = v:WaitForChild("Humanoid", 10)
        HumanoidRootPart = v:WaitForChild("HumanoidRootPart", 10)
        Backpack = LocalPlayer.Backpack

        warn("Spawn", Character, Humanoid, HumanoidRootPart, Backpack)
    end)

    Connect(LocalPlayer.Idled, function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

local function IsAlive()
    if not Character then return end

    if not Humanoid then return end

    if not HumanoidRootPart then return end

    if not Head then return end

    if not Backpack then return end

    return (Humanoid and Humanoid.Health > 0) or HumanoidRootPart ~= nil
end

local function ValidData(filter, enemy)
    if filter == nil then return true end

    if type(filter) == "table" then
        return table.find(filter, enemy.Name) ~= nil
    end

    if type(filter) == "string" then
        return enemy.Name == filter
    end

    return false
end

local Teleport do  
    AddModule("Tween", function()
        local TweenCreator = Module.TweenCreator
        local BodyVelocity = Module.BodyVelocity

        local function TweenStopped()
            if not BodyVelocity.Parent and IsAlive() then
                TweenCreator:stopTween(Character:FindFirstChild("HumanoidRootPart"))
            end

            if _ENV.StopShip then pcall(_ENV.StopShip) end
        end

        local function Entrance(Target)
            local Position = Target.Position
            local Position_Magnitude = Module:Distance(Position)

            local Distance = math.huge
            local Nearest = nil

            for _, v in ipairs(Module.GateList[Module.Sea]) do
                local Magnitude = (v - Position).Magnitude

                if Magnitude < Position_Magnitude and Magnitude > 30 and Magnitude < Distance then
                    Distance = Magnitude
                    Nearest = v
                end
            end

            return Nearest
        end

        local LastCFrame = nil
        local LastTeleport = 0

        local LastRequestedGate = nil
        local LastRequestTime = 0

        local GATE_REQUEST_COOLDOWN = 5

        local function floor(Position)
            return math.floor(Position.Position.X), math.floor(Position.Position.Y), math.floor(Position.Position.Z)
        end

        Teleport = function(TargetCFrame, CanSit)
            if not IsAlive() then
                return false
            elseif (tick() - LastTeleport) <= 1 and LastCFrame == CFrame.new(floor(TargetCFrame)) then
                return false
            end

            if not CanSit then
                if Humanoid.Sit then Humanoid.Sit = false return end
            end

            local PrimaryPart = Character.PrimaryPart
            local Distance = Module:Distance(TargetCFrame)
            local HrpPos = HumanoidRootPart.Position
            local Floor = CFrame.new(floor(TargetCFrame))
            local TargetY = Floor.Position.Y

            LastTeleport = tick()
            LastCFrame = Floor

            _ENV.OnFarm = true

            if Settings['Dodge Position'] and Distance < 250 then
                PrimaryPart.CFrame = CFrame.new(HrpPos.X, TargetY, HrpPos.Z)

                return TweenCreator.new(PrimaryPart, 0.1, "CFrame", Floor)
            end

            local Entrance = Entrance(Floor)

            if Entrance and Module:IsPortal() then
                local CurrentTime = tick()

                local IsSameGate = LastRequestedGate and (Entrance - LastRequestedGate).Magnitude < 5
                local IsOnCooldown = (CurrentTime - LastRequestTime) < GATE_REQUEST_COOLDOWN

                if IsSameGate and IsOnCooldown then
                    PrimaryPart.CFrame = CFrame.new(HrpPos.X, TargetY, HrpPos.Z)

                    return TweenCreator.new(PrimaryPart, Distance / 250, "CFrame", Floor)
                end

                TweenCreator:stopTween(PrimaryPart)

                LastRequestedGate = Entrance
                LastRequestTime = CurrentTime

                task.wait(1.25)

                Module:ComF("requestEntrance", Entrance)

                return task.wait(1.25)
            end

            PrimaryPart.CFrame = CFrame.new(HrpPos.X, TargetY, HrpPos.Z)
            TweenCreator.new(PrimaryPart, Distance / 250, "CFrame", Floor)
        end

        Connect(BodyVelocity:GetPropertyChangedSignal("Parent"), TweenStopped)

        return Teleport
    end)
end

local function Distance(v)
    return Module:Distance(v)
end

local function WaitForEnemies(a, b)
    return Module:WaitForEnemy(a, b, Teleport)
end

local function CheckCakePrinceSkill()
    for _, v in WorldOrigin:GetChildren() do
        if v.Name == "Ring" or v.Name == "Fist" then
            if Distance(v.Position) <= 400 then
                return true
            end
        end
    end
end

local function Kills(Mobs, IsSuperBring, Break, Tools)
    if not IsAlive() or not Module:IsAlive(Mobs) then return end

    local Brought = false

    repeat
        Heartbeat:Wait()
        Module:Equip(Tools or Settings['Select Weapon'] or "Melee", true)

        if Character and not Character:FindFirstChild('HasBuso') then
            Module:ComF('Buso')
        end

        local BasePart = Mobs and Mobs:FindFirstChild('HumanoidRootPart')
        local Current = BasePart.CFrame + Vector3.new(0, 25, 0)

        if Distance(Current) > 3 then
            Teleport(Current)
        end

        if Distance(Current) <= 10 and not Brought then
            Module:BringEnemies(Mobs, IsSuperBring)
            Brought = true
        end
    until not _ENV.OnFarm or (Break and Break()) or not Module:IsAlive(Mobs) or not IsAlive()

    Brought = false
end

local Text, Functions = {}, (function()
    local Cached = {}

    _ENV.OPENSTOCK = (function()
        if Executor == "XENO" then
            return function(Advanced)
                return warn("Cant not require ModuleScript")
            end
        end

        local Success, FruitShop = pcall(require, ReplicatedStorage.Controllers.UI.FruitShop)

        if not Success or type(FruitShop) ~= "table" then
            return function(Advanced)
                return warn("Cant not require ModuleScript")
            end
        end

        return function(Advanced)
            if FruitShop then
                if Advanced then
                    FruitShop.Open(FruitShop, "AdvancedFruitDealer")
                else
                    FruitShop.Open(FruitShop)
                end
            end
        end
    end)()

    function FormatCommas(number)
        if typeof(number) == 'string' then return number end

        local formattedNumber = tostring(number)
        local left, num, right = string.match(formattedNumber, '^([^%d]*%d)(%d*)(.-)$')

        num = num:reverse():gsub('(%d%d%d)', '%1,'):reverse()
        num = num:gsub('^,', '')

        return left .. num .. right
    end

    local function MatchString(str, str2)
        local s = tostring(str)

        if typeof(str2) == "string" then
            return string.find(s, str2) ~= nil
        end

        for _, v in pairs(str2) do
            if string.find(s, v) then
                return true
            end
        end

        return false
    end

    do
        Cached.AcceptLevelQuest = function(Quest)
            if Distance(Quest.Position) <= 15 then
                task.wait(1)
                Module:ComF("StartQuest", Quest.Quest, Quest.Level)

                return true
            end

            Teleport(Quest.Position)

            return true
        end

        Cached.KillTyrantSkies = function(Break)
            if workspace:FindFirstChild('TikiOutpost') then
                Teleport(CFrame.new(-16326, 292, 1394))

                return true
            end

            local Model = Map:FindFirstChild("TikiOutpost")
            if not Model then return end

            local Inside = Model:FindFirstChild("E", true)
            if not Inside then return end

            if Inside.Eye4.Transparency ~= 0 then
                local Enemy = EnemiesModule:GetClosestByTag('TyrantSkies')

                if not Enemy then
                    WaitForEnemies({
                        "Sun-kissed Warrior",
                        "Skull Slayer",
                        "Isle Champion",
                        "Serpent Hunter"
                    }, function()
                        return (Break and Break()) or Inside.Eye4.Transparency == 0
                    end)

                    return true
                end

                Kills(Enemy, false, function()
                    return (Break and Break()) or Inside.Eye4.Transparency == 0
                end)

                return true
            end

            local Boss = EnemiesModule:GetClosestByTag("Tyrant of the Skies")

            if not Boss then
                local Tree = WorkspaceModule:Tree()

                if Distance(Tree:GetPivot()) <= 10 then
                    AimbotModule:SetTarget(Tree:GetPivot())
                    SkillModule:Use()

                    return true
                end

                Teleport(Tree:GetPivot())

                return true
            end

            Kills(Boss, false, function()
                return (Break and Break())
            end)

            return true
        end

        Cached.UnlockSubmergIsland = function(Break)
            local SubmarineQuest = SubmarineWorkerSpeak:InvokeServer("AskKilledTikiBoss")

            if not SubmarineQuest then
                return Cached.KillTyrantSkies(function()
                    return (Break and Break()) or SubmarineQuest
                end)
            end

            if Distance(CFrame.new(-16266, 25, 1372)) < 10 then
                SubmarineWorkerSpeak:InvokeServer("TravelToSubmergedIsland")

                return true
            end

            Teleport(CFrame.new(-16266, 25, 1372))

            return true
        end

        Cached.FarmLevel = function(Break)
            if Module.Sea == 3 and Level.Value >= 2600 and Distance(Vector3.new(11534, -2155, 9830)) > 5000 then
                return Cached.UnlockSubmergIsland(Break)
            end

            local Quest = QuestModule:GetQuest(Level)
            if not Quest then return true end

            local QuestFrame = PlayerGui.Main.Quest
            local OnQuest = QuestFrame.Visible
            local QuestTitle = QuestFrame.Container.QuestTitle.Title.Text
            local IsValidQuest = MatchString(QuestTitle, Quest.Monster)

            if OnQuest and not IsValidQuest then
                Module:ComF("AbandonQuest")
                task.wait(1)

                return true
            end

            if not OnQuest then
                return Cached.AcceptLevelQuest(Quest)
            end

            local Enemy = EnemiesModule:GetClosestByTag(Quest.Monster)

            if not Enemy then
                WaitForEnemies(Quest.Monster, function()
                    return (Break and Break()) or not QuestFrame.Visible or not MatchString(QuestFrame.Container.QuestTitle.Title.Text, Quest.Monster)
                end)

                return true
            end

            Kills(Enemy, false, function()
                return (Break and Break()) or not OnQuest or not QuestFrame.Visible or not MatchString(QuestFrame.Container.QuestTitle.Title.Text, Quest.Monster)
            end)

            return true
        end

        Cached.CollectGift = function()
            local Countdown = workspace:FindFirstChild('Countdown')
            if not Countdown then return end

            local Time = Countdown:FindFirstChild('TextLabel', true)
            if not Time then return end

            local totalSeconds = WorkspaceModule:ParseTime(Time.Text)

            if totalSeconds > 60 then return end

            local Gift = WorkspaceModule:GetGift()

            if not Gift then
                Teleport(Countdown.CFrame)

                return true
            end

            Teleport(Gift:GetPivot())

            local Promp = Gift:FindFirstChild('ProximityPrompt', true)

            if Promp then
                fireproximityprompt(Promp)
            end

            return true
        end

        Cached.IsOnWater = function(Part)
            local Water = Map:FindFirstChild("WaterBase-Plane")

            if not Water or not Part then return false end

            local partPos = Part.Position
            local waterPos = Water.Position
            local waterSize = Water.Size

            local halfX = waterSize.X / 2
            local halfZ = waterSize.Z / 2

            local inX = partPos.X >= (waterPos.X - halfX) and partPos.X <= (waterPos.X + halfX)
            local inZ = partPos.Z >= (waterPos.Z - halfZ) and partPos.Z <= (waterPos.Z + halfZ)
            local inY = partPos.Y <= waterPos.Y + 2

            return inX and inZ and inY
        end

        Cached.CollectBloxFruits = function()
            for _, v in pairs(workspace:GetChildren()) do
                if string.find(v.Name, "Fruit") and not Cached.IsOnWater(v.Handle.CFrame) then
                    Teleport(v.Handle.CFrame + Vector3.new(0, 2, 0))
                    return true
                end
            end
        end

        Cached.UnStoreBloxFruits = function(Type)
            if not IsAlive() then return end
            if InventoryModule:HaveFruit() then return end

            InventoryModule:UnStore(Type or 'Lower')
        end

        Cached.CollectChest = function()
            local Chest = WorkspaceModule:Chest()
            if not Chest then return end

            if Distance(Chest:GetPivot()) <= 3 then
                Module:Equip("Melee", true)
                task.wait(0.1)
                Humanoid:UnequipTools()
            end

            Teleport(Chest:GetPivot())

            return true
        end

        Cached.CollectBerry = function()
            local Berry = WorkspaceModule:Berry()
            if not Berry then return end

            if Distance(Berry.Parent:GetPivot()) >= 100 then
                Teleport(Berry.Parent:GetPivot())

                return true
            end

            for _, v in pairs(Berry:GetDescendants()) do
                if v:IsA('ProximityPrompt') then
                    Teleport(v.Parent:GetPivot())

                    if Distance(v.Parent:GetPivot()) <= 10 then
                        fireproximityprompt(v)
                    end
                end
            end

            return true
        end

        Cached.ClearPirateRaid = function(Break)
            local Enemy = EnemiesModule:GetClosestByTag('PirateRaid')

            if not Enemy then return end

            if Distance(CFrame.new(-5128, 314, -2957)) > 1000 then
                Teleport(CFrame.new(-5128, 314, -2957))
                return true
            end

            Kills(Enemy, false, function()
                return (Break and Break())
            end)

            return true
        end

        Cached.KillElite = function(Break)
            local Elite = EnemiesModule:GetClosestByTag('Elite')
            if not Elite then return end

            local QuestFrame = PlayerGui.Main.Quest
            local OnQuest = QuestFrame.Visible
            local QuestTitle = QuestFrame.Container.QuestTitle.Title.Text
            local IsValidQuest = MatchString(QuestTitle, {
                "Deandre", "Diablo", "Urban"
            })

            if OnQuest and not IsValidQuest then
                Module:ComF("AbandonQuest")
                task.wait(1)
                return true
            end

            if not OnQuest then
                if Distance(CFrame.new(-5418, 313, -2826)) <= 15 then
                    task.wait(1)
                    Module:ComF("EliteHunter")
                    return true
                end

                Teleport(CFrame.new(-5418, 313, -2826))
                return true
            end

            Kills(Elite, false, function()
                return (Break and Break()) or not OnQuest
            end)

            return true
        end

        Cached.FarmBone = function(Break, Tool)
            local Boss = EnemiesModule:GetClosestByTag('Soul Reaper')

            if Boss then
                Kills(Boss, false, function()
                    return (Break and Break())
                end, Tool)

                return true
            end

            local Enemy = EnemiesModule:GetClosestByTag('Bones')

            if not Enemy then
                WaitForEnemies({
                    "Reborn Skeleton",
                    "Living Zombie",
                    "Demonic Soul",
                    "Posessed Mummy"
                }, function()
                    return (Break and Break()) or EnemiesModule:GetClosestByTag('Soul Reaper')
                end)

                return true
            end

            Kills(Enemy, false, function()
                return (Break and Break()) or EnemiesModule:GetClosestByTag('Soul Reaper')
            end, Tool)

            return true
        end

        Cached.FarmNearest = function(Distance, Break)
            local Enemy = EnemiesModule:GetEnemies(Distance)
            if not Enemy then return end

            Kills(Enemy, false, function()
                return (Break and Break())
            end)

            return true
        end

        Cached.InstantKill = function(Distance)
            local Enemy = EnemiesModule:GetEnemies(Distance)
            if not Enemy then return end

            Enemy:AddTag(_ENV._KillAura_Tag)
        end

        Cached.ThirdSea = function(Break)
            if Level.Value < 1500 then return end

            local Quest = Module:ComF("BartiloQuestProgress","Bartilo")

            if Quest == 3 then
                if Module:ComF("GetUnlockables").FlamingoAccess ~= nil then		
                    if Module:ComF("ZQuestProgress","Check") == 0 then
                        local Enemy = EnemiesModule:GetClosestByTag('rip_indra')
                        if not Enemy then return end

                        Module:ComF("ZQuestProgress","Begin")
                        Module:TravelTo(3)

                        Kills(Enemy, false, function()
                            return (Break and Break())
                        end)

                        return true
                    end

                    local Enemy = EnemiesModule:GetClosestByTag('Don Swan')
                    if not Enemy then return end

                    Kills(Enemy, false, function()
                        return (Break and Break())
                    end)

                    return true
                end

                Cached.UnStoreBloxFruits('High')

                return false
            end

            if Quest == 2 then
                if Distance(CFrame.new(-1830, 10, 1680)) > 50 then
                    Teleport(CFrame.new(-1830, 10, 1680))

                    return true
                end

                local BartiloPlates = Map.Dressrosa.BartiloPlates

                for i = 1, 8 do
                    HumanoidRootPart.CFrame = BartiloPlates['Plate' .. i].CFrame
                    task.wait(0.5)
                end

                return true
            end

            if Quest == 1 then
                local Jeremy = EnemiesModule:GetClosestByTag('Jeremy')
                if not Jeremy then return end

                Kills(Jeremy, false, function()
                    return (Break and Break())
                end)

                return true
            end

            if Quest == 0 then
                local QuestFrame = PlayerGui.Main.Quest
                local OnQuest = QuestFrame.Visible
                local QuestTitle = QuestFrame.Container.QuestTitle.Title.Text
                local IsValidQuest = MatchString(QuestTitle, 'Swan Pirate')

                if OnQuest and not IsValidQuest then
                    Module:ComF("AbandonQuest")
                    task.wait(1)

                    return true
                end

                if not OnQuest then
                    return Cached.AcceptLevelQuest({
                        Position = CFrame.new(-461, 72, 300),
                        Quest = "BartiloQuest",
                        Level = 1
                    })
                end

                local Enemy = EnemiesModule:GetClosestByTag('Swan Pirate')

                if not Enemy then
                    WaitForEnemies('Swan Pirate', function()
                        return (Break and Break())
                    end)

                    return true
                end

                Kills(Enemy, false, function()
                    return (Break and Break())
                end)

                return true
            end
        end

        Cached.SecondSea = function(Break)
            if Level.Value <= 700 then return end

            if Module:ComF("DressrosaQuestProgress", "Dressrosa") == 0 then
                Module:TravelTo(2)
                return true
            end

            if not Module:HaveItem("Key") then
                if Distance(CFrame.new(4852, 5, 718)) < 5 then
                    Module:ComF("DressrosaQuestProgress", "Detective")

                    return true
                end

                Teleport(CFrame.new(4852, 5, 718))

                return true
            end

            if not Map.Ice.Door.CanCollide then
                Teleport(CFrame.new(1345, 37, -1327))

                Module:Equip('Key', false)

                return true
            end

            local Enemy = EnemiesModule:GetClosestByTag('Ice Admiral')
            if not Enemy then return end

            Kills(Enemy, false, function()
                return (Break and Break())
            end)

            return true
        end

        Cached.KillBoss = function(Boss, Break)
            local Enemy = EnemiesModule:GetClosest(Boss)
            if not Enemy then return end

            Kills(Enemy, false, function()
                return (Break and Break())
            end)

            return true
        end

        Cached.SpawnDarkbeard = function()
            if not Module:HaveItem('Fist of Darkness') then
                return Cached.CollectChest()
            end

            Teleport(CFrame.new(3783, 15, -3500))

            if Distance(CFrame.new(3783, 15, -3500)) < 10 then
                Module:Equip('Fist of Darkness', false)
            end

            return true
        end

        Cached.KillDarkbeard = function(Break)
            local Darkbeard = EnemiesModule:GetClosestByTag('Darkbeard')

            if Darkbeard then
                Kills(Darkbeard, false, function()
                    return (Break and Break())
                end)

                return true
            end

            return Cached.SpawnDarkbeard()
        end

        Cached.FindGodChalice = function(Break)
            if not EnemiesModule:GetClosestByTag('Elite') then
                return Cached.CollectChest()
            end

            return Cached.KillElite(Break)
        end

        Cached.SpawnIndra = function(Break)
            if not Module:HaveItem("God's Chalice") then
                return Cached.FindGodChalice(Break)
            end

            if workspace:FindFirstChild('Boat Castle') then
                Teleport(CFrame.new(-5086, 315, -2974))
                return true
            end

            local BoatCastle = Map:FindFirstChild('Boat Castle')
            local Circle = BoatCastle and BoatCastle:FindFirstChild('Circle', true)

            if not Circle then return true end

            local ColorsPart = WorkspaceModule:GetPartColors(Circle)

            if not ColorsPart then
                local Detection = BoatCastle.Summoner.Detection.CFrame

                if Distance(Detection) > 5 then
                    Teleport(Detection)
                    return true
                end

                Module:Equip("God's Chalice", false)

                return true
            end

            local Haki = WorkspaceModule:CalculateColors(ColorsPart)
            if not Haki then return end

            Net['RF/FruitCustomizerRF']:InvokeServer({
                {
                    StorageName = Haki,
                    Type = "AuraSkin",
                    Context = "Equip"
                }
            })

            task.wait(0.5)
            firetouchinterest(HumanoidRootPart, ColorsPart, 0)
            firetouchinterest(HumanoidRootPart, ColorsPart, 1)
            task.wait(0.5)

            return true
        end

        Cached.KillIndra = function(Break)
            local Enemy = EnemiesModule:GetClosestByTag('rip_indra True Form')

            if not Enemy then
                return Cached.SpawnIndra(Break)
            end

            Kills(Enemy, false, function()
                return (Break and Break())
            end)

            return true
        end

        Cached.FarmMaterial = function(name, Break)
            local EnemiesList = DataModule:GetMaterail(name)
            if not EnemiesList then return end

            local Enemy = EnemiesModule:GetClosest(EnemiesList)

            if not Enemy then
                WaitForEnemies(EnemiesList, function()
                    return (Break and Break())
                end)

                return true
            end

            Kills(Enemy, false, function()
                return (Break and Break())
            end)

            return true
        end

        Cached.FindSweetChalice = function(Break)
            if Module:HaveItem("God's Chalice") then
                if InventoryModule:Counts('Conjured Cocoa') >= 10 then
                    Module:Equip("God's Chalice", false)
                    Module:ComF("SweetChaliceNpc")
                    return true
                end 

                return Cached.FarmMaterial('Conjured Cocoa', function()
                    return (Break and Break()) or InventoryModule:Counts('Conjured Cocoa') >= 10
                end)
            end

            return Cached.FindGodChalice(Break)
        end

        Cached.CakePince500Enemies = function(Break)
            local Enemy = EnemiesModule:GetClosestByTag('CakePrince')

            if not Enemy then
                WaitForEnemies({
                    "Head Baker",
                    "Baking Staff",
                    "Cake Guard",
                    "Cookie Crafter"
                }, function()
                    return (Break and Break())
                end)

                return true
            end

            Kills(Enemy, false, function()
                return (Break and Break())
            end)

            return true
        end

        Cached.SpawnCakePrince = function(IsDoughKing, Break)
            if IsDoughKing and not Module:HaveItem("Sweet Chalice") then
                return Cached.FindSweetChalice(Break)
            end

            Module:ComF("CakePrinceSpawner", true)

            return Cached.CakePince500Enemies(function()
                return (Break and Break()) or string.find("have defeated", Module:ComF("CakePrinceSpawner"))
            end)
        end

        Cached.FullCakePrince = function(IsDoughKing, Break)
            local Boss = EnemiesModule:GetClosest({
                "Cake Prince", "Dough King"
            })

            if not Boss then
                return Cached.SpawnCakePrince(IsDoughKing, function()
                    return (Break and Break()) or Boss
                end)
            end

            Kills(Boss, false, function()
                return (Break and Break())
            end)

            return true
        end

        Cached.FarmEctoplasm = function(Break)
            local Enemy = EnemiesModule:GetClosest({
                'Ship Steward',
                'Ship Officer',
                'Ship Engineer',
                'Ship Deckhand',
            })

            if not Enemy then
                WaitForEnemies({
                    'Ship Steward',
                    'Ship Officer',
                    'Ship Engineer',
                    'Ship Deckhand',
                }, function()
                    return (Break and Break())
                end)

                return true
            end

            Kills(Enemy, false, function()
                return (Break and Break())
            end)

            return true
        end

        Cached.DestroyFactory = function(Break)
            local Core = Enemies:FindFirstChild('Core')

            if not Core then
                local StorageCore = ReplicatedStorage:FindFirstChild('Core')
                if not StorageCore then return end
                if not Module:IsAlive(StorageCore) then return end

                Teleport(CFrame.new(428, 212, -430))

                return true
            end

            Kills(Core, false, function()
                return (Break and Break())
            end)

            return true
        end

        Cached.KillLaw = function(Break)
            local Order = EnemiesModule:GetClosestByTag('Order')

            if Order then
                Kills(Order, false, function()
                    return (Break and Break())
                end)

                return true
            end

            if not Module:HaveItem("Microchip") then
                Module:ComF("BlackbeardReward", "Microchip", "2") 
                task.wait(1)

                return true
            end

            fireclickdetector(Map.CircleIsland.RaidSummon.Button.Main.ClickDetector)
            task.wait(1)

            return true
        end

        Cached.FullRaid = function(Break, Target)
            local RaidIsland = WorkspaceModule:Raid()

            if PlayerGui.Main.TopHUDList.RaidTimer.Visible and LocalPlayer:GetAttribute("IslandRaiding") then
                local Enemy = EnemiesModule:GetEnemies(3500)

                if not Enemy then
                    Teleport(RaidIsland.CFrame + Vector3.new(0, 50, 0))

                    return true
                end

                Kills(Enemy, false, function()
                    return (Break and Break())
                end)

                return true
            end

            if Module:HaveItem('Special Microchip') then
                if not RaidIsland and not LocalPlayer:GetAttribute("IslandRaiding") then

                    if Module.Sea == 2 then
                        if Map:FindFirstChild('CircleIsland') then
                            task.wait(2.5)
                            fireclickdetector(Map.CircleIsland.RaidSummon2.Button.Main.ClickDetector)

                            return true
                        end

                        Teleport(CFrame.new(-6462, 250, -4518))

                        return true
                    end

                    if Map:FindFirstChild('Boat Castle') then
                        task.wait(2.5)
                        fireclickdetector(Map["Boat Castle"].RaidSummon2.Button.Main.ClickDetector)

                        return true
                    end

                    Teleport(CFrame.new(-5016, 315, -2828))

                    return true
                end

                task.wait(1)

                return true
            end

            Module:ComF("RaidsNpc", "Select", Target)
        end

        do
            local Attacks = {
                "ChargeModel","BiteModel"
            }

            local function ShouldAbort(Mobs, Break, IsOcean)
                local AliveCheck = IsOcean and OceanModule or Module
                return not IsAlive() or not AliveCheck:IsAlive(Mobs) or (Break and Break()) or not _ENV.OnFarm
            end

            Cached.IsTerrorAttack = function(Terror)
                if not Terror then return nil end

                local nearest = nil
                local nearestDist = math.huge
                local terrorPos = Terror:GetPivot().Position

                for _, name in ipairs(Attacks) do
                    local obj = WorldOrigin:FindFirstChild(name)

                    if obj then
                        local dist = (obj:GetPivot().Position - terrorPos).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                            nearest = obj
                        end
                    end
                end

                return nearest
            end

            Cached.ClearTerrorShark = function(Mobs, Break)
                if not IsAlive() or not Module:IsAlive(Mobs) then
                    return
                end

                local MaxHP = Humanoid.MaxHealth
                local AboveOffset  = Vector3.new(0, 40, 0)
                local EscapeOffset = Vector3.new(0, 220, 0)

                repeat
                    Heartbeat:Wait()

                    local Ratio = Humanoid.Health / MaxHP

                    if Ratio <= 0.3 or Cached.IsTerrorAttack(Mobs) then
                        SkillModule:Use()
                        return Teleport(Mobs:GetPivot() + EscapeOffset)
                    end

                    if Ratio <= 0.35 then return end

                    Module:Equip(Settings['Select Weapon'], true)

                    if not Character:FindFirstChild('HasBuso') then
                        Module:ComF('Buso')
                    end

                    AimbotModule:SetTarget(HumanoidRootPart.CFrame - Vector3.new(0, 40, 0))
                    Teleport(Mobs:GetPivot() + AboveOffset)
                until ShouldAbort(Mobs, Break, false) or not IsAlive()
            end

            Cached.ClearSeaBeast = function(Mobs, Break)
                if not IsAlive() or not OceanModule:IsAlive(Mobs) then
                    return
                end

                repeat
                    Heartbeat:Wait()

                    local RootPart = Mobs:FindFirstChild("HumanoidRootPart")
                    if not RootPart then break end

                    if RootPart.Position.Y ~= -179 then return end

                    local Attack = RootPart.CFrame * CFrame.new(0, 450, 50)

                    AimbotModule:SetTarget(RootPart.CFrame)

                    Teleport(Attack)

                    if Distance(Attack) < 20 then SkillModule:Use() end
                until ShouldAbort(Mobs, Break, true) or not IsAlive()
            end

            Cached.ClearShip = function(Mobs, Z, Break)
                if not IsAlive() or not OceanModule:IsAlive(Mobs) then return end

                repeat
                    Heartbeat:Wait()

                    if Character and not Character:FindFirstChild('HasBuso') then
                        Module:ComF('Buso')
                    end

                    local Engine = Mobs:FindFirstChild('Engine', true)
                    local VehicleSeat = Mobs:FindFirstChild('VehicleSeat', true)

                    if not Engine or not VehicleSeat then return end

                    local AttackPos = Engine.CFrame + Vector3.new(0, 0, Z or 40)

                    Teleport(AttackPos)
                    AimbotModule:SetTarget(VehicleSeat.Position)

                    if Distance(AttackPos) < 20 then SkillModule:Use() end
                until ShouldAbort(Mobs, Break, true) or not IsAlive()
            end



            Cached.GetEnemies = function(Max)
                return {
                    {
                        name = 'Piranha',
                        getData = function()
                            return EnemiesModule:GetEnemies(Max, 'Piranha')
                        end,
                        attack = function(target, breakFn) 
                            return Kills(target, false, breakFn) 
                        end
                    },
                    {
                        name = 'Terrorshark',
                        getData = function()
                            return EnemiesModule:GetEnemies(Max, 'Terrorshark')
                        end,
                        attack = function(target, breakFn) 
                            return Cached.ClearTerrorShark(target, breakFn) 
                        end
                    },
                    {
                        name = 'Shark',
                        getData = function()
                            return EnemiesModule:GetEnemies(Max, 'Shark')
                        end,
                        attack = function(target, breakFn) 
                            return Kills(target, false, breakFn) 
                        end
                    },
                    {
                        name = 'Fish Crew Member',
                        getData = function()
                            return EnemiesModule:GetEnemies(Max, 'Fish Crew Member')
                        end,
                        attack = function(target, breakFn) 
                            return Kills(target, false, breakFn) 
                        end
                    },
                    {
                        name = 'Pirate Ship',
                        getData = function() 
                            return OceanModule:GetEnemiesShip({"PirateGrandBrigade", "PirateBrigade"})
                        end,
                        attack = function(target, breakFn) 
                            return Cached.ClearShip(target, 40, breakFn) 
                        end
                    },
                    {
                        name = 'Ghost Ship',
                        getData = function()
                            return OceanModule:GetEnemiesShip({"FishBoat", "GhostShip"})
                        end,
                        attack = function(target, breakFn) 
                            return Cached.ClearShip(target, 40, breakFn)
                        end
                    },
                    {
                        name = 'Sea Beast',
                        getData = function()
                            print(typeof(OceanModule:Seabeast()))
                            return OceanModule:Seabeast()
                        end,
                        attack = function(target, breakFn) 
                            return Cached.ClearSeaBeast(target, breakFn)
                        end
                    }
                }
            end

            local Buy = Vector3.new(-16928, 9, 437)
            Cached.BuyNewShip = function()
                if _ENV.StopShip then pcall(_ENV.StopShip) end

                if Distance(Buy) > 15 then
                    Teleport(CFrame.new(Buy))
                    return true
                end

                Module:ComF("BuyBoat", Settings['Select Ship'] or 'PirateGrandBrigade')

                task.wait(1)

                return true
            end

            Cached.Drive = function()
                if not IsAlive() then return true end

                local TargetZone = OceanModule:Zone()
                local PlayerShip = OceanModule:Ship(Settings['Select Ship'])

                if not PlayerShip then return Cached.BuyNewShip() end

                local Humanoider = PlayerShip:FindFirstChild("Humanoid")
                local MaxHealth = PlayerShip:GetAttribute("MaxHealth") or 0

                if not Humanoider or MaxHealth <= 0 then return Cached.BuyNewShip() end

                local Ratio = (Humanoider.Value / MaxHealth) * 100

                if Ratio < (Settings['Ship Retreat Health'] or 30) then return Cached.BuyNewShip() end

                local VehicleSeat = PlayerShip:FindFirstChild('VehicleSeat')

                if VehicleSeat and not Humanoid.Sit then
                    if _ENV.StopShip then pcall(_ENV.StopShip) end

                    Teleport(VehicleSeat.CFrame + Vector3.new(0, 3, 0), true)

                    return true
                end

                OceanModule:RemoveBoatCollision(PlayerShip)
                OceanModule:Drive(PlayerShip, TargetZone, Settings["High Position"])

                return true
            end

            do
                Cached.AutoFindIsland = function(Island)
                    if not IsAlive() then return true end
                    if not Island then return Cached.Drive() end
                    if _ENV.StopShip then pcall(_ENV.StopShip) end

                    return true
                end

                do
                    Cached.GetMirageChest = function(Mirage)
                        local Chests = CollectionService:GetTagged("_ChestTagged")
                        local Distance, Nearest = math.huge, nil

                        for i = 1, #Chests do
                            local Chest = Chests[i]
                            local Magnitude = (Chest:GetPivot().Position - HumanoidRootPart.Position).Magnitude

                            if not Chest:IsDescendantOf(Mirage) then continue end

                            if not Chest:GetAttribute("IsDisabled") and Magnitude < Distance then
                                Distance, Nearest = Magnitude, Chest
                            end
                        end

                        return Nearest
                    end
                end

                Cached.FullMirage = function()
                    local Island = Map:FindFirstChild("MysticIsland")

                    if not Island then
                        return Cached.AutoFindIsland(Island)
                    end

                    local Chest = Cached.GetMirageChest(Island)
                    if not Chest then return end

                    if Distance(Chest:GetPivot()) <= 3 then
                        Module:Equip("Melee", true)
                        task.wait(0.1)
                        Humanoid:UnequipTools()
                    end

                    Teleport(Chest:GetPivot())

                    return true
                end

                Cached.FullVolcano = function(Break)
                    local Island = Map:FindFirstChild("PrehistoricIsland")

                    if not Island then
                        return Cached.AutoFindIsland(Island)
                    end

                    local Core = Island:FindFirstChild('Core')

                    if not Core then return end

                    if Island:FindFirstChild('TrialTeleport') then
                        local DinoBone = workspace:FindFirstChild('DinoBone')

                        if not DinoBone then
                            local DragonEgg = Core.SpawnedDragonEggs:FindFirstChild("DragonEgg")

                            if Distance(DragonEgg.Molten.CFrame) < 10 then
                                fireproximityprompt(DragonEgg.Molten.ProximityPrompt)
                            end

                            Teleport(DragonEgg.Molten.CFrame)

                            return true
                        end

                        Teleport(DinoBone.CFrame)

                        return true
                    end

                    if not Island:GetAttribute('IsMinigameActive') then
                        local ActivationPrompt = Core:FindFirstChild("ActivationPrompt", true)
                        local ProximityPrompt = ActivationPrompt and ActivationPrompt:FindFirstChild('ProximityPrompt')

                        if not ProximityPrompt then return end

                        if Distance(ActivationPrompt.CFrame) < 10 then
                            fireproximityprompt(ProximityPrompt)
                        end

                        Teleport(ActivationPrompt.CFrame)

                        return true
                    end

                    if Core:FindFirstChild("InteriorLava") then
                        for _, Instance in Island:GetDescendants() do
                            if string.find(string.lower(Instance.Name), "lava") and Instance:IsA("BasePart") then
                                Instance:Destroy()
                            end
                        end

                        Core.InteriorLava:Destroy()
                    end

                    local VolcanoRocks = Core:FindFirstChild('VolcanoRocks')

                    if not VolcanoRocks then return end

                    local Enemy = EnemiesModule:GetClosestByTag("Lava Golem")

                    if Enemy then
                        Kills(Enemy, false, function()
                            return (Break and Break())
                        end)

                        return true
                    end

                    local LavaRock = WorkspaceModule:GetLavaRocks(VolcanoRocks) 

                    if not LavaRock then return end

                    Teleport(LavaRock:GetPivot())

                    if Distance(LavaRock:GetPivot()) < 10 then
                        AimbotModule:SetTarget(LavaRock:GetPivot())
                        SkillModule:Use()
                    end

                    return true
                end

                _ENV.Shrine = nil

                Cached.FullKitsune = function()
                    local Island = Map:FindFirstChild("KitsuneIsland")

                    if not Island then
                        _ENV.Shrine = nil
                        return Cached.AutoFindIsland(Island)
                    end

                    local Active = Island:FindFirstChild('ShrineActive')

                    if not Active then
                        if not _ENV.Shrine then
                            local Descendants = Active:GetDescendants() do
                                for i = 1, #Descendants do
                                    local Object = Descendants[1]

                                    if Object.Name:find("NeonShrinePart") then
                                        _ENV.Shrine = Object
                                    end
                                end 
                            end

                            return true
                        end

                        if Distance(_ENV.Shrine.CFrame) < 10 then
                            Net:WaitForChild("RE/TouchKitsuneStatue"):FireServer()
                        end

                        Teleport(Island:GetPivot())

                        return true
                    end

                    local Ember = workspace:FindFirstChild("EmberTemplate", true)

                    if not Ember then return end

                    Teleport(Ember:FindFirstChildOfClass("Part").CFrame)

                    return true
                end
            end
        end

        do
            Cached.Yama = function(Break)
                if Module:HaveItem("Yama") then return end

                if Module:ComF("EliteHunter", "Progress") >= 30 then
                    if not workspace.Map:FindFirstChild("Waterfall") or not workspace.Map.Waterfall:FindFirstChild("SealedKatana") then
                        Teleport(CFrame.new(5250.71924, 19.842907, 453.177002))
                    else
                        if Distance(workspace.Map.Waterfall.SealedKatana.Hitbox.Position) <= 15 then
                            fireclickdetector(workspace.Map.Waterfall.SealedKatana.Hitbox.ClickDetector)
                        else
                            Teleport(workspace.Map.Waterfall.SealedKatana.Hitbox.CFrame)
                        end
                    end

                    return true
                end

                return Cached.KillElite(Break)
            end

            Cached.Tushita = function(Break)
                if Module:HaveItem('Tushita') or Level.Value < 2000 then return end

                local Progress = Module:ComF("TushitaProgress")

                if not Progress.OpenedDoor then
                    if not EnemiesModule:GetClosestByTag("rip_indra True Form") then
                        if not Module:HaveItem("Holy Torch") then
                            Teleport(CFrame.new(5717.06592, 18.8161335, 252.124573))

                            return true
                        end

                        Module:Equip("Holy Torch")

                        for Numbers = 1, 5 do
                            Module:ComF("TushitaProgress", "Torch", Numbers)
                        end

                        return true
                    end

                    return Cached.SpawnIndra(Break)
                end

                return Cached.KillBoss(Break, { "Longma" })
            end

            do -- CDK BET
                local function Progress()
                    local Scroll = { Evil = 0, Good = 0 }

                    for Quest, Value in Module:ComF("CDKQuest", "Progress", "Good") do
                        Scroll[Quest] = Value
                    end

                    return Scroll
                end

                local function GetQuest(Evil, Heaven)
                    if Evil ~= -2 and Evil ~= 3 and Evil ~= 4 then
                        if Evil == 2 or Evil == -5 then
                            return "Hell Dismension Quest"
                        elseif Evil == 1 or Evil == -4 then
                            return "Haze Quest"
                        elseif Evil == 0 or Evil == -3 then
                            return "Die Quest"
                        end
                    else
                        if Heaven == 2 or Heaven == -5 then
                            return "Heavenly Dismension Quest"
                        elseif Heaven == 1 or Heaven == -4 then
                            return "Raid Castle Quest"
                        elseif Heaven == 0 or Heaven == -3 then
                            return "Boat Quest"
                        end
                    end

                    return "None"
                end

                local function GetPedestal(Cursed, Evil, Heaven)
                    local Pedestal2 = Cursed:FindFirstChild('Pedestal2')
                    local Pedestal1 = Cursed:FindFirstChild('Pedestal1')

                    if Evil == 3 then
                        return Pedestal2
                    elseif (Heaven == 3 or Heaven == 4) and Pedestal1 and Pedestal1.ProximityPrompt.Enabled then
                        return Pedestal1
                    end
                end

                local function EnemiesHazeName()
                    local QuestHaze = LocalPlayer:FindFirstChild('QuestHaze')

                    if not QuestHaze then return end

                    local HazeEnemies = {}

                    for _, Enemies in QuestHaze:GetChildren() do
                        if Enemies.Value > 0 then
                            table.insert(HazeEnemies, Enemies)
                        end
                    end

                    return HazeEnemies
                end

                local function GetHazeEnemies()
                    local Nearest, NearestDist = nil, math.huge
                    local EnemiesList = CollectionService:GetTagged("BasicMob")

                    for i = 1, #EnemiesList do
                        local Enemy = EnemiesList[i]
                        if not Enemy:FindFirstChild("HazeESP") then continue end
                        if not Enemy.PrimaryPart then continue end

                        if Module:IsAlive(Enemy) then
                            local Magnitude = Distance(Enemy.PrimaryPart.Position)
                            if Magnitude < NearestDist then
                                NearestDist, Nearest = Magnitude, Enemy
                            end
                        end
                    end

                    return Nearest
                end

                local function IsEquipped(Name)
                    if not IsAlive() then return end
                    return Character:FindFirstChild(Name) or Backpack:FindFirstChild(Name)
                end

                local function CheckInventory(Name)
                    for _, v in next, Module:ComF("getInventory") do
                        if v.Name == Name then
                            return v
                        end
                    end
                end

                local QuestHandlers = {} do
                    QuestHandlers["Die Quest"]= function()
                        local Enemies = EnemiesModule:GetClosestByTag("Forest Pirate")

                        if Enemies then
                            Humanoid:UnequipTools()
                            Teleport(Enemies:GetPivot())
                        else
                            Teleport(CFrame.new(-13234, 520, -6800))
                        end

                        return true
                    end

                    QuestHandlers["Haze Quest"] = function(Break)
                        local Name = EnemiesHazeName()
                        local Enemies = GetHazeEnemies()

                        if not Enemies then
                            WaitForEnemies(Name, function()
                                return GetQuest() ~= "Haze Quest" or (Break and Break())
                            end)
                        else
                            Kills(Enemies, false, Break, "Sword")
                        end

                        return true
                    end

                    QuestHandlers["Hell Dismension Quest"] = function(Break)
                        local Dimension = Locations["Hell Dimension"]
                        local Hell = Map:FindFirstChild("HellDimension")

                        if Dimension and Distance(Dimension.Position) <= 2000 then
                            if Hell and Hell.Exit.BrickColor == BrickColor.new("Olivine") then
                                Teleport(Hell.Exit.CFrame)

                                return true
                            end

                            local Enemies = EnemiesModule:GetEnemies(2000)

                            if Enemies then
                                Kills(Enemies, false, Break, "Sword")
                                return true
                            end

                            if Hell then
                                for _, v in Hell:GetChildren() do
                                    if v.Name:find("Torch") and v.ProximityPrompt.Enabled then

                                        if Distance(v.Position) <= 10 then
                                            fireproximityprompt(v.ProximityPrompt)
                                        else
                                            Teleport(v.CFrame)
                                        end

                                        return true
                                    end
                                end
                            end

                            return true
                        end

                        local Reaper = EnemiesModule:GetClosestByTag("Soul Reaper")

                        if Reaper then
                            Humanoid:UnequipTools()
                            Teleport(Reaper:GetPivot())
                            return true
                        end

                        if Module:HaveItem("Hallow Essence") then
                            Module:Equip("Hallow Essence", false)
                            Teleport(CFrame.new(-8932.859375, 141.875, 6063.31298828125))

                            return true
                        end

                        Module:ComF("Bones", "Buy", 1, 1)

                        return Cached.FarmBone(Break, "Sword")
                    end

                    QuestHandlers["Boat Quest"] = function(Break)
                        for _, v in workspace:GetChildren() do
                            if v.Name ~= "Luxury Boat Dealer" or v:GetAttribute("Dit") then continue end

                            if Distance(v.Position) <= 15 then
                                v:SetAttribute("Dit", true)
                                Module:ComF("CDKQuest", "BoatQuest", NPCs:FindFirstChild("Luxury Boat Dealer"))
                                Module:ComF("CDKQuest", "BoatQuest", NPCs:FindFirstChild("Luxury Boat Dealer"), "Check")
                                task.wait(1)
                                break
                            else
                                Teleport(v.CFrame)
                                break
                            end
                        end

                        return true
                    end

                    QuestHandlers["Raid Castle Quest"] = function(Break)
                        return Cached.ClearPirateRaid(Break)
                    end

                    QuestHandlers["Heavenly Dismension Quest"] = function(Break)
                        local Dimension = Locations["Heavenly Dimension"]
                        local Heaven = workspace.Map:FindFirstChild("HeavenlyDimension")

                        if Dimension and Distance(Dimension.Position) <= 2000 then
                            if Heaven and Heaven.Exit.BrickColor == BrickColor.new("Cloudy grey") then
                                Teleport(Heaven.Exit.CFrame)
                                return true
                            end

                            local Enemies = EnemiesModule:GetEnemies(2000)

                            if Enemies then
                                Kills(Enemies, false, Break, "Sword")
                                return true
                            end

                            if Heaven then
                                for _, v in Heaven:GetChildren() do
                                    if v.Name:find("Torch") and v.ProximityPrompt.Enabled then
                                        if Distance(v.Position) <= 30 then
                                            fireproximityprompt(v.ProximityPrompt)
                                        else
                                            Teleport(v.CFrame)
                                        end

                                        return true
                                    end
                                end
                            end

                            return true
                        end

                        local Queen = EnemiesModule:GetClosestByTag("Cake Queen")

                        if not Queen then return end

                        Kills(Queen, false, Break, "Sword")
                    end
                end

                Cached.CDK = function(Break)
                    if Level.Value <= 2200 then return Cached.FarmLevel(Break) end

                    local Yama = CheckInventory("Yama")
                    local Tushita = CheckInventory("Tushita")

                    if not Yama then return Cached.Yama(Break) end
                    if not Tushita then return Cached.Tushita(Break) end

                    if Yama.Mastery < 350 then
                        if IsEquipped("Yama") then
                            return Cached.FarmBone(Break, "Sword")
                        end

                        Module:ComF("LoadItem", "Yama")

                        return true
                    end

                    if Tushita.Mastery < 350 then
                        if IsEquipped("Tushita") then
                            return Cached.FarmBone(Break, "Sword")
                        end

                        Module:ComF("LoadItem", "Tushita")

                        return true
                    end


                    local Turtle = Map:FindFirstChild('Turtle')
                    local Cursed = Turtle and Turtle:FindFirstChild('Cursed')

                    if not Cursed then
                        Teleport(CFrame.new(-12389, 601, -6548))
                        return true
                    end

                    local TheProgress = Progress()

                    local Evil = TheProgress and TheProgress.Evil
                    local Heaven = TheProgress and TheProgress.Good

                    local Pedestal = GetPedestal(Cursed, Evil, Heaven)

                    if Pedestal then
                        if Distance(Pedestal.Position) < 10 then
                            fireproximityprompt(Pedestal.ProximityPrompt)
                            return true
                        end

                        Teleport(Pedestal.CFrame)

                        return true
                    end

                    if Evil == 4 and Heaven == 4 then
                        ReplicatedStorage.DialogueController._Close:Fire()

                        if not Cursed then
                            Teleport(CFrame.new(-12389, 601, -6548))
                            return true
                        end

                        if Cursed.PlacedGem.Transparency == 0 then
                            local Enemies = EnemiesModule:GetClosestByTag("Cursed Skeleton Boss")

                            if not Enemies then
                                Teleport(CFrame.new(-12341.66796875, 603.3455810546875, -6550.6064453125))
                                return true
                            end

                            if not IsEquipped("Yama") then
                                Module:ComF("LoadItem", "Yama")
                            end

                            Kills(Enemies, false, Break, "Sword")

                            return true
                        end

                        if Distance(Cursed.Pedestal3.Position) < 10 then
                            fireproximityprompt(Cursed.Pedestal3.ProximityPrompt)
                        else
                            Teleport(Cursed.Pedestal3.CFrame)
                        end

                        return true
                    end

                    local Process = GetQuest(Evil, Heaven)

                    if Evil == -2 or Evil == 4 then
                        Module:ComF("CDKQuest", "StartTrial", "Good")
                    else
                        Module:ComF("CDKQuest", "StartTrial", "Evil")
                    end

                    if QuestHandlers[Process] then
                        return QuestHandlers[Process](Break)
                    end
                end
            end
        end

        Cached.GetEggs = function()
            for _, v in workspace:GetChildren() do
                if v:FindFirstChild('_PrimaryPart') then
                    return v
                end
            end
        end

        Cached.Egg = function()
            local Cube = Cached.GetEggs()

            if not Cube then return end

            Teleport(Cube:GetPivot())

            return true
        end
    end

    return Cached
end)()

local function NewStateLabel(Form, Name)
    Text[Name] = Plugins:RightLabel(Form, { Name, "Displays the current status.", "N/A" })
end

local function AddInventoryEvent(Form, Name, Color)
    local Right = Plugins:RightLabel(Form, { Name, "Indicates the player's current " .. Name .. ".", "None" }) do
        Connect(InventoryModule:GetInventoryChanged(Name), function(New)
            Right.Text = Colors(FormatCommas(New), Color or Color3.fromRGB(255, 255, 255))
        end)

        Right.Text = Colors(FormatCommas(InventoryModule:Counts(Name)), Color or Color3.fromRGB(255, 255, 255))
    end
end

do
    do  -- Not a Queue
        NewOption('Nearest Execution', function()
            Functions.InstantKill(300)
        end, 0.1)

        NewOption("Upgrade Stats", function()
            for _, v in pairs(Settings['Select Stats']) do
                Module:ComF("AddPoint", v, tonumber(LocalPlayer.Data.Level.Value))
            end
        end, 1)

        NewOption("Buy Awaken Skill", function()
            Module:ComF("Awakener","Check")
            Module:ComF("Awakener","Awaken")
        end, 5)

        NewOption("Unstore Fruit", function()
            Functions.UnStoreBloxFruits()
        end, 1)

        NewOption("Random Surprise", function()
            if not IsAlive() then return end

            Module:ComF("Bones", "Buy", 1, 1)
        end, 1)

        NewOption("V3", function()
            if not IsAlive() then return end

            Module:ComE("ActivateAbility")
        end, 1)

        NewOption("Random Fruit", function()
            if not IsAlive() then return end

            Module:ComF("Cousin", "Buy")
        end, 1)

        local function Store(v)
            if string.find(v.Name, "Fruit") then
                local name = v:GetAttribute("OriginalName")

                if InventoryModule:Counts(name) ~= Data.FruitCap.Value then
                    Module:ComF("StoreFruit", tostring(v:GetAttribute("OriginalName")), v)
                end
            end
        end

        NewOption("Store Fruit", function()
            if not IsAlive() then return end

            for _, v in pairs(Backpack:GetChildren()) do Store(v) end
            for _, v in pairs(Character:GetChildren()) do Store(v) end
        end, 1)

        NewOption("V4", function()
            if not IsAlive() then return end

            local RaceEnergy = Character and Character:FindFirstChild("RaceEnergy")
            local OnRace = Character and Character:FindFirstChild("RaceTransformed")

            if RaceEnergy and RaceEnergy.Value >= 1 and OnRace and not OnRace.Value then
                local Awakening = Backpack:FindFirstChild('Awakening')

                if not Awakening then return end

                Awakening.RemoteFunction:InvokeServer(true)
            end
        end, 3)

        NewOption("Look Moon", function()
            if not IsAlive() then return end

            if not Map:FindFirstChild('MysticIsland') then return end

            local Camera = workspace.CurrentCamera

            Camera.CFrame = CFrame.lookAt(Camera.CFrame.p,  Camera.CFrame.p + Lighting:GetMoonDirection() * 100)
        end, 3)

        NewOption("Haki Colors", function()
            Module:ComF("ColorsDealer", "2")
        end, 3)

        NewOption("True Tripple Katana", function()
            if Module:HaveItem("Oroshi") and Module:HaveItem("Shizu") and Module:HaveItem("Saishi") then
                return Module:ComF("MysteriousMan", "2")
            end

            if not ReplicatedNPCs:FindFirstChild('Legendary Sword Dealer') then
                return
            end

            if not NPCs:FindFirstChild('Legendary Sword Dealer') then
                return
            end

            Module:ComF("LegendarySwordDealer", "1")
            Module:ComF("LegendarySwordDealer", "2")
            Module:ComF("LegendarySwordDealer", "3")
        end, 3)
    end

    do -- FORCE USAGE
        NewOption("Teleport to Island", function()
            local Target = DataModule['Island'][Module.Sea][Settings['Select Island']]

            if not Target then return end

            Teleport(Target)

            return true
        end)


        NewOption("Teleport to Place", function()
            local Target = DataModule['Place'][Module.Sea][Settings['Select Place']]

            if not Target then return end

            Teleport(Target)

            return true
        end)

        NewOption("Teleport to Lab", function()
            if Module.Sea == 2 then
                Teleport(CFrame.new(-6535, 310, -4745))
            else
                Teleport(CFrame.new(-5016, 315, -2828))
            end

            return true
        end)

        NewOption('Advance Dealer', function()
            local Loaded = NPCs:FindFirstChild("Advanced Fruit Dealer")

            if not Loaded then
                local Replicated = ReplicatedNPCs:FindFirstChild('Advanced Fruit Dealer')
                if not Replicated then return end

                Teleport(Replicated:GetPivot())
                return true
            end

            Teleport(Loaded:GetPivot())

            return true
        end)

        NewOption("Collect Gears", function()
            local Mirage = Map:FindFirstChild('MysticIsland')
            if not Mirage then return end

            for _, v in pairs(Mirage:GetChildren()) do
                if v.Name == "Part" and v:IsA("MeshPart") then
                    Teleport(v.CFrame)
                    v.Transparency = 0
                end
            end

            return true
        end)

        do
            NewOption("Mirage Island", function()
                return Functions.FullMirage()
            end)

            NewOption('Kitsune Shrine', function()
                return Functions.FullKitsune()
            end)

            NewOption('Prehistoric', function()
                return Functions.FullVolcano()
            end)
        end

        AimbotModule:Import("Sea Event")
        NewOption("Sea Event", function()
            local Enemies  = Functions.GetEnemies(5000)

            for i, enemy in ipairs(Enemies) do
                if not table.find(Settings['Select Enemies'], enemy.name) then continue end

                local target = enemy.getData()
                if not target then continue end

                if _ENV.StopShip then pcall(_ENV.StopShip) end

                enemy.attack(target, function()
                    if not table.find(Settings['Select Enemies'], enemy.name) then
                        return true
                    end

                    if not Settings["Sea Event"] then
                        return true
                    end

                    for back = 1, i - 1 do
                        local higher = Enemies[back]

                        if table.find(Settings['Select Enemies'], higher.name) and higher.getData() then
                            return true
                        end
                    end

                    return false
                end)

                return true
            end
        end)

        NewOption("Drive a Ship", function()
            return Functions.Drive()
        end)

        NewOption("Clear Raid", function()
            Functions.FullRaid(function()
                return not Settings['Clear Raid']
            end, Settings['Select Chip'])
        end)

        NewOption("Law", function()
            return Functions.KillLaw(function()
                return not Settings['Law']
            end)
        end)

        NewOption("Chest", function()
            return Functions.CollectChest()
        end)

        NewOption("Nearest", function()
            return Functions.FarmNearest(1000, function()
                return not Settings['Nearest']
            end)
        end)

        NewOption("Third Sea", function()
            return Functions.ThirdSea(function()
                return not Settings["Third Sea"]
            end)
        end)

        NewOption("Second Sea", function()
            return Functions.SecondSea(function()
                return not Settings["Second Sea"]
            end)
        end)
    end

    do -- EVENTS ON FARMING
        NewOption("Collect Fruit", function()
            return Functions.CollectBloxFruits()
        end)

        NewOption("Gift", function()
            return Functions.CollectGift()
        end)

        NewOption("Egg", function()
            return Functions.Egg()
        end)

        NewOption("Berry", function()
            return Functions.CollectBerry()
        end)

        NewOption("Pirate Raid", function()
            return Functions.ClearPirateRaid(function()
                return not Settings['Pirate Raid']
            end)
        end)

        NewOption("Factory", function()
            return Functions.DestroyFactory(function()
                return not Settings['Factory']
            end)
        end)

        NewOption("Elite", function()
            return Functions.KillElite(function()
                return not Settings['Elite']
            end)
        end)

        NewOption("Saber", function()
            if Level.Value <= 200 then return end

            if Module:HaveItem("Saber") then return end

            if Map.Jungle.Final.Part.Transparency ~= 0 then
                local Enemy = EnemiesModule:GetClosestByTag("Saber Expert")
                if not Enemy then return end

                Kills(Enemy, false, function()
                    return not Settings["Saber"]
                end)

                return true
            end

            if Map.Jungle.QuestPlates.Door.Transparency == 0 then
                for _ ,v in next, Map.Jungle.QuestPlates:GetChildren() do
                    if v:IsA("Model") then
                        if v.Button:FindFirstChild("TouchInterest") then
                            firetouchinterest(HumanoidRootPart, v.Button, 1)
                            firetouchinterest(HumanoidRootPart, v.Button, 0)
                        end
                    end
                end

                return true
            end

            if not Module:ComF("ProQuestProgress")["UsedTorch"] then
                Module:ComF("ProQuestProgress","GetTorch")

                if Module:HaveItem("Torch") then
                    Module:Equip("Torch", false)
                end

                Module:ComF("ProQuestProgress","DestroyTorch")

                return true
            end

            if not Module:ComF("ProQuestProgress")["UsedCup"] then
                Module:ComF("ProQuestProgress","GetCup")

                if Module:HaveItem("Cup") then
                    Module:Equip("Cup", false)
                end

                Module:ComF("ProQuestProgress","FillCup", Character:FindFirstChild('Cup'))
                Module:ComF("ProQuestProgress","SickMan")

                return true
            end

            if not Module:ComF("ProQuestProgress")["KilledMob"] then
                Module:ComF("ProQuestProgress","RichSon")

                local Enemy = EnemiesModule:GetClosestByTag("Mob Leader")
                if not Enemy then return end

                Kills(Enemy, false, function()
                    return not Settings["Saber"]
                end)

                return true
            end

            if not Module:ComF("ProQuestProgress")["UsedRelic"] then
                Module:ComF("ProQuestProgress","RichSon")

                if Module:HaveItem("Relic") then
                    Module:Equip("Relic", false)
                end

                Module:ComF("ProQuestProgress","PlaceRelic")

                return true
            end
        end)

        NewOption("Yama", function()
            return Functions.Yama(function()
                return not Settings['Yama']
            end)
        end)

        NewOption("Tushita", function()
            return Functions.Tushita(function()
                return not Settings['Tushita']
            end)
        end)

        NewOption("Cursed Duel Katana", function()
            return Functions.CDK(function()
                return not Settings['Cursed Duel Katana']
            end)
        end)

        NewOption("Target Boss", function()
            return Functions.KillBoss(Settings['Select Boss'], function()
                return not Settings["Target Boss"]
            end)
        end)
    end

    do  -- On Queue
        NewOption("Material", function()
            return Functions.FarmMaterial(Settings['Select Material'], function()
                return not Settings['Material']
            end)
        end)

        AimbotModule:Import("Candy")
        NewOption("Candy", function()
            return Functions.FarmLevel(function()
                return not Settings['Candy']
            end)
        end)

        NewOption("Ectoplasm", function()
            return Functions.FarmEctoplasm(function()
                return not Settings['Ectoplasm']
            end)
        end)

        AimbotModule:Import("Tyrant Skies")
        NewOption("Tyrant Skies", function()
            return Functions.KillTyrantSkies(function()
                return not Settings['Tyrant Skies']
            end)
        end)

        NewOption("Dough King", function()
            return Functions.FullCakePrince(true, function()
                return not Settings['Dough King']
            end)
        end)

        NewOption("Cake Prince", function()
            return Functions.FullCakePrince(false, function()
                return not Settings['Cake Prince']
            end)
        end)

        NewOption("Bone", function()
            return Functions.FarmBone(function()
                return not Settings['Bone']
            end)
        end)

        AimbotModule:Import("Level")
        NewOption("Level", function()
            return Functions.FarmLevel(function()
                return not Settings['Level']
            end)
        end)
    end
end

do
    do
        local Core = gethui and gethui()

        for _, Rapid in Core:GetChildren() do
            if Rapid.Name == 'Rapid' then
                Rapid:Destroy()
            end
        end
    end

    local Reimagined = Colors("Easter", Color3.fromRGB(255, 170, 0))
    local Updater = Colors("[ 🥚 " .. Reimagined .. " ]", Color3.fromRGB(255, 255, 255))

    local Title = Updater .. " THAI NO 1's official "
    local Credits = "Made by @THAI NO 1"

    local LEVEL_CAP = workspace:GetAttribute('LEVEL_CAP')

    local Window = Plugins:Window({
        Title = Title,
        SubTitle = Credits
    })

    Plugins:Community()

    local Application = Plugins:NewPage({ "Application", "Application Options", 96487611333794 }) do
        Application:Section("Farming") do
            local Weapon = { "Melee", "Sword", "Blox Fruit" }

            Default("Select Weapon", "Melee")
            Default("Fast Attack", true)

            Plugins:Dropdown(Application, "Select Weapon", Weapon, "Select Weapon")

            Plugins:Toggle(Application, { "Fast Attack", "Attacking at a high speed with extended range" }, "Fast Attack")

            Plugins:Toggle(Application, { "Can Attack Players", "Fast Attack can hit other players." }, "Attack Players")

            Plugins:Button(Application, { "Improve Fast Attack", "Lets a player fix fast attack if not working." }, function()
                task.spawn(function()
                    loadstring([[
                        local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local cachedRemote, cachedRemoteId = nil, nil

local function registerRemote(obj)
    if obj:IsA("RemoteEvent") and obj:GetAttribute("Id") then
        cachedRemote = obj
        cachedRemoteId = obj:GetAttribute("Id")
    end
end

for _, folder in ipairs({
    ReplicatedStorage.Util,
    ReplicatedStorage.Common,
    ReplicatedStorage.Remotes,
    ReplicatedStorage.Assets,
    ReplicatedStorage.FX,
    }) do
    for _, child in ipairs(folder:GetChildren()) do
        registerRemote(child)
    end
    folder.ChildAdded:Connect(registerRemote)
end

local function getNearbyEnemyParts(rootPart, range)
    local results = {}
    for _, folder in ipairs({ workspace.Enemies, workspace.Characters }) do
        for _, entity in ipairs(folder:GetChildren()) do
            local entityRoot = entity:FindFirstChild("HumanoidRootPart")
            local humanoid = entity:FindFirstChild("Humanoid")
            if entity ~= LocalPlayer.Character
                and entityRoot
                and humanoid
                and humanoid.Health > 0
                and (entityRoot.Position - rootPart.Position).Magnitude <= range
            then
                for _, part in ipairs(entity:GetChildren()) do
                    if part:IsA("BasePart") then
                        table.insert(results, { entity, part })
                    end
                end
            end
        end
    end
    return results
end

local function encryptRemoteName(name)
    return string.gsub(name, ".", function(c)
        return string.char(bit32.bxor(string.byte(c), math.floor(workspace:GetServerTimeNow() / 10 % 10) + 1))
    end)
end

local function fireHit(targets)
    local character = LocalPlayer.Character
    if not character then return end

    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end

    local weaponType = tool:GetAttribute("WeaponType")
    if weaponType ~= "Melee" and weaponType ~= "Sword" then return end

    local head = targets[1][1]:FindFirstChild("Head")
    if not head then return end

    local Net = require(ReplicatedStorage.Modules.Net)
    local uid = tostring(LocalPlayer.UserId):sub(2, 4) .. tostring(coroutine.running()):sub(11, 15)
    local seed = ReplicatedStorage.Modules.Net.seed:InvokeServer()
    local xorId = bit32.bxor(cachedRemoteId + 909090, seed * 2)

    pcall(function()
        Net:RemoteEvent("RegisterHit", true)
        ReplicatedStorage.Modules.Net["RE/RegisterAttack"]:FireServer()
        ReplicatedStorage.Modules.Net["RE/RegisterHit"]:FireServer(head, targets, {}, uid)
        cloneref(cachedRemote):FireServer(encryptRemoteName("RE/RegisterHit"), xorId, head, targets)
    end)
end

game:GetService('StarterGui'):SetCore('SendNotification', {
    Title = 'Injecting ..',
    Text = "Waiting for seed ...",
    Duration = 3,
})

task.delay(5, function()
    game:GetService('StarterGui'):SetCore('SendNotification', {
        Title = 'Injected !',
        Text = "✅ : Operational",
        Duration = 5,
    })
end)

task.spawn(function()
    while task.wait(0.0001) do
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then continue end

        local targets = getNearbyEnemyParts(rootPart, 60)
        
        if #targets > 0 then
            fireHit(targets)
        end
    end
end)

                    ]])()
                end)
            end)
        end

        Application:Section("Tweening") do
            Default("Wait Enemies Delay", 0.75)

            Plugins:Toggle(Application, { "Quick Teleport", "Quickly teleports when the target is within 250 meters." }, "Dodge Position")

            Plugins:Slider(Application, "Wait Enemies Delay", { 0.5, 1, 2 }, "Wait Enemies Delay")
        end

        Application:Section("Pulling") do
            Default("Enabled Bring", true)
            Default("Bring Distance", 300)

            Plugins:Toggle(Application, { "Pulls Enemies", "Pulls nearby enemies toward you." }, "Enabled Bring")

            Plugins:Slider(Application, "Pulls Range", { 150, 350 }, "Bring Distance")
        end

        Application:Section("Skilling") do
            Default('Melee', { "Z", "X", "C" })
            Default('Sword', { "Z", "X" })
            Default('Gun', { "Z", "X" })
            Default('Blox Fruit', { "Z", "X", "C", "V" })

            Plugins:Dropdown(Application, 'Melee', { "Z", "X", "C" }, 'Melee')

            Plugins:Dropdown(Application, 'Sword', { "Z", "X" }, 'Sword')

            Plugins:Dropdown(Application, 'Gun', { "Z", "X" }, 'Gun')

            Plugins:Dropdown(Application, "Blox Fruit", { "Z", "X", "C", "V" }, "Blox Fruit")
        end

        Application:Section("Options") do
            Plugins:Toggle(Application, { "Disable Notifications", "Turns off game notifications such as EXP and money gains." }, "Disable Notification", function(value)
                PlayerGui.Notifications.Enabled = not value
            end)

            Plugins:Toggle(Application, { "Set Spawn Point", "Automatically sets your spawn point to the current island." }, "Force Spawn Point")

            Plugins:Toggle(Application, { "Activated Race V3", "Automatically activates Race V3." }, "V3")

            Plugins:Toggle(Application, { "Activated Race V4", "Automatically activates Race V4." }, "V4")

            Plugins:Toggle(Application, { "Walk On Water", "Allows you to walk on water." }, "Walk On Water", function(value)
                if value then
                    Map["WaterBase-Plane"].Size = Vector3.new(Map["WaterBase-Plane"].Size.X, 165, Map["WaterBase-Plane"].Size.Z)
                else
                    Map["WaterBase-Plane"].Size = Vector3.new(Map["WaterBase-Plane"].Size.X, 80, Map["WaterBase-Plane"].Size.Z)
                end
            end)
        end
    end

    local Standard = Plugins:NewPage({ "Standard", "Standard Options", 89366688240346 }) do
        Standard:Section("Leveling") do
            Default("Adaptive Update", true)

            Plugins:Toggle(Standard, { "Auto Farm Level", "Farm levels from 1 – ".. LEVEL_CAP }, "Level")

            Plugins:Toggle(Standard, { "Adaptive Update", "Uses latest level data from the game." }, "Adaptive Update")
        end

        Standard:Section("Stats") do
            local Stats = {
                "Melee", "Defense",
                "Sword", "Gun",
                "Demon Fruit"
            }

            Default("Select Stats", { "Melee" })

            Plugins:Dropdown(Standard, "Select Stats", Stats, "Select Stats")

            Plugins:Toggle(Standard, { "Auto Upgrade Stats", "Automatically upgrades stats as you level up." }, "Upgrade Stats")

            Plugins:Button(Standard, { "Refund Stats", "Lets a player reset and reallocate their stat points." }, function()
                Module:ComF("BlackbeardReward", "Refund", "2")
            end)

            Plugins:Button(Standard, { "Race Reroll", "Lets a player randomly change their current race" }, function()
                Module:ComF("BlackbeardReward", "Reroll", "2")
            end)
        end

        Standard:Section("Story") do
            Settings['Second Sea'] = false
            Settings['Third Sea'] = false

            Plugins:Toggle(Standard, { "Auto Second Sea", "Defeat the ice admiral at frozen village to complete quest." }, "Second Sea")

            Plugins:Toggle(Standard, { "Auto Third Sea", "Completes second Sea quest, kill don swan, trevor’s 1M+ fruit, and rip_indra." }, "Third Sea")
        end 

        Standard:Section("Enemies") do
            Plugins:Toggle(Standard, { "Auto Farm Nearest", "Farm nearest enemies in 1000 m." }, "Nearest")

            Plugins:Toggle(Standard, { "Nearest Execution", "Instant kill nearest enemies in 300 m." }, "Nearest Execution")
        end

        Standard:Section("Bosses") do
            Default("Select Boss", { BossesModule[1], BossesModule[2] })

            Plugins:Dropdown(Standard, "Select Boss", BossesModule, 'Select Boss')

            Plugins:Toggle(Standard, { "Kill Target Boss", "Farms the target boss when it spawns." }, "Target Boss")
        end
    end

    local Automatic = Plugins:NewPage({ "Automatic", "Automatic Options", 121366445504981 }) do
        Automatic:Section("Events") do
            Plugins:Toggle(Automatic, { "Auto Pirate Raid", "Clear pirate raid, spawn every 1 hour 15 mins." }, 'Pirate Raid')

            Plugins:Toggle(Automatic, { "Auto Factory Raid", "Destroy factory raid, spawn every 2 hous." }, 'Factory')
        end

        Automatic:Section("Bones") do
            AddInventoryEvent(Automatic, "Bones")

            Plugins:Toggle(Automatic, { "Auto Farm Bone", "Farms enemies that drop bones." }, 'Bone')

            Plugins:Toggle(Automatic, { "Random Surprise", "Random bone to get rewards." }, 'Random Surprise')
        end

        Automatic:Section("Elite") do
            NewStateLabel(Automatic, "Elite")

            Plugins:Toggle(Automatic, { "Auto Elite", "Get quest and kill elite." }, 'Elite')
        end

        Automatic:Section("Cake Prince") do
            NewStateLabel(Automatic, "Required Enemies")
            NewStateLabel(Automatic, "Cake Prince")
            NewStateLabel(Automatic, "Dough King")

            Plugins:Toggle(Automatic, { "Auto Cake Prince", "Kill 500 enemies and summon boss." }, 'Cake Prince') 

            Plugins:Toggle(Automatic, { "Auto Dough King", "Find sweet chalice, kill enemies and summon boss." }, 'Dough King') 
        end
    end

    local Items = Plugins:NewPage({ "Items", "Items Options", 98969437843417 }) do
        Items:Section("Collectable") do
            Plugins:Toggle(Items, { "Auto Collect Egg", "Collects all eggs." }, "Egg")

            Plugins:Toggle(Items, { "Auto Collect Berry", "Collects all berries." }, "Berry")

            Plugins:Toggle(Items, { "Auto Collect Chest", "Collects all chests." }, "Chest")
        end

        Items:Section("Fruit") do
            Plugins:Toggle(Items, { "Auto Collect Fruit", "Collects all devil fruits." }, "Collect Fruit")

            Plugins:Toggle(Items, { "Auto Random Fruit", "Random fruits every 60s." }, 'Random Fruit')

            Plugins:Toggle(Items, { "Auto Store Fruit", "Stores all fruits to backpack." }, 'Store Fruit')

            Plugins:Button(Items, { "Random Fruit", "Lets a player randomly devil fruits." }, function()
                Module:ComF("Cousin", "Buy")
            end)

            Plugins:Button(Items, { "Normal Stock", "Lets a player open devil fruits shop." }, function()
                _ENV.OPENSTOCK()
            end)

            Plugins:Button(Items, { "Advanced Stock", "Lets a player open devil fruits shop." }, function()
                _ENV.OPENSTOCK(true)
            end)
        end

        Items:Section("Material") do
            Default('Select Material', DataModule['Material List'][1])

            Plugins:Dropdown(Items, 'Select Material', DataModule['Material List'], 'Select Material')
            Plugins:Toggle(Items, { "Auto Farm Material", "Farms enemies that drop the selected material." }, 'Material')
        end
    end

    local Dungeon = Plugins:NewPage({ "Dungeon", "Dungeon Options", 71085907390638 }) do
        Dungeon:Section("Order") do
            Plugins:Toggle(Dungeon, { "Automatic Law Raid", "Buy chip and kill law the order." }, 'Law')
        end

        Dungeon:Section("Dungeon") do
            Default('Select Chip', Module.RaidList[1])

            Plugins:Dropdown(Dungeon, 'Select Chip', Module.RaidList, 'Select Chip')

            Plugins:Toggle(Dungeon, { "Automatic Clear Raid", "Buys the chip, starts raids and clears all enemies." }, 'Clear Raid')

            Plugins:Toggle(Dungeon, { "Buy Awaken Skill", "Buys skill after end raids." }, 'Buy Awaken Skill')

            Plugins:Toggle(Dungeon, { "Unstore Fruit", "Unstore fruits that lower than 1m." }, 'Unstore Fruit')

            Plugins:Toggle(Dungeon, { "Teleport to Lab", "Teleports to the Lab" }, 'Teleport to Lab')

            Plugins:Button(Dungeon, { "Buy Chip", "Lets user buy select chip" }, function()
                Module:ComF("RaidsNpc", "Select", Settings['Select Chip'])
            end)
        end
    end

    local Equipment = Plugins:NewPage({ "Equipment", "Equipment Options", 111489723544340 }) do
        Equipment:Section("Dealer") do
            Plugins:Toggle(Equipment, { "Auto True Triple Katana", "Waits for the Legendary Sword Dealer to spawn and automatically buys all required katanas." }, 'True Tripple Katana')

            Plugins:Toggle(Equipment, { "Auto Haki Colors", "Waits for the Master of Auras (Haki Colors Dealer) and automatically buys available haki colors." }, 'Haki Colors')
        end

        Equipment:Section("Sword") do
            Plugins:Toggle(Equipment, { "Auto Saber", "Automatically completes puzzle torch, defeats Mob Leader, and relic quest." }, 'Saber')

            Plugins:Toggle(Equipment, { "Auto Yama", "Defeats Elite Pirates until reaching the required amount and attempts to obtain the Yama sword." }, 'Yama')

            Plugins:Toggle(Equipment, { "Auto Tushita", "Spawns Rip_Indra, lights all torches, and defeats Longma to obtain Tushita." }, 'Tushita')

            Plugins:Toggle(Equipment, { "[ BETA ] Auto Cursed Dual Katana", "Completes the Heaven and Hell trials." }, 'Cursed Duel Katana')
        end
    end

    local SeaEvent = Plugins:NewPage({ "Sea Events", "Sea Event Options", 102432461962788 }) do
        SeaEvent:Section("Skill") do
            Plugins:Button(SeaEvent, { Colors("From s1nve", Color3.fromRGB(255, 0, 127)), "Click for back to the <b><font color=\"rgb(255, 170, 0)\">(Application > Skilling)</font></b> page and select skill." }, function()
                Library.PageService:JumpToIndex(2)
            end)
        end

        SeaEvent:Section("Options") do
            local Ship = {
                "Beast Hunter", "Sleigh", "PirateGrandBrigade",
                "MarineGrandBrigade", "Miracle", "The Sentinel",
                "Guardain", "Lantern"
            }

            local EnemyList = {
                "Shark", "Piranha", "Terrorshark", "Fish Crew Member",
                "Sea Beast", "Pirate Ship", "Ghost Ship"
            }

            local ZoneList = { 
                "Infinite - ∞", "Low - 1","Meduim - 2","High - 3",
                "Extreme - 4", "Crazy - 5", "??? - 6"
            }

            Default("Select Zone", 'Infinite - ∞')
            Default("Select Enemies", { "Piranha", "Terror Shark" })
            Default("Select Ship", "PirateGrandBrigade")

            Plugins:Dropdown(SeaEvent, 'Select Zone', ZoneList, 'Select Zone')

            Plugins:Dropdown(SeaEvent, 'Select Enemies', EnemyList, 'Select Enemies')

            Plugins:Dropdown(SeaEvent, 'Select Ship', Ship, 'Select Ship')
        end

        SeaEvent:Section("Controller") do
            Default("High Position", 150)
            Default("Ship Retreat Health", 15)

            Plugins:Slider(SeaEvent, "High Position", { 20, 175, 0 }, "High Position")

            Plugins:Slider(SeaEvent, "Ship Retreat Health", { 10, 40, 0 }, "Ship Retreat Health")
        end

        SeaEvent:Section("Hunting") do
            Plugins:Toggle(SeaEvent, { "Drive a Ship", "Allowed to drive a ship." }, 'Drive a Ship')

            Plugins:Toggle(SeaEvent, { "Clear Event", "Clear select enemies." }, 'Sea Event')

            Plugins:Button(SeaEvent, { "Remove Rock", "Removes rocks to clear the ocean." }, function()
                pcall(function()
                    if workspace:FindFirstChild('Rocks') then
                        workspace.Rocks.Parent = nil
                    end
                end)
            end)
        end
    end

    local Spacial = Plugins:NewPage({ "Spacial", "Spacial Options", 114944379706502 }) do
        Spacial:Section("Shrine") do
            NewStateLabel(Spacial, "Shrine")

            Plugins:Toggle(Spacial, { "Auto Shrine", "Fully find kitsune shrine collect orb and trade." }, 'Kitsune Shrine')
        end

        Spacial:Section("Volcano") do
            NewStateLabel(Spacial, "Volcano")

            Plugins:Button(Spacial, { Colors("From s1nve", Color3.fromRGB(255, 0, 127)), "Click for back to the <b><font color=\"rgb(255, 170, 0)\">(Application > Skilling)</font></b> page and select skill." }, function()
                Library.PageService:JumpToIndex(2)
            end)

            Plugins:Toggle(Spacial, { "Auto Volcano", "Fully find volcano, patch event, collect bone and egg." }, 'Prehistoric')

            Plugins:Button(Spacial, { "Remove Lava", "Removes lava to safe user." }, function()
                pcall(function()
                    task.spawn(pcall, function()
                        local PrehistoricIsland = Map.PrehistoricIsland

                        if PrehistoricIsland.Core:FindFirstChild("InteriorLava") then
                            PrehistoricIsland.Core.InteriorLava:Destroy()
                        end

                        for _, Instance in PrehistoricIsland:GetDescendants() do
                            if string.find(string.lower(Instance.Name), "lava") and Instance:IsA("BasePart") then
                                Instance:Destroy()
                            end
                        end
                    end)
                end)
            end)
        end

        Spacial:Section("Mirage") do
            NewStateLabel(Spacial, "Mirage Island")

            Plugins:Toggle(Spacial, { "Auto Mirage Island", "Fully find mirage island and collect chest." }, 'Mirage Island')

            Plugins:Toggle(Spacial, { "Auto Collect Gears", "Collect gears in mirage island." }, 'Collect Gears')

            Plugins:Toggle(Spacial, { "Auto Look Moon", "Look moon in mirage island." }, 'Look Moon')

            Plugins:Toggle(Spacial, { "Find Advance Dealer", "Teleport to advance dealer." }, 'Advance Dealer')

            Plugins:Button(Spacial, { "Remove Fog", "Remove dark fog from mirage island." }, function()
                task.spawn(pcall, function()
                    Lighting.LightingLayers.MirageFog:Destroy()
                end)
            end)
        end
    end

    local Visual = Plugins:NewPage({ "Visual", "Visual Options", 113843981805131 }) do

    end

    local Teleport = Plugins:NewPage({ "Teleport", "Teleport Options", 107953520698619 }) do
        Teleport:Section("Sea") do
            local function Add(SeaName, SeaIndex)
                Plugins:Button(Teleport, { SeaName, "Travel to " .. SeaName .. "." }, function()
                    Module:TravelTo(SeaIndex)
                end)
            end

            Add("Third Sea", 3) Add("Second Sea", 2) Add("First Sea", 1)
        end

        Teleport:Section("Island") do
            Default('Select Island', Module.IslandString[1])

            Plugins:Dropdown(Teleport, 'Select Island', Module.IslandString, 'Select Island')

            Plugins:Toggle(Teleport, { "Teleport to Island", "Teleport to the select island" }, 'Teleport to Island')
        end

        Teleport:Section("Place") do
            Default('Select Place',Module.PlaceString[1])

            Plugins:Dropdown(Teleport, 'Select Place', Module.PlaceString, 'Select Place')

            Plugins:Toggle(Teleport, { "Teleport to Place", "Teleport to the select place" }, 'Teleport to Place')
        end

        Teleport:Section("Gate") do
            local Gates = {
                {
                    ['Gate'] = Vector3.new(3864, 5, -1926),
                    ["Under Water"] = Vector3.new(61163, 5, 1819),
                    ["Sky 2"] = Vector3.new(-7894, 5545, -380),
                    ["Sky 1"] = Vector3.new(-4607, 872, -1667),
                },
                {
                    ["Ghost Ship"] = Vector3.new(923, 125, 32852),
                    ['Mansion'] = Vector3.new(-288, 200, 611),
                    ['Swan'] = Vector3.new(2283, 60, 905),
                    ["Out Ghost Ship"] = Vector3.new(-6505, 125, -130),
                },
                {
                    ["Castle on the Sea"] = Vector3.new(-5076, 314, -3151),
                    ['Hydra'] = Vector3.new(5657, 1013, -338),
                    ['Mansion'] = Vector3.new(-12479, 375, -7566),
                },
            }

            local GateList = {
                { 'Gate', 'Under Water', 'Sky 2', 'Sky 1' },
                { 'Ghost Ship', 'Mansion', 'Swan', 'Out Ghost Ship' },
                { 'Castle on the Sea', 'Hydra', 'Mansion' },
            }

            Default('Select Gate', GateList[Module.Sea][1])

            Plugins:Dropdown(Teleport, 'Select Gate', GateList[Module.Sea], 'Select Gate')

            Plugins:Button(Teleport, { "Enter Gate", "Lets user teleport to gate instant." }, function()
                task.spawn(function()
                    if Gates[Module.Sea][Settings['Select Gate']] then
                        Module:ComF("requestEntrance", Gates[Module.Sea][Settings['Select Gate']])
                    end
                end)
            end)
        end
    end

    Plugins:Managers()

    do
        local Checks = {
            { tag = "Elite",       label = Text["Elite"]      },
            { tag = "Dough King",  label = Text["Dough King"] },
            { tag = "Cake Prince", label = Text["Cake Prince"] },
        }

        local CheckIslands = {
            { name = "KitsuneIsland",label = Text["Shrine"]      },
            { name = "PrehistoricIsland",  label = Text["Volcano"] },
            { name = "MysticIsland", label = Text["Mirage Island"] },
        }

        local function FormatTime(seconds)
            local h = math.floor(seconds / 3600)
            local m = math.floor((seconds % 3600) / 60)
            local s = seconds % 60

            return string.format("%02d:%02d:%02d", h, m, s)
        end

        local function OnUpdate()
            pcall(function()
                local CakePrincRequired = tonumber(string.match(tostring(Module:ComF("CakePrinceSpawner")), "%d+"))

                for _, v in ipairs(Checks) do
                    v.label.Text = EnemiesModule:GetClosestByTag(v.tag) and SPAWNED or DESPAWNED
                end

                for _, v in ipairs(CheckIslands) do
                    v.label.Text = Map:FindFirstChild(v.name) and SPAWNED or DESPAWNED
                end

                if CakePrincRequired then
                    Text['Required Enemies'].Text = Colors(tostring(CakePrincRequired), Color3.fromRGB(255, 170, 0))
                end

                local Expire = (JD_EXPIRES_AT and JD_EXPIRES_AT - os.time()) or "00:00:00"
                if Expire then Library:SetTimeValue(tostring(FormatTime(Expire)) .. " Hours") end
            end)
        end

        Connect(Stepped, OnUpdate)
    end
end
