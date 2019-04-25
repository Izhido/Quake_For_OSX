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
    fileprivate var cardboardView: GVRCardboardView! = nil
    
    fileprivate var displayLink: CADisplayLink! = nil
    
    fileprivate var previousTime: TimeInterval = -1
    
    fileprivate var currentTime: TimeInterval = -1
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        UserDefaults.standard.register(defaults: ["lanConfig_joinname" : "", "lanConfig_port" : 26000, "net_ipaddress" : "", "cl_name" : "", "sys_commandlineindex" : 1, "sys_commandline2" : "-game hipnotic -hipnotic", "sys_commandline3" : "-rogue", "sys_logmaxlines" : 1000, "sys_displayHelp" : false])
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        currentViewController = self
        
        if !startGame
        {
            let displayHelp = UserDefaults.standard.bool(forKey: "sys_displayHelp")
            
            if displayHelp
            {
                performSegue(withIdentifier: "ToIntroduction", sender: self)
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
                    performSegue(withIdentifier: "ToIntroduction", sender: self)
                }
            }
        }
        
        if startGame
        {
            cardboardView = self.view as? GVRCardboardView
            
            cardboardView.delegate = self
            cardboardView.vrModeEnabled = true
            
            displayLink = CADisplayLink(target: self, selector: #selector(render))
            displayLink.add(to: RunLoop.current, forMode: RunLoop.Mode.default)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(controllerDidConnect), name: NSNotification.Name(rawValue: "GCControllerDidConnectNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(controllerDidDisconnect), name: NSNotification.Name(rawValue: "GCControllerDidDisconnectNotification"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)

        currentViewController = nil
    }

    @objc func render()
    {
        cardboardView.render()
    }
    
    func setupEndingScreen()
    {
        if cardboardView.vrModeEnabled
        {
            displayLink.invalidate()
            
            cardboardView.vrModeEnabled = false
            
            performSegue(withIdentifier: "ToEnding", sender: self)
        }
    }
    
    func cardboardView(_ cardboardView: GVRCardboardView!, willStartDrawing headTransform: GVRHeadTransform!)
    {
        gl_screenwidth = Int32(UIScreen.main.bounds.size.width * UIScreen.main.scale)
        gl_screenheight = Int32(UIScreen.main.bounds.size.height * UIScreen.main.scale)
        
        glvr_mode = 2
        glvr_eyecount = 2
        
        let ipAddress = UserDefaults.standard.string(forKey: "net_ipaddress")
        
        if ipAddress != nil && !ipAddress!.isEmpty
        {
            net_ipaddress = UnsafeMutablePointer<Int8>.allocate(capacity: ipAddress!.count + 1)

            strcpy(net_ipaddress, ipAddress!.cString(using: String.defaultCStringEncoding)!)
        }
        
        var commandLineIndex = UserDefaults.standard.integer(forKey: "sys_commandlineindex")
        
        if commandLineIndex < 1 || commandLineIndex > 16
        {
            commandLineIndex = 1
        }

        var commandLine = UserDefaults.standard.string(forKey: "sys_commandline\(commandLineIndex)")
        
        if commandLine == nil
        {
            commandLine = ""
        }

        let resourcesDir = Bundle.main.resourcePath!

        let documentsDir = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).path
        
        Sys_Init(resourcesDir, documentsDir, commandLine!)
        
        if (host_initialized != qboolean(0))
        {
            let server = UserDefaults.standard.string(forKey: "lanConfig_joinname")
            
            if server != nil && !server!.isEmpty
            {
                strcpy(lanConfig_joinname, server!.cString(using: String.defaultCStringEncoding)!)
            }
            
            let port = UserDefaults.standard.integer(forKey: "lanConfig_port")
            
            if port != 0
            {
                lanConfig_port = Int32(port)
            }
            
            let playerName = UserDefaults.standard.string(forKey: "cl_name")
            
            if playerName != nil && !playerName!.isEmpty
            {
                Sys_Cbuf_AddText("name \(playerName!)")
            }
            
            let logMaxLines = UserDefaults.standard.integer(forKey: "sys_logmaxlines")
            
            if logMaxLines != 0
            {
                sys_logmaxlines = Int32(logMaxLines)
            }
        }
    }
    
    func cardboardView(_ cardboardView: GVRCardboardView!, prepareDrawFrame headTransform: GVRHeadTransform!)
    {
        if sys_ended.rawValue != 0
        {
            setupEndingScreen()
            
            return
        }
        
        if previousTime < 0
        {
            previousTime = ProcessInfo().systemUptime
        }
        else if currentTime < 0
        {
            currentTime = ProcessInfo().systemUptime
        }
        else
        {
            previousTime = currentTime
            
            currentTime = ProcessInfo().systemUptime
            
            frame_lapse = Float(currentTime - previousTime)
        }
        
        glvr_eyeindex = 0
        
        glvr_rotation = headTransform.headPoseInStartSpace().m
        
        let pitchroll_origin : [GLfloat] = [ 0.0, 1.0, 0.0, 1.0 ]
        
        let pitchroll_00 = glvr_rotation.0 * pitchroll_origin[0]
        let pitchroll_41 = glvr_rotation.4 * pitchroll_origin[1]
        let pitchroll_82 = glvr_rotation.8 * pitchroll_origin[2]
        let pitchroll_123 = glvr_rotation.12 * pitchroll_origin[3]
        
        let pitchroll_0 = pitchroll_00 + pitchroll_41 + pitchroll_82 + pitchroll_123

        let pitchroll_10 = glvr_rotation.1 * pitchroll_origin[0]
        let pitchroll_51 = glvr_rotation.5 * pitchroll_origin[1]
        let pitchroll_92 = glvr_rotation.9 * pitchroll_origin[2]
        let pitchroll_133 = glvr_rotation.13 * pitchroll_origin[3]
        
        let pitchroll_1 = pitchroll_10 + pitchroll_51 + pitchroll_92 + pitchroll_133

        let pitchroll_20 = glvr_rotation.2 * pitchroll_origin[0]
        let pitchroll_61 = glvr_rotation.6 * pitchroll_origin[1]
        let pitchroll_102 = glvr_rotation.10 * pitchroll_origin[2]
        let pitchroll_143 = glvr_rotation.14 * pitchroll_origin[3]
        
        let pitchroll_2 = pitchroll_20 + pitchroll_61 + pitchroll_102 + pitchroll_143
        
        let pitchroll_30 = glvr_rotation.3 * pitchroll_origin[0]
        let pitchroll_71 = glvr_rotation.7 * pitchroll_origin[1]
        let pitchroll_112 = glvr_rotation.11 * pitchroll_origin[2]
        let pitchroll_153 = glvr_rotation.15 * pitchroll_origin[3]
        
        let pitchroll_3 = pitchroll_30 + pitchroll_71 + pitchroll_112 + pitchroll_153

        let pitchroll_dest = [ pitchroll_0, pitchroll_1, pitchroll_2, pitchroll_3 ]
        
        glvr_viewangles.0 = asin(pitchroll_dest[2]) * 180.0 / .pi // [PITCH] = asin(.z)
        
        glvr_viewangles.2 = atan2(pitchroll_dest[1], pitchroll_dest[0]) * 180.0 / .pi - 90.0 // [ROLL] atan2(.y, .x) - 90
        
        let yaw_origin : [GLfloat] = [ 1.0, 0.0, 0.0, 1.0 ]
        
        let yaw_00 = glvr_rotation.0 * yaw_origin[0]
        let yaw_41 = glvr_rotation.4 * yaw_origin[1]
        let yaw_82 = glvr_rotation.8 * yaw_origin[2]
        let yaw_123 = glvr_rotation.12 * yaw_origin[3]
        
        let yaw_0 = yaw_00 + yaw_41 + yaw_82 + yaw_123
        
        let yaw_10 = glvr_rotation.1 * yaw_origin[0]
        let yaw_51 = glvr_rotation.5 * yaw_origin[1]
        let yaw_92 = glvr_rotation.9 * yaw_origin[2]
        let yaw_133 = glvr_rotation.13 * yaw_origin[3]
        
        let yaw_1 = yaw_10 + yaw_51 + yaw_92 + yaw_133
        
        let yaw_20 = glvr_rotation.2 * yaw_origin[0]
        let yaw_61 = glvr_rotation.6 * yaw_origin[1]
        let yaw_102 = glvr_rotation.10 * yaw_origin[2]
        let yaw_143 = glvr_rotation.14 * yaw_origin[3]
        
        let yaw_2 = yaw_20 + yaw_61 + yaw_102 + yaw_143
        
        let yaw_30 = glvr_rotation.3 * yaw_origin[0]
        let yaw_71 = glvr_rotation.7 * yaw_origin[1]
        let yaw_112 = glvr_rotation.11 * yaw_origin[2]
        let yaw_153 = glvr_rotation.15 * yaw_origin[3]
        
        let yaw_3 = yaw_30 + yaw_71 + yaw_112 + yaw_153
        
        let yaw_dest = [ yaw_0, yaw_1, yaw_2, yaw_3 ]
        
        glvr_viewangles.1 = 180.0 - atan2(yaw_dest[0], yaw_dest[2]) * 180.0 / .pi // [YAW] = atan2(.x, .z)

        Sys_FrameBeforeRender()
    }
    
    func cardboardView(_ cardboardView: GVRCardboardView!, draw eye: GVREye, with headTransform: GVRHeadTransform!)
    {
        if sys_ended.rawValue != 0
        {
            setupEndingScreen()
            
            return
        }
        
        let viewport = headTransform.viewport(for: eye)
        
        glvr_viewportx = Float(viewport.origin.x)
        glvr_viewporty = Float(viewport.origin.y)
        glvr_viewportwidth = Float(viewport.size.width)
        glvr_viewportheight = Float(viewport.size.height)
        
        glvr_eyetranslation = headTransform.eye(fromHeadMatrix: eye).m
        glvr_projection = headTransform.projectionMatrix(for: eye, near: 4.0, far: 4096.0).m
        
        Sys_FrameRender()
        
        glvr_eyeindex += 1
        
        if glvr_eyeindex == glvr_eyecount
        {
            Sys_FrameAfterRender()
        }
    }
    
    func cardboardView(_ cardboardView: GVRCardboardView!, didFire event: GVRUserEvent)
    {
        if (event == GVRUserEvent.backButton)
        {
            if gameInterrupted
            {
                return
            }

            gameInterrupted = true
            
            if (host_initialized != qboolean(0))
            {
                Host_Shutdown()
            }
            
            sys_ended = qboolean(1)

            setupEndingScreen()
        }
    }
    
    func cardboardView(_ cardboardView: GVRCardboardView!, shouldPauseDrawing pause: Bool)
    {
    }
    
    @objc func controllerDidConnect(_ notification: Notification)
    {
        GameControllerSetup.connect(notification.object as? GCController)
    }
    
    @objc func controllerDidDisconnect(_ notification: Notification)
    {
        GameControllerSetup.disconnect(notification.object as? GCController)
    }
}

