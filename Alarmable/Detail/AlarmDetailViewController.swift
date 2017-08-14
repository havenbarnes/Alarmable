//
//  DetailViewController.swift
//  Alarmable
//
//  Created by Haven Barnes on 6/1/17.
//  Copyright © 2017 Azing. All rights reserved.
//

import UIKit
import EventKit
import RealmSwift
import ContactsUI

class AlarmDetailViewController: UITableViewController, UITextFieldDelegate, CNContactPickerDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var alarmLabel: UITextField!
    @IBOutlet weak var repeatsSwitch: UISwitch!

    var headerWhiteView: UIView?
    
    var detailItem: Alarm?
    private var alarm = Alarm()
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if detailItem != nil {
            // Replace new alarm with existing 
            // one that we are editing
            alarm = detailItem!
            navigationItem.rightBarButtonItem = nil
        }
        
        configureView()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = -self.tableView.contentOffset.y
        
        if headerWhiteView == nil {
            headerWhiteView = UIView()
            headerWhiteView?.backgroundColor = UIColor.white
            let window = UIApplication.shared.keyWindow
            window?.addSubview(headerWhiteView!)
        }
        
        if y > 0 {
            headerWhiteView?.frame = CGRect(x: 0, y: 64, width: tableView.frame.width, height: y)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        headerWhiteView?.alpha = 0
        headerWhiteView?.removeFromSuperview()
        headerWhiteView = nil
        
        if detailItem != nil {
            updateAlarm()
        }
    }
    
    func configureView() {
        alarmLabel.delegate = self
        repeatsSwitch.onTintColor = UIColor.purple

        guard let alarm = detailItem else { return }
        titleLabel.text = "Edit Alarm"
        timePicker.date = alarm.fireDate.modernized()
        alarmLabel.text = alarm.label
        repeatsSwitch.setOn(alarm.repeats, animated: false)

    }
    
    // MARK: - Actions
    @IBAction func saveButtonPressed(_ sender: Any) {
        try! realm.write {
            realm.add(alarm)
        }
        
        alarm.enable()
        
        navigationController?.popViewController(animated: true)
    }
    
    func updateAlarm() {
        if alarm.isEnabled {
            alarm.disable()
            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: {
                timer in
                
                self.alarm.enable()
            })
        }
    }
    
    @IBAction func timeChanged(_ sender: Any) {
        try! realm.write {
            alarm.fireDate = timePicker.date as NSDate
            alarm.fireDate = alarm.fireDate.modernized() as NSDate
        }
    }
    
    @IBAction func labelValueChanged(_ sender: Any) {
        try! realm.write {
            alarm.label = alarmLabel.text
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    @IBAction func repeatsSwitchChanged(_ sender: Any) {
        try! realm.write {
            alarm.repeats = repeatsSwitch.isOn
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if detailItem == nil {
            return 2 + alarm.friends.count
        } else {
            return 4 + alarm.friends.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard indexPath.row > 1 else {
            return tableView.dequeueReusableCell(withIdentifier: "detailCell\(indexPath.row)", for: indexPath)
        }
        
        if indexPath.row < 2 + alarm.friends.count {
            // Friend Cell
            let cell = tableView
                .dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendCell
            
            let friendIndex = indexPath.row - 2
            let friend = alarm.friends[friendIndex]
            cell.nameLabel.text = friend.name
            
            return cell
        }
        
        if indexPath.row == 2 + alarm.friends.count {
            return tableView.dequeueReusableCell(withIdentifier: "deleteSpaceCell", for: indexPath)
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "deleteCell", for: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            guard indexPath.row == 1 else { return }
            showContactPicker()
            break
        case 3 + alarm.friends.count:
            detailItem = nil
            alarm.disable()
            try! realm.write {
                realm.delete(alarm)
            }
            navigationController?.popViewController(animated: true)
            break
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row > 1 && indexPath.row < 2 + alarm.friends.count {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            guard let existingAlarm = detailItem else {
                alarm.friends.remove(objectAtIndex: indexPath.row - 2)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                return
            }

            try? realm.write {
                realm.delete(existingAlarm.friends[indexPath.row - 2])
                
                DispatchQueue.main.async {
                    tableView.deleteRows(at: [indexPath], with: .top)
                }
            }
            
        }
    }
    
    func showContactPicker() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0")
        contactPicker.displayedPropertyKeys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        
        present(contactPicker, animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        picker.dismiss(animated: true, completion: nil)
        
        
        var selectedPhoneNumber = ""
        
        let addFriend = {
            for friend in self.alarm.friends {
                if self.clean(selectedPhoneNumber) == friend.phoneNumber {
                    return
                }
            }
            
            let newFriend = Friend()
            newFriend.name = contact.givenName + " " + contact.familyName
            newFriend.phoneNumber = self.clean(selectedPhoneNumber)
            
            try! self.realm.write {
                self.alarm.friends.append(newFriend)
            }
            
            let newIndexPath = IndexPath(item: self.alarm.friends.count + 1, section: 0)
            self.tableView.insertRows(at: [newIndexPath], with: .automatic)
            self.tableView.scrollToRow(at: newIndexPath, at: .middle, animated: false)
        }

        
        // Allow user to select phone number if selected contact has multiple
        if contact.phoneNumbers.count > 1 {
            let alert = UIAlertController(title: "Select A Phone Number For \(contact.givenName)", message: nil, preferredStyle: .actionSheet)
            
            for number in contact.phoneNumbers {
                
                let numberSelectAction = UIAlertAction(title: number.value.stringValue, style: .default) { (action) in
                    
                    selectedPhoneNumber = number.value.stringValue
                    addFriend()
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(numberSelectAction)
            }
            
            present(alert, animated: true, completion: nil)
            
        } else {
            selectedPhoneNumber = contact.phoneNumbers.first!.value.stringValue
            addFriend()
        }
    }
    
    /// Parses out any non-numerical characters from phone number
    func clean(_ phoneNumber: String) -> String {
        
        let cleansedPhone = phoneNumber
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "+1", with: "")
            .replacingOccurrences(of: " ", with: "")
        
        print("Cleansed \(phoneNumber) down to \(cleansedPhone)")
        
        return cleansedPhone
    }
    
}

