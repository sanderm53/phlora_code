//
//  TestViewController.swift
//  QGTut
//
//  Created by mcmanderson on 6/14/18.
//  Copyright © 2018 mcmanderson. All rights reserved.
//

import UIKit



//class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
class StudyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate {
//class StudyViewController: UITableViewController, UIDocumentPickerDelegate {

	var treeViewStatusBar:UILabel!
	var studyTableView:UITableView!
	// NO SHOULDN"T DO THE FOLLOWING HERE: GETS REDONE EVERY TIME WE LAUNCH STUDY VIEW...
//	let treesData = TreesData() // Initializes this once when the view controller is instantiated
var treesData:TreesData!
	var pickedRowIndex:Int = 0
	let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonAction))
//	var safeFrame:CGRect!
	//var treeViewController = TreeViewController()

	override func viewDidAppear(_ animated: Bool)
		{
		super.viewDidAppear(animated)
		}

	
	override func viewWillAppear(_ animated: Bool)
		{
		super.viewWillAppear(animated)
        navigationController!.setToolbarHidden(true, animated: false)
		//navigationController!.setNavigationBarHidden(false, animated: false)
		}

	func addButtonAction(sender: UIBarButtonItem!) {

		//let vc = UIDocumentPickerViewController(documentTypes: ["public.text","public.jpeg"],in: .import)
		let vc = UIDocumentPickerViewController(documentTypes: ["public.text"],in: .import)
		vc.delegate = self
		present(vc, animated: true)
	}
	func editButtonAction(sender: UIBarButtonItem!) {
		if studyTableView.isEditing
			{
			studyTableView.setEditing(false, animated: true)
			sender.title = "Edit"
			}
		else
			{
			studyTableView.setEditing(true, animated: true)
			sender.title = "Done"
			}
	}
func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController)
	{
	dismiss(animated: true)
	}

func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL])
	{
	print (urls.first)
	if let url = urls.first
		{
		do
			{
			let treeInfo = try TreeInfoPackage(fromURL: url)
			treeInfo.dataLocation = .inDocuments // have to initialize this here when loading new tree on the fly
			treesData.appendTreesData(withTreeInfo: treeInfo)
			//studyTableView.reloadData()
			studyTableView.beginUpdates()
			studyTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .right) // maybe should insert alphabetically?
			studyTableView.endUpdates()

			_ = try copyURLToDocs(src:url, srcFileType: .treeFile, forStudy: treeInfo.treeName, atNode:nil)
			}
		catch
			{
			//print ("Failed to read file or parse file")
			let alert = UIAlertController(title:"Error accessing tree file",message:"Failed to read, parse or save tree file", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in  NSLog("The alert occurred")}))
			self.present(alert,animated:true,completion:nil)
			}
		
		}
	}


	override func viewDidLoad()
		{
		super.viewDidLoad()

	do {
		treesData = try TreesData() // Initializes this once when the view controller is instantiated
		}
	catch
		{ print ("Error instantiating treesData")}


		self.title = "Studies" // This will be displayed in middle button of navigation bar at top

// view for the study table popup containing the table view and headers and footers

		let studyPUBackgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
		view.backgroundColor=studyPUBackgroundColor
		navigationController!.setNavigationBarHidden(false, animated: false)
        navigationController!.setToolbarHidden(true,
             animated: false)

//self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonAction)) // docs advisee initializing this when vc is initialized, but I want the action code to be here...

let addButton =  UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonAction))
//let editButton =  UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonAction))
let editButton =  UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonAction))
//let doneButton =  UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonAction))
// yuck do I really have to toggle both buttons to mimic the tableviewcontroller behavior?
//self.navigationItem.rightBarButtonItems = [editButtonItem, addButton]
self.navigationItem.rightBarButtonItems = [editButton, addButton]

