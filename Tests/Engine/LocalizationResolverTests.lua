
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       Tests/Engine/LocalizationResolverTests
-- Description: Tests localized text resolution
-- ============================================================================

local UI = _G.Declarus.UI
local Localization = _G.Declarus.Localization
local Resolver = UI._LocalizationResolver

-- ============================================================================
-- Title:       Tests
-- ============================================================================

local function TestResolveWithoutLocalization()
    assert(Resolver.Resolve("Hello World") == "Hello World")
end

local function TestResolveWithLocalization()
    local L = Localization.Create("TestResolver")

    L:Register("enUS", {
        TITLE = "Welcome to Declarus",
    })

    SetMockLocale("enUS")

    assert(Resolver.Resolve("TITLE", L) == "Welcome to Declarus")
end

-- ============================================================================
-- Title:       Registration
-- ============================================================================

return {
    TestResolveWithoutLocalization = TestResolveWithoutLocalization,
    TestResolveWithLocalization = TestResolveWithLocalization,
}