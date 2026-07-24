local players = game:GetService("Players")
local coreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local localPlayer = players.LocalPlayer or players:GetPropertyChangedSignal("LocalPlayer"):Wait() or players.LocalPlayer

-- File configuration path para sa save/load
local configFileName = "IOHUB_Config.json"
local currentConfigData = {
    toggles = {},
    dropdowns = {}
}

-- Load saved config if exists
if readfile and pcall(readfile, configFileName) then
    local success, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(configFileName))
    end)
    if success and decoded then
        currentConfigData = decoded
    end
end

local function saveConfigToFile()
    if writefile then
        pcall(function()
            writefile(configFileName, HttpService:JSONEncode(currentConfigData))
        end)
    end
end

-- Main ScreenGui setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UniversalMenuGui_Delta"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if gethui then
    screenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(screenGui)
    screenGui.Parent = coreGui
else
    screenGui.Parent = coreGui
end

----------------------------------------------------
-- NOTIFICATION SYSTEM
----------------------------------------------------
local function showNotification(message)
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 220, 0, 40)
    notifFrame.Position = UDim2.new(1, -235, 1, -60)
    notifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notifFrame.BackgroundTransparency = 0.2
    notifFrame.BorderSizePixel = 0
    notifFrame.ZIndex = 999
    notifFrame.Parent = screenGui

    local nCorner = Instance.new("UICorner")
    nCorner.CornerRadius = UDim.new(0, 8)
    nCorner.Parent = notifFrame

    local nStroke = Instance.new("UIStroke")
    nStroke.Color = Color3.fromRGB(150, 30, 50)
    nStroke.Thickness = 1
    nStroke.Parent = notifFrame

    local nText = Instance.new("TextLabel")
    nText.Size = UDim2.new(1, 0, 1, 0)
    nText.BackgroundTransparency = 1
    nText.Text = message
    nText.TextColor3 = Color3.fromRGB(255, 255, 255)
    nText.Font = Enum.Font.GothamBold
    nText.TextSize = 11
    nText.ZIndex = 1000
    nText.Parent = notifFrame

    task.delay(2, function()
        local tw = TweenService:Create(notifFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1})
        tw:Play()
        TweenService:Create(nText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        tw.Completed:Connect(function()
            notifFrame:Destroy()
        end)
    end)
end

