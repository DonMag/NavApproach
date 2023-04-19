//
//  ViewController.swift
//  NavApproach
//
//  Created by Don Mag on 4/19/23.
//

import UIKit

struct MyUserStruct {
	var name: String = ""
	var info: String = ""
	var notes: String = ""
}

class DataSingleton {
	static let shared = DataSingleton()
	var theData: [MyUserStruct] = []
}

class MainCell: UITableViewCell {
	@IBOutlet var nameLabel: UILabel!
}

class MainListTableViewController: UITableViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = "List"
		
		// let's create a couple user data items
		
		DataSingleton.shared.theData.append(MyUserStruct(name: "Bob", info: "Bob's info", notes: "Bob's notes"))
		DataSingleton.shared.theData.append(MyUserStruct(name: "Dave", info: "Dave's info", notes: "Dave's notes"))
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return DataSingleton.shared.theData.count
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let c = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as! MainCell
		c.nameLabel.text = DataSingleton.shared.theData[indexPath.row].name
		return c
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? ViewUserTableViewController,
		   let pth = tableView.indexPathForSelectedRow
		{
			vc.userIDX = pth.row
			vc.dataChanged = { [weak self] in
				guard let self = self else { return }
				self.tableView.reloadData()
			}
		}
		if let vc = segue.destination as? EditUserTableViewController
		{
			vc.userIDX = -1
			vc.dataChanged = { [weak self] in
				guard let self = self else { return }
				self.tableView.reloadData()
			}
		}
	}
}

class ViewUserTableViewController: UITableViewController {

	var dataChanged: (() -> ())?
	
	var userIDX: Int = 0
	
	@IBOutlet var nameTextField: UITextField!
	@IBOutlet var infoTextView: UITextView!
	@IBOutlet var notesTextView: UITextView!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "View User"
		
		nameTextField.isUserInteractionEnabled = false
		infoTextView.isUserInteractionEnabled = false
		notesTextView.isUserInteractionEnabled = false
		
		updateData()
	}
	func updateData() {
		let theUser = DataSingleton.shared.theData[userIDX]
		nameTextField.text = theUser.name
		infoTextView.text = theUser.info
		notesTextView.text = theUser.notes
	}
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? EditUserTableViewController {
			vc.userIDX = self.userIDX
			vc.dataChanged = { [weak self] in
				guard let self = self else { return }
				self.updateData()
				self.dataChanged?()
			}
		}
	}
}

class EditUserTableViewController: UITableViewController {
	
	var dataChanged: (() -> ())?
	
	var userIDX: Int = -1
	var theUser: MyUserStruct = MyUserStruct()

	@IBOutlet var navBar: UINavigationBar!
	
	@IBOutlet var nameTextField: UITextField!
	@IBOutlet var infoTextView: UITextView!
	@IBOutlet var notesTextView: UITextView!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		if userIDX == -1 {
			navBar.topItem?.title = "New User"
			nameTextField.text = ""
			infoTextView.text = ""
			notesTextView.text = ""
		} else {
			theUser = DataSingleton.shared.theData[userIDX]
			navBar.topItem?.title = "Edit User"
			nameTextField.text = theUser.name
			infoTextView.text = theUser.info
			notesTextView.text = theUser.notes
		}
	}
	
	@IBAction func saveTapped(_ sender: Any) {
		let s1 = nameTextField.text ?? ""
		let s2 = infoTextView.text ?? ""
		let s3 = notesTextView.text ?? ""
		
		if s1.isEmpty {
			// show an error, because the name cannot be blank
		} else {
			theUser.name = s1
			theUser.info = s2
			theUser.notes = s3
			if userIDX == -1 {
				// new user
				DataSingleton.shared.theData.append(theUser)
			} else {
				DataSingleton.shared.theData[userIDX] = theUser
			}
			dataChanged?()
			dismiss(animated: true)
		}
	}
	
	@IBAction func cancelTapped(_ sender: Any) {
		dismiss(animated: true)
	}
	
}
