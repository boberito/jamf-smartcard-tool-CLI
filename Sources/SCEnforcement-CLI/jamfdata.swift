//
//  jamfData.swift
//  Smartcard Enforcement Utility 2.0
//
//  Created by Gendler, Bob (Fed) on 4/1/22.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct jamfuserInfo: Decodable {
    var computers: [entries]
    
    struct entries: Decodable {
        let id: Int
        let name: String
        let username: String
        let realname: String
        let email_address: String
        let asset_tag: String
    }
}

struct userGroupInfo: Decodable {
    let user_group: usergroup
    
    struct usergroup: Decodable {
        let users:[entries]
        
        struct entries: Decodable {
            let username: String
        }
    }
}

struct extensionAttribute: Decodable {
    let computer: computerEA
    
    struct computerEA: Decodable {
        let extension_attributes: [EA]
        
        struct EA: Decodable {
            let id: Int
            let name: String
            let value: String
        }
        
    }
    
}

struct jamfauth: Decodable {
    let token: String
    let expires: String?
    let httpStatus: Int?
}

struct computerInfo: Decodable {
    let computer: computer
    
    struct computer: Decodable {
        let general: General
        var hardware: Hardware
        let extension_attributes: [EAs]
        
        struct General: Decodable {
            let name: String
            let ip_address: String
            let asset_tag: String
            let last_contact_time: String
            let report_date: String
        }
        struct Hardware: Decodable {
            let os_version: String
            let active_directory_status: String
            let is_apple_silicon: Bool
            let processor_type: String
        }
        struct EAs: Decodable {
            let id: Int
            let value: String
        }
    }
    
}

struct permissionInfo: Decodable {
    let user: User
    struct User: Decodable {
        let privileges: [String]
    }
}
