//
//  ViewController.swift
//  Quake_iOS_VR
//
//  Created by Heriberto Delgado on 5/2/16.
//
//

import GLKit
import GameController

class ViewController: UIViewController, GCSCardboardViewDelegate
{
    @IBOutlet weak var cardboardView: GCSCardboardView!

    private var displayLink: CADisplayLink! = nil
    
    private var previousTime: NSTimeInterval = -1
    
    private var currentTime: NSTimeInterval = -1
    
    private var firstEyeRendered: Bool = false
    
    private var lastEyeRendered: Bool = false
    
    private var remote: GCController? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.cardboardView.delegate = self
        self.cardboardView.vrModeEnabled = true
        
        displayLink = CADisplayLink(target: self, selector: #selector(render))
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(controllerDidConnect), name: "GCControllerDidConnectNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(controllerDidDisconnect), name: "GCControllerDidDisconnectNotification", object: nil)
    }

    func render()
    {
        cardboardView.render()
    }

    func cardboardView(cardboardView: GCSCardboardView!, willStartDrawing headTransform: GCSHeadTransform!)
    {
        gl_screenwidth = Int32(UIScreen.mainScreen().bounds.size.width * UIScreen.mainScreen().scale)
        gl_screenheight = Int32(UIScreen.mainScreen().bounds.size.height * UIScreen.mainScreen().scale)

        glvr_mode = 2
    
        Sys_Init(NSBundle.mainBundle().resourcePath!)
    }

    func cardboardView(cardboardView: GCSCardboardView!, prepareDrawFrame headTransform: GCSHeadTransform!)
    {
        if previousTime < 0
        {
            previousTime = NSProcessInfo().systemUptime
        }
        else if currentTime < 0
        {
            currentTime = NSProcessInfo().systemUptime
        }
        else
        {
            previousTime = currentTime
            
            currentTime = NSProcessInfo().systemUptime
            
            frame_lapse = Float(currentTime - previousTime)
        }
        
        firstEyeRendered = false
        lastEyeRendered = false
        
        glvr_rotation = headTransform.headPoseInStartSpace().m

        let pitchroll_origin : [Float] = [ 0.0, 1.0, 0.0, 1.0 ]
        
        let pitchroll_dest = [ glvr_rotation.0 * pitchroll_origin[0] + glvr_rotation.4 * pitchroll_origin[1] + glvr_rotation.8 * pitchroll_origin[2] + glvr_rotation.12 * pitchroll_origin[3], glvr_rotation.1 * pitchroll_origin[0] + glvr_rotation.5 * pitchroll_origin[1] + glvr_rotation.9 * pitchroll_origin[2] + glvr_rotation.13 * pitchroll_origin[3], glvr_rotation.2 * pitchroll_origin[0] + glvr_rotation.6 * pitchroll_origin[1] + glvr_rotation.10 * pitchroll_origin[2] + glvr_rotation.14 * pitchroll_origin[3], glvr_rotation.3 * pitchroll_origin[0] + glvr_rotation.7 * pitchroll_origin[1] + glvr_rotation.11 * pitchroll_origin[2] + glvr_rotation.15 * pitchroll_origin[3] ]
        
        glvr_viewangles.0 = asin(pitchroll_dest[2]) * 180.0 / Float(M_PI) // [PITCH] = asin(.z)
        
        glvr_viewangles.2 = atan2(pitchroll_dest[1], pitchroll_dest[0]) * 180.0 / Float(M_PI) - 90.0 // [ROLL] atan2(.y, .x) - 90
        
        let yaw_origin : [Float] = [ 1.0, 0.0, 0.0, 1.0 ]
        
        let yaw_dest = [ glvr_rotation.0 * yaw_origin[0] + glvr_rotation.4 * yaw_origin[1] + glvr_rotation.8 * yaw_origin[2] + glvr_rotation.12 * yaw_origin[3], glvr_rotation.1 * yaw_origin[0] + glvr_rotation.5 * yaw_origin[1] + glvr_rotation.9 * yaw_origin[2] + glvr_rotation.13 * yaw_origin[3], glvr_rotation.2 * yaw_origin[0] + glvr_rotation.6 * yaw_origin[1] + glvr_rotation.10 * yaw_origin[2] + glvr_rotation.14 * yaw_origin[3], glvr_rotation.3 * yaw_origin[0] + glvr_rotation.7 * yaw_origin[1] + glvr_rotation.11 * yaw_origin[2] + glvr_rotation.15 * yaw_origin[3] ]
        
        glvr_viewangles.1 = 180.0 - atan2(yaw_dest[0], yaw_dest[2]) * 180.0 / Float(M_PI) // [YAW] = atan2(.x, .z)
        
        Sys_FrameBeforeRender()
    }