----------------------------------------------------
-- MAIN CONTAINER WINDOW
----------------------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 580, 0, 420)
mainFrame.Position = UDim2.new(0.5, -290, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Visible = false 
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

----------------------------------------------------
-- FLOATING TOGGLE IMAGE BUTTON
----------------------------------------------------
local toggleButton = Instance.new("ImageButton")
toggleButton.Name = "MenuToggleButton"
toggleButton.Size = UDim2.new(0, 55, 0, 55)
toggleButton.Position = UDim2.new(0, 20, 0.5, -27) 
toggleButton.BackgroundTransparency = 1
toggleButton.Image = "rbxassetid://139934599708171" 
toggleButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Active = true
toggleButton.Parent = screenGui

----------------------------------------------------
-- DRAGGING FEATURE
----------------------------------------------------
local userInputService = game:GetService("UserInputService")

local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    userInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

makeDraggable(mainFrame)
makeDraggable(toggleButton)

----------------------------------------------------
-- TOGGLE LOGIC
----------------------------------------------------
local uiTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local isMenuOpen = false 
local isTweening = false 

local function minimizeToButton()
    if isTweening then return end
    isTweening = true
    
    local closeTween = TweenService:Create(mainFrame, uiTweenInfo, {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    closeTween:Play()
    closeTween.Completed:Connect(function()
        mainFrame.Visible = false
        isMenuOpen = false
        isTweening = false
    end)
end

local function openMenu()
    if isTweening then return end
    isTweening = true
    
    mainFrame.Visible = true
    mainFrame.Size = UDim2.new(0, 0, 0, 0) 
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local openTween = TweenService:Create(mainFrame, uiTweenInfo, {
        Size = UDim2.new(0, 580, 0, 420),
        Position = UDim2.new(0.5, -290, 0.5, -210)
    })
    openTween:Play()
    openTween.Completed:Connect(function()
        isMenuOpen = true
        isTweening = false
    end)
end

toggleButton.MouseButton1Click:Connect(function()
    if isMenuOpen then minimizeToButton() else openMenu() end
end)

----------------------------------------------------
-- TOP WINDOW CONTROL DOTS & TITLE
----------------------------------------------------
local controlsFrame = Instance.new("Frame")
controlsFrame.Name = "Controls"
controlsFrame.Size = UDim2.new(0, 60, 0, 20)
controlsFrame.Position = UDim2.new(1, -75, 0, 15)
controlsFrame.BackgroundTransparency = 1
controlsFrame.Parent = mainFrame

local colors = {Color3.fromRGB(255, 95, 87), Color3.fromRGB(254, 188, 46), Color3.fromRGB(40, 200, 64)}
for i, color in ipairs(colors) do
    local dot = Instance.new("TextButton")
    dot.Name = "ControlDot" .. i
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(0, (i - 1) * 20, 0, 4)
    dot.BackgroundColor3 = color
    dot.BorderSizePixel = 0
    dot.Text = ""
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
    dot.Parent = controlsFrame
    dot.MouseButton1Click:Connect(minimizeToButton)
end

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "IOHUB"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.Parent = mainFrame

local logo = Instance.new("ImageLabel")
logo.Name = "Logo"
logo.Size = UDim2.new(0, 24, 0, 24)
logo.Position = UDim2.new(0, 15, 0, 12)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://10840244199" 
logo.ImageColor3 = Color3.fromRGB(255, 30, 30)
logo.Parent = mainFrame

----------------------------------------------------
-- NAVIGATION & PAGES SETUP
----------------------------------------------------
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 160, 1, -60)
sidebar.Position = UDim2.new(0, 10, 0, 50)
sidebar.BackgroundTransparency = 1
sidebar.Parent = mainFrame

local uiListSide = Instance.new("UIListLayout")
uiListSide.Padding = UDim.new(0, 8)
uiListSide.SortOrder = Enum.SortOrder.LayoutOrder
uiListSide.Parent = sidebar

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -195, 1, -55)
contentFrame.Position = UDim2.new(0, 180, 0, 40)
contentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
contentFrame.BackgroundTransparency = 0.4
contentFrame.Parent = mainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 12)
contentCorner.Parent = contentFrame

local tabs = {}
local pages = {}
local activeTab = nil

local function createPageContainer()
    local scrollPage = Instance.new("ScrollingFrame")
    scrollPage.Size = UDim2.new(1, -10, 1, -15)
    scrollPage.Position = UDim2.new(0, 5, 0, 10)
    scrollPage.BackgroundTransparency = 1
    scrollPage.BorderSizePixel = 0
    scrollPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollPage.ScrollBarThickness = 2
    scrollPage.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    scrollPage.Visible = false
    scrollPage.Parent = contentFrame

    local uiListContent = Instance.new("UIListLayout")
    uiListContent.Padding = UDim.new(0, 10)
    uiListContent.SortOrder = Enum.SortOrder.LayoutOrder
    uiListContent.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiListContent.Parent = scrollPage
    
    uiListContent:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollPage.CanvasSize = UDim2.new(0, 0, 0, uiListContent.AbsoluteContentSize.Y + 20)
    end)

    return scrollPage
end

local function switchTab(tabName)
    for name, btnElements in pairs(tabs) do
        if name == tabName then
            btnElements.Button.BackgroundTransparency = 0.9
            btnElements.Icon.ImageColor3 = Color3.fromRGB(255, 100, 120)
            btnElements.Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            if btnElements.Stroke then btnElements.Stroke.Enabled = true end
            pages[name].Visible = true
        else
            btnElements.Button.BackgroundTransparency = 1
            btnElements.Icon.ImageColor3 = Color3.fromRGB(180, 180, 180)
            btnElements.Label.TextColor3 = Color3.fromRGB(180, 180, 180)
            if btnElements.Stroke then btnElements.Stroke.Enabled = false end
            pages[name].Visible = false
        end
    end
    activeTab = tabName
