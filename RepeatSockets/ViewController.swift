//
//  ViewController.swift
//  RepeatSockets
//
//  Created by Andreas on 18.06.2021.
//

import UIKit

class ViewController: UIViewController {
    
    let networkManager = NetworkManager(host: "5.9.9.46", port: 2023)

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func tryConnect() {
        networkManager.connectRequest()
    }
    
    @IBAction func login() {
        networkManager.authRequest(login: "fort", password: "fort")
    }
    
    
    @IBAction func syncRequest() {
        networkManager.syncRequest()
    }
    
    @IBAction func busRequest() {
        networkManager.busRequest()
    }
    
    @IBAction func pointRequest() {
        networkManager.pointRequest()
    }
}

