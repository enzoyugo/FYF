//
//  SettingsVC.swift
//  FYF Beta
//
//  Created by enzo on 4/3/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func inviteFriendsBtn(_ sender: Any) {
        let activityVC = UIActivityViewController(activityItems: ["FindyourFit el papi"], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func helpBtn(_ sender: Any) {
        let appURL = URL(string: "mailto:ayuda.findyourfit@gmail.com")!
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(appURL)
        }
    }
}
