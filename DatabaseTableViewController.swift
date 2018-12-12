//
//  TestViewController.swift
//  QGTut
//
//  Created by mcmanderson on 6/14/18.
//  Copyright © 2018 mcmanderson. All rights reserved.
//

import Foundation
import UIKit



//class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
class DatabaseTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate, UIGestureRecognizerDelegate {

	//var treeViewStatusBar:UILabel!
	var studyTableView:UITableView!
	//var treesData:TreesData!
	var pickedRowIndex:Int = 0
	var xTree:XTree!
	var nodeArraySortedByLabel: [Node] = []
	var thumbArraySortedByLabel: [UIImage?] = []
	var alert: UIAlertController?
	var databaseLocationLabel:UILabel!
	var button:UIButton!
	var remoteTreesData:TreesData?
	var manifestList:[(DataFileType , URL )] = []
	let downloadService = DownloadService()

lazy var downloadsSession: URLSession = {
  //let configuration = URLSessionConfiguration.default
  let configuration = URLSessionConfiguration.background(withIdentifier:
  "bgSessionConfiguration")
  return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
}()


	let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonAction))

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
		//nodeArraySortedByLabel = xTree.nodeArray.sorted (by: { 0 > $0.originalLabel!.localizedStandardCompare($1.originalLabel!).rawValue } )


		self.title = "Remote Database" // This will be displayed in middle button of navigation bar at top

// view for the study table popup containing the table view and headers and footers

		let studyPUBackgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
		view.backgroundColor=studyPUBackgroundColor
		//view.backgroundColor=UIColor.black
		navigationController!.setNavigationBarHidden(false, animated: false)
        navigationController!.setToolbarHidden(true,
             animated: false)

//let addButton =  UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonAction))
//let editButton =  UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonAction))
//self.navigationItem.rightBarButtonItems = [editButton, addButton]

