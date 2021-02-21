//
//  UIRectCorner.swift
//  Example
//
//  Created by Carlos Duclos on 10/17/18.
//  Copyright © 2018 Carlos Duclos. All rights reserved.
//

import Foundation
import UIKit

public extension UIRectCorner {
    static var none: UIRectCorner { return [] }
    static var top: UIRectCorner { return [.topLeft, .topRight] }
    static var bottom: UIRectCorner { return [.bottomLeft, .bottomRight] }
    static var right: UIRectCorner { return [.topRight, .bottomRight] }
    static var left: UIRectCorner { return [.topLeft, .bottomLeft] }
    static var all: UIRectCorner { return [.topLeft, .bottomLeft, .topRight, .bottomRight] }
}
