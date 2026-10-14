
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       Tests/TestRunner
-- Description: Executes test suites and reports their results.
-- ============================================================================

-- ============================================================================
-- Title:       Locals
-- Description: Defines terminal colors and test statistics.
-- ============================================================================

local RESET = "\27[0m"
local GREEN = "\27[32m"
local RED = "\27[31m"
local CYAN = "\27[36m"

local TestRunner = {}

local passed = 0
local failed = 0
local passedSuites = 0
local totalSuites = 0

-- ============================================================================
-- Title:       Implementation
-- Description: Executes tests and prints their results.
-- ============================================================================

---@param path string
function TestRunner.RunSuite(path)
    local name = path:match("([^/]+)$")
    local filePath = "Tests/" .. path .. ".lua"

    totalSuites = totalSuites + 1

    print()
    print(CYAN .. "--------------- Declarus " .. name .. " ---------------" .. RESET)

    local success, tests = pcall(dofile, filePath)

    if not success then
        failed = failed + 1
        print(RED .. "✗ Failed to load suite: " .. tostring(tests) .. RESET)
        return
    end

    if type(tests) ~= "table" then
        failed = failed + 1
        print(RED .. "✗ Suite must return a table of tests" .. RESET)
        return
    end

    local names = {}

    for testName, callback in pairs(tests) do
        if type(callback) == "function" and testName:match("^Test") then
            names[#names + 1] = testName
        end
    end

    table.sort(names)

    local suiteFailed = false

    for _, testName in ipairs(names) do
        local successTest, err = pcall(tests[testName])

        if successTest then
            passed = passed + 1

            print(
                "Declarus " .. name .. " - " .. testName .. ": "
                .. GREEN .. "✓ passed" .. RESET
            )
        else
            failed = failed + 1
            suiteFailed = true

            print(
                "Declarus " .. name .. " - " .. testName .. ": "
                .. RED .. "✗ failed" .. RESET
            )

            print(RED .. tostring(err) .. RESET)
        end
    end

    if not suiteFailed then
        passedSuites = passedSuites + 1
        print(GREEN .. "✓ All Tests passed" .. RESET)
    end
end

function TestRunner.Summary()
    print()
    print(CYAN .. "══════════════════════════════════════════════" .. RESET)
    print("  DECLARUS TEST RESULTS")
    print()
    print("  Test Suites:  " .. passedSuites .. "/" .. totalSuites)
    print("  Passed:       " .. GREEN .. passed .. RESET)
    print("  Failed:       " .. RED .. failed .. RESET)
    print()

    if failed == 0 then
        print(GREEN .. "  ✓ All tests passed successfully" .. RESET)
    else
        print(RED .. "  ✗ Some tests failed" .. RESET)
    end

    print(CYAN .. "══════════════════════════════════════════════" .. RESET)

    if failed > 0 then
        os.exit(1)
    end
end

-- ============================================================================
-- Title:       Return
-- Description: Exposes the test runner.
-- ============================================================================

return TestRunner