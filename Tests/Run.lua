
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

---@diagnostic disable: undefined-global

dofile("Core/Init.lua")
dofile("UI/Init.lua")

dofile("UI/Types/Alignment.lua")
dofile("UI/Types/Size.lua")
dofile("UI/Types/Edge.lua")
dofile("UI/Types/Color.lua")

dofile("UI/Core/View.lua")

dofile("UI/Components/View.lua")

dofile("UI/Engine/Measure.lua")
dofile("UI/Engine/Arrange.lua")
dofile("Tests/Mocks/WoW.lua")
dofile("UI/Engine/Render.lua")

dofile("UI/Layout/Stack.lua")
dofile("UI/Layout/HStack.lua")
dofile("UI/Layout/VStack.lua")

-- ============================================================================
-- Title:       Tests
-- Description: Executes the registered test suites
-- ============================================================================

local TestRunner = dofile("Tests/TestRunner.lua")

TestRunner.RunSuite("Core/ViewTests")
TestRunner.RunSuite("Core/ColorTests")

TestRunner.RunSuite("Engine/MeasureTests")
TestRunner.RunSuite("Engine/ArrangeTests")
TestRunner.RunSuite("Engine/RenderTests")

TestRunner.RunSuite("Layout/HStackTests")
TestRunner.RunSuite("Layout/VStackTests")
TestRunner.RunSuite("Layout/StackTests")

TestRunner.Summary()
