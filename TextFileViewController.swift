//
//  htmlTextViewController.swift
//  QGTut
//
//  Created by mcmanderson on 6/20/18.
//  Copyright © 2018 mcmanderson. All rights reserved.
//

import Foundation
import UIKit



class TextFileViewController: UIViewController {

	var treeInfo:TreeInfoPackage!
	var textView:UITextView!
	let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonAction))

	init(treeInfo t:TreeInfoPackage)
		{
		treeInfo = t
		super.init(nibName:nil, bundle: nil)
		}
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
		{
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		}
	required init?(coder:NSCoder)
		{
		super.init(coder:coder)
		}

	override func viewDidAppear(_ animated: Bool)
		{
		super.viewDidAppear(animated)
		}

	override func viewWillAppear(_ animated: Bool)
		{
		super.viewWillAppear(animated)
        //navigationController!.setToolbarHidden(true, animated: false)
		navigationController!.setNavigationBarHidden(false, animated: false)
		}
	override func viewDidLoad()
		{
		super.viewDidLoad()

		self.title = treeInfo.treeName // This will be displayed in middle button of navigation bar at top
		navigationController!.setNavigationBarHidden(false, animated: false)
        navigationController!.setToolbarHidden(true,
             animated: false)
 		self.navigationItem.rightBarButtonItem = saveButton
        view.backgroundColor=UIColor.black

		textView = UITextView()
		self.view.addSubview(textView)
		textView.allowsEditingTextAttributes = true
		textView.text = textInfoFileToString()
		textView.textColor = UIColor.white
		textView.font = UIFont.preferredFont(forTextStyle:.body)
		textView.isEditable=true // careful, sometimes seems to throw constraint errors
		textView.backgroundColor=UIColor.black
		textView.translatesAutoresizingMaskIntoConstraints=false
		let margins = view.readableContentGuide
		textView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
		textView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
		textView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
		textView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true

 		}

	func textInfoFileToString() -> String
		{
		// As usual, first we look for this in user-added docs dir, which takes precedence. If not there and if it might be in
		// bundle (builtin), then check there
		if let dir = docDirectoryNameFor(study: treeInfo.treeName, inLocation:.inDocuments, ofType:.text, create:false)
			{
			let textFile = dir.appendingPathComponent(treeInfo.treeName).appendingPathExtension("txt")
			if let s = try? String(contentsOf: textFile)
				{ return s }
			}
		else if treeInfo.dataLocation == .inBundle
			{
			if let dir = docDirectoryNameFor(study: treeInfo.treeName, inLocation:.inBundle, ofType:.text, create:false)
				{
				let textFile = dir.appendingPathComponent(treeInfo.treeName).appendingPathExtension("txt")
				if let s = try? String(contentsOf: textFile)
					{ return s }
				}
			}
			
		return "Add text here." // dummy text in case no file present
		}

	func saveTextToFile(text s:String) throws
		{
		let fileManager = FileManager.default
		if let dir = docDirectoryNameFor(study: treeInfo.treeName, inLocation:.inDocuments, ofType:.text, create:true)
		// Note we force this to write to documents directory, even if original location is inBundle
			{
			if fileManager.fileExists(atPath: dir.path) == false  // create if needed
				{
				try fileManager.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
				}
			let textFileURL = dir.appendingPathComponent(treeInfo.treeName).appendingPathExtension("txt")
	//print (s,textFileURL)
			try s.write(to: textFileURL, atomically: true, encoding: .utf8)
			}
		}
	
	func saveButtonAction(sender: UIBarButtonItem!) {
		do {
			try saveTextToFile(text:textView.text)
			}
		catch {
			print ("Failed to save edited text")
			}
		self.textView.resignFirstResponder()
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
	
//		super.viewWillTransition(to: size, with: coordinator)

		}

	}
