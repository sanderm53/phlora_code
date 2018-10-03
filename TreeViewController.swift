//
//  ViewController.swift
//  QGTut
//
//  Created by mcmanderson on 5/15/17.
//  Copyright © 2017 mcmanderson. All rights reserved.
//

import UIKit
import Photos


var appleBlue = UIColor(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1.0).cgColor

//class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
class TreeViewController: UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

var timer: CADisplayLink?
var startAnimation: TimeInterval = 0
var endAnimation: TimeInterval = 0
var lastUpdate: TimeInterval = 0
var progress: TimeInterval = 0
var startAnimationY: CGFloat = 0.0
var targetY: CGFloat = 0.0
var animateDuration: TimeInterval = 2.0 // Careful if we let this run too long! Mucks up other events/anims
var animateDurationImagePanes: TimeInterval = 0.2 // Careful if we let this run too long! Mucks up
var imageIsPanning:Bool=false
var panningLeafIndex:Int?
var imageIconsArePanning:Bool=false
var lastPanningIconLeafIndex:Int?
var imageIsZooming:Bool=false
var deviceType:UIUserInterfaceIdiom!

var imageScale:CGFloat = 1.0
let buttonGap:CGFloat = 60

//@IBOutlet weak var treeView: DrawTreeView!
//weak var treeView: DrawTreeView!
var treeView: DrawTreeView!  // had to drop the 'weak' to do the programmatic view handling
var helpView: UITextView!
var infoButton: UIButton!
var cladeNameButton: UIButton!
var imagesButton: UIButton!
var treePickerButton: UIButton!
var pkSelectTreeButton: UIButton!
var tablePopupCancelButton: UIButton!
var pkViewStatusBar: UILabel!
var treeViewStatusBar:UILabel!
var studyPopupView:UIView!
var studyTableView:UITableView!
var pickedRowIndex:Int!
var safeFrame:CGRect!

var myNavigationController:UINavigationController!
var otherVC:UIViewController!
var infoViewController:TextFileViewController?

var activityIndicator:UIActivityIndicatorView!

var treesData:TreesData! // Initializes this once when the view controller is instantiated

var panGesture:UIPanGestureRecognizer?

var panningImagePane:ImagePaneView?
var panningImagePaneStartPt:CGPoint?
var panningImagePaneEndPt:CGPoint?
var panningImageVelocity:CGPoint?
var lastTime: TimeInterval?

var showingImageAddButtons:Bool = false

//Utilities

func addButtonAction(sender: UIBarButtonItem!) {
	treeView.showingImageAddButtons = !treeView.showingImageAddButtons
	treeView.setNeedsDisplay()
	}

func infoButtonAction(sender: UIButton!) {
    //helpView.isHidden = !helpView.isHidden
		self.navigationController?.pushViewController(infoViewController!, animated: true)


}

func cladeNameButtonAction(sender: UIButton!) {
    treeView.cladeNamesAreVisible = !treeView.cladeNamesAreVisible
    treeView.setNeedsDisplay()
}
func imagesButtonAction(sender: UIButton!) {
    treeView.imagesAreVisible = !treeView.imagesAreVisible

	for subview in treeView.subviews
			{
			let imagePane = subview as! ImagePaneView
			if imagePane.associatedNode!.isDisplayingImage
				{
				imagePane.isHidden = !treeView.imagesAreVisible
				}
			}

    treeView.setNeedsDisplay()

}
func treePickerButtonAction(sender: UIButton!) {

/*
	let vc = StudyViewController()
	vc.treesData = treesData
	vc.pickedRowIndex = pickedRowIndex
	self.navigationController?.pushViewController(vc, animated: true)


 	if let indexPath = studyTableView.indexPathForSelectedRow
		{studyTableView.deselectRow(at:indexPath, animated:false)}
   studyPopupView.isHidden = false
   studyPopupView.setNeedsDisplay() // doesn't seem necessary...
*/


}
/*
func treePickerSelectTreeButtonAction(sender: UIButton!) {
    //
	let treeName = treesData.treeInfoNamesSortedArray[pickedRowIndex]
	switchTreeView(fromTreeView:treeView, toTreeNamed:treeName)
    studyTableView.isHidden = true
}
*/
func tablePopupCancelButtonAction(sender: UIButton!) {
    //
    studyPopupView.isHidden = true
}



