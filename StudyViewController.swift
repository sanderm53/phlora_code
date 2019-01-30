//
//  TestViewController.swift
//  QGTut
//
//  Created by mcmanderson on 6/14/18.
//  Copyright © 2019 Michael J Sanderson. All rights reserved.
//

import UIKit

// Displays a table view of the studies currently accessible to Phlora 

class StudyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate, ImageSelectorDelegate {

	var treeViewStatusBar:UILabel!
	var studyTableView:UITableView!
	var treesData:TreesData!
	var pickedRowIndex:Int = 0
	//let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonAction))

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

	func addButtonAction(sender: UIBarButtonItem!)
		{
		let vc = UIDocumentPickerViewController(documentTypes: ["public.text"],in: .import)
		vc.delegate = self
		present(vc, animated: true)
		}

	func editButtonAction(sender: UIBarButtonItem!)
		{
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
				showAlertMessage ("Failed to read, parse or save tree file", onVC:self)
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
			{ showAlertMessage ("Error loading study data", onVC:self)}

		self.title = "Studies" // This will be displayed in middle button of navigation bar at top

		// view for the study table popup containing the table view and headers and footers

		let studyPUBackgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
		view.backgroundColor=studyPUBackgroundColor
		navigationController!.setNavigationBarHidden(false, animated: false)
        navigationController!.setToolbarHidden(true,
             animated: false)

		//self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonAction)) // docs advise initializing this when vc is initialized, but I want the action code to be here...

		let addButton =  UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonAction))
		let editButton =  UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonAction))
		self.navigationItem.rightBarButtonItems = [editButton, addButton]

		// table view
		studyTableView = UITableView()
		studyTableView.delegate=self
		studyTableView.dataSource = self
		studyTableView.register(StudyTableViewCell.self, forCellReuseIdentifier: "cell") // This is calling a class name for the cell, but here it is just the root UITableViewCell class; if I want to init this to a different default style prob have to subclass it
		studyTableView.isHidden=false
		//studyTableView.backgroundColor=studyPUBackgroundColor
		studyTableView.backgroundColor=nil // transparent, keep view color
		studyTableView.rowHeight=treeSettings.studyTableRowHeight
		view.addSubview(studyTableView)

		studyTableView.translatesAutoresizingMaskIntoConstraints=false
		let margins = view.readableContentGuide
		studyTableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
		studyTableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
		studyTableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
		studyTableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
 		}

	override func didReceiveMemoryWarning()
		{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
		}

   override func viewDidLayoutSubviews()
   		{
		super.viewDidLayoutSubviews()
    	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
		{
		super.viewWillTransition(to: size, with: coordinator)
		}


// UITableView delegate methods used

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
		{
		return treesData.treeInfoNamesSortedArray.count
		}

 	func handleTap(gesture: UITapGestureRecognizer)
 		{
		//print ("Time to add an image")
		let imagePane = gesture.view as! ImagePaneView
		switch gesture.state
			{
			case UIGestureRecognizerState.began:
				break
			case UIGestureRecognizerState.changed:
				break
			case UIGestureRecognizerState.ended:
				if imagePane.imageIsLoaded == false
					{
					let touchPt = imagePane.convert(gesture.location(in:imagePane), to : studyTableView)
					if let ip = studyTableView.indexPathForRow(at:touchPt)
						{
						let cell = studyTableView.cellForRow(at:ip) as! StudyTableViewCell
						let sourceRect = imagePane.frame // This frame is relative to the cell view's bounds rect and works
						let iS = ImageSelector(receivingImagePane:imagePane, calledFromViewController:self, delegate:self, callingView:cell, atRect: sourceRect)
						iS.selectImage()
						}
					}
			default:
				break
			}
		}

// Handle the image selected from file system. This is required by the ImageSelector delegate protocol
	func imageSelector(_ imageSelector: ImageSelector, didSelectImage image: UIImage)
		{
		let cell = imageSelector.sourceView as! StudyTableViewCell
		cell.treeInfo!.thumbStudyImage = resizeUIImageToFitSquare(image, withHeight:treeSettings.studyTableRowHeight) // necessary to resize this every time NO? Mucked with prop observer in cell code

		// save to disk...
		do
			{
			if let fileNameBase = cell.treeInfo?.treeName, let targetDir = docDirectoryNameFor(study: cell.treeInfo!.treeName, inLocation:cell.treeInfo!.dataLocation!, ofType:.images, create:true)
				{ _ = try copyImageToDocs(srcImage:image, copyToDir: targetDir, usingFileNameBase: fileNameBase) }
			}
		catch
			{
			showAlertMessage ("Error saving image file to Phlora", onVC: self)
			}

		// Tableview nonsense. Tableview won't let me use constraints as normal. Have to reload a row to get the cell to enforce constraints way I want.
		if let ip = studyTableView.indexPath(for: cell)
			{
			studyTableView.beginUpdates()
			studyTableView.reloadRows(at: [ip], with: .right)
			studyTableView.endUpdates()
			}
		}
	
	func imageSelector(_ imageSelector: ImageSelector, didSelectDirectory url: URL)
		{
		}

	func deleteAllGestureRecognizersFrom(view:UIView)
		{
		if let grs = view.gestureRecognizers
			{
			for gr in grs { view.removeGestureRecognizer(gr) }
			}

		}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
			let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StudyTableViewCell
			let treeName = treesData.treeInfoNamesSortedArray[indexPath.row]
			// I set up the cell using a property observer in cell controller, which watches treeInfo property!!
			// When tableView needs to display this cell, the prop observer will make sure to (re)load image and setNeedsLayout in that class defn
			cell.treeInfo = treesData.treeInfoDictionary[treeName]

			deleteAllGestureRecognizersFrom(view:cell.studyImagePane) // yikes, otherwise these could stack up over time with cell reuse
			// Note on GR here. If you inadvertantly leave a GR to launch the tree, then it will conflict with the GR to add image and throw runtime error. Make sure to cancelTouchesView for an addimage pane but make sure it is NOT there for cells with images.
			if cell.studyImagePane.imageIsLoaded == false  // the new cell row has no study image; add add gesture
				{
				let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
				tapGesture.cancelsTouchesInView = true // when adding an image, stop the touch event from going up to the tableview and mistakenly leading to selection of the row
				cell.studyImagePane.addGestureRecognizer(tapGesture)
				}
			//if cell.treeInfo?.treeViewController != nil // put a checkmark here if you have instantiated a treeVC here before
			// Not working as desired
			//	{ cell.accessoryType = .checkmark }
			//else
			//	{ cell.accessoryType = .none }
			return cell
		}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
			{
			tableView.deselectRow(at: indexPath, animated: true)
			//if indexPath.row != pickedRowIndex
			//	{
				//var cell = tableView.cellForRow(at: IndexPath(row:pickedRowIndex, section:0))
				//cell?.accessoryType = .none
				//cell = tableView.cellForRow(at: indexPath)
				//cell?.accessoryType = .checkmark
				//pickedRowIndex = indexPath.row
			//	}
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
				// And we have to return the screen to non-editing mode...(else selection of studies in table is disabled until done editing, which can be confusing if it looks like no rows are being edited on that screenful)
				self.studyTableView.setEditing(false, animated: true)
				if let rightBarButtons = self.navigationItem.rightBarButtonItems
					{ rightBarButtons[0].title = "Edit"}
					// Another little mystery: I couldn't instantiate this button at top of class and use it; had to make it a 'let' in viewDidLoad and then fetch the stupid thing from here. My bad.
				}
			alert.addAction(action1)
			alert.addAction(action2)
			present(alert, animated: true, completion: nil)
			}
		}

	func deleteStudyFromDocuments(at indexPath:IndexPath)
		{
		let studyName = treesData.treeInfoNamesSortedArray[indexPath.row]
		guard let treeInfo = treesData.treeInfoDictionary[studyName] else { return }
		if let studyDir = docDirectoryNameFor(study: treeInfo.treeName, inLocation:treeInfo.dataLocation!, ofType:.study,create:false)
			{
			do {
				try FileManager.default.removeItem(at: studyDir)
				treesData.treeInfoNamesSortedArray.remove(at:indexPath.row)
				treesData.treeInfoNamesSortedArray = treesData.treeInfoNamesSortedArray.sorted(by: <)
				studyTableView.beginUpdates()
				studyTableView.deleteRows(at: [indexPath], with: .fade)
				studyTableView.endUpdates()
				}
			catch
				{
				showAlertMessage ("Error deleting this study", onVC:self)
				}
			}
		}

	func transitionToTreeView(atStudyIndex ix:Int)
		{

		let treeName = treesData.treeInfoNamesSortedArray[ix]
		let treeInfo = treesData.treeInfoDictionary[treeName]!


		if treeInfo.treeViewController == nil
			{ treeInfo.treeViewController = TreeViewController() }
		treeInfo.treeViewController!.treesData = treesData // seems like this should be done when vc is init-ed?
		treeInfo.treeViewController!.pickedRowIndex = pickedRowIndex

		self.navigationController?.pushViewController(treeInfo.treeViewController!, animated: true)

		}


	


}



