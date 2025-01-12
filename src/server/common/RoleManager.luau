local RoleManager = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local GameConfig = require(script.Parent.GameConfig)

local PASSWORD = GameConfig.TEACHER.PASSWORD

function RoleManager.init()
	-- 선생님 유저 저장
	local function SetTeacher(Player)
		Player:SetAttribute("Role", "Teacher")
	end
	-- 학생 유저 저장
	local function SetStudent(Player)
		Player:SetAttribute("Role", "Student")
	end

	-- 전송받은 비밀번호로 인증 후 결과 전송
	Remotes.Role.AuthRoleFunction.OnServerInvoke = function(player, enteredPassword)
		if enteredPassword == PASSWORD then
			Remotes.Notify.NotifyEvent:FireClient(player, "Registered as a Teacher")
			SetTeacher(player)
			-- 다른 모든 유저를 Student로 설정
			for _, otherPlayer in pairs(Players:GetPlayers()) do
				if otherPlayer ~= player then
					SetStudent(otherPlayer)
				end
			end

			return true
		else
			Remotes.Notify.NotifyEvent:FireClient(player, "Incorrect password")
			return false
		end
	end

	-- 인증 완료 후 RemoteFunction 파괴
	Remotes.Role.DestroyAuthEvent.OnServerEvent:Connect(function()
		Remotes.Role.AuthRoleFunction:Destroy()
		Remotes.Role:Destroy()
	end)
end

return RoleManager
