# Quake For OSX

This is a port of the original Quake rendering engine for OSX 10.11 / tvOS 9.1.

The source code contains an Xcode 7.2 project with two targets, one for OS X and the other for tvOS, playable in the 4th gen. Apple TV.

This port uses software rendering (instead of OpenGL); presenting to the screen, however, is performed by using Metal in both OS X and tvOS targets.

To run the OS X target:
- Open the project in Xcode.
- Select the "Quake_OSX" target.
- "Edit Scheme" - "Run" - "Arguments Passed on Launch".
- Modify the command line to specify the"id1" folder containing the shareware / full game PAK files.
- "Product" - "Run" to start the application.

The OS X target currently has no sound, network, or gamepad support, but it can be played using a keyboard and mouse.
NOTE: Since it is a port of the original Quake engine, things like Mouse Look mode and playing by using WASD keys are not enabled by default; you will need to enable/bind them all from the console if you want to use them.

To run the tvOS target:
- Open the project in Xcode.
- Select the "Quake_tvOS" target.
- Go to the "Quake_tvOS/Resources" group.
- Remap the "id1" folder and "pak0.pak" resource file to the shareware / full game PAK files in your hard drive. NOTE: For the full game, you will need to add the pak1.pak file into the id1 folder as well.
- Connect your Apple TV to your computer, then assign it to the "Quake_tvOS" target.
- "Product" - "Run" to start the application.

The tvOS target, just like the OS X target, currently has no sound, network, or external gamepad support; the game can be played using the Siri Remote that comes with the Apple TV.

Controls for the tvOS target are as follows:
- To access the main menu, press the "Menu" button. Tap lightly on the touch surface up, down, left and right to move around the options; click firmly on the touch surface to select an option.
- To pause / resume the game, press the "Play/Pause" button.
- To walk forward, backwards, or sidestep, slide your thumb across the touch surface, as if using a gamepad joystick.
- To fire / attack, click firmly on the touch surface.
- To look up / down, tilt your remote up / down.
- To turn left / right, *spin* your remote to the left or to the right (as if using a screwdriver).
- To jump, tap lightly at the bottom of the touch surface.
- To switch weapons, tap lightly at the right side of the touch surface.

This control scheme is experimental. While the game is playable, maybe even winnable, it has a fairly steep curve to learn & master; you will need steady hands to control the game this way. Some button combinations are not possible using this scheme, so it is likely that not all areas in the game can be reached this way. Proceed with caution. YOU'VE BEEN WARNED.

Any comments and bug reports are welcome. 

This software, just like the original engine, is released under the terms of the GNU General Public License v2.

Quake is (c) 1996-1997 id Software, Inc.

Modifications for OS X / tvOS (c) 2016 Heriberto Delgado.
