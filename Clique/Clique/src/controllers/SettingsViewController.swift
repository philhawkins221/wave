//
//  SettingsViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 3/28/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    //MARK: - properties
    
    var mode: SettingsMode = .general
    var delegate: SettingsDelegate?

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var options: UIView!
    @IBOutlet weak var optionscover: UIView!
    @IBOutlet weak var closebutton: UIBarButtonItem?
    
    @IBOutlet weak var profilebar: ProfileBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NavigationControllerStyleGuide.enforce(on: navigationController)
        TabBarControllerStyleGuide.enforce(on: tabBarController)
        
        refresh()
        
        profilebar.controller = self
        
        guard let me = CliqueAPI.find(user: Identity.me) else { return }
        profilebar.manage(profile: me)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        table.indexPathsForSelectedRows?.forEach { table.deselectRow(at: $0, animated: true) }
        
        refresh()
    }
    
    //MARK: - tasks
    
    func kill(confirmed: Bool = false) {
        guard confirmed else { return Alerts.kill(on: self) }
        
        CliqueAPI.delete(user: Identity.me)
        Identity.me = ""
        UserDefaults.standard.set("", forKey: "id")
        
        Identity.wave()
        navigationController?.popToRootViewController(animated: true)
    }
    
    func refresh() {
        switch mode {
        case .general: delegate = SettingsDelegate(to: self)
        case .queue: delegate = QueueSettingsDelegate(to: self)
        case .sharing: delegate = SharingDelegate(to: self)
        case .help: delegate = HelpSettingsDelegate(to: self)
        }
        
        table.delegate = delegate
        table.dataSource = delegate
        
        table.reloadData()
    }
    
    func view(about: Void) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "about") else { return }        
        show(vc, sender: self)
    }
    
    func view(settings: SettingsMode) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "settings") as? SettingsViewController else { return }
        
        vc.mode = settings
        show(vc, sender: self)
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
