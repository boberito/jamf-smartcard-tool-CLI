import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

var jamf = actions()


#if os(Windows)

let task = Process()
let pipe = Pipe()

task.standardOutput = pipe
task.standardError = pipe
task.executableURL = URL(fileURLWithPath: "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe")
task.arguments = ["$c = Get-Credential; $c.Username; [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR(($c.Password)))"]

try task.run()

let data = pipe.fileHandleForReading.readDataToEndOfFile()
let output = String(data: data, encoding: .utf8)!

let login = output.components(separatedBy: "\n")
jamf.username = login[0]
jamf.password = login[1]

jamf.username.removeLast()
jamf.password.removeLast()


if jamf.password == "" {
    print("Password is required")
    exit(1)
}
#else

print("Please enter functional account:", terminator: "")
let user_name = readLine(strippingNewline: true)!

guard let cPass = getpass("Please enter password:") else {
    print("Password is required")
    exit(1)
}
let password = String(cString: cPass)
jamf.password = password
jamf.username = user_name

#endif

var interactiveMode = true
print(Colors.clearscreen)
print("--- macOS Smartcard Enforcement ---")
while interactiveMode == true {
    
    print("Search for machine [enter tag, computer name, username]\(Colors.bold)\(Colors.blink): \(Colors.reset)", terminator: "")
    if let lookupVar = readLine(strippingNewline: true) {
        
        if lookupVar == "q" {
            jamf.invalidate()
            exit(0)
        }
        if jamf.List(lookup: lookupVar) {
            print("Choose an entry to lookup more details on\(Colors.bold)\(Colors.blink): \(Colors.reset)", terminator: "")
            if let selection = readLine(strippingNewline: true) {
                print(Colors.clearscreen)
                if selection == "q" {
                    jamf.invalidate()
                    exit(0)
                }
                if jamf.Lookup(entry: Int(selection) ?? 0) {
                    print("Give 24 hour PIV exemption (Y/N)\(Colors.bold)\(Colors.blink): \(Colors.reset)", terminator: "")
                    if let exempt = readLine(strippingNewline: true) {
                        if exempt.lowercased() == "y" {
                            jamf.exempt(entry: Int(selection) ?? 0)
                        }
                        if exempt.lowercased() == "q" {
                            jamf.invalidate()
                            exit(0)
                        }
                        
                    }
                    
                }
            }
        }
    }
    print(Colors.clearscreen)
}


