//
//  ImageCollection.swift
//  iTree
//
//  Created by mcmanderson on 12/29/17.
//  Copyright © 2017 mcmanderson. All rights reserved.
//

import UIKit


func getImageFromFile(withFileNamePrefix fileNamePrefix:String, atTreeDirectoryNamed treeDir:String)->UIImage?
	// treeDir is commonly just named from the treeName
	{
		let ext = ["jpg","png"]
		let imageBundlePath = Bundle.main.bundlePath + "/" + treeSettings.imageBundleLoc + "/" + treeDir
		guard let imageBundle = Bundle(path: imageBundlePath	)
		else { return nil }
		let imageFilename0 = fileNamePrefix+"."+ext[0]
		let imageFilename1 = fileNamePrefix+"."+ext[1]
		var image = UIImage(named:imageFilename0,in:imageBundle,compatibleWith:nil)
		if image == nil
			{
			image = UIImage(named:imageFilename1,in:imageBundle,compatibleWith:nil) // try the other extension
			if image == nil
				{ return nil }
			}
		return image
	}


// 'Leaf indices' are [0..N-1] labels for leaves running vertically on view from top to bottom
// They are used to index the node array. These are *elements* (not subscripts!) of the openImagesArray.

// Note. The imageCollection is ALWAYS initialized even if there are no images. This helps guard against calls
// which assume an imageCollection is present. It's possible bugs may follow this.


class ImageCollection {
	var nodeArray: [Node]=[]
	var openImagesArray: [Int]=[]
	let imageMinimumWidth=treeSettings.initialImageSize
	var imageMaximumWidth=treeSettings.initialImageSize // this can change with rotations of screen and will be reset to something else
	var imageXCenter:CGFloat? //initialized later in DrawTreeView
	//var isDisplayingImage: Bool = false
	var hasImages:Bool = false
	var hasImageFiles:Bool = false

	var imagePinchInProgress = false
	var imagePinchLocation = CGPoint(x: 0, y: 0)
	var imagePinchScale:CGFloat = 1.0
	var xTree:XTree
	//var numImages:Int = 0

	init(forTree xTree:XTree)
		{
		hasImages = false
		//numImages = 0
		self.xTree = xTree
		}

	// Either preload all available images (slow), or just check if image files exist so we can draw image
	// icons and wait to init the imageViews later when needed
	func setup()
		{
		let root = xTree.root!
		root.putNodeArray(into:&nodeArray)		// This will be used to help pick images
		if treeSettings.allowedToLoadImages == false
			{
				hasImages = false
				//numImages = 0
			}
		else
			{
			hasImageFiles = root.initImageFilesExistence(usingTreeNameAsDirName:xTree.treeInfo.treeName) // determine whether image file exists for each node
			if treeSettings.preLoadImages
				{
				root.initImages(onTree:xTree)
				for node in nodeArray
					{
						if node.hasImage!	// hasImage will be true or false if preLoading images!
						{
						hasImages = true
						//numImages += 1   // careful if preLoad is false then this has to be updated as images are loaded
						}
					}
				}
			}
		}

	func getPickedLeafNode(withLeafIndex lix:Int)->Node
		{
		return nodeArray[lix]
		}

	func imageIsBig(withLeafIndex lix:Int)->Bool? // image width is bigger than "maximize" amount (which is allowed)
		{
		if leafNodeHasImage(withLeafIndex: lix) == false
			{ return nil}
		else
			{
			if nodeArray[lix].imageView!.rect.width > imageMaximumWidth
				{ return true}
			else
				{ return false}
			}
		}
	func leafNodeHasImage(withLeafIndex lix:Int)->Bool
		{
		if nodeArray[lix].hasImage == nil
			{
			nodeArray[lix].initImage(onTree:xTree)
			hasImages = nodeArray[lix].hasImage! // Just set this to true for overall image collection if we returned one here...
			}
		return nodeArray[lix].hasImage!
		}

	func leafImageisOpen(withLeafIndex lix:Int)->Bool
		{
		return nodeArray[lix].isDisplayingImage
		}
		
