//
//  SimonTreeNwk.swift
//  iTree
//
//  Created by mcmanderson on 5/25/17.
//  Copyright © 2017 mcmanderson. All rights reserved.
//

import UIKit
//import QuartzCore

class TreesData
	{

	var treeInfoDictionary = [String:TreeInfoPackage]()
	var treeInfoNamesSortedArray = [String]()



	init()
		{
		let nexusFilenames = getNexusFilenamesFromBundle()
		for nexFile in nexusFilenames
			{
			let treeInfo = TreeInfoPackage(fromFileName: nexFile)
			treeInfoDictionary[treeInfo.treeName]=treeInfo
			}
		treeInfoNamesSortedArray = Array(treeInfoDictionary.keys).sorted(by: <)
		}

	//func selectTreeView(forTreeName treeName:String, usingSameFrameAs frame:CGRect)->DrawTreeView
	func selectTreeView(forTreeName treeName:String)->DrawTreeView
		{
		// make all trees that have had a treeView at sometime in past be hidden in prep for selecting a new one
		for (tree,treeInfo) in treeInfoDictionary
			{
			if treeInfo.treeView != nil
				{treeInfo.isHidden = true}
			}
			
		let treeInfo = treeInfoDictionary[treeName]!
		if treeInfo.treeView == nil // This tree view has never been created, so init it and return it
			{
			//treeInfo.treeView = DrawTreeView(frame:frame,using:treeInfo)
			treeInfo.treeView = DrawTreeView(using:treeInfo)
			}
		treeInfo.treeView!.isHidden = false
		return treeInfo.treeView!
		}

	func getNexusFilenamesFromBundle()->[String]
			{
			var matchingFileNames = [String]()
			let fileManager = FileManager.default
			do {
				let files = try fileManager.contentsOfDirectory(atPath:Bundle.main.bundlePath)
				for file in files
					{
			//print (file)
					let matchesAr = matches(for: "\\.nex", in: file)
					if matchesAr.count == 1
						{
			//print ("Matched")
						let filePath = Bundle.main.bundlePath + "/" + file
						if fileManager.fileExists(atPath: filePath)
							{
							//print(filePath,"...exists")
							matchingFileNames.append(filePath)
							}
						}
					}
				}
			catch
				{
				print ("Nexus Files not found")
				}

			return matchingFileNames
			}

	}

//*************************************************************************

class TreeInfoPackage
	{
	var treeName:String;
	var treeDescription:String;
	var treeSource:String;
	var mrcaArray: [Dictionary<String, String>] = []
	var treeViewController:TreeViewController?
	var treeView:DrawTreeView?
	var isHidden:Bool = true
	var nLeaves:Int=0

	init(fromFileName file:String)
		{
		(nLeaves, treeName, treeDescription, treeSource, mrcaArray)=parseNexusFile(fromFileName:file)
		//treeSource = ""
		}
	}




		
	func parseNexusFile(fromFileName file:String)->(Int,String,String,String, [[String:String]]) // returns an array of hashes of three taxon names
		{
		//var mrca = [String:String]()
		var mrca: [String:String] = [:]
		var mrcaArray: [Dictionary<String, String>] = []
		//let nexusFilePath = Bundle.main.bundlePath + "/" + file
		let nexusFilePath =  file
		var treeDescription:String = ""
		var treeSource = ""
		var treeName:String = ""
		var nLeaves = 1
		
		do {
			let nexusString = try String(contentsOfFile: nexusFilePath)

			let commands = nexusString.split(whereSeparator: { $0 == ";" })
			for command in commands
				{
				//let chomped = command.drop(while: {$0 == "\n"}) ...working inconsistently
				let ctokens = matches(for: nwktokensTilde, in: String(command))

				if ctokens.count >= 3 // could be a valid line; there might be others that just have white space or crap
					{
					if ctokens[0] == "mrca" && ctokens[2] == "=" && ctokens.count == 6
						{
						//print ("Taxa = ",ctokens[1],ctokens[3],ctokens[5])
						mrca["cladeName"] = ctokens[1]
						mrca["specifierA"] = ctokens[3]
						mrca["logic"] = ctokens[4]	// this is either a ',' or a '~'
						mrca["specifierB"] = ctokens[5]
						mrcaArray.append(mrca)
						}

					if ctokens[0] == "tree" && ctokens[2] == "=" && ctokens.count >= 4
						{
						treeName = ctokens[1]
						for token in ctokens[3...ctokens.count-1]
							{
							if token == ","
								{
								nLeaves += 1 // counting the number of leaves as commas+1
								}
							}
						treeDescription = ctokens[3...ctokens.count-1].joined()
						}

					if ctokens[0] == "reference" && ctokens[1] == "=" && ctokens.count >= 3
						{
						treeSource = ctokens[2...ctokens.count-1].joined()
						treeSource = treeSource.replacingOccurrences(of: "'", with: "")
						}


					}


				}
			}
		catch {print ("mrca file read or process error")}
		return (nLeaves, treeName, treeDescription, treeSource, mrcaArray)
		}





	//let treeTitle:String = "Leguminosae (Simon 2009)"
	//let treeTitle:String = "Cactaceae (Hernandez-Hernandez et al. 2011)"
	//let treeSource:String = "J. Charboneau, 2017: Families of the Arizona Flora"
	//let treeName:String = "Flowering Plants"
	let treeSource:String = "Donoghue, pers.comm."
	let treeName:String = "Viburnum"



