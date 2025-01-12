local UIBuilder = {}
UIBuilder.__index = UIBuilder

-- 기본 스타일 정의
local DefaultStyles = {
	Frame = {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0,
		CornerRadius = UDim.new(0, 30),
	},
	TextButton = {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		TextColor3 = Color3.fromRGB(0, 0, 0),
		Font = Enum.Font.TitilliumWeb,
		FontWeight = Enum.FontWeight.Regular,
		TextScaled = true,
		TextConstraint = {
			MaxTextSize = 70,
			MinTextSize = 10,
		},
		CornerRadius = UDim.new(0, 30),
	},
	TextLabel = {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		TextColor3 = Color3.fromRGB(0, 0, 0),
		Font = Enum.Font.TitilliumWeb,
		FontWeight = Enum.FontWeight.Regular,
		TextScaled = true,
		TextConstraint = {
			MaxTextSize = 70,
			MinTextSize = 10,
		},
	},
	TextBox = {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		TextColor3 = Color3.fromRGB(0, 0, 0),
		Font = Enum.Font.TitilliumWeb,
		FontWeight = Enum.FontWeight.Regular,
		TextConstraint = {
			MaxTextSize = 70,
			MinTextSize = 10,
		},
		ClearTextOnFocus = false,
		-- CornerRadius = UDim.new(0, 20),
	},
}

-- 템플릿 설정값 정의
local SizeTemplates = {
	Frame = {
		S0 = { size = UDim2.fromScale(1, 1), position = UDim2.fromScale(0, 0) },
		S1 = { size = UDim2.fromScale(0.8, 0.7), position = UDim2.fromScale(0.1, 0.15) },
		S2 = { size = UDim2.fromScale(0.5, 0.5), position = UDim2.fromScale(0.25, 0.25) },
		S3 = { size = UDim2.fromScale(0.4, 0.5), position = UDim2.fromScale(0.3, 0.25) },
	},
	TextButton = {
		S0 = { size = UDim2.fromScale(1, 1), position = UDim2.fromScale(0, 0) },
		S1 = { size = UDim2.fromScale(0.5, 0.5), position = UDim2.fromScale(0.25, 0.25) },
		S2 = { size = UDim2.fromScale(0.2, 0.1), position = UDim2.fromScale(0.4, 0.45) },
	},
	TextLabel = {
		S0 = { size = UDim2.fromScale(1, 1), position = UDim2.fromScale(0, 0) },
		S1 = { size = UDim2.fromScale(0.5, 0.5), position = UDim2.fromScale(0.25, 0.25) },
		S2 = { size = UDim2.fromScale(0.2, 0.1), position = UDim2.fromScale(0.4, 0.45) },
	},
}

-- UI 객체 생성 함수들
local function applyCorner(instance, radius)
	local corner = instance:FindFirstChild("UICorner") or Instance.new("UICorner")
	corner.CornerRadius = radius
	corner.Parent = instance
	return corner
end
local function applyTextConstraint(instance, constraints)
	local constraint = instance:FindFirstChild("UITextSizeConstraint") or Instance.new("UITextSizeConstraint")
	instance.TextScaled = true
	constraint.MaxTextSize = constraints.MaxTextSize
	constraint.MinTextSize = constraints.MinTextSize
	constraint.Parent = instance
	return constraint
end
local function applyStroke(instance, strokeProps)
	local stroke = instance:FindFirstChild("UIStroke") or Instance.new("UIStroke")

	-- table 타입이면 상세 설정 적용
	if type(strokeProps) == "table" then
		stroke.Color = strokeProps.Color or Color3.fromRGB(0, 0, 0)
		stroke.ApplyStrokeMode = strokeProps.Mode or "Border"
		stroke.Thickness = strokeProps.Thickness or 4
	else
		stroke.Color = strokeProps
		stroke.ApplyStrokeMode = "Border"
		stroke.Thickness = 4
	end

	stroke.Parent = instance
	return stroke
end

-- 새로운 인스턴스 생성
function UIBuilder.new(instance)
	return setmetatable({ instance = instance }, UIBuilder)
end

-- create 함수
function UIBuilder.create(parent, className, templateCode)
	local instance = Instance.new(className)
	instance.Parent = parent

	-- 템플릿 크기 적용
	if SizeTemplates[className] and templateCode and SizeTemplates[className][templateCode] then
		local template = SizeTemplates[className][templateCode]
		instance.Size = template.size
		instance.Position = template.position
	end

	return UIBuilder.new(instance)
end

-- withDefault 체이닝 메서드
function UIBuilder:withDefault()
	local className = self.instance.ClassName
	local defaultProps = DefaultStyles[className]

	if defaultProps then
		for prop, value in pairs(defaultProps) do
			if prop == "CornerRadius" then
				applyCorner(self.instance, value)
			elseif prop == "TextConstraint" then
				applyTextConstraint(self.instance, value)
			elseif prop == "Stroke" then
				applyStroke(self.instance, value)
			else
				pcall(function()
					self.instance[prop] = value
				end)
			end
		end
	end

	return self
end

-- with 체이닝 메서드
function UIBuilder:with(properties)
	for prop, value in pairs(properties) do
		if prop == "CornerRadius" then
			applyCorner(self.instance, value)
		elseif prop == "Stroke" then
			applyStroke(self.instance, value)
		elseif prop == "TextConstraint" then
			applyTextConstraint(self.instance, value)
		elseif prop == "FontWeight" then
			pcall(function()
				local currentFont = self.instance.FontFace
				local newFont = Font.new(currentFont.Family, value, currentFont.Style)
				self.instance.FontFace = newFont
			end)
		elseif prop == "Events" then
			self:withEvents(value)
		else
			pcall(function()
				self.instance[prop] = value
			end)
		end
	end
	return self
end

-- withEvents 체이닝 메서드
function UIBuilder:withEvents(events)
	for eventName, callback in pairs(events) do
		if self.instance[eventName] then
			local instance = self.instance
			instance[eventName]:Connect(function(...)
				callback(instance, ...)
			end)
		end
	end
	return self
end

return UIBuilder

-- 사용 예시:
-- local button = UIComponents.create(parent, "TextButton", "S2")
--     :withDefault()
--     :with({
--         Name = "MyButton",
--         Text = "Click me",
--     })
--     :withEvents({
--         MouseButton1Click = function(button)
--             print("Button clicked:", button.Name)
--         end
--     })
