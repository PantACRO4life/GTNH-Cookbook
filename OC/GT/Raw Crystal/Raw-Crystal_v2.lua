local component = require("component")
local transposer = component.transposer
local sides = require("sides")
local os = require("os")
local event = require("event")
local computer = require("computer")

-- Configuration
local inputSide = sides.south     -- Raw Chips chest (source)
local outputSide = sides.west     -- Raw Parts chest (destination)
local monitorSide = sides.north   -- Monitor chest to check stock
local chipLabel = "Raw Crystal Chip"
local chipMinStock = 4096         -- Minimum stock threshold
local transferAmount = 256        -- 4 stacks (64 * 4 = 256 chips)
local sleepTime = 10

-- Exit flag
local shouldExit = false
local function onKeyUp(_, _, char, _, _)
  if char == 113 then -- 'q'
    shouldExit = true
    computer.beep(1000, 1)
    print("===== Q PRESSED: EXITING =====")
    return false
  end
end
event.listen("key_up", onKeyUp)

-- Get total number of Raw Chips in the monitor chest (north)
function getChipCount()
  local total = 0
  for slot = 1, transposer.getInventorySize(monitorSide) do
    local stack = transposer.getStackInSlot(monitorSide, slot)
    if stack and stack.label == chipLabel then
      total = total + stack.size
    end
  end
  return total
end

-- Transfer up to "amount" chips from input chest to output chest
function transferChips(amount)
  local toTransfer = amount
  for slot = 1, transposer.getInventorySize(inputSide) do
    if toTransfer <= 0 then break end
    local stack = transposer.getStackInSlot(inputSide, slot)
    if stack and stack.label == chipLabel then
      local moved = transposer.transferItem(inputSide, outputSide, toTransfer, slot)
      toTransfer = toTransfer - moved
    end
  end
  return amount - toTransfer  -- Actual transferred
end

-- Main loop
local lastTriggeredLevel = nil

while not shouldExit do
  local chipCount = getChipCount()
  print("Raw Crystal Chips in monitor chest (north): " .. chipCount)

  if lastTriggeredLevel then
    if chipCount > lastTriggeredLevel then
      print("🔁 Chip count has increased. Resetting trigger lock.")
      lastTriggeredLevel = nil
    else
      print("⏸ Waiting for stock recovery before next transfer...")
    end
  elseif chipCount < chipMinStock then
    print("⚠️ Below target! Sending " .. transferAmount .. " chip(s) from south to west chest.")
    local sent = transferChips(transferAmount)
    print("✅ Sent: " .. sent .. " chip(s).")
    lastTriggeredLevel = chipCount  -- Save current value to prevent repeating
  else
    print("✅ Stock OK. No action.")
  end

  os.sleep(sleepTime)
end

-- Cleanup
event.ignore("key_up", onKeyUp)
print("Exited safely.")
