--// Ouroboros - One Run UI Translator
--// รันครั้งเดียว:
--// 1. ติดตั้ง UI Translator
--// 2. โหลด Ouroboros
--// 3. Ouroboros สร้าง UI -> แปลให้อัตโนมัติ
--// 4. UI ที่สร้างภายหลังก็แปลด้วย

local GAME_URL =
    "https://raw.githubusercontent.com/bloxfruitsnokey/Fluent/refs/heads/main/EZ/script.luau"

--==================================================
-- TRANSLATION
--==================================================

local TRANSLATIONS = {

["EZ Hub - Blox Fruits"] = "EZ Hub - Blox Fruits",
["Farm"] = "ฟาร์ม",
["Config"] = "การตั้งค่า",
["Fighting Style"] = "สไตล์การต่อสู้",
["Items Farm"] = "ฟาร์มไอเทม",
["Sea Events"] = "อีเวนต์ทะเล",
["Mirage - RaceV4"] = "มิราจ - เผ่า V4",
["Drago Dojo"] = "สำนักดราโก",
["Prehistoric"] = "ยุคก่อนประวัติศาสตร์",
["Raid"] = "เรด",
["Combat PVP"] = "ต่อสู้ PVP",
["Boss Spawn Notification"] = "แจ้งเตือนบอสเกิด",
["Notifies you when a world boss spawns in this server"] = "แจ้งเตือนคุณเมื่อบอสโลกเกิดในเซิร์ฟเวอร์นี้",
["Rare Island Spawn Notification"] = "แจ้งเตือนเกาะหายากเกิด",
["Notifies you when Mirage/Kitsune Island spawns"] = "แจ้งเตือนคุณเมื่อเกาะมิราจ/คิตسุเนะเกิด",
["Buso/Aura Colours"] = "สีฮา/ออร่า",
["Current Buso Color:"] = "สีฮาคิปัจจุบัน:",
["None"] = "ไม่มี",
["Auto Buso Rarity:"] = "สุ่มความหายากฮาคิอัตโนมัติ:",
["Random"] = "สุ่ม",
["Auto Buy Buso Color"] = "ซื้อสีฮาคิอัตโนมัติ",
["Teleport to Barista and buy this Buso color tier"] = "เทเลพอร์ตไปหา บาริสต้า และซื้อสีฮาคิระดับนี้",
["Auto Teleport Barista Cousin"] = "เทเลพอร์ตไปหาญาติบาริสต้าอัตโนมัติ"
}

--==================================================
-- SETTINGS
--==================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- เก็บ object ที่เราเคยติดตามแล้ว
local tracked = {}

--==================================================
-- TRANSLATOR
--==================================================

local function translateText(text)
    if type(text) ~= "string" or text == "" then
        return text
    end

    -- แปลแบบตรงตัวก่อน
    local exact = TRANSLATIONS[text]

    if exact then
        return exact
    end

    -- แปลข้อความที่มีคำเหล่านี้อยู่ข้างใน
    local result = text

    for english, thai in pairs(TRANSLATIONS) do
        if string.find(result, english, 1, true) then
            result = string.gsub(result, english, thai)
        end
    end

    return result
end

--==================================================
-- HOOK TEXT OBJECT
--==================================================

local function hookTextObject(obj)

    if tracked[obj] then
        return
    end

    if not (
        obj:IsA("TextLabel")
        or obj:IsA("TextButton")
        or obj:IsA("TextBox")
    ) then
        return
    end

    tracked[obj] = true

    -- แปลทันที
    pcall(function()
        local oldText = obj.Text
        local newText = translateText(oldText)

        if newText ~= oldText then
            obj.Text = newText
        end
    end)

    -- ถ้าสคริปต์เปลี่ยนข้อความภายหลัง
    pcall(function()

        obj:GetPropertyChangedSignal("Text"):Connect(function()

            if not obj.Parent then
                return
            end

            local oldText = obj.Text
            local newText = translateText(oldText)

            if newText ~= oldText then
                obj.Text = newText
            end

        end)

    end)
end

--==================================================
-- SCAN UI
--==================================================

local function scan(root)

    if not root then
        return
    end

    -- root เอง
    pcall(function()
        hookTextObject(root)
    end)

    -- ลูกทั้งหมด
    pcall(function()

        for _, obj in ipairs(root:GetDescendants()) do
            hookTextObject(obj)
        end

    end)
end

--==================================================
-- WATCH NEW UI
--==================================================

local function watchRoot(root)

    if not root then
        return
    end

    scan(root)

    pcall(function()

        root.DescendantAdded:Connect(function(obj)

            task.defer(function()
                hookTextObject(obj)
            end)

        end)

    end)
end

--==================================================
-- START TRANSLATOR FIRST
--==================================================

watchRoot(CoreGui)

if LocalPlayer then

    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

    if playerGui then
        watchRoot(playerGui)
    end

    -- เผื่อ PlayerGui ถูกสร้างภายหลัง
    LocalPlayer.ChildAdded:Connect(function(child)

        if child:IsA("PlayerGui") then
            watchRoot(child)
        end

    end)

end

--==================================================
-- LOAD OUROBOROS
--==================================================

task.wait()

local success, source = pcall(function()

    return game:HttpGet(GAME_URL)

end)

if not success then

    warn("[Ouroboros Translator] โหลดสคริปต์ไม่สำเร็จ")
    warn(source)

    return
end

if type(source) ~= "string" or #source < 10 then

    warn("[Ouroboros Translator] ได้ source ไม่ถูกต้อง")

    return
end

--==================================================
-- EXECUTE
--==================================================

local loader, compileError = loadstring(source)

if not loader then

    warn("[Ouroboros Translator] Compile Error:")
    warn(compileError)

    return
end

local executed, runtimeError = pcall(loader)

if not executed then

    warn("[Ouroboros Translator] Runtime Error:")
    warn(runtimeError)

    return
end

print("[Ouroboros Translator] Loaded successfully")
