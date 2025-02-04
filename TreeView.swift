//
//  DrawLineView.swift
//  QGTut
//
//  Created by mcmanderson on 5/15/17.
//  Copyright © 2019 Michael J Sanderson. All rights reserved.
//

// The tree view itself

import UIKit
import QuartzCore

	func WindowCoord(fromTreeCoord Y:CGFloat, inTreeView treeView:TreeView)->CGFloat
		{
		return (Y + treeView.decoratedTreeRect.midY + treeView.panTranslateTree)
		
		}

	func TreeCoord(fromWindowCoord y:CGFloat, inTreeView treeView:TreeView)->CGFloat
		{
		return (y - treeView.decoratedTreeRect.midY - treeView.panTranslateTree)
		}


//@IBDesignable

/*
This subview is inset from the superview. It then does a bunch
of calculations of subrectangles that will be important for various things. Importantly, the geometry of
this treeView subview is determined at runtime when the view controller's viewDidLayoutSubviews executes.
Therefore, the init() for the subview apparently runs before the geometry is established, and I have to make
sure to initialize any geometry dependent stuff in that view controller func. The init() below should ONLY
handle stuff about the tree that is not dependent on the window geometry.

The TreeView is a subview of UIView.
Inside this is decoratedTree rectangle, which is the smallest rectangle containing the tree, taxa labels, and image icons. It may be vertically smaller than the UIView frame, so we can write some stuff at the bottom or top.
Inside the decoratedTree is the nakedTree rectangle, which is the smallest rectangle containing just the
tree's edges! No labels, etc. We center this around y=0 to build the tree node coordinate system.

There are a couple of other rectangles defined relative to the image icons; see defs below.

|---------------------------------------------------------------------------|
|  View:UIView (basically the entire screen)                                |
|  |----------------------------------------------------------------------| |
|  |     TreeView:UIView (inset on all sides from superview              )| |
|  |   |---------------------------------------------------------------|  | |
|  |   | decoratedTreeRect:CGRect  (tree+trimmings)                    |  | |
|  |   |    |-----------------------------------|                      |  | |
|  |   |    |  nakedTreeRect:CGRect             |                      |  | |
|  |   |    |     (just edges,nodes)            |                      |  | |
|  |   |    |                                   |                      |  | |
|  |   |    |                                   |                      |  | |
...
...
|  |   |    |                                   |                      |  | |
|  |   |    |                                   |                      |  | |
|  |   |    |-----------------------------------|                      |  | |
|  |   |---------------------------------------------------------------|  | |
|  |----------------------------------------------------------------------| |
|---------------------------------------------------------------------------|

*/