	func leafImageIsFrozen(withLeafIndex lix:Int)->Bool
		{
		if nodeArray[lix].hasImage == nil
			{
			nodeArray[lix].initImage(onTree:xTree)
			hasImages = nodeArray[lix].hasImage! // Just set this to true for overall image collection if we returned one here...
			}
		if nodeArray[lix].hasImage!
			{
				return nodeArray[lix].imageView!.imageIsFrozen
			}
		else
			{ return false }
		}
	func setLeafImageIsFrozen(withLeafIndex lix:Int, inTreeView treeView:DrawTreeView)
		{
		if nodeArray[lix].hasImage == nil
			{
			nodeArray[lix].initImage(onTree:xTree)
			hasImages = nodeArray[lix].hasImage! // Just set this to true for overall image collection if we returned one here...
			}
		if nodeArray[lix].hasImage!
			{
				//print (state)
			nodeArray[lix].imageView!.imageIsFrozen=true
			let windowCoord = WindowCoord(fromTreeCoord: nodeArray[lix].coord.y, inTreeView: treeView)
			nodeArray[lix].imageView!.imageWindowCoord = windowCoord
//print ("Freezing image at window loc = ", windowCoord)
			}
		}
	func setLeafImageIsUnfrozen(withLeafIndex lix:Int, inTreeView treeView:DrawTreeView)
		{
		if nodeArray[lix].hasImage == nil
			{
			nodeArray[lix].initImage(onTree:xTree)
			hasImages = nodeArray[lix].hasImage! // Just set this to true for overall image collection if we returned one here...
			}
		if nodeArray[lix].hasImage!
			{
			let imageView = nodeArray[lix].imageView!
			imageView.imageIsFrozen=false
			let targetTreeCoord = TreeCoord(fromWindowCoord: imageView.imageWindowCoord,inTreeView: treeView)
			let necessaryRectYCoordOffset = targetTreeCoord - nodeArray[lix].coord.y
			imageView.rect = imageView.rect.offsetBy(dx: 0, dy: necessaryRectYCoordOffset)
			}
		}



	func setLeafImageIsOpen(withLeafIndex lix:Int, to state:Bool)
		{
		if nodeArray[lix].hasImage == nil
			{
			nodeArray[lix].initImage(onTree:xTree)
			hasImages = nodeArray[lix].hasImage! // Just set this to true for overall image collection if we returned one here...
			}
		if nodeArray[lix].hasImage!
			{
			if state == true
				{
				if nodeArray[lix].isDisplayingImage==false
					{
					openImagesArray.append(lix)
					nodeArray[lix].isDisplayingImage=true
					}
				}
			else // close image
				{
				if nodeArray[lix].isDisplayingImage==true
					{
					nodeArray[lix].isDisplayingImage=false
					let foundIx = openImagesArray.index(of:lix)
					if foundIx != nil
						{ openImagesArray.remove(at: foundIx!) }
					}
				}
			}
		}
	
	// returns the leaf node id for the window that is at coord
	// and re-order the display order of open windows so that this is "brought to front" (displayed last!)
	func getFrontmostImageView(atTreeCoord treeCoord:CGPoint, inTreeView thisTreeView:DrawTreeView)->Int?
		{
		if openImagesArray.count>0
			{
			for oix in (0...openImagesArray.count-1).reversed()
				{
				let leafNode = nodeArray[openImagesArray[oix]]
				let imageView = leafNode.imageView
				//let rect = imageView!.rect.offsetBy(dx: treeSettings.initialImageXPos, dy: leafNode.coord.y)
				let drawRect = imageView!.getDrawRect(atXCenter: imageXCenter!, forLeafNode: leafNode, inTreeView:thisTreeView)

//print ("**",treeCoord,rect)

				if drawRect.contains(treeCoord)
					{
	//print ("--before--",openImagesArray)
					if (oix != openImagesArray.count-1) // ignore if this window is already on top
						{
						moveToTopOfImageArray(atIndex:oix)
						}
	//print ("--after--",openImagesArray)
					//return openImagesArray[index]
					return openImagesArray.last
					}
				}
			return nil
			}
		else
			{ return nil }
		}


	func moveToTopOfImageArray(atIndex oix:Int) // so it is drawn last. index is subscript of openImagesArray, not a leaf index
		{
		let element = openImagesArray.remove(at:oix)
		openImagesArray.append(element)
		return
		}



