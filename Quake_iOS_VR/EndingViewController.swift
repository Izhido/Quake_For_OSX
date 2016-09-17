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
            copyLogButton.isHidden = false
            
            let lastMessage = IndexPath(row: messagesCount - 1, section: 0)
            consoleTableView.scrollToRow(at: lastMessage, at: .bottom, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return Int(Sys_MessagesCount())
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let identifier = "consoleCell"
        
        var cell = consoleTableView.dequeueReusableCell(withIdentifier: identifier)
        
        if cell == nil
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
            cell!.textLabel!.font = UIFont(name: "Courier", size: 10.0)
        }
        
        cell!.textLabel!.text = String(cString: Sys_GetMessage(Int32((indexPath as NSIndexPath).row)))
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 12.0
    }
    
    @IBAction func onCopyLog(_ sender: UIButton)
    {
        var log : String = ""
        
        let messageCount = Sys_MessagesCount()
        
        for messageIndex in 0...messageCount - 1
        {
            log += String(cString: Sys_GetMessage(Int32(messageIndex)))
        }
        
        UIPasteboard.general.string = log
        
        copyLogButton.setTitle("Log copied.", for: .disabled)
        copyLogButton.isEnabled = false
    }
    
    func controllerDidConnect(_ notification: Notification)
    {
        GameControllerSetup.connect(notification.object as! GCController!)
    }
    
    func controllerDidDisconnect(_ notification: Notification)
    {
        GameControllerSetup.disconnect(notification.object as! GCController!)
    }
}
