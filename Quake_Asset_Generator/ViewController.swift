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

    override var representedObject: Any?
    {
        didSet
        {
            // Update the view, if already loaded.
        }
    }

    func loadAsset(_ type: AssetType)
    {
        if assetView.assetType != type
        {
            if type == .icon
            {
                assetView.pointSize = 1024.0
            }
            else
            {
                assetView.level = 0.0
            }
        }
        else
        {
            if type == .icon
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
    
    @IBAction func generateButtonClick(_ sender: AnyObject)
    {
        if assetView.assetType != .none
        {
            if assetView.assetType == .icon
            {
                assetView.pointSize = 1024.0
            }
            else
            {
                assetView.level = 0.0
            }
            assetView.generate = true
            assetView.needsDisplay = true
        }
    }
    
    @IBAction func setIconButtonClick(_ sender: NSButton)
    {
        loadAsset(.icon)
    }    
}
