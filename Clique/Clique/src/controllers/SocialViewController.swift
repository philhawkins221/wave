//
//  SocialViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 3/28/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import UIKit

class SocialViewController: UIViewController {
    
    //MARK: - properties
    
    var delegate = SocialDelegate()
    
    //MARK: - outlets

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var options: UIView!
    @IBOutlet weak var optionscover: UIView!
    
    @IBOutlet weak var profilebar: ProfileBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NavigationControllerStyleGuide.enforce(on: navigationController)
        TabBarControllerStyleGuide.enforce(on: tabBarController)
        
        profilebar.controller = self
        
        //let delegate = SocialDelegate()
        table.delegate = delegate
        table.dataSource = delegate
        
        table.reloadData()
        
        guard let me = CliqueAPI.find(user: Identity.me) else { return }
        profilebar.manage(profile: me)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - actions
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    //MARK: - navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "options":
            guard let vc = segue.destination as? OptionsTableViewController else { return }
            profilebar.options = vc
            profilebar.optionscontainer = options
            profilebar.optionscover = optionscover
            vc.profilebar = profilebar
        default: break
        }
    }
    

}
