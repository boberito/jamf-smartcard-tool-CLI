//
//  JamfInfo.swift
//  Smartcard Enforcement Utility 2.0
//
//  Created by Gendler, Bob (Fed) on 4/1/22.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class JamfInfo {
    var server: String?
    var id = ""
    var id2 = ""
    var username: String?
    var password: String?
    var token: String?
    var expires: String?
}
