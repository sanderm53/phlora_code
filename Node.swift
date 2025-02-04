//
//  Node.swift
//  QGTut
//
//  Created by mcmanderson on 5/16/17.
//  Copyright © 2019 Michael J Sanderson. All rights reserved.
//

// Node data structure within trees

import UIKit

func floorPow2(_ v:UInt)->UInt // smallest power of 2 integer less than this
	{
	var r:UInt = 1;
	var u = v
	u=u>>1
	while (u>0) // unroll for more speed...
		{
		u = u >> 1
		r = r << 1
		}
	return (r)
	}

func getLinearFunction(xmin xMin:Float, xmax xMax:Float, yxmin yxMin:Float, yxmax yxMax:Float)->(Float, Float)
	{
	let m = (yxMax-yxMin)/(xMax-xMin)
	let b = yxMin - m*xMin
	return (m,b)
	}

func clamp(_ x:CGFloat, between xmin:CGFloat, and xmax:CGFloat)->CGFloat
	{
	if x < xmin {return xmin}
	if x > xmax {return xmax}
	return x
}

class Node {
  var originalLabel: String? 	// This is the raw text from the newick file, remains unchanged throughout course of run
  var label: String?			// This is the label used by the program everywhere, may be modified or edited by the program
  var length: Float?
  var children: [Node] = [] // This is initialized to the empty array
  var order: Int?
  var numDescLvs:UInt?
  var leafID:UInt?
  var time: Float?
  var coord: CGPoint		//anything not optional must be initialized in inits below
  weak var parent: Node?
  var nodeIsMaximallyVisible:Bool = false // This refers to whether the node's LABEL is visible -- not the image icon
  var imageIconAlpha:CGFloat = 0.0	// This is the opacity of the image icon; will be hidden if too low
	
  //var hasImage: Bool?  // maybe totally deprecated??????
  var imageFileURL:URL?
  var imageFileDataLocation:PhloraDataLocation?
  var imageThumb:UIImage?

  var imagePaneView:ImagePaneView?
  //var hasImageFile: Bool = false
  var hasLoadedImageAtLeastOnce: Bool = false // but may have been unloaded...

// delete following...
//  var imageIsNowLoaded:Bool = false // but may be hidden or not...

	
  var descendantRangeOfIDs:(UInt,UInt) = (0,0)
  //var alphaModifier:CGFloat = 1.0
  var nodeFlag:Bool = false
  var closestImageIconNeighberDistance:Int = 10000

  var foundInSearch:Bool = false
	enum CladeNameType
                {
                case nodeBased
                case stemBased
                }
	struct CladeName {
		   var type:CladeNameType
		   var label:String
		   var originalLabel:String

		   init(_ s:String, ofType ty:CladeNameType)
				   {
					self.originalLabel = s
					self.type = ty
					var label=originalLabel
					if treeSettings.replaceUnderscore == true
						{
						label = label.replacingOccurrences(of: "_", with: " ")
						}
					if treeSettings.replaceSingleQuotes == true
						{
						label = label.replacingOccurrences(of: "'", with: "")
						}
					self.label = label
					}
		   }
	var cladeName:CladeName?

 func hasImagePaneView()->Bool
  	{
	return imagePaneView != nil
	}
 func hasImageFile()->Bool
  	{
	return imageFileURL != nil
	}
  func imageIsLoaded()->Bool
  	{
  	guard let ipv = imagePaneView else { return false }
	return ipv.imageIsLoaded
  	}

  init()
	{
	self.coord=CGPoint()
	}
  init(withLabel label: String)
	{
	self.originalLabel = label
	self.coord=CGPoint()
	}
  init(withLength length: Float)
	{
	self.length = length
	self.coord=CGPoint()
	}
  init(withLabel label: String, withLength length: Float)
	{
	self.originalLabel = label
	self.length = length
	self.coord=CGPoint()
	}

  //func isLabelPresent()->Bool { return label != nil }


  func add(child: Node)
	{
    children.append(child)
    child.parent = self
	}
  func isLeaf()->Bool
	{
	return children.isEmpty
	}
  func isRoot()->Bool
	{
	if parent==nil {return true}
	else {return false}
	}
  func printNode()
	{
	
	if self.label != nil
		{
		print ("\(self.label!) : isRoot (\(self.isRoot())) isLeaf (\(self.isLeaf())) ")
		}
	else
		{
		print ("Internal node : isRoot (\(self.isRoot())) isLeaf (\(self.isLeaf())) ")
		}
	print ("x=\(self.coord.x) y=\(self.coord.y)")
	
	}
  func printTree()
	{
	print ("\n*********")
	printNode();
	if self.length != nil
			{print ("Length=",self.length!) }
	if !self.children.isEmpty
		{
		print ("Children...")
		for child in children
			{ child.printNode()}
		}
	print ("*********")
	for child in children
		{ child.printTree()}
	}
	// **********************************************************************

