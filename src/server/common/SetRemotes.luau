local SetRemotes = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")

-- 초기 설정 리모트 구조
-- :event, :function, :bindEvent, :bindFunction 으로 객체 타입 설정 가능
local RemoteStructure = {
	Loading = { "ServerReadyFunction:function" },
	Notify = { "NotifyEvent:event" },
	Log = { "LogEvent:event" },
	Role = {
		"AuthRoleFunction:function",
		"DestroyAuthEvent:event",
	},
	Exam = { "ExamDone:event" },
}

-- RemoteStructure에 따라 모든 리모트 설정 로컬함수
local function setupRemoteStructure()
	for category, events in pairs(RemoteStructure) do
		if type(events) == "table" then
			for _, eventName in ipairs(events) do
				local name, remoteType = string.match(eventName, "(.+):(.+)$")
				local instanceType = remoteType == "event" and "RemoteEvent"
					or remoteType == "function" and "RemoteFunction"
					or remoteType == "bindEvent" and "BindableEvent"
					or remoteType == "bindFunction" and "BindableFunction"
				SetRemotes.createRemoteInstance(instanceType, name, category)
			end
		end
	end
end

-- 단일 리모트 인스턴스 생성 함수
function SetRemotes.createRemoteInstance(remoteType, name, parentName)
	local parentFolder = Remotes:FindFirstChild(parentName)
	if not parentFolder then
		parentFolder = Instance.new("Folder")
		parentFolder.Name = parentName
		parentFolder.Parent = Remotes
	end

	local newRemote
	if remoteType == "RemoteEvent" then
		newRemote = Instance.new("RemoteEvent")
	elseif remoteType == "RemoteFunction" then
		newRemote = Instance.new("RemoteFunction")
	elseif remoteType == "BindableEvent" then
		newRemote = Instance.new("BindableEvent")
	elseif remoteType == "BindableFunction" then
		newRemote = Instance.new("BindableFunction")
	else
		warn("잘못된 remoteType: " .. remoteType)
		return
	end

	newRemote.Name = name
	newRemote.Parent = parentFolder
end

-- 초기화 함수
function SetRemotes.init()
	-- RemoteStructure에 따른 리모트 생성
	if not Remotes then
		Remotes = Instance.new("Folder")
		Remotes.Name = "Remotes"
		Remotes.Parent = ReplicatedStorage
	end
	setupRemoteStructure()
end

return SetRemotes