end

local function createSidebarTab(name, iconId, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundTransparency = 1
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = ""
    btn.LayoutOrder = order
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(150, 20, 40)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Enabled = false
    stroke.Parent = btn
    
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 16, 0, 16)
    icon.Position = UDim2.new(0, 12, 0.5, -8)
    icon.BackgroundTransparency = 1
    icon.Image = iconId
    icon.ImageColor3 = Color3.fromRGB(180, 180, 180)
    icon.Parent = btn
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -40, 1, 0)
    lbl.Position = UDim2.new(0, 36, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn
    
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    btn.Parent = sidebar
    
    tabs[name] = {Button = btn, Icon = icon, Label = lbl, Stroke = stroke}
    pages[name] = createPageContainer()
end

----------------------------------------------------
-- MAIN DROPDOWN SECTION
----------------------------------------------------
local function createDropdownSection(pageName, sectionTitle)
    local targetPage = pages[pageName]
    if not targetPage then return end

    local isOpen = false 
    
    local dropContainer = Instance.new("Frame")
    dropContainer.Size = UDim2.new(0.92, 0, 0, 40)
    dropContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    dropContainer.BackgroundTransparency = 0.5
    dropContainer.ClipsDescendants = true
    dropContainer.Parent = targetPage

    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 8)
    dropCorner.Parent = dropContainer

    local headerBtn = Instance.new("TextButton")
    headerBtn.Size = UDim2.new(1, 0, 0, 40)
    headerBtn.BackgroundTransparency = 1
    headerBtn.Text = ""
    headerBtn.Parent = dropContainer

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -40, 1, 0)
    titleLbl.Position = UDim2.new(0, 15, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = sectionTitle
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 20
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = headerBtn

    local arrowIcon = Instance.new("ImageLabel")
    arrowIcon.Size = UDim2.new(0, 16, 0, 16)
    arrowIcon.Position = UDim2.new(1, -28, 0.5, -8)
    arrowIcon.BackgroundTransparency = 1
    arrowIcon.Image = "rbxassetid://10709791437"
    arrowIcon.Rotation = 90
    arrowIcon.ImageColor3 = Color3.fromRGB(200, 200, 200)
    arrowIcon.Parent = headerBtn

    local itemsHolder = Instance.new("Frame")
    itemsHolder.Size = UDim2.new(1, 0, 0, 0)
    itemsHolder.Position = UDim2.new(0, 0, 0, 40)
    itemsHolder.BackgroundTransparency = 1
    itemsHolder.Parent = dropContainer

    local itemsList = Instance.new("UIListLayout")
    itemsList.Padding = UDim.new(0, 8)
    itemsList.SortOrder = Enum.SortOrder.LayoutOrder
    itemsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    itemsList.Parent = itemsHolder

    itemsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if isOpen then
            dropContainer.Size = UDim2.new(0.92, 0, 0, itemsList.AbsoluteContentSize.Y + 50)
            itemsHolder.Size = UDim2.new(1, 0, 0, itemsList.AbsoluteContentSize.Y + 10)
        end
    end)

    headerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        if isOpen then
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 270}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.92, 0, 0, itemsList.AbsoluteContentSize.Y + 50)}):Play()
        else
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 90}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.92, 0, 0, 40)}):Play()
        end
    end)

    return itemsHolder
end

