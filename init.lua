-- Global variables for the event taps
local cmdToCtrlTap = nil
local ctrlToCtrlOptTap = nil
local watchdog = nil

-- List of terminal applications where Command should act as Control
local terminalApps = {
	"Ghostty",
	"Alacritty",
	"iTerm2",
	"Kitty",
	"Terminal", -- Adding macOS Terminal just in case
}

-- Function to check if an app is in our list of terminal apps
local function isTerminalApp(appName)
	for _, app in ipairs(terminalApps) do
		if appName == app then
			return true
		end
	end
	return false
end

-- Function to remap Command to Control when in terminal apps
local function remapCommandToControl(e)
	local app = hs.application.frontmostApplication()
	if app and isTerminalApp(app:name()) then
		local flags = e:getFlags()
		if flags.cmd then
			-- Remove the Command modifier and add the Control modifier
			flags.cmd = false
			flags.ctrl = true
			e:setFlags(flags)
		end
	end
	return false
end

-- Function to add Option modifier to Control key GLOBALLY
local function addOptionToControl(e)
	local flags = e:getFlags()
	if flags.ctrl and not flags.alt then
		-- Add Option modifier to Control key presses
		flags.alt = true
		e:setFlags(flags)
	end
	return false
end

-- Function to check and restore the event taps if they've stopped
local function checkTapStatus()
	if not cmdToCtrlTap:isEnabled() then
		print("Command-to-Control remap disabled, restarting...")
		cmdToCtrlTap:start()
	end

	if not ctrlToCtrlOptTap:isEnabled() then
		print("Control-to-ControlOption remap disabled, restarting...")
		ctrlToCtrlOptTap:start()
	end
end

-- Function to initialize all the event taps
local function setupEventTaps()
	-- Stop existing taps if they exist
	if cmdToCtrlTap then
		cmdToCtrlTap:stop()
	end
	if ctrlToCtrlOptTap then
		ctrlToCtrlOptTap:stop()
	end
	if watchdog then
		watchdog:stop()
	end

	-- Create new event taps
	-- First tap: Command -> Control in terminal apps only
	cmdToCtrlTap =
		hs.eventtap.new({ hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp }, remapCommandToControl)

	-- Second tap: Control -> Control+Option GLOBALLY
	ctrlToCtrlOptTap =
		hs.eventtap.new({ hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp }, addOptionToControl)

	-- Start the event taps
	cmdToCtrlTap:start()
	ctrlToCtrlOptTap:start()

	-- Create and start the watchdog timer (check every 15 seconds)
	watchdog = hs.timer.new(15, checkTapStatus, true)
	watchdog:start()

	print("Keyboard remapping setup complete")
end

-- Application observer to handle application switching
local function applicationObserver(appName, eventType, appObject)
	if eventType == hs.application.watcher.activated then
		-- Ensure our taps are running regardless of app switching
		if not cmdToCtrlTap:isEnabled() or not ctrlToCtrlOptTap:isEnabled() then
			print("Detected disabled taps during app switch, restarting...")
			setupEventTaps()
		end
	end
end

-- System wakeup handler to ensure taps survive sleep/wake cycles
local caffeinateWatcher = hs.caffeinate.watcher.new(function(eventType)
	if eventType == hs.caffeinate.watcher.systemDidWake then
		print("System woke from sleep, ensuring taps are active...")
		-- Give the system a moment to stabilize after wake
		hs.timer.doAfter(2, function()
			setupEventTaps()
		end)
	end
end)
caffeinateWatcher:start()

-- Create an app watcher
local appWatcher = hs.application.watcher.new(applicationObserver)
appWatcher:start()

-- Set up a hotkey to manually reload the configuration if needed
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "r", function()
	print("Manual reload of keyboard remapping")
	setupEventTaps()
	hs.alert.show("Keyboard remapping reloaded")
end)

-- Schedule periodic full reloads to ensure continued operation
local periodicReloader = hs.timer.new(3600, function()
	print("Performing hourly preventative reload of keyboard mapping")
	setupEventTaps()
end, true)
periodicReloader:start()

-- Initial setup
setupEventTaps()

-- Log startup
print("Keyboard remapping initialization complete for multiple terminals")
