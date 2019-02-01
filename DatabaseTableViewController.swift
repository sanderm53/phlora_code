//
//  TestViewController.swift
//  QGTut
//
//  Created by mcmanderson on 6/14/18.
//  Copyright © 2019 Michael J Sanderson. All rights reserved.
//

// Displays a table reporting available data sets for download and manages downloads

import Foundation
import UIKit

func showAlertMessage (_ s:String, onVC vc:UIViewController)
	{
	let alert = UIAlertController(title:s,message:nil, preferredStyle: .alert)
	alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil ))
	vc.present(alert,animated:true,completion:nil)
	}

class DatabaseTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,  UIGestureRecognizerDelegate {

	var studyTableView:UITableView!
	var pickedRowIndex:Int = 0
	var xTree:XTree!
	var nodeArraySortedByLabel: [Node] = []
	var thumbArraySortedByLabel: [UIImage?] = []
	var alert: UIAlertController?
	var databaseLocationLabel:UILabel!
	var button:UIButton!
	var remoteTreesData:TreesData?
	var localTreesData:TreesData? // initialized by main vc if it is available already (might use it to update images on a tree vc)
	var manifestList:[(DataFileType , URL )] = []
	var downloadService:DownloadService!
	lazy var downloadsSession: URLSession = {
		let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
		return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
		}()


	func handleCancelDownloadButton(sender:UIButton)
			{
			downloadService.cancelAll()
			}


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



	override func viewDidLoad()
		{
		super.viewDidLoad()
		self.title = "Download" // This will be displayed in middle button of navigation bar at top

		// view for the study table popup containing the table view and headers and footers

		let studyPUBackgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
		view.backgroundColor=studyPUBackgroundColor
		navigationController!.setNavigationBarHidden(false, animated: false)
        navigationController!.setToolbarHidden(true,
             animated: false)

		// Table
		studyTableView = UITableView()
		studyTableView.delegate=self
		studyTableView.dataSource = self
		studyTableView.register(DatabaseTableViewCell.self, forCellReuseIdentifier: "cellDatabaseTable") // This is calling a class name for the cell, but here it is just the root UITableViewCell class; if I want to init this to a different default style prob have to subclass it
		studyTableView.isHidden=false
		studyTableView.backgroundColor=nil // transparent, keep view color
		studyTableView.rowHeight=treeSettings.studyTableRowHeight
		studyTableView.estimatedRowHeight = 0; // Thanks to 'rshinich' on Apple Devel Forum for suggesting these lines to cure the wonky behavior on async updates of the images...
		studyTableView.estimatedSectionHeaderHeight = 0;
		studyTableView.estimatedSectionFooterHeight = 0;

		// Server location label
		databaseLocationLabel = UILabel()
		databaseLocationLabel.textColor = UIColor.lightGray
		databaseLocationLabel.text = "Downloads available from \(treeSettings.defaultDatabasePath)"
		databaseLocationLabel.textAlignment = .center
		databaseLocationLabel.lineBreakMode = .byWordWrapping
		databaseLocationLabel.font = UIFont(name:"Helvetica", size:20)
		databaseLocationLabel.numberOfLines = 2

		view.addSubview(studyTableView)
		view.addSubview(databaseLocationLabel)

		addConstraints()

		// Initialize the data for the table from the remote metadata file
		if let dbMetaDataURL = URL(string:treeSettings.defaultDatabasePath)?.appendingPathComponent("PhloraMetadata.txt")
			{
			do
				{
				remoteTreesData = try TreesData(usingMetaDataFileAt:dbMetaDataURL)
				}
			catch TreesData.TreesDataError.zeroEntries
				{
				showAlertMessage ("Remote trees metadata file had no entries", onVC:self)
				}
			catch
				{
				showAlertMessage ("Error finding or parsing remote trees metadata file", onVC:self)
				}
			
			}
		downloadService = DownloadService(viewController:self)
  		downloadService.downloadsSession = downloadsSession
 		}
	
	func addConstraints()
		{
		let margins = view.readableContentGuide

		databaseLocationLabel.translatesAutoresizingMaskIntoConstraints=false
		databaseLocationLabel.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
		databaseLocationLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
		databaseLocationLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
		databaseLocationLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true

		studyTableView.translatesAutoresizingMaskIntoConstraints=false
		studyTableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
		studyTableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
		studyTableView.topAnchor.constraint(equalTo: databaseLocationLabel.bottomAnchor).isActive = true
		studyTableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
		}
	
	
	func changeServerLocation(sender:UIButton)
		{
		//print ("Change the server location")
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


}

extension DatabaseTableViewController: DatabaseTableViewCellDelegate
	{
	func downloadTapped(_ cell: DatabaseTableViewCell)
		{
		downloadService.downloadAll(forStudy:cell.treeInfo!,havingFileTypes: [.imageFile, .treeFile, .textFile])
		}

	}

extension DatabaseTableViewController: URLSessionDownloadDelegate
	{
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo tempLocalURL: URL)
		{
		guard let sourceURL = downloadTask.originalRequest?.url else { return }
		let download = downloadService.activeDownloads[sourceURL] // do this before calling fileDidFinish...
		guard let finalURL = downloadService.fileDidFinishDownloading(from:sourceURL, to:tempLocalURL) else { return }
		// If we have opened a tree view in this session already for the same tree we are downloading to, let's update the nodes' info about an image as we download the images
		if let localTreesData = localTreesData, let studyName = download?.studyName // no reason to pursue this if we haven't set up local study data yet
				{
				if let treeInfo = localTreesData.treeInfoDictionary[studyName]
					{
					let fileNameBase = finalURL.deletingPathExtension().lastPathComponent
					if let node = treeInfo.treeViewController?.treeView.xTree.nodeHash[fileNameBase]
						{
						node.imageFileURL = finalURL
						node.imageFileDataLocation = .inDocuments // Bad debugging: this controls whether longpress GR is addded in TreeVC
						//if let imagePane = node.imagePaneView
						// DONT TRY THIS AT HOME	{ imagePane.delete() } // bit of a hack: this is case of a deleted image and now empty image pane on tree view; for now, let's just delete it back to the dot; then let user reopen with newly downloaded image
						treeInfo.treeViewController?.treeView.xTree.nImages += 1
						DispatchQueue.main.async
							{
							//treeInfo.treeViewController?.updateViewControllerTitle() I put this in treevc.viewdidappear()
							treeInfo.treeViewController?.treeView.setNeedsDisplay() // to redraw the image icons
							treeInfo.treeViewController?.treeView.setNeedsLayout() // to refresh possibly empty imagePanes by calling layoutsubviews
							// Are there any issues here having possibly many async dispatches for large collection downloads?
							}
						}
					}
				}

		}
	}

extension DatabaseTableViewController: URLSessionDelegate
	{ 	// see copyright in DownloadService.swift
		// Standard background session handler
	func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession)
		{
		DispatchQueue.main.async
			{
			if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
			let completionHandler = appDelegate.backgroundSessionCompletionHandler
				{
				appDelegate.backgroundSessionCompletionHandler = nil
				completionHandler()
				}
			}
		}
	}

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
