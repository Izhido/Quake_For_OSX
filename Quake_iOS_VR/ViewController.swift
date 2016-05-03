//
//  ViewController.swift
//  Quake_iOS_VR
//
//  Created by Heriberto Delgado on 5/2/16.
//
//

import UIKit

class ViewController: UIViewController, GCSCardboardViewDelegate
{
    @IBOutlet weak var cardboardView: GCSCardboardView!

    private var previousTime: NSTimeInterval = -1
    
    private var currentTime: NSTimeInterval = -1
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.cardboardView.delegate = self;
        self.cardboardView.vrModeEnabled = true;
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
        
        Sys_Frame()
    }

    func cardboardView(cardboardView: GCSCardboardView!, drawEye eye: GCSEye, withHeadTransform headTransform: GCSHeadTransform!)
    {
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

