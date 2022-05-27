print("Running all tests...")

local import = _G.import -- evo-luvi module loader

import("./low-level/run-low-level-tests.lua")
import("./high-level/run-high-level-tests.lua")

local RedGreenRefactor = import("../.evo/evo-lua/RedGreenRefactor/RedGreenRefactor.lua")
RedGreenRefactor:RunDemo()