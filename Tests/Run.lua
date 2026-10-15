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

-- ============================================================================
-- Title:       Mocks
-- ============================================================================

dofile("Tests/Mocks/WoW.lua")

-- ============================================================================
-- Title:       Core
-- ============================================================================

dofile("Core/Init.lua")
dofile("Core/Localization.lua")

-- ============================================================================
-- Title:       UI
-- ============================================================================

dofile("UI/Init.lua")

-- ============================================================================
-- Title:       Types
-- ============================================================================

dofile("UI/Types/Alignment.lua")
dofile("UI/Types/Size.lua")
dofile("UI/Types/Edge.lua")
dofile("UI/Types/Color.lua")

-- ============================================================================
-- Title:       View Foundations
-- ============================================================================

dofile("UI/Core/View.lua")
dofile("UI/Core/TextView.lua")

-- ============================================================================
-- Title:       Resolvers
-- ============================================================================

dofile("UI/Engine/LocalizationResolver.lua")

-- ============================================================================
-- Title:       Components
-- ============================================================================

dofile("UI/Components/View.lua")
dofile("UI/Components/Text.lua")

-- ============================================================================
-- Title:       Typography
-- ============================================================================

dofile("UI/Typography/TextMeasure.lua")

-- ============================================================================
-- Title:       Layout
-- ============================================================================

dofile("UI/Layout/Stack.lua")
dofile("UI/Layout/HStack.lua")
dofile("UI/Layout/VStack.lua")

-- ============================================================================
-- Title:       Engine
-- ============================================================================

dofile("UI/Engine/Measure.lua")
dofile("UI/Engine/Arrange.lua")
dofile("UI/Engine/Render.lua")

-- ============================================================================
-- Title:       Tests
-- Description: Executes the registered test suites
-- ============================================================================

local TestRunner = dofile("Tests/TestRunner.lua")

-- Core
TestRunner.RunSuite("Core/LocalizationTests")

-- Types
TestRunner.RunSuite("Types/ViewTests")
TestRunner.RunSuite("Types/TextViewTests")
TestRunner.RunSuite("Types/ColorTests")

-- Components
TestRunner.RunSuite("Components/TextTests")

-- Typography
TestRunner.RunSuite("Typography/TextMeasureTests")

-- Resolvers
TestRunner.RunSuite("Engine/LocalizationResolverTests")

-- Engine
TestRunner.RunSuite("Engine/MeasureTests")
TestRunner.RunSuite("Engine/ArrangeTests")
TestRunner.RunSuite("Engine/RenderTests")

-- Layout
TestRunner.RunSuite("Layout/HStackTests")
TestRunner.RunSuite("Layout/VStackTests")
TestRunner.RunSuite("Layout/StackTests")

-- ============================================================================
-- Title:       Summary
-- ============================================================================

TestRunner.Summary()