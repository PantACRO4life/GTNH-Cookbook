local robot = require("robot")
local component = require("component")
local sides = require("sides")
local os = require("os")

local inv = component.inventory_controller

-- Configuration
local toolName = "Hoe of Growth"
local seedName = "Infused Seeds"
local maxAllowedDamage = 1400
local chestSide = sides.front -- Chest is in front of robot
local toolUseCount = 3
local toolUseDelay = 0.3

-- Helper: check if slot contains the tool
function isTool(slot)
    local item = inv.getStackInInternalSlot(slot)
    return item and item.label == toolName
end

-- Helper: check if slot contains the seed
function isSeed(slot)
    local item = inv.getStackInInternalSlot(slot)
    return item and item.label == seedName
end

-- Helper: check tool durability and stop if it's low
function checkToolDurability()
    for slot = 1, 16 do
        local item = inv.getStackInInternalSlot(slot)
        if item and item.label == toolName and item.damage and item.maxDamage then
            print("🛠 Tool durability: " .. item.damage .. "/" .. item.maxDamage)
            if item.damage >= maxAllowedDamage then
                print("⚠️ Tool is too damaged. Stopping program.")
                os.exit()
            end
        end
    end
end

-- Helper: drop non-seed, non-tool items into chest
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

-- Helper: find seed slot
function findSeedSlot()
    for slot = 1, 16 do
        if isSeed(slot) then
            return slot
        end
    end
    return nil
end

-- Main loop
while true do
    checkToolDurability()

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

    -- Step 2: Use the tool 3 times to grow
    for i = 1, toolUseCount do
        if robot.useDown() then
            print("🪄 Used tool on plant (" .. i .. ")")
        else
            print("⚠️ Tool use failed (" .. i .. ")")
        end
        os.sleep(toolUseDelay)
    end

    -- Step 3: Harvest plant (tool must be equipped manually)
    if robot.swingDown() then
        print("🌾 Plant harvested.")
    else
        print("❌ Failed to harvest plant.")
    end

    os.sleep(0.2)

    -- Step 4: Dump other items to chest
    dumpItems()

    os.sleep(0.5)

    ::continue::
end
