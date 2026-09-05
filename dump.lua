-- ======================================================================================
-- [[ PAYOMBOYZ AI GENERATE - OBSIDIAN GLASSMORPHIC 2 ENGINE ]]
-- ======================================================================================
-----------------------------------------------------------------------------------------
-- 🧹 CONNECTION & CLEANUP MANAGER
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- 🧹 CONNECTION & CLEANUP MANAGER (MAID PATTERN & GLOBAL HOOK SINGLETON)
-----------------------------------------------------------------------------------------
local Maid = {}
Maid.Connections = {}

function Maid:Give(conn)
    if conn then
        table.insert(self.Connections, conn)
    end
    return conn
end

function Maid:Cleanup()
    for i, conn in ipairs(self.Connections) do
        pcall(function()
            if conn and conn.Disconnect then
                conn:Disconnect()
            end
        end)
        self.Connections[i] = nil
    end
    table.clear(self.Connections)
end

local TrackedConnections = Maid.Connections
local function TrackConnection(conn)
    return Maid:Give(conn)
end

local function CleanupConnections()
    Maid:Cleanup()
end

-- Global singleton state for Remote Spy Hook
if getgenv()._PayomboyZ_RemoteSpyEnabled ~= nil then
    getgenv()._PayomboyZ_RemoteSpyEnabled = false
end

-- Clean up any existing UI instances and active connections
local parentGui = (typeof(gethui) == "function") and gethui() or game:GetService("CoreGui")
if getgenv()._PayomboyZ_Maid then
    pcall(function() getgenv()._PayomboyZ_Maid:Cleanup() end)
end
getgenv()._PayomboyZ_Maid = Maid

if parentGui:FindFirstChild("ObsidianGlass2_UI") then
    parentGui.ObsidianGlass2_UI:Destroy()
end
if parentGui:FindFirstChild("AtmosphereSystemHub") then
    parentGui.AtmosphereSystemHub:Destroy()
end

-----------------------------------------------------------------------------------------
-- 🐛 DEBUG LOGGING ENGINE
-----------------------------------------------------------------------------------------
local DebugLogs = {}
local DebugConsoleBox = nil

local function DebugLog(level, category, message)
    local timestamp = os.date("%H:%M:%S")
    local raw = string.format("[%s] %-7s [%s] %s", timestamp, level, category, message)
    table.insert(DebugLogs, { Level = level, Category = category, Message = message, Time = timestamp, Raw = raw })
    if #DebugLogs > 400 then table.remove(DebugLogs, 1) end
    
    if DebugConsoleBox then
        local currentText = DebugConsoleBox.Text
        if currentText == "" then
            DebugConsoleBox.Text = raw
        else
            DebugConsoleBox.Text = currentText .. "\n" .. raw
        end
    end
end

