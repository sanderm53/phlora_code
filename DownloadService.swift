//
//  DownloadService.swift
//  QGTut
//
//  Created by mcmanderson on 12/10/18.
//  Borrowing and modifying some code from the following...and snippets used elsewhere in URLSession code
//
/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import UIKit

enum DownloadServiceError: Error {
	case busy
	case manifestError
	case noNewFiles
	}


// Manage download of a collection of files in a new or existing study in the app

class DownloadService // Instantiate this once for the entire database table view to represent one study's download service only
	{
	var downloadsSession: URLSession!
	var treeInfo:TreeInfoPackage! // but this gets set to appropriate tree/study when download begins
	var activeDownloads: [URL: Download] = [:] // provides info needed by the delegate, keyed to the source URL
	var nFilesToDownload: Int = 0
	var nFilesHaveDownloaded: Int = 0 // just setting thse to dummy values
	var isDownloading: Bool = false
	var viewController:UIViewController
	var annotatedProgressView = AnnotatedProgressView()

	init(viewController vc:UIViewController)
		{
		self.viewController = vc
		if let view = self.viewController.view
			{
			view.addSubview(annotatedProgressView)
			annotatedProgressView.translatesAutoresizingMaskIntoConstraints=false
			annotatedProgressView.heightAnchor.constraint(equalToConstant: 150).isActive = true
			annotatedProgressView.widthAnchor.constraint(equalToConstant: 300).isActive = true
			annotatedProgressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
			annotatedProgressView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
			}
		}

	func downloadAll(forStudy t:TreeInfoPackage,havingFileTypes fileTypes:[DataFileType])
		{
		do
			{
			try startDownload(forStudy:t, havingFileTypes:fileTypes)
			annotatedProgressView.start(title:t.displayTreeName, nFilesToDownload: nFilesToDownload)
			}
		catch (DownloadServiceError.busy) // errors defined in DownloadService
			{
			showAlertMessage ("Download service busy", onVC:viewController)
			}
		catch (DownloadServiceError.manifestError)
			{
			showAlertMessage ("Error fetching manifest file", onVC:viewController)
			}
		catch (DownloadServiceError.noNewFiles)
			{
			showAlertMessage ("No remote files that are missing locally", onVC:viewController)
			}
		catch
			{
			}
		}

	func startDownload(forStudy t:TreeInfoPackage, havingFileTypes fileTypes:[DataFileType]) throws

		// Begins process of possibly downloading files for one study only of type given in the array
		// Fetches and parses the manifest to get filetypes and URLS and then filters them by type.
		// Does NOT overwrite local files with remote files of the same name. Checks the names in the remote manifest and skips any
		// matches to local names. Thus, you'd have to manually delete a local file to overwrite it with a remote one.
		// Ignores local files in the bundle and makes a duplicate in the docs directory if there is one of the same name
		// (Code generally prefers any file in the docs dir and ignores matching one in bundle).

		{
		let downloadThreshold = 5 // if > this number, make the user confirm they want to do this
		if isDownloading { throw DownloadServiceError.busy }
		treeInfo = t
		nFilesHaveDownloaded = 0
		var filteredManifestList:[(DataFileType , URL)] = []
		if let manifestList = try? getManifestData(forStudy:t.treeName, atRemoteServerPath:treeSettings.defaultDatabasePath)
			{
			for (fileType,url) in manifestList
				{
				//print (fileType,url)
				if fileTypes.contains(fileType)
					{
					if fileExistsInDocs(srcFileType:fileType, srcFilename:url.lastPathComponent, forStudy:t.treeName) == false
						{
						filteredManifestList.append((fileType,url))
						}
					}
				}
			nFilesToDownload = filteredManifestList.count

			if (nFilesToDownload > 0)
				{
				if nFilesToDownload > downloadThreshold // for large downloads do an alert confirm
					{
					let alert = UIAlertController(title:"Really download \(nFilesToDownload) files to your device?",message:"", preferredStyle: .alert)
					let action1 = UIAlertAction(title: "Cancel", style: .cancel)
						{ (action:UIAlertAction) in
						self.viewController.dismiss(animated:true)
						}
					let action2 = UIAlertAction(title: "Download", style: .default)
						{ (action:UIAlertAction) in
						self.isDownloading = true
						self.downloadFiles(forStudyName:t.treeName, using:filteredManifestList)
						}
					alert.addAction(action1)
					alert.addAction(action2)
					self.viewController.present(alert, animated: true, completion: nil)
					}
				else
					{
					self.isDownloading = true
					self.downloadFiles(forStudyName:t.treeName, using:filteredManifestList)
					}
				}
			else
				{throw DownloadServiceError.noNewFiles}
			}
		else
			{ throw DownloadServiceError.manifestError}
		}


	func downloadFiles(forStudyName studyName:String, using manifestList: [(DataFileType , URL )]) // throws
		{
		for (fileType,url) in manifestList
			{
			//print (fileType,url)
			let srcFileName = url.lastPathComponent // copy saved to local temp file has a weird name; have to reconstute it
			let download = Download(studyName:studyName, srcFileName:srcFileName,srcFileType:fileType)
			download.task = downloadsSession.downloadTask(with: url)
			download.task!.resume()
			download.isDownloading = true
			activeDownloads[url] = download
			}
		}

	func cancelAll()
		{
		for download in activeDownloads.values
			{
			download.task?.cancel() // Hmm this is only the right logic if the dictionary is completely populated synchronously prior to getting here
			}
		annotatedProgressView.isHidden = true
		isDownloading = false
		}

	func fileDidFinishDownloading(from sourceURL:URL, to tempLocalURL:URL) -> URL?
		{
		if let download = activeDownloads[sourceURL] // info I need for copyURL..() below is in this dictionary
			{
			activeDownloads[sourceURL] = nil
			if let targetURL = try? copyURLToDocs(src:tempLocalURL, srcFileType: download.srcFileType, srcFilename: download.srcFileName, forStudy: download.studyName,overwrite:true)
				{

				nFilesHaveDownloaded += 1
				let progress = Float(nFilesHaveDownloaded)/Float(nFilesToDownload)
				DispatchQueue.main.async
					{
					self.annotatedProgressView.updateProgress(int1: self.nFilesHaveDownloaded, int2: self.nFilesToDownload)
					}
				if (progress == 1.0)
					{
					DispatchQueue.main.async
						{
						self.annotatedProgressView.isHidden = true
						self.isDownloading = false
						}
					}

				print ("file copied to", targetURL)
				return targetURL
				}
			else
				{
				showAlertMessage ("Error downloading/saving remote file", onVC:viewController)
				return nil
				}
			}
		return nil
		}



	}
// ************************

class Download {

  var srcFileName: String
  var srcFileType:DataFileType
  var studyName: String
	
  init(studyName st:String, srcFileName fn:String, srcFileType ty:DataFileType)
  	{
  	studyName = st
    srcFileName = fn
    srcFileType = ty
  	}

  // Download service sets these values:
  var task: URLSessionDownloadTask?
  var isDownloading = false
  var resumeData: Data?

  // Download delegate sets this value:
  var progress: Float = 0

}







/* KEEP!! This code can be used for a quick URLsession w/o delegates, background download, etc.
	func downloadFiles(forStudyName studyName:String, using manifestList: [(DataFileType , URL )]) throws
		{
		for (fileType,url) in manifestList
			{
			print (fileType,url)
			let srcFileName = url.lastPathComponent // copy saved to local temp file has a weird name; have to reconstute it
			let task = URLSession.shared.downloadTask(with: url) { localURL, urlResponse, error in
				if let localURL = localURL
					{
					if let targetURL = try? copyURLToDocs(src:localURL, srcFileType: fileType, srcFilename: srcFileName, forStudy: studyName)
						{
						print ("file copied to", targetURL)
						}
					else
						{ print ("Error in url copying")}
					}
				}
			task.resume()
			}
		}
*/


