
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       Tests/Run
-- Description: Runs Declarus tests without World of Warcraft
-- ============================================================================

-- ============================================================================
-- Title:       Required Modules
-- Description: Loads the required modules
-- ============================================================================

dofile("Core/Init.lua")
dofile("UI/Init.lua")

dofile("UI/Types/Alignment.lua")
dofile("UI/Types/Size.lua")
dofile("UI/Types/Edge.lua")
dofile("UI/Types/Color.lua")

dofile("Core/View.lua")

dofile("UI/Engine/Measure.lua")

dofile("UI/Layout/Stack.lua")
dofile("UI/Layout/HStack.lua")
dofile("UI/Layout/VStack.lua")

-- ============================================================================
-- Title:       Tests
-- Description: Executes the registered test suites
-- ============================================================================

dofile("Tests/Core/ViewTests.lua")
dofile("Tests/Core/ColorTests.lua")

dofile("Tests/Engine/MeasureTests.lua")

dofile("Tests/Layout/HStackTests.lua")
dofile("Tests/Layout/VStackTests.lua")
dofile("Tests/Layout/StackTests.lua")
