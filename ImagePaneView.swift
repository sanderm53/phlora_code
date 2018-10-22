//
//  ImagePaneView.swift
//  QGTut
//
//  Created by mcmanderson on 6/27/18.
//  Copyright © 2018 mcmanderson. All rights reserved.
//

import Foundation
import UIKit


func centeredRect(center c:CGPoint, size s:CGSize)->CGRect
	{
	let origin = CGPoint(x:c.x-s.width/2, y:c.y-s.height/2)
	return CGRect(origin:origin,size:s)
	}

func rectFromTwoPoints(_ pt1:CGPoint, _ pt2:CGPoint)->CGRect
	{
	let origin = CGPoint(x: min(pt1.x,pt2.x), y:min(pt1.y,pt2.y))
	let size = CGSize(width: abs(pt1.x-pt2.x), height: abs(pt1.y-pt2.y))
//print ("**",pt1,pt2,CGRect(origin: origin, size: size))
	return CGRect(origin: origin, size: size)


	}

/*
NB. I needed to keep the frame size of the imagePane to be a superset of the imageView because the gesture recognizer
chain works by intersecting the frames of the hierarchy of views down to the imageView. If the frame of imagePane is merely intersecting
with the imageView it won't work properly, so keep the imagePane frame such that it strictly contains imageView. Thus the code in 'scale()'
*/

/*
Pane EVENTUALLY will appear initially with its center at the same Y as its node. However, this positioning
occurs during layoutSubviews of treeView. Panning the image pane changes its coordinates relative to the center of
its initial frame, which is set to (midX,y=0).
*/

enum imageResolutionType
	{
	case low,high
	}

