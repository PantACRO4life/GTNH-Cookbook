local robot = require("robot")
local os = require("os")

-- Slot config
local toolSlot = 2
local seedSlot = 3 -- reused seed lands here after breaking

-- Timing
local toolUseDelay = 0.3
local harvestDelay = 0.5

while true do
    -- Step 1: Plant seed from slot 3
    robot.select(seedSlot)
    if robot.count(seedSlot) > 0 and robot.place() then
        print("✅ Seed planted.")
    else
        print("❌ Failed to plant. No seed?")
        os.sleep(1)
        goto continue
    end

    -- Step 2: Use tool 3 times to fully grow plant
    robot.select(toolSlot)
    for i = 1, 3 do
        if robot.use() then
            print("🔧 Used tool (" .. i .. ")")
        else
            print("⚠️ Tool use failed (" .. i .. ")")
        end
        os.sleep(toolUseDelay)
    end

    -- Step 3: Break fully grown plant
    os.sleep(harvestDelay)
    if robot.swing() then
        print("🌾 Plant harvested.")
    else
        print("❌ Failed to harvest.")
    end

    os.sleep(0.5)

    ::continue::
end
