local ExamMain = {
	timerConnection = nil, -- timerConnection 필드를 추가하여 관리
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local UIBuilder = require(StarterPlayerScripts.Client.common.UIBuilder)
local Countdown = require(StarterPlayerScripts.Client.common.Countdown)

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local proximityPrompt = Workspace.Office.Desk.Note.Note.ExamPrompt

local currentQuestionIndex = 1
local score = 0
local maxTime = 300 -- 5분
local examGui = nil -- [개선점 1] 중복 UI 생성을 방지하기 위해 전역 변수로 선언

-- 문제 데이터 구조체
local questions = {
	{ question = "Is it legal for a 5 year old to drive?", options = { "YES", "NO" }, answer = 2 },
	{
		question = "What does this sign mean?",
		image = "rbxassetid://110311495827475",
		options = { "ONLY MEN ALLOWED", "STOP WALKING", "PEDESTRIAN CROSSING" },
		answer = 3,
	},
	{
		question = "What should you do if you see a yellow light?",
		options = { "Speed up", "Slow down", "Stop" },
		answer = 2,
	},
	{
		question = "What does this sign mean?",
		image = "rbxassetid://87009047292862",
		options = { "Left turn only", "Stop", "U-turn not allowed" },
		answer = 3,
	},
	{
		question = "What does this sign mean?",
		image = "rbxassetid://131276410083691",
		options = { "Stop 30 meters ahead", "Go faster than 30 kmph", "30 kmph speed limit" },
		answer = 3,
	},
	{
		question = "Which of these statements are true?",
		options = {
			"If a police officer is behind you, you should speed up",
			"You can park anywhere on the road",
			"Anyone can drive as long as they are confident",
			"You should always stop at a red light",
			"The highway is a place to sleep",
		},
		answer = 4,
	},
	{
		question = "When should you honk at the car in front of you?",
		options = {
			"When the car in front of you is not moving",
			"All the time",
			"When you feel like it",
			"When you are listening to music",
		},
		answer = 1,
	},
	{
		question = "Should you drive if you are tired?",
		options = { "Yes", "No" },
		answer = 2,
	},
	{
		question = "Which of these statements are illegal?",
		options = {
			"Driving while listening to music",
			"Driving while singing",
			"Driving while playing mobile games",
			"Driving while talking to passengers",
		},
		answer = 3,
	},
	{
		question = "Is it ok to speed up while going downhill?",
		options = { "Yes", "No" },
		answer = 2,
	},
}

-- 초기화 함수
function ExamMain:init()
	print("[DEBUG] Initializing Exam Game...")
	if not proximityPrompt then
		warn("[DEBUG] ProximityPrompt is missing.")
		return
	end

	proximityPrompt.Triggered:Connect(function(player)
		print("ProximityPrompt triggered by:", player.Name)
		ExamMain.onProximityTriggered(player)
	end)
	print("[DEBUG] Exam Game initialized successfully.")
end

-- 시험 UI 생성 함수
function ExamMain.createExamUI()
	print("[DEBUG] Creating Exam UI...")
	if examGui then -- [개선점 1] 이미 생성된 UI가 있는지 확인
		print("[DEBUG] Exam UI already exists. Reusing existing UI.")
		return examGui
	end

	examGui = UIBuilder.create(PlayerGui, "ScreenGui"):with({
		Name = "ExamGui",
		DisplayOrder = 50,
		Enabled = false,
	}).instance

	local frame = UIBuilder.create(examGui, "Frame", "S1"):withDefault():with({
		Name = "ExamFrame",
	}).instance

	local questionLabel = UIBuilder.create(frame, "TextLabel"):withDefault():with({
		Name = "QuestionLabel",
		Size = UDim2.new(0.9, 0, 0.2, 0),
		Position = UDim2.new(0.05, 0, 0.05, 0),
		Text = "",
	}).instance

	local imageLabel = UIBuilder.create(frame, "ImageLabel"):with({
		Name = "QuestionImage",
		Size = UDim2.new(0.6, 0, 0.3, 0),
		Position = UDim2.new(0.2, 0, 0.3, 0),
		BackgroundTransparency = 1,
		Visible = false,
	}).instance

	local optionsFrame = UIBuilder.create(frame, "Frame"):withDefault():with({
		Name = "OptionsFrame",
		Size = UDim2.new(0.9, 0, 0.3, 0),
		Position = UDim2.new(0.05, 0, 0.65, 0),
	}).instance

	local timerLabel = UIBuilder.create(frame, "TextLabel"):withDefault():with({
		Name = "TimerLabel",
		Size = UDim2.new(0.3, 0, 0.1, 0),
		Position = UDim2.new(0.05, 0, -0.1, 0),
		Text = "Time: 300",
	}).instance

	local scoreLabel = UIBuilder.create(frame, "TextLabel"):withDefault():with({
		Name = "ScoreLabel",
		Size = UDim2.new(0.3, 0, 0.1, 0),
		Position = UDim2.new(0.65, 0, -0.1, 0),
		Text = "Score: 0",
	}).instance

	print("[DEBUG] Exam UI Created.")
	return examGui, questionLabel, imageLabel, optionsFrame, timerLabel, scoreLabel
end

-- UI 갱신 함수
function ExamMain.updateUI(questionData, questionLabel, imageLabel, optionsFrame)
	print("[DEBUG] Updating UI for question:", questionData.question)
	questionLabel.Text = questionData.question

	if questionData.image then
		print("[DEBUG] Displaying image for question:", questionData.image)
		imageLabel.Image = questionData.image
		imageLabel.Visible = true
	else
		imageLabel.Visible = false
	end

	for _, child in ipairs(optionsFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local optionCount = #questionData.options
	print("[DEBUG] Number of options:", optionCount)
	for i, optionText in ipairs(questionData.options) do
		local button = UIBuilder.create(optionsFrame, "TextButton"):withDefault():with({
			Name = "Option" .. i,
			Text = optionText,
			Size = UDim2.new(1 / optionCount, -10, 1, 0),
			Position = UDim2.new((i - 1) / optionCount, 5, 0, 0),
			Events = {
				MouseButton1Click = function()
					print("[DEBUG] Option", i, "clicked.")
					if i == questionData.answer then
						print("[DEBUG] Correct answer selected.")
						score += 10
					else
						print("[DEBUG] Incorrect answer selected.")
					end

					currentQuestionIndex += 1
					if currentQuestionIndex > #questions then
						print("[DEBUG] No more questions. Ending exam.")
						ReplicatedStorage.Remotes.Exam.ExamDone:FireServer(player, score)
						optionsFrame.Parent.Parent.Enabled = false
						if score >= 80 then
							print("[DEBUG] Player score achieve 80. Firing examDone event.")
							ReplicatedStorage.Remotes.Exam.ExamDone:FireServer(player, score)
						end
						ExamMain.cleanup()
						Countdown.stop()
						return
					end
					ExamMain.updateUI(questions[currentQuestionIndex], questionLabel, imageLabel, optionsFrame)
				end,
			},
		}).instance
	end
end

function ExamMain.cleanup()
	print("[DEBUG] Cleaning up Exam GUI and related elements.")

	-- timerConnection 해제
	if ExamMain.timerConnection then
		ExamMain.timerConnection:Disconnect()
		ExamMain.timerConnection = nil
	end

	-- ExamGui 정리
	if examGui then
		examGui:Destroy()
		examGui = nil
	end

	-- CountdownGui 정리
	local countdownGui = PlayerGui:FindFirstChild("CountdownGui")
	if countdownGui then
		countdownGui:Destroy()
	end
end

-- ProximityPrompt와 상호작용 이벤트
function ExamMain.onProximityTriggered(player)
	print("[DEBUG] ProximityPrompt triggered by player.")
	local examGui, questionLabel, imageLabel, optionsFrame, timerLabel, scoreLabel = ExamMain.createExamUI()
	examGui.Enabled = true

	ExamMain.updateUI(questions[currentQuestionIndex], questionLabel, imageLabel, optionsFrame)

	-- 기존 연결 해제 (중복 방지)
	if ExamMain.timerConnection then
		ExamMain.timerConnection:Disconnect()
		ExamMain.timerConnection = nil
	end

	-- 새 Heartbeat 연결
	ExamMain.timerConnection = game:GetService("RunService").Heartbeat:Connect(function()
		timerLabel.Text = "Time: " .. math.max(0, PlayerGui.CountdownGui.CountdownLabel.Text)
		scoreLabel.Text = "Score: " .. score
		if not examGui.Enabled then
			if ExamMain.timerConnection then
				ExamMain.timerConnection:Disconnect()
				ExamMain.timerConnection = nil
			end
		end
	end)

	Countdown.start(maxTime, function()
		print("[DEBUG] Countdown finished.")
		examGui.Enabled = false

		if score >= 80 then
			print("[DEBUG] Player score achieve 80. Firing examDone event.")
			ReplicatedStorage.Remotes.Exam.ExamDone:FireServer(player, score)
		end
	end)
end

return ExamMain