-----------------------------------------------------------------------------------------
-- 🧠 AI CONTEXT ENGINE (CONTEXT-AWARE CODE SYNTHESIS)
-----------------------------------------------------------------------------------------
local AIContextEngine = {
    BoundItems = {},
    AddContext = function(self, name, className, fullName, category)
        for _, item in ipairs(self.BoundItems) do
            if item.FullName == fullName then return false end
        end
        table.insert(self.BoundItems, { Name = name, ClassName = className, FullName = fullName, Category = category or "Explorer" })
        DebugLog("INFO", "AI_CONTEXT", "Bound " .. className .. ": " .. fullName)
        return true
    end,
    RemoveContext = function(self, fullName)
        for i, item in ipairs(self.BoundItems) do
            if item.FullName == fullName then
                table.remove(self.BoundItems, i)
                DebugLog("INFO", "AI_CONTEXT", "Removed bound context: " .. fullName)
                return true
            end
        end
        return false
    end,
    ClearContext = function(self)
        self.BoundItems = {}
        DebugLog("INFO", "AI_CONTEXT", "Cleared all bound AI game contexts")
    end,
    GetSummaryText = function(self)
        if #self.BoundItems == 0 then return "-- No game context bound yet. Add items from '🔎 Game Explorer' or '📡 Remote Spy'." end
        local lines = { "-- [[ ACTIVE GAME CONTEXT (" .. #self.BoundItems .. " INSTANCES BOUND) ]]" }
        for i, item in ipairs(self.BoundItems) do
            lines[#lines + 1] = string.format("-- [%d] %s (%s) -> %s", i, item.Name, item.ClassName, item.FullName)
        end
        return table.concat(lines, "\n")
    end
}

-----------------------------------------------------------------------------------------
-- 🌐 GITHUB KNOWLEDGE RETRIEVAL & INTEGRATION ENGINE
-----------------------------------------------------------------------------------------
local KnowledgeEngine = {
    Enabled = true,
    RawRepoBaseUrl = "https://raw.githubusercontent.com/aslamdunk7/PayomboyZKnowledge/main/",
    CacheFolder = "PayomboyZ_KnowledgeCache",
    ManifestEntries = {},
    DocCache = {},
    IsLoaded = false,
    LastSyncTime = "Never",
    
    -- Thai Synonym dictionary for semantic query expansion
    ThaiSynonyms = {
        ["ผู้เล่น"] = {"player", "players", "character", "humanoid"},
        ["ตัวละคร"] = {"character", "humanoid", "humanoidrootpart", "rig"},
        ["เก็บข้อมูล"] = {"cache", "store", "storage", "table"},
        ["ล้าง"] = {"cleanup", "clear", "disconnect", "maid", "destroy"},
        ["วาป"] = {"teleport", "cframe", "position", "moveto"},
        ["วาร์ป"] = {"teleport", "cframe", "position", "moveto"},
        ["ย้าย"] = {"teleport", "cframe", "position"},
        ["เหตุการณ์"] = {"event", "signal", "callback", "bindable"},
        ["รีโมท"] = {"remote", "remoteevent", "remotefunction"},
        ["หน่วง"] = {"lag", "performance", "optimization", "task"},
        ["กระเป๋า"] = {"backpack", "inventory", "tool"},
        ["อาวุธ"] = {"weapon", "tool", "sword", "gun"},
        ["ดักจับ"] = {"spy", "remote", "hook", "intercept"},
        ["สแกน"] = {"scan", "anticheat", "ac", "heuristic"},
        ["สถานะ"] = {"state", "statemachine", "fsm", "condition"},
        ["วนลูป"] = {"runservice", "heartbeat", "renderstepped", "stepped", "loop"},
        ["หน่วยความจำ"] = {"cleanup", "disconnect", "memory", "leak"},
        ["ข้อผิดพลาด"] = {"error", "pcall", "xpcall", "assert"},
        ["โมดูล"] = {"module", "modulescript", "require"},
        -- THAI COMMAND SYNONYMS
        ["บิน"] = {"fly", "noclip", "speed", "movement"},
        ["เหาะ"] = {"fly", "noclip", "movement"},
        ["ลอย"] = {"fly", "hover", "movement"},
        ["ลอยตัว"] = {"fly", "hover", "movement"},
        ["มองทะลุ"] = {"esp", "box", "highlight", "visuals", "xray"},
        ["มองคน"] = {"esp", "players", "highlight", "visuals"},
        ["กล่อง"] = {"chest", "box", "esp"},
        ["แร่"] = {"ore", "esp", "mine"},
        ["อมตะ"] = {"god", "health", "maxhealth", "utilities"},
        ["ไม่ตาย"] = {"god", "health", "maxhealth"},
        ["วิ่งเร็ว"] = {"speed", "walkspeed", "sprint", "movement"},
        ["เดินเร็ว"] = {"speed", "walkspeed", "movement"},
        ["กระโดดสูง"] = {"jump", "jumppower", "movement"},
        ["ฟาร์ม"] = {"farm", "collect", "automation"},
        ["ออโต้ฟาร์ม"] = {"farm", "collect", "automation"},
        ["เก็บของ"] = {"collect", "pickup", "proximityprompt"},
        ["ล็อกเป้า"] = {"aim", "lock", "fov", "hitbox", "combat"},
        ["ล็อกหัว"] = {"aim", "lock", "fov", "hitbox", "combat"},
        ["ยิงหัว"] = {"aim", "lock", "hitbox", "combat"},
        ["ดาบ"] = {"sword", "katana", "blade", "weapon"},
        ["ปืน"] = {"gun", "blaster", "rifle", "weapon"},
        ["เสก"] = {"weapon", "tool", "synthesizer"},
        ["ทะลุกำแพง"] = {"noclip", "cancollide", "movement"}
    }
}

function KnowledgeEngine:EnsureCacheFolder()
    if typeof(makefolder) == "function" then
        pcall(function() makefolder(self.CacheFolder) end)
    end
end

function KnowledgeEngine:LoadManifest(forceRefresh)
    self:EnsureCacheFolder()
    local manifestContent = nil
    local manifestCacheFile = self.CacheFolder .. "/manifest.txt"

    if not forceRefresh and typeof(readfile) == "function" and typeof(isfile) == "function" and isfile(manifestCacheFile) then
        pcall(function() manifestContent = readfile(manifestCacheFile) end)
    end

    if not manifestContent or manifestContent == "" or forceRefresh then
        local ok, body = pcall(function()
            return game:HttpGet(self.RawRepoBaseUrl .. "manifest.txt")
        end)
        if ok and body and #body > 0 then
            manifestContent = body
            if typeof(writefile) == "function" then
                pcall(function() writefile(manifestCacheFile, body) end)
            end
            self.LastSyncTime = os.date("%H:%M:%S")
            DebugLog("INFO", "KNOWLEDGE", "Fetched manifest.txt from GitHub")
        else
            DebugLog("WARN", "KNOWLEDGE", "Failed to fetch manifest.txt from GitHub, fallback to local if available")
        end
    end

    if not manifestContent or manifestContent == "" then
        DebugLog("ERROR", "KNOWLEDGE", "Manifest data unavailable")
        return false
    end

    table.clear(self.ManifestEntries)
    for line in string.gmatch(manifestContent, "[^\r\n]+") do
        line = string.gsub(line, "^%s*(.-)%s*$", "%1")
        if line ~= "" and not string.find(line, "^#") then
            -- Schema: PATH|TITLE|KEYWORDS|PRIORITY
            local parts = {}
            for part in string.gmatch(line, "[^|]+") do
                table.insert(parts, part)
            end
            if #parts >= 3 then
                local path = parts[1]
                local title = parts[2]
                local rawKw = parts[3]
                local priority = parts[4] or "MEDIUM"
                
                local kwList = {}
                for kw in string.gmatch(rawKw, "[^,]+") do
                    local cleanKw = string.lower(string.gsub(kw, "^%s*(.-)%s*$", "%1"))
                    if cleanKw ~= "" then
                        table.insert(kwList, cleanKw)
                    end
                end

                table.insert(self.ManifestEntries, {
                    Path = path,
                    Title = title,
                    Keywords = kwList,
                    Priority = string.upper(priority)
                })
            end
        end
    end

    self.IsLoaded = true
    DebugLog("INFO", "KNOWLEDGE", string.format("Parsed %d entries from manifest.txt", #self.ManifestEntries))
    return true
end

function KnowledgeEngine:GetDocument(path)
    if self.DocCache[path] then
        return self.DocCache[path]
    end

    self:EnsureCacheFolder()
    local safePath = string.gsub(path, "[/\\]", "_")
    local cacheFilePath = self.CacheFolder .. "/" .. safePath
    local content = nil

    if typeof(readfile) == "function" and typeof(isfile) == "function" and isfile(cacheFilePath) then
        pcall(function() content = readfile(cacheFilePath) end)
    end

    if not content or content == "" then
        local ok, body = pcall(function()
            return game:HttpGet(self.RawRepoBaseUrl .. path)
        end)
        if ok and body and #body > 0 then
            content = body
            if typeof(writefile) == "function" then
                pcall(function() writefile(cacheFilePath, body) end)
            end
            DebugLog("INFO", "KNOWLEDGE", "Downloaded doc: " .. path)
        end
    end

    if content then
        self.DocCache[path] = content
        return content
    end

    return nil
end

function KnowledgeEngine:ExpandQuery(userPrompt)
    local tokens = {}
    local lowerPrompt = string.lower(userPrompt or "")
    
    for word in string.gmatch(lowerPrompt, "[%w%z\128-\255]+") do
        if #word > 1 then
            table.insert(tokens, word)
        end
    end

    local expanded = {}
    local seen = {}
    for _, t in ipairs(tokens) do
        if not seen[t] then
            seen[t] = true
            table.insert(expanded, t)
        end
        if self.ThaiSynonyms[t] then
            for _, syn in ipairs(self.ThaiSynonyms[t]) do
                if not seen[syn] then
                    seen[syn] = true
                    table.insert(expanded, syn)
                end
            end
        end
    end

    return expanded
end

function KnowledgeEngine:Search(userPrompt, maxResults)
    maxResults = maxResults or 3
    if not self.IsLoaded then
        self:LoadManifest(false)
    end

    if #self.ManifestEntries == 0 then
        return {}
    end

    local expandedQuery = self:ExpandQuery(userPrompt)
    local lowerPrompt = string.lower(userPrompt or "")
    local priorityWeights = { S = 40, CRITICAL = 40, A = 30, HIGH = 30, B = 20, MEDIUM = 20, C = 10, LOW = 10 }

    local scoredResults = {}

    for _, entry in ipairs(self.ManifestEntries) do
        local score = 0
        local entryTitleLower = string.lower(entry.Title)

        if string.find(lowerPrompt, entryTitleLower, 1, true) then
            score = score + 50
        else
            for _, qTerm in ipairs(expandedQuery) do
                if string.find(entryTitleLower, qTerm, 1, true) then
                    score = score + 15
                end
            end
        end

        for _, kw in ipairs(entry.Keywords) do
            for _, qTerm in ipairs(expandedQuery) do
                if kw == qTerm then
                    score = score + 25
                elseif string.find(kw, qTerm, 1, true) or string.find(qTerm, kw, 1, true) then
                    score = score + 10
                end
            end
        end

        if score > 0 then
            local pWeight = priorityWeights[entry.Priority] or 10
            score = score + pWeight
            table.insert(scoredResults, {
                Path = entry.Path,
                Title = entry.Title,
                Score = score,
                Priority = entry.Priority
            })
        end
    end

    table.sort(scoredResults, function(a, b) return a.Score > b.Score end)

    local finalResults = {}
    for i = 1, math.min(maxResults, #scoredResults) do
        table.insert(finalResults, scoredResults[i])
    end

    return finalResults
end

function KnowledgeEngine:BuildContext(userPrompt)
    local results = self:Search(userPrompt, 3)
    if #results == 0 then
        return "-- [[ GITHUB KNOWLEDGE: No specific architectural patterns matched for prompt ]]"
    end

    local contextLines = {
        "-- [[ GITHUB KNOWLEDGE RETRIEVAL (" .. #results .. " DOCUMENTS MATCHED) ]]"
    }

    for i, res in ipairs(results) do
        local docContent = self:GetDocument(res.Path)
        if docContent then
            contextLines[#contextLines + 1] = string.format("-- [%d] %s (%s) [Score: %d | Priority: %s]", i, res.Title, res.Path, res.Score, res.Priority)
            
            local guidance = string.match(docContent, "##%s*AI_GUIDANCE(.-)##") or string.match(docContent, "##%s*AI_GUIDANCE(.*)")
            if guidance then
                guidance = string.gsub(guidance, "^%s*(.-)%s*$", "%1")
                contextLines[#contextLines + 1] = "-- AI Guidance Rules:\n-- " .. string.gsub(guidance, "\n", "\n-- ")
            else
                local summary = string.sub(docContent, 1, 350)
                contextLines[#contextLines + 1] = "-- Content Snippet:\n-- " .. string.gsub(summary, "\n", "\n-- ")
            end
            contextLines[#contextLines + 1] = ""
        end
    end

    DebugLog("INFO", "KNOWLEDGE", string.format("Built Knowledge Context (%d docs) for query: '%s'", #results, userPrompt))
    return table.concat(contextLines, "\n")
end

function KnowledgeEngine:Refresh()
    self.DocCache = {}
    self:LoadManifest(true)
    DebugLog("INFO", "KNOWLEDGE", "Refreshed Knowledge Engine manifest and cleared document cache")
end

function KnowledgeEngine:Initialize()
    task.spawn(function()
        self:LoadManifest(false)
    end)
end

-- Initialize Knowledge Engine automatically
KnowledgeEngine:Initialize()

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local SoundService = game:GetService("SoundService")

local SessionRegistry = {
    Macros = {
        {
            Name = "PayomboyZ Anime Card Farm",
            Code = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/payomboyz333/Anime-Card-Farm/refs/heads/main/start.txt"))()'
        },
        {
            Name = "Dex Debugging Explorer",
            Code = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()'
        },
        {
            Name = "Infinite Yield Admin Tools",
            Code = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()'
        }
    }
}
local MacroCounter = 4

-----------------------------------------------------------------------------------------
-- 🧬 UNIFIED SERIALIZATION ENGINE (SINGLETON TYPE SERIALIZER)
-----------------------------------------------------------------------------------------
local SerializationEngine = {}

function SerializationEngine.Serialize(value)
    local kind = typeof(value)
    if kind == "string" then 
        return string.format("%q", value) 
    elseif kind == "number" or kind == "boolean" then 
        return tostring(value) 
    elseif kind == "nil" then 
        return "nil" 
    elseif kind == "Vector3" then 
        return string.format("Vector3.new(%.3f, %.3f, %.3f)", value.X, value.Y, value.Z) 
    elseif kind == "Vector2" then 
        return string.format("Vector2.new(%.3f, %.3f)", value.X, value.Y) 
    elseif kind == "Color3" then 
        return string.format("Color3.fromRGB(%d, %d, %d)", math.floor(value.R * 255), math.floor(value.G * 255), math.floor(value.B * 255)) 
    elseif kind == "CFrame" then
        local components = {value:GetComponents()}
        for i, n in ipairs(components) do components[i] = string.format("%.3f", n) end
        return "CFrame.new(" .. table.concat(components, ", ") .. ")"
    elseif kind == "EnumItem" then 
        return tostring(value) 
    elseif kind == "UDim" then
        return string.format("UDim.new(%.3f, %d)", value.Scale, value.Offset)
    elseif kind == "UDim2" then
        return string.format("UDim2.new(%.3f, %d, %.3f, %d)", value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset)
    elseif kind == "BrickColor" then
        return string.format("BrickColor.new(%q)", value.Name)
    elseif kind == "Instance" then 
        local ok, path = pcall(function() return value:GetFullName() end)
        return ok and string.format("%q", path) or "<Instance>"
    elseif kind == "table" then
        local parts = {}
        local count = 0
        for k, v in pairs(value) do
            count = count + 1
            if count > 20 then table.insert(parts, "..."); break end
            table.insert(parts, string.format("[%s] = %s", SerializationEngine.Serialize(k), SerializationEngine.Serialize(v)))
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    else
        return string.format("%q", tostring(value))
    end
end

local function literal(val)
    return SerializationEngine.Serialize(val)
end

-----------------------------------------------------------------------------------------
-- 🎨 COLOR PALETTE SPECIFICATION
-----------------------------------------------------------------------------------------
local COLORS = {
    backdrop = Color3.fromRGB(5, 14, 8),
    shell = Color3.fromRGB(8, 20, 12),
    glass = Color3.fromRGB(12, 28, 16),
    glassDeep = Color3.fromRGB(8, 22, 12),
    glassRaised = Color3.fromRGB(16, 40, 22),
    userPanel = Color3.fromRGB(10, 24, 14),
    surface = Color3.fromRGB(14, 34, 20),
    surfaceRaised = Color3.fromRGB(18, 48, 26),
    surfaceHover = Color3.fromRGB(24, 64, 34),
    surfacePressed = Color3.fromRGB(10, 26, 15),
    input = Color3.fromRGB(6, 16, 9),
    inputFocus = Color3.fromRGB(12, 38, 20),
    divider = Color3.fromRGB(30, 140, 60),
    primary = Color3.fromRGB(0, 230, 118),
    primaryHover = Color3.fromRGB(45, 255, 145),
    primaryPressed = Color3.fromRGB(0, 180, 90),
    secondary = Color3.fromRGB(12, 36, 20),
    text = Color3.fromRGB(240, 255, 245),
    textMuted = Color3.fromRGB(140, 210, 165),
    textFaint = Color3.fromRGB(80, 140, 100),
    cyan = Color3.fromRGB(0, 255, 170),
    success = Color3.fromRGB(0, 230, 118),
    warning = Color3.fromRGB(240, 200, 50),
    danger = Color3.fromRGB(255, 65, 80),
    disabled = Color3.fromRGB(15, 35, 22),
    btnRed = Color3.fromRGB(80, 18, 24),
    btnRedHover = Color3.fromRGB(130, 28, 38),
    btnRedPressed = Color3.fromRGB(55, 12, 16),
    btnRedStroke = Color3.fromRGB(255, 65, 80),
}

-----------------------------------------------------------------------------------------
-- 🌐 LOCALIZATION ENGINE (THAI & ENGLISH SUPPORT)
-----------------------------------------------------------------------------------------
local CurrentLanguage = "TH" -- Default Language is Thai ("TH" or "EN")
local RegisteredLabels = {}

local I18N_DICT = {
    TH = {
        WINDOW_TITLE = "PayomboyZ สคริปต์ฮับ",
        WINDOW_SUBTITLE = "ระบบประมวลผล Obsidian Glassmorphic 2 Core Architecture",
        NAV_HEADER = "หมวดหมู่ระบบ / SYSTEM MODULES",
        STATUS_ACTIVE = "✅ PayomboyZ ทำงานปกติ",
        ACTIVE_SERVICE = "สถานะเซิร์ฟเวอร์",
        SYSTEM_VERIFIED = "🛡️ ผ่านการตรวจสอบแล้ว",
        SERVICE_SUB = "ระบบสคริปต์พรีเมียม • ทำงานเต็มประสิทธิภาพ",

        -- Tabs
        TAB_AI = "✨ สร้างโค้ด AI",
        TAB_EXPLORER = "🔎 สำรวจโครงสร้างเกม",
        TAB_SPY = "📡 ดักจับ Remote Spy",
        TAB_AC = "🛡️ สแกน Anti-Cheat",
        TAB_DUMP = "📦 เครื่องมือ Dump",
        TAB_PREVIEW = "👁️ ตัวอย่างไฟล์ Dump",
        TAB_DEBUG = "🐛 เทอร์มินัลระบบ (Debug)",
        TAB_MATRIX = "📁 คลังคำสั่ง (Matrix)",
        TAB_SETTINGS = "⚙️ ตั้งค่าระบบ",

        -- AI Tab
        AI_TITLE = "🤖 PayomboyZ AI สร้างโค้ด Luau",
        AI_DESC = "พิมพ์ความต้องการของคุณ (เช่น 'ระบบฟาร์มเวลอัตโนมัติ' หรือ 'ระบบวาปไปเกาะ') ระบบ AI จะรวมโหนดคำสั่งและผูกข้อมูล Instance ในเกมให้อัตโนมัติ",
        AI_PLACEHOLDER = "พิมพ์คำสั่งสร้างสคริปต์ที่นี่...",
        AI_SYNTHESIZE_BTN = "⚡ ประมวลผลสร้างโค้ดด้วย AI",
        AI_COPY_BTN = "📋 คัดลอกโค้ดทั้งหมด",
        AI_CLEAR_BTN = "🧹 ล้างหน้าจอโค้ด",
        AI_SAVE_MATRIX_BTN = "💾 บันทึกลงคลังคำสั่ง",

        -- Explorer Tab
        EXPLORER_SEARCH_LABEL = "🔎 ค้นหา Instance ข้าม Services ในเกม:",
        EXPLORER_SEARCH_PLACEHOLDER = "พิมพ์ชื่อวัตถุ Script, Remote, Module...",
        EXPLORER_REFRESH_BTN = "🔄 รีเฟรชการค้นหา",
        EXPLORER_BIND_CONTEXT_BTN = "🧠 ผูก Instance ที่เลือกเข้าสมอง AI",

        -- Remote Spy Tab
        SPY_FILTER_LABEL = "🚫 คำสั่ง/รีโมทที่จะข้าม (เว้นด้วยเครื่องหมายจุลภาค ,):",
        SPY_CLEAR_BTN = "🧹 ล้างประวัติ Remote",
        SPY_COPY_LOG_BTN = "📋 คัดลอก Log ทั้งหมด",
        SPY_BIND_AI_BTN = "🧠 ผูก Remote ทั้งหมดเข้าสมอง AI",

        -- AC Scanner Tab
        AC_SECTION = "🛡️ ระบบควบคุมเอนจินสแกน",
        AC_RUN_SCAN_BTN = "🔍 เริ่มสแกน Anti-Cheat ทั่วทั้งเกม",
        AC_SAVE_LOG_BTN = "💾 บันทึก Log สแกนลงไฟล์",
        AC_CLEAR_LOG_BTN = "🧹 ล้างหน้าจอ Log",

        -- Instance Dumper Tab
        DUMP_SECTION = "📦 ตั้งค่าการส่งออกไฟล์และ DUMP DATA",
        DUMP_TARGET_LABEL = "🎯 เลือก Service เป้าหมาย:",
        DUMP_FOLDER_LABEL = "📁 ชื่อโฟลเดอร์สำหรับบันทึก:",
        DUMP_OPT_TERRAIN = "🌐 รวม Terrain",
        DUMP_OPT_SCRIPTS = "📜 รวม Script (Decompile)",
        DUMP_OPT_CHARS = "👤 รวมตัวละครผู้เล่น (Character)",
        DUMP_START_BTN = "🚀 เริ่มกระบวนการ Dump Instance",
        DUMP_WORKSPACE_BTN = "🏢 Dump ทั้งหมดใน Workspace",
        DUMP_REPLICATED_BTN = "📦 Dump ทั้งหมดใน ReplicatedStorage",

        -- Dump Preview Tab
        PREVIEW_CLEAR_BTN = "🧹 ล้างหน้าจอ Preview",
        PREVIEW_COPY_BTN = "📋 คัดลอกเนื้อหา Preview",
        PREVIEW_SAVE_BTN = "💾 บันทึกเป็นไฟล์ .txt",

        -- Debug Console Tab
        DEBUG_CLEAR_BTN = "🧹 ล้าง Debug Log",
        DEBUG_COPY_BTN = "📋 คัดลอก Log ทั้งหมด",
        DEBUG_SAVE_BTN = "💾 บันทึก Log ลงไฟล์",

        -- Command Matrix Tab
        MATRIX_SECTION = "📁 คลังไมโครโมดูลและสคริปต์สำเร็จรูป",

        -- Settings Tab
        LANG_SECTION = "🌐 เลือกภาษาใช้งาน (LANGUAGE / สลับภาษา)",
        LANG_SWITCH_TH = "🇹🇭 ภาษาไทย (Thai - ใช้งานอยู่)",
        LANG_SWITCH_EN = "🇬🇧 Switch to English",

        SCALE_SECTION = "🖥️ ปรับขนาดหน้าจอ UI",
        SCALE_STD = "🖥️ ขนาดมาตรฐาน (1.0x Scale)",
        SCALE_MOBILE = "📱 ขนาดพกพาสำหรับมือถือ (0.75x Scale)",

        EXT_SECTION = "🛠️ สคริปต์ภายนอกและเครื่องมือพรีเมียม",
        EXT_ANIME_CARD = "🎴 เปิดสคริปต์ PayomboyZ Script HUB",
        EXT_DEX = "🛠️ เปิด Dex Debugging Explorer",
        EXT_IY = "⚡ เปิด Infinite Yield Admin Tools",

        CONFIG_SECTION = "💾 จัดการโปรไฟล์การตั้งค่า",
        CONFIG_SAVE_BTN = "💾 บันทึกโปรไฟล์ปัจจุบัน",
        CONFIG_LOAD_BTN = "📂 โหลดโปรไฟล์ที่บันทึกไว้",

        DIAG_SECTION = "📊 ติดตามประสิทธิภาพและสถานะระบบ",
        CONTROL_SECTION = "❌ ควบคุมระบบ",
        NOTIF_TEST_BTN = "🔔 ทดสอบระบบแจ้งเตือน",
        UNLOAD_HUB_BTN = "❌ ปิดการทำงาน PayomboyZ Hub UI และคืนค่าความจำ",

        -- Notifications
        NOTIF_TITLE = "PayomboyZ สคริปต์ฮับ",
        NOTIF_LOADED = "โหลดระบบประมวลผล Obsidian Glassmorphic 2 เรียบร้อยแล้ว!",
        NOTIF_LANG_CHANGED = "เปลี่ยนภาษาเป็นภาษาไทยเรียบร้อยแล้ว!",
    },
    EN = {
        WINDOW_TITLE = "PayomboyZ Script HUB",
        WINDOW_SUBTITLE = "Obsidian Glassmorphic 2 Core Architecture",
        NAV_HEADER = "SYSTEM MODULES / CATEGORIES",
        STATUS_ACTIVE = "✅ PayomboyZ Active",
        ACTIVE_SERVICE = "ACTIVE SERVICE",
        SYSTEM_VERIFIED = "🛡️ SYSTEM VERIFIED",
        SERVICE_SUB = "Verified client delivery • Premium Automation",

        -- Tabs
        TAB_AI = "✨ Deep AI Engine",
        TAB_EXPLORER = "🔎 Game Explorer",
        TAB_SPY = "📡 Remote Spy",
        TAB_AC = "🛡️ AC Scanner",
        TAB_DUMP = "📦 Instance Dumper",
        TAB_PREVIEW = "👁️ Dump Preview",
        TAB_DEBUG = "🐛 Debug Console",
        TAB_MATRIX = "📁 Command Matrix",
        TAB_SETTINGS = "⚙️ Hub Settings",

        -- AI Tab
        AI_TITLE = "🤖 PayomboyZ Luau Code Synthesizer",
        AI_DESC = "Enter your requirements (e.g. 'Auto farm level' or 'Teleport system'). The AI engine will assemble composite code modules and bind bound game context instances automatically.",
        AI_PLACEHOLDER = "Type code generation prompt here...",
        AI_SYNTHESIZE_BTN = "⚡ Synthesize Luau Code with AI",
        AI_COPY_BTN = "📋 Copy Full Compiled Code",
        AI_CLEAR_BTN = "🧹 Clear Terminal Window",
        AI_SAVE_MATRIX_BTN = "💾 Save to Command Matrix",

        -- Explorer Tab
        EXPLORER_SEARCH_LABEL = "🔎 Search Instances Across Game Services:",
        EXPLORER_SEARCH_PLACEHOLDER = "Type Script, Remote, or Module name...",
        EXPLORER_REFRESH_BTN = "🔄 Refresh Search Results",
        EXPLORER_BIND_CONTEXT_BTN = "🧠 Bind Selected Instance to AI Context",

        -- Remote Spy Tab
        SPY_FILTER_LABEL = "🚫 Skip Remotes/Keywords (Comma separated ,):",
        SPY_CLEAR_BTN = "🧹 Clear Remote Logs",
        SPY_COPY_LOG_BTN = "📋 Copy All Remote Logs",
        SPY_BIND_AI_BTN = "🧠 Bind Captured Remotes to AI Context",

        -- AC Scanner Tab
        AC_SECTION = "🛡️ SCAN ENGINE CONTROLS",
        AC_RUN_SCAN_BTN = "🔍 RUN UNIVERSAL ANTI-CHEAT SCAN",
        AC_SAVE_LOG_BTN = "💾 SAVE SCAN LOG TO FILE",
        AC_CLEAR_LOG_BTN = "🧹 CLEAR SCAN TERMINAL",

        -- Instance Dumper Tab
        DUMP_SECTION = "📦 DUMP DATA & EXPORT SETTINGS",
        DUMP_TARGET_LABEL = "🎯 Select Target Service:",
        DUMP_FOLDER_LABEL = "📁 Export Folder Name:",
        DUMP_OPT_TERRAIN = "🌐 Include Terrain",
        DUMP_OPT_SCRIPTS = "📜 Include Scripts (Decompile)",
        DUMP_OPT_CHARS = "👤 Include Player Characters",
        DUMP_START_BTN = "🚀 Start Instance Dumping Process",
        DUMP_WORKSPACE_BTN = "🏢 Dump Workspace Completely",
        DUMP_REPLICATED_BTN = "📦 Dump ReplicatedStorage Completely",

        -- Dump Preview Tab
        PREVIEW_CLEAR_BTN = "🧹 Clear Preview Terminal",
        PREVIEW_COPY_BTN = "📋 Copy Preview Content",
        PREVIEW_SAVE_BTN = "💾 Save Preview to .txt File",

        -- Debug Console Tab
        DEBUG_CLEAR_BTN = "🧹 Clear Debug Terminal",
        DEBUG_COPY_BTN = "📋 Copy Full System Logs",
        DEBUG_SAVE_BTN = "💾 Save Debug Log to File",

        -- Command Matrix Tab
        MATRIX_SECTION = "📁 MOUNTED MICRO MODULES LIBRARY",

        -- Settings Tab
        LANG_SECTION = "🌐 LANGUAGE SWITCHER / เลือกภาษา",
        LANG_SWITCH_TH = "🇹🇭 Switch to Thai Language",
        LANG_SWITCH_EN = "🇬🇧 English Language (Active)",

        SCALE_SECTION = "🖥️ UI DISPLAY SCALING",
        SCALE_STD = "🖥️ Standard Profile (1.0x Scale)",
        SCALE_MOBILE = "📱 Compact Mobile Profile (0.75x Scale)",

        EXT_SECTION = "🛠️ EXTERNAL UTILITIES & GAME SCRIPTS",
        EXT_ANIME_CARD = "🎴 Launch PayomboyZ Script HUB",
        EXT_DEX = "🛠️ Launch Dex Debugging Explorer",
        EXT_IY = "⚡ Launch Infinite Yield Admin Tools",

        CONFIG_SECTION = "💾 HUB CONFIGURATION & PROFILE MANAGER",
        CONFIG_SAVE_BTN = "💾 Save Current Profile Config",
        CONFIG_LOAD_BTN = "📂 Load Saved Profile Config",

        DIAG_SECTION = "📊 SYSTEM DIAGNOSTICS & PERFORMANCE",
        CONTROL_SECTION = "❌ SYSTEM CONTROL",
        NOTIF_TEST_BTN = "🔔 Test Toast Notification",
        UNLOAD_HUB_BTN = "❌ Unload PayomboyZ Hub UI & Cleanup Connections",

        -- Notifications
        NOTIF_TITLE = "PayomboyZ Script HUB",
        NOTIF_LOADED = "Obsidian Glassmorphic 2 UI Engine Loaded Successfully!",
        NOTIF_LANG_CHANGED = "Language switched to English successfully!",
    }
}

local function GetText(key)
    local langTable = I18N_DICT[CurrentLanguage] or I18N_DICT.TH
    return langTable[key] or I18N_DICT.TH[key] or key
end

local function RegisterI18N(element, key, property, prefix, suffix)
    property = property or "Text"
    prefix = prefix or ""
    suffix = suffix or ""
    if element then
        table.insert(RegisteredLabels, { element = element, key = key, property = property, prefix = prefix, suffix = suffix })
        pcall(function() element[property] = prefix .. GetText(key) .. suffix end)
    end
end

local function SwitchLanguage(newLang)
    if newLang ~= "TH" and newLang ~= "EN" then return end
    CurrentLanguage = newLang
    for _, item in ipairs(RegisteredLabels) do
        if item.element and item.element.Parent then
            pcall(function() item.element[item.property] = item.prefix .. GetText(item.key) .. item.suffix end)
        end
    end
    DebugLog("INFO", "I18N", "Switched language to: " .. CurrentLanguage)
    ObsidianGlassEngine:Notify({
        Title = GetText("NOTIF_TITLE"),
        Content = GetText("NOTIF_LANG_CHANGED"),
        Duration = 3
    })
end

local ObsidianGlassEngine = { Options = {} }

-- UI Sound Effect Helper
local function playClickSound()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://6895079853"
        sound.Volume = 0.3
        sound.Parent = SoundService
        sound:Play()
        sound.Ended:Connect(function() sound:Destroy() end)
    end)
end

local customAvatarAsset = nil
local function loadCustomAvatarImage()
    if customAvatarAsset then return customAvatarAsset end
    local avatarUrl = "https://raw.githubusercontent.com/aslamdunk7/paypmboygang/main/543199739_2812856088914181_3062917809445648175_n.jpg"
    local fileName = "payomboyz_avatar.jpg"
    
    pcall(function()
        if typeof(writefile) == "function" and (typeof(getcustomasset) == "function" or typeof(getsynasset) == "function") then
            local getAsset = getcustomasset or getsynasset
            local isFileExist = (typeof(isfile) == "function" and isfile(fileName))
            if not isFileExist then
                local imageBytes = game:HttpGet(avatarUrl)
                if imageBytes and #imageBytes > 0 then
                    writefile(fileName, imageBytes)
                end
            end
            if typeof(isfile) == "function" and isfile(fileName) then
                customAvatarAsset = getAsset(fileName)
            end
        end
    end)

    if not customAvatarAsset then
        customAvatarAsset = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    end
    return customAvatarAsset
end

-- 🔔 TOAST NOTIFICATION ENGINE
function ObsidianGlassEngine:Notify(cfg)
    pcall(function()
        local title = cfg.Title or "System"
        local content = cfg.Content or ""
        local duration = cfg.Duration or 4
        
        local parentContainer = (typeof(gethui) == "function") and gethui() or CoreGui
        local notifHolder = parentContainer:FindFirstChild("ObsidianGlass_NotifHolder")
        if not notifHolder then
            notifHolder = Instance.new("ScreenGui")
            notifHolder.Name = "ObsidianGlass_NotifHolder"
            notifHolder.ResetOnSpawn = false
            notifHolder.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            notifHolder.Parent = parentContainer
        end
        
        local toast = Instance.new("Frame")
        toast.Size = UDim2.new(0, 300, 0, 65)
        toast.Position = UDim2.new(1, 20, 1, -85)
        toast.BackgroundColor3 = COLORS.glass
        toast.BackgroundTransparency = 0.15
        toast.BorderSizePixel = 0
        toast.Parent = notifHolder
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = toast
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = COLORS.cyan
        stroke.Thickness = 1.5
        stroke.Parent = toast
        
        local tTitle = Instance.new("TextLabel")
        tTitle.Size = UDim2.new(1, -20, 0, 22)
        tTitle.Position = UDim2.new(0, 10, 0, 6)
        tTitle.BackgroundTransparency = 1
        tTitle.Text = title
        tTitle.TextColor3 = COLORS.cyan
        tTitle.Font = Enum.Font.GothamBold
        tTitle.TextSize = 13
        tTitle.TextXAlignment = Enum.TextXAlignment.Left
        tTitle.Parent = toast
        
        local tDesc = Instance.new("TextLabel")
        tDesc.Size = UDim2.new(1, -20, 0, 32)
        tDesc.Position = UDim2.new(0, 10, 0, 26)
        tDesc.BackgroundTransparency = 1
        tDesc.Text = content
        tDesc.TextColor3 = COLORS.text
        tDesc.Font = Enum.Font.Gotham
        tDesc.TextSize = 11
        tDesc.TextWrapped = true
        tDesc.TextXAlignment = Enum.TextXAlignment.Left
        tDesc.Parent = toast
        
        playClickSound()
        TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.new(1, -320, 1, -85) }):Play()
        task.delay(duration, function()
            if toast and toast.Parent then
                local tw = TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Position = UDim2.new(1, 20, 1, -85) })
                tw:Play()
                tw.Completed:Connect(function() toast:Destroy() end)
            end
        end)
    end)
end

-- 🖼️ MAIN WINDOW ENGINE
function ObsidianGlassEngine:CreateWindow(cfg)
    local parentContainer = (typeof(gethui) == "function") and gethui() or CoreGui
    if parentContainer:FindFirstChild("ObsidianGlass2_UI") then
        parentContainer.ObsidianGlass2_UI:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "ObsidianGlass2_UI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 99999
    gui.Parent = parentContainer

    local uiScale = Instance.new("UIScale")
    
    -- Mobile Responsive Scaling Engine
    local camera = workspace.CurrentCamera
    local function updateScale()
        if camera and camera.ViewportSize then
            local vp = camera.ViewportSize
            local targetWidth, targetHeight = 920, 600
            local scaleX = (vp.X - 24) / targetWidth
            local scaleY = (vp.Y - 24) / targetHeight
            local calcScale = math.clamp(math.min(scaleX, scaleY), 0.45, 1.0)
            uiScale.Scale = calcScale
        end
    end
    updateScale()
    if camera then
        camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
    end
    uiScale.Parent = gui

    local shell = Instance.new("Frame")
    shell.Name = "MainShell"
    shell.Size = UDim2.fromOffset(920, 600)
    shell.AnchorPoint = Vector2.new(0.5, 0.5)
    shell.Position = UDim2.new(0.5, 0, 0.5, 0)
    shell.BackgroundColor3 = COLORS.shell
    shell.BackgroundTransparency = 0.20
    shell.BorderSizePixel = 0
    shell.ClipsDescendants = true
    shell.Parent = gui

    local shellCorner = Instance.new("UICorner")
    shellCorner.CornerRadius = UDim.new(0, 18)
    shellCorner.Parent = shell

    local shellStroke = Instance.new("UIStroke")
    shellStroke.Color = COLORS.cyan
    shellStroke.Thickness = 1.5
    shellStroke.Transparency = 0.3
    shellStroke.Parent = shell

    -- 🌐 Cybernetic Data Layer (แทนที่ SnowLayer เดิม)
    local dataLayer = Instance.new("Frame")
    dataLayer.Name = "CyberDataLayer"
    dataLayer.Size = UDim2.fromScale(1, 1)
    dataLayer.BackgroundTransparency = 1
    dataLayer.ZIndex = 2
    dataLayer.Parent = shell

    local cyberParticles = {}
    
    -- สร้าง Particles 2 แบบ: แบบจุด (Nodes) และแบบเส้น (Streams)
    for i = 1, 25 do
        local isLine = math.random() > 0.6 -- 40% เป็นเส้น, 60% เป็นจุด
        local particle = Instance.new("Frame")
        
        if isLine then
            -- แบบเส้นข้อมูล (Data Streams)
            particle.Size = UDim2.fromOffset(math.random(15, 45), math.random(1, 2))
        else
            -- แบบโหนด (Data Nodes)
            particle.Size = UDim2.fromOffset(math.random(2, 4), math.random(2, 4))
            local pCorner = Instance.new("UICorner")
            pCorner.CornerRadius = UDim.new(1, 0)
            pCorner.Parent = particle
        end

        particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
        particle.BackgroundColor3 = (math.random() > 0.5) and COLORS.danger or Color3.fromRGB(230, 40, 50)
        particle.BackgroundTransparency = 1
        particle.BorderSizePixel = 0
        particle.Parent = dataLayer

        table.insert(cyberParticles, {
            frame = particle,
            speedX = (math.random() - 0.5) * 0.0008,
            speedY = (math.random() - 0.5) * 0.0008,
            pulse = math.random(1, 100),
            pulseSpeed = math.random(2, 5) * 0.01
        })
    end

    -- 💎 Draggable Toggle Capsule
    local toggleCapsule = Instance.new("Frame")
    toggleCapsule.Name = "ObsidianToggleCapsule"
    toggleCapsule.Size = UDim2.fromOffset(230, 58)
    toggleCapsule.Position = UDim2.new(0, 15, 0.5, -29)
    toggleCapsule.BackgroundColor3 = COLORS.shell
    toggleCapsule.BackgroundTransparency = 0.18
    toggleCapsule.BorderSizePixel = 0
    toggleCapsule.ClipsDescendants = true
    toggleCapsule.ZIndex = 99999
    toggleCapsule.Parent = gui

    local tcCorner = Instance.new("UICorner")
    tcCorner.CornerRadius = UDim.new(0, 16)
    tcCorner.Parent = toggleCapsule

    local tcStroke = Instance.new("UIStroke")
    tcStroke.Color = COLORS.primary
    tcStroke.Thickness = 1.5
    tcStroke.Transparency = 0.2
    tcStroke.Parent = toggleCapsule

    -- 🌐 Cyber Data Layer for Toggle Capsule
    local capDataLayer = Instance.new("Frame")
    capDataLayer.Name = "CapsuleCyberDataLayer"
    capDataLayer.Size = UDim2.fromScale(1, 1)
    capDataLayer.BackgroundTransparency = 1
    capDataLayer.ZIndex = 1
    capDataLayer.Parent = toggleCapsule

    for i = 1, 10 do
        local isLine = math.random() > 0.6
        local particle = Instance.new("Frame")
        if isLine then
            particle.Size = UDim2.fromOffset(math.random(10, 25), math.random(1, 2))
        else
            particle.Size = UDim2.fromOffset(math.random(2, 3), math.random(2, 3))
            local pCorner = Instance.new("UICorner")
            pCorner.CornerRadius = UDim.new(1, 0)
            pCorner.Parent = particle
        end
        particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
        particle.BackgroundColor3 = (math.random() > 0.5) and COLORS.danger or Color3.fromRGB(230, 40, 50)
        particle.BackgroundTransparency = 1
        particle.BorderSizePixel = 0
        particle.ZIndex = 1
        particle.Parent = capDataLayer

        table.insert(cyberParticles, {
            frame = particle,
            speedX = (math.random() - 0.5) * 0.001,
            speedY = (math.random() - 0.5) * 0.001,
            pulse = math.random(1, 100),
            pulseSpeed = math.random(2, 5) * 0.015
        })
    end

    -- Single Unified RenderStepped Connection for All Particles (Optimized)
    local unifiedParticleConn = TrackConnection(RunService.RenderStepped:Connect(function()
        if not gui or not gui.Parent then return end
        for _, data in ipairs(cyberParticles) do
            if data.frame and data.frame.Parent then
                local curPos = data.frame.Position
                local newX = (curPos.X.Scale + data.speedX) % 1
                local newY = (curPos.Y.Scale + data.speedY) % 1
                data.frame.Position = UDim2.new(newX, 0, newY, 0)

                data.pulse = data.pulse + data.pulseSpeed
                data.frame.BackgroundTransparency = 0.6 + math.sin(data.pulse) * 0.3
            end
        end
    end))

    local capAvatarFrame = Instance.new("Frame")
    capAvatarFrame.Size = UDim2.fromOffset(42, 42)
    capAvatarFrame.Position = UDim2.new(0, 8, 0.5, -21)
    capAvatarFrame.BackgroundColor3 = COLORS.glassDeep
    capAvatarFrame.BorderSizePixel = 0
    capAvatarFrame.ZIndex = 3
    capAvatarFrame.Parent = toggleCapsule

    local caCorner = Instance.new("UICorner")
    caCorner.CornerRadius = UDim.new(1, 0)
    caCorner.Parent = capAvatarFrame

    local caStroke = Instance.new("UIStroke")
    caStroke.Color = COLORS.primary
    caStroke.Thickness = 1.5
    caStroke.Parent = capAvatarFrame

    local capAvatarImg = Instance.new("ImageLabel")
    capAvatarImg.Size = UDim2.fromScale(1, 1)
    capAvatarImg.BackgroundTransparency = 1
    capAvatarImg.Image = loadCustomAvatarImage()
    capAvatarImg.ZIndex = 4
    capAvatarImg.Parent = capAvatarFrame

    local caiCorner = Instance.new("UICorner")
    caiCorner.CornerRadius = UDim.new(1, 0)
    caiCorner.Parent = capAvatarImg

    local capUserLabel = Instance.new("TextLabel")
    capUserLabel.Size = UDim2.new(1, -58, 0, 18)
    capUserLabel.Position = UDim2.new(0, 56, 0, 10)
    capUserLabel.BackgroundTransparency = 1
    capUserLabel.Text = "@" .. LocalPlayer.Name
    capUserLabel.TextColor3 = COLORS.text
    capUserLabel.Font = Enum.Font.GothamBold
    capUserLabel.TextSize = 12
    capUserLabel.TextXAlignment = Enum.TextXAlignment.Left
    capUserLabel.ZIndex = 3
    capUserLabel.Parent = toggleCapsule

    local capMetricsLabel = Instance.new("TextLabel")
    capMetricsLabel.Size = UDim2.new(1, -58, 0, 16)
    capMetricsLabel.Position = UDim2.new(0, 56, 0, 28)
    capMetricsLabel.BackgroundTransparency = 1
    capMetricsLabel.Text = "⚡ 60 FPS  •  📡 0 ms"
    capMetricsLabel.TextColor3 = COLORS.cyan
    capMetricsLabel.Font = Enum.Font.GothamBold
    capMetricsLabel.TextSize = 10
    capMetricsLabel.TextXAlignment = Enum.TextXAlignment.Left
    capMetricsLabel.ZIndex = 3
    capMetricsLabel.Parent = toggleCapsule

    task.spawn(function()
        local frameCount = 0
        local lastFpsTime = tick()
        local fpsVal = 60

        local renderConn
        renderConn = RunService.RenderStepped:Connect(function()
            frameCount = frameCount + 1
            local now = tick()
            if now - lastFpsTime >= 1 then
                fpsVal = frameCount
                frameCount = 0
                lastFpsTime = now
            end
        end)

        while task.wait(0.8) do
            if not gui or not gui.Parent or not toggleCapsule or not toggleCapsule.Parent then
                if renderConn then renderConn:Disconnect() end
                break
            end
            local pingVal = 0
            pcall(function() pingVal = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            capMetricsLabel.Text = string.format("⚡ %d FPS  •  📡 %d ms", fpsVal, pingVal)
        end
    end)

    local capBtn = Instance.new("TextButton")
    capBtn.Size = UDim2.fromScale(1, 1)
    capBtn.BackgroundTransparency = 1
    capBtn.Text = ""
    capBtn.ZIndex = 10
    capBtn.Parent = toggleCapsule

    local tDragging, tDragInput, tDragStart, tStartPos
    local hasDragged = false

    capBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            tDragging = true
            hasDragged = false
            tDragStart = input.Position
            tStartPos = toggleCapsule.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    tDragging = false
                end
            end)
        end
    end)

    capBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            tDragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == tDragInput and tDragging then
            local delta = input.Position - tDragStart
            if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then
                hasDragged = true
            end
            toggleCapsule.Position = UDim2.new(tStartPos.X.Scale, tStartPos.X.Offset + delta.X, tStartPos.Y.Scale, tStartPos.Y.Offset + delta.Y)
        end
    end)

    capBtn.MouseButton1Click:Connect(function()
        if not hasDragged then
            playClickSound()
            shell.Visible = not shell.Visible
        end
    end)

    -- 👤 Left Sidebar
    local userPanel = Instance.new("Frame")
    userPanel.Name = "UserPanel"
    userPanel.Size = UDim2.new(0, 240, 1, 0)
    userPanel.BackgroundColor3 = COLORS.userPanel
    userPanel.BackgroundTransparency = 0.20
    userPanel.BorderSizePixel = 0
    userPanel.ZIndex = 5
    userPanel.Parent = shell

    local userDiv = Instance.new("Frame")
    userDiv.Size = UDim2.new(0, 1, 1, 0)
    userDiv.Position = UDim2.new(1, -1, 0, 0)
    userDiv.BackgroundColor3 = COLORS.glassRaised
    userDiv.BorderSizePixel = 0
    userDiv.ZIndex = 10
    userDiv.Parent = userPanel

    local avatarFrame = Instance.new("Frame")
    avatarFrame.Size = UDim2.fromOffset(44, 44)
    avatarFrame.Position = UDim2.new(0, 14, 0, 14)
    avatarFrame.BackgroundColor3 = COLORS.glassDeep
    avatarFrame.BorderSizePixel = 0
    avatarFrame.ZIndex = 10
    avatarFrame.Parent = userPanel

    local avCorner = Instance.new("UICorner")
    avCorner.CornerRadius = UDim.new(1, 0)
    avCorner.Parent = avatarFrame

    local avStroke = Instance.new("UIStroke")
    avStroke.Color = COLORS.cyan
    avStroke.Thickness = 1.5
    avStroke.Parent = avatarFrame

    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Size = UDim2.fromScale(1, 1)
    avatarImg.BackgroundTransparency = 1
    avatarImg.Image = loadCustomAvatarImage()
    avatarImg.ZIndex = 11
    avatarImg.Parent = avatarFrame

    local avImgCorner = Instance.new("UICorner")
    avImgCorner.CornerRadius = UDim.new(1, 0)
    avImgCorner.Parent = avatarImg

    local onlineDot = Instance.new("Frame")
    onlineDot.Size = UDim2.fromOffset(10, 10)
    onlineDot.Position = UDim2.new(1, -8, 1, -8)
    onlineDot.BackgroundColor3 = COLORS.success
    onlineDot.BorderSizePixel = 0
    onlineDot.ZIndex = 12
    onlineDot.Parent = avatarFrame

    local onlineCorner = Instance.new("UICorner")
    onlineCorner.CornerRadius = UDim.new(1, 0)
    onlineCorner.Parent = onlineDot

    local displayNameLabel = Instance.new("TextLabel")
    displayNameLabel.Size = UDim2.new(1, -75, 0, 18)
    displayNameLabel.Position = UDim2.new(0, 66, 0, 15)
    displayNameLabel.BackgroundTransparency = 1
    displayNameLabel.Text = LocalPlayer.DisplayName
    displayNameLabel.TextColor3 = COLORS.text
    displayNameLabel.Font = Enum.Font.GothamBold
    displayNameLabel.TextSize = 13
    displayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    displayNameLabel.ZIndex = 10
    displayNameLabel.Parent = userPanel

    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Size = UDim2.new(1, -75, 0, 14)
    usernameLabel.Position = UDim2.new(0, 66, 0, 33)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Text = "@" .. LocalPlayer.Name
    usernameLabel.TextColor3 = COLORS.textMuted
    usernameLabel.Font = Enum.Font.Gotham
    usernameLabel.TextSize = 10
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    usernameLabel.ZIndex = 10
    usernameLabel.Parent = userPanel

    local metricsBox = Instance.new("Frame")
    metricsBox.Size = UDim2.new(1, -28, 0, 24)
    metricsBox.Position = UDim2.new(0, 14, 0, 64)
    metricsBox.BackgroundColor3 = COLORS.glassDeep
    metricsBox.BorderSizePixel = 0
    metricsBox.ZIndex = 10
    metricsBox.Parent = userPanel

    local mCorner = Instance.new("UICorner")
    mCorner.CornerRadius = UDim.new(0, 6)
    mCorner.Parent = metricsBox

    local metricsLabel = Instance.new("TextLabel")
    metricsLabel.Size = UDim2.fromScale(1, 1)
    metricsLabel.BackgroundTransparency = 1
    metricsLabel.Text = "⏱️ 00:00  •  📡 0 ms"
    metricsLabel.TextColor3 = COLORS.cyan
    metricsLabel.Font = Enum.Font.GothamBold
    metricsLabel.TextSize = 10
    metricsLabel.ZIndex = 11
    metricsLabel.Parent = metricsBox

    task.spawn(function()
        local startTime = os.time()
        while task.wait(1) do
            if not gui or not gui.Parent then break end
            local elapsed = os.time() - startTime
            local mins = math.floor(elapsed / 60)
            local secs = elapsed % 60
            local ping = 0
            pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            metricsLabel.Text = string.format("⏱️ %02d:%02d  •  📡 %d ms", mins, secs, ping)
        end
    end)

    local sideDiv = Instance.new("Frame")
    sideDiv.Size = UDim2.new(1, -28, 0, 1)
    sideDiv.Position = UDim2.new(0, 14, 0, 96)
    sideDiv.BackgroundColor3 = COLORS.glassRaised
    sideDiv.BorderSizePixel = 0
    sideDiv.ZIndex = 10
    sideDiv.Parent = userPanel

    local navHeader = Instance.new("TextLabel")
    navHeader.Size = UDim2.new(1, -28, 0, 18)
    navHeader.Position = UDim2.new(0, 16, 0, 104)
    navHeader.BackgroundTransparency = 1
    navHeader.Text = GetText("NAV_HEADER")
    navHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
    navHeader.Font = Enum.Font.GothamBold
    navHeader.TextSize = 11
    navHeader.TextXAlignment = Enum.TextXAlignment.Left
    navHeader.ZIndex = 10
    navHeader.Parent = userPanel
    RegisterI18N(navHeader, "NAV_HEADER")

    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Name = "VerticalTabScroll"
    tabScroll.Size = UDim2.new(1, -20, 1, -178)
    tabScroll.Position = UDim2.new(0, 10, 0, 126)
    tabScroll.BackgroundTransparency = 1
    tabScroll.ScrollBarThickness = 3
    tabScroll.ScrollBarImageColor3 = COLORS.cyan
    tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabScroll.ZIndex = 10
    tabScroll.Parent = userPanel

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Vertical
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabScroll

    tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabScroll.CanvasSize = UDim2.new(0, 0, 0, tabLayout.AbsoluteContentSize.Y + 10)
    end)

    local statusCard = Instance.new("Frame")
    statusCard.Size = UDim2.new(1, -24, 0, 36)
    statusCard.Position = UDim2.new(0, 12, 1, -44)
    statusCard.BackgroundColor3 = COLORS.glassDeep
    statusCard.BorderSizePixel = 0
    statusCard.ZIndex = 10
    statusCard.Parent = userPanel

    local stCorner = Instance.new("UICorner")
    stCorner.CornerRadius = UDim.new(0, 8)
    stCorner.Parent = statusCard

    local stTitle = Instance.new("TextLabel")
    stTitle.Size = UDim2.fromScale(1, 1)
    stTitle.BackgroundTransparency = 1
    stTitle.Text = GetText("STATUS_ACTIVE")
    stTitle.TextColor3 = COLORS.success
    stTitle.Font = Enum.Font.GothamBold
    stTitle.TextSize = 12
    stTitle.Parent = statusCard
    RegisterI18N(stTitle, "STATUS_ACTIVE")

    -- 🖥️ Right Main Panel
    local mainPanel = Instance.new("Frame")
    mainPanel.Name = "MainPanel"
    mainPanel.Size = UDim2.new(1, -240, 1, 0)
    mainPanel.Position = UDim2.new(0, 240, 0, 0)
    mainPanel.BackgroundTransparency = 1
    mainPanel.ZIndex = 5
    mainPanel.Parent = shell

    local headerBar = Instance.new("Frame")
    headerBar.Size = UDim2.new(1, 0, 0, 48)
    headerBar.BackgroundTransparency = 1
    headerBar.Parent = mainPanel

    local mainTitle = Instance.new("TextLabel")
    mainTitle.Size = UDim2.new(0, 400, 0, 22)
    mainTitle.Position = UDim2.new(0, 20, 0, 8)
    mainTitle.BackgroundTransparency = 1
    mainTitle.Text = GetText("WINDOW_TITLE")
    mainTitle.TextColor3 = COLORS.text
    mainTitle.Font = Enum.Font.GothamBold
    mainTitle.TextSize = 18
    mainTitle.TextXAlignment = Enum.TextXAlignment.Left
    mainTitle.Parent = headerBar
    RegisterI18N(mainTitle, "WINDOW_TITLE")

    local mainSubTitle = Instance.new("TextLabel")
    mainSubTitle.Size = UDim2.new(0, 400, 0, 16)
    mainSubTitle.Position = UDim2.new(0, 20, 0, 28)
    mainSubTitle.BackgroundTransparency = 1
    mainSubTitle.Text = GetText("WINDOW_SUBTITLE")
    mainSubTitle.TextColor3 = COLORS.textMuted
    mainSubTitle.Font = Enum.Font.Gotham
    mainSubTitle.TextSize = 11
    mainSubTitle.TextXAlignment = Enum.TextXAlignment.Left
    mainSubTitle.Parent = headerBar
    RegisterI18N(mainSubTitle, "WINDOW_SUBTITLE")

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(28, 28)
    closeBtn.Position = UDim2.new(1, -38, 0, 10)
    closeBtn.BackgroundColor3 = COLORS.glass
    closeBtn.BackgroundTransparency = 0.20
    closeBtn.Text = "X"
    closeBtn.TextColor3 = COLORS.textMuted
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = headerBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        playClickSound()
        shell.Visible = not shell.Visible
    end)

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.fromOffset(28, 28)
    minBtn.Position = UDim2.new(1, -72, 0, 10)
    minBtn.BackgroundColor3 = COLORS.glass
    minBtn.BackgroundTransparency = 0.20
    minBtn.Text = "─"
    minBtn.TextColor3 = COLORS.textMuted
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 13
    minBtn.Parent = headerBar

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 8)
    minCorner.Parent = minBtn

    minBtn.MouseButton1Click:Connect(function()
        playClickSound()
        shell.Visible = not shell.Visible
    end)

    local dragging, dragInput, dragStart, startPos
    headerBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = shell.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    headerBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    TrackConnection(UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging and startPos then
            local delta = input.Position - dragStart
            shell.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))

    local serviceBanner = Instance.new("Frame")
    serviceBanner.Size = UDim2.new(1, -40, 0, 65)
    serviceBanner.Position = UDim2.new(0, 20, 0, 48)
    serviceBanner.BackgroundColor3 = COLORS.glassDeep
    serviceBanner.BackgroundTransparency = 0.18
    serviceBanner.BorderSizePixel = 0
    serviceBanner.Parent = mainPanel

    local sCorner = Instance.new("UICorner")
    sCorner.CornerRadius = UDim.new(0, 10)
    sCorner.Parent = serviceBanner

    local sStroke = Instance.new("UIStroke")
    sStroke.Color = COLORS.glassRaised
    sStroke.Thickness = 1
    sStroke.Parent = serviceBanner

    local perfBannerHeader = Instance.new("TextLabel")
    perfBannerHeader.Size = UDim2.new(1, -24, 0, 18)
    perfBannerHeader.Position = UDim2.new(0, 14, 0, 8)
    perfBannerHeader.BackgroundTransparency = 1
    perfBannerHeader.Text = "📊 PERFORMANCE MONITOR V6 (LIVE GLOBAL DIAGNOSTICS)"
    perfBannerHeader.TextColor3 = COLORS.primary
    perfBannerHeader.Font = Enum.Font.GothamBold
    perfBannerHeader.TextSize = 11
    perfBannerHeader.TextXAlignment = Enum.TextXAlignment.Left
    perfBannerHeader.Parent = serviceBanner

    local perfBannerText = Instance.new("TextLabel")
    perfBannerText.Size = UDim2.new(1, -28, 0, 34)
    perfBannerText.Position = UDim2.new(0, 14, 0, 26)
    perfBannerText.BackgroundTransparency = 1
    perfBannerText.Font = Enum.Font.Code
    perfBannerText.TextSize = 10
    perfBannerText.TextColor3 = Color3.fromRGB(160, 245, 210)
    perfBannerText.TextXAlignment = Enum.TextXAlignment.Left
    perfBannerText.TextYAlignment = Enum.TextYAlignment.Top
    perfBannerText.TextWrapped = true
    perfBannerText.Parent = serviceBanner

    task.spawn(function()
        while gui and gui.Parent and perfBannerText and perfBannerText.Parent do
            local memKB = gcinfo()
            local memMB = string.format("%.2f MB", memKB / 1024)
            perfBannerText.Text = string.format(
                "• Memory: %s (%d KB)   • Connections: %d tracked\n• Debug Buffer: %d entries   • Bound AI Contexts: %d",
                memMB, memKB, #TrackedConnections, #DebugLogs, #AIContextEngine.BoundItems
            )
            task.wait(1)
        end
    end)

    local pagesFolder = Instance.new("Frame")
    pagesFolder.Name = "PagesFolder"
    pagesFolder.Size = UDim2.new(1, -40, 1, -128)
    pagesFolder.Position = UDim2.new(0, 20, 0, 120)
    pagesFolder.BackgroundTransparency = 1
    pagesFolder.Parent = mainPanel

    local WindowObj = { Tabs = {}, CurrentTab = nil, MainShell = shell, UIScale = uiScale }

    function WindowObj:AddTab(tabCfg)
        local tabTitleKey = tabCfg.TitleKey
        local tabTitle = tabTitleKey and GetText(tabTitleKey) or tabCfg.Title or "Tab"
        local tabIndex = #WindowObj.Tabs + 1

        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, -6, 0, 40)
        tabBtn.Position = UDim2.new(0, 3, 0, 0)
        tabBtn.BackgroundColor3 = (tabIndex == 1) and COLORS.primary or Color3.fromRGB(38, 16, 24)
        tabBtn.BackgroundTransparency = (tabIndex == 1) and 0.15 or 0.22
        tabBtn.Text = "    " .. tabTitle
        tabBtn.TextColor3 = (tabIndex == 1) and Color3.fromRGB(255, 255, 255) or COLORS.textMuted
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 14
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        tabBtn.AutoButtonColor = false
        tabBtn.ZIndex = 12
        tabBtn.Parent = tabScroll

        if tabTitleKey then
            RegisterI18N(tabBtn, tabTitleKey, "Text", "    ", "")
        end

        local tbCorner = Instance.new("UICorner")
        tbCorner.CornerRadius = UDim.new(0, 8)
        tbCorner.Parent = tabBtn

        local tbStroke = Instance.new("UIStroke")
        tbStroke.Color = (tabIndex == 1) and COLORS.primary or Color3.fromRGB(70, 30, 45)
        tbStroke.Thickness = 1
        tbStroke.Transparency = (tabIndex == 1) and 0 or 0.3
        tbStroke.Parent = tabBtn

        local activeIndicator = Instance.new("Frame")
        activeIndicator.Size = UDim2.new(0, 4, 0, 20)
        activeIndicator.Position = UDim2.new(0, 4, 0.5, -10)
        activeIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        activeIndicator.BorderSizePixel = 0
        activeIndicator.Visible = (tabIndex == 1)
        activeIndicator.Parent = tabBtn

        local indCorner = Instance.new("UICorner")
        indCorner.CornerRadius = UDim.new(1, 0)
        indCorner.Parent = activeIndicator

        local pageScroll = Instance.new("ScrollingFrame")
        pageScroll.Name = "Page_" .. tabTitle
        pageScroll.Size = UDim2.fromScale(1, 1)
        pageScroll.BackgroundTransparency = 1
        pageScroll.ScrollBarThickness = 4
        pageScroll.ScrollBarImageColor3 = COLORS.primary
        pageScroll.Visible = (tabIndex == 1)
        pageScroll.Parent = pagesFolder

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.Padding = UDim.new(0, 8)
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Parent = pageScroll

        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            pageScroll.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 20)
        end)

        local function activateTab()
            playClickSound()
            for _, t in ipairs(WindowObj.Tabs) do
                t.btn.BackgroundColor3 = Color3.fromRGB(38, 16, 24)
                t.btn.BackgroundTransparency = 0.22
                t.btn.TextColor3 = COLORS.textMuted
                t.stroke.Color = Color3.fromRGB(70, 30, 45)
                t.stroke.Transparency = 0.3
                if t.indicator then t.indicator.Visible = false end
                t.page.Visible = false
            end
            tabBtn.BackgroundColor3 = COLORS.primary
            tabBtn.BackgroundTransparency = 0.15
            tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            tbStroke.Color = COLORS.primary
            tbStroke.Transparency = 0
            activeIndicator.Visible = true
            pageScroll.Visible = true
        end

        tabBtn.MouseButton1Click:Connect(activateTab)

        local TabObj = {
            btn = tabBtn,
            stroke = tbStroke,
            indicator = activeIndicator,
            page = pageScroll,
            Select = activateTab
        }

        function TabObj:AddToggle(id, tCfg)
            local title = tCfg.Title or id
            local desc = tCfg.Desc or ""
            local defaultVal = (tCfg.Default ~= nil) and tCfg.Default or false

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -10, 0, desc ~= "" and 55 or 44)
            frame.BackgroundColor3 = COLORS.glassDeep
            frame.BackgroundTransparency = 0.18
            frame.BorderSizePixel = 0
            frame.Parent = pageScroll

            local fCorner = Instance.new("UICorner")
            fCorner.CornerRadius = UDim.new(0, 8)
            fCorner.Parent = frame

            local fStroke = Instance.new("UIStroke")
            fStroke.Color = COLORS.surface
            fStroke.Thickness = 1
            fStroke.Parent = frame

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -70, 0, 22)
            lbl.Position = UDim2.new(0, 12, 0, desc ~= "" and 8 or 11)
            lbl.BackgroundTransparency = 1
            lbl.Text = title
            lbl.TextColor3 = COLORS.text
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = frame

            if desc ~= "" then
                local dLbl = Instance.new("TextLabel")
                dLbl.Size = UDim2.new(1, -70, 0, 18)
                dLbl.Position = UDim2.new(0, 12, 0, 30)
                dLbl.BackgroundTransparency = 1
                dLbl.Text = desc
                dLbl.TextColor3 = COLORS.textMuted
                dLbl.Font = Enum.Font.Gotham
                dLbl.TextSize = 11
                dLbl.TextXAlignment = Enum.TextXAlignment.Left
                dLbl.Parent = frame
            end

            local switch = Instance.new("TextButton")
            switch.Size = UDim2.fromOffset(46, 24)
            switch.Position = UDim2.new(1, -56, 0.5, -12)
            switch.BackgroundColor3 = defaultVal and COLORS.cyan or COLORS.surface
            switch.Text = ""
            switch.Parent = frame

            local swCorner = Instance.new("UICorner")
            swCorner.CornerRadius = UDim.new(1, 0)
            swCorner.Parent = switch

            local knob = Instance.new("Frame")
            knob.Size = UDim2.fromOffset(20, 20)
            knob.Position = defaultVal and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
            knob.BackgroundColor3 = COLORS.text
            knob.BorderSizePixel = 0
            knob.Parent = switch

            local kCorner = Instance.new("UICorner")
            kCorner.CornerRadius = UDim.new(1, 0)
            kCorner.Parent = knob

            local OptionObj = {
                Value = defaultVal,
                Callback = tCfg.Callback or function() end,
                ChangedCallbacks = {}
            }

            local function updateToggle(val)
                playClickSound()
                OptionObj.Value = val
                switch.BackgroundColor3 = val and COLORS.cyan or COLORS.surface
                knob.Position = val and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
                pcall(function() OptionObj.Callback(val) end)
                for _, cb in ipairs(OptionObj.ChangedCallbacks) do pcall(function() cb(val) end) end
            end

            function OptionObj:OnChanged(cb) table.insert(OptionObj.ChangedCallbacks, cb) end
            function OptionObj:SetValue(val) updateToggle(val == true) end

            switch.MouseButton1Click:Connect(function() updateToggle(not OptionObj.Value) end)
            ObsidianGlassEngine.Options[id] = OptionObj
            return OptionObj
        end

        function TabObj:AddSlider(id, sCfg)
            local title = sCfg.Title or id
            local minVal = sCfg.Min or 0
            local maxVal = sCfg.Max or 100
            local defaultVal = sCfg.Default or minVal

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -10, 0, 52)
            frame.BackgroundColor3 = COLORS.glassDeep
            frame.BackgroundTransparency = 0.18
            frame.BorderSizePixel = 0
            frame.Parent = pageScroll

            local fCorner = Instance.new("UICorner")
            fCorner.CornerRadius = UDim.new(0, 8)
            fCorner.Parent = frame

            local fStroke = Instance.new("UIStroke")
            fStroke.Color = COLORS.surface
            fStroke.Thickness = 1
            fStroke.Parent = frame

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.7, 0, 0, 22)
            lbl.Position = UDim2.new(0, 12, 0, 6)
            lbl.BackgroundTransparency = 1
            lbl.Text = title
            lbl.TextColor3 = COLORS.text
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = frame

            local valLbl = Instance.new("TextLabel")
            valLbl.Size = UDim2.new(0.3, -12, 0, 22)
            valLbl.Position = UDim2.new(0.7, 0, 0, 6)
            valLbl.BackgroundTransparency = 1
            valLbl.Text = tostring(defaultVal)
            valLbl.TextColor3 = COLORS.cyan
            valLbl.Font = Enum.Font.GothamBold
            valLbl.TextSize = 14
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Parent = frame

            local bar = Instance.new("TextButton")
            bar.Size = UDim2.new(1, -24, 0, 8)
            bar.Position = UDim2.new(0, 12, 0, 34)
            bar.BackgroundColor3 = COLORS.surface
            bar.Text = ""
            bar.Parent = frame

            local bCorner = Instance.new("UICorner")
            bCorner.CornerRadius = UDim.new(1, 0)
            bCorner.Parent = bar

            local fill = Instance.new("Frame")
            local pct = (defaultVal - minVal) / math.max(maxVal - minVal, 1)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            fill.BackgroundColor3 = COLORS.cyan
            fill.BorderSizePixel = 0
            fill.Parent = bar

            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(1, 0)
            fillCorner.Parent = fill

            local OptionObj = {
                Value = defaultVal,
                Callback = sCfg.Callback or function() end,
                ChangedCallbacks = {}
            }

            local function updateSlider(val)
                val = math.clamp(val, minVal, maxVal)
                if sCfg.Rounding then val = math.floor(val * (10 ^ sCfg.Rounding) + 0.5) / (10 ^ sCfg.Rounding) else val = math.floor(val + 0.5) end
                OptionObj.Value = val
                valLbl.Text = tostring(val)
                local newPct = (val - minVal) / math.max(maxVal - minVal, 1)
                fill.Size = UDim2.new(newPct, 0, 1, 0)
                pcall(function() OptionObj.Callback(val) end)
                for _, cb in ipairs(OptionObj.ChangedCallbacks) do pcall(function() cb(val) end) end
            end

            function OptionObj:OnChanged(cb) table.insert(OptionObj.ChangedCallbacks, cb) end
            function OptionObj:SetValue(val) updateSlider(val) end

            local isDragging = false
            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = true
                    local relX = input.Position.X - bar.AbsolutePosition.X
                    updateSlider(minVal + (relX / bar.AbsoluteSize.X) * (maxVal - minVal))
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local relX = input.Position.X - bar.AbsolutePosition.X
                    updateSlider(minVal + (relX / bar.AbsoluteSize.X) * (maxVal - minVal))
                end
            end)

            ObsidianGlassEngine.Options[id] = OptionObj
            return OptionObj
        end

        function TabObj:AddButton(bCfg)
            local titleKey = bCfg.TitleKey
            local title = titleKey and GetText(titleKey) or bCfg.Title or "Button"
            local cb = bCfg.Callback or function() end
            local isPrimary = string.find(title, "⚡") or string.find(title, "🚀") or string.find(title, "🔍") or bCfg.Style == "primary"

            local normalBg = isPrimary and Color3.fromRGB(0, 140, 80) or Color3.fromRGB(14, 34, 22)
            local hoverBg = isPrimary and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(22, 58, 36)
            local pressBg = isPrimary and Color3.fromRGB(0, 110, 60) or Color3.fromRGB(8, 22, 14)

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 40)
            btn.BackgroundColor3 = normalBg
            btn.BackgroundTransparency = 0.15
            btn.Text = title
            btn.TextColor3 = Color3.fromRGB(240, 255, 245)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 13
            btn.Parent = pageScroll

            if titleKey then
                RegisterI18N(btn, titleKey)
            end

            local bCorner = Instance.new("UICorner")
            bCorner.CornerRadius = UDim.new(0, 8)
            bCorner.Parent = btn

            local bStroke = Instance.new("UIStroke")
            bStroke.Color = isPrimary and COLORS.primary or Color3.fromRGB(24, 80, 48)
            bStroke.Thickness = 1
            bStroke.Parent = btn

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = hoverBg}):Play()
            end)

            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = normalBg}):Play()
            end)

            btn.MouseButton1Down:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundColor3 = pressBg}):Play()
            end)

            btn.MouseButton1Up:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundColor3 = hoverBg}):Play()
            end)

            btn.MouseButton1Click:Connect(function()
                playClickSound()
                pcall(cb)
            end)
            return btn
        end

        function TabObj:AddInput(id, iCfg)
            local title = iCfg.Title or id
            local defaultVal = iCfg.Default or ""

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -10, 0, 48)
            frame.BackgroundColor3 = COLORS.glassDeep
            frame.BackgroundTransparency = 0.18
            frame.BorderSizePixel = 0
            frame.Parent = pageScroll

            local fCorner = Instance.new("UICorner")
            fCorner.CornerRadius = UDim.new(0, 8)
            fCorner.Parent = frame

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.5, 0, 1, 0)
            lbl.Position = UDim2.new(0, 12, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = title
            lbl.TextColor3 = COLORS.text
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = frame

            local box = Instance.new("TextBox")
            box.Size = UDim2.new(0.45, 0, 0, 30)
            box.Position = UDim2.new(0.52, 0, 0.5, -15)
            box.BackgroundColor3 = COLORS.input
            box.BackgroundTransparency = 0.20
            box.Text = tostring(defaultVal)
            box.TextColor3 = COLORS.cyan
            box.Font = Enum.Font.Gotham
            box.TextSize = 13
            box.Parent = frame

            local bxCorner = Instance.new("UICorner")
            bxCorner.CornerRadius = UDim.new(0, 6)
            bxCorner.Parent = box

            local OptionObj = {
                Value = defaultVal,
                Callback = iCfg.Callback or function() end,
                ChangedCallbacks = {}
            }

            box.FocusLost:Connect(function()
                OptionObj.Value = box.Text
                pcall(function() OptionObj.Callback(box.Text) end)
                for _, cb in ipairs(OptionObj.ChangedCallbacks) do pcall(function() cb(box.Text) end) end
            end)

            function OptionObj:OnChanged(cb) table.insert(OptionObj.ChangedCallbacks, cb) end
            function OptionObj:SetValue(val) box.Text = tostring(val); OptionObj.Value = tostring(val) end

            ObsidianGlassEngine.Options[id] = OptionObj
            return OptionObj
        end

        function TabObj:AddSection(titleOrKey, fallbackTitle)
            local sec = Instance.new("TextLabel")
            sec.Size = UDim2.new(1, -10, 0, 30)
            sec.BackgroundTransparency = 1
            sec.TextColor3 = COLORS.cyan
            sec.Font = Enum.Font.GothamBold
            sec.TextSize = 14
            sec.Parent = pageScroll

            if I18N_DICT.TH[titleOrKey] or I18N_DICT.EN[titleOrKey] then
                RegisterI18N(sec, titleOrKey, "Text", "──  ", "  ──")
            else
                local disp = fallbackTitle or titleOrKey
                sec.Text = "──  " .. disp .. "  ──"
            end
            return sec
        end

        function TabObj:AddParagraph(pCfg)
            local title = pCfg.Title or ""
            local desc = pCfg.Desc or ""

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -10, 0, 54)
            frame.BackgroundColor3 = COLORS.glassDeep
            frame.BackgroundTransparency = 0.18
            frame.BorderSizePixel = 0
            frame.Parent = pageScroll

            local fCorner = Instance.new("UICorner")
            fCorner.CornerRadius = UDim.new(0, 8)
            fCorner.Parent = frame

            local pTitle = Instance.new("TextLabel")
            pTitle.Size = UDim2.new(1, -20, 0, 22)
            pTitle.Position = UDim2.new(0, 10, 0, 6)
            pTitle.BackgroundTransparency = 1
            pTitle.Text = title
            pTitle.TextColor3 = COLORS.text
            pTitle.Font = Enum.Font.GothamBold
            pTitle.TextSize = 13
            pTitle.TextXAlignment = Enum.TextXAlignment.Left
            pTitle.Parent = frame

            local pDesc = Instance.new("TextLabel")
            pDesc.Size = UDim2.new(1, -20, 0, 24)
            pDesc.Position = UDim2.new(0, 10, 0, 26)
            pDesc.BackgroundTransparency = 1
            pDesc.Text = desc
            pDesc.TextColor3 = COLORS.textMuted
            pDesc.Font = Enum.Font.Gotham
            pDesc.TextSize = 11
            pDesc.TextWrapped = true
            pDesc.TextXAlignment = Enum.TextXAlignment.Left
            pDesc.Parent = frame
            return frame
        end

        table.insert(WindowObj.Tabs, TabObj)
        return TabObj
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.K then
            playClickSound()
            shell.Visible = not shell.Visible
        elseif input.KeyCode == Enum.KeyCode.F then
            playClickSound()
            uiScale.Scale = (uiScale.Scale == 1.0) and 0.85 or 1.0
        end
    end)

    return WindowObj
