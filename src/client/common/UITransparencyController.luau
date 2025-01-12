local UITransparencyController = {}
UITransparencyController.__index = UITransparencyController

-- 투명도 속성
local transparencyProperties = {
	"BackgroundTransparency",
	"TextTransparency",
	"ImageTransparency",
	"ScrollBarImageTransparency",
	"Transparency",
}

-- 투명도 업데이트 로컬 함수
local function updateTransparency(obj, prop, transparency, delay)
	local lerpFactor = 0.1

	pcall(function()
		if not delay then
			obj[prop] = transparency
		else
			for i = 0, 1, lerpFactor do
				obj[prop] = obj[prop] + (transparency - obj[prop]) * i
				task.wait(delay)
			end
			obj[prop] = transparency
		end
	end)
end

-- 투명도를 즉시 또는 부드럽게 변경하는 함수
function UITransparencyController:setTransparency(input)
	-- prop이 nil일 경우 지정된 객체의 모든 투명도 속성을 변경
	if not input.prop then
		for _, prop in ipairs(transparencyProperties) do
			task.spawn(function()
				updateTransparency(input.obj, prop, input.transparency, input.delay)
			end)
		end
	else
		task.spawn(function()
			updateTransparency(input.obj, input.prop, input.transparency, input.delay)
		end)
	end
end

-- 모든 자식 객체의 투명도를 동시에 설정하는 함수
function UITransparencyController:setTransparencyAllChildren(input)
	-- 모든 대상 객체를 저장할 테이블
	local allObjects = {}

	local function collectObjects(obj)
		-- 객체가 투명도 속성을 하나라도 가지고 있는지 확인
		for _, prop in ipairs(transparencyProperties) do
			if pcall(function()
				return obj[prop] ~= nil
			end) then
				table.insert(allObjects, obj)
				break
			end
		end

		-- 자식 객체들에 대해 재귀적으로 검사
		for _, child in ipairs(obj:GetChildren()) do
			collectObjects(child)
		end
	end

	-- 모든 객체 수집
	collectObjects(input.obj)

	-- 모든 객체의 투명도를 동시에 변경
	for _, obj in ipairs(allObjects) do
		self:setTransparency({ obj = obj, transparency = input.transparency, delay = input.delay })
	end
end

return UITransparencyController