/*
	Order of view controller calls here:
	1. viewDidLoad
		- then calls drawTree Init, because that is called from within viewDidLoad function
	2. viewDidLayoutSubviews
	    - then calls draw in the drawTreeView to try to draw the tree, and only then...calls
	3. viewDidAppear
*/


	override func viewDidLoad() // Gets loaded once but not when going back and forth in VC stack
		{
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

        navigationController!.setToolbarHidden(false, animated: false)
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonAction)) // docs advisee initializing this when vc is initialized, but I want the action code to be here...

	// Add gesture recognizers NOTE I'M NOW ATTACHING THESE TO THE VIEW RATHER THAN THE treeView


		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))

	// I can delete this if I move it to its own view controller
		tapGesture.cancelsTouchesInView = false /* This takes a while to explain...the default for a GR is true.
			GRs are the easy way to handle gestures, but you can configure views to handle them in some fancy custom way. If a GR is
			present, the window first tries to detect whether it recognizes a gesture, like a single tap; if so, it handles it; if not,
			it passes the "touches" (more specialized touch-related objects) to the view directly. So, a TableView detects clicks for selection
			apparently via the latter route, and these taps in a table view might get swallowed up by my gesture recognizer first. When this
			happens, the default is to discard the gesture even if our handler does nothing special with it. Hence, here we turn off the discarding
			and pass the touches along to the view, which apparently passes them along to all subviews, incl the tableview.
			Sheesh, but this explains the mystery of where touches go on the way to controllers when there is no code in my viewcontroller for this. */

		view.addGestureRecognizer(tapGesture)
		self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
		view.addGestureRecognizer(panGesture!)

		let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(recognizer:)))
		view.addGestureRecognizer(pinchGesture)

		let treeName = treesData.treeInfoNamesSortedArray[pickedRowIndex]
		let nLeaves = treesData.treeInfoDictionary[treeName]!.nLeaves
		let treeInfo = treesData.treeInfoDictionary[treeName]!
		//treeView = DrawTreeView(frame:safeFrame,using:treeInfo)

		self.title = treeName + " (\(nLeaves) leaves)" // This will be displayed in middle button of navigation bar at top

		if infoViewController == nil
			{ infoViewController = TextFileViewController(treeInfo:treeInfo) }

		//treeView = treesData.selectTreeView(forTreeName:treeName, usingSameFrameAs:safeFrame)
		treeView = treesData.selectTreeView(forTreeName:treeName)


		self.view.addSubview(treeView)
		treeView.translatesAutoresizingMaskIntoConstraints=false
		treeView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		treeView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

		treeView.topAnchor.constraint(equalTo:topLayoutGuide.bottomAnchor).isActive = true
		treeView.bottomAnchor.constraint(equalTo:bottomLayoutGuide.topAnchor).isActive = true

		infoButton = UIButton(type: .infoDark)
		infoButton.addTarget(self, action: #selector(infoButtonAction), for: .touchUpInside)
		infoButton.tintColor=UIColor.white

  	// display a toggle button to show clade names but only if present on tree

		cladeNameButton = UIButton(type: .custom) // defaults to frame of zero size! Have to do custom to short circuit the tint color assumption for example
		cladeNameButton.addTarget(self, action: #selector(cladeNameButtonAction), for: .touchUpInside)
		cladeNameButton.frame.size = infoButton.frame.size
		cladeNameButton.tintColor=UIColor.yellow
		let cladeNameButtonImage = makeCladeNameButtonImage(size:cladeNameButton.frame.size)
		cladeNameButton.setImage(cladeNameButtonImage, for: .normal)
		//self.view.addSubview(cladeNameButton)

 // display a toggle button to show images but only if present on tree
		imagesButton = UIButton(type: .custom) // defaults to frame of zero size! Have to do custom to short circuit the tint color assumption for example
		imagesButton.addTarget(self, action: #selector(imagesButtonAction), for: .touchUpInside)
		imagesButton.frame.size = infoButton.frame.size
		imagesButton.tintColor=UIColor.yellow
		let imagesButtonImage = makeImagesButtonImage(size:imagesButton.frame.size)
		imagesButton.setImage(imagesButtonImage, for: .normal)

			
		let it1 = UIBarButtonItem(customView: cladeNameButton)
		let it2 = UIBarButtonItem(customView: imagesButton)
//		let it3 = UIBarButtonItem(customView: treePickerButton)
		let it4 = UIBarButtonItem(customView: infoButton)
		let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		// only add appropriate buttons depending on tree data
		var buttonArray = [spacer]
		if treeView.xTree.hasCladeNames
			{
			buttonArray += [it1,spacer]
			}
		//if treeView.xTree.imageCollection.hasImageFiles
		if treeView.xTree.hasImageFiles
			{
			buttonArray += [it2,spacer]
			}
		buttonArray += [it4,spacer]
		//buttonArray += [it3,spacer,it4,spacer] // add this when I add the taxon list button
		setToolbarItems(buttonArray,animated: false)
		}


// ****************************** Other view cycle overrides *******************************

	override func viewDidAppear(_ animated: Bool)
		{
		super.viewDidAppear(animated)
		}

	override func viewWillAppear(_ animated: Bool)
		{
		super.viewWillAppear(animated)
        navigationController!.setToolbarHidden(false, animated: false)
		}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
		}

   override func viewDidLayoutSubviews()
	
	// Here is the place to adjust the tree size parameters, since here the treeView frame/bounds has finally been established
	
   		{
//print ("Entering viewDidLayoutSubviews")
		super.viewDidLayoutSubviews()
		// Need to include the application state because of an apparent reportd bug where switching apps (i.e., sending this
		// to background) actually forces spurious calls to this func and viewWillTransition. Since these reset the TreeParams
		// it was causing unneeded resets to unzoomed, unpanned tree.
		if UIApplication.shared.applicationState == .active
			{
			if treeView.previousBounds == nil // treeview's bounds have not been set up; do the following the first time thru
				{
				treeView.setupViewDependentTreeRectsEtc()
				treeView.setupTreeCoordsForTreeToFill()
				}
			else
				{
				if treeView.bounds != treeView.previousBounds // treeview's been set up once anyway, change it if size has changed
					{
					treeView.updateTreeViewWhenSizeChanged(oldWindowHeight:treeView.previousBounds!.height)
					}
				}
			treeView.previousBounds = treeView.bounds
			treeView.setNeedsDisplay()
			}
    	}

// Handle recomputing tree coords on a device rotation event.

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)

