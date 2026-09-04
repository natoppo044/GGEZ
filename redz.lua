
local GAME_URL =
    "https://raw.githubusercontent.com/realredz999/NewRedz/main/main.lua"

--==================================================
-- TRANSLATION
--==================================================

local TRANSLATIONS = {
["Farm"] = "ฟาร์ม",
["Select Tool"] = "เลือกอุปกรณ์",
["Choose the tool you want to u"] = "เลือกอุปกรณ์ที่คุณต้องการใช้",
["UI Scale"] = "ขนาดหน้าต่าง UI",
["Adjust the user interface size"] = "ปรับขนาดของหน้าต่างอินเทอร์เฟซ",
["Farm"] = "ฟาร์ม",
["Auto Farm Level"] = "ฟาร์มเลเวลอัตโนมัติ",
["Farm Level"] = "ฟาร์มเลเวล",
["Auto Farm Nearest"] = "ฟาร์มตัวที่ใกล้ที่สุดอัตโนมัติ",
["Auto Farm Nearest Mobs"] = "ฟาร์มมอนสเตอร์ที่อยู่ใกล้ที่สุดอัตโนมัติ",
["Farm Bones"] = "ฟาร์มกระดูก",
["Check Bone"] = "เช็คจำนวนกระดูก",
["Auto Farm Bones"] = "ฟาร์มกระดูกอัตโนมัติ",
["Auto Kill Soul Reaper"] = "จัดการ Soul Reaper อัตโนมัติ",
["Auto Trade Bones"] = "สุ่มกระดูกอัตโนมัติ",
["Auto Pray"] = "อธิษฐานอัตโนมัติ",
["Auto Farm Chest [ Tween ]"] = "เก็บกล่องอัตโนมัติ [บินแบบ Tween]",
["Auto Farm Chest [ Bypass ]"] = "เก็บกล่องอัตโนมัติ [แบบ Bypassed]",
["Boss Farm"] = "ฟาร์มบอส",
["Boss Spawn Status"] = "สถานะการเกิดของบอส",
["Status: Boss Not Spawn"] = "สถานะ: บอสยังไม่เกิด",
["Boss List"] = "รายชื่อบอส",
["Auto Kill Boss Selected"] = "จัดการบอสที่เลือกอัตโนมัติ",
["Material"] = "วัตถุดิบ",
["Material List"] = "รายชื่อวัตถุดิบ",
["Auto Farm Material"] = "ฟาร์มวัตถุดิบอัตโนมัติ",
["Auto Farm Mastery"] = "ฟาร์มมาสเตอรี่อัตโนมัติ",
["Select Farm Type"] = "เลือกรูปแบบการฟาร์ม",
["Select farm mode for Mastery"] = "เลือกโหมดการฟาร์มสำหรับมาสเตอรี่",
["Select Tool"] = "เลือกอุปกรณ์",
["Choose Tool to Farm Mastery on"] = "เลือกอุปกรณ์ที่จะใช้ฟาร์มมาสเตอรี่",
["Select Skills"] = "เลือกสกิล",
["Select skills to use for farming"] = "เลือกสกิลที่จะใช้สำหรับการฟาร์ม",
["Auto Try Luck"] = "สุ่มดวงอัตโนมัติ",
["Sea Event"] = "กิจกรรมทางทะเล",
["Auto Drive Boats"] = "ขับเรืออัตโนมัติ",
["Select Boat"] = "เลือกเรือ",
["Select the boat you want to spawn and drive"] = "เลือกเรือที่คุณต้องการเสกและขับ",
["Sea Level"] = "ระดับความอันตรายของทะเล",
["Select the Sea Danger Level to roam in (Infinit to sail fully)"] = "เลือกระดับความอันตรายของทะเลที่ต้องการเดินเรือ (Infinit เพื่อแล่นเรือยาว)",
["Tween Speed"] = "ความเร็วการเคลื่อนที่ (Tween)",
["Tween Height"] = "ระดับความสูงการเคลื่อนที่ (Tween)",
["Auto Farm Sea Beast"] = "ฟาร์ม Sea Beast อัตโนมัติ",
["Auto Farm Shark"] = "ฟาร์ม Shark อัตโนมัติ",
["Auto Farm Piranha"] = "ฟาร์ม Piranha อัตโนมัติ",
["Auto Farm Fish Crew"] = "ฟาร์ม Fish Crew อัตโนมัติ",
["Auto Kill Terror Shark"] = "จัดการ Terror Shark อัตโนมัติ",
["Safe Mode"] = "โหมดปลอดภัย",
["redz hub : Blox Fruits"] = "redz hub : จ่าหมี",
["Discord"] = "ดิสคอร์ด",
["Farm"] = "ฟาร์ม",
["Quest | Items"] = "เควสต์ | ไอเทม",
["Auto Fishing"] = "ตกปลาอัตโนมัติ",
["Sea Event"] = "กิจกรรมทางทะเล",
["Race V4"] = "เผ่า V4",
["Islands"] = "เกาะต่าง ๆ",
["Raid/Fruits"] = "เรด/ผลไม้",
["Stats"] = "ค่าพลัง",
["Teleport"] = "วาร์ป",
["Status"] = "สถานะ",
["Visual"] = "ภาพและมุมมอง",
["Steal an Egg"] = "ขโมยไข่หนึ่งใบ"
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
