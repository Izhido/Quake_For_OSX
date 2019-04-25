//
//  MetalView.swift
//  Quake_OSX
//
//  Created by Heriberto Delgado on 1/30/16.
//
//

import MetalKit

class MetalView: MTKView
{
    fileprivate var previousModifierFlags : NSEvent.ModifierFlags = []
    
    fileprivate var trackingArea : NSTrackingArea?
    
    fileprivate let scantokey =
    [
        97,  //kVK_ANSI_A                    = 0x00,
        115, //kVK_ANSI_S                    = 0x01,
        100, //kVK_ANSI_D                    = 0x02,
        102, //kVK_ANSI_F                    = 0x03,
        104, //kVK_ANSI_H                    = 0x04,
        103, //kVK_ANSI_G                    = 0x05,
        122, //kVK_ANSI_Z                    = 0x06,
        120, //kVK_ANSI_X                    = 0x07,
        99,  //kVK_ANSI_C                    = 0x08,
        118, //kVK_ANSI_V                    = 0x09,
        0,   //__________                    = 0x0A,
        98,  //kVK_ANSI_B                    = 0x0B,
        113, //kVK_ANSI_Q                    = 0x0C,
        119, //kVK_ANSI_W                    = 0x0D,
        101, //kVK_ANSI_E                    = 0x0E,
        114, //kVK_ANSI_R                    = 0x0F,
        121, //kVK_ANSI_Y                    = 0x10,
        116, //kVK_ANSI_T                    = 0x11,
        49,  //kVK_ANSI_1                    = 0x12,
        50,  //kVK_ANSI_2                    = 0x13,
        51,  //kVK_ANSI_3                    = 0x14,
        52,  //kVK_ANSI_4                    = 0x15,
        54,  //kVK_ANSI_6                    = 0x16,
        53,  //kVK_ANSI_5                    = 0x17,
        61,  //kVK_ANSI_Equal                = 0x18,
        57,  //kVK_ANSI_9                    = 0x19,
        55,  //kVK_ANSI_7                    = 0x1A,
        45,  //kVK_ANSI_Minus                = 0x1B,
        56,  //kVK_ANSI_8                    = 0x1C,
        48,  //kVK_ANSI_0                    = 0x1D,
        93,  //kVK_ANSI_RightBracket         = 0x1E,
        111, //kVK_ANSI_O                    = 0x1F,
        117, //kVK_ANSI_U                    = 0x20,
        91,  //kVK_ANSI_LeftBracket          = 0x21,
        105, //kVK_ANSI_I                    = 0x22,
        112, //kVK_ANSI_P                    = 0x23,
        13,  //kVK_Return                    = 0x24,
        108, //kVK_ANSI_L                    = 0x25,
        106, //kVK_ANSI_J                    = 0x26,
        39,  //kVK_ANSI_Quote                = 0x27,
        107, //kVK_ANSI_K                    = 0x28,
        59,  //kVK_ANSI_Semicolon            = 0x29,
        92,  //kVK_ANSI_Backslash            = 0x2A,
        44,  //kVK_ANSI_Comma                = 0x2B,
        47,  //kVK_ANSI_Slash                = 0x2C,
        110, //kVK_ANSI_N                    = 0x2D,
        109, //kVK_ANSI_M                    = 0x2E,
        46,  //kVK_ANSI_Period               = 0x2F,
        9,   //kVK_Tab                       = 0x30,
        32,  //kVK_Space                     = 0x31,
        96,  //kVK_ANSI_Grave                = 0x32,
        127, //kVK_Delete                    = 0x33,
        0,   //__________                    = 0x34,
        27,  //kVK_Escape                    = 0x35,
        0,   //__________                    = 0x36,
        0,   //kVK_Command                   = 0x37,
        134, //kVK_Shift                     = 0x38,
        0,   //kVK_CapsLock                  = 0x39,
        132, //kVK_Option                    = 0x3A,
        133, //kVK_Control                   = 0x3B,
        134, //kVK_RightShift                = 0x3C,
        132, //kVK_RightOption               = 0x3D,
        133, //kVK_RightControl              = 0x3E,
        0,   //kVK_Function                  = 0x3F,
        0,   //kVK_F17                       = 0x40,
        0,   //kVK_ANSI_KeypadDecimal        = 0x41,
        0,   //__________                    = 0x42,
        42,  //kVK_ANSI_KeypadMultiply       = 0x43,
        0,   //__________                    = 0x44,
        43,  //kVK_ANSI_KeypadPlus           = 0x45,
        0,   //__________                    = 0x46,
        0,   //kVK_ANSI_KeypadClear          = 0x47,
        0,   //kVK_VolumeUp                  = 0x48,
        0,   //kVK_VolumeDown                = 0x49,
        0,   //kVK_Mute                      = 0x4A,
        47,  //kVK_ANSI_KeypadDivide         = 0x4B,
        13,  //kVK_ANSI_KeypadEnter          = 0x4C,
        0,   //__________                    = 0x4D,
        45,  //kVK_ANSI_KeypadMinus          = 0x4E,
        0,   //kVK_F18                       = 0x4F,
        0,   //kVK_F19                       = 0x50,
        61,  //kVK_ANSI_KeypadEquals         = 0x51,
        48,  //kVK_ANSI_Keypad0              = 0x52,
        49,  //kVK_ANSI_Keypad1              = 0x53,
        50,  //kVK_ANSI_Keypad2              = 0x54,
        51,  //kVK_ANSI_Keypad3              = 0x55,
        52,  //kVK_ANSI_Keypad4              = 0x56,
        53,  //kVK_ANSI_Keypad5              = 0x57,
        54,  //kVK_ANSI_Keypad6              = 0x58,
        55,  //kVK_ANSI_Keypad7              = 0x59,
        0,   //kVK_F20                       = 0x5A,
        56,  //kVK_ANSI_Keypad8              = 0x5B,
        57,  //kVK_ANSI_Keypad9              = 0x5C,
        0,   //__________                    = 0x5D,
        0,   //__________                    = 0x5E,
        0,   //__________                    = 0x5F,
        139, //kVK_F5                        = 0x60,
        140, //kVK_F6                        = 0x61,
        141, //kVK_F7                        = 0x62,
        137, //kVK_F3                        = 0x63,
        142, //kVK_F8                        = 0x64,
        143, //kVK_F9                        = 0x65,
        0,   //___________                   = 0x66,
        145, //kVK_F11                       = 0x67,
        0,   //__________                    = 0x68,
        0,   //kVK_F13                       = 0x69,
        0,   //kVK_F16                       = 0x6A,
        0,   //kVK_F14                       = 0x6B,
        0,   //__________                    = 0x6C,
        144, //kVK_F10                       = 0x6D,
        0,   //__________                    = 0x6E,
        146, //kVK_F12                       = 0x6F,
        0,   //__________                    = 0x70,
        0,   //kVK_F15                       = 0x71,
        0,   //kVK_Help                      = 0x72,
        151, //kVK_Home                      = 0x73,
        150, //kVK_PageUp                    = 0x74,
        148, //kVK_ForwardDelete             = 0x75,
        138, //kVK_F4                        = 0x76,
        152, //kVK_End                       = 0x77,
        136, //kVK_F2                        = 0x78,
        149, //kVK_PageDown                  = 0x79,
        135, //kVK_F1                        = 0x7A,
        130, //kVK_LeftArrow                 = 0x7B,
        131, //kVK_RightArrow                = 0x7C,
        129, //kVK_DownArrow                 = 0x7D,
        128  //kVK_UpArrow                   = 0x7E
    ]
    
