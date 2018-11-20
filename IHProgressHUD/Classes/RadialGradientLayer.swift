//MIT License
//
//Original Work Copyright (c) 2011-2018 Sam Vermette, Tobias Tiemerding and contributors.
//Modified Work Copyright (c) 2018 Ibrahim Hassan
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.
//
//  Converted to Swift 4 by Swiftify v4.2.29618 - https://objectivec2swift.com/
//
//  IndefiniteAnimatedView.swift
//  SVProgressHUD, https://github.com/SVProgressHUD/SVProgressHUD
//
//  Original Copyright (c) 2014-2018 Guillaume Campagna. All rights reserved.
//  Modified Copyright © 2018 Ibrahim Hassan. All rights reserved.
//

import QuartzCore

class RadialGradientLayer: CALayer {
    var gradientCenter = CGPoint.zero
    override func draw(in context: CGContext) {
        super.draw(in: context)
        let locationsCount = 2
        let locations : [CGFloat] = [0.0, 1.0]
        let colors : [CGFloat] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.75]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        if let gradient = CGGradient.init(colorSpace: colorSpace, colorComponents: colors, locations: locations, count: locationsCount) {
            let radius = min(bounds.size.width, bounds.size.height)
            
            context.drawRadialGradient(gradient, startCenter: gradientCenter, startRadius: 0, endCenter: gradientCenter, endRadius: radius, options: CGGradientDrawingOptions.drawsAfterEndLocation)
        }
    }
}
