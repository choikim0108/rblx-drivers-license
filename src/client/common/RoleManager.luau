local RoleManager = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local UIBuilder = require(script.Parent.UIBuilder)

-- Workspace 객체
local teacherPart = workspace.Interactables:WaitForChild("TeacherPart")
local teacherProx = teacherPart:WaitForChild("ProximityPrompt")

-- 로컬 변수
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local roleGui

local function endAuth()
	roleGui:Destroy()
	teacherPart:Destroy()

	Remotes.Role.DestroyAuthEvent:FireServer()
end

local function createAuthUI()
	-- ScreenGui 생성
	roleGui = UIBuilder.create(PlayerGui, "ScreenGui"):with({
		Name = "RoleGui",
		Enabled = false,
		DisplayOrder = 30,
	}).instance

	-- RegisterFrame 생성
	local registerFrame = UIBuilder.create(roleGui, "Frame", "S2"):withDefault():with({
		Name = "RegisterFrame",
		BackgroundTransparency = 0,
	}).instance

	-- PasswordTextBox 생성
	local passwordTextBox = UIBuilder.create(registerFrame, "TextBox"):withDefault():with({
		Name = "PasswordTextBox",
		Size = UDim2.fromScale(0.695, 0.423),
		Position = UDim2.fromScale(0.163, 0.145),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.3,
		Text = "",
		TextColor3 = Color3.new(1, 1, 1),
		ShowNativeInput = true,
		TextEditable = true,
		FontWeight = Enum.FontWeight.Bold,
		CornerRadius = UDim.new(0, 20),
	}).instance

	-- ExitButton 생성
	UIBuilder.create(registerFrame, "TextButton"):withDefault():with({
		Name = "ExitButton",
		Size = UDim2.fromScale(0.049, 0.095),
		Position = UDim2.fromScale(0.951, 0),
		Text = "X",
		TextConstraint = {
			MaxTextSize = 40,
			MinTextSize = 1,
		},
		FontWeight = Enum.FontWeight.Bold,
		Events = {
			MouseButton1Click = function()
				roleGui.Enabled = false
			end,
		},
	})

	-- ProceedButton 생성
	UIBuilder.create(registerFrame, "TextButton"):withDefault():with({
		Name = "ProceedButton",
		Size = UDim2.fromScale(0.694, 0.208),
		Position = UDim2.fromScale(0.163, 0.676),
		BackgroundColor3 = Color3.new(0, 0, 0),
		Text = "Proceed",
		TextColor3 = Color3.new(1, 1, 1),
		FontWeight = Enum.FontWeight.Bold,
		Events = {
			MouseButton1Click = function()
				local currentPassword = passwordTextBox.Text
				if currentPassword and currentPassword ~= "" then
					local success = Remotes.Role.AuthRoleFunction:InvokeServer(currentPassword)
					if success then
						endAuth()
					end
				end
			end,
		},
	})

	-- 엔터키 이벤트 연결
	passwordTextBox.FocusLost:Connect(function(_, enterPressed)
		if enterPressed and passwordTextBox.Text ~= "" then
			local currentPassword = passwordTextBox.Text
			local success = Remotes.Role.AuthRoleFunction:InvokeServer(currentPassword)
			if success then
				endAuth()
			end
		end
	end)
end

function RoleManager.init()
	createAuthUI()

	-- TeacherProximityPrompt
	teacherProx.Triggered:Connect(function()
		roleGui.Enabled = true
	end)
end

return RoleManager
