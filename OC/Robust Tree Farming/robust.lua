local robot = require("robot")
local component = require("component")
local sides = require("sides")
local os = require("os")

local inv = component.inventory_controller

-- Configuration
local toolName = "Hoe of Growth"
local seedName = "Infused Seeds"
local maxAllowedDamage = 1400
local chestSide = sides.front
local toolSlot = 2           -- Reserved inventory slot for the tool
local toolUseCount = 3
local toolUseDelay = 0.3

-- Helper: equip tool
function equipTool()
    robot.select(toolSlot)
    return inv.equip()
end

-- Helper: unequip tool
function unequipTool()
    robot.select(toolSlot)
    return inv.equip()
end

-- Helper: check tool durability, return true if OK, false if too damaged
function checkToolDurability()
    unequipTool()
    local item = inv.getStackInInternalSlot(toolSlot)
    if item and item.label == toolName and item.damage and item.maxDamage then
        print("🛠 Tool durability: " .. item.damage .. "/" .. item.maxDamage)
        if item.damage >= maxAllowedDamage then
            print("⚠️ Tool too damaged. Stopping.")
            return false
        end
    else
        print("❌ Could not read tool durability.")
        return false
    end
    equipTool()
    return true
end

-- Helper: drop unwanted items
function dumpItems()
    for slot = 1, 16 do
        local item = inv.getStackInInternalSlot(slot)
        if item then
            if item.label ~= seedName and item.label ~= toolName then
                robot.select(slot)
                if robot.drop(chestSide) then
                    print("📦 Dropped " .. item.label)
                else
                    print("❌ Failed to drop " .. item.label)
                end
            end
        end
    end
end

-- Helper: find the seed slot
function findSeedSlot()
    for slot = 1, 16 do
        local item = inv.getStackInInternalSlot(slot)
        if item and item.label == seedName then
            return slot
        end
    end
    return nil
end

-- 🪴 Main Loop
while true do
    if not checkToolDurability() then
        break -- stop program
    end

    -- Step 1: Find and plant seed
    local seedSlot = findSeedSlot()
    if not seedSlot then
        print("❌ No Infused Seeds found. Waiting...")
        os.sleep(2)
        goto continue
    end

    robot.select(seedSlot)
    if robot.placeDown() then
        print("🌱 Seed planted.")
    else
        print("❌ Failed to plant seed.")
        os.sleep(1)
        goto continue
    end

    -- Step 2: Use the tool 3 times
    for i = 1, toolUseCount do
        if robot.useDown() then
            print("🪄 Tool use (" .. i .. ")")
        end
        os.sleep(toolUseDelay)
    end

    -- Step 3: Harvest
    if robot.swingDown() then
        print("🌾 Plant harvested.")
    else
        print("❌ Failed to harvest.")
    end

    os.sleep(0.2)

    -- Step 4: Drop all other items
    dumpItems()

    os.sleep(0.5)

    ::continue::
end