class TreeView: UIView
	{
	var xTree:XTree!
	var ctx : CGContext!
	var	taxonLabelAttributes = [
			NSForegroundColorAttributeName : treeSettings.labelFontColor,
			NSFontAttributeName : UIFont(name:treeSettings.labelFontName, size:treeSettings.labelFontSize)!
			]								// attributes for leaf labels; paragraph style for truncation setup in setup()
	let	infoTextAttributes = [
			NSForegroundColorAttributeName : treeSettings.infoFontColor,
			NSFontAttributeName : UIFont(name:treeSettings.infoFontName, size:treeSettings.infoFontSize)!
			]								// attributes for leaf labels
	let	imageTextAttributes = [
			NSForegroundColorAttributeName : treeSettings.imageFontColor,
			NSFontAttributeName : UIFont(name:treeSettings.imageFontName, size:treeSettings.imageFontSize)!
			]								// attributes for leaf labels
	let	progNameTextAttributes = [
			NSForegroundColorAttributeName : treeSettings.titleFontColor,
			NSFontAttributeName : UIFont(name:treeSettings.titleFontName, size:treeSettings.titleFontSize)!
			]								// attributes for leaf labels
	var scaleTreeBy:CGFloat=1.0				// realtime scaling of the y-axis tree size for pinch/zoom
	var maxLabelWidth:CGFloat=0.0			// length of longest leaf label
	var maxLabelHeight:CGFloat=0.0			// height of heighest leaf label
	let imageIconWidth:CGFloat=40.0			// width to reserve for icon to the right of taxon name, for an image; center in this width
	var xCenterImageIcon:CGFloat!				// the x coord of center of image icon
	let topBorderInsetFromFrame:CGFloat=0.0	// Space for info at top and bottom of drawTree frame
	let bottomBorderInsetFromFrame:CGFloat=0.0
	let rightBorderInsetFromFrame:CGFloat=10.0
	let leftBorderInsetFromFrame:CGFloat=10.0
	let labelSpacingFactor:CGFloat=1.1		// factor controlling vertical space between leaf labels (bigger=more space)
	var labelScaleFactor:CGFloat!			// factor computed in init() to describe vertical layout of labels and passed to drawClade with modification of scaleTreeBy
	let edgeDarknessFactor:CGFloat=100.0	// factor controlling how dark the leafward edges are in large trees (bigger=darker);
	var edgeScaleFactor:CGFloat!			// factor computed in init() to describe how leafward edges get darker in large trees
	var decoratedTreeRect:CGRect!					// the rectangle that includes the entire tree, with taxon labels and  image icons
	var decoratedTreeRectCentered:CGRect!			// ...centered about y=0
	var nakedTreeRect:CGRect!					// Just the nodes edges of the tree
	var nakedTreeRectCentered:CGRect!
	var decoratedTreeRectMinusImageIcons:CGRect!	// decorated rect minus the right column containing image icons
	var imageIconsRect:CGRect!						// Just the rectangle containing the image icons on right of screen
	var bottomInfoRect:CGRect!					// Rectangle below tree containing information
	var leafLabelsRect:CGRect!					// Rectangle containing leaf labels only
	var panTranslateTree:CGFloat=0.0			// realtime translation of y-axis of tree for panning
/* yuck; easy to get into infinite loops when layoutSubviews messes with panTranslateTree somewhere in its call chain
		{
		didSet {
			setNeedsLayout() // prop observer to trigger recalculation of subview images
			}
		}
*/

	var previousBounds:CGRect? // This is only initialized once the frame is set up, i.e., in viewDidLayoutSubviews


	var treeInfo:TreeInfoPackage?

// Defaults
	var imagesAreVisible = true					// used to toggle images (not image icons) all on or all off
	var cladeNamesAreVisible = false				// used to toggle whether all (available) clade names
	var showingImageAddButtons:Bool = false
	var stretchLeafLabelBy:CGFloat = 0.0
	var labelWidthAllowed = treeSettings.truncateLabelsLength // this may be shorter


	// Used if view is called programmatically
	override init(frame: CGRect)
		{
		super.init(frame:frame)
		setup()
		}
	
	
	init(using treeInfoPackage:TreeInfoPackage)
		{
		super.init(frame:CGRect())
		treeInfo = treeInfoPackage
		setup()
		}

	// Used with IB
	required init?(coder aDecoder: NSCoder) {
		super.init(coder:aDecoder)
		setup()
	}
	
	func setup()
		{
		windowIndependentSetup()
		//xTree.imageCollection.setup() // &&&&&&
		}


	func windowIndependentSetup()
		{
		xTree = XTree(withTreeInfoPackage:treeInfo!) // initialize the tree data structure
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineBreakMode = .byTruncatingTail
		taxonLabelAttributes[NSParagraphStyleAttributeName]=paragraphStyle
		(maxLabelWidth,maxLabelHeight) =  xTree.root.getLabelSizeInfo(withAttributes: taxonLabelAttributes)
		if treeSettings.truncateLabels // Set this up initially
			{
			labelWidthAllowed = min (maxLabelWidth,treeSettings.truncateLabelsLength)
			}
		else
			{
			labelWidthAllowed = maxLabelWidth
			}
		}

	func updateTreeViewIfNeeded() // Basic initialization of tree layout; called in viewDidLayoutSubviews, and applicationDidBecomeActive
		{
		switch UIApplication.shared.applicationState
			{
			case .background: // Don't permit any changes to treeView layout here
//print ("VDL: App is in background")
				return
			case .active, .inactive: // I include inactive state here, because that happens when app is transitioning from background to active state, and this is a useful time to update the treeView
//print ("VDL: App is active or inactive")
				if previousBounds == nil // treeview's bounds have not been set up; do the following the first time thru
					{
					setupViewDependentTreeRectsEtc()
					setupTreeCoordsForTreeToFill()
					previousBounds = bounds
					setNeedsDisplay()
					}
				else
					{
					if bounds != previousBounds // treeview's been set up once anyway, change it if size has changed
						{
						updateTreeViewWhenSizeChanged(oldWindowHeight:previousBounds!.height)
						previousBounds = bounds
						setNeedsDisplay()
						}
					}
			}
		}


func treeOpensGapAtTopByThisMuch()->CGFloat
	{
	return WindowCoord(fromTreeCoord:xTree.minY, inTreeView:self) - nakedTreeRect.minY
	}
func treeOpensGapAtBottomByThisMuch()->CGFloat
	{
	return nakedTreeRect.maxY - WindowCoord(fromTreeCoord:xTree.maxY, inTreeView:self)
	}


func updateTreeViewWhenLabelRectWidthSet(to newWidth:CGFloat)
	// Manage the change in the tree when we expand or contract the allowed label width
	// Its easier to sidestep other functions and use a transform here to avoid a bunch of assumptions in those functions
	{
		let widthIncrease =  newWidth - leafLabelsRect.width
		let originalNakedTreeWidth = nakedTreeRect.width
		nakedTreeRect = UIEdgeInsetsInsetRect(nakedTreeRect, UIEdgeInsets(top: 0, left: 0, bottom: 0, right: widthIncrease))

		nakedTreeRectCentered = UIEdgeInsetsInsetRect(nakedTreeRectCentered, UIEdgeInsets(top: 0, left: 0, bottom: 0, right: widthIncrease))

		leafLabelsRect = UIEdgeInsetsInsetRect(leafLabelsRect, UIEdgeInsets(top: 0, left: -widthIncrease, bottom: 0, right: 0))
		let scaleFactor = nakedTreeRect.width/originalNakedTreeWidth
		var nodeTransform = CGAffineTransform(translationX: +nakedTreeRect.minX, y: 0)
		nodeTransform = nodeTransform.scaledBy(x: scaleFactor, y: 1.0)
		nodeTransform = nodeTransform.translatedBy(x: -nakedTreeRect.minX, y: 0)
		xTree.root.transformTreeCoords(by : nodeTransform)
		// Have to be careful to do this w.r.t left margin of tree rect.
		// Also note the reverse ordering of transform operations, because I am doing operators on the transform, not the points...
	}


func updateTreeViewWhenSizeChanged(oldWindowHeight oldH:CGFloat) // On resize or dev rotation, modify the tree to fill new treeView, but keep it centered on wherever it was before and with same scale; requires some black magic.
	// NB. If the new window is taller than the old and the current view of the tree is really zoomed out, then the tree might
	// occupy less than a full screen in the new window (bad!), so we have to trap for that and zoom in some on the new view
	{

//print ("Entering updateTreeViewWhenSizeChanged")
		let oldTreeHeight = 2*xTree.maxY
		let savePan = panTranslateTree
// Phase 1. Rotate tree keeping the taxon at midY of screen centered at new screen. May open top/bot gaps when going from small to larger screen
		setupViewDependentTreeRectsEtc()
		setupTreeCoordsForTreeToFill()

		let newTreeHeight = nakedTreeRectCentered.height
		let restoreToOriginalTreeSizeScaleFactor = oldTreeHeight/newTreeHeight
		let nodeTansform = CGAffineTransform(scaleX:1.0, y: restoreToOriginalTreeSizeScaleFactor)
		xTree.root.transformTreeCoords(by : nodeTansform)
		xTree.minY *= restoreToOriginalTreeSizeScaleFactor
		xTree.maxY *= restoreToOriginalTreeSizeScaleFactor // any problem with successive roundoff errors?
		panTranslateTree = savePan // YES!
		scaleTreeBy = restoreToOriginalTreeSizeScaleFactor // This has to just be the scale it was before transformation, because we are forcing tree first into given rect

// Phase 2: Correct if gaps are opened when going from small to larger screen
		if bounds.height > oldH // only happens when screen height got bigger
			{
			var z:CGFloat
			let topGap = max (0, treeOpensGapAtTopByThisMuch())
			let bottomGap = max (0, treeOpensGapAtBottomByThisMuch())
			let maxGap = max (topGap, bottomGap)
			if maxGap == 0
				{ return }
			if topGap > bottomGap
				{
				z = TreeCoord(fromWindowCoord: decoratedTreeRect.midY, inTreeView: self) - xTree.minY
				}
			else
				{
				z = xTree.maxY - TreeCoord(fromWindowCoord: decoratedTreeRect.midY, inTreeView: self)
				}
			let scale = 0.5*nakedTreeRect.height/z
			let nodeTansform = CGAffineTransform(scaleX:1.0, y: scale)
			xTree.root.transformTreeCoords(by : nodeTansform)
			xTree.minY *= scale
			xTree.maxY *= scale
			panTranslateTree *= scale
			scaleTreeBy *= scale
			}

	}

	func setupViewDependentTreeRectsEtc() // Inits a tree filling the treeView with 0 pan and 1.0 scale
		{
//		(maxLabelWidth,maxLabelHeight) =  xTree.root.getLabelSizeInfo(withAttributes: taxonLabelAttributes)

		// the bounds rectangle is in the treeView's coord system, with origin of 0,0. That's the coord
		// system that draw commands go into, rather than the frame. The ycenter of the tree stays fixed
		// in the coord system, but the origin moves when the frame gets resized, which has to be corrected
		// when we redraw the tree. Sheesh

		decoratedTreeRect = UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(top: 0, left: leftBorderInsetFromFrame, bottom: 0, right: rightBorderInsetFromFrame))

		decoratedTreeRectMinusImageIcons = UIEdgeInsetsInsetRect(decoratedTreeRect, UIEdgeInsets(top: 0, left: 0, bottom: 0, right: imageIconWidth))

		// the treeRect and derived rectangles are used solely to provide bounds for the initial layout of
		// coordinates of the tree edges and labels. 

		decoratedTreeRectCentered = decoratedTreeRect.offsetBy(dx: 0, dy: -decoratedTreeRect.midY)

		imageIconsRect = UIEdgeInsetsInsetRect(decoratedTreeRect, UIEdgeInsets(top: 0, left: decoratedTreeRectMinusImageIcons.width, bottom: 0, right: 0))

		let neededTopBottomGap = max(maxLabelHeight/2.0,treeSettings.imageIconRadius) // to make room for labels and image icon space

		nakedTreeRect = UIEdgeInsetsInsetRect(decoratedTreeRect, UIEdgeInsets(top: neededTopBottomGap, left: 0, bottom: neededTopBottomGap, right: labelWidthAllowed+imageIconWidth))

		nakedTreeRectCentered = nakedTreeRect.offsetBy(dx: 0, dy: -nakedTreeRect.midY)

		leafLabelsRect = UIEdgeInsetsInsetRect(decoratedTreeRect, UIEdgeInsets(top: 0, left: nakedTreeRect.width, bottom: 0, right: imageIconsRect.width))

		labelScaleFactor = CGFloat(xTree.root.numDescLvs!)*maxLabelHeight*labelSpacingFactor/decoratedTreeRect.height
		edgeScaleFactor = edgeDarknessFactor/CGFloat(xTree.root.numDescLvs!)
		backgroundColor=treeSettings.viewBackgroundColor
		xCenterImageIcon = decoratedTreeRect.maxX - imageIconWidth/2.0
		}

	func setupTreeCoordsForTreeToFill()
		{
		xTree.root.setupNodeCoordinates (in: nakedTreeRectCentered, forTreeType : .cladogram)
		(xTree.minY,xTree.maxY)=xTree.root.minMaxY() // This will be updated any time pan or scale by specific code elsewhere
		panTranslateTree = 0
		scaleTreeBy = 1.0
		}


	func getTreeRect(fromView viewRect: CGRect, left leftMargin: CGFloat,right rightMargin: CGFloat,top topMargin: CGFloat,bottom bottomMargin: CGFloat)->CGRect
		{
		let treeRect = CGRect(x:viewRect.origin.x+leftMargin,y:viewRect.origin.y+topMargin,width:viewRect.size.width-leftMargin-rightMargin,height:viewRect.size.height-topMargin-bottomMargin)
		return treeRect
		}


	override func draw(_ rect: CGRect)
		{
//print ("4..calling draw in drawTreeView")
		ctx = UIGraphicsGetCurrentContext()
		ctx.setStrokeColor(treeSettings.edgeColor)
		ctx.setLineWidth(treeSettings.edgeWidth)


		// This clipping lets me be lazy about the code controlling the vertical edges of the tree crashing into the upper and lower
		// borders of the decoratedTreeRectangle. Otherwise, I would have to clip these exactly...see drawClade code...

		ctx.clip(to:decoratedTreeRect)


		// The tree's y coordinates are centered on y=0; have to correct for this and its current pan location
		// to center the tree vertically in the view's tree rectangle
		
		ctx.translateBy(x: 0.0, y: panTranslateTree + decoratedTreeRect.midY)
//
// !! FOLLOWING SOMETIMES THROWS AN ERROR WHEN TRY TO PAN RIGHT AFTER SCREEN APPEARS. NO IDEA WHY YET !!
//
		let everyNthLabel=floorPow2(UInt(labelScaleFactor/scaleTreeBy))	// complicated but guarantees that this is an integer on [1,2,4,8..] which means once a label appears on screen it will stay on screen as we zoom in

			xTree.root.drawClade(inContext: ctx, withAttributes: taxonLabelAttributes, showEveryNthLabel: everyNthLabel, withLabelScaler: labelScaleFactor/scaleTreeBy, withEdgeScaler: edgeScaleFactor*scaleTreeBy, labelMidY: maxLabelHeight/2.0,nakedTreeRect:/*self.bounds*/ decoratedTreeRect, withPanTranslate:panTranslateTree, xImageCenter:xCenterImageIcon, showingAddButtons:showingImageAddButtons,leafLabelRectangle:leafLabelsRect)
			// NB. Jult 31,2018: this got corrected to pass decoratedTreeRect instead of nakedTreeRect, but note I haven't changed parameter id yet. This makes the upper/lower border behavior of tree/labels clean now.
		
		if cladeNamesAreVisible && xTree.hasCladeNames
			{
			xTree.root.drawClassification(havingNodeArray:xTree.nodeArray,inContext: ctx, withAttributes: taxonLabelAttributes, showEveryNthLabel: everyNthLabel, withLabelScaler: labelScaleFactor/scaleTreeBy, withEdgeScaler: edgeScaleFactor*scaleTreeBy, labelMidY: maxLabelHeight/2.0,nakedTreeRect:/*self.bounds*/ nakedTreeRect, withPanTranslate:panTranslateTree, xImageCenter:xCenterImageIcon)
			}
		
		}


