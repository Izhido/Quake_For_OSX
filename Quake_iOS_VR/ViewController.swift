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
        gl_screenwidth = Int32(UIScreen.mainScreen().bounds.size.width * UIScreen.mainScreen().scale);
        gl_screenheight = Int32(UIScreen.mainScreen().bounds.size.height * UIScreen.mainScreen().scale);

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
        glvr_rotation = headTransform.headPoseInStartSpace().m
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

                remote!.extendedGamepad!.valueChangedHandler = { (gamepad: GCExtendedGamepad, element: GCControllerElement)->() in
                    
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