// !! The transition animator appears to always call setNeedsLayout because it always jumps into viewDidLayoutSubviews

		{
//print ("Entering viewWillTransition")
		// note: size refers to self.view, not self.treeView
		//let oldH = self.treeView.frame.height
	super.viewWillTransition(to: size, with: coordinator)
//print ("In viewwilltransition",UIApplication.shared.applicationState,size, treeView.bounds, treeView.previousBounds)
/*
		if UIApplication.shared.applicationState == .active &&  treeView.bounds.size != size
			{
			coordinator.animate(alongsideTransition: nil)
				{ _ in
				//self.treeView.setupViewDependentTreeParameters()
//print ("In In viewwilltransition")

//print ("Calling setupvdtp from viewWillTransition")
				//self.treeView.updateTreeViewWhenSizeChanged(oldWindowHeight:oldH)
				//self.treeView.setNeedsDisplay() // have to keep
				}
			}
*/
		}

// **********************************

	// CAREFUL HERE RE: COORD SYSTEMS. Use 'treeView' as view in gesture recognizers. If you use self.view, the coords are in superview's system, which is a larger rectangle.
	// See diagram in DrawTreeView.swift.
	// This is because the view hierarchy set up has self.view as root and a subview called treeView

// ***********************************************************************************
// ***********************************************************************************
	// Helper function to let us pick the leaf image dot.
	// Take a y coordinate from the screen coord of the tap and convert it to an integer on [0..N-1] where N is the num leaves and
	// the leaves are arrayed regularly and vertically with 0 at the the top of screen and N-1 at bottom. Let's us pick the leaf photo dot.
	// RETURNS the integer in [0..N-1] or -1 if it is not 'close enough' to the dot vertically. That is controlled by tol, which is 
	// a fraction of the vertical distance between leaves

	func windowYToLeafIndexRange(windowY y:CGFloat)->(Int,Int)
		{
		let yTouchRadius = treeSettings.imageIconRadius
		let yTop = y - yTouchRadius
		let yBottom = y + yTouchRadius
		let ixLow = windowYToNearestLeafIndex(windowY:yTop)
		let ixHigh = windowYToNearestLeafIndex(windowY:yBottom)
//print ("y,top,bottom",y,yTop,yBottom)
		return (ixLow,ixHigh)
		}
	
	func windowYToNearestLeafIndex(windowY y:CGFloat)->Int
		{
		let delta:CGFloat = (treeView.xTree.maxY-treeView.xTree.minY)/CGFloat(treeView.xTree.numDescLvs-UInt(1))

		let iLow:Int = Int((treeCoord(fromWindowCoord: y)-treeView.xTree.minY)/delta)
		let iHigh:Int = iLow+1

//print ("y,delta,arg,iLow,iHigh",y,delta,(treeCoord(fromWindowCoord: y)-treeView.xTree.minY)/delta,iLow,iHigh)

		if (iLow < 0) // top boundary case // tricky, needs to be strictly <
			{
				return 0
			}
		else if (iLow >= (Int(treeView.xTree.numDescLvs) - 1)) // bottom boundary case
			{
				return Int(treeView.xTree.numDescLvs)-1
			}
		else	// middle cases
			{
			let diff1 = abs(treeCoord(fromWindowCoord: y) - treeView.xTree.minY - CGFloat(iLow)*delta)
			let diff2 = abs(treeCoord(fromWindowCoord: y) - treeView.xTree.minY - (CGFloat(iLow)+1)*delta)

			if (diff1 < diff2 ) // closer to lower point
				{ return iLow}
			else
				{ return iHigh }
			}
		}

// ***********************************************************************************
// ***********************************************************************************

// Image Pane controlling stuff

// ***********************************************************************************
// ***********************************************************************************
func addImagePane(atNode node:Node)
	{
	/*
	An imagePane may be instantiated with or without an image. However, we set all its VC functionality the same, but
	note that the tap gesture is handled differently in the two cases (see handlePaneSingleTap)
	*/
	// Instantiate frame at y = 0, which will place its center at tree coord y=0
	let aFrame = centeredRect(center: CGPoint(x:treeView.decoratedTreeRect.midX,y:0), size: CGSize(width:0,height:0))
	let imagePane = ImagePaneView(usingFrame:aFrame, atNode:node, onTree:treeView.xTree)
	treeView.addSubview(imagePane)
	//node.hasInstantiatedImagePane = true //  have to do this here after pane is init
	node.imagePaneView = imagePane // have to do this here after pane is init
	if imagePane.hasImage
		{
		node.isDisplayingImage = true //  have to do this here after pane is init
		}
	
	let imagePanGesture =  UIPanGestureRecognizer(target: self, action: #selector(handleImagePanePan(recognizer:)))
	imagePane.addGestureRecognizer(imagePanGesture)
	self.panGesture!.require(toFail: imagePanGesture) // ensures gestures sequenced right

	let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handleImagePanePinch(recognizer:)))
	pinchGesture.delegate = self // doesn't seem to matter
	imagePane.addGestureRecognizer(pinchGesture)

	let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImagePaneSingleTap(recognizer:)))
	tapGesture.cancelsTouchesInView = false
	imagePane.addGestureRecognizer(tapGesture)

	let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImagePaneDoubleTap(recognizer:)))
	doubleTapGesture.cancelsTouchesInView = false
	doubleTapGesture.numberOfTapsRequired = 2
	imagePane.addGestureRecognizer(doubleTapGesture)
	tapGesture.require(toFail: doubleTapGesture) // ensures gestures sequenced right

	let tripleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTripleTap(recognizer:)))
	tripleTapGesture.numberOfTapsRequired = 3
	imagePane.addGestureRecognizer(tripleTapGesture)

	doubleTapGesture.require(toFail: tripleTapGesture) // ensures double and triple tap sequenced right

	// This is a GR to long press imagePane to delete; only allow for user added data
	if treeView.treeInfo!.dataLocation! == .inDocuments
		{
		let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleImagePaneLongPress(recognizer:)))
		longTapGesture.delegate = self
		imagePane.addGestureRecognizer(longTapGesture)
		longTapGesture.minimumPressDuration = 1.0
		}

	}
