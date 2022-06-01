local testSuite = TestSuite:Construct("Low-Level C Bindings")

local listOfScenarioFilesToLoad = {
	"./scenarios/accessing-c-functions.lua"
}

testSuite:AddScenarios(listOfScenarioFilesToLoad)

-- function testSuite:TestLowLevelBindings()
-- 	print("TEST\tmongoose.lua (low-level bindings)")

-- 	self:TestEventConstantsAreExported()
-- 	self:TestLowLevelApiSurface()

-- 	print("OK\tmongoose.lua (low-level bindings)\n")
-- end

return testSuite