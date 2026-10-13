-- Put this code in a LocalScript INSIDE StarterGui > AppleLibraryGui.
-- Run AppleUI_Build_Editable.lua once in the Studio Command Bar first.
-- All UI instances are ordinary editable Studio objects; no external library required.

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local gui = script.Parent
local main = gui:FindFirstChild("main")
assert(main and main:IsA("Frame"),
	"AppleLibraryGui is missing main. Run AppleUI_Build_Editable.lua " ..
		"in Studio Command Bar (Edit mode), then add this LocalScript.")
local sidebar = main:WaitForChild("sidebar")
local workarea = main:WaitForChild("workarea")
local trafficLights = main:WaitForChild("buttons")

local tabA = sidebar:WaitForChild("ElementsTab")
local tabB = sidebar:WaitForChild("NotificationsTab")
local pageA = workarea:WaitForChild("ElementsPage")
local pageB = workarea:WaitForChild("NotificationsPage")
local notif1 = main:WaitForChild("notif")
local notif2 = main:WaitForChild("notif2")

-- Section selection; UI layout/colors can be edited independently in Studio.
local function selectPage(selectedTab, selectedPage)
	for _, tab in ipairs({tabA, tabB}) do
		tab.BackgroundTransparency = 1
		tab.TextColor3 = Color3.fromRGB(0, 0, 0)
	end
	pageA.Visible = false
	pageB.Visible = false
	selectedTab.BackgroundTransparency = 0
	selectedTab.TextColor3 = Color3.fromRGB(255, 255, 255)
	selectedPage.Visible = true
end

tabA.Activated:Connect(function() selectPage(tabA, pageA) end)
tabB.Activated:Connect(function() selectPage(tabB, pageB) end)
selectPage(tabA, pageA)

-- Search sidebar sections by their displayed text.
local search = main:WaitForChild("search")
local searchBox = search:WaitForChild("searchtextbox")
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local term = searchBox.Text:lower()
	for _, tab in ipairs({tabA, tabB}) do
		tab.Visible = term == "" or tab.Text:lower():find(term, 1, true) ~= nil
	end
end)
search:WaitForChild("searchicon").Activated:Connect(function()
	searchBox:CaptureFocus()
end)

-- Original example: Click me!
pageA:WaitForChild("ClickMeButton").Activated:Connect(function()
	print("Button clicked.")
end)

-- Original example: switch.
local switch = pageA:WaitForChild("toggleswitch")
local track = switch:FindFirstChildWhichIsA("TextButton")
assert(track, "Missing switch track")
local knob = track:FindFirstChildWhichIsA("TextButton")
assert(knob, "Missing switch knob")
local switchOn = knob.Position.X.Offset >= 30

local function toggleSwitch()
	switchOn = not switchOn
	track.BackgroundColor3 = switchOn
		and Color3.fromRGB(21, 103, 251)
		or Color3.fromRGB(216, 216, 216)
	TweenService:Create(knob, TweenInfo.new(0.12), {
		Position = switchOn
			and UDim2.fromOffset(35, 1)
			or UDim2.fromOffset(1, 1)
	}):Play()
	print(switchOn)
end
track.Activated:Connect(toggleSwitch)
knob.Activated:Connect(toggleSwitch)

-- Original example: text field.
local textField = pageA:WaitForChild("textfield")
local input = textField:FindFirstChildWhichIsA("TextBox", true)
assert(input, "Missing editable text field")
input.FocusLost:Connect(function()
	print(input.Text)
end)

-- Notification buttons and dialogs.
pageB:WaitForChild("Notification1Button").Activated:Connect(function()
	if notif1.Visible or notif2.Visible then return end
	notif1.notiftitle.Text = "Hello!"
	notif1.notiftext.Text = "I am notification"
	notif1.notificon.Image = "rbxassetid://12608259004"
	notif1.notifbutton1.Text = "Button1"
	notif1.Visible = true
end)
notif1.notifbutton1.Activated:Connect(function()
	print(1)
	notif1.Visible = false
end)

pageB:WaitForChild("Notification2Button").Activated:Connect(function()
	if notif1.Visible or notif2.Visible then return end
	notif2.notif2title.Text = "Hello!"
	notif2.notif2text.Text = "I am notification"
	notif2.notif2icon.Image = "rbxassetid://12608259004"
	notif2.notif2button1.Text = "Button 1"
	notif2.notif2button2.Text = "Button 2"
	notif2.Visible = true
end)
notif2.notif2button1.Activated:Connect(function()
	print(1)
	notif2.Visible = false
end)
notif2.notif2button2.Activated:Connect(function()
	print(2)
	notif2.Visible = false
end)

-- Temporary notification uses an editable template in StarterGui.
local toastTemplate = gui:WaitForChild("TempNotificationTemplate")
pageB:WaitForChild("TempNotificationButton").Activated:Connect(function()
	local toast = toastTemplate:Clone()
	toast.Name = "ActiveTempNotification"
	toast.t1.Text = "Be careful!"
	toast.t2.Text = "We are going to beat you up."
	toast.ticon.Image = "rbxassetid://12608259004"
	toast.Parent = gui
	toast.Visible = true
	Debris:AddItem(toast, 5)
end)

-- Window traffic-light buttons. RightShift reopens it after closing/minimizing.
trafficLights.close.Activated:Connect(function()
	gui.Enabled = false
end)
trafficLights.minimize.Activated:Connect(function()
	main.Visible = false
end)
trafficLights.resize.Activated:Connect(function()
	print("You clicked the green button!")
end)
UserInputService.InputBegan:Connect(function(key, processed)
	if processed or key.KeyCode ~= Enum.KeyCode.RightShift then return end
	if not gui.Enabled or not main.Visible then
		gui.Enabled = true
		main.Visible = true
	else
		main.Visible = false
	end
end)

-- Drag the window with its title text (rather than grabbing input fields).
local dragging = false
local dragStart, startingPosition
local title = main:WaitForChild("title")
title.Active = true

title.InputBegan:Connect(function(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.MouseButton1
		or inputObject.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = inputObject.Position
		startingPosition = main.Position
		inputObject.Changed:Connect(function()
			if inputObject.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)
UserInputService.InputChanged:Connect(function(inputObject)
	if not dragging then return end
	if inputObject.UserInputType ~= Enum.UserInputType.MouseMovement
		and inputObject.UserInputType ~= Enum.UserInputType.Touch then return end
	local delta = inputObject.Position - dragStart
	main.Position = UDim2.new(
		startingPosition.X.Scale,
		startingPosition.X.Offset + delta.X,
		startingPosition.Y.Scale,
		startingPosition.Y.Offset + delta.Y
	)
end)
