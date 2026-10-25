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
dofile("Tests/Mocks/Client.lua")

-- Load exactly the production TOC order, including the opt-in debug command.
for line in io.lines("Declarus.toc") do
    local path = line:match("^%s*([^#].-%.lua)%s*$")
    if path then dofile((path:gsub("\\", "/"))) end
end

-- ============================================================================
-- Title:       Tests
-- Description: Executes the registered test suites
-- ============================================================================

local parent = UIParent
---@cast parent DeclarusMockFrame
assert(#parent.children == 1, "Loading Declarus must not mount the demo")

local TestRunner = dofile("Tests/TestRunner.lua")

-- Core
TestRunner.RunSuite("Core/LocalizationTests")
TestRunner.RunSuite("Core/ClientTests")

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

TestRunner.RunSuite("Engine/BasicsTests")
TestRunner.RunSuite("Engine/TextureTests")

TestRunner.RunSuite("Engine/ControlTests")

TestRunner.RunSuite("Engine/MountTests")

TestRunner.RunSuite("Core/PlaygroundTests")

TestRunner.Summary()