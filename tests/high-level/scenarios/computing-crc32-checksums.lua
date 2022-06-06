local scenario = Scenario:Construct("Computing CRC32-based checksums")

scenario:WHEN("I import the LibMongoose Lua module")
scenario:THEN("I should be able to compute CRC32 checksums")

function scenario:OnRun()
	self.api = import("../../LibMongoose.lua")
end

function scenario:OnEvaluate()
	-- Heavily implied: "... without segfaulting" (the actual implementation doesn't need testing here)
	assertEquals(self.api.CRC32(), nil, "Should return nil if no data is passed")
	assertEquals(self.api.CRC32(print), nil, "Should return nil if a function value is passed")
	assertEquals(self.api.CRC32(42), nil, "Should return nil if a number value is passed")
	assertEquals(self.api.CRC32("Hello World!"), 472456355, "Should be able to compute the checksum for a Lua string")
end

return scenario