	func drawPinchRectangle (in ctx:CGContext)
		{
		let rectMinWidth:CGFloat = 200
		let boxSize = rectMinWidth*imagePinchScale
		let rectSize = CGSize(width: boxSize, height: boxSize)
		let rectOrigin =  CGPoint(x: imagePinchLocation.x - boxSize/2, y: imagePinchLocation.y-boxSize/2)
		let rect = CGRect(origin: rectOrigin, size: rectSize)
		ctx.setStrokeColor(UIColor.red.cgColor)
		ctx.stroke(rect)
		}

	func setPinchRectangleParamsAndStart(at treeLoc:CGPoint, withScale scale:CGFloat )
		{
		imagePinchInProgress=true
		imagePinchLocation=treeLoc
		imagePinchScale=scale
		}
	func setPinchRectangleToStop()
		{
		imagePinchInProgress=false
		imagePinchScale=1.0
		}

	func display (inTreeView thisTreeView:DrawTreeView, using xTree:XTree)
		{
		let ctx = thisTreeView.ctx!
		let textAttributes = thisTreeView.taxonLabelAttributes
		let xCenterImageIcon = thisTreeView.xCenterImageIcon!
		
		var drawRect:CGRect
		if openImagesArray.count>0
			{
			//for index in (0...openImagesArray.count-1).reversed()
			for index in (0...openImagesArray.count-1)
				{
				// draw the image
				let leafNode = nodeArray[openImagesArray[index]]
				let imageView = leafNode.imageView
				if imageView == nil
					{
					print ("Imageview at node is nil",leafNode.label!)
					}

// Snippet prevents images at top and bottom of tree from going offscreen. However, only enforce this behavior initially when image is minimized (or later when re-minimized
				drawRect = imageView!.getDrawRect(atXCenter:imageXCenter!, forLeafNode:leafNode, inTreeView:thisTreeView)

				if imageView!.isMinimized
					{
					if drawRect.minY < xTree.minY
						{
						imageView?.translateImageRect(by: CGPoint(x: 0, y: xTree.minY - drawRect.minY))
						drawRect = drawRect.offsetBy(dx: 0.0, dy: xTree.minY - drawRect.minY)
						}
					else if drawRect.maxY > xTree.maxY
						{
						imageView?.translateImageRect(by: CGPoint(x: 0, y: xTree.maxY - drawRect.maxY))
						drawRect = drawRect.offsetBy(dx: 0.0, dy: xTree.maxY - drawRect.maxY)
						}
					}

				imageView!.leafImage?.draw(in: drawRect)

//print (imageView!.leafImage?.scale, imageView!.leafImage?.size)

				if imagePinchInProgress
					{
					drawPinchRectangle (in:ctx)
					}

				ctx.setStrokeColor(treeSettings.imageMarginColor)
				ctx.stroke(drawRect)
				
				// Draw the label
				let text=NSString(string:leafNode.label!)
				let textHeight = text.size(attributes: textAttributes).height
				let textWidth = text.size(attributes: textAttributes).width
				
				let rectOrigin = CGPoint(x:drawRect.midX-textWidth/2.0,y:drawRect.maxY) // center justify relative to image X
				let textRect = CGRect(origin:rectOrigin, size:CGSize(width: textWidth, height: textHeight))
				// that's the point to left of node on horiz line, offset a little by the arc
				ctx.setAlpha(1.0)
				ctx.move(to:rectOrigin)
				ctx.setFillColor(treeSettings.viewBackgroundColor.cgColor)
				ctx.fill(textRect)
				//ctx.stroke(textRect)
				//ctx.setStrokeColor(treeSettings.imageIconColor) // restore stroke color
				//ctx.strokePath()
				text.draw(at:rectOrigin, withAttributes: textAttributes)

				// draw the dotted line between image and image icon
				let imageAnchorPt = CGPoint(x:drawRect.origin.x+drawRect.width,y:drawRect.minY) // upper right of image rect
				let imageIconPt = CGPoint(x: xCenterImageIcon, y: leafNode.coord.y)
				ctx.move(to:imageAnchorPt)
				ctx.addLine(to:imageIconPt)
				ctx.setStrokeColor(treeSettings.imageToIconLineColor) // restore stroke color
				ctx.setLineDash(phase: 0, lengths: [1,3])
				ctx.strokePath()
				ctx.setLineDash(phase: 0, lengths: [])
				}
			}
		}
	
