# hammerspoon_cmd_as_ctrl_combine_modifier
A hammerspoon script that helps with MacOS modifiers when dealing with terminals

## Functionality
1. Command key is interpretted as CTRL key ***ONLY*** when terminal applications are active. No longer needing to press a seperate key
2. Maps CTRL key to be interpretted as CTRL + OPTION key ***GLOBALLY***. So I can bind MacOS keybindings to CTRL + OPTION instead so it does not interfere with Application level bindings, and I'm still pressing 1 key to trigger it.

## Background
I have an issue with the Command Key on MacOS, it shares core functionality with the CTRL key in Windows, Linux eg. New Tab, Copy, Paste, Undo, etc
I like the Command Key, However when in the terminal I don't want a separate key to access my CTRL key bindings because this muscle memory doesn't translate when I move to Linux.

MacOS level bindings take precedence over application bindings. So If i bind something like SPOTLIGHT to Control/Command + Space this will take precedence over other application key bindings.
So instead I can bind SPOTLIGHT to CTRL + OPTION + Space. However I don't want to have to press 2 modifiers all the time, So I bind CTRL + OPTIOn to the CTRL key.

## Why Hammerspoon?
You can perform the same solution with a Key Binding application like Karabiner, and I have and it might even be a more robust solution, but unfortunately I can't get Karabiner to work on my corporate MacOS because Karabiner requires driver installations which is beyond my privelages.
