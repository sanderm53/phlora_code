//
//  TestViewController.swift
//  QGTut
//
//  Created by mcmanderson on 6/14/18.
//  Copyright © 2018 mcmanderson. All rights reserved.
//

import UIKit



//class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
class ImageTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate, ImageSelectorDelegate, UIGestureRecognizerDelegate {

	//var treeViewStatusBar:UILabel!
	var imageTableView:UITableView!
	//var treesData:TreesData!
	var pickedRowIndex:Int = 0
	var xTree:XTree!
	var nodeArraySortedByLabel: [Node] = []
	var thumbArraySortedByLabel: [UIImage?] = []
	var alert: UIAlertController?

	
	let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonAction))

/*
	func createThumbArray () // creates a cache of thumbsized images for all leaves that have them; run this asynch, proceeds in sort order (alphabetically)
		{
		for ix in 0...nodeArraySortedByLabel.count-1
			{
			let node = nodeArraySortedByLabel[ix]
			if node.hasImageFile()
				{
				thumbArraySortedByLabel[ix] = resizeUIImageToFitSquare(UIImage(contentsOfFile:node.imageFileURL!.path)!, withHeight: treeSettings.studyTableRowHeight)
				}
			}
		}
*/

	
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

		let vc = UIDocumentPickerViewController(documentTypes: ["public.text"],in: .import)
		vc.delegate = self
		present(vc, animated: true)
		}

	func editButtonAction(sender: UIBarButtonItem!) {
		if imageTableView.isEditing
			{
			imageTableView.setEditing(false, animated: true)
			sender.title = "Edit"
			}
		else
			{
			imageTableView.setEditing(true, animated: true)
			sender.title = "Done"
			}
	}
func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController)
	{
	dismiss(animated: true)
	}

func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL])
	{
/*
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
*/
	}


	override func viewDidLoad()
		{
		super.viewDidLoad()
		//nodeArraySortedByLabel = xTree.nodeArray.sorted (by: {$0.originalLabel! < $1.originalLabel! } )
		nodeArraySortedByLabel = xTree.nodeArray.sorted (by: { 0 > $0.originalLabel!.localizedStandardCompare($1.originalLabel!).rawValue } )


		// Very IMPORTANT that array is initialized before the next async call is done or can get indexes out of range....
/*
		for _ in 0...nodeArraySortedByLabel.count-1
			{
			thumbArraySortedByLabel.append(nil)
			}
		DispatchQueue.global(qos: .userInitiated).async {
			//print ("Started create thumb")
			self.createThumbArray()
			//print ("Ended create thumb")
			}
*/
		self.title = "Images" // This will be displayed in middle button of navigation bar at top

// view for the study table popup containing the table view and headers and footers

		let studyPUBackgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
		view.backgroundColor=studyPUBackgroundColor
		//view.backgroundColor=UIColor.black
		navigationController!.setNavigationBarHidden(false, animated: false)
        navigationController!.setToolbarHidden(true,
             animated: false)

let addButton =  UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonAction))
let editButton =  UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonAction))
//self.navigationItem.rightBarButtonItems = [editButton, addButton]

// table view
		imageTableView = UITableView()
		imageTableView.delegate=self
		imageTableView.dataSource = self
		imageTableView.register(ImageTableViewCell.self, forCellReuseIdentifier: "cellImageTable") // This is calling a class name for the cell, but here it is just the root UITableViewCell class; if I want to init this to a different default style prob have to subclass it
		imageTableView.isHidden=false
		//studyTableView.backgroundColor=studyPUBackgroundColor
	imageTableView.backgroundColor=nil // transparent, keep view color
		imageTableView.rowHeight=treeSettings.studyTableRowHeight
		view.addSubview(imageTableView)

	self.imageTableView.estimatedRowHeight = 0; // Thanks to rshinich on Apple Devel Forum for suggesting these lines to cure the wonky behavior on async updates of the images...
    self.imageTableView.estimatedSectionHeaderHeight = 0;
    self.imageTableView.estimatedSectionFooterHeight = 0;


		imageTableView.translatesAutoresizingMaskIntoConstraints=false
		let margins = view.readableContentGuide
		imageTableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
		imageTableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
		imageTableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
		imageTableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true




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
			return nodeArraySortedByLabel.count
		}

 	func handleTap(gesture: UITapGestureRecognizer) {
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
						let touchPt = imagePane.convert(gesture.location(in:imagePane), to : imageTableView)
						if let ip = imageTableView.indexPathForRow(at:touchPt)
							{
							let cell = imageTableView.cellForRow(at:ip) as! ImageTableViewCell
							let sourceRect = imagePane.frame // This frame is relative to the cell view's bounds rect and works
							let iS = ImageSelector(receivingImagePane:imagePane, calledFromViewController:self, delegate:self, callingView:cell, atRect: sourceRect)
							iS.selectImage()
							}
						}
				default:
					break

				}

	}

