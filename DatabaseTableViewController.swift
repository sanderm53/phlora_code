//
//  TestViewController.swift
//  QGTut
//
//  Created by mcmanderson on 6/14/18.
//  Copyright © 2018 mcmanderson. All rights reserved.
//

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
	var manifestList:[(DataFileType , URL )] = []
	let downloadService = DownloadService()
	var annotatedProgressView = AnnotatedProgressView()

	lazy var downloadsSession: URLSession = {
		let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
		return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
		}()


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
		self.title = "Remote Database" // This will be displayed in middle button of navigation bar at top

// view for the study table popup containing the table view and headers and footers

		let studyPUBackgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
		view.backgroundColor=studyPUBackgroundColor
		//view.backgroundColor=UIColor.black
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
		databaseLocationLabel.text = "Contents of Database at:\(treeSettings.defaultDatabasePath)"
		databaseLocationLabel.textAlignment = .center
		databaseLocationLabel.lineBreakMode = .byWordWrapping
		databaseLocationLabel.font = UIFont(name:"Helvetica", size:20)
		databaseLocationLabel.numberOfLines = 2


/*
		// Change-server button
		button = UIButton(type: .custom) // defaults to frame of zero size! Have to do custom to short circuit the tint color assumption for example
		button.addTarget(self, action: #selector(changeServerLocation), for: .touchUpInside)
		button.backgroundColor = studyPUBackgroundColor
		button.setTitleColor(UIColor.green, for: .normal)
		let myAttributes = [
			NSForegroundColorAttributeName : UIColor(cgColor: appleBlue),
			NSFontAttributeName : UIFont(name:"Helvetica", size:16)!
			]
		let mySelectedAttributedTitle = NSAttributedString(string: "Change", attributes: myAttributes)
   		button.setAttributedTitle(mySelectedAttributedTitle, for: .normal)
*/

		view.addSubview(studyTableView)
		view.addSubview(databaseLocationLabel)
		//view.addSubview(button)
		view.addSubview(annotatedProgressView)

		addConstraints()

		// Initialize the data for the table from the remote metadata file
		if let dbMetaDataURL = URL(string:treeSettings.defaultDatabasePath)?.appendingPathComponent("PhloraMetadata.txt")
			{
			do
				{
				remoteTreesData = try TreesData(usingMetaDataFileAt:dbMetaDataURL)
				}
			catch
				{
				print ("Error fetching remoteTreesData")
				showAlertMessage ("Error fetching remote trees metadata", onVC:self)
				}
			
			}

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
//		databaseLocationLabel.trailingAnchor.constraint(equalTo: button.leadingAnchor).isActive = true
/*
		button.translatesAutoresizingMaskIntoConstraints=false
		button.centerYAnchor.constraint(equalTo: databaseLocationLabel.centerYAnchor).isActive = true
		button.heightAnchor.constraint(equalToConstant: 40).isActive = true
		button.widthAnchor.constraint(equalToConstant: 75).isActive = true
		button.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
*/
		studyTableView.translatesAutoresizingMaskIntoConstraints=false
		studyTableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
		studyTableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
		studyTableView.topAnchor.constraint(equalTo: databaseLocationLabel.bottomAnchor).isActive = true
		studyTableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true

		annotatedProgressView.translatesAutoresizingMaskIntoConstraints=false
		annotatedProgressView.heightAnchor.constraint(equalToConstant: 150).isActive = true
		annotatedProgressView.widthAnchor.constraint(equalToConstant: 300).isActive = true
		annotatedProgressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		annotatedProgressView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		}
	
	
	func changeServerLocation(sender:UIButton)
		{
		print ("Change the server location")
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
		do
			{
			try downloadService.startDownload(forStudy:cell.treeInfo!)
			annotatedProgressView.start(title:cell.treeInfo!.displayTreeName, nFilesToDownload: downloadService.nFilesToDownload)
			}
		catch (DownloadServiceError.busy) // errors defined in DownloadService
			{
			showAlertMessage ("Download service busy", onVC:self)
			}
		catch (DownloadServiceError.manifestError)
			{
			showAlertMessage ("Error fetching manifest file", onVC:self)
			}
		catch
			{
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
			downloadService.activeDownloads[sourceURL] = nil
			if let targetURL = try? copyURLToDocs(src:tempLocalURL, srcFileType: download.srcFileType, srcFilename: download.srcFileName, forStudy: download.studyName,overwrite:true)
				{

				downloadService.nFilesHaveDownloaded += 1
				let progress = Float(downloadService.nFilesHaveDownloaded)/Float(downloadService.nFilesToDownload)
				DispatchQueue.main.async
					{
					self.annotatedProgressView.updateProgress(int1: self.downloadService.nFilesHaveDownloaded, int2: self.downloadService.nFilesToDownload)
					}
				if (progress == 1.0)
					{
					DispatchQueue.main.async
						{
						self.annotatedProgressView.isHidden = true
						self.downloadService.isDownloading = false
						}
					}

				//print ("Progress = ", progress)
				print ("file copied to", targetURL)
				}
			else
				{ showAlertMessage ("Error downloading/saving remote file", onVC:self) }
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
