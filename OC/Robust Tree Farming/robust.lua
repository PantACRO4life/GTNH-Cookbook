local robot = require("robot")
local os = require("os")

-- Indexes for seed and tool in inventory
local seedSlot = 1
local toolSlot = 2

-- Time between tool uses (seconds)
local useDelay = 0.5
-- Time to wait before breaking plant (if needed)
local growTime = 1.0

while true do
    -- Step 1: Select seed and place it
    robot.select(seedSlot)
    if robot.place() then
        print("Seed planted.")
    else
        print("Failed to plant seed.")
        os.sleep(1)
        goto continue
    end

    -- Step 2: Click with tool 3 times
    robot.select(toolSlot)
    for i = 1, 3 do
        if robot.use() then
            print("Used tool on plant (" .. i .. ")")
        else
            print("Tool use failed.")
        end
        os.sleep(useDelay)
    end

    -- Optional wait before breaking the plant (in case it's not immediately harvestable)
    os.sleep(growTime)

    -- Step 3: Break plant
    if robot.swing() then
        print("Plant harvested.")
    else
        print("Failed to break plant.")
    end

    -- Step 4: Wait or loop
    os.sleep(0.5)

    ::continue::
end