// ************ Function to layout the image subviews properly at correct position on tree

	override func layoutSubviews()
		{
		//super.layoutSubviews() ???? 
		for subview in subviews
			{
			if let imagePane = subview as? ImagePaneView
				{
				if !imagePane.isHidden && imagePane.isAttachedToNode()
					{
					// ........... Obscure place to do this but so be it:
					// 	If we deleted an image but left its pane open with an 'addimage' message and then we downloaded an image
					//	from the database, we have to load the image to the pane here. This gets called on main.async queue
					//	from the database view controller code

					//if imagePane.addImageLabel != nil
					if imagePane.imageIsLoaded == false //...but there is a file now...
						{
						if let imageFileURL = imagePane.associatedNode?.imageFileURL
							{
							imagePane.loadImage(atPath: imageFileURL.path)
							}
						}

					//............Now handle different layouts if panes are frozen or not
					
					if imagePane.isFrozen
						{
						imagePane.setLocationRelativeToTreeTo(0,imagePane.imageWindowCoord)
						}
					else
						{
						imagePane.setLocationRelativeTo(treeView:self)

						if self.bounds.intersects(imagePane.frame) == false && imagePane.imageLoadedAtResolution == .high // if it's hi-res but offscreen, reduce resolution
							{
							imagePane.switchToLowResImage()
							}
						}
					}
				}
			}
		}


}

