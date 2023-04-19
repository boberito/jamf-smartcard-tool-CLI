//
//  File.swift
//  
//
//  Created by Gendler, Bob (Fed) on 4/15/22.
//

import Foundation
#if os(Windows)
import WinSDK
import SwiftWin32
#endif


struct preferences {
    
    func readPreferences() -> (Server: String, ID1: String, ID2: String) {
#if os(macOS)
        let bundlePLIST = UserDefaults.init(suiteName: "gov.nist.SmartCardEnforcementUtility")
        if let jamfserver = bundlePLIST?.string(forKey: "jss_URL"), let eaID = bundlePLIST?.string(forKey: "EA_ID"), let eaID2 = bundlePLIST?.string(forKey: "EA2_ID") {
            return(Server: jamfserver, ID1: eaID, ID2: eaID2)
        }
        return(Server: "",ID1: "",ID2: "")
        
        
#elseif os(Windows)
        
        var jamfserver = String()
        jamfserver = ""
        var eaID = ""
        var eaID2 = ""
        

        func ReadRegistry(scope: HKEY, path: String, key: String) throws -> String {
            var szBuffer: [WCHAR] = Array<WCHAR>(repeating: 0, count: 64)

            var cbData: DWORD = 0
            while true {
                let lStatus: LSTATUS =
                    RegGetValueW(scope, path.wide,
                            key.wide, DWORD(RRF_RT_REG_SZ),
                            nil, &szBuffer, &cbData)
            
                if lStatus == ERROR_MORE_DATA {
                    szBuffer = Array<WCHAR>(repeating: 0, count: szBuffer.count * 2)
                    continue
                }
            
                guard lStatus == 0 else {
                    return ""
                }
                return String(decodingCString: szBuffer, as: UTF16.self)
            }
        }


        do {
            jamfserver = try ReadRegistry(scope: HKEY_CURRENT_USER, path: "jamf-smartcard-utility", key: "jamfserver")
            eaID = try ReadRegistry(scope: HKEY_CURRENT_USER, path: "jamf-smartcard-utility", key: "id1")
            eaID2 = try ReadRegistry(scope: HKEY_CURRENT_USER, path: "jamf-smartcard-utility", key: "id2")
       
        } catch {
            print("Error. Keys not found")
        }
        return(Server: jamfserver, ID1: eaID, ID2: eaID2)
        
#elseif os(Linux)
        
        var jamfserver = ""
        var eaID = ""
        var eaID2 = ""
        
        do {
            let homeDirURL = FileManager.default.homeDirectoryForCurrentUser
            let configPath = homeDirURL.path + "/.jamf-smartcard-utility.config"
            let contents = try String(contentsOfFile: configPath, encoding: String.Encoding.utf8)
            
            let entries = contents.components(separatedBy: "\n")
            
            for entry in entries {
                if entry.contains("jamfserver = "){
                    jamfserver = entry.components(separatedBy: " = ")[1].replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
                }
                if entry.contains("eaID1 = "){
                    eaID = entry.components(separatedBy: " = ")[1].replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
                }
                if entry.contains("eaID2 = "){
                    eaID2 = entry.components(separatedBy: " = ")[1].replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
                }
            }
        } catch {
            //no config file found
        }
        
        return(Server: jamfserver, ID1: eaID, ID2: eaID2)
        
#endif
    }
}


