# Quake For OSX

This is a port of the original Quake rendering engine for OSX / tvOS / iOS.

The source code contains an Xcode 7.3 workspace with three targets:
- OS X 10.11 and later;
- tvOS 9.1 and later, playable in the 4th gen. Apple TV;
- iOS 9.3 and later (iPhone only), specially designed to be used with a virtual reality (VR) viewer such as Google Cardboard or similar.

The first two targets (OS X, tvOS) do software rendering (instead of OpenGL); presenting to the screen, however, is performed by using Metal. The third target (iOS VR), however, does use OpenGL ES 3.0 to render both screens in a VR viewer configuration.

Additionally, all targets are able to use an extended-profile gaming controller, such as the SteelSeries Nimbus (the recommended controller from Apple, as of this writing). Any extended-profile gaming controller, however, should be sufficient to play with no problems.

Please notice that you MUST USE an extended-profile gaming controller in order to give commands to the iOS VR target application.

To run the OS X target:
- Open the project in Xcode.
- Select the "Quake_OSX" target.
- "Edit Scheme" - "Run" - "Arguments Passed on Launch".
- Modify the command line to specify the "id1" folder containing the shareware / full game PAK files. If there is no command line specified, just add the following line:

    -basedir "/Users/heribertodelgado/Downloads/Quake Shareware (1_06) PAK"

  (You might want to change the specified username, or the folder containing your id1/pak0.pak files.)

- "Product" - "Run" to start the application.

NOTE: Since it is a port of the original Quake engine, things like Mouse Look mode and playing by using WASD keys are not enabled by default; you will need to enable/bind them all from the console if you want to use them.

To run the tvOS target:
- Open the project in Xcode.
- Select the "Quake_tvOS" target.
- Go to the "Quake_tvOS/Resources" group.
- Remap the "id1" folder and "pak0.pak" resource file to the shareware / full game PAK files in your hard drive. NOTE: For the full game, you will need to add the pak1.pak file into the id1 folder as well.
- Connect your Apple TV to your computer, then assign it to the "Quake_tvOS" target.
- "Product" - "Run" to start the application.

The game can be played by using either the Siri Remote that comes with the Apple TV, or the extended-profile gaming controller (the preferred way as of this writing).

To run the iOS VR target:
- Ensure you have the latest CocoaPods version ( https://cocoapods.org ).
- Run "pod install" / "pod update" from Terminal as needed to get the Google Cardboard SDK and SSZipArchive libraries.
- Open the project in Xcode.
- Select the "Quake_iOS_VR" target.
- Go to the "Quake_iOS_VR/Resources" group.
- Ensure that you have a "quake106data.zip" file available, containing the "id1" folder with the pak files for the shareware (or full) version of the game.
- Connect your iPhone to your computer.
- Have your VR viewer ready to be used with your iPhone.
- "Product" - "Run" to start the application. If you're running it for the first time, a guide will appear to help you set up things in your device before starting the game.
- If you haven't already done so, match your VR viewer with the application by using the Settings option.

Strictly speaking, the iOS VR target can be started without an extended-profile gaming controller; however, you won't be able to control it at all until you pair the controller to your iPhone.

Controls for the tvOS target by using the Siri Remote are as follows:
- To access the main menu, press the "Menu" button. Tap lightly on the touch surface up, down, left and right to move around the options; click firmly on the touch surface to select an option.
- To pause / resume the game, press the "Play/Pause" button.
- To walk forward, backwards, or sidestep, slide your thumb across the touch surface, as if using a gamepad joystick.
- To fire / attack, click firmly on the touch surface.
- To look up / down, tilt your remote up / down.
- To turn left / right, *spin* your remote to the left or to the right (as if using a screwdriver).
- To jump, tap lightly at the bottom of the touch surface.
- To switch weapons, tap lightly at the right side of the touch surface.

This control scheme is experimental. While the game is playable, maybe even winnable, it has a fairly steep curve to learn & master; you will need steady hands to control the game this way. Some button combinations are not possible using this scheme, so it is likely that not all areas in the game can be reached this way. Proceed with caution. YOU'VE BEEN WARNED.

Controls for all targets by using an extended-profile gaming controller are as follows:
- To access the main menu AND to pause / resume the game, press the "Menu" / "Pause" button. Use the D-pad to move around the options; press A to enter an option, B to exit the current screen.
- To access the main menu only (without pausing the game), press B, and follow the instructions above.
- To walk forward, backwards, or sidestep, use the left thumbstick.
- To fire / attack, press the right trigger button.
- To look up / down, or turn left / right, use the right thumbstick. NOTE: For the iOS VR target, this only works in the VR Static mode. See below for details.
- Alternatively, to walk forward / backwards / turn left / right, use the D-pad.
- To jump, press A.
- To switch weapons, press the right shoulder button.
- To cycle between VR modes, press Y. There are 2 VR modes:
  - Static mode: The game will not respond to the player's head movements at all. The VR viewer becomes, effectively, a 3D monitor attached to the player's head, and nothing else.
  - Head Forward mode: The game will respond to the player's head movement; fire will be directed to whatever direction the player is looking at. The player will also move in whatever direction his/her head is pointing to; this implies that sidestepping will also be relative to the player's head. Lastly, since the player's head controls the direction of movement, the right thumbstick will be deactivated in this mode.

Any comments and bug reports are welcome. 

This software, just like the original engine, is released under the terms of the GNU General Public License v2.

Quake is (c) 1996-1997 id Software, Inc.

Modifications for OS X / tvOS (c) 2016 Heriberto Delgado.
