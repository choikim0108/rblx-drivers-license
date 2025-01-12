local Log = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local UIBuilder = require(script.Parent.UIBuilder)
local UITransparencyController = require(script.Parent.UITransparencyController)

-- 상수
local MAX_LOGS = 3
local LOG_TRANSPARENCY = 0.2
local DISPLAY_DURATION = 3

-- 로컬 변수
local player = Players.LocalPlayer
local PlayerGui = player.PlayerGui

local messages = {}
local logFrames = {}

-- UI 생성 함수
local function createLogUI()
	-- ScreenGui 생성
	local logGui = UIBuilder.create(PlayerGui, "ScreenGui"):with({
		Name = "LogGui",
		DisplayOrder = 49,
	}).instance

	-- MAX_LOGS 만큼 로그 프레임 생성
	for i = 1, MAX_LOGS do
		local frame = UIBuilder.create(logGui, "Frame", "S0"):withDefault():with({
			Name = "LogFrame" .. i,
			Size = UDim2.new(0.3 * (i > 1 and 0.8 or 1), 0, 0.05 * (i > 1 and 0.8 or 1), 0),
			Position = UDim2.new(0.7, 0, 0.215 + (i - 1) * 0.06 * (i > 2 and 0.92 or 1), 0),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,
		}).instance

		UIBuilder.create(frame, "TextLabel", "S0"):withDefault():with({
			Name = "ContentLabel",
			Size = UDim2.new(0.98, 0, 0.9, 0),
			Position = UDim2.new(0.01, 0, 0.005, 0),
			Text = "",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			TextTransparency = 1,
		})

		table.insert(logFrames, frame)
	end
end

-- 로그 업데이트 함수
local function updateLogs()
	local currentTime = tick()

	-- 로그 프레임 업데이트
	for i, logFrame in ipairs(logFrames) do
		if not messages[i] then
			if logFrame.Visible then
				UITransparencyController:setTransparencyAllChildren({
					obj = logFrame,
					transparency = 1,
					delay = 0.003,
				})
				logFrame.Visible = false
			end
			continue
		end

		logFrame.ContentLabel.Text = messages[i].message

		-- 로그 프레임이 보이지 않으면 보이게 설정
		if not logFrame.Visible then
			logFrame.Visible = true
			task.spawn(function()
				UITransparencyController:setTransparency({
					obj = logFrame.ContentLabel,
					prop = "TextTransparency",
					transparency = 0,
					delay = 0.01,
				})
				UITransparencyController:setTransparency({
					obj = logFrame,
					prop = "BackgroundTransparency",
					transparency = LOG_TRANSPARENCY,
					delay = 0.01,
				})
			end)
		end

		-- 로그 프레임이 보이는 시간이 지나면 사라지게 설정
		if currentTime - messages[i].time >= DISPLAY_DURATION then
			table.remove(messages, i)
			task.spawn(function()
				UITransparencyController:setTransparencyAllChildren({
					obj = logFrame,
					transparency = 1,
					delay = 0.003,
				})
				logFrame.Visible = false
			end)
		end
	end
end

-- 초기화 함수
function Log.init()
	createLogUI()

	-- 서버에서 로그 이벤트를 받아 로그 프레임에 표시
	Remotes.Log.LogEvent.OnClientEvent:Connect(function(new_message)
		table.insert(messages, 1, { message = new_message, time = tick() })
		if #messages > MAX_LOGS then
			table.remove(messages, MAX_LOGS + 1)
		end
	end)
end

-- 계속해서 로그 업데이트 호출
game:GetService("RunService").Heartbeat:Connect(updateLogs)

return Log
