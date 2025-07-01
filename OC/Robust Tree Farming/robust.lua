local robot = require("robot")
local component = require("component")
local os = require("os")

local inv = component.inventory_controller

-- Slot config
local toolSlot = 2      -- Tool (e.g., watering can)
local seedSlot = 3      -- Seed ends up here after harvesting

-- Timing config
local toolUseDelay = 0.3
local harvestDelay = 0.5

while true do
    -- Step 1: Equip tool from slot 2
    robot.select(toolSlot)
    if inv.equip() then
        print("🛠️ Tool equipped.")
    else
        print("❌ Failed to equip tool.")
        goto continue
    end

    -- Step 2: Plant from slot 3
    robot.select(seedSlot)
    if robot.count(seedSlot) > 0 and robot.place() then
        print("✅ Seed planted.")
    else
        print("❌ No seed to plant.")
        os.sleep(1)
        goto continue
    end

    os.sleep(0.2)

    -- Step 3: Use tool 3 times
    for i = 1, 3 do
        if robot.use() then
            print("🪄 Tool use (" .. i .. ")")
        else
            print("⚠️ Tool use failed.")
        end
        os.sleep(toolUseDelay)
    end

    -- Step 4: Unequip tool back to slot 2
    robot.select(toolSlot)
    if inv.equip() then
        print("🧤 Tool unequipped.")
    else
        print("❌ Failed to unequip tool.")
        goto continue
    end

    -- Step 5: Harvest plant (bare-handed)
    os.sleep(harvestDelay)
    if robot.swing() then
        print("🌾 Plant harvested.")
    else
        print("❌ Failed to harvest plant.")
    end

    os.sleep(0.5)

    ::continue::
end