// table view
		studyTableView = UITableView()
		studyTableView.delegate=self
		studyTableView.dataSource = self
		studyTableView.register(DatabaseTableViewCell.self, forCellReuseIdentifier: "cellDatabaseTable") // This is calling a class name for the cell, but here it is just the root UITableViewCell class; if I want to init this to a different default style prob have to subclass it
		studyTableView.isHidden=false
		studyTableView.backgroundColor=nil // transparent, keep view color
		studyTableView.rowHeight=treeSettings.studyTableRowHeight
		view.addSubview(studyTableView)

		self.studyTableView.estimatedRowHeight = 0; // Thanks to 'rshinich' on Apple Devel Forum for suggesting these lines to cure the wonky behavior on async updates of the images...
		self.studyTableView.estimatedSectionHeaderHeight = 0;
		self.studyTableView.estimatedSectionFooterHeight = 0;


		databaseLocationLabel = UILabel()
		databaseLocationLabel.textColor = UIColor.white
		databaseLocationLabel.text = "Studies available at remote server:\n\(treeSettings.defaultDatabasePath)"
		databaseLocationLabel.lineBreakMode = .byWordWrapping
		databaseLocationLabel.font = UIFont(name:"Helvetica", size:20)
		databaseLocationLabel.textAlignment = .left
		databaseLocationLabel.numberOfLines = 2
		view.addSubview(databaseLocationLabel)

		button = UIButton(type: .roundedRect) // defaults to frame of zero size! Have to do custom to short circuit the tint color assumption for example
		button.addTarget(self, action: #selector(changeServerLocation), for: .touchUpInside)
		//button.frame.size = CGSize(width: 200, height: 50)
		button.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
		button.layer.borderColor=UIColor.green.cgColor
		button.layer.borderWidth=2.0
		button.layer.cornerRadius=10
		//button.frame = CGRect(origin: CGPoint(x:0,y:0), size: button.frame.size)
		button.setTitleColor(UIColor.green, for: .normal)
		let myAttributes = [
			NSForegroundColorAttributeName : UIColor.green,
			NSFontAttributeName : UIFont(name:"Helvetica", size:16)!
			]
		let mySelectedAttributedTitle = NSAttributedString(string: "Change server location", attributes: myAttributes)
   		button.setAttributedTitle(mySelectedAttributedTitle, for: .normal)
		view.addSubview(button)


		let margins = view.readableContentGuide

		databaseLocationLabel.translatesAutoresizingMaskIntoConstraints=false
		databaseLocationLabel.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
		databaseLocationLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
		databaseLocationLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
		databaseLocationLabel.trailingAnchor.constraint(equalTo: button.leadingAnchor).isActive = true

		button.translatesAutoresizingMaskIntoConstraints=false
		button.centerYAnchor.constraint(equalTo: databaseLocationLabel.centerYAnchor).isActive = true
		button.heightAnchor.constraint(equalToConstant: 40).isActive = true
		button.widthAnchor.constraint(equalToConstant: 200).isActive = true
		button.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true

		studyTableView.translatesAutoresizingMaskIntoConstraints=false
		studyTableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
		studyTableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
		studyTableView.topAnchor.constraint(equalTo: button.bottomAnchor).isActive = true
		studyTableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true

/* SAVE SAVE SAVE SAVE 
	To read the herbarium server, which is http, not https:, need to modify the info.plist as follows
	NB! This may cause problems in the app store or when/if Apple disallows this exception
	NB! To get the source version of the info.plist, do right click on info.plist at left, and open as source
	NB! Should check this out with testflight
	
	<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSExceptionDomains</key>
		<dict>
			<key>db.herbarium.arizona.edu</key>
			<dict>
				<key>NSExceptionAllowsInsecureHTTPLoads</key>
				<true/>
			</dict>
		</dict>
	</dict>

*/
		if let dbMetaDataURL = URL(string:treeSettings.defaultDatabasePath)?.appendingPathComponent("PhloraMetadata.txt")
			{
			do
				{
				remoteTreesData = try TreesData(usingMetaDataFileAt:dbMetaDataURL)
				}
			catch
				{ print ("Error initializing remoteTreesData") }
// NEED A SERIOUS CATCH HERE
			}

  		downloadService.downloadsSession = downloadsSession

 
 		}

	func changeServerLocation(sender:UIButton)
		{
		
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
			guard let treesData = remoteTreesData else {return 0} // might be nil if init failed
			return treesData.treeInfoNamesSortedArray.count // nodeArraySortedByLabel.count
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
					break
				default:
					break

				}

	}



	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
			let cell = tableView.dequeueReusableCell(withIdentifier: "cellDatabaseTable", for: indexPath) as! DatabaseTableViewCell
			if let treesData = remoteTreesData  // might be nil if init failed
				{
				let treeName = treesData.treeInfoNamesSortedArray[indexPath.row]
				let treeInfo = treesData.treeInfoDictionary[treeName]
				cell.delegate = self
				cell.configure(using: treeInfo!)

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

extension DatabaseTableViewController: DatabaseTableViewCellDelegate
	{
	func downloadTapped(_ cell: DatabaseTableViewCell)
		{
		if let indexPath = studyTableView.indexPath(for:cell)
			{
			print ("Preparing to fetch manifest and download...")
			downloadService.startDownload(forStudy:cell.treeInfo!)
			}
		}
	
	}

extension DatabaseTableViewController: URLSessionDownloadDelegate
	{
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo tempLocalURL: URL)
		{
		print("Finished downloading to \(tempLocalURL).")

		guard let sourceURL = downloadTask.originalRequest?.url else { return }
		if let download = downloadService.activeDownloads[sourceURL] // info I need for copyURL..() below is in this dictionary
			{
			if let targetURL = try? copyURLToDocs(src:tempLocalURL, srcFileType: download.srcFileType, srcFilename: download.srcFileName, forStudy: download.studyName,overwrite:true)
				{
				print ("file copied to", targetURL)
				}
			else
				{ print ("Error in url copying")}
			}
		}
			
	}
extension DatabaseTableViewController: URLSessionDelegate { // see copyright in DownloadService.swift

  // Standard background session handler
  func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    DispatchQueue.main.async {
      if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
        let completionHandler = appDelegate.backgroundSessionCompletionHandler {
        appDelegate.backgroundSessionCompletionHandler = nil
        completionHandler()
      }
    }
  }

}
