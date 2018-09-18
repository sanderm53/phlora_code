//
//  fetchImageController.swift
//  QGTut
//
//  Created by mcmanderson on 8/20/18.
//  Copyright © 2018 mcmanderson. All rights reserved.
//

import Foundation
import UIKit
import Photos

class FetchImageController : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate
	{
	weak var viewController: TreeViewController?
	//weak var viewController: UIViewController?
	lazy var pickerController = UIImagePickerController()
	var imagePane: ImagePaneView
	var alert: UIAlertController


	init(viewControllerToPresent viewController:TreeViewController, forImagePane imagePane:ImagePaneView)
		{
		self.imagePane = imagePane
		self.viewController = viewController
		self.alert = UIAlertController(title:"Choose source of image",message:"", preferredStyle: .alert)
		super.init()
		let action1 = UIAlertAction(title: "Cancel", style: .cancel)
			{ (action:UIAlertAction) in print("You've pressed cancel") }
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

		if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
			{
				processImage(usingImage:image)
			}

		picker.dismiss(animated: true)
		}

//***

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
		print (urls.first)
		if let url = urls.first
			{
			if let image = UIImage(contentsOfFile:url.path)
				{
				processImage(usingImage:image)
				}
			}
		}


//***

/*
Will check to see what kind of imagePane this is. If it's associated with node, write to a jpeg for that node name.
If not, assume it is the study image (only alternative now), and write to a jpeg with studyname.jpg.
*/
	func processImage(usingImage image:UIImage)
		{

		do
			{
			let treeInfo = viewController!.treeView.treeInfo
			if imagePane.associatedNode != nil
				{
				let destURL = try copyImageToDocs(srcImage:image, srcFileType: .imageFile, forStudy: treeInfo!.treeName, atNode:imagePane.associatedNode!)


				imagePane.associatedNode!.imageFileURL = destURL
				imagePane.associatedNode!.hasImageFile = true
				}
			imagePane.addImage(image)
			viewController!.treeView.setNeedsDisplay()
			}
		catch
			{
// Need to dismiss alert before presentig this one??
	print ("Catch an image import error here")
			let alert = UIAlertController(title:"Error importing image file",message:nil, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in  NSLog("The alert occurred")}))
			viewController!.present(alert,animated:true,completion:nil)
			}
		}






//***

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
				imagePickerPopoverPresentationController?.permittedArrowDirections = .right
				imagePickerPopoverPresentationController?.sourceView = viewController!.treeView
				if let coord = imagePane.associatedNode?.coord // make the popover point at the node
					{
					let origin = CGPoint(x:coord.x, y:WindowCoord(fromTreeCoord:coord.y, inTreeView: viewController!.treeView)  )
					imagePickerPopoverPresentationController?.sourceRect = CGRect(origin:origin, size:CGSize(width:0, height:0))
					viewController!.present(pickerController, animated: true, completion: nil)
					}
				}
			else
				{ 
					viewController!.present(pickerController, animated: true, completion: nil)
				}
			}
		
		}



	}


/*
			func checkPermission() {
					let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
					switch photoAuthorizationStatus {
					case .authorized:
						print("Access is granted by user")
					case .notDetermined:
						PHPhotoLibrary.requestAuthorization({
							(newStatus) in
							print("status is \(newStatus)")
							if newStatus ==  PHAuthorizationStatus.authorized {
								/* do stuff here */
								print("success")
							}
						})
						print("It is not determined until now")
					case .restricted:
						// same same
						print("User do not have access to photo album.")
					case .denied:
						// same same
						print("User has denied the permission.")
					}
				}

*/

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
			{ (action:UIAlertAction) in print("You've pressed cancel") }
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

		if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
			{
				addAndSaveImage(image)
			}

		picker.dismiss(animated: true)
		}

//***

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
		print (urls.first)
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
						associatedNode.hasImageFile = true
						}
					}
			imagePane.addImage(image)
			viewController!.view.setNeedsDisplay()
// Pass auf! Need this to trickle down to treeview when it is treeviewcontroller...
			}
		catch
			{
	print ("Catch an image import error here")
			let alert = UIAlertController(title:"Error importing image file",message:nil, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in  NSLog("The alert occurred")}))
			viewController!.present(alert,animated:true,completion:nil)
			}
		}






//***

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




