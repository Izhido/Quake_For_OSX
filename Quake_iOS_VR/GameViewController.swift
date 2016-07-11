//
//  ViewController.swift
//  Quake_iOS_VR
//
//  Created by Heriberto Delgado on 5/2/16.
//
//

import GLKit
import GameController

public var gameInterrupted : Bool = false

public var startGame : Bool = false

class GameViewController: UIViewController, GVRCardboardViewDelegate
{
    private var cardboardView: GVRCardboardView! = nil
    
    private var displayLink: CADisplayLink! = nil
    
    private var previousTime: NSTimeInterval = -1
    
    private var currentTime: NSTimeInterval = -1
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NSUserDefaults.standardUserDefaults().registerDefaults(["lanConfig_joinname" : "", "lanConfig_port" : 26000, "net_ipaddress" : "", "cl_name" : "", "sys_commandlineindex" : 1, "sys_commandline2" : "-game hipnotic -hipnotic", "sys_commandline3" : "-rogue", "sys_logmaxlines" : 1000, "sys_displayHelp" : false])
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        currentViewController = self
        
        if !startGame
        {
            let displayHelp = NSUserDefaults.standardUserDefaults().boolForKey("sys_displayHelp")
            
            if displayHelp
            {
                performSegueWithIdentifier("ToIntroduction", sender: self)
            }
            else
            {
                GameDataDetection.detect()
                
                if GameDataDetection.sharewarePresent || GameDataDetection.registeredPresent
                {
                    startGame = true
                }
                else
                {
                    performSegueWithIdentifier("ToIntroduction", sender: self)
                }
            }
        }
        
        if startGame
        {
            cardboardView = self.view as! GVRCardboardView
            
            cardboardView.delegate = self
            cardboardView.vrModeEnabled = true
            
            displayLink = CADisplayLink(target: self, selector: #selector(render))
            displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(controllerDidConnect), name: "GCControllerDidConnectNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(controllerDidDisconnect), name: "GCControllerDidDisconnectNotification", object: nil)
    }

    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)

        currentViewController = nil
    }

    func render()
    {
        cardboardView.render()
    }
    
    func setupEndingScreen()
    {
        if cardboardView.vrModeEnabled
        {
            displayLink.invalidate()
            
            cardboardView.vrModeEnabled = false
            
            performSegueWithIdentifier("ToEnding", sender: self)
        }
    }
    
    func cardboardView(cardboardView: GVRCardboardView!, willStartDrawing headTransform: GVRHeadTransform!)
    {
        gl_screenwidth = Int32(UIScreen.mainScreen().bounds.size.width * UIScreen.mainScreen().scale)
        gl_screenheight = Int32(UIScreen.mainScreen().bounds.size.height * UIScreen.mainScreen().scale)
        
        glvr_mode = 2
        glvr_eyecount = 2
        
        let ipAddress = NSUserDefaults.standardUserDefaults().stringForKey("net_ipaddress")
        
        if ipAddress != nil && !ipAddress!.isEmpty
        {
            net_ipaddress = UnsafeMutablePointer<Int8>(malloc(ipAddress!.characters.count + 1))

            strcpy(net_ipaddress, ipAddress!.cStringUsingEncoding(String.defaultCStringEncoding())!)
        }
        
        var commandLineIndex = NSUserDefaults.standardUserDefaults().integerForKey("sys_commandlineindex")
        
        if commandLineIndex < 1 || commandLineIndex > 16
        {
            commandLineIndex = 1
        }

        var commandLine = NSUserDefaults.standardUserDefaults().stringForKey("sys_commandline\(commandLineIndex)")
        
        if commandLine == nil
        {
            commandLine = ""
        }

        let resourcesDir = NSBundle.mainBundle().resourcePath!

        let documentsDir = try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true).path!
        
        Sys_Init(resourcesDir, documentsDir, commandLine!)
        
        if (host_initialized != qboolean(0))
        {
            let server = NSUserDefaults.standardUserDefaults().stringForKey("lanConfig_joinname")
            
            if server != nil && !server!.isEmpty
            {
                strcpy(lanConfig_joinname, server!.cStringUsingEncoding(String.defaultCStringEncoding())!)
            }
            
            let port = NSUserDefaults.standardUserDefaults().integerForKey("lanConfig_port")
            
            if port != 0
            {
                lanConfig_port = Int32(port)
            }
            
            let playerName = NSUserDefaults.standardUserDefaults().stringForKey("cl_name")
            
            if playerName != nil && !playerName!.isEmpty
            {
                Sys_Cbuf_AddText("name \(playerName!)")
            }
            
            let logMaxLines = NSUserDefaults.standardUserDefaults().integerForKey("sys_logmaxlines")
            
            if logMaxLines != 0
            {
                sys_logmaxlines = Int32(logMaxLines)
            }
        }
    }
    
    func cardboardView(cardboardView: GVRCardboardView!, prepareDrawFrame headTransform: GVRHeadTransform!)
    {
        if sys_ended.rawValue != 0
        {
            setupEndingScreen()
            
            return
        }
        
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
        
        glvr_eyeindex = 0
        
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
    
    func cardboardView(cardboardView: GVRCardboardView!, drawEye eye: GVREye, withHeadTransform headTransform: GVRHeadTransform!)
    {
        if sys_ended.rawValue != 0
        {
            setupEndingScreen()
            
            return
        }
        
        let viewport = headTransform.viewportForEye(eye)
        
        glvr_viewportx = Float(viewport.origin.x)
        glvr_viewporty = Float(viewport.origin.y)
        glvr_viewportwidth = Float(viewport.size.width)
        glvr_viewportheight = Float(viewport.size.height)
        
        glvr_eyetranslation = headTransform.eyeFromHeadMatrix(eye).m
        glvr_projection = headTransform.projectionMatrixForEye(eye, near: 4.0, far: 4096.0).m
        
        Sys_FrameRender()
        
        glvr_eyeindex += 1
        
        if glvr_eyeindex == glvr_eyecount
        {
            Sys_FrameAfterRender()
        }
    }
    
    func cardboardView(cardboardView: GVRCardboardView!, didFireEvent event: GVRUserEvent)
    {
        if (event == GVRUserEvent.BackButton)
        {
            gameInterrupted = true
            
            if (host_initialized != qboolean(0))
            {
                Host_Shutdown()
            }
            
            sys_ended = qboolean(1)

            setupEndingScreen()
        }
    }
    
    func cardboardView(cardboardView: GVRCardboardView!, shouldPauseDrawing pause: Bool)
    {
    }
    
    func controllerDidConnect(notification: NSNotification)
    {
        GameControllerSetup.connect(notification.object as! GCController!)
    }
    
    func controllerDidDisconnect(notification: NSNotification)
    {
        GameControllerSetup.disconnect(notification.object as! GCController!)
    }
}

