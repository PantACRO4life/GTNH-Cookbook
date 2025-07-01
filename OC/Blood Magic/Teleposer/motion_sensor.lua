-- Creator :: PantACRO4life
local component = require("component")
local event = require("event")
local os = require("os")

--=== Configuration ===--
local freq =           -- Wireless redstone frequency
local SensorSense = 5     -- Sensitivity level of the Motion Sensor In Blocks
local OnOff = 0.5         -- Redstone ON time in seconds
--======================--

local redstone = component.redstone
local sensor = component.motion_sensor

redstone.setWirelessFrequency(freq)
sensor.setSensitivity(SensorSense)

while true do
  event.pull("motion")
  redstone.setWirelessOutput(true)
  os.sleep(OnOff)
  redstone.setWirelessOutput(false)
  os.sleep(0.5)  -- Debouncer
end
