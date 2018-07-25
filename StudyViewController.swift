//
//  TestViewController.swift
//  QGTut
//
//  Created by mcmanderson on 6/14/18.
//  Copyright © 2018 mcmanderson. All rights reserved.
//

import UIKit


//class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
class StudyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	var treeViewStatusBar:UILabel!
	var studyTableView:UITableView!
	// NO SHOULDN"T DO THE FOLLOWING HERE: GETS REDONE EVERY TIME WE LAUNCH STUDY VIEW...
	let treesData = TreesData() // Initializes this once when the view controller is instantiated
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

	override func viewDidLoad()
		{
		super.viewDidLoad()

		self.title = "Studies" // This will be displayed in middle button of navigation bar at top

// view for the study table popup containing the table view and headers and footers

		let studyPUBackgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
		view.backgroundColor=studyPUBackgroundColor
		navigationController!.setNavigationBarHidden(false, animated: false)
        navigationController!.setToolbarHidden(true,
             animated: false)

	//	let topBarY = self.navigationController!.navigationBar.frame.maxY // self.nav.. is the nearest ancestor that is a nav controller (i.e. here the parent of self); note this rect is below the iOS status bar stuff, so have to use position of its maxY
	//	let bottomBarHeight = self.navigationController!.toolbar.frame.height
	//safeFrame = CGRect(x: view.frame.minX, y: topBarY, width: view.frame.width, height: view.frame.height - topBarY - bottomBarHeight) // need this crap until i fix constraints for treeview

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



/* Have to work on the alignment of this header to the table cells, which are being automatically squished toward center
		let headerFooterColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
		let headerLabel = UILabel()
		headerLabel.frame = CGRect(origin:CGPoint(x:200,y:3*headerFooterHeight), size:CGSize(width: studyTableView.frame.width, height: headerFooterHeight))
		headerLabel.text = "Study"
		headerLabel.textAlignment = .left
		headerLabel.font = UIFont(name:"Helvetica", size:20)
		headerLabel.backgroundColor = headerFooterColor
		headerLabel.textColor=UIColor.white
		view.addSubview(headerLabel)
*/


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

/*
		let imageFile = "Cardon50x50"
	
// QUESTION: Should I be reiniting these subviews every time? If I subclass it then I can store subviews as properties and query whether or not they have already been initialized...if so don't forget to update constraints (I think), since we can leave these fixed from cell to cell also

		let iv = UIImageView(image: UIImage(named:imageFile))
		cell.addSubview(iv)

		iv.translatesAutoresizingMaskIntoConstraints=false
		iv.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
		iv.leftAnchor.constraint(equalTo: cell.leftAnchor).isActive = true
		iv.heightAnchor.constraint(equalToConstant: 100.0).isActive = true
		iv.widthAnchor.constraint(equalToConstant: 100.0).isActive = true

		let studyLabel = UILabel()
		studyLabel.textColor = UIColor.white
		studyLabel.font = UIFont(name:"Helvetica", size:24)
        studyLabel.text = treesData.treeInfoNamesSortedArray[indexPath.row]
		cell.addSubview(studyLabel)
		studyLabel.translatesAutoresizingMaskIntoConstraints=false
		studyLabel.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
		studyLabel.leftAnchor.constraint(equalTo: iv.rightAnchor, constant:20.0).isActive = true

		let nLeafLabel = UILabel()
		nLeafLabel.textColor = UIColor.white
		nLeafLabel.font = UIFont(name:"Helvetica", size:18)
        nLeafLabel.text = "\(nLeaves) taxa"
		cell.addSubview(nLeafLabel)
		nLeafLabel.translatesAutoresizingMaskIntoConstraints=false
		nLeafLabel.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
		nLeafLabel.rightAnchor.constraint(equalTo: cell.rightAnchor,constant:-50.0).isActive = true

*/

/*
		cell.imageView!.image = UIImage(named:imageFile)
		cell.imageView!.translatesAutoresizingMaskIntoConstraints=false
		cell.imageView!.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
		cell.imageView!.leftAnchor.constraint(equalTo: cell.leftAnchor).isActive = true
		cell.imageView!.heightAnchor.constraint(equalToConstant: 100.0).isActive = true
		cell.imageView!.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
*/


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
/*
print ("**", indexPath.row)
for row in (0...4)
{
let cell = tableView.cellForRow(at: IndexPath(row:row, section:0))
print (row,"\t",cell!.imageView!.frame)

}
*/
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