// ***********************************************************************************

var alert: UIAlertController?

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
				treeView.bringSubview(toFront: imagePane)
				if imagePane.hasImage
					{
					alert = UIAlertController(title:"Delete user-added image from Phlora?",message:"", preferredStyle: .alert)
					let action1 = UIAlertAction(title: "Cancel", style: .cancel)
						{ (action:UIAlertAction) in self.dismiss(animated:true) }
					let action2 = UIAlertAction(title: "Delete", style: .default)
						{ (action:UIAlertAction) in
						//self.deleteImagePane(imagePane)
						self.deleteImageInPane(imagePane)
						}
					alert!.addAction(action1)
					alert!.addAction(action2)
					present(alert!, animated: true, completion: nil)
					}
			default:
				break
			}
		}
func deleteImagePane(_ imagePane:ImagePaneView)
	{
		if let node = imagePane.associatedNode
			{
			node.hasImage = false
			node.hasImageFile = false
			node.imagePaneView = nil
			guard let url = node.imageFileURL else { return }
			do 	{
				try FileManager.default.removeItem(at:url)
				}
			catch
				{
				print ("Error removing file")
				return
				}
			node.imageFileURL = nil
			treeView.xTree.setupNearestImageIconPositions(for : treeView.xTree.nodeArray) // have to recompute this now
	
			}
		imagePane.removeFromSuperview()
		self.treeView.setNeedsDisplay()
	}
func deleteImageInPane(_ imagePane:ImagePaneView) // This leaves the pane but resets to no image
	{
		if let node = imagePane.associatedNode
			{
			node.hasImage = false
			node.hasImageFile = false
			//node.imagePaneView = nil
			guard let url = node.imageFileURL else { return }
			do 	{
				try FileManager.default.removeItem(at:url)
				}
			catch
				{
				print ("Error removing file")
				return
				}
			node.imageFileURL = nil
			imagePane.deleteImage()
			}
		self.treeView.setNeedsDisplay() // to update the image icons 
	}

// ***********************************************************************************
// Minimally bring imagepane to front; if no image, go on add one!

func handleImagePaneSingleTap(recognizer : UITapGestureRecognizer)
		{
		let imagePane = recognizer.view as! ImagePaneView
		treeView.bringSubview(toFront: imagePane)
		switch recognizer.state
			{
			case UIGestureRecognizerState.began:
				break
			case UIGestureRecognizerState.changed:
				break
			case UIGestureRecognizerState.ended:
				if imagePane.hasImage == false
					{

					if let node  = imagePane.associatedNode
						{
						let coord = node.coord
						let origin = CGPoint(x:coord.x, y:WindowCoord(fromTreeCoord:coord.y, inTreeView: treeView)  )
						let sourceRect = CGRect(origin:origin, size:CGSize(width:0, height:0))
						//if let fileNameBase = node.originalLabel, let targetDir = docDirectoryNameFor(treeInfo:treeView.treeInfo!, ofType: .images)


							if let fileNameBase = node.originalLabel, let targetDir = docDirectoryNameFor(study: treeView.treeInfo!.treeName, inLocation:treeView.treeInfo!.dataLocation!, ofType:.images, create:true)
							{
							let icc = ImageChooserController(receivingImagePane:imagePane, calledFromViewController:self, copyToDir:targetDir, usingFileNameBase:fileNameBase, callingView:treeView, atRect: sourceRect)
							icc.launch()
							}
						}
					}
			default:
				break

			}
		}

// ***********************************************************************************

func handleImagePaneDoubleTap(recognizer : UITapGestureRecognizer)
		{
		let imagePane = recognizer.view as! ImagePaneView
		treeView.bringSubview(toFront: imagePane)
		//let location = recognizer.location(in: imagePane.imageView) // SUPER IMPORTANT location in imageView BECAUSE OF MY DEFINITION OF imagePane.scale
		switch recognizer.state
			{
			case UIGestureRecognizerState.began:
				break
			case UIGestureRecognizerState.changed:
				break
			case UIGestureRecognizerState.ended:
				let location = recognizer.location(in: imagePane) // SUPER IMPORTANT location in imageView BECAUSE OF MY DEFINITION OF imagePane.scale
				let scale:CGFloat = 2.0
				imagePane.scale(by:scale, around:location, inTreeView: treeView)
				self.treeView.setNeedsDisplay()
			default:
				break
			}

		}
