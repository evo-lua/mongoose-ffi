local TestSuite = import("./TestSuite.lua")
local Scenario = import("./Scenario.lua")

local RedGreenRefactor = {}

function RedGreenRefactor:RunDemo()
	local testSuite = TestSuite:Construct("Basic demonstration")
	local scenario = Scenario:Construct("Testing the framework")

	scenario:GIVEN(
		"I have established the pre-conditions",
		function()
			-- There are none, in this case
		end
	)

	scenario:WHEN(
		"I run the test code",
		function()
			self.someValue = 42
		end
	)

	scenario:THEN(
		"The post-conditions hold true",
		function()
			assert(self.someValue == 42, "Some value is set correctly")
		end
	)

	testSuite:AddScenario(scenario)
	testSuite:RunAllScenarios()
end

RedGreenRefactor.TestSuite = TestSuite
RedGreenRefactor.Scenario = Scenario

return RedGreenRefactor
