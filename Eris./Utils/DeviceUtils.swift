//
//  DeviceUtils.swift
//  Eris.
//
//  Created by Ignacio Palacio on 19/6/25.
//

import Foundation
import UIKit

struct DeviceUtils {
    enum DeviceType {
        case iPhone
        case iPad
        case mac
        case unknown
    }
    
    enum ChipFamily {
        case a17Pro
        case a18
        case a18Pro
        case m1
        case m2
        case m3
        case m4
        case unsupported
        case unknown
    }
    
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    static var deviceType: DeviceType {
        #if os(macOS)
        return .mac
        #else
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return .iPhone
        case .pad:
            return .iPad
        default:
            return .unknown
        }
        #endif
    }
    
    static var deviceModel: String {
        #if targetEnvironment(simulator)
        return ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "Simulator"
        #else
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
        #endif
    }
    
    static var chipFamily: ChipFamily {
        let model = deviceModel.lowercased()
        
        // iPhone models with compatible chips
        if model.contains("iphone16,1") || model.contains("iphone16,2") {
            return .a17Pro // iPhone 15 Pro/Pro Max
        }
        if model.contains("iphone17,1") || model.contains("iphone17,2") {
            return .a18 // iPhone 16/16 Plus
        }
        if model.contains("iphone17,3") || model.contains("iphone17,4") {
            return .a18Pro // iPhone 16 Pro/Pro Max
        }
        
        // iPad models with M-series chips
        if model.contains("ipad13,4") || model.contains("ipad13,5") ||
           model.contains("ipad13,6") || model.contains("ipad13,7") {
            return .m1 // iPad Pro M1
        }
        if model.contains("ipad13,8") || model.contains("ipad13,9") ||
           model.contains("ipad13,10") || model.contains("ipad13,11") {
            return .m1 // iPad Air M1
        }
        if model.contains("ipad14,3") || model.contains("ipad14,4") ||
           model.contains("ipad14,5") || model.contains("ipad14,6") {
            return .m2 // iPad Pro M2
        }
        if model.contains("ipad14,8") || model.contains("ipad14,9") {
            return .m2 // iPad Air M2
        }
        if model.contains("ipad16,3") || model.contains("ipad16,4") ||
           model.contains("ipad16,5") || model.contains("ipad16,6") {
            return .m4 // iPad Pro M4
        }
        
        // Mac detection (when running as Designed for iPad)
        #if os(iOS) && arch(arm64)
        if ProcessInfo.processInfo.isiOSAppOnMac {
            // Running on Mac with Apple Silicon
            let cpuType = getCPUType()
            if cpuType.contains("Apple M1") {
                return .m1
            } else if cpuType.contains("Apple M2") {
                return .m2
            } else if cpuType.contains("Apple M3") {
                return .m3
            } else if cpuType.contains("Apple M4") {
                return .m4
            }
            return .m1 // Default to M1 if can't detect specific version
        }
        #endif
        
        return isSimulator ? .unsupported : .unknown
    }
    
    static var canRunMLX: Bool {
        if isSimulator { return false }
        
        switch chipFamily {
        case .a17Pro, .a18, .a18Pro, .m1, .m2, .m3, .m4:
            return true
        case .unsupported, .unknown:
            return false
        }
    }
    
    static var deviceDescription: String {
        switch deviceType {
        case .iPhone:
            return "iPhone"
        case .iPad:
            return "iPad"
        case .mac:
            return "Mac"
        case .unknown:
            return "Unknown Device"
        }
    }
    
    static var chipDescription: String {
        switch chipFamily {
        case .a17Pro:
            return "A17 Pro"
        case .a18:
            return "A18"
        case .a18Pro:
            return "A18 Pro"
        case .m1:
            return "M1"
        case .m2:
            return "M2"
        case .m3:
            return "M3"
        case .m4:
            return "M4"
        case .unsupported:
            return "Unsupported Chip"
        case .unknown:
            return "Unknown Chip"
        }
    }
    
    static var compatibilityMessage: String {
        if canRunMLX {
            return "Your \(deviceDescription) with \(chipDescription) chip is compatible with MLX models."
        } else if isSimulator {
            return "Simulator detected. MLX models require real Apple Silicon hardware."
        } else {
            return "Your device doesn't support MLX models. Compatible devices include iPhone 15 Pro or later, iPads with M-series chips, and Macs with Apple Silicon."
        }
    }
    
    private static func getCPUType() -> String {
        var size = 0
        sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)
        var cpu = [CChar](repeating: 0, count: size)
        sysctlbyname("machdep.cpu.brand_string", &cpu, &size, nil, 0)
        return String(cString: cpu)
    }
}