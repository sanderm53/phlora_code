//
//  fetchImageController.swift
//  QGTut
//
//  Created by mcmanderson on 8/20/18.
//  Copyright © 2018 mcmanderson. All rights reserved.
//

/*DEPRECATED ... see ImageSelector()

import Foundation
import UIKit
import Photos


class ImageChooserController : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate
	{
	weak var viewController: UIViewController?
	lazy var pickerController = UIImagePickerController()
	var imagePane: ImagePaneView
	var alert: UIAlertController
	var targetDir:URL
	var fnbase:String
	var sourceView:UIView
	var sourceRect:CGRect


	init(receivingImagePane imagePane:ImagePaneView, calledFromViewController viewController:UIViewController,copyToDir dir:URL, usingFileNameBase fnbase:String, callingView sourceView:UIView, atRect sourceRect:CGRect)
		{
		self.imagePane = imagePane
		self.viewController = viewController
		self.targetDir = dir
		self.fnbase = fnbase
		self.sourceView = sourceView
		self.sourceRect = sourceRect

		self.alert = UIAlertController(title:"Choose source of image",message:"", preferredStyle: .alert)
		super.init()
		let action1 = UIAlertAction(title: "Cancel", style: .cancel)
			{ (action:UIAlertAction) in  }
		let action2 = UIAlertAction(title: "Photo library", style: .default)
			{ (action:UIAlertAction) in
			//print("You've pressed pl")
			//self.choosePhotoFromLibrary(forImagePane:imagePane)
			self.choosePhotoFromLibrary()
			}
		let action3 = UIAlertAction(title: "Files", style: .default)
			{ (action:UIAlertAction) in
			//print("You've pressed files")
			self.choosePhotoFromFiles()
			}
		alert.addAction(action1)
		alert.addAction(action2)
		alert.addAction(action3)

		}

	func launch()
		{
		viewController!.present(alert, animated: true, completion: nil)
		}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
		{
		picker.dismiss(animated: true) // dismisses via ancestral view controller that presented it
		}

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
		{
//print (info)
		if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
			{
				addAndSaveImage(image)
			}

		picker.dismiss(animated: true)
		}


	func choosePhotoFromFiles()
		{
		let vc = UIDocumentPickerViewController(documentTypes: ["public.jpeg"],in: .import)
		vc.delegate = self
		viewController!.present(vc, animated: true)
		}
	
	func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController)
		{
		controller.dismiss(animated: true)
		}

	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL])
		{
		//print (urls.first)
		if let url = urls.first
			{
			if let image = UIImage(contentsOfFile:url.path)
				{
				addAndSaveImage(image)
				}
			}
		}


/*
Will check to see what kind of imagePane this is. If it's associated with node, write to a jpeg for that node name.
If not, assume it is the study image (only alternative now), and write to a jpeg with studyname.jpg.
*/
	func addAndSaveImage(_ image:UIImage)
		{

		do
			{
			if let destURL = try copyImageToDocs(srcImage:image, copyToDir: targetDir, usingFileNameBase: fnbase)
					{
					if let associatedNode = imagePane.associatedNode
						{
						associatedNode.imageFileURL = destURL
						//associatedNode.hasImageFile() = true
						//associatedNode.isDisplayingImage = true
						associatedNode.imageFileDataLocation = .inDocuments

						}
					}
print ("1..",imagePane.frame)

			imagePane.loadImage(image)
print ("2..",imagePane.frame,imagePane.imageView.frame)
			// iff this is being called from a treeview, then I want to make sure there is a longpress delete tapgesture added to imagePane once image is added
			// Otherwise, the longpress gesture is only added when images are loaded from disk...
			if let vc = viewController as? TreeViewController
				{ vc.addLongTapGestureToDeleteImageFrom(imagePane) }
			// The following is really useful when this is called by treeView, as it updates the diagonal lines; also seems OK
			// on study view, but I suppose there might be a context in which I don't want to update...

//if let cell = sourceView as? StudyTableViewCell
//	{
//	let ti = cell.treeInfo
//	cell.treeInfo = ti
//	}
sourceView.setNeedsDisplay()
//imagePane.setNeedsLayout()
//imagePane.layoutIfNeeded()
//sourceView.setNeedsLayout()
//sourceView.layoutIfNeeded()
			}
		catch
			{
			let alert = UIAlertController(title:"Error importing image file",message:nil, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in  NSLog("The alert occurred")}))
			viewController!.present(alert,animated:true,completion:nil)
			}
		}


	func choosePhotoFromLibrary()
		{
		//checkPermission()
		pickerController.delegate = self
		pickerController.sourceType = .photoLibrary

		if UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
			{

			pickerController.allowsEditing = false
			if UIDevice.current.userInterfaceIdiom == .pad
				{
				pickerController.modalPresentationStyle = .popover
				let imagePickerPopoverPresentationController = pickerController.popoverPresentationController
				imagePickerPopoverPresentationController?.permittedArrowDirections = .any
				imagePickerPopoverPresentationController?.sourceView = sourceView
				imagePickerPopoverPresentationController?.sourceRect = sourceRect
				viewController!.present(pickerController, animated: true, completion: nil)
				}
			else
				{
					viewController!.present(pickerController, animated: true, completion: nil)
				}
			}
		
		}



	}


*/

