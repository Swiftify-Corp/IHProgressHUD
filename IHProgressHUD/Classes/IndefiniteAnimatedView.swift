//
//  Converted to Swift 4 by Swiftify v4.2.29618 - https://objectivec2swift.com/
//
//  IndefiniteAnimatedView.swift
//  SVProgressHUD, https://github.com/SVProgressHUD/SVProgressHUD
//
//  Original Copyright (c) 2014-2018 Guillaume Campagna. All rights reserved.
//  Modified Copyright © 2018 Ibrahim Hassan. All rights reserved.
//

import UIKit

class IndefiniteAnimatedView : UIView {
    
    private var activityIndicator : UIActivityIndicatorView?
    private var strokeThickness : CGFloat?
    private var strokeColor : UIColor?
    private var indefiniteAnimatedGradientLayer : CAGradientLayer?
    private var radius : CGFloat?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if self.superview != nil {
            layoutAnimatedLayer()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Setter Functions
extension IndefiniteAnimatedView {
    
    func setIndefinite(radius: CGFloat) {
        if (self.radius != radius) {
            self.radius = radius
            
            getIndefiniteAnimatedGradientLayer().removeFromSuperlayer()
            indefiniteAnimatedGradientLayer = nil

            if superview != nil {
                layoutAnimatedLayer()
            }
        }
    }
    
    func setIndefinite(strokeThickness : CGFloat) {
        self.strokeThickness = strokeThickness
        
        getIndefiniteAnimatedGradientLayer().removeFromSuperlayer()
        indefiniteAnimatedGradientLayer = nil
        
        if superview != nil {
            layoutAnimatedLayer()
        }
    }
    
    func setIndefinite(strokeColor: UIColor) {
        self.strokeColor = strokeColor
        
        getIndefiniteAnimatedGradientLayer().removeFromSuperlayer()
        indefiniteAnimatedGradientLayer = nil
        
        if superview != nil {
            layoutAnimatedLayer()
        }
    }
    
}

//MARK: - Getter Functions
extension IndefiniteAnimatedView {
    private func getIndefiniteAnimatedGradientLayer() -> CAGradientLayer {
        if indefiniteAnimatedGradientLayer != nil {
            return indefiniteAnimatedGradientLayer!
        } else {
            let localRingRadius: CGFloat = radius ?? 18
            let localStrokeThickness: CGFloat = strokeThickness ?? 2
            let localStrokeColor: UIColor = strokeColor ?? UIColor.black
            let arcCenter = CGPoint(x: localRingRadius + localStrokeThickness / 2 + 5, y: localRingRadius + localStrokeThickness / 2 + 5)
            
            let smoothedPath = UIBezierPath(arcCenter: arcCenter, radius: localRingRadius, startAngle: .pi * 3 / 2, endAngle: -0.5 * .pi, clockwise: false)
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.contentsScale = UIScreen.main.scale
            shapeLayer.frame = CGRect(x: 0.0, y: 0.0, width: arcCenter.x * 2, height: arcCenter.y * 2)
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = strokeColor?.cgColor
            shapeLayer.lineWidth = localStrokeThickness
            shapeLayer.lineCap = .round
            shapeLayer.lineJoin = .round
            shapeLayer.path = smoothedPath.cgPath
            shapeLayer.strokeStart = 0.4
            shapeLayer.strokeEnd = 1.0
            
            indefiniteAnimatedGradientLayer = CAGradientLayer()
            indefiniteAnimatedGradientLayer?.startPoint = CGPoint(x: 0.5, y: 0.0)
            indefiniteAnimatedGradientLayer?.endPoint = CGPoint(x: 0.5, y: 1.0)
            indefiniteAnimatedGradientLayer?.frame = shapeLayer.bounds
            indefiniteAnimatedGradientLayer?.colors = [localStrokeColor.withAlphaComponent(0).cgColor, localStrokeColor.withAlphaComponent(0.5).cgColor, localStrokeColor.cgColor]
            indefiniteAnimatedGradientLayer?.locations = [NSNumber(value: 0.25), NSNumber(value: 0.5), NSNumber(value: 1.0)]
            indefiniteAnimatedGradientLayer?.mask = shapeLayer
            
            let animationDuration = TimeInterval(1)
            let linearCurve = CAMediaTimingFunction(name: .linear)
            let animation = CABasicAnimation(keyPath: "transform.rotation")
            animation.fromValue = 0
            animation.toValue = CGFloat.pi * 2
            animation.duration = animationDuration
            animation.timingFunction = linearCurve
            animation.isRemovedOnCompletion = false
            animation.repeatCount = .infinity
            animation.fillMode = .forwards
            animation.autoreverses = false
            indefiniteAnimatedGradientLayer?.add(animation, forKey: "progress")
        }
        return self.indefiniteAnimatedGradientLayer!
    }
}

// MARK: - ActivityIndicatorView Functions

extension IndefiniteAnimatedView {
    
    func removeAnimationLayer() {
        for view in self.subviews {
            if let activityView = view as? UIActivityIndicatorView {
                activityView.removeFromSuperview()
            }
        }
        getIndefiniteAnimatedGradientLayer().removeFromSuperlayer()
    }
    
    func startAnimation() {
        if let activityIndicator = activityIndicator {
            self.addSubview(activityIndicator)
            activityIndicator.frame = CGRect.init(x: 8, y: 8, width: self.frame.size.width - 16, height: self.frame.size.height - 16)
        }
    }
    
    func stopActivityIndicator() {
        activityIndicator?.stopAnimating()
    }
    
    func setActivityIndicator(color: UIColor) {
        activityIndicator = UIActivityIndicatorView.init(style: .whiteLarge)
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.startAnimating()
        activityIndicator?.color = color
    }
}
//MARK: -
extension IndefiniteAnimatedView {
    override func willMove(toSuperview newSuperview: UIView?) {
        if let _ = newSuperview {
            layoutAnimatedLayer()
        } else {
            getIndefiniteAnimatedGradientLayer().removeFromSuperlayer()
            indefiniteAnimatedGradientLayer = nil
        }
    }
    
    private func layoutAnimatedLayer() {
        let calayer = getIndefiniteAnimatedGradientLayer()
        self.layer.addSublayer(calayer)
        let widthDiff: CGFloat = bounds.width - layer.bounds.width
        let heightDiff: CGFloat = bounds.height - layer.bounds.height
        let xPos = bounds.width - layer.bounds.width / 2 - widthDiff / 2
        let yPos = bounds.height - layer.bounds.height / 2 - heightDiff / 2
        calayer.position = CGPoint.init(x: xPos, y: yPos)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let localRadius : CGFloat = radius ?? 18
        let localStrokeThickness : CGFloat = strokeThickness ?? 2
        for view in self.subviews {
            if let _ = view as? UIActivityIndicatorView {
                return CGSize.init(width: 50, height: 50)
            }
        }
        return CGSize.init(width: (localRadius + localStrokeThickness / 2 + 5) * 2, height: (localRadius + localStrokeThickness / 2 + 5) * 2)
    }
    
    private func loadImageBundle(named imageName:String) -> UIImage? {
        var imageBundle = Bundle.init(for: IndefiniteAnimatedView.self)
        if let resourcePath = imageBundle.path(forResource: "IHProgressHUD", ofType: "bundle") {
            if let resourcesBundle = Bundle(path: resourcePath) {
                imageBundle = resourcesBundle
            }
        }
        
        return (UIImage(named: imageName, in: imageBundle, compatibleWith: nil))
    }
}