func addLongTapGestureToDeleteImageFrom(_ ip:ImagePaneView)
	{
		let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleImagePaneLongPress(recognizer:)))
		longTapGesture.delegate = self
		ip.addGestureRecognizer(longTapGesture)
		longTapGesture.minimumPressDuration = 1.0
	}

func handleImagePaneLongPress(recognizer:UILongPressGestureRecognizer)
		{
		switch recognizer.state
			{
			case UIGestureRecognizerState.ended:
				break
			case UIGestureRecognizerState.changed:
				break
			case UIGestureRecognizerState.began:
				let imagePane = recognizer.view as! ImagePaneView
				guard let cell = imagePane.superview?.superview as? ImageTableViewCell else {return} //.... superview is contentView then cell!!!!!
				guard let indexPath =  imageTableView.indexPath(for: cell) else {return}
				if imagePane.imageIsLoaded
					{
					if let node = imagePane.associatedNode
						{
						alert = UIAlertController(title:"Delete user-added image from Phlora?",message:"", preferredStyle: .alert)
						let action1 = UIAlertAction(title: "Cancel", style: .cancel)
							{ (action:UIAlertAction) in self.dismiss(animated:true) }
						let action2 = UIAlertAction(title: "Delete", style: .default)
							{ (action:UIAlertAction) in
							imagePane.deleteImageFromDiskButKeepPane(updateView:self.imageTableView) // actually NEED TO DO TABLE ROW UPDATE CRAP
							node.imageThumb = nil
							self.imageTableView.reloadRows(at: [indexPath], with: .right)
							}
						alert!.addAction(action1)
						alert!.addAction(action2)
						present(alert!, animated: true, completion: nil)
						}
					}
			default:
				break
			}
		}


