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

class fetchImageController : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate
	{
	weak var viewController: TreeViewController?
	lazy var pickerController = UIImagePickerController()
	var imagePane: ImagePaneView
	
	init(viewControllerToPresent viewController:TreeViewController, forImagePane imagePane:ImagePaneView)
		{
		self.imagePane = imagePane
		super.init()
		self.viewController = viewController
		}
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
		{
		picker.dismiss(animated: true)
		}
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
		{
	print ("Got to here")
		print (info["UIImagePickerControllerImageURL"])
		// other keys : UIImagePickerControllerReferenceURL , UIImagePickerControllerOriginalImage
		picker.dismiss(animated: true)
		}


	func showChoosePhotoSourceAlert(forImagePane imagePane:ImagePaneView)
		{
		let alert = UIAlertController(title:"Choose source of image",message:"", preferredStyle: .alert)

		let action1 = UIAlertAction(title: "Cancel", style: .cancel)
			{ (action:UIAlertAction) in print("You've pressed cancel") }
		let action2 = UIAlertAction(title: "Photo library", style: .default)
			{ (action:UIAlertAction) in
			print("You've pressed pl")
			self.choosePhotoFromLibrary(forImagePane:imagePane)
			}
		let action3 = UIAlertAction(title: "Files", style: .default)
			{ (action:UIAlertAction) in print("You've pressed files") }
		alert.addAction(action1)
		alert.addAction(action2)
		alert.addAction(action3)
		viewController!.present(alert,animated:true,completion:nil)
		}
	
	
	func choosePhotoFromLibrary(forImagePane imagePane:ImagePaneView)
		{
checkPermission()
		//pickerController = UIImagePickerController()
		pickerController.delegate = self
		pickerController.sourceType = .photoLibrary

if UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
	{ print ("Photolibrary available")}

		pickerController.allowsEditing = false
		if UIDevice.current.userInterfaceIdiom == .pad
			{
			pickerController.modalPresentationStyle = .popover
			let imagePickerPopoverPresentationController = pickerController.popoverPresentationController
			imagePickerPopoverPresentationController?.permittedArrowDirections = .right
			imagePickerPopoverPresentationController?.sourceView = viewController!.treeView
			if let coord = imagePane.associatedNode?.coord
				{
				let origin = CGPoint(x:coord.x, y:WindowCoord(fromTreeCoord:coord.y, inTreeView: viewController!.treeView)  )

				print ("origin=",origin)
				imagePickerPopoverPresentationController?.sourceRect = CGRect(origin:origin, size:CGSize(width:0, height:0))
				viewController!.present(pickerController, animated: true, completion: nil)
				}
			}
		
		}


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

	}







