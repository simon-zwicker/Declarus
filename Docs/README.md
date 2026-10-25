# Declarus documentation

This is the guide to what Declarus can do right now. Each topic shows how to use
the API, what you get from it and where the current limits are.

We use one codebase for current official Blizzard clients. No private servers and
no old original clients.

## Pick a topic

| Guide | Use it for |
| --- | --- |
| [Getting started](GettingStarted.md) | Loading Declarus and building your first UI |
| [Views and modifiers](ViewsAndModifiers.md) | Common styling and sizing options |
| [Layout](Layout.md) | Arranging elements and understanding their sizes |
| [Text and localization](TextAndLocalization.md) | Fonts, text measurement and translations |
| [Controls](Controls.md) | User input and callbacks |
| [Textures](Textures.md) | Icons, image cropping, tint and draw order |
| [Gradients](Gradients.md) | Color transitions on surfaces and images |
| [ScrollView](ScrollView.md) | Content that needs more vertical space |
| [State and lifecycle](StateAndLifecycle.md) | Updating and closing a UI correctly |
| [Recipes](Recipes.md) | Putting the pieces together |
| [API reference](API.md) | Looking up a function or modifier |
| [Troubleshooting](Troubleshooting.md) | Finding the cause of a problem |
| [Development](Development.md) | Working on the library |
| [Playground](Playground.md) | Testing the features in game |
| [Client compatibility](ClientCompatibility.md) | Checking the supported targets and test status |

## How to read the examples

Lua examples run inside a WoW addon after Declarus has loaded. They are not plain
Lua programs you can run without WoW or the project's mocks.

Examples use this shortcut:

```lua
local UI = Declarus.UI
```

Calling a constructor only builds a description. To see it, mount it:

```lua
local UI = Declarus.UI
local view = UI.Text("This is a view description.")
local handle = UI.Mount(view, UIParent)
```

**Result:** The text appears centered on UIParent. The handle belongs to that
mounted UI and can update or remove it later.

Examples on the same page are independent unless a paragraph explicitly says
that the next block continues the previous one. A block that only creates a view
is showing its configuration; it does not display anything until mounted.

The **Result** below an example describes the expected behavior. Exact text sizes
depend on the client font and language. Geometry examples using plain views can
give exact dimensions.

## The main rules

Modifiers change the same view object and return it for chaining. They do not
create copies. Changes are not automatically pushed to an existing mount.

Use stacks for children, a ScrollView for vertical overflow, and explicit mount
updates when the data changes. Keep application state outside the rendered tree.
Declarus does not save settings for you.
