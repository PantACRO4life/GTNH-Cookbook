local component = require("component")
local sides = require("sides")
local os = require("os")
local event = require("event")

local transposer = component.transposer
local redstone = component.redstone
local computer = component.computer

-- Redstone + transposer config
local chestSide = sides.down           -- Chest is below transposer
local dropperSide = sides.west         -- Dropper is west of transposer
local dropperControlSide = sides.down  -- Redstone to dropper (down of computer)
local accelSide = sides.west           -- Redstone to world accelerator (west of computer)

-- Exit flag
local shouldExit = false

-- Keyboard event to quit on 'q'
local function onKeyUp(_, _, char, _, _)
  if char == 113 then -- 'q'
    shouldExit = true
    computer.beep(1000, 1)
    print("===== Q PRESSED: EXITING =====")
    return false -- auto-unregisters this listener
  end
end

-- Register event listener
event.listen("key_up", onKeyUp)

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
while not shouldExit do
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

-- Cleanup
event.ignore("key_up", onKeyUp)
print("Exited safely.")
