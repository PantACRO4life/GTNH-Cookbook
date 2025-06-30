local component = require("component")
local sides = require("sides")
local os = require("os")

local transposer = component.transposer
local redstone = component.redstone

-- Configuration
local chestSide = sides.down        -- Chest is below transposer
local dropperSide = sides.west      -- Dropper is west of transposer
local dropperControlSide = sides.west -- Redstone output to dropper (west of computer)
local accelSide = sides.west        -- Redstone output to world accelerator (west of computer)

-- Utility: find any princess
local function findPrincess()
  local inv = transposer.getAllStacks(chestSide)
  for i = 1, #inv do
    local stack = inv[i]
    if stack and stack.label and stack.label:find("Princess") then
      return i
    end
  end
  return nil
end

-- Main loop
while true do
  local slot = findPrincess()
  if slot then
    print("Found Princess in chest slot: " .. slot)

    -- Move it into the dropper
    local moved = transposer.transferItem(chestSide, dropperSide, 1, slot)
    if moved and moved > 0 then
      print("Moved princess to dropper.")

      -- Pulse dropper
      redstone.setOutput(dropperControlSide, 15)
      os.sleep(0.3)
      redstone.setOutput(dropperControlSide, 0)
      print("Dropper pulsed.")

      -- Turn on world accelerator
      redstone.setOutput(accelSide, 15)
      print("Accelerator ON")

      os.sleep(30)

      -- Turn off accelerator
      redstone.setOutput(accelSide, 0)
      print("Accelerator OFF")
    end
  else
    print("No princess found in chest.")
  end

  os.sleep(5)
end
