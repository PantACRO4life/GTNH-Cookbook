local component = require("component")
local transposer = component.transposer
local sides = require("sides")
local os = require("os")
local event = require("event")
local computer = require("computer")

-- Configuration
local inputSide = sides.west     -- Raw Chips chest
local outputSide = sides.east    -- Hammer input chest
local chipLabel = "Raw Crystal Chip"
local chipMinStock = 1024
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

-- Get total number of Raw Chips in the input chest
function getChipCount()
  local total = 0
  for slot = 1, transposer.getInventorySize(inputSide) do
    local stack = transposer.getStackInSlot(inputSide, slot)
    if stack and stack.label == chipLabel then
      total = total + stack.size
    end
  end
  return total
end

-- Transfer up to "amount" chips to output chest
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
  print("Raw Crystal Chips in stock: " .. chipCount)

  if lastTriggeredLevel then
    if chipCount > lastTriggeredLevel then
      print("🔁 Chip count has increased. Resetting trigger lock.")
      lastTriggeredLevel = nil
    else
      print("⏸ Waiting for stock recovery before next transfer...")
    end
  elseif chipCount < chipMinStock and chipCount > 2 then
    local toSend = math.floor(chipCount / 2)
    print("⚠️ Below target! Sending " .. toSend .. " chip(s) to hammer chest.")
    local sent = transferChips(toSend)
    print("✅ Sent: " .. sent .. " chip(s).")
    lastTriggeredLevel = chipCount  -- Save current value to prevent repeating
  else
    print("✅ Stock OK or too low to send half. No action.")
  end

  os.sleep(sleepTime)
end

-- Cleanup
event.ignore("key_up", onKeyUp)
print("Exited safely.")
