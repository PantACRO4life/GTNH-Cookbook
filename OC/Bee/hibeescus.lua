local component = require("component")
local sides = require("sides")
local os = require("os")

local transposer = component.transposer
-- Use two separate redstone devices
local redstoneDropper = component.proxy("3df2adb6-4298-4c02-9686-f935cdc48289")
local redstoneAccelerator = component.proxy("6dc0088e-85e3-4d91-ae67-e62de5549f0e")

-- Configuration
local chestSide = sides.down        -- Chest is below transposer
local dropperSide = sides.west      -- Dropper is west of transposer
local dropperControlSide = sides.down -- Dropper is down from its redstone interface
local accelSide = sides.west        -- World accelerator is west of its redstone interface

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

      -- Pulse the dropper using its own redstone card
      redstoneDropper.setOutput(dropperControlSide, 15)
      os.sleep(0.3)
      redstoneDropper.setOutput(dropperControlSide, 0)
      print("Dropper triggered.")

      -- Turn on accelerator using its own redstone card
      redstoneAccelerator.setOutput(accelSide, 15)
      print("Accelerator ON")

      os.sleep(30) -- run the flower for full conversion time

      redstoneAccelerator.setOutput(accelSide, 0)
      print("Accelerator OFF")
    end
  else
    print("Chest is empty. Waiting...")
  end

  os.sleep(5)
end