	func getLeafLabels()->Set<String>
		{
		func getLeafLabelsHelper(node thisNode : Node,  labelSet theSet : Set<String>) -> Set<String>
			{
			var thisSet = theSet
			if thisNode.isLeaf()
				{thisSet.insert(thisNode.label!)}
			else
				{
				for child in thisNode.children
					{ thisSet = thisSet.union(getLeafLabelsHelper(node: child, labelSet: thisSet)) }
				}
			return thisSet
			}
		let S : Set<String> = []
		return (getLeafLabelsHelper(node : self,labelSet : S))
		}
	// **********************************************************************
	func getLabelSizeInfo(withAttributes textAttributes: [String: AnyObject]?)->(CGFloat,CGFloat)
		{
		let labelSpacing:CGFloat=5
		var nodeArray: [Node]=[]
		self.putNodeArray(into: &nodeArray)
		var maxStringLength:CGFloat=0.0
		var maxStringHeight:CGFloat=0.0
		for node in nodeArray
			{
			let boxSize = node.label!.size(attributes: textAttributes)
			if boxSize.width > maxStringLength {maxStringLength=boxSize.width}
			if boxSize.height > maxStringHeight {maxStringHeight=boxSize.height}
			}
		return (maxStringLength+labelSpacing,maxStringHeight)
		}

// Set a node parameter that will be used to dim edges within named clades
// Must be called after prepareLabels has been initialized first
// As the clade is expanded, the effect tends to diminish, since edges get brighter then anyway.
/*
func setEdgeAlphaModifier(haveSeenInternalLabel flag:Bool)
		{
		let dimFactor:CGFloat = 0.1
		var haveSeenLabelAlready = flag
		if haveSeenLabelAlready
			{
			self.alphaModifier=dimFactor
			}
		if isLabelPresent()
			{ haveSeenLabelAlready = true }
//print (label, alphaModifier)
		for child in children
			{ child.setEdgeAlphaModifier(haveSeenInternalLabel:haveSeenLabelAlready) }
		}
*/
	// **********************************************************************
	
	func putNodeArray(into nodeAr:inout [Node]) // leaf node array
		{
		if self.isLeaf() {nodeAr.append(self)}
		for child in children
			{ child.putNodeArray(into: &nodeAr) }
		}
		
	func setNodeFlags(to flag: Bool)
		{
		self.nodeFlag = flag
		for child in children
			{ child.setNodeFlags(to: flag) }
		}

	func assignLeafIDs(startingWith curID:inout UInt) -> (UInt,UInt)
		// irrespective of left or right ladderizing, this will put leaves in increasing sequence of IDs
		// from top to bottom of page. Also, for each node, saves the min and max of IDs of the desc clade.
		{
		var minMinID:UInt = 100000000
		var maxMaxID:UInt = 0
		var rangeOfIDs:(UInt,UInt)
		if isLeaf()
			{
			leafID = curID
			//print (self.label!,leafID!)
			rangeOfIDs = (curID,curID)
			curID += 1
			}
		else
			{
			for child in children
				{
				let (minID,maxID) = child.assignLeafIDs(startingWith: &curID)
				if (minID < minMinID) {minMinID=minID}
				if (maxID > maxMaxID) {maxMaxID=maxID}
				}
			rangeOfIDs = (minMinID,maxMaxID)
			}
		descendantRangeOfIDs = rangeOfIDs
//print (rangeOfIDs)
		return rangeOfIDs
		}


	// **********************************************************************
	


	// creates "display" labels from original labels in newick string.
	// possibly incl editing them; currently only affects leaves
	func prepareLabels()
		{
		if (originalLabel != nil) {
			label=originalLabel
			if treeSettings.replaceUnderscore == true
				{
				label = label!.replacingOccurrences(of: "_", with: " ")
				}
			if treeSettings.replaceSingleQuotes == true
				{
				label = label!.replacingOccurrences(of: "'", with: "")
				}
			}
		if isLeaf()
			{
			return
			}
		else
			{
			for child in children
				{ child.prepareLabels() }
			return
			}
		
		}

	func ladderize(direction whichWay:LadderizeType)
		{
		if isLeaf() {return}
		else
			{
			for child in children
				{ child.ladderize(direction:whichWay) }
			if numDescLvs == UInt(children.count)
				{ return } // trap for the special case of a terminal polytomy of just leaves. Swift's array sort is "unstable" and may rearrange the order of leaves
							// in this polytomy because it can't handle equality comparisons, which I don't want, because I may have alphabetized them in making the tree file
							// Gotcha!
			switch whichWay
				{
				case .left:
					children.sort {$0.numDescLvs! > $1.numDescLvs!} // sort desc order, thus first children have larger clade sizes? check
				case .right:
					children.sort {$0.numDescLvs! < $1.numDescLvs!}
				case .asis:
					return // do nothing, leave alone, probably shouldnt even call this method
				}
			return
			}
		}

	// **********************************************************************

	func treeCoordIsInRect(coord y:CGFloat, theRect:CGRect, withPanTranslate panTranslate:CGFloat)->Bool
		{
		let littleBuffer:CGFloat=1.0 // this corrects for floating point issues in the comparisons below
		let yTreeW = y + theRect.midY + panTranslate
		if (yTreeW < theRect.maxY+littleBuffer) && (yTreeW > theRect.minY-littleBuffer)
			{return true}
		else
			{return false}
		}

	func treeYCoord2RectY(coord y:CGFloat, theRect:CGRect, withPanTranslate panTranslate:CGFloat)->CGFloat
		{
		return  y + theRect.midY + panTranslate
		}

	// **********************************************************************

