//
//  Interpolatable.swift
//  Interpolate
//
//  Created by Roy Marmelstein on 10/04/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation
import QuartzCore
#if os(iOS)
import UIKit
#else
import Cocoa
#endif

/**
 *  Interpolatable protocol. Requires implementation of a vectorize function.
 */
public protocol Interpolatable {
    /**
     Vectorizes the type and returns and IPValue
     */
    func vectorize() -> IPValue
    /**
     The number of components of the IPValue
     */
    static var components: Int { get }
}

// MARK: Extensions

/// CATransform3D Interpolatable extension.
extension CATransform3D: Interpolatable {
    /**
     Vectorize CATransform3D.
     
     - returns: IPValue
     */
    public func vectorize() -> IPValue {
        return IPValue(vectors: [m11, m12, m13, m14, m21, m22, m23, m24, m31, m32, m33, m34, m41, m42, m43, m44]) {
            CATransform3D(m11: $0[0], m12: $0[1], m13: $0[2], m14: $0[3], m21: $0[4], m22: $0[5], m23: $0[6], m24: $0[7], m31: $0[8], m32: $0[9], m33: $0[10], m34: $0[11], m41: $0[12], m42: $0[13], m43: $0[14], m44: $0[15])
        }
    }

    public static let components: Int = 16
}

/// CGAffineTransform Interpolatable extension.
extension CGAffineTransform: Interpolatable {
    /**
     Vectorize CGAffineTransform.
     
     - returns: IPValue
     */
    public func vectorize() -> IPValue {
        return IPValue(vectors: [a, b, c, d, tx, ty]) { CGAffineTransform(a: $0[0], b: $0[1], c: $0[2], d: $0[3], tx: $0[4], ty: $0[5]) }
    }

    public static let components: Int = 6
}

/// CGFloat Interpolatable extension.
extension CGFloat: Interpolatable {
    /**
     Vectorize CGFloat.
     
     - returns: IPValue
     */
    public func vectorize() -> IPValue {
        return IPValue(vectors: [self]) { $0[0] }
    }

    public static let components: Int = 1
}

/// CGPoint Interpolatable extension.
extension CGPoint: Interpolatable {
    /**
     Vectorize CGPoint.
     
     - returns: IPValue
     */
    public func vectorize() -> IPValue {
        return IPValue(vectors: [x, y]) { CGPoint(x: $0[0], y: $0[1]) }
    }

    public static let components: Int = 2
}

/// CGRect Interpolatable extension.
extension CGRect: Interpolatable {
    /**
     Vectorize CGRect.
     
     - returns: IPValue
     */
    public func vectorize() -> IPValue {
        return IPValue(vectors: [origin.x, origin.y, size.width, size.height]) { CGRect(x: $0[0], y: $0[1], width: $0[2], height: $0[3]) }
    }

    public static let components: Int = 4
}

/// CGSize Interpolatable extension.
extension CGSize: Interpolatable {
    /**
     Vectorize CGSize.
     
     - returns: IPValue
     */
    public func vectorize() -> IPValue {
        return IPValue(vectors: [width, height]) { CGSize(width: $0[0], height: $0[1]) }
    }

    public static let components: Int = 2
}

/// Double Interpolatable extension.
extension Double: Interpolatable {
    /**
     Vectorize Double.
     
     - returns: IPValue
     */
    public func vectorize() -> IPValue {
        return IPValue(vectors: [CGFloat(self)]) { Double($0[0]) }
    }

    public static let components: Int = 1
}

/// Int Interpolatable extension.
extension Int: Interpolatable {
    /**
     Vectorize Int.
     
     - returns: IPValue
     */
    public func vectorize() -> IPValue {
        return IPValue(vectors: [CGFloat(self)]) { Int($0[0]) }
    }

    public static let components: Int = 1
}

/// NSNumber Interpolatable extension.
extension NSNumber: Interpolatable {
    /**
     Vectorize NSNumber.
     
     - returns: IPValue
     */
    public func vectorize() -> IPValue {
        return IPValue(vectors: [CGFloat(truncating: self)]) { $0[0] as NSNumber }
    }

    public static let components: Int = 1
}

#if os(iOS)
public typealias ColorType = UIColor
public typealias EdgeInsetsType = UIEdgeInsets
#else
public typealias ColorType = NSColor
public typealias EdgeInsetsType = NSEdgeInsets
#endif

/// ColorType Interpolatable extension.
extension ColorType: Interpolatable {
    /**
     Vectorize ColorType.
     
     - returns: IPValue
     */
    public func vectorize() -> IPValue {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0

        #if os(macOS)
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return IPValue(vectors: [red, green, blue, alpha]) { NSColor(calibratedRed: $0[0], green: $0[1], blue: $0[2], alpha: $0[3]) }
        #else
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return IPValue(vectors: [red, green, blue, alpha]) { ColorType(red: $0[0], green: $0[1], blue: $0[2], alpha: $0[3]) }
        }
        
        var white: CGFloat = 0
        if getWhite(&white, alpha: &alpha) {
            return IPValue(vectors: [white, alpha, 0.0, 0.0]) { ColorType(white: $0[0], alpha: $0[1]) }
        }
        
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0
        
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return IPValue(vectors: [hue, saturation, brightness, alpha]) { ColorType(hue: $0[0], saturation: $0[1], brightness: $0[2], alpha: $0[3]) }
        #endif
    }

    public static let components: Int = 4
}

/// EdgeInsetsType Interpolatable extension.
extension EdgeInsetsType: Interpolatable {
    /**
     Vectorize UIEdgeInsets.
     
     - returns: IPValue
     */
    public func vectorize() -> IPValue {
        return IPValue(vectors: [top, left, bottom, right]) { EdgeInsetsType(top: $0[0], left: $0[1], bottom: $0[2], right: $0[3]) }
    }

    public static let components: Int = 4
}

open class IPValue {
    var vectors: [CGFloat]
    private let interpolatableCreator: ([CGFloat]) -> Interpolatable
    
    public init(value: IPValue) {
        self.vectors = value.vectors
        self.interpolatableCreator = value.interpolatableCreator
    }
    
    public init(vectors: [CGFloat], interpolatableCreator: @escaping ([CGFloat]) -> Interpolatable) {
        self.vectors = vectors
        self.interpolatableCreator = interpolatableCreator
    }
    
    func toInterpolatable() -> Interpolatable {
        return interpolatableCreator(self.vectors)
    }
    
}