let nwkAZFamilies="(Nymphaeaceae,((Aristolochiaceae,Saururaceae),(((Araceae,(Hydrocharitaceae,(Alismataceae,(Juncaginaceae,(Ruppiaceae,Potamogetonaceae))))),((Melanthiaceae,Liliaceae),((Orchidaceae,(Hypoxidaceae,(Iridaceae,(Xanthorrhoeaceae,(Amaryllidaceae,Asparagaceae))))),(Arecaceae,((Commelinaceae,Pontederiaceae),((Typhaceae,Bromeliaceae),(Poaceae,(Juncaceae,Cyperaceae)))))))),(Ceratophyllaceae,((Papaveraceae,(Menispermaceae,(Berberidaceae,Ranunculaceae))),(Platanaceae,((((Crassulaceae,Haloragaceae),(Grossulariaceae,Saxifragaceae)),(Vitaceae,(((Krameriaceae,Zygophyllaceae),((Celastraceae,(Oxalidaceae,(Hypericaceae,(Elatinaceae,Malpighiaceae),((Violaceae,(Passifloraceae,Salicaceae)),(Euphorbiaceae,(Linaceae,(Phyllanthaceae,Picrodendraceae))))))),((Polygalaceae,Fabaceae),((Rosaceae,((Rhamnaceae,Elaeagnaceae),(Ulmaceae,(Cannabaceae,(Moraceae,Urticaceae))))),((Apodanthaceae,Cucurbitaceae),(Fagaceae,(Juglandaceae,Betulaceae))))))),((Geraniaceae,(Myrtaceae,(Onagraceae,Lythraceae))),(Crossosomataceae,((Nitrariaceae,((Burseraceae,Anacardiaceae),(Sapindaceae,(Rutaceae,(Simaroubaceae,Meliaceae))))),((Bixaceae,Malvaceae),(Koeberliniaceae,(Resedaceae,(Capparaceae,(Cleomaceae,Brassicaceae))))))))))),(Santalaceae,(((Tamaricaceae,(Plumbaginaceae,Polygonaceae)),(Simmondsiaceae,((Caryophyllaceae,Amaranthaceae),((Aizoaceae,(Phytolaccaceae,(Sarcobataceae,Nyctaginaceae))),(Molluginaceae,(Montiaceae,(Talinaceae,(Portulacaceae,Cactaceae)))))))),((Cornaceae,(Loasaceae,Hydrangeaceae)),(((Polemoniaceae,Fouquieriaceae),(Ericaceae,(Sapotaceae,Primulaceae))),((Garryaceae,((Rubiaceae,(Apocynaceae,Gentianaceae)),((Convolvulaceae,Solanaceae),(Boraginaceae,(Oleaceae,(Plantaginaceae,(Scrophulariaceae,(Linderniaceae,((Martyniaceae,Acanthaceae),(Bignoniaceae,((Lentibulariaceae,Verbenaceae),(Lamiaceae,(Phrymaceae,Orobanchaceae))))))))))))),((Campanulaceae,(Menyanthaceae,Asteraceae)),((Araliaceae,Apiaceae),(Adoxaceae,Caprifoliaceae)))))))))))))));"


let nwkAZOrders="(Nympheales,(Piperales,(((Alismatales,(Liliales,Asparagales)),(Arecales,(Commelinales,Poales))),(Ceratophyllales,(Ranunculales,(Proteales,((Saxifragales,(Vitales,(Zygophyllales,(((Celastrales,(Oxalidales,Malpighiales)),(Fabales,(Rosales,(Cucurbitales,Fagales)))),((Geraniales,Myrtales),(Crossosomatales,(Sapindales,(Malvales,Brassicales)))))))),(Santalales,(Caryophyllales,(Cornales,(Ericales,((Garryales,(Gentianales,(Lamiales,(Solanales,Boraginales)))),(Asterales,(Apiales,Dipsacales))))))))))))));"






	
