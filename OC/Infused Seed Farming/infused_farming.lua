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
local toolSlot = 2
local toolUseCount = 3
local toolUseDelay = 0.3

-- Equip tool from slot 2
function equipTool()
    robot.select(toolSlot)
    return inv.equip()
end

-- Unequip tool to slot 2
function unequipTool()
    robot.select(toolSlot)
    return inv.equip()
end

-- Auto-equip tool at startup if present
function ensureToolEquipped()
    local item = inv.getStackInInternalSlot(toolSlot)
    if item and item.label == toolName then
        print("🧤 Equipping tool at startup...")
        equipTool()
    end
end

-- Waits until a repaired tool is pulled with robot.suckUp()
function waitForReplacementTool()
    print("🔁 Waiting for a repaired tool from chest above...")
    while true do
        robot.select(toolSlot)
        local sucked = robot.suckUp()

        if sucked then
            local item = inv.getStackInInternalSlot(toolSlot)
            if item and item.label == toolName and item.damage and item.damage < maxAllowedDamage then
                print("✅ Repaired tool acquired.")
                inv.equip()
                return
            else
                -- Not the right tool or too damaged — drop it back
                print("❌ Invalid or damaged tool. Dropping it back.")
                robot.drop()
            end
        end

        os.sleep(0.5)
    end
end

-- Check tool durability, and swap when needed
function checkToolDurability()
    unequipTool()
    local item = inv.getStackInInternalSlot(toolSlot)
    if item and item.label == toolName and item.damage and item.maxDamage then
        print("🛠 Tool durability: " .. item.damage .. "/" .. item.maxDamage)
        if item.damage >= maxAllowedDamage then
            print("⚠️ Tool too damaged. Exchanging...")
            robot.select(toolSlot)
            if robot.drop() then
                print("📤 Dropped damaged tool into chest.")
                waitForReplacementTool()
                return true
            else
                print("❌ Failed to drop damaged tool.")
                return false
            end
        end
    else
        print("❌ Could not read tool durability.")
        return false
    end
    equipTool()
    return true
end


-- Drop non-seed/non-tool items
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

-- Find seed slot
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
ensureToolEquipped()

while true do
    if not checkToolDurability() then
        os.sleep(5)
        goto continue
    end

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

    for i = 1, toolUseCount do
        robot.useDown()
        print("🪄 Tool use (" .. i .. ")")
        os.sleep(toolUseDelay)
    end

    if robot.swingDown() then
        print("🌾 Plant harvested.")
    else
        print("❌ Failed to harvest.")
    end

    os.sleep(0.2)
    dumpItems()
    os.sleep(0.5)

    ::continue::
end
