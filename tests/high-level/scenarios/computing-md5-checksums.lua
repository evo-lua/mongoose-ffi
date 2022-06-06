local scenario = Scenario:Construct("Computing MD5-based checksums")

scenario:WHEN("I import the LibMongoose Lua module")
scenario:THEN("I should be able to compute MD5 checksums")

function scenario:OnRun()
	self.api = import("../../LibMongoose.lua")
end


function scenario:OnEvaluate()
	-- Heavily implied: "... without segfaulting" (the actual implementation doesn't need testing here)
	assertEquals(self.api.MD5(), nil, "Should return nil if no data is passed")
	assertEquals(self.api.MD5(print), nil, "Should return nil if a function value is passed")
	assertEquals(self.api.MD5(42), nil, "Should return nil if a number value is passed")
	assertEquals(self.api.MD5("The quick brown fox jumps over the lazy dog"), "9e107d9d372bb6826bd81d3542a419d6" ,"Should be able to compute the checksum for a Lua string")
	assertEquals(self.api.MD5("The quick brown fox jumps over the lazy dog."), "e4d909c290d0fb1ca068ffaddf22cbd0" ,"Should be able to compute the checksum for a Lua string")
	assertEquals(self.api.MD5(""), "d41d8cd98f00b204e9800998ecf8427e" ,"Should be able to compute the checksum for an empty string")
end

return scenario