	func scaleImage(withLeafIndex leafIndex:Int, by scale:CGFloat, around pt:CGPoint, inTreeView thisTreeView:DrawTreeView) // don't like how I am tunneling down here...
		{
			nodeArray[leafIndex].imageView?.scaleImageRect(by: scale, around:pt, withXOffset:imageXCenter!, inTreeView:thisTreeView)
		}

	func translateImage(withLeafIndex leafIndex:Int, by translation:CGPoint)
		{
		nodeArray[leafIndex].imageView?.translateImageRect(by: translation)
		}
	func  imageRectReInit(withLeafIndex leafIndex:Int)
		{
		nodeArray[leafIndex].imageView?.rectReInit()
		}
	func  imageRectMinimize(withLeafIndex leafIndex:Int)
		{
		nodeArray[leafIndex].imageView?.rectMinimize(toWidth:imageMinimumWidth)
		}
	func  imageRectMaximize(withLeafIndex leafIndex:Int)
		{
		nodeArray[leafIndex].imageView?.rectMaximize(toWidth:imageMaximumWidth)
		}
	func  setImageNotMaxOrMin(withLeafIndex leafIndex:Int)
		{
		nodeArray[leafIndex].imageView?.isMaximized=false
		nodeArray[leafIndex].imageView?.isMinimized=false
		}
	func leafImageIsMaximized(withLeafIndex leafIndex:Int)->Bool
		{ return nodeArray[leafIndex].imageView!.isMaximized }
	func leafImageIsMinimized(withLeafIndex leafIndex:Int)->Bool
		{ return nodeArray[leafIndex].imageView!.isMinimized }

}
// ...................................................................................

/*
Expected dir structure in folder Images.bundle is to have a subdir with the treeName for each nexus tree file. Within this subdir are the images
*/

