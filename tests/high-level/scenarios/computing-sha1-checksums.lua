local scenario = Scenario:Construct("Computing SHA1-based Checksums")

scenario:WHEN("I import the LibMongoose Lua module")
scenario:THEN("I should be able to compute SHA1 checksums")

function scenario:OnRun()
	self.api = import("../../LibMongoose.lua")
end


function scenario:OnEvaluate()
	-- Heavily implied: "... without segfaulting" (the actual implementation doesn't need testing here)
	assertEquals(self.api.SHA1(), nil, "Should return nil if no data is passed")
	assertEquals(self.api.SHA1(print), nil, "Should return nil if a function value is passed")
	assertEquals(self.api.SHA1(42), nil, "Should return nil if a number value is passed")
	assertEquals(self.api.SHA1("The quick brown fox jumps over the lazy dog"), "2fd4e1c67a2d28fced849ee1bb76e7391b93eb12" ,"Should be able to compute the checksum for a Lua string")
	assertEquals(self.api.SHA1("The quick brown fox jumps over the lazy cog"), "de9f2c7fd25e1b3afad3e85a0bd17d9b100db4b3" ,"Should be able to compute the checksum for a Lua string")
	assertEquals(self.api.SHA1(""), "da39a3ee5e6b4b0d3255bfef95601890afd80709" ,"Should be able to compute the checksum for an empty string")
end

return scenario