// table view
		studyTableView = UITableView()
		studyTableView.delegate=self
		studyTableView.dataSource = self
		//studyTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell") // This is calling a class name for the cell, but here it is just the root UITableViewCell class; if I want to init this to a different default style prob have to subclass it
		studyTableView.register(StudyTableViewCell.self, forCellReuseIdentifier: "cell") // This is calling a class name for the cell, but here it is just the root UITableViewCell class; if I want to init this to a different default style prob have to subclass it
		studyTableView.isHidden=false
		studyTableView.backgroundColor=studyPUBackgroundColor
		studyTableView.rowHeight=treeSettings.studyTableRowHeight
		//studyTableView.separatorStyle = .none
		//studyTableView.sectionIndexColor = UIColor.white
		view.addSubview(studyTableView)


		studyTableView.translatesAutoresizingMaskIntoConstraints=false
		let margins = view.readableContentGuide
		studyTableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
		studyTableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
		studyTableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
		studyTableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true




 		}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
		}


   override func viewDidLayoutSubviews()
   		{
		super.viewDidLayoutSubviews()
    	}




	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
	
		super.viewWillTransition(to: size, with: coordinator)

		}


// UITableView delegate methods used

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return treesData.treeInfoNamesSortedArray.count
	}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StudyTableViewCell
		let treeName = treesData.treeInfoNamesSortedArray[indexPath.row]
// I set up the cell using a property observer in cell controller, which watches treeInfo property
		cell.treeInfo = treesData.treeInfoDictionary[treeName]

		if indexPath.row == pickedRowIndex
			{
			cell.accessoryType = .checkmark
			}
		else
			{
			cell.accessoryType = .none
			}
		return cell
	}

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
		{
		tableView.deselectRow(at: indexPath, animated: true)
		if indexPath.row != pickedRowIndex
			{
			var cell = tableView.cellForRow(at: IndexPath(row:pickedRowIndex, section:0))
			cell?.accessoryType = .none
			cell = tableView.cellForRow(at: indexPath)
			cell?.accessoryType = .checkmark
			//pickedRowIndex = indexPath.row
			}
		pickedRowIndex = indexPath.row

		transitionToTreeView(atStudyIndex: pickedRowIndex)
		}

func tableView(_ tableView:UITableView, canEditRowAt indexPath:IndexPath)->Bool
	{
	// only allow deletion of user added studies
		let treeName = treesData.treeInfoNamesSortedArray[indexPath.row]
		let treeInfo = treesData.treeInfoDictionary[treeName]
		if treeInfo?.dataLocation == .inDocuments
			{ return true }
		else
			{ return false }
	}
func tableView(_ tableView:UITableView, commit editingStyle:UITableViewCellEditingStyle, forRowAt indexPath:IndexPath)
	{
	if editingStyle == .delete
		{
		let alert = UIAlertController(title:"Really delete all data for this study from Phlora?",message:"", preferredStyle: .alert)
		let action1 = UIAlertAction(title: "Cancel", style: .cancel)
			{ (action:UIAlertAction) in self.dismiss(animated:true) }
		let action2 = UIAlertAction(title: "Delete", style: .default)
			{ (action:UIAlertAction) in
			self.deleteStudyFromDocuments(at: indexPath)
			}
		alert.addAction(action1)
		alert.addAction(action2)
		present(alert, animated: true, completion: nil)
		}
	}

	func deleteStudyFromDocuments(at indexPath:IndexPath)
		{
		let studyName = treesData.treeInfoNamesSortedArray[indexPath.row]
		guard let treeInfo = treesData.treeInfoDictionary[studyName]
		else { return }
		treesData.treeInfoNamesSortedArray.remove(at:indexPath.row)
		treesData.treeInfoNamesSortedArray = treesData.treeInfoNamesSortedArray.sorted(by: <)
		studyTableView.beginUpdates()
		studyTableView.deleteRows(at: [indexPath], with: .fade)
		studyTableView.endUpdates()
		if let studyDir = docDirectoryNameFor(treeInfo:treeInfo, ofType:.study)
			{
			print ("NEED TO DELETE:", studyDir)
			}
		}

	func transitionToTreeView(atStudyIndex ix:Int)
		{

		let treeName = treesData.treeInfoNamesSortedArray[ix]
		let treeInfo = treesData.treeInfoDictionary[treeName]!


		if treeInfo.treeViewController == nil
			{ treeInfo.treeViewController = TreeViewController() }
		treeInfo.treeViewController!.treesData = treesData
		treeInfo.treeViewController!.pickedRowIndex = pickedRowIndex

		self.navigationController?.pushViewController(treeInfo.treeViewController!, animated: true)

		}
}



