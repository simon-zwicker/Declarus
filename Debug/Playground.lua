
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       Debug/Playground
-- Description: Demonstrates Declarus rendering in World of Warcraft
-- ============================================================================

-- ============================================================================
-- Title:       Locals
-- Description: Defines dependencies
-- ============================================================================

local UI = _G.Declarus.UI

-- ============================================================================
-- Title:       Playground
-- Description: Creates a declarative test layout
-- ============================================================================

-- ============================================================================
-- Title:       Localization Playground
-- ============================================================================

local Localization = Declarus.Localization

local L = Localization.Create("DeclarusPlayground")

L:Register("enUS", {
    TITLE = "Welcome to Declarus",
    DESCRIPTION = "Declarative UI for World of Warcraft",
})

L:Register("deDE", {
    TITLE = "Willkommen bei Declarus",
    DESCRIPTION = "Deklarative UI für World of Warcraft",
})

print("Declarus Locale:", GetLocale())
print("Declarus Title:", L:Get("TITLE"))
print("Declarus Description:", L:Get("DESCRIPTION"))

local textContent = UI.VStack({
    UI.Text("Welcome to Declarus"),

    UI.Text("TITLE")
        :localize(L),

    UI.Text("This text is inside a VStack"),
})
:spacing(10)
:padding(20)

local playground = UI.VStack({
    UI.View()
        :size(300, 60)
        :backgroundColor(UI.Color.RGB(255, 0, 0)),

    UI.View()
        :size(50, 25)
        :backgroundColor(UI.Color.RGB(255, 0, 0)),

    UI.HStack({
        UI.View()
            :height(50)
            :width(UI.Size.Fill)
            :backgroundColor(UI.Color.RGB(0, 150, 255)),

        textContent
    })
    :spacing(20)
})
:spacing(10)
:padding(20)
:backgroundColor(UI.Color.RGB(0, 0, 0))

local measured = UI._Measure.Measure(playground)
local arranged = UI._Arrange.Arrange(playground, measured)

local hstack = arranged.children[3]

print("Arranged HStack:", hstack.width, hstack.height)

for index, child in ipairs(hstack.children) do
    print(
        "Arranged Blue View " .. index .. ":",
        child.width,
        child.height
    )
end

UI.Mount(playground, UIParent)