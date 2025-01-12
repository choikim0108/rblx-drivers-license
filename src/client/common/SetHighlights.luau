local SetHighlights = {}
SetHighlights.__index = SetHighlights

local colorPalette = {
	["Red"] = Color3.new(1, 0, 0),
	["Green"] = Color3.new(0, 1, 0),
	["Blue"] = Color3.new(0, 0, 1),
	["Yellow"] = Color3.new(1, 1, 0),
	["White"] = Color3.new(1, 1, 1),
}

function SetHighlights:set(model, color)
	-- Remove existing highlight if any
	local highlight = model:FindFirstChildOfClass("Highlight")
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Parent = model
	end
	highlight.FillColor = colorPalette[color] or colorPalette["White"]
end

function SetHighlights:destroy(model)
	local highlight = model:FindFirstChildOfClass("Highlight")
	if highlight then
		highlight:Destroy()
	end
end

return SetHighlights
