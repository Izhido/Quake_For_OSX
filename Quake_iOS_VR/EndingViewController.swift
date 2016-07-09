//
//  EndingViewController.swift
//  Quake_iOS_VR
//
//  Created by Heriberto Delgado on 7/8/16.
//
//

import UIKit
import GameController

class EndingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var consoleTableView: UITableView!
    
    @IBOutlet weak var copyLogButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        consoleTableView.dataSource = self
        consoleTableView.delegate = self
        
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
        
        consoleTableView.reloadData()
        
        let messagesCount = Sys_MessagesCount()
        
        if messagesCount > 0
        {
            copyLogButton.hidden = false
            
            let lastMessage = NSIndexPath(forRow: messagesCount - 1, inSection: 0)
            consoleTableView.scrollToRowAtIndexPath(lastMessage, atScrollPosition: .Bottom, animated: true)
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
    
    func controllerDidConnect(notification: NSNotification)
    {
        GameControllerSetup.connect(notification.object as! GCController!)
    }
    
    func controllerDidDisconnect(notification: NSNotification)
    {
        GameControllerSetup.disconnect(notification.object as! GCController!)
    }
}
