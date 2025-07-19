local computer = require('computer')
local component = require('component')
local robot = require('robot')
local sides = require('sides')
local event = require("event")
local os = require('os')
local rs = component.redstone
local freq = 69

rs.setWirelessFrequency(freq)

-- Exit flag --
local shouldExit = false
local isMining = false

local function onKeyUp(_, _, char, _, _)
  if char == 113 then -- 'q'
    shouldExit = true
    computer.beep(1000, 1)
    print("===== Q PRESSED: EXITING =====")
    return false
  end
end
event.listen("key_up", onKeyUp)

function canMeteor()
    local charge1 = computer.energy()
    os.sleep(5)
    local charge2 = computer.energy()   
    return charge2 >= charge1 -- ✅ TRUE  if sky is visible
end

function isSucked()
    local success = robot.suck(1) -- Pick 1 item from chest in front
    os.sleep(0.5)
    return success
end

-- Main loop
while not shouldExit do
    print("Checking if sky is visible...")
    if not isMining and canMeteor() then
        print("Sky is clear, attempting to suck catalyst...")
        rs.setWirelessOutput(false)
        if isSucked() then
            print("Catalyst received. Preparing to spawn meteor...")

            -- Wait until sky is visible (old meteor gone)
            while not canMeteor() do
                print("Waiting for sky to clear...")
                os.sleep(1)
            end

            robot.useDown() -- Awakened Activation Crystal
            os.sleep(0.5)
            robot.dropDown() -- Drop Catalyst item.

            -- Wait until sky is blocked again (meteor is there)
            print("Waiting for meteor to land...")
            while canMeteor() do
                os.sleep(1)
            end

            -- Activate miners
            print("Meteor landed. Activating miners.")
            rs.setWirelessOutput(true)
            os.sleep(15)
            isMining = true
        else
            print("No catalyst item in chest. Waiting...")
            os.sleep(2)
        end

    elseif isMining then
        if not canMeteor() then
            -- Still mining
            print("Still mining...")
        else
            -- Mining complete
            print("Sky became visible again. Mining almost done...")
            os.sleep(15)
            print("Mining finished. Deactivating miners.")
            rs.setWirelessOutput(false)
            isMining = false
        end
    end
end

-- Cleanup
event.ignore("key_up", onKeyUp)
print("Exited safely.")