	func drawImageIcon(inContext ctx:CGContext, atX xCenter:CGFloat, atY yCenter:CGFloat,withRadius radius:CGFloat,withFillColor fillColor:CGColor, alpha:CGFloat, isFilled filled:Bool)
		{
		let squareSize:CGSize=CGSize(width:2*radius,height:2*radius)
		let imageIconOrigin=CGPoint(x:xCenter-radius, y:yCenter-radius)
		let imageIconRect = CGRect(origin:imageIconOrigin, size:squareSize)
		// that's the point to left of node on horiz line, offset a little by the arc
		ctx.setAlpha(alpha)
		ctx.move(to:imageIconOrigin)
		if filled
			{
			ctx.setFillColor(fillColor)
			ctx.fillEllipse(in:imageIconRect)
			}
		else
			{
			ctx.setStrokeColor(treeSettings.imageIconColor)
			ctx.strokeEllipse(in:imageIconRect)
			}
		//ctx.strokePath()
		ctx.setStrokeColor(treeSettings.edgeColor) // restore stroke color
		
		
		}



/*	...To do...but I need to fade the internal labels or oclude them so no overlaps
	...One way would be to disallow any two internal labels with similar y-window coords but would be choppy
	...so perhaps need to come up with a fade function...
*/
	
	func drawClassification(havingNodeArray nodeArray:[Node], inContext ctx:CGContext, withAttributes textAttributes: [String: AnyObject]?, showEveryNthLabel everyNthLabel:UInt,withLabelScaler labelScaleFactor:CGFloat, withEdgeScaler edgeScaleFactor: CGFloat, labelMidY yOffset:CGFloat, nakedTreeRect:CGRect, withPanTranslate panTranslate:CGFloat, xImageCenter:CGFloat)
		// Recurses in from this node and draws nested shaded rounded rectangles for named clades, and the clade label
		{
		var cladeRootXPos:CGFloat
//if !isLeaf()  //  ouch, don't do what's to the right; messes up recursion...===> &&  self.originalLabel != nil
		//if true  //  ouch, don't do what's to the right; messes up recursion...===> &&  self.originalLabel != nil
		//	{
			//if self.label != nil
			if let cladeName = self.cladeName
				{
				drawRoundedRectClade(inContext:ctx, havingNodeArray:nodeArray)

				var	cladeLabelAttributes = [
						NSForegroundColorAttributeName : UIColor.yellow,
						NSFontAttributeName : UIFont(name:treeSettings.labelFontName, size:treeSettings.cladeLabelFontSize)!
						]								// attributes for leaf labels; paragraph style for truncation setup in setup()
				let paragraphStyle = NSMutableParagraphStyle()
				paragraphStyle.lineBreakMode = .byTruncatingTail
				cladeLabelAttributes[NSParagraphStyleAttributeName]=paragraphStyle


				//let aText=NSAttributedString(string:self.label!,attributes: cladeLabelAttributes)
				let aText=NSAttributedString(string:cladeName.label,attributes: cladeLabelAttributes)

				let textHeight = aText.size().height
				
				let nudge:CGFloat = 5.0

				//let allowedTextWidthWithinClade = nakedTreeRect.maxX - self.coord.x-nudge
				//let allowedTextWidthLeftOfClade = self.coord.x - nudge
				var textRect:CGRect
				var allowedTextWidthWithinClade:CGFloat
				switch cladeName.type
					{
					case .nodeBased:
						cladeRootXPos = self.coord.x
						allowedTextWidthWithinClade = nakedTreeRect.maxX - cladeRootXPos - nudge
					case .stemBased:
						cladeRootXPos = parent!.coord.x  // for there to be a stem-based defn here, there has to be a parent
						allowedTextWidthWithinClade = nakedTreeRect.maxX - cladeRootXPos - nudge
					}
				let allowedTextWidthLeftOfClade = cladeRootXPos - nudge


				if aText.size().width < allowedTextWidthWithinClade // fits within clade
					{
					textRect = CGRect(x:cladeRootXPos+nudge,y:self.coord.y-textHeight/2,width:aText.size().width, height:textHeight)
					}
				else
					{
					if aText.size().width < allowedTextWidthLeftOfClade // fits to left of clade aligned right against clade root
						{
						//textRect = CGRect(x:cladeRootXPos-aText.size().width-nudge,y:self.coord.y-textHeight/2,width:aText.size().width, height:textHeight)
						textRect = CGRect(x:cladeRootXPos-aText.size().width,y:self.coord.y-textHeight/2,width:aText.size().width, height:textHeight)
						}
					else // Too big, so align left against left margin
						{
						//textRect = CGRect(x:nakedTreeRect.minX+nudge,y:self.coord.y-textHeight/2,width:nakedTreeRect.width-nudge, height:textHeight)
						textRect = CGRect(x:nakedTreeRect.minX,y:self.coord.y-textHeight/2,width:nakedTreeRect.width, height:textHeight)
						}

					}
				ctx.setAlpha(0.4)
				
				
				aText.draw(in:textRect)
				ctx.setStrokeColor(treeSettings.edgeColor) // restore stroke color

				} // end of label present handling

			for child in children
				{
				child.drawClassification(havingNodeArray:nodeArray, inContext:ctx, withAttributes: textAttributes, showEveryNthLabel: everyNthLabel, withLabelScaler: labelScaleFactor, withEdgeScaler:edgeScaleFactor, labelMidY:yOffset, nakedTreeRect: nakedTreeRect, withPanTranslate:panTranslate,xImageCenter: xImageCenter)
				}

		//	}
		//else // is leaf
		//	{
		//	return
		//	}
		}
//***************************************************
// Heinous code to make sure balloons remain nested. Following function is used to check for the length of the longest top right edge in any
// balloon that is nested within this one. We need this to correct for the balloon that will be drawn here. See drawRoundedRectClade()