end

-----------------------------------------------------------------------------------------
-- 🧠 HIGH-INTELLIGENCE PARSING DICTIONARY
-----------------------------------------------------------------------------------------
local SemanticPatterns = {
    -- 1. VISUALS / ESP CATEGORY
    {
        Keywords = {"esp", "box", "skeleton", "health", "name", "item", "chest", "ore", "npc", "tracer", "cham", "xray", "radar", "minimap", "distance", "fov", "fullbright", "vision", "fog", "crosshair", "มองทะลุ", "มองคน", "มองกล่อง", "มองแร่", "เนมแท็ก", "หลอดเลือด", "เรดาร์"},
        Title = "Visuals_ESP_Framework",
        Code = [[local Players = game:GetService("Players")
local function applyHighlight(player)
    if player ~= Players.LocalPlayer and player.Character then
        local highlight = player.Character:FindFirstChildOfClass("Highlight") or Instance.new("Highlight")
        highlight.FillColor = Color3.fromRGB(255, 0, 100)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.4
        highlight.Parent = player.Character
    end
end
for _, p in ipairs(Players:GetPlayers()) do applyHighlight(p) end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(0.5); applyHighlight(p) end) end)
print("PayomboyZ AI: Visual Matrix and ESP Highlights Enabled.")]]
    },
    -- 2. FARMING / AUTOMATION CATEGORY
    {
        Keywords = {"farm", "collect", "sell", "buy", "upgrade", "quest", "spin", "roll", "fish", "mine", "chop", "harvest", "hatch", "craft", "rebirth", "prestige", "claim", "open", "pickup", "deposit", "ฟาร์ม", "ออโต้ฟาร์ม", "เก็บของ", "ปั๊ม", "ตีมอน", "ขุด", "ตกปลา", "กดเอฟ", "ซื้อของ"},
        Title = "Automation_Engine",
        Code = [[local Running = true
task.spawn(function()
    while Running do
        task.wait(0.5)
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                fireproximityprompt(obj)
            elseif obj:IsA("TouchTransmitter") and obj.Parent then
                firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, obj.Parent, 0)
                firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, obj.Parent, 1)
            end
        end
    end
end)
print("PayomboyZ AI: Automation & Framework Cycle Enabled.")]]
    },
    -- 3. PLAYER UTILITIES CATEGORY
    {
        Keywords = {"god", "afk", "ragdoll", "stun", "knockback", "fling", "void", "stamina", "energy", "oxygen", "fall", "respawn", "revive", "freeze", "unfreeze", "invisible", "lock", "freecam", "spectate", "fps", "อมตะ", "ไม่ตาย", "เลือดไม่ลด", "ลบดาเมจ", "รีเซ็ต"},
        Title = "Player_Utilities_Modifier",
        Code = [[local LocalPlayer = game.Players.LocalPlayer
local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Hum = Char:WaitForChild("Humanoid")
Hum.MaxHealth = math.huge
Hum.Health = math.huge
if Char:FindFirstChild("HumanoidRootPart") then
    local Root = Char.HumanoidRootPart
    local AntiVelocity = game:GetService("RunService").Heartbeat:Connect(function()
        if Root then
            local vel = Root.AssemblyLinearVelocity
            Root.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
        end
    end)
end
print("PayomboyZ AI: God-State & Anti-Debuff Framework Initialized.")]]
    },
    -- 4. MOVEMENT CATEGORY
    {
        Keywords = {"fly", "noclip", "speed", "sprint", "jump", "climb", "run", "dash", "slide", "teleport", "blink", "glide", "hover", "swim", "gravity", "hop", "parkour", "phase", "บิน", "เหาะ", "ลอย", "ลอยตัว", "วิ่งเร็ว", "เดินเร็ว", "กระโดดสูง", "ทะลุกำแพง", "เดินทะลุ", "วาป", "วาร์ป", "ย้าย"},
        Title = "Kinematic_Movement_Engine",
        Code = [[local LocalPlayer = game.Players.LocalPlayer
local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Hum = Char:WaitForChild("Humanoid")
Hum.WalkSpeed = 60
Hum.JumpPower = 100
local NoclipLoop = game:GetService("RunService").Stepped:Connect(function()
    for _, part in ipairs(Char:GetChildren()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
end)
print("PayomboyZ AI: Kinematic Movement speed & Noclip modules deployed.")]]
    },
    -- 5. MISCELLANEOUS UTILITIES
    {
        Keywords = {"hub", "menu", "admin", "spy", "remote", "server", "hop", "rejoin", "id", "bring", "save", "waypoint", "notification", "key", "config", "macro", "clicker", "lag", "booster", "player", "emote", "skin", "pet", "inventory", "ฮับ", "เมนู", "แอดมิน", "โปร", "รีโมท", "ดัก"},
        Title = "Utility_Matrix_Pack",
        Code = [[print("PayomboyZ AI: Generating Diagnostic Utility Pack configurations...")
local LogService = game:GetService("LogService")
LogService.MessageOut:Connect(function(message, messageType)
    if string.find(string.lower(message), "remote") or string.find(string.lower(message), "fire") then
        print("[Remote Diagnostic Monitor]: " .. message)
    end
end)
print("PayomboyZ AI: Miscellaneous Matrix and Remote Interceptors Online.")]]
    },
    -- 6. COMBAT / AIM ASSIST
    {
        Keywords = {"aim", "lock", "hitbox", "size", "extend", "killaur", "aura", "attack", "ล็อกเป้า", "ล็อกหัว", "ยิงหัว", "ฮิตบ็อกซ์", "ขยายเป้า", "ออร่า", "ฟันอัตโนมัติ"},
        Title = "Targeting_Combat_Matrix",
        Code = [[local Camera = workspace.CurrentCamera
local LocalPlayer = game.Players.LocalPlayer
local FOVRadius = 150
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Radius = FOVRadius
FOVCircle.Color = Color3.fromRGB(0, 255, 140)
FOVCircle.Visible = true
FOVCircle.Filled = false
game:GetService("RunService").RenderStepped:Connect(function()
    FOVCircle.Position = game:GetService("UserInputService"):GetMouseLocation()
end)
print("PayomboyZ AI: Core Target Acquisition Matrix Online.")]]
    },
    -- 7. WEAPONS / TOOLS MATRIX SYSTEM
    {
        Keywords = {
            "sword", "katana", "greatsword", "longsword", "shortsword", "rapier", "dagger", "dual daggers", "scythe", "battle axe", 
            "war axe", "tomahawk", "hammer", "war hammer", "mace", "morning star", "spear", "pike", "halberd", "trident", "lance", 
            "club", "staff", "magic staff", "wand", "bow", "longbow", "crossbow", "slingshot", "throwing knife", "throwing axe", 
            "boomerang", "chakram", "shuriken", "kunai", "whip", "chain whip", "energy blade", "plasma sword", "laser saber", 
            "fire sword", "ice blade", "thunder hammer", "shadow blade", "crystal sword", "poison dagger", "venom fang", 
            "dragon blade", "phoenix staff", "frost axe", "lava hammer", "wind blade", "earth mace", "light spear", "dark scythe", 
            "soul reaper", "moon blade", "sun staff", "star wand", "galaxy sword", "void blade", "blood scythe", "bone club", 
            "spirit staff", "rune sword", "mythic axe", "ancient spear", "pirate cutlass", "viking axe", "samurai katana", 
            "ninja blade", "knight sword", "gladiator spear", "tribal club", "crystal bow", "ember bow", "ice bow", "storm bow", 
            "shadow bow", "hunter crossbow", "mystic wand", "arcane staff", "battle staff", "energy cannon", "blaster", 
            "laser rifle", "plasma cannon", "ray gun", "magic orb", "spell book", "cursed tome", "flame orb", "frost orb", 
            "lightning orb", "meteor staff", "comet blade", "eclipse sword", "inferno blade", "celestial spear", "chaos blade"
        },
        Title = "Weapon_Tool_Synthesizer",
        Code = [[local textInput = string.lower(PromptInput and PromptInput.Text or "sword")
local matchedName = textInput ~= "" and textInput or "Engine Blade"
local plyr = game.Players.LocalPlayer
local bpack = plyr:WaitForChild("Backpack")

local newTool = Instance.new("Tool")
newTool.Name = "⚔️ " .. string.upper(matchedName)
newTool.RequiresHandle = true

local handle = Instance.new("Part")
handle.Name = "Handle"
handle.Material = Enum.Material.Neon
handle.BrickColor = BrickColor.new("Electric Blue")
handle.Parent = newTool

local isGun = string.find(textInput, "cannon") or string.find(textInput, "blaster") or string.find(textInput, "rifle") or string.find(textInput, "gun") or string.find(textInput, "bow") or string.find(textInput, "wand") or string.find(textInput, "staff")

if isGun then
    handle.Size = Vector3.new(0.4, 1.2, 2.5)
    newTool.Name = "💥 " .. string.upper(matchedName)
else
    handle.Size = Vector3.new(0.4, 4.2, 0.4)
end

if string.find(textInput, "fire") or string.find(textInput, "flame") or string.find(textInput, "inferno") or string.find(textInput, "lava") or string.find(textInput, "ember") then
    handle.BrickColor = BrickColor.new("Bright Red")
    local fire = Instance.new("Fire")
    fire.Size = 5
    fire.Parent = handle
elseif string.find(textInput, "plasma") or string.find(textInput, "laser") or string.find(textInput, "energy") then
    handle.BrickColor = BrickColor.new("Lime green")
elseif string.find(textInput, "shadow") or string.find(textInput, "void") or string.find(textInput, "dark") then
    handle.BrickColor = BrickColor.new("Really black")
end

newTool.Activated:Connect(function()
    local char = plyr.Character
    if not char then return end
    
    if isGun then
        local mouse = plyr:GetMouse()
        local startPos = handle.Position
        local targetPos = mouse.Hit.p
        local direction = (targetPos - startPos).Unit * 300
        
        local raycastParams = RaycastParams.new()
        raycastParams.FilterPlayers = {plyr}
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        
        local raycastResult = workspace:Raycast(startPos, direction, raycastParams)
        
        local beam = Instance.new("Part")
        beam.Material = Enum.Material.Neon
        beam.BrickColor = handle.BrickColor
        beam.Anchored = true
        beam.CanCollide = false
        
        local endPos = raycastResult and raycastResult.Position or (startPos + direction)
        local distance = (startPos - endPos).Magnitude
        beam.Size = Vector3.new(0.15, 0.15, distance)
        beam.CFrame = CFrame.new(startPos:Lerp(endPos, 0.5), endPos)
        beam.Parent = workspace
        game:GetService("Debris"):AddItem(beam, 0.15)
        
        if raycastResult and raycastResult.Instance then
            local hitChar = raycastResult.Instance:FindFirstAncestorOfClass("Model")
            local hitHum = hitChar and hitChar:FindFirstChildOfClass("Humanoid")
            if hitHum and hitHum ~= char.Humanoid then
                hitHum.Health = 0 
                print("PayomboyZ Combat: Bullet neutralized " .. hitChar.Name)
            end
        end
    else
        local damageConn
        damageConn = handle.Touched:Connect(function(hit)
            local hitChar = hit:FindFirstAncestorOfClass("Model")
            local hitHum = hitChar and hitChar:FindFirstChildOfClass("Humanoid")
            if hitHum and hitHum ~= char.Humanoid then
                hitHum.Health = 0
                print("PayomboyZ Combat: Melee weapon neutralized " .. hitChar.Name)
                if damageConn then damageConn:Disconnect() end
            end
        end)
        task.wait(0.4)
        if damageConn then damageConn:Disconnect() end
    end
end)

newTool.Parent = bpack
print("PayomboyZ AI System: Synthesized functional weapon module ["..matchedName.."] safely into backpack.")]]
    }
}