----------------------------------------------------
-- NESTED DROPDOWN SECTION
----------------------------------------------------
local function createNestedDropdownSection(parentContainer, sectionTitle)
    local isOpen = false
    
    local dropContainer = Instance.new("Frame")
    dropContainer.Size = UDim2.new(0.95, 0, 0, 36)
    dropContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    dropContainer.BackgroundTransparency = 0.5
    dropContainer.ClipsDescendants = true
    dropContainer.Parent = parentContainer

    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 6)
    dropCorner.Parent = dropContainer

    local headerBtn = Instance.new("TextButton")
    headerBtn.Size = UDim2.new(1, 0, 0, 36)
    headerBtn.BackgroundTransparency = 1
    headerBtn.Text = ""
    headerBtn.Parent = dropContainer

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -35, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = sectionTitle
    titleLbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 11
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = headerBtn

    local arrowIcon = Instance.new("ImageLabel")
    arrowIcon.Size = UDim2.new(0, 14, 0, 14)
    arrowIcon.Position = UDim2.new(1, -24, 0.5, -7)
    arrowIcon.BackgroundTransparency = 1
    arrowIcon.Image = "rbxassetid://10709791437"
    arrowIcon.Rotation = 90
    arrowIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
    arrowIcon.Parent = headerBtn

    local itemsHolder = Instance.new("Frame")
    itemsHolder.Size = UDim2.new(1, 0, 0, 0)
    itemsHolder.Position = UDim2.new(0, 0, 0, 36)
    itemsHolder.BackgroundTransparency = 1
    itemsHolder.Parent = dropContainer

    local itemsList = Instance.new("UIListLayout")
    itemsList.Padding = UDim.new(0, 6)
    itemsList.SortOrder = Enum.SortOrder.LayoutOrder
    itemsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    itemsList.Parent = itemsHolder

    itemsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if isOpen then
            dropContainer.Size = UDim2.new(0.95, 0, 0, itemsList.AbsoluteContentSize.Y + 45)
            itemsHolder.Size = UDim2.new(1, 0, 0, itemsList.AbsoluteContentSize.Y + 10)
        end
    end)

    headerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        if isOpen then
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 270}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.95, 0, 0, itemsList.AbsoluteContentSize.Y + 45)}):Play()
        else
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 90}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.95, 0, 0, 36)}):Play()
        end
    end)

    return itemsHolder
end

----------------------------------------------------
-- BUTTON CREATOR (Para sa Action Buttons tulad ng Save)
----------------------------------------------------
local function createButton(parentContainer, title, description, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(0.95, 0, 0, 42)
    row.BackgroundTransparency = 1
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.6, 0, 0, 16)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 11
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = row
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.6, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 0, 0, 16)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.Parent = row
    
    local actionBtn = Instance.new("TextButton")
    actionBtn.Size = UDim2.new(0, 100, 0, 26)
    actionBtn.Position = UDim2.new(1, -100, 0.5, -13)
    actionBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 50)
    actionBtn.BackgroundTransparency = 0.2
    actionBtn.Text = "Save"
    actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    actionBtn.Font = Enum.Font.GothamBold
    actionBtn.TextSize = 11
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = actionBtn
    
    actionBtn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    actionBtn.Parent = row
    row.Parent = parentContainer
end

