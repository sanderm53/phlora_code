//
//  DownloadService.swift
//  QGTut
//
//  Created by mcmanderson on 12/10/18.
//  Borrowing heavily from the following... and snippets used elsewhere in URLSession code
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

class DownloadService // Instantiate this once for the entire database table view
	{
	var downloadsSession: URLSession!
	var treeInfo:TreeInfoPackage! // but this gets set to appropriate tree/study when download begins
	var activeDownloads: [URL: Download] = [:] // provides info needed by the delegate, keyed to the source URL
	
	func startDownload(forStudy t:TreeInfoPackage)
		{
		treeInfo = t
		do
			{
				let manifestList = try getManifestData(forStudy:t.treeName, atRemoteServerPath:treeSettings.defaultDatabasePath)
				try downloadFiles(forStudyName:t.treeName, using:manifestList)
			}
		catch
			{ print ("Error fetching manifest data or files") }

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

	func downloadFiles(forStudyName studyName:String, using manifestList: [(DataFileType , URL )]) throws
		{
		for (fileType,url) in manifestList
			{
			print (fileType,url)
			let srcFileName = url.lastPathComponent // copy saved to local temp file has a weird name; have to reconstute it
			let download = Download(studyName:studyName, srcFileName:srcFileName,srcFileType:fileType)
			download.task = downloadsSession.downloadTask(with: url)
			download.task!.resume()
			download.isDownloading = true
			activeDownloads[url] = download
			}
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

