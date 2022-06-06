local scenario = Scenario:Construct("Decoding Base64 strings")

scenario:WHEN("I import the LibMongoose Lua module")
scenario:THEN("I should be able to decode Base64 strings")

function scenario:OnRun()
	self.api = import("../../LibMongoose.lua")
end

function scenario:OnEvaluate()
	-- Heavily implied: "... without segfaulting" (the actual implementation doesn't need testing here)
	assertEquals(self.api.DecodeBase64(), nil, "Should return nil if no data is passed")
	assertEquals(self.api.DecodeBase64(print), nil, "Should return nil if a function value is passed")
	assertEquals(self.api.DecodeBase64(42), nil, "Should return nil if a number value is passed")
	assertEquals(self.api.DecodeBase64("TWFueSBoYW5kcyBtYWtlIGxpZ2h0IHdvcmsu"), "Many hands make light work.", "Should decode Base64-encoded strings correctly")
end

return scenario