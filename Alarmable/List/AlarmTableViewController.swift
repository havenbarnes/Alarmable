//
//  MasterViewController.swift
//  Alarmable
//
//  Created by Haven Barnes on 6/1/17.
//  Copyright © 2017 Azing. All rights reserved.
//

import UIKit
import RealmSwift
import DZNEmptyDataSet
import UserNotifications

class AlarmTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    var alarms: Results<Alarm>!
    
    @IBOutlet weak var tableView: UITableView!
    
    var notificationToken: NotificationToken?
    deinit {
        notificationToken?.stop()
    }
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        alarms = realm.objects(Alarm.self).sorted(byKeyPath: "fireDate")
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        notificationToken = alarms.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            guard self != nil else { return }
            self!.realmDidUpdate(changes)
        }
        
        cleanupUsedAlarms()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !showOnboardingIfNeeded() {
            checkIfNotificationsEnabled()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hide()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.show()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // MARK: - Alarms
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "No Alarms"
        let attributes = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Semibold", size: 26)!,
                          NSForegroundColorAttributeName: UIColor("DBDBDB")]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func setupUI() {
        navigationController?.setSolidWhite()
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "EEEE, MMMM d"
        dateLabel.text = dateFormatter.string(from: Date()).uppercased()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 135
        
        tableView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.7, options: .curveEaseOut, animations: {
            self.tableView.alpha = 1
        }, completion: nil)
    }
    
    /// Sets Alarms to off if they have fired
    /// and weren't meant to repeat
    func cleanupUsedAlarms() {
        for alarm in alarms {
            if alarm.isEnabled
                && !alarm.repeats
                && (alarm.fireDate as Date) < Date() {
                
                try! realm.write {
                    alarm.isEnabled = false
                }
            }
        }
    }
    
    /// Checks to see if current user name is set, presents
    /// onboarding flow if not.
    /// Return Bool indicating whether onboarding was needed
    func showOnboardingIfNeeded() -> Bool {
        let showOnboarding = {
            let vc = self.instantiate("sbOnboardingNavViewController")
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
        
        if App.shared.userName == nil {
            showOnboarding()
            return true
        } else {
            return false
        }
    }
    
    /// Checks to see if user still has notifications
    /// enabled, points them in the right direction if not.
    func checkIfNotificationsEnabled() {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {
            settings in
            
            if settings.alertSetting == .disabled {
                self.showSettingsLink()
            }
        })
    }
    
    func showSettingsLink() {
        let alert = UIAlertController(title: "Push Notifications", message: "Push Notifications are required for alarms to work. Please turn them on for the best experience with Alarmable", preferredStyle: .alert)
        
        let linkAction = UIAlertAction(title: "Go To Settings", style: .default, handler: {
            action in
            
            let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        })
        
        alert.addAction(linkAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func realmDidUpdate(_ changes: RealmCollectionChange<Results<Alarm>>) {
        guard let tableView = self.tableView else { return }
        switch changes {
        case .initial:
            tableView.reloadData()
            break
        case .update(_, let deletions, let insertions, let modifications):
            tableView.beginUpdates()
            tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                 with: .automatic)
            tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                 with: .automatic)
            tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                 with: .automatic)
            tableView.endUpdates()
            break
        case .error(let error):
            print("\(error)")
            break
        }
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        let alarmViewController = instantiate("AlarmDetailViewController")
        title = "Cancel"
        navigationController?.show(alarmViewController, sender: nil)
    }
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath) as! AlarmCell
        let object = alarms[indexPath.row]
        cell.alarm = object
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alarmViewController = instantiate("AlarmDetailViewController") as! AlarmDetailViewController
        alarmViewController.detailItem = alarms[indexPath.row]
        title = "Save Changes"
        navigationController?.show(alarmViewController, sender: nil)
    }
}

