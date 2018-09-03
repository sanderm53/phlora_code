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
		//viewController!.dismiss(animated: true)
		picker.dismiss(animated: true) // dismisses via ancestral view controller that presented it
		}

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
		{
		//var originalImage:UIImage?
		//print (info["UIImagePickerControllerImageURL"])
		// other keys : UIImagePickerControllerReferenceURL , UIImagePickerControllerOriginalImage
		//viewController!.dismiss(animated: true)

		//originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage
		if let url = info["UIImagePickerControllerImageURL"] as? URL
			{ processImage(using: url)}
		


		picker.dismiss(animated: true)
		}

//***

	func choosePhotoFromFiles() {

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
		processImage(using:url)
		}
	}

//***
	func processImage(using url:URL)
		{

		do
			{
			let treeInfo = viewController!.treeView.treeInfo
			
			let destURL = try copyURLToDocs(src:url, srcFileType: .imageFile, forStudy: treeInfo!.treeName, atNode:imagePane.associatedNode!)


			imagePane.associatedNode!.imageFileURL = destURL
			imagePane.associatedNode!.hasImageFile = true

			viewController!.addImagePane(atNode:imagePane.associatedNode!)
			viewController!.treeView.xTree.setupNearestImageIconPositions(for: viewController!.treeView.xTree.nodeArray)
			// ugh that seems like a overly special place to insert that code
			imagePane.removeFromSuperview()
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

	
	//func choosePhotoFromLibrary(forImagePane imagePane:ImagePaneView)
	func choosePhotoFromLibrary()
		{
		//checkPermission()
		pickerController.delegate = self
		pickerController.sourceType = .photoLibrary

		if UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
			{
			pickerController.allowsEditing = true
			if UIDevice.current.userInterfaceIdiom == .pad
				{
				pickerController.modalPresentationStyle = .popover
				let imagePickerPopoverPresentationController = pickerController.popoverPresentationController
				imagePickerPopoverPresentationController?.permittedArrowDirections = .right
				imagePickerPopoverPresentationController?.sourceView = viewController!.treeView
				if let coord = imagePane.associatedNode?.coord
					{
					let origin = CGPoint(x:coord.x, y:WindowCoord(fromTreeCoord:coord.y, inTreeView: viewController!.treeView)  )
					imagePickerPopoverPresentationController?.sourceRect = CGRect(origin:origin, size:CGSize(width:0, height:0))
					viewController!.present(pickerController, animated: true, completion: nil)
					}
				}
			else
				{ // haven't tested this on iPhone yet
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