	func maxUpperLengthLimitInDescendants(from leafNodeUpper:Node)->CGFloat
		{
if isLeaf() { return 0.0 } // happens with stem group defn of monotypic group
		let edgeRoundAmount:CGFloat = 3 // this is the "radius" from the drawClade routine
		var node=leafNodeUpper
		var maxAllowedEdgeUpperLength = leafNodeUpper.coord.x  - leafNodeUpper.parent!.coord.x - edgeRoundAmount
		node = node.parent!

		while (node !== self) // traverse from leaf node back to root of this clade.
			{
			//if !node.isLeaf() && node.isLabelPresent() // passing through internal node with a label on way back to root of this clade
			if !node.isLeaf() && node.cladeName != nil // passing through internal node with a label on way back to root of this clade
				{
				var yMin:CGFloat = 10000000.0
				var yMax:CGFloat = -10000000.0
				for child in node.children
					{
						if child.coord.y < yMin {yMin = child.coord.y}
						if child.coord.y > yMax {yMax = child.coord.y}
					}
				yMin += edgeRoundAmount
				yMax -= edgeRoundAmount // this range measures the vertical edge (without corners) running through the self node

				let topVertRadiusLimit = yMin - leafNodeUpper.coord.y
				let topHorizRadiusLimit = (leafNodeUpper.coord.x - node.coord.x) - maxAllowedEdgeUpperLength
				let topRadius = min(topVertRadiusLimit,topHorizRadiusLimit)
				let upperLength =  (leafNodeUpper.coord.x - node.coord.x) - topRadius

				if upperLength > maxAllowedEdgeUpperLength {maxAllowedEdgeUpperLength = upperLength}
				}
			node = node.parent!
			}
		
		return maxAllowedEdgeUpperLength
		}


// !! NOTE WE SHOULD CREATE PATH ONLY ONCE AND CHANGE IT ONLY ON ZOOMING. STAYS THE SAME ON PAN, BUT CURRENTLY RECOMPUTING EVEN THEN!!!
// Note also this is for ONE KIND OF LADDERIZING ONLY. IT WILL BORK IF LADDERIZING IS REVERSED..
// Feb 2019 I added ability to have a monotypic stem based clade. However, the code does not trivially let me fatten up the width of this without introducing artifacts in the polygon. Needs work.