    override func keyDown(with theEvent: NSEvent)
    {
        let code = Int(theEvent.keyCode)
        
        let mapped = Int32(scantokey[code])
        
        Key_Event(mapped, qboolean(1))
    }
    
    override func keyUp(with theEvent: NSEvent)
    {
        let code = Int(theEvent.keyCode)
        
        let mapped = Int32(scantokey[code])
        
        Key_Event(mapped, qboolean(0))
    }
    
    override func flagsChanged(with theEvent: NSEvent)
    {
        if theEvent.modifierFlags.contains(.option) && !previousModifierFlags.contains(.option)
        {
            Key_Event(132, qboolean(1))
        }
        else if !theEvent.modifierFlags.contains(.option) && previousModifierFlags.contains(.option)
        {
            Key_Event(132, qboolean(0))
        }
        
        if theEvent.modifierFlags.contains(.control) && !previousModifierFlags.contains(.control)
        {
            Key_Event(133, qboolean(1))
        }
        else if !theEvent.modifierFlags.contains(.control) && previousModifierFlags.contains(.control)
        {
            Key_Event(133, qboolean(0))
        }
        
        if theEvent.modifierFlags.contains(.shift) && !previousModifierFlags.contains(.shift)
        {
            Key_Event(134, qboolean(1))
        }
        else if !theEvent.modifierFlags.contains(.shift) && previousModifierFlags.contains(.shift)
        {
            Key_Event(134, qboolean(0))
        }
        
        previousModifierFlags = theEvent.modifierFlags
    }

    override var acceptsFirstResponder: Bool { return true }
    
    fileprivate func createTrackingArea()
    {
        trackingArea = NSTrackingArea(rect: self.bounds, options: [.mouseMoved, .mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        
        addTrackingArea(trackingArea!)
    }

    override func viewWillMove(toWindow newWindow: NSWindow?)
    {
        if newWindow != nil
        {
            createTrackingArea()
        }
    }

    override func updateTrackingAreas()
    {
        removeTrackingArea(trackingArea!)
        
        createTrackingArea()
    }
    
    override func mouseDown(with theEvent: NSEvent)
    {
        Key_Event(200, qboolean(1))
    }
    
    override func mouseUp(with theEvent: NSEvent)
    {
        Key_Event(200, qboolean(0))
    }
    
    override func mouseMoved(with theEvent: NSEvent)
    {
        mx += Int32(theEvent.deltaX)
        my += Int32(theEvent.deltaY)
    }
    
    override func rightMouseDown(with theEvent: NSEvent)
    {
        Key_Event(201, qboolean(1))
    }
    
    override func rightMouseUp(with theEvent: NSEvent)
    {
        Key_Event(201, qboolean(0))
    }
    
    override func mouseEntered(with theEvent: NSEvent)
    {
        NSCursor.hide()
    }
    
    override func mouseExited(with theEvent: NSEvent)
    {
        NSCursor.unhide()
    }
}