    func cardboardView(cardboardView: GCSCardboardView!, drawEye eye: GCSEye, withHeadTransform headTransform: GCSHeadTransform!)
    {
        let viewport = headTransform.viewportForEye(eye)
        
        glvr_viewportx = Float(viewport.origin.x)
        glvr_viewporty = Float(viewport.origin.y)
        glvr_viewportwidth = Float(viewport.size.width)
        glvr_viewportheight = Float(viewport.size.height)
        
        glvr_eyetranslation = headTransform.eyeFromHeadMatrix(eye).m
        glvr_projection = headTransform.projectionMatrixForEye(eye, near: 4.0, far: 4096.0).m

        if firstEyeRendered
        {
            Sys_FrameRender()
            
            lastEyeRendered = true
            
            Sys_FrameAfterRender()
        }
        else if !lastEyeRendered
        {
            Sys_FrameRender()
            
            firstEyeRendered = true
        }
    }

    func cardboardView(cardboardView: GCSCardboardView!, didFireEvent event: GCSUserEvent)
    {
    }
    
    func cardboardView(cardboardView: GCSCardboardView!, shouldPauseDrawing pause: Bool)
    {
    }

    func controllerDidConnect(notification: NSNotification)
    {
        for controller in GCController.controllers()
        {
            if controller.extendedGamepad != nil && remote == nil
            {
                remote = controller
                
                remote!.playerIndex = .Index1

                remote!.controllerPausedHandler = { (controller: GCController) -> () in
                    
                    Key_Event(255, qboolean(1)) // K_PAUSE, true
                    Key_Event(255, qboolean(0)) // K_PAUSE, false
                    
                    Key_Event(27, qboolean(1)) // K_ESCAPE, true
                    Key_Event(27, qboolean(0)) // K_ESCAPE, false
                
                }

                remote!.extendedGamepad!.dpad.up.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Key_Event(128, qboolean(pressed ? 1 : 0)) // K_UPARROW, true / false
                }
                

                remote!.extendedGamepad!.dpad.left.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Key_Event(130, qboolean(pressed ? 1 : 0)) // K_LEFTARROW, true / false
                
                }
                
                remote!.extendedGamepad!.dpad.right.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Key_Event(131, qboolean(pressed ? 1 : 0)) // K_RIGHTARROW, true / false
                
                }
                
                remote!.extendedGamepad!.dpad.down.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Key_Event(129, qboolean(pressed ? 1 : 0)) // K_DOWNARROW, true / false
                
                }

                remote!.extendedGamepad!.buttonA.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Key_Event(13, qboolean(pressed ? 1 : 0)) // K_ENTER, true / false
                
                }
                
                remote!.extendedGamepad!.buttonB.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Key_Event(27, qboolean(pressed ? 1 : 0)) // K_ESCAPE, true / false
                
                }

                remote!.extendedGamepad!.buttonY.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    glvr_mode += 1
                    
                    if (glvr_mode > 2)
                    {
                        glvr_mode = 0
                    }
                    
                    if (glvr_mode == 0)
                    {
                        Sys_Con_Printf ("VR Static mode enabled.\n")
                    }
                    else if (glvr_mode == 1)
                    {
                        Sys_Con_Printf ("VR Head View mode enabled.\n")
                    }
                    else
                    {
                        Sys_Con_Printf ("VR Head Forward mode enabled.\n")
                    }
                    
                }

                remote!.extendedGamepad!.leftThumbstick.xAxis.valueChangedHandler = { (button: GCControllerAxisInput, value: Float) -> () in
                    
                    in_forwardmove = value
                    
                }
                
                remote!.extendedGamepad!.leftThumbstick.yAxis.valueChangedHandler = { (button: GCControllerAxisInput, value: Float) -> () in
                    
                    in_sidestepmove = value
                    
                }
                
                remote!.extendedGamepad!.rightThumbstick.xAxis.valueChangedHandler = { (button: GCControllerAxisInput, value: Float) -> () in
                    
                    if glvr_mode != 2
                    {
                        in_rollangle = value
                    }
                    
                }
                
                remote!.extendedGamepad!.rightThumbstick.yAxis.valueChangedHandler = { (button: GCControllerAxisInput, value: Float) -> () in
                    
                    if glvr_mode == 0
                    {
                        in_pitchangle = value
                    }
                    
                }

                remote!.extendedGamepad!.rightTrigger.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Key_Event(133, qboolean(pressed ? 1 : 0)) // K_CTRL, true / false
                
                }
                
                remote!.extendedGamepad!.rightShoulder.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    if pressed
                    {
                        Sys_Cbuf_AddText("impulse 10\n")
                    }
                    
                }
                
                break
            }
        }
    }
    
    func controllerDidDisconnect(notification: NSNotification)
    {
        if remote != nil
        {
            remote!.playerIndex = .IndexUnset
            
            remote = nil
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

