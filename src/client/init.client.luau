local Loading = require(script.common.Loading)

Loading.modulesToInit = {
	-- 초기화할 모듈들을 추가
	script.common.Log,
	script.common.Notify,
	script.common.RoleManager,

	script.exam.ExamMain,
}

Loading.assetsToPreload = {
	-- 프리로드할 에셋 ID들을 추가
	"rbxassetid://110311495827475",
	"rbxassetid://87009047292862",
	"rbxassetid://131276410083691",
}

game.ReplicatedFirst:RemoveDefaultLoadingScreen()

Loading:init()