// ***********************************************************************************

	func handleImageTripleTap(recognizer: UITapGestureRecognizer)
		{
		let imagePane = recognizer.view as! ImagePaneView
		treeView.bringSubview(toFront: imagePane)
		switch recognizer.state
			{
			case UIGestureRecognizerState.began:
				break
			case UIGestureRecognizerState.changed:
				break
			case UIGestureRecognizerState.ended:
//print ("Triple tap")
				if imagePane.isFrozen {imagePane.unfreeze(inTreeView:treeView)}
				else {imagePane.freeze(inTreeView:treeView)}
//				self.treeView.setNeedsDisplay()
			default:
				break
			}
		}

// ***********************************************************************************
	func handleImagePanePinch(recognizer : UIPinchGestureRecognizer)
		{
		killTheAnimationTimer()	// This is important. The image pane pan timer may still be running when I try to scale this, which mucks up the scaling around point behavior. This seems to have fixed it.
		let scale=recognizer.scale
		let imagePane = recognizer.view as! ImagePaneView
		treeView.bringSubview(toFront: imagePane)

		let location = recognizer.location(in: imagePane) // SUPER IMPORTANT location in imageView BECAUSE OF MY DEFINITION OF imagePane.scale


		switch recognizer.state
			{
			case UIGestureRecognizerState.changed:
				imagePane.scale(by:scale, around:location, inTreeView: treeView)
				self.treeView.setNeedsDisplay() // needed to update the diagonal lines

			default:
				break
			}
		recognizer.scale = 1
		}
// ***********************************************************************************
	func handleImagePanePan(recognizer : UIPanGestureRecognizer)
		{
		killTheAnimationTimer()	// If in the middle of a pan animation, kill the animation and go: IMPORTANT
		let imagePane = recognizer.view as! ImagePaneView
		treeView.bringSubview(toFront: imagePane)
		let translation = recognizer.translation(in: imagePane)
		switch recognizer.state
			{
			case UIGestureRecognizerState.began:
				break
			case UIGestureRecognizerState.changed:
				imagePane.translate(dx: translation.x, dy: translation.y, inTreeView: treeView)
				self.treeView.setNeedsDisplay() // needed to update the diagonal lines
				recognizer.setTranslation(CGPoint(x:0,y:0), in: imagePane) // reset
			case UIGestureRecognizerState.ended:
				let velocity = recognizer.velocity(in: imagePane)

				let magnitude = sqrt(velocity.x*velocity.x + velocity.y*velocity.y)
				let slideMultiplier = magnitude/1000
				let slideFactor = 0.05 * slideMultiplier

				let targetX = velocity.x * slideFactor
				let targetY = velocity.y * slideFactor
				let finalCenter = CGPoint(x:imagePane.center.x+targetX, y:imagePane.center.y+targetY)
			panningImageVelocity = velocity
				createDisplayLink2(forImagePane:imagePane, toTargetPt:finalCenter)
			default:
				break
			}
		}


// ***********************************************************************************
// ***********************************************************************************

// Tree View controlling stuff

// ***********************************************************************************
// ***********************************************************************************

	// When an image is doubletapped:
	//  If it is larger than minimum size it is reduced to min
	//  If it is equal to minimum size it is maximized

	func handleDoubleTap(gesture: UITapGestureRecognizer)
		{
		if treeView.imagesAreVisible
			{
			let location = gesture.location(in: treeView)
			let treeLocation = treePoint(fromWindowPoint:location)
				let leafIndex = treeView.xTree.imageCollection.getFrontmostImageView(atTreeCoord:treeLocation, inTreeView:treeView)
			if leafIndex != nil
				{
				if treeView.xTree.imageCollection.leafImageIsMinimized(withLeafIndex:leafIndex!)
					{treeView.xTree.imageCollection.imageRectMaximize(withLeafIndex:leafIndex!)}
				else
					{treeView.xTree.imageCollection.imageRectMinimize(withLeafIndex:leafIndex!)}
				treeView.setNeedsDisplay()
				}
			}
		}

// ***********************************************************************************

	// See the Intro Swift/App 'Working with view controllers page to set these up through IB correctly


 	func handleTap(gesture: UITapGestureRecognizer) {
		// Handle single tap anywhere on screen
		//	1. In image icon: if any image in the y-range is open, close all of them, else open all of them
		//	2. In image: bring to front

		//Location is in the superview's absolute coordinates, i.e., not local coords
		//let location = sender.location(in: self.view)
		var anyOpen:Bool=false
		//let location = sender.location(in: treeView)

		if treeView.imagesAreVisible == false
			{ return }

		let location = gesture.location(in: treeView)

		if treeView.decoratedTreeRectMinusImageIcons.contains(location) // tap is in tree+taxa zone; check if an image
			{ //...and move to front then
			let treeLocation = treePoint(fromWindowPoint:location)
			let leafIndex = treeView.xTree.imageCollection.getFrontmostImageView(atTreeCoord:treeLocation, inTreeView:treeView)
			if leafIndex != nil
				{
				treeView.setNeedsDisplay()
				}
			}
		else
		if treeView.imageIconsRect.contains(location)	// tap is in image icon zone, handle
			{


			let (ixLow,ixHigh) = windowYToLeafIndexRange(windowY:location.y)
			for ix in (ixLow...ixHigh)
				{
				if treeView.xTree.imageCollection.leafImageisOpen(withLeafIndex:ix) // close image if open (works under old code)
						{
						anyOpen=true
						break
						}
				}

			for ix in (ixLow...ixHigh)
				{
				let pickedNode = treeView.xTree.imageCollection.getPickedLeafNode(withLeafIndex:ix)
				if anyOpen // close any that are open, instead of opening one or more
					{
					if let imagePane = pickedNode.imagePaneView
						{
						imagePane.isHidden = true
						pickedNode.isDisplayingImage = false
						}
					}
				else // open one or more
					{
					if let imagePane = pickedNode.imagePaneView
						{
						imagePane.isHidden = false
						pickedNode.isDisplayingImage = true
						treeView.setNeedsLayout() // When an image has been hidden and then tree is panned, it may be in wrong
									// place and won't be updated by the setNeedsLayout prop observer in treeView...(apparently)
									// so need to do this explicitly when the pane becomes visible again
						}
					else
						{
						if pickedNode.nodeIsMaximallyVisible
							{
							if pickedNode.hasImageFile || treeView.showingImageAddButtons
								{ addImagePane(atNode:pickedNode) }
							}
						}

					}
				treeView.setNeedsDisplay() // only needed to update the imageIcons! Fix later by making them view objects?
				}




			}
		else // tap is not in treeRect
			{
				// Occasionally I had a funny response to this empty block; the code getting hung up...
			}
	}
