local scenario = Scenario:Construct("Encoding Lua Strings with Base64")

scenario:WHEN("I import the LibMongoose Lua module")
scenario:THEN("I should be able to encode Lua strings in Base64")

function scenario:OnRun()
	self.api = import("../../LibMongoose.lua")
end

function scenario:OnEvaluate()
	-- Heavily implied: "... without segfaulting" (the actual implementation doesn't need testing here)
	assertEquals(self.api.EncodeBase64(), nil, "Should return nil if no data is passed")
	assertEquals(self.api.EncodeBase64(print), nil, "Should return nil if a function value is passed")
	assertEquals(self.api.EncodeBase64(42), nil, "Should return nil if a number value is passed")
	assertEquals(self.api.EncodeBase64("Many hands make light work."), "TWFueSBoYW5kcyBtYWtlIGxpZ2h0IHdvcmsu", "Should return a Base64 representation when encoding Lua strings")
end

return scenario