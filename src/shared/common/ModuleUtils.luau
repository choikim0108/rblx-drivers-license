local ModuleUtils = {}

-- 테이블 깊은 복사 함수
function ModuleUtils.deepCopy(t)
	local copy = {}
	for key, value in pairs(t) do
		if type(value) == "table" then
			copy[key] = ModuleUtils.deepCopy(value)
		else
			copy[key] = value
		end
	end
	return copy
end

-- 테이블 내용 비교 함수
function ModuleUtils.areTablesEqual(t1, t2)
	if #t1 ~= #t2 then
		return false
	end

	for i = 1, #t1 do
		if t1[i].name ~= t2[i].name or t1[i].score ~= t2[i].score then
			return false
		end
	end

	return true
end

-- 자식모듈 초기화 함수
function ModuleUtils.initModules(modulesToInit, player)
	for _, module in ipairs(modulesToInit) do
		local moduleInstance = require(module)
		-- init 함수 존재 확인
		if typeof(moduleInstance.init) == "function" then
			if player then
				-- 메서드(:) 와 함수(.) 호출 방식 모두 지원, player 인자 존재 시 호출
				if getmetatable(moduleInstance) then
					moduleInstance:init(player)
				else
					moduleInstance.init(player)
				end
			else
				if getmetatable(moduleInstance) then
					moduleInstance:init()
				else
					moduleInstance.init()
				end
			end
		end
	end
end

return ModuleUtils
