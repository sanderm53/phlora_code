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

	var treeViewStatusBar:UILabel!
	var studyTableView:UITableView!
	// NO SHOULDN"T DO THE FOLLOWING HERE: GETS REDONE EVERY TIME WE LAUNCH STUDY VIEW...
//	let treesData = TreesData() // Initializes this once when the view controller is instantiated
var treesData:TreesData!
	var pickedRowIndex:Int = 0
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

		let vc = UIDocumentPickerViewController(documentTypes: ["public.text","public.jpeg"],in: .import)
		//navigationController!.setNavigationBarHidden(false, animated: false)
		// Need to make frame smaller to adjust to show navigation bar...
		//self.navigationController?.pushViewController(vc, animated: true)
		vc.delegate = self
		present(vc, animated: true)
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
			treesData.appendTreesData(withTreeInfo: treeInfo)
print (treesData.treeInfoNamesSortedArray.count	)
studyTableView.reloadData()
		}
		catch {print ("Failed to read file or parse file")}
		
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

self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonAction)) // docs advisee initializing this when vc is initialized, but I want the action code to be here...


// table view
		studyTableView = UITableView()
		studyTableView.delegate=self
		studyTableView.dataSource = self
		//studyTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell") // This is calling a class name for the cell, but here it is just the root UITableViewCell class; if I want to init this to a different default style prob have to subclass it
		studyTableView.register(StudyTableViewCell.self, forCellReuseIdentifier: "cell") // This is calling a class name for the cell, but here it is just the root UITableViewCell class; if I want to init this to a different default style prob have to subclass it
		studyTableView.isHidden=false
		studyTableView.backgroundColor=studyPUBackgroundColor
		studyTableView.rowHeight=200.0
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



// ********************************** I have disabled device rotations in info.plist!, so the following is mute and not current

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
	
		super.viewWillTransition(to: size, with: coordinator)

		}


// UITableView methods for the delegate protocol
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return treesData.treeInfoNamesSortedArray.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StudyTableViewCell
		//let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
		//let backgroundView = UIView()
		//backgroundView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
		//cell.selectedBackgroundView = backgroundView

		//cell.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0) // doesn't inherit this from tableview




		//cell.textLabel!.textColor = UIColor.white
		//cell.textLabel!.font = UIFont(name:"Helvetica", size:24)
        //cell.textLabel!.text = treesData.treeInfoNamesSortedArray[indexPath.row]
		//cell.textLabel!.textAlignment = .center

		let treeName = treesData.treeInfoNamesSortedArray[indexPath.row]
		let nLeaves = treesData.treeInfoDictionary[treeName]!.nLeaves

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



