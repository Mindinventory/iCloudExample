//
//  iClodeManager.swift
//  iClodeDemo
//
//  Created by mac-00021 on 15/06/21.
//  Developer Name: Parth Gohel

import Foundation

class CloudDataManager {
    
    static let shared = CloudDataManager() // Singleton
    
    let fileManager = FileManager.default
    
    struct DocumentsDirectory {
        static var localDocumentsURL: URL? {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        static var iCloudDocumentsURL: URL? {
            return FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
        }
    }
    
    // Return the Document directory (Cloud OR Local)
    // To do in a background thread
    func getDocumentDiretoryURL() -> URL {
        
        debugPrint("======================= Document paths =======================")
        debugPrint("iCloud Directory: \(String(describing: DocumentsDirectory.iCloudDocumentsURL?.path))")
        debugPrint("Local Directory: \(String(describing: DocumentsDirectory.localDocumentsURL?.path))")
        
        if self.isCloudEnabled() {
            return DocumentsDirectory.iCloudDocumentsURL!
        } else {
            return DocumentsDirectory.localDocumentsURL!
        }
    }
    
    //// Return true if iCloud is enabled
    func isCloudEnabled() -> Bool {
        if DocumentsDirectory.iCloudDocumentsURL != nil { return true }
        else {
            debugPrint("iCloud is not enabled")
            return false
        }
    }
    
    func isFileExist(at path: String) -> Bool{
        return FileManager.default.fileExists(atPath: path, isDirectory: nil)
    }
    
    //create subdirectory in iCloud
    func createSubdirectory(folderName: String){
        guard isCloudEnabled() else {return}
        
        let nestedFolderURL = DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(folderName)
        if self.isFileExist(at: nestedFolderURL.path){
            debugPrint("!!!!!! Folder already exist !!!!!!")
            return
        }else{
            do{
                let _ = try FileManager.default.createDirectory(
                    at: nestedFolderURL,
                    withIntermediateDirectories: false,
                    attributes: nil
                )
                debugPrint("\(folderName) is created sussceefully")
            } catch {
                debugPrint("Can't create a folder")
            }
        }
    }
    
