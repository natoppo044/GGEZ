

local GAME_URL =
    "https://raw.githubusercontent.com/JaxRol/ZeroPoint/refs/heads/main/KeySystem"

--==================================================
-- TRANSLATION
--==================================================

local TRANSLATIONS = {

["Auto Egg"] = "เก็บไข่อัตโนมัติ",
["Egg filters, target override and collection controls"] = "ตัวกรองไข่ การเจาะจงเป้าหมาย ",
["Auto Egg Filters"] = "ตัวกรองเก็บไข่อัตโนมัติ",
["Egg Target overrides Animal, Rarity, and Mutation filters when selected. The Money / Second filter remains active so you can require a specific earning range even for a chosen pet type."] = "ก่อนขโมยไข่! ต้องเลือกชื่อและระดับความยากของไข่ก่อน /วินาที จะยังคงทำงานเพื่อกำหนดช่วงรายได้ของสัตว์เลี้ยงที่ต้องการ",
["Egg Target"] = "เป้าหมายไข่",
["None"] = "ไม่ระบุ",
["Animal Names"] = "ชื่อสัตว์",
["Egg Rarities"] = "ระดับความหายากของไข่",
["Egg Mutations"] = "มิวเทชันของไข่",
["Money / Second Filter"] = "ตัวกรองเงิน / วินาที",
["Minimum Money / Second"] = "เงินขั้นต่ำ / วินาที",
["Maximum Money / Second"] = "เงินสูงสุด / วินาที",
["Auto Egg Control"] = "การควบคุมเก็บไข่อัตโนมัติ",
["Status: Going to Jerboa [Common] | $6/s - Desert"] = "สถานะ: กำลังไปที่ Jerboa [ทั่วไป] | $6/วิ - ทะเลทราย",
["Auto Go To Egg"] = "เริ่มขโมยไข่อัตโนมัติ",
["Custom Tween Speed"] = "ปรับแต่งความเร็วการเคลื่อนที่ (Tween)",
["Tween Speed"] = "ความเร็วการเคลื่อนที่ (Tween)",
["Auto Egg Server Hop"] = "ย้ายเซิร์ฟเวอร์เก็บไข่อัตโนมัติ",
["Status: Matching egg found - collecting"] = "สถานะ: พบไข่ที่ตรงกัน - กำลังเก็บ",
["Server Hop For Auto Egg"] = "ย้ายเซิร์ฟเวอร์สำหรับเก็บไข่อัตโนมัติ",
["Locations"] = "สถานที่",
["Base"] = "ฐาน",
["Spawn"] = "จุดเกิด",
["Fuse Machine"] = "ตู้ผสมไอเทม",
["Egg Seller"] = "คนขายไข่",
["Traveling Merchant"] = "พ่อค้าพเนจร",
["Treadmill"] = "ลู่วิ่ง",
["Areas"] = "พื้นที่",
["Selected Area"] = "พื้นที่ที่เลือก",
["Forest"] = "ป่า",
["Return / Status"] = "ย้อนกลับ / สถานะ",
["Return to Previous Position"] = "กลับไปยังตำแหน่งก่อนหน้า",
["Status: Ready"] = "สถานะ: พร้อมใช้งาน",
["Shops"] = "ร้านค้า",
["Selected Shop"] = "ร้านค้าที่เลือก",
["Gear Shop"] = "ร้านขายอุปกรณ์",
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
