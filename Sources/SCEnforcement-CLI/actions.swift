import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class actions: DataModelDelegate {
    func didRecieveDataUpdate(jamfData: Data, jamfResponse: HTTPURLResponse) {
        returnData = jamfData
        returnResponse = jamfResponse
    }
    var jamf = JamfClass()
    
    var info: jamfuserInfo?
    var ea: extensionAttribute?
    var jamfInfo: computerInfo?
    
    var returnData: Data?
    var returnResponse: HTTPURLResponse?
    var username = String()
    var password = String()
    
    func exempt(entry: Int) {
        jamf.delegate = self
        let y = entry - 1

        let daysToAdd = 1
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.day = daysToAdd
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "MM-dd-YY"
        let date = dateFormatter.string(from: futureDate!)
        
        let xmldata = "<computer><extension_attributes><extension_attribute><id>" + jamf.id + "</id><value>Disabled</value></extension_attribute><extension_attribute><id>\(jamf.id2)</id><value>\(date)</value></extension_attribute></extension_attributes></computer>"
        jamf.putData(apiURL: "JSSResource/computers/id/\(info!.computers[y].id)", xmlData: xmldata) {
            
            switch self.returnResponse?.statusCode {
            case 201:
                //good
                print("24 Hour Exemption applied!")
            case 401:
                print("\(Colors.red)401 Error\(Colors.reset): login incorrect")
                exit(0)
            case 400:
                print("\(Colors.red)400 Error\(Colors.reset): You sent a request that this server could not understand")
                
            case 404:
                print("\(Colors.red)404 Error\(Colors.reset): No Entries found")
                
            case 1:
                print("\(Colors.red)Could not connect to the server.\(Colors.reset)")
                
            default:
                print("\(Colors.bold)\(Colors.red)Things went really bad if you got here\(Colors.reset)")
            }
#if os(Windows)
                    Thread.sleep(forTimeInterval: 5)
#else
                    sleep(5)
#endif

        }
    }
    
    func Lookup(entry: Int) -> Bool {
        jamf.delegate = self
        let y = entry - 1
        var success = false
        if let info = info {
            if entry > info.computers.count || entry <= 0 {
                print("Selection out of range")
                do {
#if os(Windows)
                    Thread.sleep(forTimeInterval: 5)
#else
                    sleep(5)
#endif
                }
                return success
            }
            
            jamf.getData(apiURL: "JSSResource/computers/id/\(info.computers[y].id)") {
                switch self.returnResponse?.statusCode {
                case 401:
                    print("\(Colors.red)401 Error\(Colors.reset): login incorrect")
                    exit(0)
                case 400:
                    print("\(Colors.red)400 Error\(Colors.reset): You sent a request that this server could not understand")
                case 404:
                    print("\(Colors.red)404 Error\(Colors.reset): No Entries found")
                case 1:
                    print("derp derp not sure what happened")
                case 200:
                    success = true
                    let decoder = JSONDecoder()
                    if let returnData = self.returnData {
                        do {
                            jamfInfo = try decoder.decode(computerInfo.self, from: returnData)
                            if let jamfInfo = jamfInfo {
                                print("\(Colors.bold)Computer Name:\(Colors.reset) \(jamfInfo.computer.general.name)")
                                print("\(Colors.bold)Asset Tag:\(Colors.reset) \(jamfInfo.computer.general.asset_tag)")
                                print("\(Colors.bold)Last Known IP:\(Colors.reset) \(jamfInfo.computer.general.ip_address)")
                                print("\(Colors.bold)Last Check In:\(Colors.reset) \(jamfInfo.computer.general.last_contact_time)")
                                print("\(Colors.bold)Last Inventory Update:\(Colors.reset) \(jamfInfo.computer.general.report_date)")
                                print("\(Colors.bold)macOS Version:\(Colors.reset) \(jamfInfo.computer.hardware.os_version)")
                                print("\(Colors.bold)Processor:\(Colors.reset) \(jamfInfo.computer.hardware.processor_type)")
                                print("\(Colors.bold)AD Status:\(Colors.reset) \(jamfInfo.computer.hardware.active_directory_status)")
                                if jamfInfo.computer.hardware.active_directory_status == "campus.nist.gov" {
                                    print("\t   AD Connected")
                                } else {
                                    print("\t   AD Not Connected")
                                }
                                
                                for EA in jamfInfo.computer.extension_attributes {
                                    switch EA.id {
                                    case 478:
                                        print("\(Colors.bold)Uptime:\(Colors.reset) \(EA.value) Days")
                                    case 523:
                                        print("\(Colors.bold)AD Group Membership:\(Colors.reset) ")
                                        let ADGroups = EA.value.split(separator: "\n")
                                        for ADGroup in ADGroups {
                                            print("\t    \(ADGroup)")
                                        }
                                    case 497:
                                        print("\(Colors.bold)PIV Enforcement:\(Colors.reset) \(EA.value)")
                                    default:
                                        continue
                                    }
                                    
                                }
                            }
                            
                        } catch {
                            
                        }
                    }
                default:
                    print("I dont know how you got here but you did")
                }
            }
        } else {
            print("problemo")
        }
        return success
    }
    
    func List(lookup: String) -> Bool {
        var success = false
        jamf.delegate = self
        jamf.username = username
        jamf.password = password
        

                
                self.jamf.getData(apiURL: "JSSResource/computers/match/\(lookup)") {
                    
                    switch self.returnResponse?.statusCode {
                    case 401:
                        print("Unauthorized - incorrect login")
                    case 400:
                        print("Bad request the server did not understand")
                    case 404:
                        print("404 error")
                    case 1:
                        print("derp derp not sure what happened")
                    case 200:
                        let decoder = JSONDecoder()
                        if let returnData = self.returnData {
                            do {
                                self.info = try decoder.decode(jamfuserInfo.self, from: returnData)
                                if self.info?.computers.count == 0 {
                                    print("no entries found")
                                    do {
#if os(Windows)
                                        Thread.sleep(forTimeInterval: 5)
#else
                                        sleep(5)
#endif
                                    }
                                    success = false
                                } else {
                                    success = true
                                }
                                if let info = self.info {
                                    var x = 1
                                    for computer in info.computers {
                                        print("\(x). \(computer.name)")
                                        x += 1
                                    }
                                }
                            } catch {
                                
                            }
                        }
                    default:
                        print("I dont know how you got here but you did")
                        if let statusCode = self.returnResponse?.statusCode {
                            print("HTTP RESPONSE CODE: \(statusCode)")
                        } else {
                            print("No HTTP Response Code. Life is unfair")
                        }
                        
                        exit(2)
                    }
                    
                }
                

        return success
    }
    
    func invalidate() {
        if jamf.token != nil {
            jamf.invalidate_token {
            }
        }
    }
    
}


