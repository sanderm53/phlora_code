//
//  MainViewController.swift
//  QGTut
//
//  Created by mcmanderson on 6/18/18.
//  Copyright © 2018 mcmanderson. All rights reserved.
//

import Foundation
import UIKit

func resizeUIImage(image theImage:UIImage, toSize size:CGSize) -> UIImage?
			{
			UIGraphicsBeginImageContextWithOptions(size, true, theImage.scale)
			theImage.draw(in:CGRect(origin: CGPoint(x:0,y:0), size: size))
			let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			return resizedImage
			}


class MainViewController: UIViewController {

	var imagePane:ImagePaneView!
	var treeViewStatusBar:UILabel!
	var studyTableView:UITableView!
	//let treesData = TreesData() // Initializes this once when the view controller is instantiated
	var pickedRowIndex:Int = 0
	var safeFrame:CGRect!
	var studyViewController:StudyViewController?
	//var initialLocation = CGPoint(x:0,y:0)
	
	func studyButtonAction(sender: UIButton!) {

		if studyViewController == nil
			{ studyViewController = StudyViewController()}
		//let svc = StudyViewController() // this is instantiated but the code in viewDidLoad in it is not executed yet.
		// so set these variables before the VC does load
		self.navigationController?.pushViewController(studyViewController!, animated: true)
		//self.navigationController?.pushViewController(svc, animated: true)

// Is there a more approp place for these...? Probably in viewWillAppear of studyVC? and treeVC--Nope tried these, nor viewDidLoad
        navigationController!.setToolbarHidden(false, animated: false)
		navigationController!.setNavigationBarHidden(false, animated: false)


	}

// NEW TEST OF IMPORT FEATURES ...***********


// **************

	func aboutButtonAction(sender: UIButton!)
		{
		let vc = htmlFileTextViewController()
		vc.htmlFilePrefix="About"
		self.navigationController?.pushViewController(vc, animated: true)
		}
	func helpButtonAction(sender: UIButton!)
		{
		let vc = htmlFileTextViewController()
		vc.htmlFilePrefix="HelpGuide"
		self.navigationController?.pushViewController(vc, animated: true)
		}




	override func viewDidAppear(_ animated: Bool)
		{
		super.viewDidAppear(animated)
		}

	override func viewWillAppear(_ animated: Bool)
		{
		super.viewWillAppear(animated)
        navigationController!.setToolbarHidden(true, animated: false)
		navigationController!.setNavigationBarHidden(true, animated: false)
		}
	override func viewDidLoad()
		{
		super.viewDidLoad()

		self.title = "Phlora" // This will be displayed in middle button of navigation bar at top
        navigationController!.setToolbarHidden(true,
             animated: false)



		let imageFile = "LupineTableMountain"
		let image = UIImage(named:imageFile)
		let imageView = UIImageView(image: image)
		imageView.contentMode = .scaleAspectFill
		view.addSubview(imageView)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true



		navigationController!.setNavigationBarHidden(true, animated: false)
		let margins = view.layoutMarginsGuide
		imageView.translatesAutoresizingMaskIntoConstraints=false
		imageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true

		let studyButton = button(title:"Studies",fontSize:30,action:#selector(studyButtonAction))
		let aboutButton = button(title:"About/Credits",fontSize:30,action:#selector(aboutButtonAction))
		let helpButton = button(title:"Help",fontSize:30,action:#selector(helpButtonAction))

		let stackView = UIStackView(arrangedSubviews:[studyButton,helpButton,aboutButton])
		stackView.axis = .vertical
		stackView.distribution = .fillEqually
		stackView.alignment = .fill
		stackView.spacing = 50
		stackView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(stackView)
		
//		stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		stackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
		//stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		stackView.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
		stackView.heightAnchor.constraint(equalToConstant: 400.0).isActive = true
 		}


	func button (title t:String, fontSize fs:CGFloat, action act: Selector)->UIButton
		{
		let button = UIButton(type: .roundedRect) // defaults to frame of zero size! Have to do custom to short circuit the tint color assumption for example
		button.addTarget(self, action: act, for: .touchUpInside)
		button.frame.size = CGSize(width: 200, height: 50)
		button.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
		button.layer.borderColor=UIColor.white.cgColor
		button.layer.borderWidth=2.0
		button.layer.cornerRadius=10
		button.frame = CGRect(origin: CGPoint(x:0,y:0), size: button.frame.size)
		button.setTitleColor(UIColor.black, for: .normal)
		let myAttributes = [
			NSForegroundColorAttributeName : UIColor.white,
			NSFontAttributeName : UIFont(name:"Helvetica", size:fs)!
			]
		let mySelectedAttributedTitle = NSAttributedString(string: t, attributes: myAttributes)
   		button.setAttributedTitle(mySelectedAttributedTitle, for: .normal)
		return button
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