    func createTextFileInDirectry(folderName: String,
                                  filename: String){
        guard self.isCloudEnabled() else {return}
        
        let nestedFolderURL = DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(folderName)
        
        if !self.isFileExist(at: nestedFolderURL.path){
            debugPrint("\(folderName) is not found at \(DocumentsDirectory.iCloudDocumentsURL!)")
        }
        let fullname = filename + ".txt"
        let fileUrl = nestedFolderURL.appendingPathComponent(fullname)
        do {
            try "Hello iCloud!".write(to: fileUrl, atomically: true, encoding: .utf8)
            debugPrint("Write successfully in the file")
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    //// Delete all files at URL
    //
    func deleteFilesInDirectory(url: URL,filenameWithExtension: String = "") {
        if filenameWithExtension.isEmpty{
            let enumerator = self.fileManager.enumerator(atPath: url.path)
            while let file = enumerator?.nextObject() as? String {
                do {
                    if !self.isFileExist(at: url.appendingPathComponent(file).path){
                        debugPrint("!!!!! File is not exist !!!!")
                        return
                    }
                    try fileManager.removeItem(at: url.appendingPathComponent(file))
                    print("!!! \(file) deleted !!!")
                } catch let error as NSError {
                    print("!!! Failed deleting files : \(error) !!!")
                }
            }
            debugPrint("All files deleted")
        }else{
            if !self.isFileExist(at: url.appendingPathComponent(filenameWithExtension).path){
                debugPrint("file is not exist")
                return
            }
            debugPrint("Deleting........")
            do {
                try fileManager.removeItem(at: url.appendingPathComponent(filenameWithExtension))
                print("\(filenameWithExtension) deleted")
            } catch let error as NSError {
                print("Failed deleting files : \(error)")
            }
        }
        
    }
    
    func fetchListOfFiles(at urlPath: String = DocumentsDirectory.iCloudDocumentsURL?.path ?? ""){
        guard self.isCloudEnabled(),
              !urlPath.isEmpty else {
            debugPrint("!!! Path is empty !!!")
            return
        }
        
        let enumerator = self.fileManager.enumerator(atPath: urlPath)
        
        debugPrint("!!!!================== All Files ===================!!!!")
        while let file = enumerator?.nextObject() as? String {
            debugPrint(file)
        }
    }
    
    // Move iCloud files to local directory
    // Local dir will be cleared
    // No data merging
    
    func moveFileToLocal(fileName: String = "",
                         withExtension: String = "",
                         copyToLocal: Bool = false) {
        guard  self.isCloudEnabled() else {return}
        
        if fileName.isEmpty && withExtension.isEmpty{
            let enumerator = fileManager.enumerator(atPath: DocumentsDirectory.iCloudDocumentsURL!.path)
            while let file = enumerator?.nextObject() as? String {
                debugPrint(file)
                do {
                    //Note: When you try to send the file to iCloud you should set the flag to true. you where using false which is to remove the file from iCloud.
                    if copyToLocal{
                        try self.fileManager.copyItem(at: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(file), to: DocumentsDirectory.localDocumentsURL!.appendingPathComponent(file))
                        debugPrint("Copy to local dir \(DocumentsDirectory.localDocumentsURL!.appendingPathComponent(file))")
                    }else{
                        try fileManager.setUbiquitous(false,
                                                      itemAt: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(file),
                                                      destinationURL: DocumentsDirectory.localDocumentsURL!.appendingPathComponent(file))
                        debugPrint("Moved to local dir \(DocumentsDirectory.localDocumentsURL!.appendingPathComponent(file))")
                    }
                    
                    
                } catch let error as NSError {
                    debugPrint("Failed to move file to local dir : \(error)")
                }
            }
        }else{
            
            var fullName: String = ""
            
            if withExtension.isEmpty{
                fullName = fileName
            }else{
                fullName = fileName+withExtension
            }
            
            if !self.isFileExist(at: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(fullName).path){
                debugPrint("\(fullName) not exist")
                return
            }
            do {
                //Note: When you try to send the file to iCloud you should set the flag to true. you where using false which is to remove the file from iCloud.
                if copyToLocal{
                    try fileManager.copyItem(at: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(fullName), to: DocumentsDirectory.localDocumentsURL!.appendingPathComponent(fullName))
                    debugPrint("Copy to local dir \(DocumentsDirectory.localDocumentsURL!.appendingPathComponent(fullName))")
                }else{
                    try fileManager.setUbiquitous(false,
                                                  itemAt: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(fullName),
                                                  destinationURL: DocumentsDirectory.localDocumentsURL!.appendingPathComponent(fullName))
                    debugPrint("Moved to local dir \(DocumentsDirectory.localDocumentsURL!.appendingPathComponent(fullName))")
                    
                }
            } catch let error as NSError {
                debugPrint("Failed to move file to local dir : \(error)")
            }
        }
        
    }
    
    //// Move/copy iCloud files to local directory
    //// Local dir will be cleared
    //// No data merging
    
    func moveFileToCloud(fileName: String,
                         withExtension: String,
                         copyToCloud:Bool = false) {
        guard  self.isCloudEnabled() else {return}
        
        if fileName.isEmpty && withExtension.isEmpty{
            let enumerator = fileManager.enumerator(atPath: DocumentsDirectory.localDocumentsURL!.path)
            while let file = enumerator?.nextObject() as? String {
                debugPrint(file)
                do {
                    //Note: When you try to send the file to iCloud you should set the flag to true. you where using false which is to remove the file from iCloud.
                    if copyToCloud{
                        try fileManager.copyItem(at: DocumentsDirectory.localDocumentsURL!.appendingPathComponent(file), to: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(file))
                        debugPrint("Copy to icloud dir \(DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(file))")
                    }else{
                        try fileManager.setUbiquitous(true,
                                                      itemAt:DocumentsDirectory.localDocumentsURL!.appendingPathComponent(file) ,
                                                      destinationURL:DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(file))
                        debugPrint("Moved to icloud dir \(DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(file))")
                    }
                    
                    
                    
                } catch let error as NSError {
                    print("Failed to move file to Cloud : \(error)")
                }
            }
        }else{
            
            var fullName: String = ""
            
            if withExtension.isEmpty{
                fullName = fileName
            }else{
                fullName = fileName+withExtension
            }
            
            if !self.isFileExist(at: DocumentsDirectory.localDocumentsURL!.appendingPathComponent(fullName).path){
                debugPrint("\(fullName) not exist")
                return
            }
            do {
                //Note: When you try to send the file to iCloud you should set the flag to true. you where using false which is to remove the file from iCloud.
                debugPrint(fullName)
                if copyToCloud{
                    try self.fileManager.copyItem(at: DocumentsDirectory.localDocumentsURL!.appendingPathComponent(fullName),
                                             to: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(fullName))
                    debugPrint("Copy to icloud dir \(DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(fullName))")
                }else{
                    try self.fileManager.setUbiquitous(true,
                                                  itemAt:DocumentsDirectory.localDocumentsURL!.appendingPathComponent(fullName) ,
                                                  destinationURL:DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(fullName))
                    debugPrint("Moved to icloud dir \(DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(fullName))")
                }
            } catch let error as NSError {
                print("Failed to move file to Cloud : \(error)")
            }
        }
    }
}

