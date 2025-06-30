local component = require("component")
local sides = require("sides")
local os = require("os")

local transposer = component.transposer
local redstone = component.redstone

-- Configuration
local chestSide = sides.down           -- Chest is below transposer
local dropperSide = sides.west         -- Dropper is west of transposer
local dropperControlSide = sides.down  -- Redstone to dropper (down of computer)
local accelSide = sides.west           -- Redstone to world accelerator (west of computer)

-- Check if chest has at least one item
local function chestHasItem()
  local size = transposer.getInventorySize(chestSide)
  for slot = 1, size do
    local stack = transposer.getStackInSlot(chestSide, slot)
    if stack then
      return slot
    end
  end
  return nil
end

-- Main loop
while true do
  local slot = chestHasItem()
  if slot then
    print("Bee found in chest slot " .. slot .. ", starting conversion.")

    local moved = transposer.transferItem(chestSide, dropperSide, 1, slot)
    if moved and moved > 0 then
      print("Moved to dropper.")

      redstone.setOutput(dropperControlSide, 15)
      os.sleep(0.5)
      redstone.setOutput(dropperControlSide, 0)
      print("Dropped.")

      redstone.setOutput(accelSide, 15)
      print("Accelerator ON")
      os.sleep(30)
      redstone.setOutput(accelSide, 0)
      print("Accelerator OFF")
    end
  else
    print("Chest is empty, waiting...")
  end
  os.sleep(0.5)
end
