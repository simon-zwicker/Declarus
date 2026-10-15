
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

        UI.View()
            :height(50)
            :width(UI.Size.Fill)
            :backgroundColor(UI.Color.RGB(0, 150, 255)),
    })
    :spacing(20)
})
:spacing(10)
:padding(20)
:backgroundColor(UI.Color.RGB(0, 0, 0))

UI.Mount(playground, UIParent)