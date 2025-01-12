local Loading = {}

local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local UIBuilder = require(script.Parent.UIBuilder)
local UITransparencyController = require(script.Parent.UITransparencyController)

local Player = Players.LocalPlayer
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local loadingCount = 0

-- 로딩 UI 생성
function Loading:createLoadingUI()
	-- ScreenGui 생성
	local loadingGui = UIBuilder.create(PlayerGui, "ScreenGui"):with({
		Name = "LoadingGui",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		DisplayOrder = 100,
	}).instance

	-- MainFrame 생성
	local mainFrame = UIBuilder.create(loadingGui, "Frame", "S0"):with({
		Name = "MainFrame",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0,
	}).instance

	-- 타이틀 텍스트
	UIBuilder.create(mainFrame, "TextLabel", "S2"):withDefault():with({
		Name = "TitleText",
		Size = UDim2.new(0.8, 0, 0.1, 0),
		Position = UDim2.new(0.1, 0, 0.4, 0),
		BackgroundTransparency = 1,
		Text = "4Fun Speaking",
		FontWeight = Enum.FontWeight.Bold,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextConstraint = {
			MaxTextSize = 100,
			MinTextSize = 10,
		},
	})

	-- 로딩바 외부 베이스
	local loadingBarBase = UIBuilder.create(mainFrame, "Frame", "S0"):withDefault():with({
		Name = "LoadingBarBase",
		Size = UDim2.new(0.6, 0, 0.05, 0),
		Position = UDim2.new(0.2, 0, 0.55, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		CornerRadius = UDim.new(1, 0),
		Stroke = Color3.fromRGB(255, 255, 255),
	}).instance

	-- 로딩바
	local loadingBar = UIBuilder.create(loadingBarBase, "Frame", "S0"):with({
		Name = "LoadingBar",
		Size = UDim2.new(0, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		CornerRadius = UDim.new(1, 0),
	}).instance

	-- 퍼센티지 텍스트
	UIBuilder.create(mainFrame, "TextLabel", "S2"):withDefault():with({
		Name = "PercentText",
		Size = UDim2.new(0.2, 0, 0.05, 0),
		Position = UDim2.new(0.4, 0, 0.62, 0),
		BackgroundTransparency = 1,
		Text = "0%",
		TextColor3 = Color3.fromRGB(255, 255, 255),
	})

	return loadingGui, mainFrame, loadingBar
end

-- 로딩 초기화 함수
function Loading:init()
	local loadingGui, mainFrame, loadingBar = self:createLoadingUI()
	loadingCount = 0

	-- 로딩 화면 제거 함수
	local function removeLoadingScreen()
		UITransparencyController:setTransparencyAllChildren({
			obj = loadingGui,
			transparency = 1,
			delay = 0.03,
		})

		while mainFrame.BackgroundTransparency ~= 1 do
			task.wait()
		end

		loadingGui:Destroy()
	end

	-- 로딩 단계 관리 함수
	local function incrementLoadingStep()
		loadingCount += 1
		return loadingCount
	end

	-- 로딩바 업데이트 함수
	local function updateLoadingBar(progress)
		loadingBar.Size = UDim2.new(progress, 0, 1, 0)
		mainFrame.PercentText.Text = string.format("%d%%", math.floor(progress * 100))
	end

	-- 로딩 시작 함수
	local function setupLoadingScreen()
		loadingGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		incrementLoadingStep()

		-- 단계 1: 초기 설정
		if loadingCount == 1 then
			Player.CameraMaxZoomDistance = 15
			updateLoadingBar(0.1)
			incrementLoadingStep()
			task.wait(0.01)
		end

		-- 단계 2: 모듈 초기화
		if loadingCount == 2 then
			updateLoadingBar(0.2)
			local totalModules = #self.modulesToInit
			for i, module in ipairs(self.modulesToInit) do
				local moduleInstance = require(module)
				-- Init 또는 init 메서드 호출
				if typeof(moduleInstance.Init) == "function" then
					moduleInstance:Init()
				elseif typeof(moduleInstance.init) == "function" then
					moduleInstance.init()
				end
				updateLoadingBar(0.2 + (i / totalModules * 0.1))
			end
			incrementLoadingStep()
		end

		-- 단계 3: 캐릭터 로드
		if loadingCount == 3 then
			local _ = Player.Character or Player.CharacterAdded:Wait()
			updateLoadingBar(0.3)
			incrementLoadingStep()
		end

		-- 단계 4: 에셋 프리로드
		if loadingCount == 4 then
			local loadedAssets = 0
			local totalAssets = #self.assetsToPreload or 0

			-- 프리로드할 에셋이 없는 경우 바로 다음 단계로
			if totalAssets == 0 then
				updateLoadingBar(0.6)
				incrementLoadingStep()
			else
				local function onAssetLoaded(assetId, status)
					if status == Enum.AssetFetchStatus.Success then
						loadedAssets += 1
						updateLoadingBar(0.3 + (loadedAssets / totalAssets * 0.3))
					else
						warn("Failed to load asset:", assetId)
					end

					-- 모든 에셋 로딩 완료 시 다음 단계로
					if loadedAssets >= totalAssets then
						incrementLoadingStep()
					end
				end

				ContentProvider:PreloadAsync(self.assetsToPreload, onAssetLoaded)
			end
		end

		-- 단계 5: 워크스페이스 로딩
		if loadingCount == 5 then
			local descendants = workspace:GetDescendants()
			local totalParts = 0
			local loadedParts = 0

			-- 먼저 BasePart 개수를 계산
			for _, part in ipairs(descendants) do
				if part:IsA("BasePart") then
					totalParts += 1
				end
			end

			-- BasePart가 없는 경우 바로 다음 단계로
			if totalParts == 0 then
				updateLoadingBar(0.8)
				incrementLoadingStep()
			else
				-- 이미 로드된 파트들 처리
				for _, part in ipairs(descendants) do
					if part:IsA("BasePart") then
						loadedParts += 1
						updateLoadingBar(0.6 + (loadedParts / totalParts * 0.2))
					end
				end

				-- 모든 파트가 로드되었으면 다음 단계로
				if loadedParts >= totalParts then
					incrementLoadingStep()
				end
			end
		end

		-- 단계 6: 서버측 로딩 확인
		if loadingCount == 6 then
			Remotes.Loading.ServerReadyFunction:InvokeServer()
			updateLoadingBar(0.9)
			incrementLoadingStep()
			Remotes.Loading:Destroy()
		end

		-- 최종 로딩 완료
		if loadingCount == 7 then
			updateLoadingBar(1)
			task.wait(1)
			removeLoadingScreen()
		end
	end

	setupLoadingScreen()
	return loadingGui
end

return Loading
