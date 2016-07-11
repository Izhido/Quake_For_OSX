//
//  ViewController.swift
//  Quake_Asset_Generator
//
//  Created by Heriberto Delgado on 7/11/16.
//
//

import Cocoa

class ViewController: NSViewController
{
    @IBOutlet weak var assetView: AssetGeneratorView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject?
    {
        didSet
        {
            // Update the view, if already loaded.
        }
    }

    func loadAsset(type: AssetType)
    {
        if assetView.assetType != type
        {
            if type == .Icon
            {
                assetView.pointSize = 180.0
            }
            else
            {
                assetView.level = 0.0
            }
        }
        else
        {
            if type == .Icon
            {
                assetView.pointSize = assetView.nextPointSize()
            }
            else
            {
                assetView.level += 1.0
            }
        }
        assetView.assetType = type
        assetView.preview = true
        assetView.needsDisplay = true
    }
    
    @IBAction func generateButtonClick(sender: AnyObject)
    {
        if assetView.assetType != .None
        {
            if assetView.assetType == .Icon
            {
                assetView.pointSize = 180.0
            }
            else
            {
                assetView.level = 0.0
            }
            assetView.generate = true
            assetView.needsDisplay = true
        }
    }
    
    @IBAction func setIconButtonClick(sender: NSButton)
    {
        loadAsset(.Icon)
    }    
}