// ***********************************************************************************
	// NB! My gesture recognizers use transforms on the tree node points, rather than the whole view.

	func handlePan(recognizer:UIPanGestureRecognizer)
		{
		let location = recognizer.location(in: treeView)

		killTheAnimationTimer()	// If in the middle of a pan animation, kill the animation and go

		let translation = recognizer.translation(in: treeView)
		//let treeLocation = treePoint(fromWindowPoint:location)

		if recognizer.state == UIGestureRecognizerState.began
			{

			}
		if recognizer.state == UIGestureRecognizerState.changed
			{
			if imageIsPanning  // panning an image
				{
				}
			else if imageIconsArePanning // panning an image icon
				{
				}
			else // panning on rest of tree view
				{
				treeView.panTranslateTree += translation.y // keeps track of panning position changes
				let bottomGap = treeOpensGapAtBottomByThisMuch(withPanOffset: treeView.panTranslateTree)
				let topGap = treeOpensGapAtTopByThisMuch(withPanOffset: treeView.panTranslateTree)
				if (bottomGap > 0.0) {treeView.panTranslateTree -= translation.y} // note translation must have been negative
				else if (topGap > 0.0) {treeView.panTranslateTree -= translation.y}

				treeView.setNeedsDisplay()
treeView.setNeedsLayout()
				recognizer.setTranslation(CGPoint(x:0,y:0), in: treeView)
				}
			}
		if recognizer.state == UIGestureRecognizerState.ended
			{
			if imageIsPanning
				{
				}
			else if imageIconsArePanning // panning an image icon
				{
				}
			else
				{
				//let velocity = recognizer.velocity(in: view)
				let velocity = recognizer.velocity(in: treeView)
				targetY = velocity.y

				let bottomGap = treeOpensGapAtBottomByThisMuch(withPanOffset: treeView.panTranslateTree+targetY)
				let topGap = treeOpensGapAtTopByThisMuch(withPanOffset: treeView.panTranslateTree+targetY)
				if (bottomGap > 0.0) {targetY += bottomGap}
				else if (topGap > 0.0) {targetY -= topGap} // correct in case animation will open a gap

				createDisplayLink()
				}
			}
		}
// ***********************************************************************************


	func treeOpensGapAtBottomByThisMuch(withPanOffset offset:CGFloat)->CGFloat // tree has moved up, leaving open space at bottom of window
			// so return a + value if open space exists, otherwise a minus
			// Note we have to nudge this a bit to add space for 1/2 the taxon labels at top and bottom
		{
		let yW = treeWindowCoord(fromTreeCoord: +treeView.xTree.maxY) + offset + max(treeView.maxStringHeight/2.0,treeSettings.imageIconRadius)
		return (treeView.decoratedTreeRect.maxY-yW)
		}

	func treeOpensGapAtTopByThisMuch(withPanOffset offset:CGFloat)->CGFloat
		{

		let yW = treeWindowCoord(fromTreeCoord: -treeView.xTree.maxY) + offset - max(treeView.maxStringHeight/2.0,treeSettings.imageIconRadius)
		
//print(treeView.xTree.maxY,offset,treeWindowCoord(fromTreeCoord: -treeView.xTree.maxY),max(treeView.maxStringHeight/2.0,treeSettings.imageIconRadius),yW, treeView.decoratedTreeRect.minY,yW - treeView.decoratedTreeRect.minY)
		return yW - treeView.decoratedTreeRect.minY
		}

	func treeWindowCoord(fromTreeCoord y:CGFloat)->CGFloat // Watch out! not generally what it implies. No pan offset
		{
		return (y + treeView.decoratedTreeRect.midY)
		}

// ***********************************************************************************
// ***********************************************************************************

	func windowCoord(fromTreeCoord Y:CGFloat)->CGFloat
		{
		return (Y + treeView.decoratedTreeRect.midY + treeView.panTranslateTree)
		
		}

	func treeCoord(fromWindowCoord y:CGFloat)->CGFloat
		{
		return (y - treeView.decoratedTreeRect.midY - treeView.panTranslateTree)
		}

// ***********************************************************************************
// ***********************************************************************************
	func treePoint(fromWindowPoint p:CGPoint)->CGPoint
		{
		return CGPoint(x:p.x,y:treeCoord(fromWindowCoord:p.y))
		}
// ***********************************************************************************

