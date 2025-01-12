local Countdown = {}

local Players = game:GetService("Players")

local UIBuilder = require(script.Parent.UIBuilder)

local player = Players.LocalPlayer
local PlayerGui = player.PlayerGui

-- 카운트다운 UI 생성
local function createCountdownUI()
	local countdownGui = UIBuilder.create(PlayerGui, "ScreenGui"):with({
		Name = "CountdownGui",
		DisplayOrder = 60,
		Enabled = false,
	}).instance

	local countdownLabel = UIBuilder.create(countdownGui, "TextLabel"):with({
		Name = "CountdownLabel",
		Size = UDim2.new(0.2, 0, 0.2, 0),
		Position = UDim2.new(0.4, 0, 0.2, 0),
		Text = "",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		RichText = true,
		Font = Enum.Font.TitilliumWeb,
		FontWeight = Enum.FontWeight.Bold,
		BackgroundTransparency = 1,
		Stroke = {
			Color = Color3.fromRGB(0, 0, 0),
			Mode = "Contextual",
			Thickness = 3,
		},
		Visible = false,
	}).instance

	return countdownGui, countdownLabel
end

-- 카운트다운 실행 함수
function Countdown.start(duration: number, onComplete: () -> ()?)
	local countdownGui, countdownLabel = createCountdownUI()
	countdownGui.Enabled = true

	-- 카운트다운 시작
	for i = duration, 1, -1 do
		countdownLabel.Text = tostring(i)
		task.wait(1)
	end

	-- "Start!" 표시
	--countdownLabel.Text = "Start!"
	--task.wait(0.8) -- Start! 메시지를 0.8초 동안 표시

	-- 카운트다운 종료
	countdownGui:Destroy()

	-- 완료 콜백 실행
	if onComplete then
		onComplete()
	end
end

function Countdown.stop()
	local countdownGui = player.PlayerGui:FindFirstChild("CountdownGui")
	if countdownGui then
		countdownGui:Destroy()
	end
end

return Countdown