----------------------------------------------------
-- MULTI-SELECT DROPDOWN SELECTOR
----------------------------------------------------
local function createDropdownSelect(parentContainer, title, itemsListTable, callback)
    local isOpen = false
    
    if not currentConfigData.dropdowns[title] then
        currentConfigData.dropdowns[title] = {}
    end
    local selectedItems = currentConfigData.dropdowns[title]
    local allSelected = false
    
    local dropContainer = Instance.new("Frame")
    dropContainer.Size = UDim2.new(0.95, 0, 0, 36)
    dropContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    dropContainer.BackgroundTransparency = 0.5
    dropContainer.ClipsDescendants = true
    dropContainer.Parent = parentContainer

    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 6)
    dropCorner.Parent = dropContainer

    local headerBtn = Instance.new("TextButton")
    headerBtn.Size = UDim2.new(1, 0, 0, 36)
    headerBtn.BackgroundTransparency = 1
    headerBtn.Text = ""
    headerBtn.Parent = dropContainer

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.5, 0, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 11
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = headerBtn

    local selectedLbl = Instance.new("TextLabel")
    selectedLbl.Size = UDim2.new(0.4, 0, 1, 0)
    selectedLbl.Position = UDim2.new(0.55, -20, 0, 0)
    selectedLbl.BackgroundTransparency = 1
    selectedLbl.Text = "None selected"
    selectedLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    selectedLbl.Font = Enum.Font.Gotham
    selectedLbl.TextSize = 10
    selectedLbl.TextXAlignment = Enum.TextXAlignment.Right
    selectedLbl.Parent = headerBtn

    local arrowIcon = Instance.new("ImageLabel")
    arrowIcon.Size = UDim2.new(0, 14, 0, 14)
    arrowIcon.Position = UDim2.new(1, -24, 0.5, -7)
    arrowIcon.BackgroundTransparency = 1
    arrowIcon.Image = "rbxassetid://10709791437"
    arrowIcon.Rotation = 90
    arrowIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
    arrowIcon.Parent = headerBtn

    local contentHolder = Instance.new("Frame")
    contentHolder.Size = UDim2.new(1, 0, 0, 0)
    contentHolder.Position = UDim2.new(0, 0, 0, 36)
    contentHolder.BackgroundTransparency = 1
    contentHolder.Parent = dropContainer

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent = contentHolder

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(0.92, 0, 0, 28)
    searchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    searchBox.Text = ""
    searchBox.PlaceholderText = "Search 🔎"
    searchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 11
    searchBox.ClearTextOnFocus = false
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 4)
    searchCorner.Parent = searchBox
    searchBox.Parent = contentHolder

    local scrollOptions = Instance.new("ScrollingFrame")
    scrollOptions.Size = UDim2.new(0.92, 0, 0, 90)
    scrollOptions.BackgroundTransparency = 1
    scrollOptions.BorderSizePixel = 0
    scrollOptions.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollOptions.ScrollBarThickness = 2
    scrollOptions.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    scrollOptions.Parent = contentHolder

    local optList = Instance.new("UIListLayout")
    optList.Padding = UDim.new(0, 4)
    optList.SortOrder = Enum.SortOrder.LayoutOrder
    optList.Parent = scrollOptions

    local optionButtons = {}
    local allBtn = nil

    local function updateSelectedLabel()
        local count = 0
        local names = {}
        for item, isSel in pairs(selectedItems) do
            if isSel then
                count = count + 1
                table.insert(names, item)
            end
        end
        if count == 0 then
            selectedLbl.Text = "None selected"
        elseif count == #itemsListTable then
            selectedLbl.Text = "All selected"
        else
            selectedLbl.Text = table.concat(names, ", ")
        end
    end

    local function updateAllButtonState()
        if not allBtn then return end
        local allCurrentlySelected = true
        for _, itemText in ipairs(itemsListTable) do
            if not selectedItems[itemText] then
                allCurrentlySelected = false
                break
            end
        end
        allSelected = allCurrentlySelected
        
        allBtn.BackgroundColor3 = allSelected and Color3.fromRGB(150, 30, 50) or Color3.fromRGB(35, 35, 35)
        allBtn.BackgroundTransparency = allSelected and 0.2 or 0.5
        allBtn.TextColor3 = allSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        allBtn.Font = allSelected and Enum.Font.GothamBold or Enum.Font.Gotham
    end

    local function populateOptions(filter)
        for _, btn in pairs(optionButtons) do btn:Destroy() end
        optionButtons = {}
        if allBtn then allBtn:Destroy() allBtn = nil end

        if not filter or filter == "" or string.find(string.lower("All"), string.lower(filter)) then
            allBtn = Instance.new("TextButton")
            allBtn.Size = UDim2.new(1, 0, 0, 26)
            allBtn.BackgroundColor3 = allSelected and Color3.fromRGB(150, 30, 50) or Color3.fromRGB(35, 35, 35)
            allBtn.BackgroundTransparency = allSelected and 0.2 or 0.5
            allBtn.Text = "  All"
            allBtn.TextColor3 = allSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
            allBtn.Font = allSelected and Enum.Font.GothamBold or Enum.Font.Gotham
            allBtn.TextSize = 11
            allBtn.TextXAlignment = Enum.TextXAlignment.Left

            local allCorner = Instance.new("UICorner")
            allCorner.CornerRadius = UDim.new(0, 4)
            allCorner.Parent = allBtn

            allBtn.MouseButton1Click:Connect(function()
                allSelected = not allSelected
                for _, itemText in ipairs(itemsListTable) do
                    selectedItems[itemText] = allSelected
                end
                updateAllButtonState()
                for _, btnData in pairs(optionButtons) do
                    local isSel = selectedItems[btnData.ItemName] == true
                    btnData.Button.BackgroundColor3 = isSel and Color3.fromRGB(150, 30, 50) or Color3.fromRGB(35, 35, 35)
                    btnData.Button.BackgroundTransparency = isSel and 0.2 or 0.5
                    btnData.Button.TextColor3 = isSel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
                    btnData.Button.Font = isSel and Enum.Font.GothamBold or Enum.Font.Gotham
                end
                updateSelectedLabel()
                if callback then callback(selectedItems) end
            end)

            allBtn.Parent = scrollOptions
        end

        for _, itemText in ipairs(itemsListTable) do
            if not filter or filter == "" or string.find(string.lower(itemText), string.lower(filter)) then
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 26)
                
                local isSelected = selectedItems[itemText] == true
                optBtn.BackgroundColor3 = isSelected and Color3.fromRGB(150, 30, 50) or Color3.fromRGB(35, 35, 35)
                optBtn.BackgroundTransparency = isSelected and 0.2 or 0.5
                
                optBtn.Text = "  " .. itemText
                optBtn.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
                optBtn.Font = isSelected and Enum.Font.GothamBold or Enum.Font.Gotham
                optBtn.TextSize = 11
                optBtn.TextXAlignment = Enum.TextXAlignment.Left

                local optCorner = Instance.new("UICorner")
                optCorner.CornerRadius = UDim.new(0, 4)
                optCorner.Parent = optBtn

                optBtn.MouseButton1Click:Connect(function()
                    selectedItems[itemText] = not selectedItems[itemText]
                    
                    local nowSelected = selectedItems[itemText]
                    optBtn.BackgroundColor3 = nowSelected and Color3.fromRGB(150, 30, 50) or Color3.fromRGB(35, 35, 35)
                    optBtn.BackgroundTransparency = nowSelected and 0.2 or 0.5
                    optBtn.TextColor3 = nowSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
                    optBtn.Font = nowSelected and Enum.Font.GothamBold or Enum.Font.Gotham

                    updateAllButtonState()
                    updateSelectedLabel()
                    if callback then callback(selectedItems) end
                end)

                optBtn.Parent = scrollOptions
                table.insert(optionButtons, {Button = optBtn, ItemName = itemText})
            end
        end
        updateAllButtonState()
        scrollOptions.CanvasSize = UDim2.new(0, 0, 0, optList.AbsoluteContentSize.Y + 10)
    end

    populateOptions("")
    updateSelectedLabel()
    if callback then callback(selectedItems) end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        populateOptions(searchBox.Text)
    end)

    optList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollOptions.CanvasSize = UDim2.new(0, 0, 0, optList.AbsoluteContentSize.Y + 10)
    end)

    contentHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if isOpen then
            dropContainer.Size = UDim2.new(0.95, 0, 0, listLayout.AbsoluteContentSize.Y + 45)
        end
    end)

    headerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local totalHeight = listLayout.AbsoluteContentSize.Y + 45
        
        if isOpen then
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 270}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.95, 0, 0, totalHeight)}):Play()
        else
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 90}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.95, 0, 0, 36)}):Play()
        end
    end)

    return dropContainer
