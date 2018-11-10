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

protocol ImageSelectorDelegate: class
	{
	func imageSelector(_ imageSelector: ImageSelector, didSelectImage image: UIImage)
	func imageSelector(_ imageSelector: ImageSelector, didSelectDirectory url: URL)
	}

class ImageSelector : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate
	{
	weak var viewController: UIViewController?
	lazy var pickerController = UIImagePickerController()
	var alert: UIAlertController
	var sourceView:UIView
	var sourceRect:CGRect
	var delegate:ImageSelectorDelegate
	var imagePane:ImagePaneView


	init(receivingImagePane imagePane:ImagePaneView, calledFromViewController viewController:UIViewController, delegate:ImageSelectorDelegate, callingView sourceView:UIView, atRect sourceRect:CGRect)
		{
		self.viewController = viewController
		self.sourceView = sourceView
		self.sourceRect = sourceRect
		self.delegate = delegate
		self.imagePane = imagePane

		self.alert = UIAlertController(title:"Choose source of image",message:"", preferredStyle: .alert)
		super.init()
		let action1 = UIAlertAction(title: "Cancel", style: .cancel)
			{ (action:UIAlertAction) in  }
		let action2 = UIAlertAction(title: "Photo library", style: .default)
			{ (action:UIAlertAction) in
			self.choosePhotoFromLibrary()
			}
		let action3 = UIAlertAction(title: "Files", style: .default)
			{ (action:UIAlertAction) in
			self.choosePhotoFromFiles()
			}
		alert.addAction(action1)
		alert.addAction(action2)
		alert.addAction(action3)

		}

	func selectImage()
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
				delegate.imageSelector(self, didSelectImage:image)
			}

		picker.dismiss(animated: true)
		}


	func choosePhotoFromFiles() // reads any image file recognized by public.image UTI
		{
		let vc = UIDocumentPickerViewController(documentTypes: ["public.image","public.directory"],in: .import)
		vc.delegate = self
		
		viewController!.present(vc, animated: false) {if #available(iOS 11.0, *) {
				vc.allowsMultipleSelection = true
				}
			}
		}
	
	func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController)
		{
		controller.dismiss(animated: true)
		}

	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL])
		{
		//print (urls.first)

		if let url = urls.first // just picking FIRST at the moment if multiple selected
			{
			if url.hasDirectoryPath
				{
				print ("This is a directory")
						delegate.imageSelector(self, didSelectDirectory:url)
				}
			else
				{
				if let image = UIImage(contentsOfFile:url.path)
					{
						delegate.imageSelector(self, didSelectImage:image)
					}
				}
			}
		}



	func choosePhotoFromLibrary()
		{
		//checkPermission()
		
//viewController!.dismiss(animated: true) // dismiss alert before calling this vc
		
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