// Handle the image selected from file system. This is required by the ImageSelector delegate protocol
func imageSelector(_ imageSelector: ImageSelector, didSelectImage image: UIImage)
	{
	let cell = imageSelector.sourceView as! ImageTableViewCell
	//cell.treeInfo!.thumbStudyImage = resizeUIImageToFitSquare(image, withHeight:treeSettings.studyTableRowHeight)

	// save to disk...

	let imagePane = imageSelector.imagePane
	guard let node = imagePane.associatedNode  else  { return }

	// This code works via the thumb array, which gets loaded into imagePane during 'cellForRowAt', rather than how the study table view handles image additions via the imagePane directly
/*
	if let row =  imageTableView.indexPath(for: cell)?.row
		{
		thumbArraySortedByLabel[row] = resizeUIImageToFitSquare(image, withHeight: treeSettings.studyTableRowHeight)
		}
*/

	node.imageThumb = resizeUIImageToFitSquare(image, withHeight: treeSettings.studyTableRowHeight)

	// I am adding an image from a picker, not from the file on disk. The imagepane already exists at this point but it might have two histories
	//		a. pane might have been empty before, in which case it was initialized with "add" message and no long press gesture...
	//		b. might have had an image and imagefile before, then was deleted, but in that case it WOULD have a GR before...

	if node.imageFileURL == nil  // ... so this is case (a)
		{
		addLongTapGestureToDeleteImageFrom(imagePane)
		}

	// save to disk...
	do
		{
			if let fileNameBase = node.originalLabel, let targetDir = docDirectoryNameFor(study: xTree.treeInfo.treeName, inLocation:.inDocuments, ofType:.images, create:true)
				{
				if let destURL = try copyImageToDocs(srcImage:image, copyToDir: targetDir, usingFileNameBase: fileNameBase)
						{
						node.imageFileURL = destURL
						node.imageFileDataLocation = .inDocuments
						}
				}
		}
	catch
		{
		print ("Error saving image file to Phlora")
		let alert = UIAlertController(title:"Error saving image file to Phlora",message:nil, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in  NSLog("The alert occurred")}))
		present(alert,animated:true,completion:nil)
		}


	// Tableview nonsense. Tableview won't let me use constraints as normal. Have to reload a row to get the cell to enforce constraints way I want.



	if let ip = imageTableView.indexPath(for: cell)
		{
		imageTableView.beginUpdates()
		imageTableView.reloadRows(at: [ip], with: .right)
		imageTableView.endUpdates()
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

func loadThumbAsync(atNode node:Node, forCell cell:ImageTableViewCell, at indexPath:IndexPath)
	{
	cell.savedNode = node
	DispatchQueue.global(qos: .userInitiated).async {
		if node.imageThumb != nil { return } // I don't know, let's check again in case another thread did this?
		node.imageThumb = resizeUIImageToFitSquare(UIImage(contentsOfFile:node.imageFileURL!.path)!, withHeight: treeSettings.studyTableRowHeight)

		//print ("Did load cell asynchronously? ",indexPath.row, node.originalLabel!, node.imageThumb != nil)

		if let image = node.imageThumb
			{
			DispatchQueue.main.async {
				if  cell.savedNode!.originalLabel == node.originalLabel // cell has not been reused/scrolled up, bleck
					{
					cell.taxonImagePane.loadImage(image)
//					self.imageTableView.beginUpdates()
					if self.imageTableView.indexPathsForVisibleRows?.contains(indexPath)  ?? false // may not be necessary
						{ self.imageTableView.reloadRows(at: [indexPath], with: .none) } // .none is better than .fade in this context
//					self.imageTableView.endUpdates()

					}
				}
			}
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
			let cell = tableView.dequeueReusableCell(withIdentifier: "cellImageTable", for: indexPath) as! ImageTableViewCell
			let node = nodeArraySortedByLabel[indexPath.row]

			cell.taxonImagePane.associatedNode=node // have to set this here, not
      		cell.leafLabel.text = node.label

			if let thumb = node.imageThumb
				{
				cell.taxonImagePane.loadImage(thumb)
				}
			else // no thumb present
				{
				if node.hasImageFile()

					{
					loadThumbAsync(atNode:node, forCell:cell, at:indexPath)
					}
				else // should not display an image here but have kept one by reusing cell
					{
					if cell.taxonImagePane.imageIsLoaded
							{ cell.taxonImagePane.unloadImage()} // in case we are reusing a cell with an image pane already populated
					}
				}
/*
			if let thumb = thumbArraySortedByLabel[indexPath.row]
				{
				cell.taxonImagePane.loadImage(thumb)
				}
			else
				{
				if cell.taxonImagePane.imageIsLoaded
						{ cell.taxonImagePane.unloadImage()} // in case we are reusing a cell with an image pane already populated

				}
*/


			deleteAllGestureRecognizersFrom(view:cell.taxonImagePane) // yikes, otherwise these could stack up over time with cell reuse
			// Note on GR here. If you inadvertantly leave a GR to launch the tree, then it will conflict with the GR to add image and throw runtime error. Make sure to cancelTouchesView for an addimage pane but make sure it is NOT there for cells with images.
			if cell.taxonImagePane.imageIsLoaded == false  // the new cell row has no study image; add add gesture
				{
				let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
				tapGesture.cancelsTouchesInView = true // when adding an image, stop the touch event from going up to the tableview and mistakenly leading to selection of the row
				cell.taxonImagePane.addGestureRecognizer(tapGesture)
				}
			else
				{addLongTapGestureToDeleteImageFrom(cell.taxonImagePane) } // have to put this here since to manage the GRs
/*
			if indexPath.row == pickedRowIndex
				{
				cell.accessoryType = .checkmark
				}
			else
				{
				cell.accessoryType = .none
				}
*/
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

			//transitionToTreeView(atStudyIndex: pickedRowIndex)
			}

	func tableView(_ tableView:UITableView, canEditRowAt indexPath:IndexPath)->Bool
		{
		// only allow deletion of user added studies
/*
			let treeName = treesData.treeInfoNamesSortedArray[indexPath.row]
			let treeInfo = treesData.treeInfoDictionary[treeName]
			if treeInfo?.dataLocation == .inDocuments
				{ return true }
			else
				{ return false }
*/
return false
		}
	
	func tableView(_ tableView:UITableView, commit editingStyle:UITableViewCellEditingStyle, forRowAt indexPath:IndexPath)
		{
/*
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
*/
		}
/*
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
		if let studyDir = docDirectoryNameFor(study: treeInfo.treeName, inLocation:treeInfo.dataLocation!, ofType:.study,create:false)
		//if let studyDir = docDirectoryNameFor(treeInfo:treeInfo, ofType:.study)
			{
			do {
				try FileManager.default.removeItem(at: studyDir)
				}
			catch
				{print ("There was a problem deleting everything at \(studyDir)") }
			}
		}
*/

/*
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
*/

	


}



