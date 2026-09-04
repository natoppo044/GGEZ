local GAME_URL =
    "loadstring(game:HttpGet("https://raw.githubusercontent.com/bloxfruitsnokey/Banana/refs/heads/main/Scythe/hub.luau"))()"

--==================================================
-- TRANSLATION ไอ้ควาย ของง่ายๆ ใครก็ทำได้
--==================================================

local TRANSLATIONS = {
["Farm"] = "ฟาร์ม",
["Config"] = "ตั้งค่า",
["Fighting Style"] = "สไตล์การต่อสู้",
["Items Farm"] = "ฟาร์มไอเทม",
["Sea Events"] = "กิจกรรมทางทะเล",
["Mirage + RaceV4"] = "เกาะมิราจ + เผ่า V4",
["Drago Dojo"] = "สำนักดราโกะ (Drago Dojo)",
["Prehistoric"] = "ยุคก่อนประวัติศาสตร์",
["Raid"] = "เรด",
["Combat PVP"] = "ต่อสู้ PVP",
["Auto Farm Level"] = "ฟาร์มเลเวลอัตโนมัติ",
["Auto Travel Dressrosa"] = "เดินทางไปเดรสโรซ่าอัตโนมัติ",
["Auto Zou Quest"] = "ทำเควสต์โซอัตโนมัติ",
["Miscellanea / Quest"] = "เบ็ดเตล็ด / เควสต์",
["Auto Farm Nearest"] = "ฟาร์มตัวที่ใกล้ที่สุดอัตโนมัติ",
["Auto Factory Raid"] = "ตีโรงงานอัตโนมัติ",
["Choose Material:"] = "เลือกวัตถุดิบ:",
["Auto Materials"] = "ฟาร์มวัตถุดิบอัตโนมัติ",
["Auto Farm Ectoplasm"] = "ฟาร์ม Ectoplasm อัตโนมัติ",
["Auto Done Bartilo Quest"] = "ทำเควสต์ Bartilo อัตโนมัติ",
["Auto Done Citizen Quest"] = "ทำเควสต์ Citizen อัตโนมัติ",
["Auto Training Dummy"] = "ตีหุ่นซ้อมอัตโนมัติ",
["Auto Collect Berry"] = "เก็บ Berry อัตโนมัติ",
["Miscellanea / Mastery"] = "เบ็ดเตล็ด / มาสเตอรี่",
["NPC Health % Switch to Weapon"] = "% เลือด NPC ที่ให้สลับไปใช้อาวุธ",
["NPC Aimbot (Mastery)"] = "ล็อคเป้า NPC (มาสเตอรี่)",
["Auto-aims fruit skills at the NPC during mastery farming"] = "เล็งสกิลผลไม้อัตโนมัติใส่ NPC ระหว่างฟาร์มมาสเตอรี่",
["Double Attack (Fruit M1 + Melee M1)"] = "โจมตีสองทาง (คลิกซ้ายผลไม้ + คลิกซ้ายต่อสู้ประชิด)",
["Alternates fruit M1 and melee M1 on nearest enemy"] = "สลับการโจมตีด้วยผลไม้และหมัดประชิดใส่ศัตรูที่ใกล้ที่สุด",
["Choose Island: Cake"] = "เลือกเกาะ: Cake",
["Auto Mastery Fruits"] = "ฟาร์มมาสเตอรี่ผลไม้อัตโนมัติ",
["Auto Mastery Gun"] = "ฟาร์มมาสเตอรี่ปืนอัตโนมัติ",
["Sea Event / Setting Sail"] = "กิจกรรมทางทะเล / ออกเดินเรือ",
["Spy Leviathan : 1"] = "Spy Leviathan : 1",
["Buy Fragments with Spy"] = "ซื้อแฟร็กเมนต์กับ Spy",
["Click"] = "คลิก",
["Frozen Dimension : False"] = "มิติมิรอด/มิติแช่แข็ง : เท็จ",
["Auto Teleport Frozen Dimension"] = "วาร์ปไปมิติแช่แข็งอัตโนมัติ",
["turn on for teleport to frozen dimension and start the leviathan gate"] = "เปิดเพื่อวาร์ปไปยังมิติแช่แข็งและเริ่มประตูเลเวียธาน",
["Auto Drive To Hydra Island"] = "ขับเรือไปเกาะไฮดราอัตโนมัติ",
["Volcanic Magnet"] = "แม่เหล็กภูเขาไฟ",
["Auto Craft Volcanic Magnet"] = "คราฟต์แม่เหล็กภูเขาไฟอัตโนมัติ",
["turn on for auto farm material and craft volcanic magnet & stop when you have 1 volcanic magnet"] = "เปิดเพื่อฟาร์มวัตถุดิบและคราฟต์แม่เหล็กภูเขาไฟอัตโนมัติ และจะหยุดเมื่อมีแม่เหล็กภูเขาไฟครบ 1 ชิ้น",
["Craft Volcanic Magnet"] = "คราฟต์แม่เหล็กภูเขาไฟ",
["Click"] = "คลิก",
["Initialize Attack [M1/Melee/Sword]"] = "เริ่มการโจมตี [คลิกซ้าย/หมัด/ดาบ]",
["[ Not Supported Gas M1 ]"] = "[ ไม่รองรับคลิกซ้ายของผลแก๊ส ]",
["Bring Mobs"] = "ดึงมอนสเตอร์มารวมกัน",
["Auto Turn on Buso"] = "เปิดฮาคิเกราะอัตโนมัติ",
["Auto Turn on Race V3"] = "เปิดใช้สกิลเผ่า V3 อัตโนมัติ",
["Auto Turn on Race V4"] = "เปิดใช้สกิลเผ่า V4 อัตโนมัติ",
["Auto Turn on Spin Position"] = "เปิดการหมุนตำแหน่งอัตโนมัติ",
["Generals Quests / Items"] = "เควสต์ทั่วไป / ไอเทม",
["Killed : 0"] = "สังหาร : 0",
["Bones :"] = "กระดูก :",
["Auto Cake Prince"] = "ตี Cake Prince อัตโนมัติ",
["Auto Bones"] = "ฟาร์มกระดูกอัตโนมัติ",
["Accept Quests"] = "รับเควสต์อัตโนมัติ",
["Auto ฟาร์ม Mirror"] = "ฟาร์ม Mirror อัตโนมัติ",
["Auto Soul Reaper [Fully]"] = "จัดการ Soul Reaper อัตโนมัติ [ครบวงจร]",
["Entity Sea Event"] = "ศัตรูกิจกรรมทางทะเล",
["Auto Shark"] = "จัดการ Shark อัตโนมัติ",
["Auto Piranha"] = "จัดการ Piranha อัตโนมัติ",
["Auto Terror Shark"] = "จัดการ Terror Shark อัตโนมัติ",
["Auto Fish Crew Member"] = "จัดการ Fish Crew Member อัตโนมัติ",
["Auto Haunted Crew Member"] = "จัดการ Haunted Crew Member อัตโนมัติ",
["Auto Attack PirateGrandBrigade"] = "โจมตี Pirate Grand Brigade อัตโนมัติ",
["Kitsune Island / Event"] = "เกาะคิสึเนะ / กิจกรรม",
["Auto Find Kitsune Island"] = "หาเกาะคิสึเนะอัตโนมัติ",
["turn on for finding & tween kitsune island"] = "เปิดเพื่อตามหาและบินไปที่เกาะคิสึเนะอัตโนมัติ",
["Auto Teleport to Shrine Actived"] = "วาร์ปไปศาลเจ้าที่เปิดใช้งานอัตโนมัติ",
["Auto Collect Azure Ember"] = "เก็บ Azure Ember อัตโนมัติ",
["Auto Trade Azure Ember"] = "แลก Azure Ember อัตโนมัติ",
["Mystic Island / Full Moon"] = "เกาะปริศนา / พระจันทร์เต็มดวง",
["FullMoon Status"] = "สถานะพระจันทร์เต็มดวง",
["Auto Find Mirage Island"] = "หาเกาะมิราจอัตโนมัติ",
["turn on for finding & tween mirage island"] = "เปิดเพื่อตามหาและบินไปที่เกาะมิราจอัตโนมัติ",
["Auto Tween To Highest Point"] = "บินไปจุดสูงสุดอัตโนมัติ",
["Auto Collect Gear"] = "เก็บเฟืองอัตโนมัติ",
["Change Transparency can see"] = "ปรับความโปร่งใสให้มองเห็นชัดขึ้น",
["Auto Tween Advanced Fruit Dealer"] = "บินไปหาพ่อค้าผลไม้ขั้นสูงอัตโนมัติ",
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
