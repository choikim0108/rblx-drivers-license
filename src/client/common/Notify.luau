local Notify = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local UIBuilder = require(script.Parent.UIBuilder)
local UITransparencyController = require(script.Parent.UITransparencyController)

-- 상수
local NOTIFY_TRANSPARENCY = 0.2
local DISPLAY_DURATION = 2.5

-- 로컬 변수
local player = Players.LocalPlayer
local PlayerGui = player.PlayerGui

local currentMessage = {
	message = nil,
	startTime = nil,
}
local notifyFrame

-- UI 생성 로컬 함수
local function createNotifyUI()
	-- ScreenGui 생성
	local notifyGui = UIBuilder.create(PlayerGui, "ScreenGui"):with({
		Name = "NotifyGui",
		DisplayOrder = 50,
	}).instance

	-- NotifyFrame 생성
	notifyFrame = UIBuilder.create(notifyGui, "Frame", "S0"):withDefault():with({
		Name = "NotifyFrame",
		Size = UDim2.new(0.6, 0, 0.109, 0),
		Position = UDim2.new(0.2, 0, 0.115, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 2,
	}).instance

	-- ContentLabel 생성
	UIBuilder.create(notifyFrame, "TextLabel", "S2"):withDefault():with({
		Name = "ContentLabel",
		Size = UDim2.new(0.989, 0, 0.844, 0),
		Position = UDim2.new(0.005, 0, 0.08, 0),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		ZIndex = 3,
	})
end

-- 메시지 업데이트 로컬 함수
local function updateNotification()
	if currentMessage.startTime then
		local currentTime = tick()
		notifyFrame.ContentLabel.Text = currentMessage.message

		if not notifyFrame.Visible then
			notifyFrame.Visible = true

			UITransparencyController:setTransparency({
				obj = notifyFrame.ContentLabel,
				prop = "TextTransparency",
				transparency = 0,
				delay = 0.01,
			})
			UITransparencyController:setTransparency({
				obj = notifyFrame,
				prop = "BackgroundTransparency",
				transparency = NOTIFY_TRANSPARENCY,
				delay = 0.01,
			})
		end
		if currentTime - currentMessage.startTime >= DISPLAY_DURATION then
			UITransparencyController:setTransparencyAllChildren({ obj = notifyFrame, transparency = 1, delay = 0.003 })

			if notifyFrame.BackgroundTransparency == 1 then
				notifyFrame.Visible = false
				currentMessage.message = nil
				currentMessage.startTime = nil
			end
		end
	end
end

-- 메시지 업데이트
game:GetService("RunService").Heartbeat:Connect(updateNotification)

Remotes.Notify.NotifyEvent.OnClientEvent:Connect(function(new_message)
	currentMessage.message = new_message
	currentMessage.startTime = tick()
end)

-- 초기화 함수
function Notify.init()
	createNotifyUI()
end

return Notify
