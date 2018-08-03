//
//  DrawLineView.swift
//  QGTut
//
//  Created by mcmanderson on 5/15/17.
//  Copyright © 2017 mcmanderson. All rights reserved.
//

import UIKit
import QuartzCore

	func WindowCoord(fromTreeCoord Y:CGFloat, inTreeView treeView:DrawTreeView)->CGFloat
		{
		return (Y + treeView.decoratedTreeRect.midY + treeView.panTranslateTree)
		
		}

	func TreeCoord(fromWindowCoord y:CGFloat, inTreeView treeView:DrawTreeView)->CGFloat
		{
		return (y - treeView.decoratedTreeRect.midY - treeView.panTranslateTree)
		}


@IBDesignable

/*
This subview is inset from the superview. It then does a bunch
of calculations of subrectangles that will be important for various things. Importantly, the geometry of
this treeView subview is determined at runtime when the view controller's viewDidLayoutSubviews executes.
Therefore, the init() for the subview apparently runs before the geometry is established, and I have to make
sure to initialize any geometry dependent stuff in that view controller func. The init() below should ONLY
handle stuff about the tree that is not dependent on the window geometry.

The drawTreeView is a subview of UIView.
Inside this is decoratedTree rectangle, which is the smallest rectangle containing the tree, taxa labels, and image icons. It may be vertically smaller than the UIView frame, so we can write some stuff at the bottom or top.
Inside the decoratedTree is the nakedTree rectangle, which is the smallest rectangle containing just the
tree's edges! No labels, etc. We center this around y=0 to build the tree node coordinate system.

There are a couple of other rectangles defined relative to the image icons; see defs below.

|---------------------------------------------------------------------------|
|  View:UIView (basically the entire screen)                                |
|  |----------------------------------------------------------------------| |
|  | drawTreeView:UIView (inset on all sides from superview, set up in IB)| |
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




class DrawTreeView: UIView
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
	var maxStringLength:CGFloat=0.0			// length of longest leaf label
	var maxStringHeight:CGFloat=0.0			// height of heighest leaf label
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

	var panTranslateTree:CGFloat=0.0			// realtime translation of y-axis of tree for panning

		{
		didSet {
			setNeedsLayout() // prop observer to trigger recalculation of subview images
			}
		}

	var previousBounds:CGRect = .zero


	var treeInfo:TreeInfoPackage?

// Defaults
	var imagesAreVisible = true					// used to toggle images (not image icons) all on or all off
	var cladeNamesAreVisible = false				// used to toggle whether all (available) clade names



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
//print("0: drawtree setup frame=",frame)
		windowIndependentSetup()
		xTree.imageCollection.setup() // &&&&&&
//		windowDependentSetup()
		}


	func windowIndependentSetup()
		{
		xTree = XTree(withTreeInfoPackage:treeInfo!) // initialize the tree data structure
//xTreeIsSetup = true
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineBreakMode = .byTruncatingTail
		taxonLabelAttributes[NSParagraphStyleAttributeName]=paragraphStyle

		}
	
	func windowDependentSetup()
		{
        setupViewDependentTreeParameters()
//		setupViewDependentImageCollectionGeometry() &&&&
//		xTree.imageCollection.setup()  &&&&&
		}

	func setupViewDependentImageCollectionGeometry()
		{
		xTree.imageCollection.imageMaximumWidth = decoratedTreeRectMinusImageIcons.width // clunky place to init this but has to be in this order...
		xTree.imageCollection.imageXCenter=decoratedTreeRectMinusImageIcons.midX //ditto
		}

	func setupViewDependentTreeParameters()
		{
		panTranslateTree=0.0
		scaleTreeBy=1.0
		
		(maxStringLength,maxStringHeight) =  xTree.root.getLabelSizeInfo(withAttributes: taxonLabelAttributes)

		if treeSettings.truncateLabels
			{
			maxStringLength = min (maxStringLength,treeSettings.truncateLabelsLength)
			}
		
		// the bounds rectangle is in the treeView's coord system, with origin of 0,0. That's the coord
		// system that draw commands go into, rather than the frame. The ycenter of the tree stays fixed
		// in the coord system, but the origin moves when the frame gets resized, which has to be corrected
		// when we redraw the tree. Sheesh


		//decoratedTreeRect = getTreeRect(fromView:self.bounds,left:leftBorderInsetFromFrame,right:rightBorderInsetFromFrame,top:topBorderInsetFromFrame,bottom:bottomBorderInsetFromFrame)

		decoratedTreeRect = UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(top: 0, left: leftBorderInsetFromFrame, bottom: 0, right: rightBorderInsetFromFrame))

		//decoratedTreeRectMinusImageIcons = getTreeRect(fromView:self.bounds,left:leftBorderInsetFromFrame,right:rightBorderInsetFromFrame+imageIconWidth,top:topBorderInsetFromFrame,bottom:bottomBorderInsetFromFrame)

		decoratedTreeRectMinusImageIcons = UIEdgeInsetsInsetRect(decoratedTreeRect, UIEdgeInsets(top: 0, left: 0, bottom: 0, right: imageIconWidth))



		// the treeRect and derived rectangles are used solely to provide bounds for the initial layout of
		// coordinates of the tree edges and labels. 



		decoratedTreeRectCentered = decoratedTreeRect.offsetBy(dx: 0, dy: -decoratedTreeRect.midY)

		//imageIconsRect = getTreeRect(fromView:self.bounds,left:leftBorderInsetFromFrame+decoratedTreeRectMinusImageIcons.width,right:rightBorderInsetFromFrame,top:topBorderInsetFromFrame,bottom:bottomBorderInsetFromFrame)

		imageIconsRect = UIEdgeInsetsInsetRect(decoratedTreeRect, UIEdgeInsets(top: 0, left: decoratedTreeRectMinusImageIcons.width, bottom: 0, right: 0))



		let neededTopBottomGap = max(maxStringHeight/2.0,treeSettings.imageIconRadius) // to make room for labels and image icon space

		//nakedTreeRect = CGRect(x:decoratedTreeRect.origin.x,y:decoratedTreeRect.origin.y+neededTopBottomGap,width:decoratedTreeRect.size.width-(maxStringLength+imageIconWidth),height:decoratedTreeRect.size.height-2*neededTopBottomGap)

		nakedTreeRect = UIEdgeInsetsInsetRect(decoratedTreeRect, UIEdgeInsets(top: neededTopBottomGap, left: 0, bottom: neededTopBottomGap, right: maxStringLength+imageIconWidth))

		nakedTreeRectCentered = nakedTreeRect.offsetBy(dx: 0, dy: -nakedTreeRect.midY)

		xTree.root.setupNodeCoordinates (in: nakedTreeRectCentered, forTreeType : TreeType.cladogram)

		(xTree.minY,xTree.maxY)=xTree.root.minMaxY() // This will be updated any time pan or scale by specific code elsewhere
		
		labelScaleFactor = CGFloat(xTree.root.numDescLvs!)*maxStringHeight*labelSpacingFactor/decoratedTreeRect.height
		edgeScaleFactor = edgeDarknessFactor/CGFloat(xTree.root.numDescLvs!)
		backgroundColor=treeSettings.viewBackgroundColor
		xCenterImageIcon = decoratedTreeRect.maxX - imageIconWidth/2.0
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

			xTree.root.drawClade(inContext: ctx, withAttributes: taxonLabelAttributes, showEveryNthLabel: everyNthLabel, withLabelScaler: labelScaleFactor/scaleTreeBy, withEdgeScaler: edgeScaleFactor*scaleTreeBy, labelMidY: maxStringHeight/2.0,nakedTreeRect:/*self.bounds*/ decoratedTreeRect, withPanTranslate:panTranslateTree, xImageCenter:xCenterImageIcon)
			// NB. Jult 31,2018: this got corrected to pass decoratedTreeRect instead of nakedTreeRect, but note I haven't changed parameter id yet. This makes the upper/lower border behavior of tree/labels clean now.
		
		if cladeNamesAreVisible && xTree.hasCladeNames
			{
			xTree.root.drawInternalLabels(havingNodeArray:xTree.nodeArray,inContext: ctx, withAttributes: taxonLabelAttributes, showEveryNthLabel: everyNthLabel, withLabelScaler: labelScaleFactor/scaleTreeBy, withEdgeScaler: edgeScaleFactor*scaleTreeBy, labelMidY: maxStringHeight/2.0,nakedTreeRect:/*self.bounds*/ nakedTreeRect, withPanTranslate:panTranslateTree, xImageCenter:xCenterImageIcon)
			}
		
		}


// ************ Function to layout the image subviews properly at correct position on tree

	override func layoutSubviews()
		{
		//super.layoutSubviews() ???? yup what about other subviews? OOps this assumes all subviews are imagepanes!!!
		for subview in subviews
			{
			let imagePane = subview as! ImagePaneView
			if !imagePane.isHidden && imagePane.isAttachedToNode
				{
// SHOULD IMBED THIS TEST IN THE SETLOC FUNC
				if let treeCoordY = imagePane.associatedNode?.coord.y
					{
					//imagePane.setLocationRelativeToTreeTo(0,panTranslateTree + treeCoordY + decoratedTreeRect.midY)
					
					//imagePane.upDateDiagonalFrame(iconX:xCenterImageIcon)
					//let newFrame = imagePane.upDateDiagonalFrame(usingFrame: imagePane.frame, iconX:xCenterImageIcon)
					//imagePane.diagonalLineView?.frame = newFrame
					imagePane.setLocationRelativeToTreeTo(0,WindowCoord(fromTreeCoord: treeCoordY , inTreeView: self))
setNeedsDisplay()
					}
				}
			}
		}


}

