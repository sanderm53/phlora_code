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

// NB! When embedding a pane in a table view, have to use reloadRows to get constraints to work right. The usual ..Needs..() flags won't hack it.

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
		var imageSmall: UIImage?
        var imageLabel=UILabel()
        var addImageLabel:UILabel?
        var associatedNode:Node?
		var imageOriginalSize:CGSize?	// size of the image as it's stored on disk, and max size to be used for 'high' res
		var imageSmallSize:CGSize?		// keep a size here that is smallish and use it to resize an image to something small when res needs to be low
		var imageOriginalResolution:imageResolutionType? // i.e., in the file
		var imageLoadedAtResolution:imageResolutionType? // either low or high
		//let imageResolutionBoundaryFactor:CGFloat = 3.0 // boundary between low and high resolution image to be requested is given in units of the 'scale' parameter that describes the size of the image relative to its original size. This code is sort of wasted if image is really low res

		var imageSizeWidthBoundary:CGFloat? // If size of pane grows above this we will resize image to high resolution and vice versa

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
				let initialImagePaneSize = CGSize()
				
            	super.init(frame:f)
            	backgroundColor = nil // transparent (should be default)
				frame = centeredRect(center:paneCenter,size:initialImagePaneSize)

				associatedNode = node // will remain nil if this is not a node-associated call

				// This will set up pane's imageView either with or without an image, and then constraints follow below
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

		func delete() // delete pane but leave image file on disk
			{
				if let node = associatedNode
					{
					node.imagePaneView = nil
					}
				imageView = nil
				removeFromSuperview()
			}



		func loadImage (_ image:UIImage)
			// Load image to an existing pane , get rid of addAdd label.
			// Regardless of size, an image is loaded at "low" resolution (size = imageSmallSize), and a UIImage at this size is kept in 'smallImage' property.
			// If the image is originally low resolution, this is the only version that is ever displayed. However,
			// if the image is high resolution, then we do some switching back and forth:
			// 		If the imagePane and thus imageView grows larger than imageSizeWidthBoundary.width, then load the original image and use it.
			//		Use the saved smallImage if the pane is zoomed out, and let the hi-res copy be deallocated by ARC
			//		When a hi-res image scrolls off screen, the treeView.layoutSubviews function will call switchToLowResImage() on it to use the smallImage again.
			//		When that image returns to view, it will be fuzzy. A touch down on it will call touchesBegan() function below to reload from disk the hi res version.
			
			
			{
				var initialImagePaneSize:CGSize
				var targetResolutionSize:CGSize // The file will be loaded and sized to this

				imageOriginalSize = image.size

				if (image.size.height*image.size.width < treeSettings.imageResolutionSmallSize) // a cutoff value to define low and high resolution images
					{ imageOriginalResolution = .low}
				else
					{ imageOriginalResolution = .high}
				var rectMult:CGFloat
				let L=treeSettings.initialImagePaneSize
				let aspect = image.size.height/image.size.width
				if aspect >= 1.0
					{ rectMult=L/image.size.height }
				else
					{ rectMult=L/image.size.width }
				initialImagePaneSize = CGSize(width:rectMult*image.size.width ,height:rectMult*image.size.height)

				if imageOriginalResolution == .low // if its a small image to begin with we will keep it that way
					{
					targetResolutionSize = image.size
					}
				else	// but if high res, we will initially load it at a low resolution
					{
					let ratio = treeSettings.imageSizeAtLowRes/treeSettings.initialImagePaneSize // required resolution will be this much bigger/smaller than imagePane size
					targetResolutionSize = CGSize(width:ratio*initialImagePaneSize.width ,height:ratio*initialImagePaneSize.height)
					}
				
				imageSizeWidthBoundary = targetResolutionSize.width // stored and used to trigger resizing to higher or lower resolution
				imageSmallSize = targetResolutionSize
				imageOriginalSize = image.size
				imageLoadedAtResolution = .low
				imageIsLoaded = true // well, it should anyway, after loading it below

				if imageView == nil
					{ imageView = UIImageView(image: resizeUIImage(image:image, toSize:targetResolutionSize)) }
				else
					{
					imageView.image = resizeUIImage(image:image, toSize:targetResolutionSize)
					}
				imageSmall = imageView.image

				bounds.size = initialImagePaneSize // keep it centered on frame center by changing bounds size
				//if associatedNode != nil
				//	{
				//	associatedNode!.hasLoadedImageAtLeastOnce = true
				//	}
				if let addImageLabel = addImageLabel // remove an existing addaddimage label if present
					{
					addImageLabel.removeFromSuperview()
					}
			}

		func loadEmptyImage() // set up the empty imageView and add the addaddlabel messag to it
			{
				let L=treeSettings.initialImagePaneSize
				let initialImagePaneSize = CGSize(width:L ,height:L)
				imageIsLoaded = false // default empty image
				imageView = UIImageView(image: nil) // works even if image == nil
				bounds.size = initialImagePaneSize // keep it centered on frame center by changing bounds size
				addAddImageLabel()
			}

		func unloadImage() // delete image, add the addaddLabel, leave pane in place at default size, do not delete from disk
			{
				imageOriginalSize = nil
				self.imageIsLoaded = false
				imageView.image = nil
				let L = treeSettings.initialImagePaneSize
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
	
		func deleteImageFromDiskButKeepPane(updateView viewToUpdate:UIView?) // This leaves the pane but resets to no image; deletes from disk, updates a view if asked
			{
			if let node = associatedNode
				{
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
				node.imageFileDataLocation = nil
				}
			unloadImage()
			if let view = viewToUpdate
				{ view.setNeedsDisplay()} // to update the image icons in tree view, for example
			}


// ********************* Geometry...


	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) // the VC is a responder so implements this method, usually attached to views
		{
		super.touchesBegan(touches, with: event) // vital to do this
//print ("Touch in pane")
		if associatedNode != nil
			{ reloadImageToFitPaneSizeIfNeeded () }// check this only on treeview
		}


		func reloadImageToFitPaneSizeIfNeeded () // add a node's image to existing pane, which may have changed size during zoom; resize image to fit pane's imageView
			{

			guard imageOriginalResolution == .high else { return } // we never resize images that are low res to begin with

			if imageView.frame.width > imageSizeWidthBoundary! &&  imageLoadedAtResolution == .low
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
			// Following assumes that to
			if imageView.frame.width <= imageSizeWidthBoundary! &&  imageLoadedAtResolution == .high
				{
				if imageSmall != nil // the save low res version
					{
					imageView.image = imageSmall
					imageLoadedAtResolution = .low
					}
				}
			}




		func switchToLowResImage()
			{
			guard imageOriginalResolution == .high else { return } // we never minimize images that are low res to begin with
			if imageLoadedAtResolution == .high
				{
				if imageSmall != nil // just load the save low res image
					{
					imageView.image = imageSmall
					imageLoadedAtResolution = .low
					}
				}
			}




		func scale(by scale:CGFloat, around pt:CGPoint, inTreeView treeView:DrawTreeView)
				{
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
					self.transform = CGAffineTransform.identity.translatedBy(x:0,y:centerY)
					}
				}

		func convert(panePt pt:CGPoint, toTreeView treeView:DrawTreeView) -> CGPoint
			{
			let nodeY = self.associatedNode!.coord.y
			let treeCoordY = nodeY + pt.y
			let Y = WindowCoord(fromTreeCoord: treeCoordY, inTreeView:treeView)
			let X = pt.x
			return CGPoint(x: X, y: Y)
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
	
        override init(frame: CGRect)
                {
                super.init(frame:frame)
                }
        required init?(coder aDecoder: NSCoder) {
                super.init(coder:aDecoder)
        }

	}