end

----------------------------------------------------
-- TOGGLE CREATOR
----------------------------------------------------
local function createToggle(parentContainer, title, description, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(0.95, 0, 0, 42)
    row.BackgroundTransparency = 1
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.7, 0, 0, 16)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 11
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = row
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.75, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 0, 0, 16)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.Parent = row
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 36, 0, 18)
    toggleBtn.Position = UDim2.new(1, -34, 0.5, -9)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggleBtn.Text = ""
    
    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(1, 0)
    tCorner.Parent = toggleBtn
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 12, 0, 12)
    indicator.Position = UDim2.new(0, 3, 0.5, -6)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    
    local iCorner = Instance.new("UICorner")
    iCorner.CornerRadius = UDim.new(1, 0)
    iCorner.Parent = indicator
    indicator.Parent = toggleBtn
    
    local enabled = currentConfigData.toggles[title] == true
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    local function applyState(state, immediate)
        enabled = state
        currentConfigData.toggles[title] = enabled
        if immediate then
            if enabled then
                toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                indicator.Position = UDim2.new(1, -15, 0.5, -6)
                indicator.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            else
                toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                indicator.Position = UDim2.new(0, 3, 0.5, -6)
                indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            end
        else
            if enabled then
                TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                TweenService:Create(indicator, tweenInfo, {Position = UDim2.new(1, -15, 0.5, -6), BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            else
                TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
                TweenService:Create(indicator, tweenInfo, {Position = UDim2.new(0, 3, 0.5, -6), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            end
        end
        if callback then callback(enabled) end
    end

    applyState(enabled, true)
    
    toggleBtn.MouseButton1Click:Connect(function()
        applyState(not enabled, false)
    end)
    
    toggleBtn.Parent = row
    row.Parent = parentContainer
end

----------------------------------------------------
-- POPULATING TABS & CONTENT
----------------------------------------------------
createSidebarTab("Main", "rbxassetid://10822165440", 1)
createSidebarTab("Automatically", "rbxassetid://10723345479", 2)
createSidebarTab("Core Settings", "rbxassetid://10734951111", 3)

-- 1. Welcome Tab Content
local welcomeGroup = createDropdownSection("Main", "General Greeting")
createToggle(welcomeGroup, "Show Intro", "Display welcome greetings on configuration execution.", function(state)
    print("Welcome Intro Set:", state)
end)

-- 2. Client Tab Content
local collectFruit = createDropdownSection("Automatically", "Auto Collect")
local sellFruit = createDropdownSection("Automatically", "Auto Sell")
local autoCollectFruit = createNestedDropdownSection(collectFruit, "Auto Collect Fruit")
local autoSellFruit = createNestedDropdownSection(sellFruit, "Auto Sell Fruit")

local fruitsList = {"Apple", "Mango", "Banana", "Pineapple", "Watermelon", "Dragonfruit", "Cherry", "Strawberry"}
createDropdownSelect(autoSellFruit, "Select Fruit", fruitsList, function(selectedTable)
    print("Mga Napiling Prutas:")
    for fruit, active in pairs(selectedTable) do
        if active then
            print("- " .. fruit)
        end
    end
end)

createToggle(autoSellFruit, "Turn on Auto Sell", "Automatically sell the selected fruits.", function(state)
    print("Auto Sell toggled:", state)
end)


local fruitsList = {"Apple", "Mango", "Banana", "Pineapple", "Watermelon", "Dragonfruit", "Cherry", "Strawberry"}
createDropdownSelect(autoCollectFruit, "Select Fruit", fruitsList, function(selectedTable)
    print("Mga Napiling Prutas:")
    for fruit, active in pairs(selectedTable) do
        if active then
            print("- " .. fruit)
        end
    end
end)

createToggle(autoCollectFruit, "Turn on Auto Sell", "Automatically sell the selected fruits.", function(state)
    print("Auto Sell toggled:", state)
end)



-- 3. Core Settings Tab Content (Dito na nakalagay ang Save Config button sa loob ng Core Settings)
local coreGroup = createDropdownSection("Core Settings", "Configuration")

createButton(coreGroup, "Save Config/Json", "Manually save current settings to file.", function()
    saveConfigToFile()
    showNotification("Configuration successfully saved manually!")
end)


-- Default open tab
switchTab("Main")
