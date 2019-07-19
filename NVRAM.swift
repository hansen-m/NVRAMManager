//
//  NVRAMManager.swift
//  BuildMenu
//
//  Created by Matt Hansen on 1/30/16.
//  Copyright © 2016 The Pennsylvania State University. All rights reserved.
//
// http://www.opensource.apple.com/source/system_cmds/system_cmds-643.30.1/nvram.tproj/nvram.c

import IOKit
import Foundation

let masterPort = IOServiceGetMatchingService(kIOMasterPortDefault, nil)
let gOptionsRef = IORegistryEntryFromPath(masterPort, "IODeviceTree:/options")
let serviceIOPlatformExpertDevice = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))


class NVRAM {

    func SetOFVariable(_ name: String, value: String) {
        
        let nameRef = CFStringCreateWithCString(kCFAllocatorDefault, name, CFStringBuiltInEncodings.UTF8.rawValue)
        
        // As CFString (Switched to NSData due to issues with trailing %00 characters in values after reboot)
        //let valueRef = CFStringCreateWithCString(kCFAllocatorDefault, value, CFStringBuiltInEncodings.UTF8.rawValue)
        
        // CFData is “toll-free bridged” with its Cocoa Foundation counterpart, NSData.
        let valueRef = value.data(using: String.Encoding.ascii)
        
        IORegistryEntrySetCFProperty(gOptionsRef, nameRef, valueRef as CFTypeRef!)
    }

    func GetOFVariable(_ name: String) -> String {
        
        let nameRef = CFStringCreateWithCString(kCFAllocatorDefault, name, CFStringBuiltInEncodings.UTF8.rawValue)
        
        let valueRef = IORegistryEntryCreateCFProperty(gOptionsRef, nameRef, kCFAllocatorDefault, 0)

        if (valueRef != nil) {
            // Read as NSData
            if let data = valueRef?.takeUnretainedValue() as? Data {
                return NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
            }
            // Read as String
            return valueRef!.takeRetainedValue() as! String
        } else {
            return ""
        }
    }
    
    func PrintOFVariables() {

        let dict = UnsafeMutablePointer<Unmanaged<CFMutableDictionary>?>.allocate(capacity: 1)
        let result = IORegistryEntryCreateCFProperties(gOptionsRef, dict, kCFAllocatorDefault, 0)
        
        if let resultDict = dict.pointee?.takeUnretainedValue() as Dictionary? {
            print(resultDict, result)
        }
    }
    
    func GetPlatformAttributeForKey(_ key: String) -> String {
        
        let nameRef = CFStringCreateWithCString(kCFAllocatorDefault, key, CFStringBuiltInEncodings.UTF8.rawValue)
    
        let valueRef = IORegistryEntryCreateCFProperty(serviceIOPlatformExpertDevice, nameRef, kCFAllocatorDefault, 0)
    
        // Read as NSData
        if let data = valueRef?.takeUnretainedValue() as? Data {
            return NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
        } else {
            // Read as String
            return valueRef!.takeRetainedValue() as! String
        }
    }
    
    func ClearOFVariable(_ key: String) {
        
        IORegistryEntrySetCFProperty(gOptionsRef, kIONVRAMDeletePropertyKey as CFString!, key as CFTypeRef!)
    }
    
}
