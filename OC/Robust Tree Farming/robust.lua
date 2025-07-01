local robot = require("robot")
local os = require("os")

-- Slot config
local toolInventorySlot = 2 -- Tool stored in this slot
local seedSlot = 3          -- Reused seed lands here after breaking

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

    os.sleep(0.2)

    -- Step 2: Equip and use tool 3 times
    robot.select(toolInventorySlot)
    if robot.equip() then
        print("🔧 Tool equipped.")
    else
        print("❌ Failed to equip tool.")
        goto continue
    end

    for i = 1, 3 do
        if robot.use() then
            print("🪄 Used tool (" .. i .. ")")
        else
            print("⚠️ Tool use failed (" .. i .. ")")
        end
        os.sleep(toolUseDelay)
    end

    -- Optional: Unequip tool and return it to inventory
    robot.equip()  -- Swaps it back to toolInventorySlot

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