class ImagePaneView: UIView, UIGestureRecognizerDelegate
        {
		var imageView: UIImageView!		// I will always put an imageView in place, even if its uiimage is nil
        var imageLabel=UILabel()
        var addImageLabel:UILabel?
        var associatedNode:Node?
		var imageOriginalSize:CGSize?	// size of the image as it's stored on disk, and max size to be used for 'high' res
		var imageSmallSize:CGSize?		// keep a size here that is smallish and use it to resize an image to something small when res needs to be low
		var imageLoadedAtResolution:imageResolutionType? // either low or high
		let imageResolutionBoundaryFactor:CGFloat = 3.0 // boundary between low and high resolution image to be requested is given in units of the 'scale' parameter that describes the size of the image relative to its original size. This code is sort of wasted if image is really low res

		var paneCenter : CGPoint!
		var scale:CGFloat = 1.0
		//var hasImage:Bool = false
		var imageIsLoaded = false
		var isFrozen:Bool = false 			// frozen means it stays in place as tree is panned
		var imageWindowCoord:CGFloat = 0.0 // Default position of this view is centered on the frame provided to it

		func isAttachedToNode() ->Bool
			{
			return associatedNode != nil
			}
	
	

// *********************** Initializer and window management

       init (usingFrame f:CGRect=CGRect(), atNode node:Node?, withImage image:UIImage?, imageLabel:String?, showBorder:Bool) // does it all
                {
				paneCenter = CGPoint(x:f.midX,y:f.midY)
				let initialImageSize = CGSize()
				
            	super.init(frame:f)
            	backgroundColor = nil // transparent (should be default)
				frame = centeredRect(center:paneCenter,size:initialImageSize)

				associatedNode = node // will remain nil if this is not a node-associated call

				// This will set up pane's imageView appropriately, and then constraints follow below
				if let image = image
					{
					loadImage(image)
					}
				else
					{
					loadEmptyImage()
  					}

				if let label = imageLabel
					{ addLabel(withName:label) }

				imageView.contentMode = .scaleAspectFit
				imageView.isUserInteractionEnabled=true

				self.addSubview(imageView)

				imageView.translatesAutoresizingMaskIntoConstraints = false
				imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
				imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
				imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
				imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

				self.isUserInteractionEnabled=true

				if showBorder
					{
					layer.borderColor=UIColor.white.cgColor
					layer.borderWidth=2.0
					}
				}

		func loadImage (_ image:UIImage) // add image to existing pane at small size , get rid of addAdd label. Can be used to reload image overwriting an existing one
			{
				imageOriginalSize = image.size
				var rectMult:CGFloat
				let L=treeSettings.initialImageSize
				var initialImageSize:CGSize
				let aspect = image.size.height/image.size.width
				if aspect >= 1.0
					{ rectMult=L/image.size.height }
				else
					{ rectMult=L/image.size.width }
				initialImageSize = CGSize(width:rectMult*image.size.width ,height:rectMult*image.size.height)

				if associatedNode == nil // if this is NOT a tree leaf image, let's keep it very small thumb at first
					{
					imageSmallSize = initialImageSize
					}
				else	// but if it is a tree image might make it bigger by boundary factor
					{
					imageSmallSize = CGSize(width:initialImageSize.width*imageResolutionBoundaryFactor, height:initialImageSize.height*imageResolutionBoundaryFactor)
					associatedNode!.hasLoadedImageAtLeastOnce = true
					}
				imageLoadedAtResolution = .low
				imageIsLoaded = true // well, it should anyway, after loading it below

				if imageView == nil
					{
					imageView = UIImageView(image: resizeUIImage(image:image, toSize:imageSmallSize!))
					}
				else

					{ imageView.image = resizeUIImage(image:image, toSize:imageSmallSize!) }
				imageOriginalSize = image.size

				bounds.size = initialImageSize // keep it centered on frame center by changing bounds size
				if let addImageLabel = addImageLabel // remove an existing addaddimage label if present
					{
					addImageLabel.removeFromSuperview()
					}
			}

		func loadEmptyImage() // set up the empty imageView and add the addaddlabel messag to it
			{
				let L=treeSettings.initialImageSize
				let initialImageSize = CGSize(width:L ,height:L)
				imageIsLoaded = false // default empty image
				imageView = UIImageView(image: nil) // works even if image == nil
				bounds.size = initialImageSize // keep it centered on frame center by changing bounds size
				addAddImageLabel()
			}

		func unloadImage() // delete image, add the addaddLabel, leave pane in place at default size, do not delete from disk
			{
				imageOriginalSize = nil
				self.imageIsLoaded = false
				imageView.image = nil
				let L = treeSettings.initialImageSize
				frame.size =  CGSize(width:L ,height:L) // reset to original square size OR SHOULD IT BE BOUNDS.size?
				addAddImageLabel()
			}

		func addLabel(withName name:String) // Usually the taxon label, placed at bottom of pane
			{
			imageLabel = UILabel()
			self.addSubview(imageLabel)
			imageLabel.textColor = UIColor.white
			imageLabel.font = UIFont(name:"Helvetica", size:18)
			imageLabel.text = name
			imageLabel.backgroundColor=treeSettings.viewBackgroundColor
			imageLabel.translatesAutoresizingMaskIntoConstraints=false
			imageLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
			//imageLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true
			imageLabel.topAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
			//imageLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
			}

		func addAddImageLabel() // A message that just says "Add an image" in the center of pane when no image is presently displayed
			{
			addImageLabel = UILabel()

			addImageLabel!.textColor = UIColor(cgColor: appleBlue)
			addImageLabel!.text = "Add an image"
			addImageLabel!.textAlignment = .center
			let studyPUBackgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
			addImageLabel!.backgroundColor = studyPUBackgroundColor

			addSubview(addImageLabel!)

			addImageLabel!.translatesAutoresizingMaskIntoConstraints=false
			addImageLabel!.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
			addImageLabel!.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
			addImageLabel!.topAnchor.constraint(equalTo: topAnchor).isActive = true
			addImageLabel!.bottomAnchor.constraint(equalTo:bottomAnchor).isActive = true

			}


// ********************* Geometry...


/*
Basic approach to memory management for possibly large collection of possibly large images:
	- Toggle between a low and high res version of the image, stored at sizes of imageSmallSize, and imageOriginalSize respectively
	- When first loaded, resize image to low res and display
	- If image is scaled UP past imageResolutionBoundaryFactor, then reload image at full res and display
	- If scaled back down, reverse...
Some setup has to occur in layoutImagePane and addImage functions.
*/

		func reloadImageToFitPaneSizeIfNeeded () // add a node's image to existing pane, which may have changed size during zoom; resize image to fit pane's imageView
			{
			if scale > imageResolutionBoundaryFactor &&  imageLoadedAtResolution == .low
				{
				if let url = associatedNode?.imageFileURL
					{
					if let image = UIImage(contentsOfFile:url.path)
						{
						imageView.image = image
						imageLoadedAtResolution = .high

						}
					}
				}

			if scale <= imageResolutionBoundaryFactor &&  imageLoadedAtResolution == .high
				{
		// could do this just be rescaling current large imageView.image, which sidesteps reloading...
				if let url = associatedNode?.imageFileURL
					{
					if let image = UIImage(contentsOfFile:url.path)
						{
						imageView.image = resizeUIImage(image: image, toSize: imageSmallSize!)
						imageLoadedAtResolution = .low
						}
					}
				}




			}




		func minimize(andHide flag:Bool)
			{
			if imageLoadedAtResolution == .high
				{
				if let image = imageView.image
					{imageView.image = resizeUIImage(image: image, toSize: imageSmallSize!) }
				}
			if flag == true
				{
				self.isHidden = true
				//if let node = associatedNode
				//	{ node.isDisplayingImage = false }
				}
			}




		func scale(by scale:CGFloat, around pt:CGPoint, inTreeView treeView:DrawTreeView)
				{

	//print ("Around Pt:",pt)
	
				let theTransform = CGAffineTransform.identity.translatedBy(x: pt.x, y: pt.y).scaledBy(x: scale, y: scale).translatedBy(x: -pt.x, y: -pt.y) // note that this order is reversed from how you'd apply them to current transform (I think)
				let newBounds = bounds.applying(theTransform)
				let deltaOrigin = newBounds.origin // since original bounds was just 0,0

				let newSize = newBounds.size
				let newFrameOrigin = CGPoint(x: frame.origin.x+deltaOrigin.x, y: frame.origin.y+deltaOrigin.y)
				let newFrame = CGRect(origin: newFrameOrigin, size: newSize)

				let newLabelCenter = CGPoint(x:newSize.width/2,y:imageLabel.frame.height/2 + newSize.height)

				frame = newFrame
				imageLabel.center = newLabelCenter

				self.scale *= scale
				}

		func translate(dx x:CGFloat, dy y:CGFloat, inTreeView treeView:DrawTreeView)
				{
				let testFrameInsets:CGFloat = 100
				var vertInset,horizInset:CGFloat

				// my way of keeping images within window during movement
				// careful, frame vs center are wonky in this code...rect comparisons need to be done with frames
				let newCenter = CGPoint(x: center.x+x, y: center.y+y)
				var testPaneFrame = frame.offsetBy(dx: x, dy: y)
				//...keep the panes from moving offscreen in the following way. For small images, don't let their center go off
				// screen. For larger images, make sure there is an overhang of dimension 'testFrameInsets' onto the visible window
				if testPaneFrame.height > 2.0 * testFrameInsets
					{ vertInset = testFrameInsets}
				else
					{ vertInset = testPaneFrame.height/2 }
				if testPaneFrame.width > 2.0 * testFrameInsets
					{ horizInset = testFrameInsets}
				else
					{ horizInset = testPaneFrame.width/2 }
				testPaneFrame = UIEdgeInsetsInsetRect(testPaneFrame, UIEdgeInsets(top: vertInset, left: horizInset, bottom: vertInset, right: horizInset))
				//....Following does the actual trapping
				if treeView.bounds.intersects(testPaneFrame)
												{
												center = newCenter
												}
				}
	

		func setLocationRelativeToTreeTo(_ x:CGFloat, _ y:CGFloat)
				{
				self.transform = CGAffineTransform.identity.translatedBy(x: x, y: y)
				}

		func setLocationRelativeTo(treeView t:DrawTreeView)
				{
				if let node = associatedNode
					{
					let centerY = WindowCoord(fromTreeCoord: node.coord.y, inTreeView: t)
					//let centerX = center.x
					self.transform = CGAffineTransform.identity.translatedBy(x:0,y:centerY)
					}

				}


        // Used if view is called programmatically

        override init(frame: CGRect)
                {
                super.init(frame:frame)
                }
	

        // Used with IB
        required init?(coder aDecoder: NSCoder) {
                super.init(coder:aDecoder)
        }
	
		func convert(panePt pt:CGPoint, toTreeView treeView:DrawTreeView) -> CGPoint
			{
			let nodeY = self.associatedNode!.coord.y
			let treeCoordY = nodeY + pt.y
			let Y = WindowCoord(fromTreeCoord: treeCoordY, inTreeView:treeView)
			let X = pt.x
			return CGPoint(x: X, y: Y)
			}
		func isPanePointWithinWindow(panePt pt:CGPoint, ofTreeView treeView:DrawTreeView) -> Bool
			{
			let p = convert(panePt:pt, toTreeView:treeView)
			let r = treeView.decoratedTreeRect!
			if p.x > r.minX && p.x < r.maxX && p.y > r.minY && p.y < r.maxY
				{ return true }
			else
				{ return false }
			}

		func rectInPaneCoordsDoesIntersectWithWindow(paneRect rect:CGRect, ofTreeView treeView:DrawTreeView) -> Bool
			{
			//let pt = rect.origin
			//let p = convert(panePt:pt, toTreeView:treeView)
			
	let convertedRect = self.convert(rect, to: treeView)
			
			//let convertedRect = CGRect(origin:p, size:rect.size)
			let r = treeView.decoratedTreeRect!
			if r.intersects(convertedRect)
				{ return true }
			else
				{ return false }
			}

	func freeze(inTreeView treeView:DrawTreeView)
		{
		if let node = associatedNode
			{
			isFrozen = true
			imageWindowCoord = WindowCoord(fromTreeCoord: node.coord.y, inTreeView: treeView)
			treeView.setNeedsDisplay()
			}
		}

	func unfreeze(inTreeView treeView:DrawTreeView)
		{
		if let node = associatedNode
			{
			isFrozen=false
			let targetTreeCoord = TreeCoord(fromWindowCoord: imageWindowCoord,inTreeView: treeView)
			let necessaryRectYCoordOffset = targetTreeCoord - node.coord.y
			frame = frame.offsetBy(dx: 0, dy: necessaryRectYCoordOffset)
			treeView.setNeedsDisplay()
			//self.setNeedsDisplay()
			}
		}

	}