-----------------------------------------------------------------------------------------
-- 🚀 BUILD PAYOMBOYZ AI GENERATE INTERFACE
-----------------------------------------------------------------------------------------

local Window = ObsidianGlassEngine:CreateWindow({
    Title = "PayomboyZ Script HUB",
    SubTitle = "Obsidian Glassmorphic 2 Core Architecture",
})

local AiTab = Window:AddTab({ TitleKey = "TAB_AI", Title = "✨ สร้างโค้ด AI" })
local ExplorerTab = Window:AddTab({ TitleKey = "TAB_EXPLORER", Title = "🔎 สำรวจโครงสร้างเกม" })
local SpyTab = Window:AddTab({ TitleKey = "TAB_SPY", Title = "📡 ดักจับ Remote Spy" })
local AcTab = Window:AddTab({ TitleKey = "TAB_AC", Title = "🛡️ สแกน Anti-Cheat" })
local DumpTab = Window:AddTab({ TitleKey = "TAB_DUMP", Title = "📦 เครื่องมือ Dump" })
local PreviewTab = Window:AddTab({ TitleKey = "TAB_PREVIEW", Title = "👁️ ตัวอย่างไฟล์ Dump" })
local DebugTab = Window:AddTab({ TitleKey = "TAB_DEBUG", Title = "🐛 เทอร์มินัลระบบ (Debug)" })
local LibraryTab = Window:AddTab({ TitleKey = "TAB_MATRIX", Title = "📁 คลังคำสั่ง (Matrix)" })
local SettingsTab = Window:AddTab({ TitleKey = "TAB_SETTINGS", Title = "⚙️ ตั้งค่าระบบ" })

-----------------------------------------------------------------------------------------
-- 🛡️ UNIVERSAL ANTI-CHEAT SCANNER v2.0 (WITH LOG FILE SUPPORT)
-----------------------------------------------------------------------------------------

local AcResults = {}
local AcLogBox = nil

local function getAllDescendants(instance)
    local list = {}
    local function recurse(obj)
        for _, child in ipairs(obj:GetChildren()) do
            table.insert(list, child)
            recurse(child)
        end
    end
    recurse(instance)
    return list
end

local function calculateHeuristicSuspicion(obj, namePatterns)
    local name = obj.Name:lower()
    local path = obj:GetFullName():lower()
    local reasons = {}
    local score = 0

    if name:find("anti") or name:find("cheat") or name:find("exploit") or name:find("detection") then
        score = score + 35
        table.insert(reasons, "✓ Critical Keyword Match (" .. obj.Name .. ")")
    else
        for _, pattern in ipairs(namePatterns) do
            if name:find(pattern, 1, true) then
                score = score + 15
                table.insert(reasons, "✓ Name Match ('" .. pattern .. "')")
                break
            end
        end
    end

    if obj:IsA("LocalScript") then
        score = score + 25
        table.insert(reasons, "✓ LocalScript (Client Context)")
    elseif obj:IsA("ModuleScript") then
        score = score + 15
        table.insert(reasons, "✓ ModuleScript (Shared Logic)")
    elseif obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        score = score + 20
        table.insert(reasons, "✓ Remote Indicator (" .. obj.ClassName .. ")")
    end

    if path:find("starterplayer") or path:find("playerscripts") then
        score = score + 20
        table.insert(reasons, "✓ Path Indicator (PlayerScripts)")
    elseif path:find("replicatedfirst") then
        score = score + 20
        table.insert(reasons, "✓ Path Indicator (ReplicatedFirst Bootloader)")
    end

    score = math.min(100, score)
    local levelTag = "🟢 LOW"
    if score >= 70 then
        levelTag = "🔴 HIGH"
    elseif score >= 40 then
        levelTag = "🟡 MEDIUM"
    end

    return score, levelTag, reasons
end

local function scanForAC(instance, namePatterns)
    local found = {}
    local okDesc, descendants = pcall(function() return instance:GetDescendants() end)
    if not okDesc or not descendants then return found end

    for _, obj in ipairs(descendants) do
        if obj:IsA("LocalScript") or obj:IsA("ModuleScript") or obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("Script") then
            local score, levelTag, reasons = calculateHeuristicSuspicion(obj, namePatterns)
            if score >= 35 and #reasons > 0 then
                table.insert(found, {
                    Path = obj:GetFullName(),
                    Class = obj.ClassName,
                    Name = obj.Name,
                    Confidence = score,
                    Tag = levelTag,
                    Reasons = table.concat(reasons, " | ")
                })
            end
        end
    end
    return found
end

