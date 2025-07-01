local robot = require("robot")
local component = require("component")
local sides = require("sides")
local os = require("os")

local inv = component.inventory_controller

-- Configuration
local toolName = "Hoe of Growth"
local seedName = "Infused Seeds"
local maxAllowedDamage = 1400
local dropQty = 64
local toolSlot = 2           -- Reserved inventory slot for the tool
local toolUseCount = 3
local toolUseDelay = 0.3

-- Helper: equip tool from slot 2
function equipTool()
    robot.select(toolSlot)
    return inv.equip()
end

-- Helper: unequip tool to slot 2
function unequipTool()
    robot.select(toolSlot)
    return inv.equip()
end

-- Ensure tool is equipped at startup
function ensureToolEquipped()
    -- Try to equip from toolSlot only if something is there
    local item = inv.getStackInInternalSlot(toolSlot)
    if item and item.label == toolName then
        print("🧤 Equipping tool at startup...")
        equipTool()
    end
end

-- Check tool durability, returns true to continue, false to stop
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

-- Drop any item that isn't the seed or the tool
function dumpItems()
    for slot = 1, 16 do
        local item = inv.getStackInInternalSlot(slot)
        if item and item.label ~= seedName and item.label ~= toolName then
            robot.select(slot)
            if robot.drop(dropQty) then
                print("📦 Dropped " .. item.label)
            else
                print("❌ Failed to drop " .. item.label)
            end
        end
    end
end

-- Find the slot that has the seed
function findSeedSlot()
    for slot = 1, 16 do
        local item = inv.getStackInInternalSlot(slot)
        if item and item.label == seedName then
            return slot
        end
    end
    return nil
end

-- 🪴 Main Execution
ensureToolEquipped() -- make sure tool is in hand before starting

while true do
    if not checkToolDurability() then
        break
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

    -- Step 2: Use tool 3 times
    for i = 1, toolUseCount do
        robot.useDown()
        print("🪄 Tool use (" .. i .. ")")
        os.sleep(toolUseDelay)
    end

    -- Step 3: Harvest
    if robot.swingDown() then
        print("🌾 Plant harvested.")
    else
        print("❌ Failed to harvest.")
    end

    os.sleep(0.2)

    -- Step 4: Drop all non-essential items
    dumpItems()

    os.sleep(0.5)

    ::continue::
end