	func drawRoundedRectClade(inContext ctx:CGContext, havingNodeArray nodeArray:[Node])
		{
		let leafNodeUpper = nodeArray[Int(self.descendantRangeOfIDs.0)] // Upper refers to screen direction!
		let leafNodeLower = nodeArray[Int(self.descendantRangeOfIDs.1)] // arrays don't want UInt subscripts
		let edgeRoundAmount:CGFloat = 3.0 // this is same as "radius" in drawClade(), where that controls round corners of tree edges
		let nudge:CGFloat = 3.0 // keep clade boundary away from tree edges by this distance

		// Find the y-axis range of children of this node
		// Careful! If these aren't big enough, it generates downstream glitches in the clade shape layout...
		// yMin and yMax is the y range of the vertical line at the root of the clade; should be zero if a leaf, and is corrected downward below by the rounded corner dimension
		var yMin:CGFloat = 10000000.0
		var yMax:CGFloat = -10000000.0
		if isLeaf() // for a leaf node (i.e., a monotypic stem based group)
			{
			yMin = coord.y
			yMax = coord.y
			}
		else // for an internal node get the range over children
			{
			for child in children
				{
					if child.coord.y < yMin {yMin = child.coord.y}
					if child.coord.y > yMax {yMax = child.coord.y}
				}
			yMin += edgeRoundAmount
			yMax -= edgeRoundAmount // when not a leaf, that is, a range of subtaxa,
			}

// QUESTION: DO I NEED TO CORRECT LOWER EDGE AS WELL? MAYBE NOT BUT SHOULD CHECK!!! -- Checked and don't think so...
// Nudge the "corners" so they do not overlap the tree edges
		let upperRightCoord = CGPoint(x:leafNodeUpper.coord.x + nudge, y:leafNodeUpper.coord.y-nudge)
		let lowerRightCoord = CGPoint(x:leafNodeLower.coord.x + nudge, y:leafNodeLower.coord.y+nudge)
		
		//let thisRootCoord = CGPoint(x:self.coord.x - nudge,y:self.coord.y)
		var thisRootCoord:CGPoint
		guard let cladeName = self.cladeName else {return}
		switch cladeName.type
			{
			case .nodeBased:
				thisRootCoord = CGPoint(x:self.coord.x - nudge,y:self.coord.y)
			case .stemBased:
				thisRootCoord = CGPoint(x:parent!.coord.x + nudge,y:self.coord.y) // Any stem def at a node will have a parent node
			}

		let topVertRadiusLimit = yMin - upperRightCoord.y
		let topHorizRadiusLimit = (upperRightCoord.x - thisRootCoord.x) - maxUpperLengthLimitInDescendants(from:leafNodeUpper)

		let topRadius = min(topVertRadiusLimit,topHorizRadiusLimit)

		var bottomRadius = lowerRightCoord.y - yMax
		let bottomRadiusLimit = (leafNodeLower.parent!.coord.x + edgeRoundAmount) - thisRootCoord.x // don't allow radius to get larger than this
		bottomRadius = min(bottomRadius,bottomRadiusLimit)

		let topHorizEdgeLength = upperRightCoord.x - thisRootCoord.x - topRadius
		let bottomHorizEdgeLength = lowerRightCoord.x - thisRootCoord.x - bottomRadius
		let topHorizEdgeLeftPt = CGPoint(x: upperRightCoord.x - topHorizEdgeLength , y: upperRightCoord.y)
		let bottomHorizEdgeLeftPt = CGPoint(x: lowerRightCoord.x - bottomHorizEdgeLength , y: lowerRightCoord.y)
		let leftVertEdgeLowerPt = CGPoint(x: thisRootCoord.x, y: yMax)
		let upperLeftRadiusCenterPt = CGPoint(x: topHorizEdgeLeftPt.x, y: topHorizEdgeLeftPt.y + topRadius)
		let lowerLeftRadiusCenterPt = CGPoint(x: bottomHorizEdgeLeftPt.x, y: bottomHorizEdgeLeftPt.y - bottomRadius)

		ctx.beginPath()
		ctx.move(to: upperRightCoord)
		ctx.addLine(to: topHorizEdgeLeftPt)
		var startAngle:CGFloat = 1.5*CGFloat.pi
		var endAngle:CGFloat = CGFloat.pi

		ctx.addArc(center: upperLeftRadiusCenterPt, radius: topRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
			// Note clockwise is flipped because UIView coord system is flipped
		ctx.addLine(to: leftVertEdgeLowerPt)
		startAngle = CGFloat.pi
		endAngle = 0.5*CGFloat.pi
		ctx.addArc(center: lowerLeftRadiusCenterPt, radius: bottomRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
		ctx.addLine(to: lowerRightCoord)
		ctx.closePath()
		let path = ctx.path

		let cladebgcolor = UIColor(red: 0.0, green: 0.2, blue: 0.0, alpha: 1.0)

		// HACK TEMP!!
		let cladeAlpha = 0.8 * 200.0 / (leafNodeLower.coord.y - leafNodeUpper.coord.y) // about right for 10.5" iPad

		let cladeBorderAlpha = clamp(cladeAlpha, between:0.6, and:0.6)

		ctx.setAlpha(cladeAlpha)
		//ctx.setFillColor(UIColor.green.cgColor)
		ctx.setFillColor(cladebgcolor.cgColor)
		ctx.drawPath(using: .fill)
		ctx.addPath(path!)
		ctx.setAlpha(cladeBorderAlpha)
		ctx.setStrokeColor(UIColor.yellow.cgColor)
		ctx.drawPath(using: .stroke)

		return
		}

	// **********************************************************************


	func drawLineToImage(inContext ctx:CGContext, fromX xImageCenter:CGFloat)
		{
		var imagePaneUpperRight:CGPoint
		if let imagePane = self.imagePaneView
			{
			ctx.setLineWidth(treeSettings.edgeWidth)


			let imageIconPt = CGPoint(x:xImageCenter, y:coord.y)

			if imagePane.isFrozen
				{
				guard let treeView = imagePane.superview as? TreeView else { return }
				let targetTreeCoord = TreeCoord(fromWindowCoord: imagePane.imageWindowCoord,inTreeView: treeView)
				imagePaneUpperRight = CGPoint(x: imagePane.frame.maxX, y: targetTreeCoord-imagePane.frame.height/2.0 + imagePane.center.y)
				}
			else
				{
				imagePaneUpperRight = CGPoint(x: imagePane.frame.maxX, y: coord.y-imagePane.frame.height/2.0 + imagePane.center.y)
				}
			ctx.setAlpha(1.0)
			ctx.move(to:imageIconPt)
			ctx.addLine(to:imagePaneUpperRight)
			ctx.setStrokeColor(treeSettings.imageToIconLineColor) // restore stroke color
			ctx.setLineWidth(3.0)
			ctx.setLineDash(phase: 0, lengths: [1,3])
			ctx.strokePath()
			ctx.setLineDash(phase: 0, lengths: [])
			ctx.setLineWidth(treeSettings.edgeWidth)
			}
		}

	enum ImageIconType {
		case blank
		case addSymbol(CGColor,CGFloat)
		case openCircle(CGColor,CGFloat)
		case filledCircle(CGColor,CGFloat)
		}

	func drawImageIcon(ofType iconType:ImageIconType, inContext ctx:CGContext, atPointCenter pt:CGPoint,withRadius radius:CGFloat)
		{
		let squareSize:CGSize=CGSize(width:2*radius,height:2*radius)
		let imageIconOrigin=CGPoint(x:pt.x-radius, y:pt.y-radius)
		let imageIconRect = CGRect(origin:imageIconOrigin, size:squareSize)
		switch iconType {
			case .blank: return

			case let .addSymbol(color,alpha):
				let insetRectangleBy:CGFloat = 6.0
				let smallerRect = imageIconRect.insetBy(dx: insetRectangleBy, dy: insetRectangleBy)
				ctx.setAlpha(alpha)
				ctx.setStrokeColor(color)
				ctx.move(to: CGPoint(x:smallerRect.minX, y:pt.y))
				ctx.addLine(to: CGPoint(x:smallerRect.maxX, y:pt.y))
				ctx.move(to: CGPoint(x:pt.x, y:smallerRect.minY))
				ctx.addLine(to: CGPoint(x:pt.x, y:smallerRect.maxY))
				ctx.strokePath()

			case let .filledCircle(color,alpha):
				ctx.setAlpha(alpha)
				ctx.setFillColor(color)
				ctx.fillEllipse(in:imageIconRect)

			case let .openCircle(color,alpha):
				ctx.setAlpha(alpha)
				ctx.setStrokeColor(color)
				ctx.strokeEllipse(in:imageIconRect)
			}
		// that's the point to left of node on horiz line, offset a little by the arc

		ctx.setStrokeColor(treeSettings.edgeColor) // restore stroke color
		}


	func drawClade(inContext ctx:CGContext, withAttributes textAttributes: [String: AnyObject]?, showEveryNthLabel everyNthLabel:UInt,withLabelScaler labelScaleFactor:CGFloat, withEdgeScaler edgeScaleFactor: CGFloat, labelMidY yOffset:CGFloat, nakedTreeRect:CGRect, withPanTranslate panTranslate:CGFloat, xImageCenter:CGFloat, showingAddButtons   showingImageAddButtons:Bool,leafLabelRectangle leafLabelsRect:CGRect)
			{
		var curAlpha:CGFloat = 0.0 // need this default below!
		let radius:CGFloat=3 // Adjust this to change roundedness of corners
		var direction:Bool
		let startAngle:CGFloat = CGFloat.pi
		var endAngle:CGFloat
		var yCornerOffset:CGFloat
		let labelSpacing:CGFloat=6 // horizontal distance from tip to label start
		if isLeaf()
			{
			// Draw the dashed line from imageIcon to imagePaneView
			if let imagePane = imagePaneView
				{
				if imagePane.isHidden == false
					{
					drawLineToImage(inContext:ctx, fromX:xImageCenter)
					}
				}

			// I do some optimizations here to avoid writing offscreen. Maybe not necessary; maybe also do it
			// when the lines are very faint
			// Only handle label writing if it will be visible!
			if treeCoordIsInRect(coord: coord.y, theRect: nakedTreeRect, withPanTranslate: panTranslate)
				{
				let aText=NSAttributedString(string:self.label!,attributes: textAttributes)
				let vertCenteredPt = CGPoint(x:self.coord.x+labelSpacing,y:self.coord.y-yOffset)

			if foundInSearch
				{
				let leafPt = CGPoint(x:self.coord.x,y:self.coord.y)
				drawImageIcon(ofType:.filledCircle(UIColor.red.cgColor,1.0), inContext:ctx, atPointCenter:leafPt,withRadius:5.0)
				}

				// Following code sets up a fade out for the text labels as we zoom tree in out, controlled
				// by setting context alpha value
				// labelScaleFactor ranges from (everyNthLabel,2*everyNthLabel)
				// Convert it to a number on (0,1) then multiply by a fade rate factor
				let fadeRate:CGFloat=3.0 // larger = fades quicker as we zoom out
				let alphaComplement = fadeRate*(labelScaleFactor-CGFloat(everyNthLabel))/CGFloat(everyNthLabel)
				// In a fairly obtuse way, the following two lines make the fading and nonfading leaf alternate
				// as we go vertically down the labels in the view. Note the labels are guaranteed to be
				// ordered vertically by the way the initialization of label ids works

				nodeIsMaximallyVisible = false // every leafID will be false except for following condition. Used in view controller to avoid adding paneView for faded or invisible nodes
				if (leafID! % (2*everyNthLabel)==0)
					{
					curAlpha = 1.0
					nodeIsMaximallyVisible = true
					}				// doesn't fade
				if (leafID! % (2*everyNthLabel) == everyNthLabel)
					{
					curAlpha = 1-alphaComplement
					if curAlpha > 0.95 // so, nearly fully opaque
						{ nodeIsMaximallyVisible = true }
					}
				// That was tricky; remember there are other leafIDs than match the prev two conditions!

				ctx.setAlpha(curAlpha)

				if  (leafID! % everyNthLabel) == 0  // Always want to be displaying at this regular position, esp when dense
					{
					// Draw the labels
					if treeSettings.truncateLabels
						{
						//let textRect = CGRect(origin: vertCenteredPt, size: CGSize(width: treeSettings.truncateLabelsLength, height: 2*yOffset))
						let textRect = CGRect(origin: vertCenteredPt, size: CGSize(width: leafLabelsRect.width, height: 2*yOffset))
						aText.draw(in:textRect)
						}
					else
						{
						aText.draw(at:vertCenteredPt)
						}

					// Now do all the image icon possibilities

					// First, filled circles of two possible colors when we know there is an image file
					
					if hasImageFile()  // draw the icon possibly before loading image as long as there is a known image file for this image
						/* When there is an image file present, I display an icon according to a delicate algorithm that trades off the fadeout-
						behavior that I want for the labels (which are densely arrayed vertically), with the actual density of images vertically (which
						may or may not be dense, but will be less or equal in density to the labels. When the icons are dense, basically I want them
						to fade like labels, but when they are sparse I want them to be visible in some negativemonotonic relation to their density.
						When the leaf node is at the everyNthLabel positions, there is a computed alpha value based on the same criteria as labels.
						For every leaf node there is also a density based alpha value. When the leaf node is inbetween everyNthLabel, use the density
						based alpha only. When the leaf node is at one of those everyNthLabel positions, use the maximum of the two alpha values to
						ensure visiblity as appropriate.
						!! NEED TO FIGURE OUT HOW TO UPDATE THIS AS IMAGES ARE ADDED...!!
						*/
						{
						var fillColor:CGColor
						// Switch the color of the image icon depending on if it is displaying
						if imageIsLoaded()
							{fillColor = treeSettings.imageFontColor.cgColor}
						else if hasLoadedImageAtLeastOnce
							{fillColor = treeSettings.imageUnloadedColor}
						else
							{fillColor = treeSettings.imageIconColor}

						let densityBasedAlpha = 1 - 1/CGFloat(closestImageIconNeighberDistance)
						let finalAlpha = max(curAlpha,densityBasedAlpha)
						if finalAlpha > 0.95 // so, nearly fully opaque
								{ nodeIsMaximallyVisible = true }
						imageIconAlpha = finalAlpha
						drawImageIcon(ofType:.filledCircle(fillColor,finalAlpha), inContext:ctx, atPointCenter:CGPoint(x:xImageCenter,y:self.coord.y),withRadius:treeSettings.imageIconRadius)
						}
					else // no image file; handle case when we are prompting for a new file
						{
						if imagePaneView != nil // I already instantiated the view, waiting for adding of image, show open circle
							{
							drawImageIcon(ofType:.openCircle(treeSettings.imageIconColor,curAlpha), inContext:ctx, atPointCenter:CGPoint(x:xImageCenter,y:self.coord.y),withRadius:treeSettings.imageIconRadius)
							}
						else // haven't even instantiated view yet, show add symbol
							{
							if showingImageAddButtons
								{ drawImageIcon(ofType:.addSymbol(appleBlue,curAlpha), inContext:ctx, atPointCenter:CGPoint(x:xImageCenter,y:self.coord.y),withRadius:treeSettings.imageIconRadius) }
							}
						}
					}
				else
					{
						if hasImageFile()  // draw tiny icons everywhere else
							{
							var fillColor:CGColor
							//if isDisplayingImage
							//	{fillColor = treeSettings.imageFontColor.cgColor}
							//else
							//	{fillColor = treeSettings.imageIconColor}


							if imageIsLoaded()
								{fillColor = treeSettings.imageFontColor.cgColor}
							else if hasLoadedImageAtLeastOnce
								{fillColor = treeSettings.imageUnloadedColor}
							else
								{fillColor = treeSettings.imageIconColor}





							let densityBasedAlpha = 1 - 1/CGFloat(closestImageIconNeighberDistance)
							if densityBasedAlpha > 0.95 // so, nearly fully opaque
								{ nodeIsMaximallyVisible = true }
							imageIconAlpha = densityBasedAlpha
							drawImageIcon(ofType:.filledCircle(fillColor,densityBasedAlpha), inContext:ctx, atPointCenter:CGPoint(x:xImageCenter,y:self.coord.y),withRadius:treeSettings.imageIconRadius)
							}

					}
				ctx.setStrokeColor(treeSettings.edgeColor) // restore stroke color
				ctx.strokePath()
				   
				} // end ifTreeCoordInRect
			} // end isLeaf

		else
			{
			for child in children
				{
				// draw the vert line of the edge in the corner tree layout
				//let ancPoint=CGPoint(x:self.coord.x, y:child.coord.y) // the point immediately left of node on	horiz line (not the parent node point)
				// Following "if" sets up stuff for rounded corners


				if (child.coord.y < self.coord.y) // child is above parent on screen
					{
					yCornerOffset=radius
					endAngle=1.5*CGFloat.pi
					direction=false
					}
				else
					{
					yCornerOffset = -radius
					endAngle=0.5*CGFloat.pi
					direction=true
					}

// !NB LITTLE BUG: I AM CURRENTLY PUTTING IN ARC IN FOR AN EDGE EVEN IN POLYTOMIES WHERE PERHAPS I WANT THE "MIDDLE" EDGE TO NOT BE ROUNDED
				//if treeCoordIsInRect(coord: child.coord.y, theRect: nakedTreeRect, withPanTranslate: panTranslate) // ...if child is visible
				//	{
					let ancPoint=CGPoint(x:self.coord.x, y:child.coord.y+yCornerOffset)
					// that's the point to left of node on horiz line, offset a little by the arc
					ctx.move(to:self.coord)
					ctx.addLine(to:ancPoint) // that's the vertical line
					let center = CGPoint(x:self.coord.x+radius,y:ancPoint.y)
					ctx.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: direction) // plus the arc
					let alpha = edgeScaleFactor*CGFloat(child.numDescLvs!)
					//ctx.setAlpha(alpha*alphaModifier) //modifier increased dimming if edge is in a named clade
					ctx.setAlpha(alpha) //modifier increased dimming if edge is in a named clade
					// Only draw the horizontal line of the edges if they are onscreen (vertical ones still drawn at moment) THIS COULD BE IMPROVED LATER IF WARRANTED
					// this is done relative to treeViewRect, which is not corrected for label heights
					if treeCoordIsInRect(coord: child.coord.y, theRect: nakedTreeRect, withPanTranslate: panTranslate)
					//if treeCoordIsInRect(coord: child.coord.y, theRect: decoratedTreeRect, withPanTranslate: panTranslate)
						{
						ctx.addLine(to:child.coord) // plus the horizontal line
						}
					ctx.setStrokeColor(treeSettings.edgeColor) // restore stroke color
					ctx.strokePath()
				//	}
				}
			for child in children
				{
				child.drawClade(inContext:ctx, withAttributes: textAttributes, showEveryNthLabel: everyNthLabel, withLabelScaler: labelScaleFactor, withEdgeScaler:edgeScaleFactor, labelMidY:yOffset, nakedTreeRect: nakedTreeRect, withPanTranslate:panTranslate,xImageCenter: xImageCenter, showingAddButtons:showingImageAddButtons,leafLabelRectangle:leafLabelsRect)
				}
			}
		}
	// **********************************************************************

		func minMaxY()->(CGFloat,CGFloat)
			{
			return ( minMaxYHelper(curMin:1e10,curMax:-1e10) )
			}


		func minMaxYHelper( curMin: CGFloat,  curMax: CGFloat)->(CGFloat,CGFloat)
			{
			var min=curMin
			var max=curMax
			if self.isLeaf()
				{
				if self.coord.y < min {min = self.coord.y}
				if self.coord.y > max {max = self.coord.y}
				}
			else
				{
				for child in children
					{
					let (childMin,childMax) = child.minMaxYHelper(curMin:min, curMax:max)
					if childMin < min {min = childMin}
					if childMax > max {max = childMax}
					}
				}
			return (min,max)
			}



	// **********************************************************************
	func scaleTreeCoords(by factor:CGFloat)
		{

		//self.coord.x *= factor
		self.coord.y *= factor
		for child in children
				{
				child.scaleTreeCoords(by:factor)
				}
		}
	// **********************************************************************
	func translateTreeCoords(by translation:CGFloat)
		{

		//self.coord.x *= factor
		self.coord.y += translation
//print ("x=\(self.coord.x) y=\(self.coord.y)")
		for child in children
				{
				child.translateTreeCoords(by:translation)
				}
		}
	// **********************************************************************
	func transformTreeCoords(by transform:CGAffineTransform)
		{

		//self.coord.x *= factor
		self.coord = self.coord.applying(transform)
		for child in children
				{
				child.transformTreeCoords(by:transform)
				}
		}

	// **********************************************************************
	// Following are several functions to set up XY coordinates for each node
	
	func setupNodeCoordinates (in rect: CGRect, forTreeType treeType: TreeType)
		{
		var N: UInt
		var yinc,yUpLeft:CGFloat;
		var maxELT:CGFloat?
			
		_ = self.maxInterveningNodesToLeaf() // sets up values at this and each desc node (discards result here, but sets them up elsewhere!
		if treeType == .phylogram
			{
			maxELT=self.maxEdgeLengthToLeaf(isRoot:true) // for phylogram find longest path to tip
			}

		self.assignX(xLeft:rect.origin.x,  xRight:rect.origin.x+rect.size.width,  xWidth:rect.size.width, withMaxToLeafLength:maxELT, forTreeType:treeType, isRoot: true)
		
		N=self.numDescendantLeaves()
		if (N==1) {yinc=0.0}
		else
			{
			yinc = (rect.size.height)/CGFloat(N-1)
			}
			
		yUpLeft=rect.origin.y
		_ = self.assignY2(currentY: &yUpLeft, withYinc: yinc)
		}

	func assignY2(currentY YcurPtr:inout CGFloat,  withYinc yinc: CGFloat)->CGFloat
	{
		var sum:CGFloat=0
		var count:Int=0
		
		if self.isLeaf()
			{
			self.coord.y = YcurPtr
			YcurPtr += yinc
			return(self.coord.y)
			}

		for child in children
			{
			sum += child.assignY2(currentY: &YcurPtr,withYinc: yinc)
			count += 1
			}
		sum/=CGFloat(count)
		self.coord.y=sum
		return(sum)
	}



	func assignX(xLeft Xleft:CGFloat,  xRight Xright:CGFloat, xWidth Xwidth:CGFloat, withMaxToLeafLength maxToLeaf:CGFloat?, forTreeType treeType: TreeType, isRoot rootFlag: Bool)
	{
		if rootFlag == true
			{
			self.coord.x = Xleft
			}
		else
			{
				switch (treeType)
				{
				case .cladogram:
					self.coord.x = Xleft + (Xright - Xleft)/CGFloat(self.order! + 1)
				case .phylogram:
					self.coord.x = Xleft + Xwidth*CGFloat(self.length!)/maxToLeaf!
				case .chronogram:
					self.coord.x = Xleft + Xwidth*CGFloat(1-self.time!)
				
				}
			}

		for child in children
			{
			switch (treeType)
				{
				case	.chronogram:
							child.assignX(xLeft:Xleft,  xRight:Xright,  xWidth:Xwidth, withMaxToLeafLength:maxToLeaf, forTreeType:treeType, isRoot: false)
				case	.cladogram,
						.phylogram:
							child.assignX(xLeft:self.coord.x,  xRight:Xright,  xWidth:Xwidth, withMaxToLeafLength:maxToLeaf, forTreeType:treeType, isRoot: false)
				}
			}
		return;
	}







	// NB. This function also sets the node property. Watch out if you don't want this.
	func numDescendantLeaves()->UInt
		{
		var sum:UInt=0;
		if self.isLeaf()
			{
			numDescLvs=1
			return (1)
			}
		else
			{
			for child in children
				{
				sum += child.numDescendantLeaves()
				}
			}
		numDescLvs=sum
		return (sum);
		}

	// What is the number of nodes in the path between this node and the leaf that has the most
	// intervening nodes, not including this node? Used in cladogram drawing. Set this up once, then call
	// values at each node.
	func maxInterveningNodesToLeaf()->Int
		{
		var max:Int = 0
		var temp:Int
		if self.isLeaf()
			{
			self.order=0
			}
		else
			{
			for child in children
				{
				temp = child.maxInterveningNodesToLeaf()
				if temp > max
					{max = temp}

				}
			self.order=max+1
			}
		return (self.order)!
		}

	// What is maximum summed edge length between this node and any leaf?
	func maxEdgeLengthToLeaf(isRoot rootFlag: Bool)->CGFloat
		{
		var max:CGFloat=0.0, temp:CGFloat, thisLength:CGFloat

		if rootFlag == true
			{
			thisLength=0.0;
			}
		else
			{
			if self.length == nil // only trap for this on nonroot nodes
				{fatalError("Apparently branch lengths are not present on tree")}
			thisLength=CGFloat(self.length!)	/* don't add length under the root */
			}
		if self.isLeaf()
				{
				return (thisLength)
				}
		else
			{
			for child in children
				{
				temp=child.maxEdgeLengthToLeaf(isRoot:false)
				if (temp > max)
					{ max = temp }
				}
			return (thisLength+max)
			}
		}
}