local function performAcScan()
    local services = {
        game:GetService("ReplicatedStorage"),
        game:GetService("StarterPlayer"),
        game:GetService("StarterGui"),
        game:GetService("StarterPack"),
        game:GetService("Players"),
        game:GetService("Workspace")
    }

    local patterns = {
        "anti", "cheat", "valid", "integrity",
        "check", "exploit", "detection", "protection",
        "secure", "verify", "auth", "guard",
        "monitor", "track", "prevent", "block"
    }

    local allResults = {}
    local logLines = {
        "═══════════════════════════════════════════════════════",
        "[HEURISTIC SUSPICION SCANNER v2.0 - CONFIDENCE ENGINE]",
        "Game PlaceId: " .. tostring(game.PlaceId),
        "Scan Time: " .. os.date("%Y-%m-%d %H:%M:%S"),
        "═══════════════════════════════════════════════════════"
    }

    DebugLog("INFO", "AC_SCAN", "Starting universal anti-cheat scan across game services...")

    for _, svc in ipairs(services) do
        if svc then
            table.insert(logLines, "\n[SCAN] " .. svc.Name .. ":")
            local res = scanForAC(svc, patterns)
            if #res > 0 then
                for _, item in ipairs(res) do
                    local entryStr = string.format("  %s [%d%% CONFIDENCE] %s (%s) | Patterns: %s", item.Tag, item.Confidence, item.Path, item.Class, item.Reasons)
                    table.insert(logLines, entryStr)
                    table.insert(allResults, item)
                    DebugLog("WARN", "AC_DETECTION", string.format("Found %s (%d%%): %s", item.Tag, item.Confidence, item.Path))
                end
            else
                table.insert(logLines, "  (No suspect scripts detected in " .. svc.Name .. ")")
            end
        end
    end

    table.insert(logLines, "\n═══════════════════════════════════════════════════════")
    table.insert(logLines, "[SUMMARY] DETECTED ANTI-CHEAT INSTANCES: " .. tostring(#allResults))
    table.insert(logLines, "═══════════════════════════════════════════════════════")
    for i, item in ipairs(allResults) do
        table.insert(logLines, string.format("  %d. %s [%d%% CONFIDENCE] %s (%s)", i, item.Tag, item.Confidence, item.Path, item.Class))
    end
    table.insert(logLines, "═══════════════════════════════════════════════════════")

    AcResults = allResults
    return allResults, table.concat(logLines, "\n")
end

-- ======================================================================================
-- 🛡️ ANTI-CHEAT SCANNER TAB BUILDER
-- ======================================================================================

AcTab:AddSection("SCAN ENGINE CONTROLS")

AcTab:AddButton({
    Title = "🔍 RUN HEURISTIC SUSPICION SCANNER",
    Callback = function()
        if AcLogBox then AcLogBox.Text = "[Scan Engine] Initiating Heuristic Suspicion Deep Scan...\n" end
        task.spawn(function()
            local results, logText = performAcScan()
            if AcLogBox then AcLogBox.Text = logText end
            
            -- Auto save log to file & clipboard
            local folderName = "ValenHub_Dumps/AntiCheatLogs"
            if typeof(makefolder) == "function" then
                pcall(function() makefolder("ValenHub_Dumps") end)
                pcall(function() makefolder(folderName) end)
            end
            local fileName = folderName .. "/ACScan_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"
            if typeof(writefile) == "function" then pcall(function() writefile(fileName, logText) end) end
            if typeof(setclipboard) == "function" then pcall(function() setclipboard(logText) end) end

            ObsidianGlassEngine:Notify({
                Title = "Heuristic Scan Complete",
                Content = "Identified " .. #results .. " suspicious indicators! Log saved to " .. fileName,
                Duration = 5
            })
        end)
    end
})

AcTab:AddSection("ANTI-CHEAT SCAN LOG OUTPUT")

local acLogCard = Instance.new("Frame")
acLogCard.Size = UDim2.new(1, -10, 0, 180)
acLogCard.BackgroundColor3 = COLORS.glassDeep
acLogCard.BackgroundTransparency = 0.18
acLogCard.BorderSizePixel = 0
acLogCard.Parent = AcTab.page

local alcCorner = Instance.new("UICorner")
alcCorner.CornerRadius = UDim.new(0, 8)
alcCorner.Parent = acLogCard

local alcStroke = Instance.new("UIStroke")
alcStroke.Color = COLORS.surface
alcStroke.Thickness = 1
alcStroke.Parent = acLogCard

local acScroll = Instance.new("ScrollingFrame")
acScroll.Size = UDim2.new(1, -12, 1, -12)
acScroll.Position = UDim2.new(0, 6, 0, 6)
acScroll.BackgroundColor3 = COLORS.input
acScroll.BackgroundTransparency = 0.30
acScroll.BorderSizePixel = 0
acScroll.ScrollBarThickness = 5
acScroll.ScrollBarImageColor3 = COLORS.primary
acScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
acScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
acScroll.Parent = acLogCard

local acsCorner = Instance.new("UICorner")
acsCorner.CornerRadius = UDim.new(0, 6)
acsCorner.Parent = acScroll

AcLogBox = Instance.new("TextBox")
AcLogBox.Size = UDim2.new(1, -10, 1, 0)
AcLogBox.Position = UDim2.new(0, 5, 0, 0)
AcLogBox.BackgroundTransparency = 1
AcLogBox.PlaceholderText = "-- Press 'RUN UNIVERSAL ANTI-CHEAT SCAN' to start scanning..."
AcLogBox.Text = ""
AcLogBox.Font = Enum.Font.Code
AcLogBox.TextSize = 11
AcLogBox.TextColor3 = Color3.fromRGB(255, 200, 100)
AcLogBox.MultiLine = true
AcLogBox.ClearTextOnFocus = false
AcLogBox.TextXAlignment = Enum.TextXAlignment.Left
AcLogBox.TextYAlignment = Enum.TextYAlignment.Top
AcLogBox.AutomaticSize = Enum.AutomaticSize.Y
AcLogBox.Parent = acScroll

local albPad = Instance.new("UIPadding")
albPad.PaddingLeft = UDim.new(0, 4)
albPad.PaddingTop = UDim.new(0, 4)
albPad.Parent = AcLogBox

AcTab:AddSection("LOG EXPORT & UTILITIES")

AcTab:AddButton({
    Title = "💾 Save Scan Log to File Manually",
    Callback = function()
        if AcLogBox and AcLogBox.Text ~= "" then
            local folderName = "ValenHub_Dumps/AntiCheatLogs"
            if typeof(makefolder) == "function" then
                pcall(function() makefolder("ValenHub_Dumps") end)
                pcall(function() makefolder(folderName) end)
            end
            local fileName = folderName .. "/ACScan_Manual_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"
            if typeof(writefile) == "function" then pcall(function() writefile(fileName, AcLogBox.Text) end) end
            if typeof(setclipboard) == "function" then pcall(function() setclipboard(AcLogBox.Text) end) end
            ObsidianGlassEngine:Notify({ Title = "File Saved", Content = "Saved scan report to " .. fileName, Duration = 4 })
        else
            ObsidianGlassEngine:Notify({ Title = "Warning", Content = "Scan log is empty!", Duration = 3 })
        end
    end
})

AcTab:AddButton({
    Title = "📋 Copy Scan Log to Clipboard",
    Callback = function()
        if AcLogBox and AcLogBox.Text ~= "" then
            if typeof(setclipboard) == "function" then
                pcall(function() setclipboard(AcLogBox.Text) end)
                ObsidianGlassEngine:Notify({ Title = "Copied", Content = "Copied scan log to clipboard!", Duration = 3 })
            end
        else
            ObsidianGlassEngine:Notify({ Title = "Warning", Content = "Scan log is empty!", Duration = 3 })
        end
    end
})


-----------------------------------------------------------------------------------------
-- 🔎 GAME INTELLIGENCE & MODULE EXPLORER TAB BUILDER
-----------------------------------------------------------------------------------------

ExplorerTab:AddSection("GAME INTELLIGENCE SEARCH ENGINE")

local explorerCard = Instance.new("Frame")
explorerCard.Size = UDim2.new(1, -10, 0, 72)
explorerCard.BackgroundColor3 = COLORS.glassDeep
explorerCard.BackgroundTransparency = 0.18
explorerCard.BorderSizePixel = 0
explorerCard.Parent = ExplorerTab.page

local ecCorner = Instance.new("UICorner")
ecCorner.CornerRadius = UDim.new(0, 8)
ecCorner.Parent = explorerCard

local ecStroke = Instance.new("UIStroke")
ecStroke.Color = COLORS.surface
ecStroke.Thickness = 1
ecStroke.Parent = explorerCard

local expLabel = Instance.new("TextLabel")
expLabel.Size = UDim2.new(1, -24, 0, 20)
expLabel.Position = UDim2.new(0, 12, 0, 8)
expLabel.BackgroundTransparency = 1
expLabel.Text = "ENTER INSTANCE / MODULE / REMOTE QUERY"
expLabel.TextColor3 = COLORS.textMuted
expLabel.Font = Enum.Font.GothamBold
expLabel.TextSize = 11
expLabel.TextXAlignment = Enum.TextXAlignment.Left
expLabel.Parent = explorerCard

local ExplorerSearchInput = Instance.new("TextBox")
ExplorerSearchInput.Size = UDim2.new(1, -24, 0, 34)
ExplorerSearchInput.Position = UDim2.new(0, 12, 0, 30)
ExplorerSearchInput.BackgroundColor3 = COLORS.input
ExplorerSearchInput.BackgroundTransparency = 0.20
ExplorerSearchInput.PlaceholderText = "e.g. 'Egg', 'NET_MAP', 'Remote', 'Quest', 'Pet', 'Data'"
ExplorerSearchInput.Text = "Egg"
ExplorerSearchInput.Font = Enum.Font.GothamSemibold
ExplorerSearchInput.TextSize = 12
ExplorerSearchInput.TextColor3 = COLORS.primary
ExplorerSearchInput.ClearTextOnFocus = false
ExplorerSearchInput.TextXAlignment = Enum.TextXAlignment.Left
ExplorerSearchInput.Parent = explorerCard

local esiCorner = Instance.new("UICorner")
esiCorner.CornerRadius = UDim.new(0, 6)
esiCorner.Parent = ExplorerSearchInput

local esiPad = Instance.new("UIPadding")
esiPad.PaddingLeft = UDim.new(0, 10)
esiPad.Parent = ExplorerSearchInput

ExplorerTab:AddSection("DISCOVERED OBJECTS & BOUND CONTEXT")

local explorerResultsScroll = Instance.new("ScrollingFrame")
explorerResultsScroll.Size = UDim2.new(1, -10, 0, 220)
explorerResultsScroll.BackgroundColor3 = COLORS.glassDeep
explorerResultsScroll.BackgroundTransparency = 0.18
explorerResultsScroll.BorderSizePixel = 0
explorerResultsScroll.ScrollBarThickness = 5
explorerResultsScroll.ScrollBarImageColor3 = COLORS.primary
explorerResultsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
explorerResultsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
explorerResultsScroll.Parent = ExplorerTab.page

local ersCorner = Instance.new("UICorner")
ersCorner.CornerRadius = UDim.new(0, 8)
ersCorner.Parent = explorerResultsScroll

local ersLayout = Instance.new("UIListLayout")
ersLayout.SortOrder = Enum.SortOrder.LayoutOrder
ersLayout.Padding = UDim.new(0, 6)
ersLayout.Parent = explorerResultsScroll

local ersPad = Instance.new("UIPadding")
ersPad.PaddingLeft = UDim.new(0, 6)
ersPad.PaddingRight = UDim.new(0, 6)
ersPad.PaddingTop = UDim.new(0, 6)
ersPad.PaddingBottom = UDim.new(0, 6)
ersPad.Parent = explorerResultsScroll

local function clearExplorerResults()
    for _, child in ipairs(explorerResultsScroll:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
    end
end

local function renderExplorerResults(query)
    clearExplorerResults()
    if not query or query == "" then return end
    
    local searchLower = query:lower()
    local searchServices = {
        game:GetService("ReplicatedStorage"),
        game:GetService("Workspace"),
        game:GetService("Players"),
        game:GetService("StarterGui"),
        game:GetService("StarterPlayer"),
        game:GetService("Lighting")
    }

    local foundCount = 0
    DebugLog("INFO", "EXPLORER", "Searching game intelligence for query: '" .. query .. "'")

    for _, svc in ipairs(searchServices) do
        if svc and foundCount < 35 then
            local okDesc, descendants = pcall(function() return svc:GetDescendants() end)
            if okDesc and descendants then
                for _, obj in ipairs(descendants) do
                    local name = obj.Name
                    local nameLower = name:lower()
                    local className = obj.ClassName
                    
                    if nameLower:find(searchLower, 1, true) or className:lower():find(searchLower, 1, true) then
                        foundCount = foundCount + 1
                        
                        local fullPath = obj:GetFullName()
                        local resultItem = Instance.new("Frame")
                        resultItem.Size = UDim2.new(1, 0, 0, 54)
                        resultItem.BackgroundColor3 = COLORS.surface
                        resultItem.BackgroundTransparency = 0.25
                        resultItem.BorderSizePixel = 0
                        resultItem.Parent = explorerResultsScroll

                        local riCorner = Instance.new("UICorner")
                        riCorner.CornerRadius = UDim.new(0, 6)
                        riCorner.Parent = resultItem

                        local riTitle = Instance.new("TextLabel")
                        riTitle.Size = UDim2.new(1, -12, 0, 18)
                        riTitle.Position = UDim2.new(0, 8, 0, 4)
                        riTitle.BackgroundTransparency = 1
                        riTitle.Text = string.format("[%d] %s (%s)", foundCount, name, className)
                        riTitle.TextColor3 = COLORS.primary
                        riTitle.Font = Enum.Font.GothamBold
                        riTitle.TextSize = 11
                        riTitle.TextXAlignment = Enum.TextXAlignment.Left
                        riTitle.Parent = resultItem

                        local riSub = Instance.new("TextLabel")
                        riSub.Size = UDim2.new(1, -12, 0, 14)
                        riSub.Position = UDim2.new(0, 8, 0, 22)
                        riSub.BackgroundTransparency = 1
                        riSub.Text = fullPath
                        riSub.TextColor3 = COLORS.textMuted
                        riSub.Font = Enum.Font.Code
                        riSub.TextSize = 10
                        riSub.TextXAlignment = Enum.TextXAlignment.Left
                        riSub.Parent = resultItem

                        local actBox = Instance.new("Frame")
                        actBox.Size = UDim2.new(1, -16, 0, 16)
                        actBox.Position = UDim2.new(0, 8, 0, 36)
                        actBox.BackgroundTransparency = 1
                        actBox.Parent = resultItem

                        local actLayout = Instance.new("UIListLayout")
                        actLayout.FillDirection = Enum.FillDirection.Horizontal
                        actLayout.Padding = UDim.new(0, 6)
                        actLayout.Parent = actBox

                        local function makeSmallBtn(btnText, btnColor, onClick)
                            local b = Instance.new("TextButton")
                            b.Size = UDim2.new(0, 95, 1, 0)
                            b.BackgroundColor3 = btnColor
                            b.BackgroundTransparency = 0.2
                            b.Text = btnText
                            b.TextColor3 = Color3.fromRGB(255, 255, 255)
                            b.Font = Enum.Font.GothamBold
                            b.TextSize = 9
                            b.Parent = actBox
                            local bc = Instance.new("UICorner")
                            bc.CornerRadius = UDim.new(0, 4)
                            bc.Parent = b
                            b.MouseButton1Click:Connect(onClick)
                        end

                        makeSmallBtn("📋 Copy Path", COLORS.secondary, function()
                            if typeof(setclipboard) == "function" then
                                setclipboard(fullPath)
                                ObsidianGlassEngine:Notify({ Title = "Copied Path", Content = fullPath, Duration = 2 })
                            end
                        end)

                        makeSmallBtn("🧠 Add to AI", COLORS.primary, function()
                            local added = AIContextEngine:AddContext(name, className, fullPath, "Explorer")
                            if added then
                                ObsidianGlassEngine:Notify({ Title = "Context Bound", Content = "Added " .. name .. " to AI Generator Context!", Duration = 3 })
                            else
                                ObsidianGlassEngine:Notify({ Title = "Already Bound", Content = "Instance is already in AI Context.", Duration = 2 })
                            end
                        end)

                        makeSmallBtn("📦 Dump Object", COLORS.glassRaised, function()
                            task.spawn(function()
                                local text = dumpObject(obj)
                                setPreviewData(text)
                                ObsidianGlassEngine:Notify({ Title = "Object Dumped", Content = "Dumped " .. name .. " to Preview tab!", Duration = 3 })
                            end)
                        end)

                        if foundCount >= 35 then break end
                    end
                end
            end
        end
        if foundCount >= 35 then break end
    end

    if foundCount == 0 then
        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Size = UDim2.new(1, 0, 0, 40)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Text = "-- No matching game instances found for '" .. query .. "' --"
        emptyLabel.TextColor3 = COLORS.textFaint
        emptyLabel.Font = Enum.Font.GothamSemibold
        emptyLabel.TextSize = 11
        emptyLabel.Parent = explorerResultsScroll
    end
end

ExplorerTab:AddButton({
    Title = "🔎 SEARCH GAME INTELLIGENCE",
    Callback = function()
        renderExplorerResults(ExplorerSearchInput.Text)
    end
})

ExplorerTab:AddButton({
    Title = "🧹 CLEAR BOUND AI CONTEXT",
    Callback = function()
        AIContextEngine:ClearContext()
        ObsidianGlassEngine:Notify({ Title = "Context Cleared", Content = "Cleared all bound game contexts.", Duration = 2 })
    end
})


-----------------------------------------------------------------------------------------
-- 📡 REMOTE SPY ENGINE (Enhanced Dual-Hook & Explorer Card Style)
-----------------------------------------------------------------------------------------

local SpyEnabled = false
local SpyCalls = {}
local SpySkipText = "ping,heartbeat"
local OldNamecall = nil

local spyScroll = nil
local spyCountLabel = nil
local hooksInstalled = false

local function shouldSkipRemote(name)
    name = tostring(name or ""):lower()
    for term in SpySkipText:gmatch("[^,%s]+") do
        if term ~= "" and name:find(term:lower(), 1, true) then return true end
    end
    return false
end

local function formatRemoteCall(remote, method, args)
    local parts = {}
    local argCount = args.n or #args
    for i = 1, argCount do
        parts[#parts + 1] = SerializationEngine.Serialize(args[i])
    end
    return string.format("%s:%s(%s)", remote:GetFullName(), method, table.concat(parts, ", "))
end

local function renderSpyLogs()
    if not spyScroll then return end
    spyScroll:ClearAllChildren()

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.Parent = spyScroll

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 4)
    pad.Parent = spyScroll

    if spyCountLabel then
        spyCountLabel.Text = string.format("📊 CAPTURED LOGS: %d Calls  •  Status: %s", #SpyCalls, SpyEnabled and "🟢 LOGGING" or "🔴 PAUSED")
    end

    if #SpyCalls == 0 then
        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Size = UDim2.new(1, 0, 0, 60)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Text = "-- No remote calls captured yet. Turn ON Remote Spy and trigger in-game actions --"
        emptyLabel.TextColor3 = COLORS.textFaint
        emptyLabel.Font = Enum.Font.GothamSemibold
        emptyLabel.TextSize = 11
        emptyLabel.Parent = spyScroll
        return
    end

    for idx, entry in ipairs(SpyCalls) do
        if idx > 60 then break end

        local itemCard = Instance.new("Frame")
        itemCard.Size = UDim2.new(1, -6, 0, 68)
        itemCard.BackgroundColor3 = COLORS.surface
        itemCard.BackgroundTransparency = 0.20
        itemCard.BorderSizePixel = 0
        itemCard.LayoutOrder = idx
        itemCard.Parent = spyScroll

        local icCorner = Instance.new("UICorner")
        icCorner.CornerRadius = UDim.new(0, 6)
        icCorner.Parent = itemCard

        local icStroke = Instance.new("UIStroke")
        icStroke.Color = COLORS.glassBorder
        icStroke.Thickness = 1
        icStroke.Parent = itemCard

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -12, 0, 16)
        titleLbl.Position = UDim2.new(0, 8, 0, 4)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = string.format("[%d] 📡 %s (%s)  •  %s  •  %s", idx, entry.Name or "Remote", entry.Class or "RemoteEvent", entry.Method or "FireServer", entry.Time or "")
        titleLbl.TextColor3 = COLORS.cyan
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 10
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.Parent = itemCard

        local codeLbl = Instance.new("TextLabel")
        codeLbl.Size = UDim2.new(1, -12, 0, 18)
        codeLbl.Position = UDim2.new(0, 8, 0, 20)
        codeLbl.BackgroundTransparency = 1
        codeLbl.Text = entry.Source
        codeLbl.TextColor3 = Color3.fromRGB(150, 240, 200)
        codeLbl.Font = Enum.Font.Code
        codeLbl.TextSize = 10
        codeLbl.TextXAlignment = Enum.TextXAlignment.Left
        codeLbl.Parent = itemCard

        local actBox = Instance.new("Frame")
        actBox.Size = UDim2.new(1, -16, 0, 20)
        actBox.Position = UDim2.new(0, 8, 0, 42)
        actBox.BackgroundTransparency = 1
        actBox.Parent = itemCard

        local actLayout = Instance.new("UIListLayout")
        actLayout.FillDirection = Enum.FillDirection.Horizontal
        actLayout.Padding = UDim.new(0, 4)
        actLayout.Parent = actBox

        local function makeSmallBtn(btnText, btnColor, onClick)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0, 82, 1, 0)
            b.BackgroundColor3 = btnColor
            b.BackgroundTransparency = 0.2
            b.Text = btnText
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.Font = Enum.Font.GothamBold
            b.TextSize = 9
            b.Parent = actBox
            local bc = Instance.new("UICorner")
            bc.CornerRadius = UDim.new(0, 4)
            bc.Parent = b
            b.MouseButton1Click:Connect(function()
                playClickSound()
                onClick()
            end)
        end

        makeSmallBtn("📋 Copy Code", COLORS.primary, function()
            if typeof(setclipboard) == "function" then
                setclipboard(entry.Source)
                ObsidianGlassEngine:Notify({ Title = "Copied Code", Content = "Copied executable remote call!", Duration = 2 })
            end
        end)

        makeSmallBtn("📋 Copy Path", COLORS.secondary, function()
            if typeof(setclipboard) == "function" then
                setclipboard(entry.Path)
                ObsidianGlassEngine:Notify({ Title = "Copied Path", Content = entry.Path, Duration = 2 })
            end
        end)

        makeSmallBtn("⚡ Re-Fire", Color3.fromRGB(180, 100, 0), function()
            task.spawn(function()
                if entry.Remote and entry.Remote.Parent then
                    if entry.Method == "FireServer" then
                        entry.Remote:FireServer(unpack(entry.Args))
                        ObsidianGlassEngine:Notify({ Title = "Fired Remote", Content = "Fired " .. entry.Name, Duration = 2 })
                    elseif entry.Method == "InvokeServer" then
                        entry.Remote:InvokeServer(unpack(entry.Args))
                        ObsidianGlassEngine:Notify({ Title = "Invoked Remote", Content = "Invoked " .. entry.Name, Duration = 2 })
                    end
                else
                    ObsidianGlassEngine:Notify({ Title = "Error", Content = "Remote instance no longer exists!", Duration = 3 })
                end
            end)
        end)

        makeSmallBtn("🧠 Add AI", COLORS.glassRaised, function()
            local added = AIContextEngine:AddContext(entry.Name, entry.Class, entry.Path, "RemoteSpy")
            if added then
                ObsidianGlassEngine:Notify({ Title = "Context Bound", Content = "Added " .. entry.Name .. " to AI Generator!", Duration = 2 })
            else
                ObsidianGlassEngine:Notify({ Title = "Already Bound", Content = "Already in AI Context.", Duration = 2 })
            end
        end)

        makeSmallBtn("👁️ Preview", COLORS.accent, function()
            setPreviewData(entry.Source, entry.Name)
            if PreviewTab and PreviewTab.Select then pcall(function() PreviewTab:Select() end) end
            ObsidianGlassEngine:Notify({ Title = "Sent to Preview", Content = "Opened remote call in Preview tab!", Duration = 2 })
        end)
    end
end

local lastLogSig = ""
local lastLogTime = 0

local function addSpyCall(remote, method, args)
    if not SpyEnabled or not getgenv()._PayomboyZ_RemoteSpyEnabled then return end
    if not remote or typeof(remote) ~= "Instance" then return end

    local rName = remote.Name
    local rFullName = remote:GetFullName()
    if shouldSkipRemote(rName) or shouldSkipRemote(rFullName) then return end

    local argCount = args.n or #args
    local argList = {}
    for i = 1, argCount do argList[i] = args[i] end

    local callSig = rFullName .. ":" .. tostring(method) .. "(" .. tostring(argList[1]) .. ")"
    local now = os.clock()
    if callSig == lastLogSig and (now - lastLogTime) < 0.015 then
        return
    end
    lastLogSig = callSig
    lastLogTime = now

    local entry = {
        Remote = remote,
        Name = rName,
        Class = remote.ClassName,
        Path = rFullName,
        Method = method,
        Args = argList,
        Time = os.date("%H:%M:%S"),
        Source = formatRemoteCall(remote, method, argList),
    }

    table.insert(SpyCalls, 1, entry)
    while #SpyCalls > 200 do table.remove(SpyCalls) end

    task.defer(renderSpyLogs)
end

local function installRemoteSpy()
    getgenv()._PayomboyZ_RemoteSpyEnabled = true
    if hooksInstalled then return end
    hooksInstalled = true

    if type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" then
        if not getgenv()._PayomboyZ_OldNamecall then
            getgenv()._PayomboyZ_OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if getgenv()._PayomboyZ_RemoteSpyEnabled and (method == "FireServer" or method == "fireServer" or method == "InvokeServer" or method == "invokeServer") then
                    local okRemote, isRemote = pcall(function()
                        return typeof(self) == "Instance" and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction") or self:IsA("UnreliableRemoteEvent"))
                    end)
                    if okRemote and isRemote then
                        addSpyCall(self, method, table.pack(...))
                    end
                end
                return getgenv()._PayomboyZ_OldNamecall(self, ...)
            end))
            OldNamecall = getgenv()._PayomboyZ_OldNamecall
        end
    end

    if type(hookfunction) == "function" then
        pcall(function()
            local dummyEvent = Instance.new("RemoteEvent")
            local dummyFunc = Instance.new("RemoteFunction")

            if not getgenv()._PayomboyZ_OldFireServer then
                getgenv()._PayomboyZ_OldFireServer = hookfunction(dummyEvent.FireServer, newcclosure(function(self, ...)
                    if getgenv()._PayomboyZ_RemoteSpyEnabled and typeof(self) == "Instance" then
                        addSpyCall(self, "FireServer", table.pack(...))
                    end
                    return getgenv()._PayomboyZ_OldFireServer(self, ...)
                end))
            end

            if not getgenv()._PayomboyZ_OldInvokeServer then
                getgenv()._PayomboyZ_OldInvokeServer = hookfunction(dummyFunc.InvokeServer, newcclosure(function(self, ...)
                    if getgenv()._PayomboyZ_RemoteSpyEnabled and typeof(self) == "Instance" then
                        addSpyCall(self, "InvokeServer", table.pack(...))
                    end
                    return getgenv()._PayomboyZ_OldInvokeServer(self, ...)
                end))
            end

            dummyEvent:Destroy()
            dummyFunc:Destroy()
        end)
    end
end

-- ======================================================================================
-- 📡 REMOTE SPY TAB BUILDER
-- ======================================================================================

SpyTab:AddSection("REMOTE SPY MONITORING & HOOKING")

local spyToggleBtn = SpyTab:AddButton({
    Title = "🔴 [OFF] Remote Spy Status (Click to Enable)",
    Style = "primary",
    Callback = function() end
})

spyToggleBtn.MouseButton1Click:Connect(function()
    playClickSound()
    SpyEnabled = not SpyEnabled
    getgenv()._PayomboyZ_RemoteSpyEnabled = SpyEnabled
    if SpyEnabled then
        installRemoteSpy()
        spyToggleBtn.Text = "🟢 [ON] Remote Spy Logging Active"
        renderSpyLogs()
        ObsidianGlassEngine:Notify({ Title = "Remote Spy", Content = "Logging active! FireServer/InvokeServer monitored.", Duration = 4 })
    else
        spyToggleBtn.Text = "🔴 [OFF] Remote Spy Status (Click to Enable)"
        renderSpyLogs()
        ObsidianGlassEngine:Notify({ Title = "Remote Spy", Content = "Logging paused.", Duration = 3 })
    end
end)

SpyTab:AddSection("BLACKLIST FILTER KEYWORDS")

local filterCard = Instance.new("Frame")
filterCard.Size = UDim2.new(1, -10, 0, 60)
filterCard.BackgroundColor3 = COLORS.glassDeep
filterCard.BackgroundTransparency = 0.18
filterCard.BorderSizePixel = 0
filterCard.Parent = SpyTab.page

local fcCorner = Instance.new("UICorner")
fcCorner.CornerRadius = UDim.new(0, 8)
fcCorner.Parent = filterCard

local fcStroke = Instance.new("UIStroke")
fcStroke.Color = COLORS.surface
fcStroke.Thickness = 1
fcStroke.Parent = filterCard

local fcLabel = Instance.new("TextLabel")
fcLabel.Size = UDim2.new(1, -24, 0, 18)
fcLabel.Position = UDim2.new(0, 12, 0, 6)
fcLabel.BackgroundTransparency = 1
fcLabel.Text = "SKIP REMOTES CONTAINING (COMMA SEPARATED)"
fcLabel.TextColor3 = COLORS.textMuted
fcLabel.Font = Enum.Font.GothamBold
fcLabel.TextSize = 10
fcLabel.TextXAlignment = Enum.TextXAlignment.Left
fcLabel.Parent = filterCard

local FilterInput = Instance.new("TextBox")
FilterInput.Size = UDim2.new(1, -24, 0, 26)
FilterInput.Position = UDim2.new(0, 12, 0, 26)
FilterInput.BackgroundColor3 = COLORS.input
FilterInput.BackgroundTransparency = 0.20
FilterInput.Text = SpySkipText
FilterInput.Font = Enum.Font.GothamSemibold
FilterInput.TextSize = 11
FilterInput.TextColor3 = COLORS.cyan
FilterInput.ClearTextOnFocus = false
FilterInput.TextXAlignment = Enum.TextXAlignment.Left
FilterInput.Parent = filterCard

FilterInput.FocusLost:Connect(function()
    SpySkipText = FilterInput.Text
    renderSpyLogs()
    ObsidianGlassEngine:Notify({ Title = "Filter Updated", Content = "Remote Spy blacklist keywords updated.", Duration = 2 })
end)

local fiCorner = Instance.new("UICorner")
fiCorner.CornerRadius = UDim.new(0, 6)
fiCorner.Parent = FilterInput

local fiPad = Instance.new("UIPadding")
fiPad.PaddingLeft = UDim.new(0, 8)
fiPad.Parent = FilterInput

SpyTab:AddSection("CAPTURED REMOTE CALL LOGS")

local spyStatusCard = Instance.new("Frame")
spyStatusCard.Size = UDim2.new(1, -10, 0, 28)
spyStatusCard.BackgroundColor3 = COLORS.glassDeep
spyStatusCard.BackgroundTransparency = 0.18
spyStatusCard.BorderSizePixel = 0
spyStatusCard.Parent = SpyTab.page

local sscCorner = Instance.new("UICorner")
sscCorner.CornerRadius = UDim.new(0, 6)
sscCorner.Parent = spyStatusCard

local sscStroke = Instance.new("UIStroke")
sscStroke.Color = COLORS.surface
sscStroke.Thickness = 1
sscStroke.Parent = spyStatusCard

spyCountLabel = Instance.new("TextLabel")
spyCountLabel.Size = UDim2.new(1, -20, 1, 0)
spyCountLabel.Position = UDim2.new(0, 10, 0, 0)
spyCountLabel.BackgroundTransparency = 1
spyCountLabel.Text = "📊 CAPTURED LOGS: 0 Calls  •  Status: 🔴 PAUSED"
spyCountLabel.TextColor3 = COLORS.cyan
spyCountLabel.Font = Enum.Font.GothamBold
spyCountLabel.TextSize = 10
spyCountLabel.TextXAlignment = Enum.TextXAlignment.Left
spyCountLabel.Parent = spyStatusCard

local spyLogCard = Instance.new("Frame")
spyLogCard.Size = UDim2.new(1, -10, 0, 240)
spyLogCard.BackgroundColor3 = COLORS.glassDeep
spyLogCard.BackgroundTransparency = 0.18
spyLogCard.BorderSizePixel = 0
spyLogCard.Parent = SpyTab.page

local slcCorner = Instance.new("UICorner")
slcCorner.CornerRadius = UDim.new(0, 8)
slcCorner.Parent = spyLogCard

local slcStroke = Instance.new("UIStroke")
slcStroke.Color = COLORS.surface
slcStroke.Thickness = 1
slcStroke.Parent = spyLogCard

spyScroll = Instance.new("ScrollingFrame")
spyScroll.Size = UDim2.new(1, -12, 1, -12)
spyScroll.Position = UDim2.new(0, 6, 0, 6)
spyScroll.BackgroundColor3 = COLORS.input
spyScroll.BackgroundTransparency = 0.30
spyScroll.BorderSizePixel = 0
spyScroll.ScrollBarThickness = 5
spyScroll.ScrollBarImageColor3 = COLORS.cyan
spyScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
spyScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
spyScroll.Parent = spyLogCard

local spysCorner = Instance.new("UICorner")
spysCorner.CornerRadius = UDim.new(0, 6)
spysCorner.Parent = spyScroll

renderSpyLogs()

SpyTab:AddSection("REMOTE LOG CONTROLS & EXPORT")

