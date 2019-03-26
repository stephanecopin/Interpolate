//
//  Interpolatable.swift
//  Interpolate
//
//  Created by Roy Marmelstein on 10/04/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation
import QuartzCore
#if os(macOS)
import Cocoa
#else
import UIKit
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
     Vectorizes the type and returns and IPValue
     */
    static func interpolated(from vectors: [CGFloat]) -> Interpolatable
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
        return IPValue(vectors: [m11, m12, m13, m14, m21, m22, m23, m24, m31, m32, m33, m34, m41, m42, m43, m44]) { type(of: self).interpolated(from: $0) }
    }

    public static func interpolated(from vectors: [CGFloat]) -> Interpolatable {
        return CATransform3D(m11: vectors[0], m12: vectors[1], m13: vectors[2], m14: vectors[3], m21: vectors[4], m22: vectors[5], m23: vectors[6], m24: vectors[7], m31: vectors[8], m32: vectors[9], m33: vectors[10], m34: vectors[11], m41: vectors[12], m42: vectors[13], m43: vectors[14], m44: vectors[15])
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
        return IPValue(vectors: [a, b, c, d, tx, ty]) { type(of: self).interpolated(from: $0) }
    }

    public static func interpolated(from vectors: [CGFloat]) -> Interpolatable {
        return CGAffineTransform(a: vectors[0], b: vectors[1], c: vectors[2], d: vectors[3], tx: vectors[4], ty: vectors[5])
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
        return IPValue(vectors: [self]) { type(of: self).interpolated(from: $0) }
    }

    public static func interpolated(from vectors: [CGFloat]) -> Interpolatable {
        return vectors[0]
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
        return IPValue(vectors: [x, y]) { type(of: self).interpolated(from: $0) }
    }

    public static func interpolated(from vectors: [CGFloat]) -> Interpolatable {
        return CGPoint(x: vectors[0], y: vectors[1])
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
        return IPValue(vectors: [origin.x, origin.y, size.width, size.height]) { type(of: self).interpolated(from: $0) }
    }

    public static func interpolated(from vectors: [CGFloat]) -> Interpolatable {
        return CGRect(x: vectors[0], y: vectors[1], width: vectors[2], height: vectors[3])
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
        return IPValue(vectors: [width, height]) { type(of: self).interpolated(from: $0) }
    }

    public static func interpolated(from vectors: [CGFloat]) -> Interpolatable {
        return CGSize(width: vectors[0], height: vectors[1])
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
        return IPValue(vectors: [CGFloat(self)]) { type(of: self).interpolated(from: $0) }
    }

    public static func interpolated(from vectors: [CGFloat]) -> Interpolatable {
        return Double(vectors[0])
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
        return IPValue(vectors: [CGFloat(self)]) { type(of: self).interpolated(from: $0) }
    }

    public static func interpolated(from vectors: [CGFloat]) -> Interpolatable {
        return Int(vectors[0])
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
        return IPValue(vectors: [CGFloat(truncating: self)]) { type(of: self).interpolated(from: $0) }
    }

    public static func interpolated(from vectors: [CGFloat]) -> Interpolatable {
        return vectors[0] as NSNumber
    }

    public static let components: Int = 1
}

#if !os(macOS)
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
        return IPValue(vectors: [red, green, blue, alpha]) { NSColor.interpolated(from: $0) }
        #else
        _ = getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return IPValue(vectors: [red, green, blue, alpha]) { type(of: self).interpolated(from: $0) }
        #endif
    }

    public static func interpolated(from vectors: [CGFloat]) -> Interpolatable {
        #if os(macOS)
        return NSColor(calibratedRed: vectors[0], green: vectors[1], blue: vectors[2], alpha: vectors[3])
        #else
        return UIColor(red: vectors[0], green: vectors[1], blue: vectors[2], alpha: vectors[3])
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
        return IPValue(vectors: [top, left, bottom, right]) { type(of: self).interpolated(from: $0) }
    }

    public static func interpolated(from vectors: [CGFloat]) -> Interpolatable {
        return EdgeInsetsType(top: vectors[0], left: vectors[1], bottom: vectors[2], right: vectors[3])
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


