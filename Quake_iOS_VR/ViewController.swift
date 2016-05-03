//
//  ViewController.swift
//  Quake_iOS_VR
//
//  Created by Heriberto Delgado on 5/2/16.
//
//

import GLKit

class ViewController: UIViewController, GCSCardboardViewDelegate
{
    @IBOutlet weak var cardboardView: GCSCardboardView!

    private var displayLink: CADisplayLink! = nil
    
    private var previousTime: NSTimeInterval = -1
    
    private var currentTime: NSTimeInterval = -1
    
    private var firstEyeRendered: Bool = false
    
    private var lastEyeRendered: Bool = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.cardboardView.delegate = self
        self.cardboardView.vrModeEnabled = true
        
        displayLink = CADisplayLink(target: self, selector: "render")
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
    }

    func render()
    {
        cardboardView.render()
    }

    func cardboardView(cardboardView: GCSCardboardView!, willStartDrawing headTransform: GCSHeadTransform!)
    {
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

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

