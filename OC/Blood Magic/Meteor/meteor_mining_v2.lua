local computer = require('computer')
local component = require('component')
local robot = require('robot')
local sides = require('sides')
local event = require("event")
local os = require('os')

-- Redstone card proxies
local rs_ae2 = component.proxy("25ea17f0-77e1-4c3c-b015-ae3a8d22bd99")
local rs_miner = component.proxy("7049c34c-a619-409b-b666-2fbbe7189874")

local freq = 69
local ae2_freq = 68

rs_ae2.setWirelessFrequency(ae2_freq)
rs_miner.setWirelessFrequency(freq)

local function canMeteor()
    local charge1 = computer.energy()
    os.sleep(5)
    local charge2 = computer.energy()   
    return charge2 >= charge1 -- ✅ TRUE  if sky is visible
end

local function isSucked()
    local success = robot.suck(1) -- Pick 1 item from chest in front
    os.sleep(0.5)
    return success
end

local function waitForAE2()
    print("Checking AE2 network availability...")
    while not rs_ae2.getWirelessInput() do
        print("AE2 network not available. Waiting...")
        rs_miner.setWirelessOutput(false)
        os.sleep(2)
    end
    print("AE2 available! Proceeding...")
    print("Proceeding with miner activation.")
    rs_miner.setWirelessOutput(true)
end

local function onKeyUp(_, _, char, _, _)
  if char == 113 then -- 'q'
    shouldExit = true
    computer.beep(1000, 1)
    print("===== Q PRESSED: EXITING =====")
    return false
  end
end

local shouldExit = false
local isMining = false

-- On startup, if sky is not visible, resume mining the current meteor
if not canMeteor() then
    print("Meteor detected on startup. Resuming mining...")
    isMining = true
end

event.listen("key_up", onKeyUp)

-- Main loop
while not shouldExit do
    print("Checking if sky is visible...")
    if not isMining and canMeteor() then
        print("Sky is clear, attempting to suck catalyst...")
        rs_miner.setWirelessOutput(false)
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
            waitForAE2()
            isMining = true
        else
            print("No catalyst item in chest. Waiting...")
            os.sleep(2)
        end

    elseif isMining then
        waitForAE2()
        if not canMeteor() then
            -- Still mining
            print("Still mining...")
        else
            -- Mining complete
            print("Sky became visible again. Mining almost done...")
            os.sleep(15)
            print("Mining finished. Deactivating miners.")
            rs_miner.setWirelessOutput(false)
            isMining = false
        end
    end
end

-- Cleanup
event.ignore("key_up", onKeyUp)
print("Exited safely.")