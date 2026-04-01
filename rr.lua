local _ENV = getgenv()

if _ENV.Ox then return nil end
_ENV.Ox = true

local Library = {}

local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local ContentProvider = game:GetService('ContentProvider')
local TweenService = game:GetService('TweenService')
local CoreGui = game:GetService('CoreGui')

local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))() do
    Junkie.service = "test"
    Junkie.identifier = "1064541" 
    Junkie.provider = "BF"
end

local Mobile = if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then true else false

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

function Library:Parent()
    if not RunService:IsStudio() then
        return (gethui and gethui()) or CoreGui
    end

    return PlayerGui
end

function Library:Create(Class, Properties)
    local Creations = Instance.new(Class)

    for prop, value in Properties do
        Creations[prop] = value
    end

    return Creations
end

function Library:Draggable(a)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function Update(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        local Tween = TweenService:Create(a, TweenInfo.new(0.3), {Position = pos})
        Tween:Play()
    end

    a.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = a.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    a.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

function Library:Button(Parent)
    local Click = Instance.new("TextButton")

    Click.Name = "Click"
    Click.Parent = Parent
    Click.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Click.BackgroundTransparency = 1.000
    Click.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Click.BorderSizePixel = 0
    Click.Size = UDim2.new(1, 0, 1, 0)
    Click.Font = Enum.Font.SourceSans
    Click.Text = ""
    Click.TextColor3 = Color3.fromRGB(0, 0, 0)
    Click.TextSize = 14.000
    Click.ZIndex = Parent.ZIndex + 3

    return Click
end

function Library:Tween(info)
    return TweenService:Create(info.v, TweenInfo.new(info.t, Enum.EasingStyle[info.s], Enum.EasingDirection[info.d]), info.g)
end

function Library.Effect(c, p)
    p.ClipsDescendants = true

    local Mouse = LocalPlayer:GetMouse()

    local relativeX = Mouse.X - c.AbsolutePosition.X
    local relativeY = Mouse.Y - c.AbsolutePosition.Y

    if relativeX < 0 or relativeY < 0 or relativeX > c.AbsoluteSize.X or relativeY > c.AbsoluteSize.Y then
        return
    end

    local ClickButtonCircle = Instance.new("Frame")
    ClickButtonCircle.Parent = p
    ClickButtonCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ClickButtonCircle.BackgroundTransparency = 0.95
    ClickButtonCircle.BorderSizePixel = 0
    ClickButtonCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    ClickButtonCircle.Position = UDim2.new(0, relativeX, 0, relativeY)
    ClickButtonCircle.Size = UDim2.new(0, 0, 0, 0)
    ClickButtonCircle.ZIndex = p.ZIndex

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = ClickButtonCircle

    local tweenInfo = TweenInfo.new(2.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    local expandTween = TweenService:Create(ClickButtonCircle, tweenInfo, {
        Size = UDim2.new(0, c.AbsoluteSize.X * 1.5, 0, c.AbsoluteSize.X * 1.5),
        BackgroundTransparency = 1
    })

    expandTween.Completed:Connect(function()
        ClickButtonCircle:Destroy()
    end)

    expandTween:Play()
end

function Library:Asset(rbx)
    local id
    if typeof(rbx) == "number" then
        id = "rbxassetid://" .. rbx
    elseif typeof(rbx) == "string" and rbx:find("rbxassetid://") then
        id = rbx
    else
        return rbx
    end
    local ok, objs = pcall(game.GetObjects, game, id)
    if ok and objs and objs[1] then
        local inst = objs[1]
        if inst and inst:IsA("Decal") and inst.Texture and inst.Texture ~= "" then
            return inst.Texture
        end
        local d = inst and inst.FindFirstChildOfClass and inst:FindFirstChildOfClass("Decal")
        if d and d.Texture and d.Texture ~= "" then
            return d.Texture
        end
        if inst and (inst:IsA("ImageLabel") or inst:IsA("ImageButton")) and inst.Image and inst.Image ~= "" then
            return inst.Image
        end
    end
    return id
end

if not RunService:IsStudio() then
    Library.SaveKey = (function()
        local Save = {}

        local FolderName = "Xova shield"
        local FileName = FolderName .. "/key.txt"

        if not isfolder(FolderName) then
            makefolder(FolderName)
        end

        function Save:Save(key)
            if type(key) ~= "string" then
                return false
            end

            writefile(FileName, key)
            return true
        end

        function Save:Load()
            if not isfile(FileName) then
                return nil
            end

            return readfile(FileName)
        end

        function Save:Clear()
            if isfile(FileName) then
                delfile(FileName)
            end
        end

        return Save
    end)() 
end

function Library:Window(Callback)
    local Secret = Library:Create("ScreenGui", {
        Name = "Secret",
        Parent = Library:Parent(),
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        IgnoreGuiInset = true
    })

    local Background_1 = Library:Create("Frame", {
        Name = "Background",
        Parent = Secret,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(15, 17, 21),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 350, 0, 110) -- UDim2.new(0, 350, 0, 200)
    })

    Library:Create("UICorner", {
        Parent = Background_1
    })

    Library:Create("UIStroke", {
        Parent = Background_1,
        Color = Color3.fromRGB(201, 169, 110),
        Transparency = 0.5,
        Thickness = 1
    })

    Library:Create("ImageLabel", {
        Name = "Shadow",
        Parent = Background_1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 120, 1, 120),
        ZIndex = 0,
        Image = "rbxassetid://8992230677",
        ImageColor3 = Color3.fromRGB(201, 169, 110),
        ImageTransparency = 0.8,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(99, 99, 99, 99)
    })

    local Page_1 = Library:Create("Frame", {
        Name = "Page",
        Parent = Background_1,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0)
    })

    Library:Create("UIListLayout", {
        Parent = Page_1,
        Padding = UDim.new(0, 7),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    Library:Create("UIPadding", {
        Parent = Page_1,
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10)
    })

    local Banner_1 = Library:Create("ImageLabel", {
        Name = "Banner",
        Parent = Page_1,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 90),
        ClipsDescendants = true,
        Image = "rbxassetid://125411502674016",
        ImageColor3 = Color3.fromRGB(229, 192, 123)
    })

    Library:Create("UICorner", {
        Parent = Banner_1,
        CornerRadius = UDim.new(0, 5)
    })

    Library:Create("UIStroke", {
        Parent = Banner_1,
        Color = Color3.fromRGB(201, 169, 110),
        Transparency = 0.4,
        Thickness = 1
    })

    -- Library image 1361715547856541 คือไอดีรุป
    local Library_1 = Library:Create("ImageLabel", {
        Name = "Library",
        Parent = Banner_1,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0.9, 0, 0.9, 0),
        Image = Library:Asset(1361715547856541),
        ScaleType = Enum.ScaleType.Fit
    })

    Library:Create("UICorner", {
        Parent = Library_1,
        CornerRadius = UDim.new(0, 5)
    })

    local Compo_1 = Library:Create("Frame", {
        Name = "Compo",
        Parent = Banner_1,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0)
    })

    Library:Create("UIListLayout", {
        Parent = Compo_1,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center
    })

    Library:Create("UIPadding", {
        Parent = Compo_1,
        PaddingLeft = UDim.new(0, 20),
        PaddingRight = UDim.new(0, 75)
    })

    Library:Create("TextLabel", {
        Name = "Title",
        Parent = Compo_1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0.314893156, 0, 0.333333343, 0),
        Size = UDim2.new(0.629787087, 0, 0, 30),
        Font = Enum.Font.GothamBold,
        RichText = true,
        Text = "DEKTHAI",
        TextColor3 = Color3.fromRGB(229, 192, 123),
        TextSize = 28,
        TextStrokeTransparency = 0.699999988079071,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local MainText = Library:Create("TextLabel", {
        Name = "Desc",
        Parent = Compo_1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0.314893454, 0, 0.666666687, 0),
        Size = UDim2.new(0.629999995, 0, 0, 13),
        Font = Enum.Font.GothamSemibold,
        RichText = true,
        Text = "100% Undectect",
        TextColor3 = Color3.fromRGB(160, 164, 174),
        TextSize = 14,
        TextStrokeTransparency = 0.699999988079071,
        TextXAlignment = Enum.TextXAlignment.Left
    })



    local Input_1 = Library:Create("Frame", {
        Name = "Input",
        Parent = Page_1,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Visible = false
    })

    Library:Create("UIListLayout", {
        Parent = Input_1,
        Padding = UDim.new(0, 10),
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center
    })

    local Front_1 = Library:Create("Frame", {
        Name = "Front",
        Parent = Input_1,
        BackgroundColor3 = Color3.fromRGB(10, 11, 14),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, -40, 1, 0)
    })

    Library:Create("UICorner", {
        Parent = Front_1,
        CornerRadius = UDim.new(0, 2)
    })

    Library:Create("UIStroke", {
        Parent = Front_1,
        Color = Color3.fromRGB(35, 35, 35),
        Thickness = 0.5
    })

    local TextBox: TextBox = Library:Create("TextBox", {
        Parent = Front_1,
        Active = true,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Font = Enum.Font.GothamMedium,
        PlaceholderColor3 = Color3.fromRGB(55, 55, 55),
        PlaceholderText = "Paste your license key here.",
        Text = "",
        TextColor3 = Color3.fromRGB(140, 140, 140),
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText = true
    })

    local Enter_1 = Library:Create("Frame", {
        Name = "Enter",
        Parent = Input_1,
        BackgroundColor3 = Color3.fromRGB(229, 192, 123),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 30, 0, 30)
    })

    Library:Create("UICorner", {
        Parent = Enter_1,
        CornerRadius = UDim.new(0, 3)
    })

    Library:Create("UIGradient", {
        Parent = Enter_1,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(56, 56, 56))
        },
        Rotation = 90
    })

    Library:Create("ImageLabel", {
        Parent = Enter_1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 15, 0, 15),
        Image = "rbxassetid://115960025411300"
    })

    local Link_1 = Library:Create("Frame", {
        Name = "Link",
        Parent = Page_1,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 45),
        Visible = false
    })

    Library:Create("UIListLayout", {
        Parent = Link_1,
        Padding = UDim.new(0, 10),
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center
    })

    local AddLink_1 = Library:Create("Frame", {
        Name = "AddLink",
        Parent = Link_1,
        BackgroundColor3 = Color3.fromRGB(10, 11, 14),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 45)
    })

    Library:Create("UICorner", {
        Parent = AddLink_1,
        CornerRadius = UDim.new(0, 5)
    })

    Library:Create("UIStroke", {
        Parent = AddLink_1,
        Color = Color3.fromRGB(201, 169, 110),
        Transparency = 0.4,
        Thickness = 1
    })

    local Banner_2 = Library:Create("ImageLabel", {
        Name = "Banner",
        Parent = AddLink_1,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Image = "rbxassetid://125411502674016",
        ImageColor3 = Color3.fromRGB(229, 192, 123),
        ScaleType = Enum.ScaleType.Crop
    })

    Library:Create("UICorner", {
        Parent = Banner_2,
        CornerRadius = UDim.new(0, 2)
    })

    -- Info
    local Info_1 = Library:Create("Frame", {
        Name = "Info",
        Parent = AddLink_1,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0)
    })

    Library:Create("UIListLayout", {
        Parent = Info_1,
        Padding = UDim.new(0, 10),
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center
    })

    Library:Create("UIPadding", {
        Parent = Info_1,
        PaddingLeft = UDim.new(0, 15)
    })

    Library:Create("ImageLabel", {
        Name = "Icon",
        Parent = Info_1,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        LayoutOrder = -1,
        Size = UDim2.new(0, 25, 0, 25),
        Image = "rbxassetid://96551286443180",
        ImageColor3 = Color3.fromRGB(229, 192, 123)
    })

    -- Text block
    local Text_1 = Library:Create("Frame", {
        Name = "Text",
        Parent = Info_1,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0.111111209, 0, 0.144444451, 0),
        Size = UDim2.new(0, 185, 0, 32)
    })

    Library:Create("UIListLayout", {
        Parent = Text_1,
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center
    })

    Library:Create("TextLabel", {
        Name = "Title",
        Parent = Text_1,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 150, 0, 14),
        Font = Enum.Font.GothamBold,
        RichText = true,
        Text = "24 Hours",
        TextColor3 = Color3.fromRGB(229, 192, 123),
        TextSize = 15,
        TextStrokeTransparency = 0.699999988079071,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    Library:Create("TextLabel", {
        Name = "Desc",
        Parent = Text_1,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(0.899999976, 0, 0, 10),
        Font = Enum.Font.Gotham,
        RichText = true,
        Text = "3 Checkpoint and Discord Invite",
        TextColor3 = Color3.fromRGB(160, 164, 174),
        TextSize = 10,
        TextStrokeTransparency = 0.5,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local Getkey_1 = Library:Create("Frame", {
        Name = "Getkey",
        Parent = Info_1,
        BackgroundColor3 = Color3.fromRGB(229, 192, 123),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0.730158806, 0, 0.166666672, 0),
        Size = UDim2.new(0, 75, 0, 25)
    })

    Library:Create("UICorner", {
        Parent = Getkey_1,
        CornerRadius = UDim.new(0, 3)
    })

    Library:Create("UIGradient", {
        Parent = Getkey_1,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(56, 56, 56))
        },
        Rotation = 90
    })

    Library:Create("TextLabel", {
        Name = "Title",
        Parent = Getkey_1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamSemibold,
        RichText = true,
        Text = "คัดลอกลิ้ง",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 11,
        TextStrokeTransparency = 0.699999988079071
    }) 

    delay(2.5, function()
        TextBox.TextTruncate = Enum.TextTruncate.AtEnd

        local ExpandSize = Library:Tween({
            v = Background_1,
            t = 0.5,
            s = "Exponential",
            d = "Out",
            g = {
                Size = UDim2.new(0, 350, 0, 200)
            }
        })

        local function Colors(text, color)
            if type(text) == "string" and typeof(color) == "Color3" then
                local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)

                return string.format('<font color="rgb(%d, %d, %d)">%s</font>', r, g, b, text)
            end

            return text
        end

        ExpandSize.Completed:Connect(function()
            task.wait(0.1)
            Input_1.Visible = true
            task.wait(0.1)
            Link_1.Visible = true

            Library:Draggable(Background_1)

            local ClickGetkey: TextButton = Library:Button(Getkey_1)
            local Click: TextButton = Library:Button(Enter_1)

            local function ValidateAndLaunch(key)
                if not key or key == "" then
                    return
                end

                local validation = Junkie.check_key(key)

                if validation and validation.valid then
                    Library.SaveKey:Save(key)

                    Link_1.Visible = false
                    Input_1.Visible = false

                    MainText.Text = "Welcome"

                    local ExpandSize_VALID = Library:Tween({
                        v = Background_1,
                        t = 0.5,
                        s = "Exponential",
                        d = "Out",
                        g = {
                            Size = UDim2.new(0, 350, 0, 110)
                        }
                    })

                    ExpandSize_VALID.Completed:Connect(function()
                        delay(2.5, function()
                            Secret:Destroy()
                            task.wait(0.5)
                            loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/67ef9920240b097d7d45d88f7490beb8f4e6b49136eaef7805ac8710f2be0c98/download"))()
                        end)
                    end)

                    ExpandSize_VALID:Play()
                else
                    Library.SaveKey:Clear()
                    TextBox.Text = Colors("Invalid license key.", Color3.fromRGB(255, 69, 69))
                end
            end

            do
                local key = Library.SaveKey:Load()

                TextBox.Text = key or ""

                _ENV.SCRIPT_KEY = key or ""

                TextBox:GetPropertyChangedSignal("Text"):Connect(function()
                    _ENV.SCRIPT_KEY = TextBox.Text
                end)

                if key then ValidateAndLaunch(key) end

                Click.MouseButton1Click:Connect(function()
                    task.spawn(Library.Effect, Click, Enter_1)
                    ValidateAndLaunch(_ENV.SCRIPT_KEY)
                end)

                ClickGetkey.MouseButton1Click:Connect(function()
                    task.spawn(Library.Effect, ClickGetkey, Getkey_1)

                    local link = Junkie.get_key_link()

                    if link then
                        setclipboard(link)
                    end
                end)
            end
        end)

        ExpandSize:Play()
    end)
end

Library:Window()

return nil