class MyImageView
	{
	var isDisplaying: Bool = false  // deprecated? Not used?
	var isMinimized: Bool = true
	var isMaximized: Bool = false
	var rect:CGRect					// This is relative to an "image coord system" where 0,0 is the initial location of the image next to leaf
									// Then this is allowed to move in that coord system in response to user dragging image.
									// So to display properly we obviously have to offset by current leaf position and xCenter amount
	var originalLeafImage:UIImage?
	var originalImageSize:CGSize?
	var imageWindowCoord:CGFloat=0.0
	var leafImage:UIImage?
	var aspect:CGFloat?
	var initialRect:CGRect?
	var leafNode:Node?
	var imageIsFrozen:Bool=false
	

	init? (leafNode leaf:Node,onTree xTree:XTree)
		{
//		let ext = ["jpg","png"]
		var rectMult:CGFloat
/*
		let imageBundlePath = Bundle.main.bundlePath + "/" + treeSettings.imageBundleLoc + "/" + xTree.treeInfo.treeName
//print (imageBundlePath)
		let imageBundle = Bundle(path: imageBundlePath	)!
		let imageFilename0 = leaf.originalLabel!+"."+ext[0]
		let imageFilename1 = leaf.originalLabel!+"."+ext[1]
		originalLeafImage = UIImage(named:imageFilename0,in:imageBundle,compatibleWith:nil) // Note use of original label name to match file
		if originalLeafImage == nil
			{
			originalLeafImage = UIImage(named:imageFilename1,in:imageBundle,compatibleWith:nil)
			if originalLeafImage == nil
				{ return nil }
			}
*/
		originalLeafImage = getImageFromFile(withFileNamePrefix:leaf.originalLabel!, atTreeDirectoryNamed:xTree.treeInfo.treeName)
		if originalLeafImage == nil
			{return nil}

		leafImage = originalLeafImage
		originalImageSize = originalLeafImage!.size
		//self.leafVertIndex=leafVertIndex
		leafNode = leaf
		let L=treeSettings.initialImageSize
		let aspect = leafImage!.size.height/leafImage!.size.width
		if aspect >= 1.0
			{ rectMult=L/leafImage!.size.height }
		else
			{ rectMult=L/leafImage!.size.width }
		rect = CGRect(x: 0, y: 0, width: leafImage!.size.width, height: leafImage!.size.height)

// center it in tree coord system around 0,0, with an adjusted size to fit the 'initialImageSize' box without changing aspect ratio

		var transform = CGAffineTransform(translationX:-leafImage!.size.width/2,y:-leafImage!.size.height/2) // center it in tree coord system around 0,0
		rect = rect.applying(transform)
		transform=CGAffineTransform(scaleX: rectMult, y: rectMult)
		rect = rect.applying(transform)
		leafImage = self.resizeUI(size:self.rect.size)
		initialRect=rect
		}

	func resizeUI(size:CGSize) -> UIImage?
			{
			UIGraphicsBeginImageContextWithOptions(size, true, leafImage!.scale)
			//UIGraphicsBeginImageContextWithOptions(size, true, 0.0) choice of screen scale doesn't seem to matter here

//let clipRect = CGRect(x: size.width/2 - 350, y: size.height/2 - 500, width: 700, height: 1000)
//UIRectClip(clipRect)

			originalLeafImage!.draw(in:CGRect(origin: CGPoint(x:0,y:0), size: size))
//print("Resizing to...",size)
			let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			return resizedImage
			}

	func getDrawRect(atXCenter xCenter:CGFloat, forLeafNode leafNode:Node, inTreeView thisTreeView:DrawTreeView )->CGRect // puts the image's rect in tree coordinates
		{
		if imageIsFrozen
			{
			let treeCoord = TreeCoord(fromWindowCoord: imageWindowCoord, inTreeView: thisTreeView)
//CONVERT THE SAVED WINDOW LOCATION TO A SCREEN COORD AND PASS THAT TO RECT.OFFSETBY!

			let offsetToCorrectForFrozen = treeCoord

//print (imageIsFrozen, offsetToCorrectForFrozen, originalImagePanLocation, curPanLoc)
			return rect.offsetBy(dx: xCenter, dy: offsetToCorrectForFrozen)
			}
		else
			{
			return rect.offsetBy(dx: xCenter, dy: leafNode.coord.y)
			}
		}

	func rectReInit()
		{
		rect=initialRect!
		leafImage = self.resizeUI(size:self.rect.size)
		}
	func rectMaximize(toWidth width:CGFloat)
		{
		let s = width/rect.width
		scaleImageRect(by:s)
		isMaximized = true
		isMinimized = false
		}
	func rectMinimize(toWidth width:CGFloat) // this now means to return it to initial conditions!
		{
		isMaximized = false
		isMinimized = true
		self.rectReInit()
		}

	func scaleImageRect(by s:CGFloat) // Zoom image in simple terms; see next for more complex
		{
		let scaleBy = boundScalingFactorToMaxOrMin(forScale:s)
		let dX = rect.width * (1-scaleBy) / 2
		let dY = rect.height * (1-scaleBy) / 2
		rect = rect.insetBy(dx: dX, dy: dY)
		leafImage = self.resizeUI(size:self.rect.size)
		}

	func scaleImageRect(by s:CGFloat, around pt:CGPoint, withXOffset imageXCenter:CGFloat,inTreeView thisTreeView:DrawTreeView) // Zoom image but such that the touched coord pt doesn't move; pt is in tree coords
		{
		let scaleBy = boundScalingFactorToMaxOrMin(forScale:s)
		let drawRect = self.getDrawRect(atXCenter: imageXCenter, forLeafNode: leafNode!,inTreeView: thisTreeView)
		let Xoffset = ( drawRect.midX - pt.x )*(scaleBy-1) // Again, as with zooming the tree around a fixed y point, we end up with a (s-1) term that has to be drawn to be believed...
		let Yoffset = ( drawRect.midY - pt.y )*(scaleBy-1)


		let dX = rect.width * (1-scaleBy) / 2
		let dY = rect.height * (1-scaleBy) / 2
		rect = rect.insetBy(dx: dX, dy: dY)
		rect = rect.offsetBy(dx:Xoffset,dy:Yoffset )

		leafImage = self.resizeUI(size:self.rect.size)

		}

	func boundScalingFactorToMaxOrMin(forScale scale:CGFloat)->CGFloat
		// image not allowed to scale above k times the size of original image, or less than initalImageSize parameter
		{
		let k:CGFloat = 2.0
		if rect.size.width * scale > k*originalImageSize!.width
			{
			return k*originalImageSize!.width/rect.size.width
			}
		if rect.size.width * scale < treeSettings.initialImageSize
			{
			return treeSettings.initialImageSize/rect.size.width
			}
		return scale // default pass through
		}

	func translateImageRect(by translation:CGPoint)
		{
		self.rect = self.rect.offsetBy(dx: translation.x, dy: translation.y)
		}
	}
