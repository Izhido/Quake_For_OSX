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

class ViewController: UIViewController, GVRCardboardViewDelegate, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var cardboardView: GVRCardboardView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var copyLogButton: UIButton!
    
    @IBOutlet weak var consoleTableView: UITableView!
    
    private var displayLink: CADisplayLink! = nil
    
    private var previousTime: NSTimeInterval = -1
    
    private var currentTime: NSTimeInterval = -1
    
    private var remote: GCController? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.cardboardView.delegate = self
        self.cardboardView.vrModeEnabled = true
        
        consoleTableView.dataSource = self
        consoleTableView.delegate = self
        
        displayLink = CADisplayLink(target: self, selector: #selector(render))
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(controllerDidConnect), name: "GCControllerDidConnectNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(controllerDidDisconnect), name: "GCControllerDidDisconnectNotification", object: nil)
    }
    
    func render()
    {
        cardboardView.render()
    }
    
    func setupEndingScreen()
    {
        if self.cardboardView.vrModeEnabled
        {
            displayLink.invalidate()
            
            self.cardboardView.vrModeEnabled = false
            
            if host_nogamedata.rawValue != 0
            {
                titleLabel.text = "Game data not found"
                descriptionLabel.text = "Transfer a copy of the ID1/ directory to this application, as well as any other related files or directories, by using iTunes File Sharing or any suitable program. Afterwards, close and restart the application to start playing."
            }
            else if sys_inerror.rawValue != 0
            {
                titleLabel.text = "Game crashed"
                descriptionLabel.text = "Check the console log below to find a possible cause for the error. Afterwards, close and restart the application to play again."
            }
            else if gameInterrupted
            {
                titleLabel.text = "Game interrupted"
                descriptionLabel.text = "To start playing again, close and restart the application."
            }
            else
            {
                titleLabel.text = "Game over"
                descriptionLabel.text = "To play again, close and restart the application."
            }
            
            titleLabel.hidden = false
            descriptionLabel.hidden = false
            consoleTableView.hidden = false
            
            consoleTableView.reloadData()

            let messagesCount = Sys_MessagesCount()
            
            if messagesCount > 0
            {
                copyLogButton.hidden = false

                let lastMessage = NSIndexPath(forRow: messagesCount - 1, inSection: 0)
                consoleTableView.scrollToRowAtIndexPath(lastMessage, atScrollPosition: .Bottom, animated: true)
            }
        }
    }
    
    func cardboardView(cardboardView: GVRCardboardView!, willStartDrawing headTransform: GVRHeadTransform!)
    {
        gl_screenwidth = Int32(UIScreen.mainScreen().bounds.size.width * UIScreen.mainScreen().scale)
        gl_screenheight = Int32(UIScreen.mainScreen().bounds.size.height * UIScreen.mainScreen().scale)
        
        glvr_mode = 2
        glvr_eyecount = 2
        
        NSUserDefaults.standardUserDefaults().registerDefaults(["lanConfig_joinname" : "", "lanConfig_port" : 26000, "net_ipaddress" : "", "cl_name" : "", "sys_commandlineindex" : 1, "sys_commandline2" : "-game hipnotic -hipnotic", "sys_commandline3" : "-rogue", "sys_logmaxlines" : 1000])
        
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

        Sys_Init(NSBundle.mainBundle().resourcePath!, try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true).path!, commandLine!)
        
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
            
            sys_ended = qboolean(1)

            setupEndingScreen()
        }
    }
    
    func cardboardView(cardboardView: GVRCardboardView!, shouldPauseDrawing pause: Bool)
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
                    
                    Sys_Key_Event(255, qboolean(1)) // K_PAUSE, true
                    Sys_Key_Event(255, qboolean(0)) // K_PAUSE, false
                    
                    Sys_Key_Event(27, qboolean(1)) // K_ESCAPE, true
                    Sys_Key_Event(27, qboolean(0)) // K_ESCAPE, false
                    
                }
                
                remote!.extendedGamepad!.dpad.up.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Sys_Key_Event(128, qboolean(pressed ? 1 : 0)) // K_UPARROW, true / false
                }
                
                
                remote!.extendedGamepad!.dpad.left.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Sys_Key_Event(130, qboolean(pressed ? 1 : 0)) // K_LEFTARROW, true / false
                    
                }
                
                remote!.extendedGamepad!.dpad.right.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Sys_Key_Event(131, qboolean(pressed ? 1 : 0)) // K_RIGHTARROW, true / false
                    
                }
                
                remote!.extendedGamepad!.dpad.down.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Sys_Key_Event(129, qboolean(pressed ? 1 : 0)) // K_DOWNARROW, true / false
                    
                }
                
                remote!.extendedGamepad!.buttonA.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Sys_Key_Event(13, qboolean(pressed ? 1 : 0)) // K_ENTER, true / false
                    
                }
                
                remote!.extendedGamepad!.buttonB.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    Sys_Key_Event(27, qboolean(pressed ? 1 : 0)) // K_ESCAPE, true / false
                    
                }
                
                remote!.extendedGamepad!.buttonY.pressedChangedHandler = { (button: GCControllerButtonInput, value: Float, pressed: Bool) -> () in
                    
                    if (!pressed)
                    {
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
                    
                    Sys_Key_Event(133, qboolean(pressed ? 1 : 0)) // K_CTRL, true / false
                    
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
        if remote == notification.object as! GCController!
        {
            remote!.playerIndex = .IndexUnset
            
            in_forwardmove = 0.0
            in_sidestepmove = 0.0
            in_rollangle = 0.0
            in_pitchangle = 0.0
            
            remote = nil
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return Int(Sys_MessagesCount())
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let identifier = "consoleCell"
        
        var cell = consoleTableView.dequeueReusableCellWithIdentifier(identifier)
        
        if cell == nil
        {
            cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
            cell!.textLabel!.font = UIFont(name: "Courier", size: 10.0)
        }
        
        cell!.textLabel!.text = String.fromCString(Sys_GetMessage(Int32(indexPath.row)))
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 12.0
    }
    
    @IBAction func onCopyLog(sender: UIButton)
    {
        var log : String = ""
        
        let messageCount = Sys_MessagesCount()
        
        for messageIndex in 0...messageCount - 1
        {
            log += String.fromCString(Sys_GetMessage(Int32(messageIndex)))!
        }
        
        UIPasteboard.generalPasteboard().string = log
        
        copyLogButton.setTitle("Log copied.", forState: .Disabled)
        copyLogButton.enabled = false
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

