local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ModuleUtils = require(ReplicatedStorage.Shared.common.ModuleUtils)

local isServerReady = false
local modulesToInit = {
	script.common.SetRemotes,
	script.common.RoleManager,
}

-- 모듈 초기화
ModuleUtils.initModules(modulesToInit)

-- ServerReadyFunction 설정
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
Remotes.Loading.ServerReadyFunction.OnServerInvoke = function()
	return isServerReady
end

isServerReady = true
