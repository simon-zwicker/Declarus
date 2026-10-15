
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       Tests/Core/LocalizationTests
-- Description: Tests localization registration and fallback behavior
-- ============================================================================

local Localization = _G.Declarus.Localization

-- ============================================================================
-- Title:       Tests
-- ============================================================================

local function TestCreateLocalization()
    local L = Localization.Create("TestAddon")

    assert(L ~= nil)
    assert(L.namespace == "TestAddon")
end

local function TestLocalizationInstanceReuse()
    local first = Localization.Create("TestAddonReuse")
    local second = Localization.Create("TestAddonReuse")

    assert(first == second)
end

local function TestEnglishFallback()
    local L = Localization.Create("TestEnglishFallback")

    L:Register("enUS", {
        TITLE = "Hello World",
    })

    assert(L:Get("TITLE") == "Hello World")
end

local function TestMissingKey()
    local L = Localization.Create("TestMissingKey")

    assert(L:Get("UNKNOWN_KEY") == "UNKNOWN_KEY")
end

local function TestNamespaceIsolation()
    local first = Localization.Create("TestNamespaceA")
    local second = Localization.Create("TestNamespaceB")

    first:Register("enUS", {
        TITLE = "First Addon",
    })

    second:Register("enUS", {
        TITLE = "Second Addon",
    })

    assert(first:Get("TITLE") == "First Addon")
    assert(second:Get("TITLE") == "Second Addon")
end

local function TestMultipleRegistrations()
    local L = Localization.Create("TestMultipleRegistrations")

    L:Register("enUS", {
        TITLE = "Title",
    })

    L:Register("enUS", {
        DESCRIPTION = "Description",
    })

    assert(L:Get("TITLE") == "Title")
    assert(L:Get("DESCRIPTION") == "Description")
end

---Tests translations for the active client locale.
local function TestActiveLocale()
    SetMockLocale("deDE")

    local L = Localization.Create("TestActiveLocale")

    L:Register("enUS", {
        TITLE = "Hello World",
    })

    L:Register("deDE", {
        TITLE = "Hallo Welt",
    })

    assert(L:Get("TITLE") == "Hallo Welt")

    SetMockLocale("enUS")
end

---Tests fallback when a translation is missing.
local function TestLocaleFallback()
    SetMockLocale("deDE")

    local L = Localization.Create("TestLocaleFallback")

    L:Register("enUS", {
        TITLE = "Hello World",
        DESCRIPTION = "Description",
    })

    L:Register("deDE", {
        TITLE = "Hallo Welt",
    })

    assert(L:Get("TITLE") == "Hallo Welt")
    assert(L:Get("DESCRIPTION") == "Description")

    SetMockLocale("enUS")
end

-- ============================================================================
-- Title:       Registration
-- ============================================================================

return {
    TestCreateLocalization = TestCreateLocalization,
    TestLocalizationInstanceReuse = TestLocalizationInstanceReuse,
    TestEnglishFallback = TestEnglishFallback,
    TestMissingKey = TestMissingKey,
    TestNamespaceIsolation = TestNamespaceIsolation,
    TestMultipleRegistrations = TestMultipleRegistrations,
    TestActiveLocale = TestActiveLocale,
    TestLocaleFallback = TestLocaleFallback,
}