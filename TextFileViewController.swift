//
//  htmlTextViewController.swift
//  QGTut
//
//  Created by mcmanderson on 6/20/18.
//  Copyright © 2019 Michael J Sanderson. All rights reserved.
//

import Foundation
import UIKit


// Update: I am disabling the ability to edit this page for Phlora's first public release. Can re-enable if seems useful later.
// Display a page with absolutely plain text; allows editing and saving though

class TextFileViewController: UIViewController {

	let defaultMessage = "See Help for more on how to add information to this page ..."
	var treeInfo:TreeInfoPackage!
	var textView:UITextView!
	//let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonAction))

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

		self.title = treeInfo.displayTreeName // This will be displayed in middle button of navigation bar at top
		navigationController!.setNavigationBarHidden(false, animated: false)
        navigationController!.setToolbarHidden(true,
             animated: false)
 		// self.navigationItem.rightBarButtonItem = saveButton ...DISABLING save feature
        view.backgroundColor=UIColor.black

		textView = UITextView()
		self.view.addSubview(textView)
		//textView.allowsEditingTextAttributes = true ... works but then will need to save as attr text
		textView.text = getTextFromFile(forStudyName:treeInfo.treeName)
		textView.textColor = UIColor.white
		textView.font = UIFont.preferredFont(forTextStyle:.body)
		//textView.isEditable=true // careful, sometimes seems to throw constraint errors
		textView.isEditable=false // careful, sometimes seems to throw constraint errors
		textView.backgroundColor=UIColor.black
		textView.translatesAutoresizingMaskIntoConstraints=false
		let margins = view.readableContentGuide
		textView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
		textView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
		textView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
		textView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true

 		}


func getTextFromFile(forStudyName studyName:String) -> String // which has a filename like study.jpg
	{
	if let url = getFileURLMatching(study:studyName, filenameBase:studyName, extensions: ["txt"], ofType:.text)
		{
		if let s = try? String(contentsOf: url)
			{ return s }
		}
	return defaultMessage
	}

func saveTextToFile(forStudyName studyName:String, text s:String) throws
	// Write to documents directory, even if original location is inBundle
	{
	if let dir = docDirectoryNameFor(study: studyName, inLocation:.inDocuments, ofType:.text, create:true)
		{
		let textFileURL = dir.appendingPathComponent(studyName).appendingPathExtension("txt")
		try s.write(to: textFileURL, atomically: true, encoding: .utf8)
		}
	}



	func saveButtonAction(sender: UIBarButtonItem!) {
		do {
			try saveTextToFile(forStudyName:treeInfo.treeName, text:textView.text)
			}
		catch {
			showAlertMessage ("Failed to save edited text", onVC:self)
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
     	self.textView.setContentOffset(CGPoint.zero, animated: false) // ensures that the top of the text appears visible at top of screen  (else it sometimes gets scrolled up and hidden
   	}



	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
	
//		super.viewWillTransition(to: size, with: coordinator)

		}

	}