SpyTab:AddButton({
    Title = "📋 Copy All Remote Logs to Clipboard",
    Style = "primary",
    Callback = function()
        if #SpyCalls == 0 then
            ObsidianGlassEngine:Notify({ Title = "Warning", Content = "Log buffer is empty!", Duration = 2 })
            return
        end
        local lines = {}
        for _, entry in ipairs(SpyCalls) do
            lines[#lines + 1] = entry.Source
        end
        local fullText = table.concat(lines, "\n")
        if typeof(setclipboard) == "function" then
            pcall(function() setclipboard(fullText) end)
            ObsidianGlassEngine:Notify({ Title = "Copied", Content = "Copied " .. #SpyCalls .. " logged remote calls to clipboard!", Duration = 3 })
        end
    end
})

SpyTab:AddButton({
    Title = "🧠 Bind Captured Remotes to AI Context",
    Callback = function()
        if #SpyCalls == 0 then
            ObsidianGlassEngine:Notify({ Title = "Warning", Content = "No remotes captured yet!", Duration = 3 })
            return
        end
        local boundCount = 0
        local seen = {}
        for _, entry in ipairs(SpyCalls) do
            if entry.Path and not seen[entry.Path] then
                seen[entry.Path] = true
                local added = AIContextEngine:AddContext(entry.Name or "Remote", entry.Class or "RemoteEvent", entry.Path, "RemoteSpy")
                if added then boundCount = boundCount + 1 end
            end
        end
        ObsidianGlassEngine:Notify({ Title = "Remotes Bound", Content = "Bound " .. boundCount .. " captured remotes to AI Context!", Duration = 4 })
    end
})

SpyTab:AddButton({
    Title = "💾 Save Remote Logs to File",
    Callback = function()
        if #SpyCalls == 0 then
            ObsidianGlassEngine:Notify({ Title = "Warning", Content = "No remote calls captured yet!", Duration = 3 })
            return
        end
        local folderName = "PAYOMBOYDumps/RemoteSpy"
        if typeof(makefolder) == "function" then
            pcall(function() makefolder("PAYOMBOYDumps") end)
            pcall(function() makefolder(folderName) end)
        end
        local fileName = folderName .. "/RemoteSpy_" .. os.date("%Y%m%d_%H%M%S") .. ".lua"
        local lines = {
            "-- [[ PayomboyZ Remote Spy Export Log ]]",
            "-- Game PlaceId: " .. tostring(game.PlaceId),
            "-- Time: " .. os.date("%Y-%m-%d %H:%M:%S"),
            "-- Captured Calls Count: " .. tostring(#SpyCalls),
            "",
        }
        for _, entry in ipairs(SpyCalls) do
            lines[#lines + 1] = entry.Source
        end
        local fullCode = table.concat(lines, "\n")
        if typeof(writefile) == "function" then pcall(function() writefile(fileName, fullCode) end) end
        if typeof(setclipboard) == "function" then pcall(function() setclipboard(fileName) end) end
        
        ObsidianGlassEngine:Notify({
            Title = "Saved Logs",
            Content = "Saved " .. #SpyCalls .. " captured calls to " .. fileName,
            Duration = 4
        })
    end
})

SpyTab:AddButton({
    Title = "🗑️ Clear Remote Log Buffer",
    Callback = function()
        SpyCalls = {}
        renderSpyLogs()
        ObsidianGlassEngine:Notify({ Title = "Cleared", Content = "Remote Spy log buffer cleared.", Duration = 2 })
    end
})


-----------------------------------------------------------------------------------------
-- 📦 UNIVERSAL SERVICE & INSTANCE DUMPER ENGINE (Ported from nokey.luau + r101)
-----------------------------------------------------------------------------------------

local ServiceNames = {
    "ReplicatedStorage", "Workspace", "Players", "Lighting", "StarterGui", "StarterPack", "StarterPlayer",
    "SoundService", "Chat", "TextChatService", "RunService", "TweenService", "HttpService", "MarketplaceService",
    "BadgeService", "Teams", "JointsService", "CollectionService", "PhysicsService", "AssetService", "GamePassService",
    "PointsService", "PolicyService", "SocialService", "TeleportService", "UserInputService", "VRService",
    "ServerScriptService", "ServerStorage", "ReplicatedFirst",
}

local PROPERTY_NAMES = {
    "Anchored", "CanCollide", "CanTouch", "CanQuery", "Transparency", "Reflectance",
    "Color", "Material", "Size", "CFrame", "Position", "Orientation",
    "Value", "Visible", "Enabled", "Text", "Image", "Texture", "TextureID", "TextureId",
    "MeshId", "MeshType", "Scale", "Offset", "SecondaryAxis", "Axis",
    "Rate", "Speed", "Lifetime", "LightEmission", "Brightness", "Range", "Shadows",
    "Volume", "PlaybackSpeed", "RollOffMaxDistance", "RollOffMinDistance", "RollOffMode",
    "Neutral", "TeamColor", "AllowTeamChangeOnTouch", "Duration", "Face", "Locked",
    "MaxSpeed", "Torque", "TurnSpeed", "Shape", "StudsPerTileU", "StudsPerTileV",
}

local function safeProperty(object, property)
    local ok, value = pcall(function() return object[property] end)
    return ok, value
end

local function literal(value)
    local kind = typeof(value)
    if kind == "string" then return string.format("%q", value) end
    if kind == "number" or kind == "boolean" then return tostring(value) end
    if kind == "nil" then return "nil" end
    if kind == "Vector3" then return string.format("Vector3.new(%s, %s, %s)", value.X, value.Y, value.Z) end
    if kind == "Vector2" then return string.format("Vector2.new(%s, %s)", value.X, value.Y, value.Z) end
    if kind == "Color3" then return string.format("Color3.new(%s, %s, %s)", value.R, value.G, value.B) end
    if kind == "CFrame" then
        local values = {value:GetComponents()}
        for i, n in ipairs(values) do values[i] = tostring(n) end
        return "CFrame.new(" .. table.concat(values, ", ") .. ")"
    end
    if kind == "EnumItem" then return tostring(value) end
    if kind == "Instance" then return string.format("%q", value:GetFullName()) end
    return string.format("%q", tostring(value))
end

local ServiceDumpPreset = "NORMAL" -- "FAST", "NORMAL", "DEEP"
local ServiceDumpOptions = {
    Children = true, 
    Attributes = true, 
    Properties = false, 
    SourceFormat = false
}

local function applyDumpPreset(preset)
    ServiceDumpPreset = preset
    if preset == "FAST" then
        ServiceDumpOptions.Children = true
        ServiceDumpOptions.Attributes = false
        ServiceDumpOptions.Properties = false
        ServiceDumpOptions.SourceFormat = false
    elseif preset == "NORMAL" then
        ServiceDumpOptions.Children = true
        ServiceDumpOptions.Attributes = true
        ServiceDumpOptions.Properties = false
        ServiceDumpOptions.SourceFormat = false
    elseif preset == "DEEP" then
        ServiceDumpOptions.Children = true
        ServiceDumpOptions.Attributes = true
        ServiceDumpOptions.Properties = true
        ServiceDumpOptions.SourceFormat = false
    end
end

local ServiceDumpSubPath = ""
local ServiceDumpFileName = ""
local ServiceTargetName = "ReplicatedStorage"
local LastServiceDumpData = nil
local LastServiceDumpPath = nil

local PreviewCodeBox = nil
local previewScroll = nil
local PreviewStatusText = nil

local function setPreviewData(text, targetName)
    if not text or text == "" then return end
    LastServiceDumpData = text
    targetName = targetName or ServiceTargetName or "Target"
    
    local charCount = #text
    local lineCount = 1
    for _ in string.gmatch(text, "\n") do
        lineCount = lineCount + 1
    end
    local sizeKB = string.format("%.2f KB", charCount / 1024)
    
    if PreviewStatusText then
        PreviewStatusText.Text = string.format("📊 STATUS: LOADED  •  Target: %s  •  Lines: %d  •  Size: %s", targetName, lineCount, sizeKB)
    end
    
    if PreviewCodeBox then
        if charCount > 25000 then
            local snippet = string.sub(text, 1, 25000)
            PreviewCodeBox.Text = snippet .. string.format("\n\n-- [⚠️ PREVIEW TRUNCATED FOR UI DISPLAY PERFORMANCE]\n-- Full Dump Size: %s (%d lines, %d characters).\n-- The complete untruncated content is ready to be saved to file or copied to clipboard!", sizeKB, lineCount, charCount)
        else
            PreviewCodeBox.Text = text
        end
        
        task.defer(function()
            if PreviewCodeBox and previewScroll then
                local textHeight = math.max(260, PreviewCodeBox.TextBounds.Y + 30)
                PreviewCodeBox.Size = UDim2.new(1, -10, 0, textHeight)
                previewScroll.CanvasSize = UDim2.new(0, 0, 0, textHeight + 20)
            end
        end)
    end
end

local function resolveServiceTarget()
    local name = ServiceTargetName or "ReplicatedStorage"
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then name = "ReplicatedStorage" end
    local target = nil
    if name:lower() == "workspace" then
        target = workspace
    else
        local ok, svc = pcall(function() return game:GetService(name) end)
        if ok and svc then
            target = svc
        else
            pcall(function() target = game:FindFirstChild(name) end)
        end
    end
    if not target then return nil, name end
    if ServiceDumpSubPath and ServiceDumpSubPath ~= "" then
        local cleanedSubPath = ServiceDumpSubPath:gsub("^%s+", ""):gsub("%s+$", "")
        if cleanedSubPath ~= "" then
            for part in cleanedSubPath:gmatch("[^/]+") do
                part = part:gsub("^%s+", ""):gsub("%s+$", "")
                if part ~= "" then
                    target = target and target:FindFirstChild(part)
                    if not target then break end
                end
            end
        end
    end
    return target, name
end

local function dumpObject(root)
    local lines = {}
    lines[#lines + 1] = "-- [[ PayomboyZ Valen Hub Service Dump ]]"
    lines[#lines + 1] = "-- Root: " .. root:GetFullName()
    lines[#lines + 1] = "-- Class: " .. root.ClassName
    lines[#lines + 1] = "-- Preset: " .. tostring(ServiceDumpPreset)
    lines[#lines + 1] = "-- Time: " .. os.date("%Y-%m-%d %H:%M:%S")
    local objects = {root}
    if ServiceDumpOptions.Children then
        local okDesc, descendants = pcall(function() return root:GetDescendants() end)
        if okDesc and descendants then
            for _, object in ipairs(descendants) do objects[#objects + 1] = object end
        end
    end
    for i, object in ipairs(objects) do
        if i % 250 == 0 then task.wait() end
        lines[#lines + 1] = ""
        lines[#lines + 1] = "[" .. object.ClassName .. "] " .. object:GetFullName()
        if ServiceDumpOptions.Attributes then
            local ok, attributes = pcall(function() return object:GetAttributes() end)
            if ok and attributes then
                for key, value in pairs(attributes) do
                    lines[#lines + 1] = "  @" .. tostring(key) .. " = " .. SerializationEngine.Serialize(value)
                end
            end
        end
        if ServiceDumpOptions.Properties and (ServiceDumpPreset == "DEEP" or ServiceDumpOptions.Properties) then
            for _, property in ipairs(PROPERTY_NAMES) do
                local ok, value = safeProperty(object, property)
                if ok and value ~= nil then lines[#lines + 1] = "  ." .. property .. " = " .. SerializationEngine.Serialize(value) end
            end
        end
    end
    if ServiceDumpOptions.SourceFormat then
        local source = {"-- PayomboyZ Hub source-format dump", "local dump = {}"}
        for i, object in ipairs(objects) do
            if i % 500 == 0 then task.wait() end
            source[#source + 1] = string.format("dump[%q] = {ClassName=%q, Name=%q}", object:GetFullName(), object.ClassName, object.Name)
        end
        source[#source + 1] = "return dump"
        return table.concat(source, "\n")
    end
    return table.concat(lines, "\n")
end

local function performServiceDump(saveToFile, showPreview)
    ObsidianGlassEngine:Notify({Title = "Dump Initiated", Content = "Processing target service... Please wait.", Duration = 2})
    local target, serviceName = resolveServiceTarget()
    if not target then
        ObsidianGlassEngine:Notify({Title = "Dump Error", Content = "Target service/subpath not found: " .. tostring(serviceName), Duration = 3})
        return
    end
    local ok, data = pcall(dumpObject, target)
    if not ok then
        ObsidianGlassEngine:Notify({Title = "Dump Error", Content = "Dump failed: " .. tostring(data), Duration = 3})
        return
    end
    
    setPreviewData(data, serviceName)

    if showPreview then
        if PreviewTab and PreviewTab.Select then pcall(function() PreviewTab:Select() end) end
        ObsidianGlassEngine:Notify({Title = "Preview Loaded", Content = "Dumped " .. serviceName .. " (" .. #data .. " chars)! Navigated to Preview tab.", Duration = 4})
    end

    if saveToFile then
        if typeof(makefolder) == "function" then
            pcall(function() makefolder("PAYOMBOYDumps") end)
            pcall(function() makefolder("PAYOMBOYDumps/Dump") end)
        end
        local name = (ServiceDumpFileName and ServiceDumpFileName ~= "") and ServiceDumpFileName or (serviceName .. "_" .. os.date("%Y%m%d_%H%M%S"))
        name = name:gsub("[^%w_%- ]", "_")
        local ext = ServiceDumpOptions.SourceFormat and ".lua" or ".txt"
        LastServiceDumpPath = "PAYOMBOYDumps/Dump/" .. name .. ext
        if typeof(writefile) == "function" then pcall(function() writefile(LastServiceDumpPath, data) end) end
        if typeof(setclipboard) == "function" then pcall(function() setclipboard(data) end) end
        if PreviewTab and PreviewTab.Select then pcall(function() PreviewTab:Select() end) end
        ObsidianGlassEngine:Notify({Title = "Dump Saved", Content = "Saved dump file to: " .. LastServiceDumpPath, Duration = 5})
    end
end

local function r101(folderName, includeTerrain, includeScripts, includeCharacters, targetInstance)
    targetInstance = targetInstance or workspace
    local lines = {
        "-- [[ PayomboyZ Dump Engine: " .. tostring(folderName) .. " ]]",
        "-- Generated At: " .. os.date("%Y-%m-%d %H:%M:%S"),
        "local targetParent = " .. (targetInstance == workspace and "workspace" or "game:GetService(\"ReplicatedStorage\")"),
        "local dumpFolder = Instance.new(\"Folder\")",
        "dumpFolder.Name = " .. string.format("%q", folderName),
        "dumpFolder.Parent = targetParent",
        "",
        "local refMap = { [0] = dumpFolder }",
    }

    local instanceCount = 0
    local nextId = 1

    local function isPlayerCharacter(inst)
        for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
            if p.Character and (inst == p.Character or inst:IsDescendantOf(p.Character)) then
                return true
            end
        end
        return false
    end

    local function shouldDump(inst)
        if not includeTerrain and inst:IsA("Terrain") then return false end
        if not includeCharacters and isPlayerCharacter(inst) then return false end
        if not includeScripts and (inst:IsA("LuaSourceContainer") or inst:IsA("Script") or inst:IsA("LocalScript") or inst:IsA("ModuleScript")) then
            return false
        end
        return true
    end

    local function processInstance(inst, parentId)
        if not shouldDump(inst) then return end

        local id = nextId
        nextId = nextId + 1
        instanceCount = instanceCount + 1

        local className = inst.ClassName
        table.insert(lines, string.format("local obj%d = Instance.new(%q)", id, className))
        table.insert(lines, string.format("obj%d.Name = %q", id, inst.Name))
        table.insert(lines, string.format("obj%d.Parent = refMap[%d]", id, parentId))
        table.insert(lines, string.format("refMap[%d] = obj%d", id, id))

        if inst:IsA("BasePart") then
            pcall(function()
                table.insert(lines, string.format("obj%d.Size = %s", id, SerializationEngine.Serialize(inst.Size)))
                table.insert(lines, string.format("obj%d.CFrame = %s", id, SerializationEngine.Serialize(inst.CFrame)))
                table.insert(lines, string.format("obj%d.Color = %s", id, SerializationEngine.Serialize(inst.Color)))
                table.insert(lines, string.format("obj%d.Material = %s", id, SerializationEngine.Serialize(inst.Material)))
                table.insert(lines, string.format("obj%d.Anchored = %s", id, tostring(inst.Anchored)))
                table.insert(lines, string.format("obj%d.CanCollide = %s", id, tostring(inst.CanCollide)))
            end)
        elseif inst:IsA("ValueBase") then
            pcall(function()
                local sVal = SerializationEngine.Serialize(inst.Value)
                if sVal then
                    table.insert(lines, string.format("obj%d.Value = %s", id, sVal))
                end
            end)
        elseif inst:IsA("LuaSourceContainer") and includeScripts then
            pcall(function()
                local src = inst.Source
                if src and #src > 0 then
                    table.insert(lines, string.format("obj%d.Source = %q", id, src))
                end
            end)
        end

        for _, child in ipairs(inst:GetChildren()) do
            processInstance(child, id)
        end
    end

    for _, child in ipairs(targetInstance:GetChildren()) do
        processInstance(child, 0)
    end

    table.insert(lines, "")
    table.insert(lines, string.format("print('[Dump Restore] Created %d instances in folder %s')", instanceCount, folderName))

    return table.concat(lines, "\n"), instanceCount
end

local function generateDumpScript(targetInstance, folderName, includeTerrain, includeScripts, includeCharacters)
    return r101(folderName, includeTerrain, includeScripts, includeCharacters, targetInstance)
end

-- ======================================================================================
-- 📦 INSTANCE & SERVICE DUMPER TAB BUILDER
-- ======================================================================================

DumpTab:AddSection("EXPORT FILENAME & SAVE CONFIGURATION")

local filenameCard = Instance.new("Frame")
filenameCard.Size = UDim2.new(1, -10, 0, 85)
filenameCard.BackgroundColor3 = COLORS.glassDeep
filenameCard.BackgroundTransparency = 0.18
filenameCard.BorderSizePixel = 0
filenameCard.Parent = DumpTab.page

local fnCorner = Instance.new("UICorner")
fnCorner.CornerRadius = UDim.new(0, 8)
fnCorner.Parent = filenameCard

local fnStroke = Instance.new("UIStroke")
fnStroke.Color = COLORS.surface
fnStroke.Thickness = 1
fnStroke.Parent = filenameCard

local fnLbl1 = Instance.new("TextLabel")
fnLbl1.Size = UDim2.new(1, -24, 0, 16)
fnLbl1.Position = UDim2.new(0, 12, 0, 6)
fnLbl1.BackgroundTransparency = 1
fnLbl1.Text = "CUSTOM EXPORT FILE NAME (OPTIONAL)"
fnLbl1.TextColor3 = COLORS.textMuted
fnLbl1.Font = Enum.Font.GothamBold
fnLbl1.TextSize = 10
fnLbl1.TextXAlignment = Enum.TextXAlignment.Left
fnLbl1.Parent = filenameCard

local DumpFileNameInput = Instance.new("TextBox")
DumpFileNameInput.Size = UDim2.new(1, -24, 0, 26)
DumpFileNameInput.Position = UDim2.new(0, 12, 0, 24)
DumpFileNameInput.BackgroundColor3 = COLORS.input
DumpFileNameInput.BackgroundTransparency = 0.20
DumpFileNameInput.Text = ServiceDumpFileName
DumpFileNameInput.PlaceholderText = "Leave empty for auto-generated timestamp name..."
DumpFileNameInput.Font = Enum.Font.GothamSemibold
DumpFileNameInput.TextSize = 11
DumpFileNameInput.TextColor3 = COLORS.cyan
DumpFileNameInput.ClearTextOnFocus = false
DumpFileNameInput.TextXAlignment = Enum.TextXAlignment.Left
DumpFileNameInput.Parent = filenameCard

local dfniCorner = Instance.new("UICorner")
dfniCorner.CornerRadius = UDim.new(0, 5)
dfniCorner.Parent = DumpFileNameInput

local dfniPad = Instance.new("UIPadding")
dfniPad.PaddingLeft = UDim.new(0, 6)
dfniPad.Parent = DumpFileNameInput

local savePathStatusLbl = Instance.new("TextLabel")
savePathStatusLbl.Size = UDim2.new(1, -24, 0, 24)
savePathStatusLbl.Position = UDim2.new(0, 12, 0, 54)
savePathStatusLbl.BackgroundTransparency = 1
savePathStatusLbl.Text = "📁 Output Path: workspace/ValenHub_Dumps/Dump/" .. ((ServiceDumpFileName ~= "") and ServiceDumpFileName or "<AutoName>") .. ".txt"
savePathStatusLbl.TextColor3 = Color3.fromRGB(0, 220, 160)
savePathStatusLbl.Font = Enum.Font.Code
savePathStatusLbl.TextSize = 10
savePathStatusLbl.TextXAlignment = Enum.TextXAlignment.Left
savePathStatusLbl.Parent = filenameCard

local function updateFileNameState()
    ServiceDumpFileName = DumpFileNameInput.Text:gsub("^%s+", ""):gsub("%s+$", "")
    local dispName = (ServiceDumpFileName ~= "") and ServiceDumpFileName or (ServiceTargetName .. "_<Timestamp>")
    savePathStatusLbl.Text = "📁 Output Path: workspace/ValenHub_Dumps/Dump/" .. dispName .. ".txt"
end

DumpFileNameInput:GetPropertyChangedSignal("Text"):Connect(updateFileNameState)
DumpFileNameInput.FocusLost:Connect(updateFileNameState)

DumpTab:AddSection("QUICK SELECT TARGET SERVICE")

local quickServiceFrame = Instance.new("Frame")
quickServiceFrame.Size = UDim2.new(1, -10, 0, 80)
quickServiceFrame.BackgroundColor3 = COLORS.glassDeep
quickServiceFrame.BackgroundTransparency = 0.18
quickServiceFrame.BorderSizePixel = 0
quickServiceFrame.Parent = DumpTab.page

local qsfCorner = Instance.new("UICorner")
qsfCorner.CornerRadius = UDim.new(0, 8)
qsfCorner.Parent = quickServiceFrame

local qsfStroke = Instance.new("UIStroke")
qsfStroke.Color = COLORS.surface
qsfStroke.Thickness = 1
qsfStroke.Parent = quickServiceFrame

local qsfGrid = Instance.new("UIGridLayout")
qsfGrid.CellSize = UDim2.new(0.24, -4, 0, 22)
qsfGrid.CellPadding = UDim2.new(0, 4, 0, 4)
qsfGrid.SortOrder = Enum.SortOrder.LayoutOrder
qsfGrid.Parent = quickServiceFrame

local qsfPad = Instance.new("UIPadding")
qsfPad.PaddingTop = UDim.new(0, 6)
qsfPad.PaddingLeft = UDim.new(0, 6)
qsfPad.PaddingRight = UDim.new(0, 6)
qsfPad.PaddingBottom = UDim.new(0, 6)
qsfPad.Parent = quickServiceFrame

local ServiceInput = nil

local quickServices = {
    "ReplicatedStorage", "Workspace", "Players", "Lighting",
    "StarterGui", "StarterPack", "StarterPlayer", "SoundService",
    "ReplicatedFirst", "ServerStorage", "TextChatService", "HttpService"
}

for idx, sName in ipairs(quickServices) do
    local sBtn = Instance.new("TextButton")
    sBtn.Size = UDim2.new(1, 0, 1, 0)
    sBtn.BackgroundColor3 = Color3.fromRGB(14, 34, 22)
    sBtn.BackgroundTransparency = 0.15
    sBtn.Text = sName
    sBtn.TextColor3 = Color3.fromRGB(240, 255, 245)
    sBtn.Font = Enum.Font.GothamSemibold
    sBtn.TextSize = 9
    sBtn.LayoutOrder = idx
    sBtn.Parent = quickServiceFrame

    local sCorner = Instance.new("UICorner")
    sCorner.CornerRadius = UDim.new(0, 4)
    sCorner.Parent = sBtn

    local sBtnStroke = Instance.new("UIStroke")
    sBtnStroke.Color = Color3.fromRGB(24, 80, 48)
    sBtnStroke.Thickness = 1
    sBtnStroke.Parent = sBtn

    sBtn.MouseEnter:Connect(function()
        sBtn.BackgroundColor3 = Color3.fromRGB(22, 58, 36)
    end)
    sBtn.MouseLeave:Connect(function()
        sBtn.BackgroundColor3 = Color3.fromRGB(14, 34, 22)
    end)

    sBtn.MouseButton1Click:Connect(function()
        playClickSound()
        ServiceTargetName = sName
        if ServiceInput then ServiceInput.Text = sName end
        updateFileNameState()
        ObsidianGlassEngine:Notify({ Title = "Target Selected", Content = "Service set to: " .. sName, Duration = 2 })
    end)
end

DumpTab:AddSection("CUSTOM TARGET SERVICE & SUB PATH INPUT")

local serviceInputCard = Instance.new("Frame")
serviceInputCard.Size = UDim2.new(1, -10, 0, 95)
serviceInputCard.BackgroundColor3 = COLORS.glassDeep
serviceInputCard.BackgroundTransparency = 0.18
serviceInputCard.BorderSizePixel = 0
serviceInputCard.Parent = DumpTab.page

local sicCorner = Instance.new("UICorner")
sicCorner.CornerRadius = UDim.new(0, 8)
sicCorner.Parent = serviceInputCard

local sicStroke = Instance.new("UIStroke")
sicStroke.Color = COLORS.surface
sicStroke.Thickness = 1
sicStroke.Parent = serviceInputCard

local sicLbl1 = Instance.new("TextLabel")
sicLbl1.Size = UDim2.new(1, -24, 0, 16)
sicLbl1.Position = UDim2.new(0, 12, 0, 6)
sicLbl1.BackgroundTransparency = 1
sicLbl1.Text = "TARGET SERVICE NAME (e.g. ReplicatedStorage, Workspace, Players)"
sicLbl1.TextColor3 = COLORS.textMuted
sicLbl1.Font = Enum.Font.GothamBold
sicLbl1.TextSize = 10
sicLbl1.TextXAlignment = Enum.TextXAlignment.Left
sicLbl1.Parent = serviceInputCard

ServiceInput = Instance.new("TextBox")
ServiceInput.Size = UDim2.new(1, -24, 0, 24)
ServiceInput.Position = UDim2.new(0, 12, 0, 22)
ServiceInput.BackgroundColor3 = COLORS.input
ServiceInput.BackgroundTransparency = 0.20
ServiceInput.Text = "ReplicatedStorage"
ServiceInput.Font = Enum.Font.GothamSemibold
ServiceInput.TextSize = 11
ServiceInput.TextColor3 = COLORS.cyan
ServiceInput.ClearTextOnFocus = false
ServiceInput.TextXAlignment = Enum.TextXAlignment.Left
ServiceInput.Parent = serviceInputCard

local siCorner = Instance.new("UICorner")
siCorner.CornerRadius = UDim.new(0, 5)
siCorner.Parent = ServiceInput

local siPad = Instance.new("UIPadding")
siPad.PaddingLeft = UDim.new(0, 6)
siPad.Parent = ServiceInput

ServiceInput:GetPropertyChangedSignal("Text"):Connect(function()
    ServiceTargetName = ServiceInput.Text
    updateFileNameState()
end)
ServiceInput.FocusLost:Connect(function()
    ServiceTargetName = ServiceInput.Text
    updateFileNameState()
end)

local sicLbl2 = Instance.new("TextLabel")
sicLbl2.Size = UDim2.new(1, -24, 0, 16)
sicLbl2.Position = UDim2.new(0, 12, 0, 48)
sicLbl2.BackgroundTransparency = 1
sicLbl2.Text = "SUB PATH (OPTIONAL, e.g. TS/data/plants)"
sicLbl2.TextColor3 = COLORS.textMuted
sicLbl2.Font = Enum.Font.GothamBold
sicLbl2.TextSize = 10
sicLbl2.TextXAlignment = Enum.TextXAlignment.Left
sicLbl2.Parent = serviceInputCard

local SubPathInput = Instance.new("TextBox")
SubPathInput.Size = UDim2.new(1, -24, 0, 24)
SubPathInput.Position = UDim2.new(0, 12, 0, 64)
SubPathInput.BackgroundColor3 = COLORS.input
SubPathInput.BackgroundTransparency = 0.20
SubPathInput.Text = ""
SubPathInput.PlaceholderText = "Leave empty for root service..."
SubPathInput.Font = Enum.Font.GothamSemibold
SubPathInput.TextSize = 11
SubPathInput.TextColor3 = COLORS.text
SubPathInput.ClearTextOnFocus = false
SubPathInput.TextXAlignment = Enum.TextXAlignment.Left
SubPathInput.Parent = serviceInputCard

local spiCorner = Instance.new("UICorner")
spiCorner.CornerRadius = UDim.new(0, 5)
spiCorner.Parent = SubPathInput

local spiPad = Instance.new("UIPadding")
spiPad.PaddingLeft = UDim.new(0, 6)
spiPad.Parent = SubPathInput

SubPathInput:GetPropertyChangedSignal("Text"):Connect(function()
    ServiceDumpSubPath = SubPathInput.Text
end)
SubPathInput.FocusLost:Connect(function()
    ServiceDumpSubPath = SubPathInput.Text
end)

DumpTab:AddSection("DUMP PRESET ENGINE (PERFORMANCE OPTIMIZATION)")

local presetBtnFast = nil
local presetBtnNormal = nil
local presetBtnDeep = nil

local function updatePresetUI()
    if presetBtnFast then presetBtnFast.Text = (ServiceDumpPreset == "FAST" and "⚡ [ACTIVE] FAST (Tree Only)" or "⚡ FAST (Tree Only)") end
    if presetBtnNormal then presetBtnNormal.Text = (ServiceDumpPreset == "NORMAL" and "🔍 [ACTIVE] NORMAL (Tree + Attributes)" or "🔍 NORMAL (Tree + Attributes)") end
    if presetBtnDeep then presetBtnDeep.Text = (ServiceDumpPreset == "DEEP" and "🧬 [ACTIVE] DEEP (Everything + Props)" or "🧬 DEEP (Everything + Props)") end
end

presetBtnFast = DumpTab:AddButton({
    Title = "⚡ FAST (Tree Only)",
    Callback = function()
        playClickSound()
        applyDumpPreset("FAST")
        updatePresetUI()
        ObsidianGlassEngine:Notify({ Title = "Preset Changed", Content = "Set Dump Preset to FAST!", Duration = 2 })
    end
})

presetBtnNormal = DumpTab:AddButton({
    Title = "🔍 [ACTIVE] NORMAL (Tree + Attributes)",
    Callback = function()
        playClickSound()
        applyDumpPreset("NORMAL")
        updatePresetUI()
        ObsidianGlassEngine:Notify({ Title = "Preset Changed", Content = "Set Dump Preset to NORMAL!", Duration = 2 })
    end
})

presetBtnDeep = DumpTab:AddButton({
    Title = "🧬 DEEP (Everything + Props)",
    Callback = function()
        playClickSound()
        applyDumpPreset("DEEP")
        updatePresetUI()
        ObsidianGlassEngine:Notify({ Title = "Preset Changed", Content = "Set Dump Preset to DEEP!", Duration = 2 })
    end
})

DumpTab:AddSection("ADVANCED CUSTOM DUMP CONFIGURATION")

local function createServiceToggle(title, defaultVal, callback)
    local state = defaultVal
    local btn = DumpTab:AddButton({
        Title = (state and "🟢 [ON] " or "🔴 [OFF] ") .. title,
        Callback = function() end
    })
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = (state and "🟢 [ON] " or "🔴 [OFF] ") .. title
        callback(state)
    end)
    return btn
end

createServiceToggle("Dump Children Tree", ServiceDumpOptions.Children, function(v) ServiceDumpOptions.Children = v end)
createServiceToggle("Dump Attributes", ServiceDumpOptions.Attributes, function(v) ServiceDumpOptions.Attributes = v end)
createServiceToggle("Dump Part / Humanoid Properties", ServiceDumpOptions.Properties, function(v) ServiceDumpOptions.Properties = v end)
createServiceToggle("Source Code Format", ServiceDumpOptions.SourceFormat, function(v) ServiceDumpOptions.SourceFormat = v end)

DumpTab:AddSection("SERVICE DUMP ACTIONS")

DumpTab:AddButton({
    Title = "💾 Dump Service to File",
    Style = "primary",
    Callback = function()
        task.spawn(function()
            performServiceDump(true, false)
        end)
    end
})

DumpTab:AddButton({
    Title = "👁️ Dump Service & Send to Preview Tab",
    Style = "primary",
    Callback = function()
        task.spawn(function()
            performServiceDump(false, true)
        end)
    end
})

DumpTab:AddSection("r101 RECONSTRUCTION DUMPER (FULL WORKSPACE / REPLICATED)")

local selectedTarget = "Workspace"
local dumpTerrain = true
local dumpScripts = true
local dumpCharacters = false

DumpTab:AddButton({
    Title = "🚀 RUN r101 INSTANCE RECONSTRUCTION DUMP",
    Style = "primary",
    Callback = function()
        local targetInst = (selectedTarget == "Workspace") and workspace or game:GetService("ReplicatedStorage")
        local folderName = (ServiceDumpFileName and ServiceDumpFileName ~= "") and ServiceDumpFileName or (selectedTarget .. "Dump_" .. os.date("%Y%m%d_%H%M%S"))
        
        task.spawn(function()
            local scriptText, instanceCount = generateDumpScript(targetInst, folderName, dumpTerrain, dumpScripts, dumpCharacters)
            if scriptText and instanceCount > 0 then
                setPreviewData(scriptText, folderName)
                if PreviewTab and PreviewTab.Select then pcall(function() PreviewTab:Select() end) end
                if typeof(makefolder) == "function" then
                    pcall(function() makefolder("PAYOMBOYDumps") end)
                    pcall(function() makefolder("PAYOMBOYDumps/Dump") end)
                end
                local savePath = "PAYOMBOYDumps/Dump/" .. folderName .. ".lua"
                LastServiceDumpPath = savePath
                if typeof(writefile) == "function" then pcall(function() writefile(savePath, scriptText) end) end
                if typeof(setclipboard) == "function" then pcall(function() setclipboard(scriptText) end) end
                
                ObsidianGlassEngine:Notify({
                    Title = "r101 Dump Completed",
                    Content = "Dumped " .. instanceCount .. " instances! Saved to " .. savePath,
                    Duration = 5
                })
            end
        end)
    end
})

-- ======================================================================================
-- 👁️ DUMP PREVIEW TAB BUILDER
-- ======================================================================================

PreviewTab:AddSection("SERVICE DUMP PREVIEW TERMINAL")

local previewHeaderCard = Instance.new("Frame")
previewHeaderCard.Size = UDim2.new(1, -10, 0, 32)
previewHeaderCard.BackgroundColor3 = COLORS.glassDeep
previewHeaderCard.BackgroundTransparency = 0.18
previewHeaderCard.BorderSizePixel = 0
previewHeaderCard.Parent = PreviewTab.page

local phcCorner = Instance.new("UICorner")
phcCorner.CornerRadius = UDim.new(0, 8)
phcCorner.Parent = previewHeaderCard

local phcStroke = Instance.new("UIStroke")
phcStroke.Color = COLORS.surface
phcStroke.Thickness = 1
phcStroke.Parent = previewHeaderCard

PreviewStatusText = Instance.new("TextLabel")
PreviewStatusText.Size = UDim2.new(1, -20, 1, 0)
PreviewStatusText.Position = UDim2.new(0, 10, 0, 0)
PreviewStatusText.BackgroundTransparency = 1
PreviewStatusText.Text = "📊 STATUS: WAITING  •  No dump data loaded yet. Perform a dump to view content."
PreviewStatusText.TextColor3 = COLORS.cyan
PreviewStatusText.Font = Enum.Font.GothamBold
PreviewStatusText.TextSize = 10
PreviewStatusText.TextXAlignment = Enum.TextXAlignment.Left
PreviewStatusText.Parent = previewHeaderCard

local previewCard = Instance.new("Frame")
previewCard.Size = UDim2.new(1, -10, 0, 260)
previewCard.BackgroundColor3 = COLORS.glassDeep
previewCard.BackgroundTransparency = 0.18
previewCard.BorderSizePixel = 0
previewCard.Parent = PreviewTab.page

local pcCardCorner = Instance.new("UICorner")
pcCardCorner.CornerRadius = UDim.new(0, 8)
pcCardCorner.Parent = previewCard

local pcCardStroke = Instance.new("UIStroke")
pcCardStroke.Color = COLORS.surface
pcCardStroke.Thickness = 1
pcCardStroke.Parent = previewCard

previewScroll = Instance.new("ScrollingFrame")
previewScroll.Size = UDim2.new(1, -12, 1, -12)
previewScroll.Position = UDim2.new(0, 6, 0, 6)
previewScroll.BackgroundColor3 = COLORS.input
previewScroll.BackgroundTransparency = 0.30
previewScroll.BorderSizePixel = 0
previewScroll.ScrollBarThickness = 6
previewScroll.ScrollBarImageColor3 = COLORS.primary
previewScroll.CanvasSize = UDim2.new(0, 0, 0, 240)
previewScroll.Parent = previewCard

local psCorner = Instance.new("UICorner")
psCorner.CornerRadius = UDim.new(0, 6)
psCorner.Parent = previewScroll

PreviewCodeBox = Instance.new("TextBox")
PreviewCodeBox.Size = UDim2.new(1, -10, 0, 240)
PreviewCodeBox.Position = UDim2.new(0, 5, 0, 0)
PreviewCodeBox.BackgroundTransparency = 1
PreviewCodeBox.PlaceholderText = "-- Dumped data preview will appear here live. Select a service in 'Instance Dumper' and click Dump & Send to Preview."
PreviewCodeBox.Text = ""
PreviewCodeBox.Font = Enum.Font.Code
PreviewCodeBox.TextSize = 11
PreviewCodeBox.TextColor3 = Color3.fromRGB(150, 240, 200)
PreviewCodeBox.MultiLine = true
PreviewCodeBox.ClearTextOnFocus = false
PreviewCodeBox.TextEditable = false
PreviewCodeBox.TextXAlignment = Enum.TextXAlignment.Left
PreviewCodeBox.TextYAlignment = Enum.TextYAlignment.Top
PreviewCodeBox.Parent = previewScroll

local pcbPad = Instance.new("UIPadding")
pcbPad.PaddingLeft = UDim.new(0, 4)
pcbPad.PaddingTop = UDim.new(0, 4)
pcbPad.Parent = PreviewCodeBox

PreviewCodeBox:GetPropertyChangedSignal("Text"):Connect(function()
    task.defer(function()
        if PreviewCodeBox and previewScroll then
            local textHeight = math.max(240, PreviewCodeBox.TextBounds.Y + 30)
            PreviewCodeBox.Size = UDim2.new(1, -10, 0, textHeight)
            previewScroll.CanvasSize = UDim2.new(0, 0, 0, textHeight + 20)
        end
    end)
end)

if LastServiceDumpData then
    setPreviewData(LastServiceDumpData, ServiceTargetName)
end

PreviewTab:AddSection("PREVIEW ACTIONS & EXPORT")

PreviewTab:AddButton({
    Title = "💾 Save Full Preview Data to File",
    Style = "primary",
    Callback = function()
        if LastServiceDumpData and LastServiceDumpData ~= "" then
            if typeof(makefolder) == "function" then
                pcall(function() makefolder("PAYOMBOYDumps") end)
                pcall(function() makefolder("PAYOMBOYDumps/Dump") end)
            end
            local name = (ServiceDumpFileName and ServiceDumpFileName ~= "") and ServiceDumpFileName or (ServiceTargetName .. "_Preview_" .. os.date("%Y%m%d_%H%M%S"))
            name = name:gsub("[^%w_%- ]", "_")
            local ext = (ServiceDumpOptions.SourceFormat or LastServiceDumpData:sub(1, 50):find("local")) and ".lua" or ".txt"
            LastServiceDumpPath = "PAYOMBOYDumps/Dump/" .. name .. ext
            if typeof(writefile) == "function" then pcall(function() writefile(LastServiceDumpPath, LastServiceDumpData) end) end
            if typeof(setclipboard) == "function" then pcall(function() setclipboard(LastServiceDumpData) end) end
            ObsidianGlassEngine:Notify({ Title = "Preview Saved", Content = "Saved full dump to " .. LastServiceDumpPath, Duration = 4 })
        else
            ObsidianGlassEngine:Notify({ Title = "Warning", Content = "No preview dump data available!", Duration = 3 })
        end
    end
})

PreviewTab:AddButton({
    Title = "🔄 Refresh Dump Preview Data",
    Callback = function()
        if LastServiceDumpData then
            setPreviewData(LastServiceDumpData, ServiceTargetName)
            ObsidianGlassEngine:Notify({ Title = "Refreshed", Content = "Dump preview refreshed!", Duration = 2 })
        else
            ObsidianGlassEngine:Notify({ Title = "Warning", Content = "No dump data available yet.", Duration = 3 })
        end
    end
})

PreviewTab:AddButton({
    Title = "📋 Copy Full Preview Code to Clipboard",
    Callback = function()
        if LastServiceDumpData and LastServiceDumpData ~= "" then
            if typeof(setclipboard) == "function" then
                pcall(function() setclipboard(LastServiceDumpData) end)
                ObsidianGlassEngine:Notify({ Title = "Copied", Content = "Copied full untruncated preview text to clipboard!", Duration = 3 })
            end
        else
            ObsidianGlassEngine:Notify({ Title = "Warning", Content = "Preview buffer is empty!", Duration = 3 })
        end
    end
})

PreviewTab:AddButton({
    Title = "📁 Copy Last Saved File Path",
    Callback = function()
        if LastServiceDumpPath then
            if typeof(setclipboard) == "function" then
                pcall(function() setclipboard(LastServiceDumpPath) end)
                ObsidianGlassEngine:Notify({ Title = "Copied Path", Content = LastServiceDumpPath, Duration = 4 })
            end
        else
            ObsidianGlassEngine:Notify({ Title = "Warning", Content = "No dump file saved yet.", Duration = 3 })
        end
    end
})

-- ======================================================================================
-- 🐛 DEBUG CONSOLE TAB BUILDER
-- ======================================================================================

DebugTab:AddSection("SYSTEM REAL-TIME DEBUG CONSOLE")

local debugCard = Instance.new("Frame")
debugCard.Size = UDim2.new(1, -10, 0, 200)
debugCard.BackgroundColor3 = COLORS.glassDeep
debugCard.BackgroundTransparency = 0.18
debugCard.BorderSizePixel = 0
debugCard.Parent = DebugTab.page

local dcCardCorner = Instance.new("UICorner")
dcCardCorner.CornerRadius = UDim.new(0, 8)
dcCardCorner.Parent = debugCard

local dcCardStroke = Instance.new("UIStroke")
dcCardStroke.Color = COLORS.surface
dcCardStroke.Thickness = 1
dcCardStroke.Parent = debugCard

local debugScroll = Instance.new("ScrollingFrame")
debugScroll.Size = UDim2.new(1, -12, 1, -12)
debugScroll.Position = UDim2.new(0, 6, 0, 6)
debugScroll.BackgroundColor3 = COLORS.input
debugScroll.BackgroundTransparency = 0.30
debugScroll.BorderSizePixel = 0
debugScroll.ScrollBarThickness = 5
debugScroll.ScrollBarImageColor3 = COLORS.primary
debugScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
debugScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
debugScroll.Parent = debugCard

local dcsCorner = Instance.new("UICorner")
dcsCorner.CornerRadius = UDim.new(0, 6)
dcsCorner.Parent = debugScroll

DebugConsoleBox = Instance.new("TextBox")
DebugConsoleBox.Size = UDim2.new(1, -10, 1, 0)
DebugConsoleBox.Position = UDim2.new(0, 5, 0, 0)
DebugConsoleBox.BackgroundTransparency = 1
DebugConsoleBox.PlaceholderText = "-- System logs (INFO, WARN, ERROR, NETWORK) will stream live here..."
DebugConsoleBox.Text = ""
DebugConsoleBox.Font = Enum.Font.Code
DebugConsoleBox.TextSize = 11
DebugConsoleBox.TextColor3 = Color3.fromRGB(180, 255, 180)
DebugConsoleBox.MultiLine = true
DebugConsoleBox.ClearTextOnFocus = false
DebugConsoleBox.TextXAlignment = Enum.TextXAlignment.Left
DebugConsoleBox.TextYAlignment = Enum.TextYAlignment.Top
DebugConsoleBox.AutomaticSize = Enum.AutomaticSize.Y
DebugConsoleBox.Parent = debugScroll

local dcbPad = Instance.new("UIPadding")
dcbPad.PaddingLeft = UDim.new(0, 4)
dcbPad.PaddingTop = UDim.new(0, 4)
dcbPad.Parent = DebugConsoleBox

local initialLogs = {}
for _, log in ipairs(DebugLogs) do
    table.insert(initialLogs, log.Raw)
end
DebugConsoleBox.Text = table.concat(initialLogs, "\n")

DebugTab:AddSection("DEBUG CONSOLE UTILITIES")

DebugTab:AddButton({
    Title = "🧹 Clear Debug Logs",
    Callback = function()
        table.clear(DebugLogs)
        if DebugConsoleBox then DebugConsoleBox.Text = "" end
        DebugLog("INFO", "CONSOLE", "Debug console buffer cleared")
        ObsidianGlassEngine:Notify({ Title = "Cleared", Content = "Debug log buffer cleared.", Duration = 2 })
    end
})

DebugTab:AddButton({
    Title = "📋 Copy Debug Logs to Clipboard",
    Callback = function()
        if DebugConsoleBox and DebugConsoleBox.Text ~= "" then
            if typeof(setclipboard) == "function" then
                pcall(function() setclipboard(DebugConsoleBox.Text) end)
                ObsidianGlassEngine:Notify({ Title = "Copied", Content = "Copied debug console log to clipboard!", Duration = 3 })
            end
        else
            ObsidianGlassEngine:Notify({ Title = "Warning", Content = "Debug log is empty!", Duration = 2 })
        end
    end
})

DebugTab:AddButton({
    Title = "💾 Save Debug Log to File",
    Callback = function()
        if #DebugLogs > 0 then
            if typeof(makefolder) == "function" then
                pcall(function() makefolder("ValenHub_Dumps") end)
                pcall(function() makefolder("ValenHub_Dumps/DebugLogs") end)
            end
            local fileName = "ValenHub_Dumps/DebugLogs/SystemDebug_" .. os.date("%Y%m%d_%H%M%S") .. ".log"
            if typeof(writefile) == "function" then pcall(function() writefile(fileName, DebugConsoleBox.Text) end) end
            ObsidianGlassEngine:Notify({ Title = "Log Saved", Content = "Saved debug log to " .. fileName, Duration = 4 })
        else
            ObsidianGlassEngine:Notify({ Title = "Warning", Content = "No debug logs to save.", Duration = 2 })
        end
    end
})


-- 1. AI GENERATOR TAB BUILDER (Remains linked below)


-- 1. AI GENERATOR TAB BUILDER
do
    AiTab:AddSection("📚 GITHUB KNOWLEDGE ENGINE (DECISION SUPPORT)")

    local kbCard = Instance.new("Frame")
    kbCard.Size = UDim2.new(1, -10, 0, 75)
    kbCard.BackgroundColor3 = COLORS.glassDeep
    kbCard.BackgroundTransparency = 0.18
    kbCard.BorderSizePixel = 0
    kbCard.Parent = AiTab.page

    local kbcCorner = Instance.new("UICorner")
    kbcCorner.CornerRadius = UDim.new(0, 8)
    kbcCorner.Parent = kbCard

    local kbcStroke = Instance.new("UIStroke")
    kbcStroke.Color = COLORS.surface
    kbcStroke.Thickness = 1
    kbcStroke.Parent = kbCard

    local kbStatusText = Instance.new("TextLabel")
    kbStatusText.Size = UDim2.new(1, -16, 1, -12)
    kbStatusText.Position = UDim2.new(0, 8, 0, 6)
    kbStatusText.BackgroundTransparency = 1
    kbStatusText.Font = Enum.Font.Code
    kbStatusText.TextSize = 11
    kbStatusText.TextColor3 = Color3.fromRGB(0, 230, 180)
    kbStatusText.TextXAlignment = Enum.TextXAlignment.Left
    kbStatusText.TextYAlignment = Enum.TextYAlignment.Top
    kbStatusText.Parent = kbCard

    local function updateKnowledgeCardUI()
        if kbStatusText and kbStatusText.Parent then
            local status = KnowledgeEngine.IsLoaded and "🟢 ONLINE" or "🟡 INITIALIZING / OFFLINE"
            local cacheCount = 0
            for _ in pairs(KnowledgeEngine.DocCache) do cacheCount = cacheCount + 1 end
            kbStatusText.Text = string.format(
                "GITHUB KNOWLEDGE RETRIEVAL LAYER:\n• Status: %s\n• Indexed Documents: %d entries (manifest.txt)\n• Active Cache: %d loaded files\n• Last Sync: %s",
                status, #KnowledgeEngine.ManifestEntries, cacheCount, KnowledgeEngine.LastSyncTime
            )
        end
    end

    task.spawn(function()
        while task.wait(2) do
            if not kbStatusText or not kbStatusText.Parent then break end
            updateKnowledgeCardUI()
        end
    end)

    AiTab:AddButton({
        Title = "🔄 Sync & Update GitHub Knowledge Base",
        Callback = function()
            ObsidianGlassEngine:Notify({ Title = "Knowledge Base", Content = "Fetching latest manifest and updating knowledge cache...", Duration = 3 })
            task.spawn(function()
                KnowledgeEngine:Refresh()
                updateKnowledgeCardUI()
                ObsidianGlassEngine:Notify({
                    Title = "Knowledge Base Updated",
                    Content = string.format("Synced %d knowledge documents from GitHub!", #KnowledgeEngine.ManifestEntries),
                    Duration = 4
                })
            end)
        end
    })
end

local PromptInput, CodeTerminal, processBtnObj, saveBtnObj

do
    AiTab:AddSection("AI CODE SYNTHESIZER")

    -- Prompt Input Frame (Glass Card)
    local promptCard = Instance.new("Frame")
    promptCard.Size = UDim2.new(1, -10, 0, 72)
    promptCard.BackgroundColor3 = COLORS.glassDeep
    promptCard.BackgroundTransparency = 0.18
    promptCard.BorderSizePixel = 0
    promptCard.Parent = AiTab.page

    local pcCorner = Instance.new("UICorner")
    pcCorner.CornerRadius = UDim.new(0, 8)
    pcCorner.Parent = promptCard

    local pcStroke = Instance.new("UIStroke")
    pcStroke.Color = COLORS.surface
    pcStroke.Thickness = 1
    pcStroke.Parent = promptCard

    local promptLabel = Instance.new("TextLabel")
    promptLabel.Size = UDim2.new(1, -24, 0, 20)
    promptLabel.Position = UDim2.new(0, 12, 0, 8)
    promptLabel.BackgroundTransparency = 1
    promptLabel.Text = "ENTER SEMANTIC INTENT PROMPT (THAI / ENGLISH SUPPORTED)"
    promptLabel.TextColor3 = COLORS.textMuted
    promptLabel.Font = Enum.Font.GothamBold
    promptLabel.TextSize = 11
    promptLabel.TextXAlignment = Enum.TextXAlignment.Left
    promptLabel.Parent = promptCard

    PromptInput = Instance.new("TextBox")
    PromptInput.Size = UDim2.new(1, -24, 0, 34)
    PromptInput.Position = UDim2.new(0, 12, 0, 30)
    PromptInput.BackgroundColor3 = COLORS.input
    PromptInput.BackgroundTransparency = 0.20
    PromptInput.PlaceholderText = "เช่น 'อยากเขียนสคริปสั่งให้บิน', 'มองทะลุคน', 'อมตะ', 'ฟาร์ม', ' katana'"
    PromptInput.Text = ""
    PromptInput.Font = Enum.Font.GothamSemibold
    PromptInput.TextSize = 12
    PromptInput.TextColor3 = COLORS.cyan
    PromptInput.ClearTextOnFocus = false
    PromptInput.TextXAlignment = Enum.TextXAlignment.Left
    PromptInput.Parent = promptCard

    local piCorner = Instance.new("UICorner")
    piCorner.CornerRadius = UDim.new(0, 6)
    piCorner.Parent = PromptInput

    local piPad = Instance.new("UIPadding")
    piPad.PaddingLeft = UDim.new(0, 10)
    piPad.Parent = PromptInput

    -- Quick Prompt Preset Buttons (Thai AI Command Suggestions)
    AiTab:AddSection("💡 QUICK THAI AI COMMANDS (กดสั่งงานทันที)")

    local quickCommandsFrame = Instance.new("Frame")
    quickCommandsFrame.Size = UDim2.new(1, -10, 0, 68)
    quickCommandsFrame.BackgroundColor3 = COLORS.glassDeep
    quickCommandsFrame.BackgroundTransparency = 0.18
    quickCommandsFrame.BorderSizePixel = 0
    quickCommandsFrame.Parent = AiTab.page

    local qcfCorner = Instance.new("UICorner")
    qcfCorner.CornerRadius = UDim.new(0, 8)
    qcfCorner.Parent = quickCommandsFrame

    local qcfGrid = Instance.new("UIGridLayout")
    qcfGrid.CellSize = UDim2.new(0.24, -4, 0, 26)
    qcfGrid.CellPadding = UDim2.new(0, 4, 0, 4)
    qcfGrid.Parent = quickCommandsFrame

    local qcfPad = Instance.new("UIPadding")
    qcfPad.PaddingTop = UDim.new(0, 6)
    qcfPad.PaddingLeft = UDim.new(0, 6)
    qcfPad.PaddingRight = UDim.new(0, 6)
    qcfPad.PaddingBottom = UDim.new(0, 6)
    qcfPad.Parent = quickCommandsFrame

    local thaiPresets = {
        { Label = "✈️ สคริปต์บิน", Prompt = "อยากเขียนสคริปสั่งให้บิน" },
        { Label = "👁️ มองทะลุคน", Prompt = "มองทะลุคน ESP" },
        { Label = "⚡ วิ่งเร็ว/สปีด", Prompt = "วิ่งเร็ว สปีด speed" },
        { Label = "🛡️ โหมดอมตะ", Prompt = "โหมดอมตะ godmode" },
        { Label = "🤖 ออโต้ฟาร์ม", Prompt = "ออโต้ฟาร์ม เก็บของ" },
        { Label = "🎯 ล็อกเป้าหัว", Prompt = "ล็อกเป้า ยิงหัว aim" },
        { Label = "⚔️ เสกดาบคาตานะ", Prompt = "เสกดาบ katana" },
        { Label = "🌐 ดักจับรีโมท", Prompt = "ดักจับรีโมท spy remote" }
    }

    for idx, preset in ipairs(thaiPresets) do
        local pBtn = Instance.new("TextButton")
        pBtn.Size = UDim2.new(1, 0, 1, 0)
        pBtn.BackgroundColor3 = Color3.fromRGB(14, 38, 24)
        pBtn.Text = preset.Label
        pBtn.TextColor3 = Color3.fromRGB(0, 230, 150)
        pBtn.Font = Enum.Font.GothamBold
        pBtn.TextSize = 10
        pBtn.LayoutOrder = idx
        pBtn.Parent = quickCommandsFrame

        local pbCorner = Instance.new("UICorner")
        pbCorner.CornerRadius = UDim.new(0, 5)
        pbCorner.Parent = pBtn

        local pbStroke = Instance.new("UIStroke")
        pbStroke.Color = COLORS.surfaceHover
        pbStroke.Thickness = 1
        pbStroke.Parent = pBtn

        pBtn.MouseButton1Click:Connect(function()
            playClickSound()
            PromptInput.Text = preset.Prompt
            ObsidianGlassEngine:Notify({ Title = "AI Command Selected", Content = "เลือกคำสั่ง: " .. preset.Label, Duration = 2 })
        end)
    end

    -- Process Button
    processBtnObj = AiTab:AddButton({
        Title = "⚡ Formulate Lexical Output Code (ประมวลผลคำสั่งไทย/อังกฤษ)",
        Callback = function() end
    })

    -- Output Terminal Frame
    AiTab:AddSection("COMPILED OUTPUT SOURCE CODE TERMINAL")

    local terminalCard = Instance.new("Frame")
    terminalCard.Size = UDim2.new(1, -10, 0, 180)
    terminalCard.BackgroundColor3 = COLORS.glassDeep
    terminalCard.BackgroundTransparency = 0.18
    terminalCard.BorderSizePixel = 0
    terminalCard.Parent = AiTab.page

    local tcCardCorner = Instance.new("UICorner")
    tcCardCorner.CornerRadius = UDim.new(0, 8)
    tcCardCorner.Parent = terminalCard

    local tcCardStroke = Instance.new("UIStroke")
    tcCardStroke.Color = COLORS.surface
    tcCardStroke.Thickness = 1
    tcCardStroke.Parent = terminalCard

    local ctScroll = Instance.new("ScrollingFrame")
    ctScroll.Size = UDim2.new(1, -12, 1, -12)
    ctScroll.Position = UDim2.new(0, 6, 0, 6)
    ctScroll.BackgroundColor3 = COLORS.input
    ctScroll.BackgroundTransparency = 0.30
    ctScroll.BorderSizePixel = 0
    ctScroll.ScrollBarThickness = 5
    ctScroll.ScrollBarImageColor3 = COLORS.cyan
    ctScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    ctScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ctScroll.Parent = terminalCard

    local ctsCorner = Instance.new("UICorner")
    ctsCorner.CornerRadius = UDim.new(0, 6)
    ctsCorner.Parent = ctScroll

    CodeTerminal = Instance.new("TextBox")
    CodeTerminal.Size = UDim2.new(1, -10, 1, 0)
    CodeTerminal.Position = UDim2.new(0, 5, 0, 0)
    CodeTerminal.BackgroundTransparency = 1
    CodeTerminal.PlaceholderText = "-- Generated Luau semantic source output will display here..."
    CodeTerminal.Text = ""
    CodeTerminal.Font = Enum.Font.Code
    CodeTerminal.TextSize = 11
    CodeTerminal.TextColor3 = Color3.fromRGB(100, 230, 255)
    CodeTerminal.MultiLine = true
    CodeTerminal.ClearTextOnFocus = false
    CodeTerminal.TextXAlignment = Enum.TextXAlignment.Left
    CodeTerminal.TextYAlignment = Enum.TextYAlignment.Top
    CodeTerminal.AutomaticSize = Enum.AutomaticSize.Y
    CodeTerminal.Parent = ctScroll

    local ctPad = Instance.new("UIPadding")
    ctPad.PaddingLeft = UDim.new(0, 6)
    ctPad.PaddingTop = UDim.new(0, 6)
    ctPad.Parent = CodeTerminal

    -- Execute Instant Button
    local execBtnObj = AiTab:AddButton({
        Title = "▶️ Execute Synthesized AI Script Now (รันโค้ด AI ทันที)",
        Style = "primary",
        Callback = function()
            playClickSound()
            local code = CodeTerminal.Text
            if code and code ~= "" then
                local func, err = loadstring(code)
                if func then
                    task.spawn(func)
                    ObsidianGlassEngine:Notify({ Title = "AI Execution Success", Content = "เริ่มรันสคริปต์ AI ในแมพสำเร็จ!", Duration = 3 })
                else
                    ObsidianGlassEngine:Notify({ Title = "Syntax Error", Content = "โค้ดมีข้อผิดพลาด: " .. tostring(err), Duration = 5 })
                end
            else
                ObsidianGlassEngine:Notify({ Title = "Warning", Content = "ยังไม่มีโค้ดในเทอร์มินัล! กรุณาประมวลผลก่อน", Duration = 3 })
            end
        end
    })

    -- Save Button to Library & Dumper Preview Sync
    saveBtnObj = AiTab:AddButton({
        Title = "💾 Save Compiled Assets to Scroll Library & Preview (บันทึกข้ามระบบ)",
        Callback = function()
            playClickSound()
            local code = CodeTerminal.Text
            if code and code ~= "" then
                local macroName = "AI Compiled: " .. (PromptInput.Text ~= "" and PromptInput.Text or ("Script_" .. os.date("%H%M%S")))
                table.insert(SessionRegistry.Macros, {
                    Name = macroName,
                    Code = code
                })
                if populateLibraryScroll then pcall(populateLibraryScroll) end
                if setPreviewData then pcall(function() setPreviewData(code, "AI_Synthesized_Script") end) end
                
                ObsidianGlassEngine:Notify({
                    Title = "Asset Saved",
                    Content = "บันทึกสคริปต์ลง Library และ Instance Dumper Preview เรียบร้อย!",
                    Duration = 4
                })
            else
                ObsidianGlassEngine:Notify({ Title = "Warning", Content = "ไม่มีโค้ดให้บันทึก!", Duration = 3 })
            end
        end
    })

    -- Process Execution Handler (V7 AUTONOMOUS CYBER-AI ASSEMBLY ENGINE)
    processBtnObj.MouseButton1Click:Connect(function()
        playClickSound()
        local userPrompt = PromptInput.Text
        local rawText = string.lower(userPrompt)
        if rawText == "" then
            ObsidianGlassEngine:Notify({ Title = "Warning", Content = "กรุณากรอกคำสั่งหรือความต้องการก่อน!", Duration = 3 })
            return
        end

        DebugLog("INFO", "AI_SYNTH", "Synthesizing V7 Code for prompt: '" .. userPrompt .. "'")
        
        -- 1. EXPANDED TOKENS & INTENT EXTRACTION
        local expandedTokens = KnowledgeEngine:ExpandQuery(userPrompt)
        local searchSet = {}
        for _, tok in ipairs(expandedTokens) do searchSet[tok] = true end
        searchSet[rawText] = true

        -- Extract numbers from prompt (e.g. "เร็ว 150", "บิน 100", "เลือด 999999")
        local customNum = tonumber(string.match(userPrompt, "(%d+)")) or nil

        -- 2. DYNAMIC PATTERN MATCHING & FEATURE EXTRACTION
        local matchedBlocks = {}
        local matchedTitles = {}
        local matchedBlockSet = {}

        for _, block in ipairs(SemanticPatterns) do
            local isMatched = false
            for _, keyword in ipairs(block.Keywords) do
                local kwLower = string.lower(keyword)
                if string.find(rawText, kwLower, 1, true) or searchSet[kwLower] then
                    isMatched = true
                    break
                else
                    for tok in pairs(searchSet) do
                        if string.find(tok, kwLower, 1, true) or string.find(kwLower, tok, 1, true) then
                            isMatched = true
                            break
                        end
                    end
                end
                if isMatched then break end
            end

            if isMatched and not matchedBlockSet[block.Title] then
                matchedBlockSet[block.Title] = true
                table.insert(matchedBlocks, block)
                table.insert(matchedTitles, block.Title)
            end
        end

        -- 3. GITHUB KNOWLEDGE BASE RETRIEVAL & REAL CODE INJECTION
        local matchedKnowledge = KnowledgeEngine:Search(userPrompt, 3)
        local injectedKnowledgeCode = {}

        for _, res in ipairs(matchedKnowledge) do
            local docContent = KnowledgeEngine:GetDocument(res.Path)
            if docContent then
                local luaBlock = string.match(docContent, "```lua(.-)```") or string.match(docContent, "```(.-)```")
                if luaBlock then
                    luaBlock = string.gsub(luaBlock, "^%s*(.-)%s*$", "%1")
                    table.insert(injectedKnowledgeCode, string.format("-- [[ REPO PATTERN: %s (%s) ]]\n%s", res.Title, res.Path, luaBlock))
                end
            end
        end

        -- 4. REAL-TIME GAME ENVIRONMENT DISCOVERY
        local liveDiscoveredPrompts = {}
        local liveDiscoveredRemotes = {}
        local liveDiscoveredTools = {}

        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if #liveDiscoveredPrompts < 3 and obj:IsA("ProximityPrompt") then
                    table.insert(liveDiscoveredPrompts, obj:GetFullName())
                end
            end
            local rSvc = game:GetService("ReplicatedStorage")
            for _, obj in ipairs(rSvc:GetDescendants()) do
                if #liveDiscoveredRemotes < 3 and (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then
                    table.insert(liveDiscoveredRemotes, obj:GetFullName())
                end
            end
            if LocalPlayer and LocalPlayer:FindFirstChild("Backpack") then
                for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
                    if t:IsA("Tool") then
                        table.insert(liveDiscoveredTools, t.Name)
                    end
                end
            end
        end)

        -- 5. BUILD PROACTIVE AI ADVICE & ARCHITECTURAL SUGGESTIONS
        local aiRecommendations = {
            "-- ======================================================================================",
            "-- [[ 🧠 PAYOMBOYZ CYBER-AI V7 - PROACTIVE ARCHITECTURAL ANALYSIS & ADVICE ]]",
            "-- • Analyzed User Intent Tokens: [" .. table.concat(expandedTokens, ", ") .. "]",
            "-- • Target Game Live Inspection: Discovered " .. #liveDiscoveredPrompts .. " Prompts, " .. #liveDiscoveredRemotes .. " Remotes & " .. #liveDiscoveredTools .. " Backpack Tools.",
            "-- • AI Recommended Optimizations:"
        }

        if searchSet["fly"] or searchSet["บิน"] or searchSet["เหาะ"] then
            local speedVal = customNum or 80
            table.insert(aiRecommendations, string.format("--   [+] Dynamic Velocity Configured: Set Fly/WalkSpeed to %d based on prompt context.", speedVal))
            table.insert(aiRecommendations, "--   [+] Safe Execution Mode: Injected Noclip & Anti-Fall-Damage loops to prevent character death.")
        end
        if searchSet["esp"] or searchSet["มองทะลุ"] then
            table.insert(aiRecommendations, "--   [+] Visual Matrix Optimization: Applied Billboard / Highlight transparency = 0.4 for smooth FPS.")
        end
        if searchSet["farm"] or searchSet["ฟาร์ม"] then
            table.insert(aiRecommendations, "--   [+] Auto-Farm Protection: Bound task.wait(0.3) throttle to avoid anti-cheat flag.")
        end
        table.insert(aiRecommendations, "-- ======================================================================================")

        -- 6. FULLY ENCAPSULATED CODE GENERATION PIPELINE
        local codeLines = {
            "-- ======================================================================================",
            "-- [[ PAYOMBOYZ CYBER-AI V7 AUTONOMOUS SYNTHESIZED SCRIPT ]]",
            "-- Intent: " .. userPrompt,
            "-- Environment: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. " (PlaceID: " .. tostring(game.PlaceId) .. ")",
            "-- Timestamp: " .. os.date("%Y-%m-%d %H:%M:%S"),
            "-- Synthesis Engine: GitHub Repo Knowledge + Live Game Environment Integration",
            "-- ======================================================================================",
            "",
            table.concat(aiRecommendations, "\n"),
            "",
            "-- [[ SECTION 1: GITHUB REPO ARCHITECTURAL KNOWLEDGE INGESTION ]]",
            #injectedKnowledgeCode > 0 and table.concat(injectedKnowledgeCode, "\n\n") or "-- (No external repo patterns injected)",
            "",
            "-- [[ SECTION 2: LIVE GAME INSTANCE ENVIRONMENT RESOLUTION ]]",
            string.format("local TargetPlaceId = %d", game.PlaceId),
            string.format("local LocalPlayer = game:GetService(\"Players\").LocalPlayer"),
            string.format("local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()"),
            string.format("local Humanoid = Character:WaitForChild(\"Humanoid\")"),
            string.format("local HumanoidRootPart = Character:WaitForChild(\"HumanoidRootPart\")"),
            ""
        }

        -- Append discovered live instances
        if #liveDiscoveredPrompts > 0 then
            codeLines[#codeLines + 1] = "-- Discovered Game Prompts:"
            for idx, path in ipairs(liveDiscoveredPrompts) do
                codeLines[#codeLines + 1] = string.format("local DiscoveredPrompt_%d = game:GetService(%q)", idx, path)
            end
            codeLines[#codeLines + 1] = ""
        end

        if #liveDiscoveredRemotes > 0 then
            codeLines[#codeLines + 1] = "-- Discovered Game Remotes:"
            for idx, path in ipairs(liveDiscoveredRemotes) do
                codeLines[#codeLines + 1] = string.format("local DiscoveredRemote_%d = game:GetService(%q)", idx, path)
            end
            codeLines[#codeLines + 1] = ""
        end

        -- Section 3: Executable Sub-System Modules
        codeLines[#codeLines + 1] = "-- [[ SECTION 3: EXECUTABLE SUB-SYSTEM MODULES ]]"
        codeLines[#codeLines + 1] = "local ScriptEngine = { Active = true }"
        codeLines[#codeLines + 1] = "function ScriptEngine:Initialize()"
        codeLines[#codeLines + 1] = "    print('[PayomboyZ Cyber-AI V7] Launching synthesized script payload...')"

        if customNum then
            codeLines[#codeLines + 1] = string.format("    Humanoid.WalkSpeed = %d", customNum)
            codeLines[#codeLines + 1] = string.format("    Humanoid.JumpPower = %d", math.clamp(customNum * 0.8, 50, 300))
        end

        if #matchedBlocks > 0 then
            for _, block in ipairs(matchedBlocks) do
                codeLines[#codeLines + 1] = "\n    -- Sub-System: " .. block.Title
                local blockCode = block.Code
                if customNum then
                    blockCode = string.gsub(blockCode, "WalkSpeed = %d+", "WalkSpeed = " .. customNum)
                    blockCode = string.gsub(blockCode, "JumpPower = %d+", "JumpPower = " .. math.floor(customNum * 0.8))
                end
                if block.Title == "Weapon_Tool_Synthesizer" then
                    blockCode = "local PromptInput = {Text = [[" .. userPrompt .. "]]}\n" .. blockCode
                end
                for line in string.gmatch(blockCode, "[^\r\n]+") do
                    codeLines[#codeLines + 1] = "    " .. line
                end
            end
        else
            codeLines[#codeLines + 1] = "    print('[PayomboyZ Cyber-AI V7] Executing contextual module for prompt: ' .. " .. string.format("%q", userPrompt) .. ")"
        end

        codeLines[#codeLines + 1] = "\n    game:GetService(\"StarterGui\"):SetCore(\"SendNotification\", {"
        codeLines[#codeLines + 1] = "        Title = 'PayomboyZ AI V7 Loaded',"
        codeLines[#codeLines + 1] = "        Text = 'Synthesized script for: " .. userPrompt:gsub("'", "") .. "',"
        codeLines[#codeLines + 1] = "        Duration = 5"
        codeLines[#codeLines + 1] = "    })"
        codeLines[#codeLines + 1] = "end"
        codeLines[#codeLines + 1] = "\ntask.spawn(function() ScriptEngine:Initialize() end)"
        codeLines[#codeLines + 1] = "return ScriptEngine"

        local fullCompiledCode = table.concat(codeLines, "\n")
        CodeTerminal.Text = fullCompiledCode
        PromptInput.Text = ""

        ObsidianGlassEngine:Notify({
            Title = "Cyber-AI V7 Synthesized",
            Content = string.format("หลอมรวมซอร์สโค้ดสำเร็จ! %d โมดูล + %d รูปแบบ GitHub + %d เกมอินสแตนซ์จริง", #matchedBlocks, #injectedKnowledgeCode, #liveDiscoveredPrompts + #liveDiscoveredRemotes),
            Duration = 4
        })
    end)
end

-- 2. LIBRARY TAB BUILDER & POPULATOR
local SessionRegistry = {
    Macros = {
        { Name = "Sempshark Open HTTP Traffic Inspector", Code = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/Sempiller/SempShark/refs/heads/main/main.lua\"))()" },
        { Name = "AXIOS Multiply By Delta", Code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/AAPVdev/scripts/refs/heads/main/UI_LimbExtender.lua'))()" },
        { Name = "PayomboyZ Anime Card Farm", Code = "loadstring(game:HttpGet('https://payomboyz333.github.io/Anime-Card-Farm/'))()" },
        { Name = "Dex Debugging Explorer", Code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/infyiff/backup/main/dex.lua'))()" },
        { Name = "Infinite Yield Admin Tools", Code = "loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()" }
    }
}
local MacroCounter = 1
local populateLibraryScroll

do
    LibraryTab:AddSection("MOUNTED MICRO MODULES LIBRARY")

    local libContainer = Instance.new("Frame")
    libContainer.Size = UDim2.new(1, -10, 0, 320)
    libContainer.BackgroundColor3 = COLORS.glassDeep
    libContainer.BackgroundTransparency = 0.18
    libContainer.BorderSizePixel = 0
    libContainer.Parent = LibraryTab.page

    local lcCorner = Instance.new("UICorner")
    lcCorner.CornerRadius = UDim.new(0, 8)
    lcCorner.Parent = libContainer

    local lcScroller = Instance.new("ScrollingFrame")
    lcScroller.Size = UDim2.new(1, -16, 1, -16)
    lcScroller.Position = UDim2.new(0, 8, 0, 8)
    lcScroller.BackgroundTransparency = 1
    lcScroller.BorderSizePixel = 0
    lcScroller.ScrollBarThickness = 4
    lcScroller.ScrollBarImageColor3 = COLORS.cyan
    lcScroller.Parent = libContainer

    local lcLayout = Instance.new("UIListLayout")
    lcLayout.Padding = UDim.new(0, 6)
    lcLayout.Parent = lcScroller

    lcLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        lcScroller.CanvasSize = UDim2.new(0, 0, 0, lcLayout.AbsoluteContentSize.Y + 10)
    end)

    populateLibraryScroll = function()
        for _, child in ipairs(lcScroller:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
        end
        
        if #SessionRegistry.Macros == 0 then
            local emptyLabel = Instance.new("TextLabel")
            emptyLabel.Size = UDim2.new(1, 0, 0, 40)
            emptyLabel.BackgroundTransparency = 1
            emptyLabel.Text = "No saved modules in library yet."
            emptyLabel.TextColor3 = COLORS.textMuted
            emptyLabel.Font = Enum.Font.Gotham
            emptyLabel.TextSize = 12
            emptyLabel.Parent = lcScroller
            return
        end

        for idx, data in ipairs(SessionRegistry.Macros) do
            local itemFrame = Instance.new("Frame")
            itemFrame.Size = UDim2.new(1, -6, 0, 42)
            itemFrame.BackgroundColor3 = COLORS.surface
            itemFrame.BackgroundTransparency = 0.20
            itemFrame.Parent = lcScroller
            
            local ifCorner = Instance.new("UICorner")
            ifCorner.CornerRadius = UDim.new(0, 6)
            ifCorner.Parent = itemFrame

            local itemTitle = Instance.new("TextLabel")
            itemTitle.Size = UDim2.new(1, -140, 1, 0)
            itemTitle.Position = UDim2.new(0, 12, 0, 0)
            itemTitle.BackgroundTransparency = 1
            itemTitle.Text = "⚡ " .. data.Name
            itemTitle.TextColor3 = COLORS.text
            itemTitle.Font = Enum.Font.GothamBold
            itemTitle.TextSize = 12
            itemTitle.TextXAlignment = Enum.TextXAlignment.Left
            itemTitle.Parent = itemFrame

            local runBtn = Instance.new("TextButton")
            runBtn.Size = UDim2.fromOffset(60, 26)
            runBtn.Position = UDim2.new(1, -130, 0.5, -13)
            runBtn.BackgroundColor3 = COLORS.primary
            runBtn.Text = "▶ Run"
            runBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            runBtn.Font = Enum.Font.GothamBold
            runBtn.TextSize = 11
            runBtn.Parent = itemFrame

            local rbCorner = Instance.new("UICorner")
            rbCorner.CornerRadius = UDim.new(0, 4)
            rbCorner.Parent = runBtn

            runBtn.MouseButton1Click:Connect(function()
                playClickSound()
                local comp, err = loadstring(data.Code)
                if comp then
                    task.spawn(comp)
                    ObsidianGlassEngine:Notify({ Title = "Execution Success", Content = "Module executed: " .. data.Name, Duration = 3 })
                else
                    local scr = Instance.new("LocalScript")
                    scr.Source = data.Code
                    scr.Disabled = false
                    scr.Parent = game.Players.LocalPlayer.Character or game.Workspace
                    task.wait(0.1)
                    scr:Destroy()
                    ObsidianGlassEngine:Notify({ Title = "Executed", Content = "Module attached to character.", Duration = 3 })
                end
            end)

            local delBtn = Instance.new("TextButton")
            delBtn.Size = UDim2.fromOffset(60, 26)
            delBtn.Position = UDim2.new(1, -65, 0.5, -13)
            delBtn.BackgroundColor3 = COLORS.surfacePressed
            delBtn.Text = "🗑 Del"
            delBtn.TextColor3 = COLORS.danger
            delBtn.Font = Enum.Font.GothamBold
            delBtn.TextSize = 11
            delBtn.Parent = itemFrame

            local dbCorner = Instance.new("UICorner")
            dbCorner.CornerRadius = UDim.new(0, 4)
            dbCorner.Parent = delBtn

            delBtn.MouseButton1Click:Connect(function()
                playClickSound()
                table.remove(SessionRegistry.Macros, idx)
                populateLibraryScroll()
                ObsidianGlassEngine:Notify({ Title = "Removed", Content = "Deleted module: " .. data.Name, Duration = 3 })
            end)
        end
    end
end

populateLibraryScroll()

-- 3. SETTINGS TAB BUILDER
SettingsTab:AddSection("LANG_SECTION", "🌐 เลือกภาษาใช้งาน (LANGUAGE / สลับภาษา)")

SettingsTab:AddButton({
    TitleKey = "LANG_SWITCH_TH",
    Title = "🇹🇭 ภาษาไทย (Thai - ใช้งานอยู่)",
    Callback = function()
        SwitchLanguage("TH")
    end
})

SettingsTab:AddButton({
    TitleKey = "LANG_SWITCH_EN",
    Title = "🇬🇧 Switch to English",
    Callback = function()
        SwitchLanguage("EN")
    end
})

SettingsTab:AddSection("SCALE_SECTION", "🖥️ UI DISPLAY SCALING")

SettingsTab:AddButton({
    TitleKey = "SCALE_STD",
    Title = "🖥️ Standard Profile (1.0x Scale)",
    Callback = function()
        Window.UIScale.Scale = 1.0
        ObsidianGlassEngine:Notify({ Title = GetText("NOTIF_TITLE"), Content = "Reset to standard scale (1.0x)", Duration = 2 })
    end
})

SettingsTab:AddButton({
    TitleKey = "SCALE_MOBILE",
    Title = "📱 Compact Mobile Profile (0.75x Scale)",
    Callback = function()
        Window.UIScale.Scale = 0.75
        ObsidianGlassEngine:Notify({ Title = GetText("NOTIF_TITLE"), Content = "Set to compact mobile scale (0.75x)", Duration = 2 })
    end
})

SettingsTab:AddSection("EXT_SECTION", "🛠️ EXTERNAL UTILITIES & GAME SCRIPTS")

SettingsTab:AddButton({
    TitleKey = "EXT_ANIME_CARD",
    Title = "🎴 Launch PayomboyZ Anime Card Farm",
    Callback = function()
        ObsidianGlassEngine:Notify({ Title = "Anime Card Farm", Content = "Fetching and launching PayomboyZ Anime Card Farm...", Duration = 3 })
        task.spawn(function()
            local ok, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/payomboyz333/Anime-Card-Farm/refs/heads/main/start.txt"))()
            end)
            if ok then
                ObsidianGlassEngine:Notify({ Title = "Anime Card Farm", Content = "PayomboyZ Anime Card Farm loaded successfully!", Duration = 4 })
            else
                ObsidianGlassEngine:Notify({ Title = "Launch Error", Content = "Failed to launch script: " .. tostring(err), Duration = 5 })
            end
        end)
    end
})

SettingsTab:AddButton({
    TitleKey = "EXT_DEX",
    Title = "🛠️ Launch Dex Debugging Explorer",
    Callback = function()
        ObsidianGlassEngine:Notify({ Title = "Dex Debugger", Content = "Fetching and launching Dex Explorer...", Duration = 3 })
        task.spawn(function()
            local ok, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
            end)
            if ok then
                ObsidianGlassEngine:Notify({ Title = "Dex Debugger", Content = "Dex Debugging Explorer loaded successfully!", Duration = 4 })
            else
                ObsidianGlassEngine:Notify({ Title = "Dex Error", Content = "Failed to launch Dex: " .. tostring(err), Duration = 5 })
            end
        end)
    end
})

SettingsTab:AddButton({
    TitleKey = "EXT_IY",
    Title = "⚡ Launch Infinite Yield Admin Tools",
    Callback = function()
        ObsidianGlassEngine:Notify({ Title = "Infinite Yield", Content = "Fetching and launching Infinite Yield...", Duration = 3 })
        task.spawn(function()
            local ok, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
            end)
            if ok then
                ObsidianGlassEngine:Notify({ Title = "Infinite Yield", Content = "Infinite Yield loaded successfully!", Duration = 4 })
            else
                ObsidianGlassEngine:Notify({ Title = "IY Error", Content = "Failed to launch Infinite Yield: " .. tostring(err), Duration = 5 })
            end
        end)
    end
})

SettingsTab:AddSection("CONFIG_SECTION", "💾 HUB CONFIGURATION & PROFILE MANAGER")

SettingsTab:AddButton({
    TitleKey = "CONFIG_SAVE_BTN",
    Title = "💾 Save Current Profile Config",
    Callback = function()
        local configData = {
            UIScale = Window.UIScale.Scale,
            SpySkipText = SpySkipText,
            CurrentLanguage = CurrentLanguage,
            BoundContextCount = #AIContextEngine.BoundItems,
            SavedTime = os.date("%Y-%m-%d %H:%M:%S")
        }
        local HttpService = game:GetService("HttpService")
        local json = HttpService:JSONEncode(configData)
        if typeof(makefolder) == "function" then pcall(function() makefolder("ValenHub_Dumps") end) end
        if typeof(writefile) == "function" then
            pcall(function() writefile("ValenHub_Dumps/PayomboyZ_Config.json", json) end)
            ObsidianGlassEngine:Notify({ Title = GetText("NOTIF_TITLE"), Content = "Saved profile config to ValenHub_Dumps/PayomboyZ_Config.json", Duration = 4 })
            DebugLog("INFO", "CONFIG", "Saved profile config successfully")
        end
    end
})

SettingsTab:AddButton({
    TitleKey = "CONFIG_LOAD_BTN",
    Title = "📂 Load Saved Profile Config",
    Callback = function()
        if typeof(readfile) == "function" and typeof(isfile) == "function" and isfile("ValenHub_Dumps/PayomboyZ_Config.json") then
            local ok, content = pcall(function() return readfile("ValenHub_Dumps/PayomboyZ_Config.json") end)
            if ok and content then
                local HttpService = game:GetService("HttpService")
                local data = HttpService:JSONDecode(content)
                if data and data.UIScale then
                    Window.UIScale.Scale = data.UIScale
                end
                if data and data.CurrentLanguage then
                    SwitchLanguage(data.CurrentLanguage)
                end
                if data and data.SpySkipText and FilterInput then
                    SpySkipText = data.SpySkipText
                    FilterInput.Text = SpySkipText
                end
                ObsidianGlassEngine:Notify({ Title = GetText("NOTIF_TITLE"), Content = "Loaded settings profile!", Duration = 3 })
                DebugLog("INFO", "CONFIG", "Loaded profile config successfully")
            end
        else
            ObsidianGlassEngine:Notify({ Title = GetText("NOTIF_TITLE"), Content = "No saved config file found.", Duration = 3 })
        end
    end
})

SettingsTab:AddSection("DIAG_SECTION", "📊 SYSTEM DIAGNOSTICS & PERFORMANCE")

local perfCard = Instance.new("Frame")
perfCard.Size = UDim2.new(1, -10, 0, 75)
perfCard.BackgroundColor3 = COLORS.glassDeep
perfCard.BackgroundTransparency = 0.18
perfCard.BorderSizePixel = 0
perfCard.Parent = SettingsTab.page

local perfCorner = Instance.new("UICorner")
perfCorner.CornerRadius = UDim.new(0, 8)
perfCorner.Parent = perfCard

local perfStroke = Instance.new("UIStroke")
perfStroke.Color = COLORS.surface
perfStroke.Thickness = 1
perfStroke.Parent = perfCard

local perfText = Instance.new("TextLabel")
perfText.Size = UDim2.new(1, -16, 1, -12)
perfText.Position = UDim2.new(0, 8, 0, 6)
perfText.BackgroundTransparency = 1
perfText.Font = Enum.Font.Code
perfText.TextSize = 11
perfText.TextColor3 = Color3.fromRGB(150, 230, 255)
perfText.TextXAlignment = Enum.TextXAlignment.Left
perfText.TextYAlignment = Enum.TextYAlignment.Top
perfText.Parent = perfCard

    task.spawn(function()
        while gui and gui.Parent and perfText and perfText.Parent do
            local memKB = gcinfo()
            local memMB = string.format("%.2f MB", memKB / 1024)
            local cacheCount = 0
            for _ in pairs(KnowledgeEngine.DocCache) do cacheCount = cacheCount + 1 end
            perfText.Text = string.format(
                "PERFORMANCE MONITOR V6:\n• Memory Usage: %s (%d KB)\n• Active Connections Tracked: %d\n• Debug Log Buffer: %d entries\n• Bound AI Contexts: %d | GitHub Knowledge: %d docs (%d cached)",
                memMB, memKB, #TrackedConnections, #DebugLogs, #AIContextEngine.BoundItems, #KnowledgeEngine.ManifestEntries, cacheCount
            )
            task.wait(1)
        end
    end)

SettingsTab:AddSection("CONTROL_SECTION", "❌ SYSTEM CONTROL & SESSION")

SettingsTab:AddButton({
    Title = "🚪 ออกจากระบบ (Logout & Return to Loader)",
    Callback = function()
        CleanupConnections()
        local mainGui = parentGui:FindFirstChild("ObsidianGlass2_UI")
        if mainGui then mainGui:Destroy() end
        RedirectToStartLoader("🚪 ออกจากระบบสำเร็จ! กำลังกลับไปยังหน้า PayomboyZ Loader...")
    end
})

SettingsTab:AddButton({
    TitleKey = "NOTIF_TEST_BTN",
    Title = "🔔 Test Toast Notification",
    Callback = function()
        ObsidianGlassEngine:Notify({
            Title = GetText("NOTIF_TITLE"),
            Content = "Obsidian Glassmorphic 2 Engine working at peak performance!",
            Duration = 4
        })
    end
})

SettingsTab:AddButton({
    TitleKey = "UNLOAD_HUB_BTN",
    Title = "❌ Unload PayomboyZ Hub UI & Cleanup Connections",
    Callback = function()
        CleanupConnections()
        local gui = parentGui:FindFirstChild("ObsidianGlass2_UI")
        if gui then gui:Destroy() end
        DebugLog("INFO", "SYSTEM", "Unloaded PayomboyZ AI Engine UI cleanly")
    end
})

DebugLog("INFO", "SYSTEM", "PayomboyZ AI Engine V6 Core Architecture Initialized Successfully!")

ObsidianGlassEngine:Notify({
    Title = "PayomboyZ Script HUB",
    Content = "Obsidian Glassmorphic 2 Engine Loaded Successfully!",
    Duration = 5
})