func killTheAnimationTimer() // If in the middle of a pan animation, kill the animation and go
	{
	if (timer != nil)
		{
		timer?.invalidate()
		timer=nil
		}
	}


	// Thanks to Ben Dietzkis' web site
	func createDisplayLink()
		{
		timer?.invalidate()
		timer=nil
		timer = CADisplayLink(target: self, selector: #selector(step))
		startAnimation = Date.timeIntervalSinceReferenceDate
		endAnimation  = Date.timeIntervalSinceReferenceDate + animateDuration
		startAnimationY = treeView.panTranslateTree
		lastUpdate = Date.timeIntervalSinceReferenceDate
		
		timer?.add(to: .current, forMode: .defaultRunLoopMode)
		}
	
	func step(displaylink: CADisplayLink)
			{
			let now: TimeInterval = Date.timeIntervalSinceReferenceDate

			let t = Float( (now-startAnimation)/animateDuration  )
			let tTransform = 1-powf((1-t),3.0) // easing out

			//print (now, startAnimation, endAnimation, t)
		
			if now >= endAnimation
				{
				killTheAnimationTimer()	// If in the middle of a pan animation, kill the animation and go
				}
			treeView.panTranslateTree = startAnimationY + CGFloat(tTransform) * targetY
			treeView.setNeedsDisplay()
			treeView.setNeedsLayout()

			}
	// Thanks to Ben Dietzkis' web site
	func createDisplayLink2(forImagePane ip:ImagePaneView, toTargetPt targetPt:CGPoint)
		{
		timer?.invalidate()
		timer=nil
		timer = CADisplayLink(target: self, selector: #selector(step2))
		startAnimation = Date.timeIntervalSinceReferenceDate
		lastTime = startAnimation
		endAnimation  = Date.timeIntervalSinceReferenceDate + animateDurationImagePanes
		self.panningImagePane = ip
		self.panningImagePaneStartPt = ip.center
		self.panningImagePaneEndPt = targetPt
		lastUpdate = Date.timeIntervalSinceReferenceDate
		
		timer?.add(to: .current, forMode: .defaultRunLoopMode)
		}
	
	func step2(displaylink: CADisplayLink)
			{
			let now: TimeInterval = Date.timeIntervalSinceReferenceDate
			let t = Float( (now-startAnimation)/animateDurationImagePanes  )
			let deltaT = now - lastTime!
			lastTime = now

			let tTransform = 1-powf(t,1.0) // deceleration function

			if now >= endAnimation
				{
				killTheAnimationTimer()	// If in the middle of a pan animation, kill the animation and go
				}
			if let ip = panningImagePane
				{

				let dx = CGFloat(deltaT) * panningImageVelocity!.x * CGFloat(tTransform)
				let dy = CGFloat(deltaT) * panningImageVelocity!.y * CGFloat(tTransform)

				ip.translate(dx: dx, dy: dy, inTreeView: treeView)
				treeView.setNeedsDisplay()
				}
			}

	
// ***********************************************************************************
// ***********************************************************************************

	func handlePinch(recognizer : UIPinchGestureRecognizer)
		{
		var imageWasPicked:Bool = false
//print ("Entering handlePinch")
		var leafIndex:Int?
		killTheAnimationTimer()	// If in the middle of a pan animation, kill the animation and go

		// Now pretty minimalist!! Just fetching the pinch scale factor


		var scale=recognizer.scale
		let location = recognizer.location(in: treeView)

		let treeLocation = treePoint(fromWindowPoint:location)
		if treeView.imagesAreVisible
			{
			leafIndex = treeView.xTree.imageCollection.getFrontmostImageView(atTreeCoord:treeLocation, inTreeView:treeView)
			if leafIndex != nil
				{ imageWasPicked=true}
			else
				{ imageWasPicked=false}
			}
		else
			{imageWasPicked=false}
		switch recognizer.state
			{
			case UIGestureRecognizerState.began:
				//print("Began",scale,imageScale)
				if imageWasPicked
					{
					imageIsZooming=true
					}
				else
					{
					imageIsZooming=false
					treeView.xTree.imageCollection.setPinchRectangleToStop() // in case this event happened before the zooming ended
					}
			case UIGestureRecognizerState.changed:
				//print("Changed",scale,imageScale)
				if imageWasPicked // image is zooming
					{
					imageIsZooming=true
					if treeView.xTree.imageCollection.imageIsBig(withLeafIndex:leafIndex!)! // zoom with a red rectangle if image is biggish
						{
						imageScale *= scale
						treeView.xTree.imageCollection.setPinchRectangleParamsAndStart(at:treeLocation, withScale:imageScale )
						}
					else // zoom the usual way if image is smallish
						{
						treeView.xTree.imageCollection.scaleImage(withLeafIndex:leafIndex!, by:scale, around:treeLocation, inTreeView:treeView)
						}
					treeView.xTree.imageCollection.setImageNotMaxOrMin(withLeafIndex:leafIndex!) // sets some flags to indicate this
					}
				else // tree is zooming
					{
					imageIsZooming=false
					treeView.xTree.imageCollection.setPinchRectangleToStop() // in case this event happened before the zooming ended

					// tree can get too small with this scaling so reduce by just correct amount to make scaleTreeBy=1
					if treeView.scaleTreeBy * scale < 1.0
						{scale = 1/treeView.scaleTreeBy}
					treeView.scaleTreeBy *= scale
					if treeView.scaleTreeBy.isNaN
						{ print ("Have mercy! scaleTreeBy is NaN. This is a sporadic error")}
					
					// The pinch/zoom will center around wherever the touch on the screen occurs
					// in the previous version, it only zoomed around the midY part of screen, which was less satisfying.
					// The scale -1 term is obscure. Have to refer to drawings for how to correct for zooming that is offset in this fashion
					treeView.panTranslateTree = (treeView.panTranslateTree+treeView.decoratedTreeRect.midY-location.y)*(scale-1) + treeView.panTranslateTree // Because the tree size changes, and it is already sitting

					let nodeTansform = CGAffineTransform(scaleX:1.0, y: scale)

					treeView.xTree.root.transformTreeCoords(by : nodeTansform)

					treeView.xTree.minY *= scale
					treeView.xTree.maxY *= scale // any problem with successive roundoff errors?

					let bottomGap = treeOpensGapAtBottomByThisMuch(withPanOffset: treeView.panTranslateTree)
					let topGap = treeOpensGapAtTopByThisMuch(withPanOffset: treeView.panTranslateTree)
					if (bottomGap > 0.0) {treeView.panTranslateTree += bottomGap}
					else if (topGap > 0.0) {treeView.panTranslateTree -= topGap}
		//treeView.setNeedsDisplay()
treeView.layoutSubviews()
					}
			
			case UIGestureRecognizerState.ended:
				//print("Ended",scale,imageScale)
				if imageWasPicked
					{
					treeView.xTree.imageCollection.scaleImage(withLeafIndex:leafIndex!, by:imageScale, around:treeLocation, inTreeView:treeView)
					treeView.xTree.imageCollection.setPinchRectangleToStop() // in case this event happened before the zooming ended
					imageIsZooming=false
					imageScale = 1.0
					}
				else
					{
					treeView.xTree.imageCollection.setPinchRectangleToStop() // in case this event happened before the zooming ended
					imageIsZooming=false
					imageScale = 1.0
					}

			default:
				break

			}

		treeView.setNeedsDisplay() 
		recognizer.scale = 1
		}

}
// ***********************************************************************************
// ***********************************************************************************

	func makeTreePickerButtonImage(size:CGSize) -> UIImage?
		// Well, efforty function to make bitmap for the clade name button image...
			{
			UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
			let ctx = UIGraphicsGetCurrentContext()!
			ctx.setStrokeColor(UIColor.white.cgColor) // restore stroke color

			for y in stride(from: 0, through: size.height, by: 4)
				{
				ctx.move(to: CGPoint(x: 0, y: y))
				ctx.addLine(to: CGPoint(x: size.width, y: y))
				ctx.strokePath()
				}
			let iconImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			return iconImage
			}

	func makeImagesButtonImage(size:CGSize) -> UIImage?
		// Well, efforty function to make bitmap for the clade name button image...
			{
			UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
			let ctx = UIGraphicsGetCurrentContext()!
			let rect = CGRect(origin: CGPoint(x:0,y:0), size: size)
			ctx.setStrokeColor(UIColor.white.cgColor)
			ctx.stroke(rect)

			let iconImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			return iconImage
			}

	func makeCladeNameButtonImage(size:CGSize) -> UIImage?
		// Well, efforty function to make bitmap for the clade name button image...but at least it is done only once
			{
			UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
			let ctx = UIGraphicsGetCurrentContext()!
			let rect = CGRect(origin: CGPoint(x:0,y:0), size: size)
			let upperRightCoord = CGPoint(x: rect.maxX, y: 0.0)
			let upperMiddleCoord = CGPoint(x:rect.midX, y:0.0)
			let centerCoord = CGPoint(x:rect.midX,y:rect.midY)
			let lowerLeftCoord = CGPoint(x:0.0,y:rect.maxY)
			let lowerRightCoord = CGPoint(x:rect.maxX,y:rect.maxY)

			ctx.beginPath()
			ctx.move(to: upperRightCoord)
			ctx.addLine(to: upperMiddleCoord)
			let startAngle:CGFloat = 1.5*CGFloat.pi
			let endAngle:CGFloat = CGFloat.pi

			ctx.addArc(center: centerCoord, radius: rect.midX, startAngle: startAngle, endAngle: endAngle, clockwise: true)
			// Note clockwise is flipped because UIView coord system is flipped
			ctx.addLine(to: lowerLeftCoord)
			ctx.addLine(to: lowerRightCoord)
			ctx.closePath()
			let path = ctx.path
			let bgcolor = UIColor(red: 0.0, green: 0.2, blue: 0.0, alpha: 1.0)
			ctx.setAlpha(1.0)
			ctx.setFillColor(bgcolor.cgColor)
			ctx.drawPath(using: .fill)
			ctx.addPath(path!)
			ctx.setStrokeColor(UIColor.yellow.cgColor)
			ctx.drawPath(using: .stroke)

			let iconImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			return iconImage
			}


/* How to add an activity indicator...terminated in viewDidAppear above
activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
self.view.addSubview(activityIndicator)
activityIndicator.center = CGPoint(x:view.frame.midX,y:view.frame.midY)
activityIndicator.frame.size=CGSize(width: 100, height: 100)
activityIndicator.isHidden=false
activityIndicator.startAnimating() // for some reason, I have to start this here, rather than in viewDidAppear
*/

//		UIDevice.current.beginGeneratingDeviceOrientationNotifications() ...need if use the orient info

