//
//  ViewController.swift
//  FYF Beta
//
//  Created by enzo on 3/8/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import ImageSlideshow
import Firebase

class HomeVC: UIViewController, UITableViewDelegate {
    
    
    override func viewDidLoad() {
        if let _ = Auth.auth().currentUser {
            presentHomeNC()
            
        } else {
            presentLoginController()
        }
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    fileprivate func presentHomeNC() {
        let storyboard = UIStoryboard(name: "HomeNC" , bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: Storyboard.FirstHomeVC)
        controller.tabBarController?.tabBar.isHidden = false
        present(controller, animated: true, completion: nil)
    }
    fileprivate func presentLoginController() {
        let storyboard = UIStoryboard(name: Storyboard.LoginStoryboard , bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: StoryboardId.LoginVC)
        
        present(controller, animated: true, completion: nil)
    }
    
}
