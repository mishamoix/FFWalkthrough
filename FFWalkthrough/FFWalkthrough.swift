//
//  FFWalkthrough.swift
//  FFWalkthrough
//
//  Created by Mikhail Malyshev on 01.10.17.
//  Copyright © 2017 Mikhail Malyshev. All rights reserved.
//

import UIKit
import Foundation

public enum FFWalkthroughQuadrant {
    case autoselect
    case topLeft
    case topRight
    case bottomRight
    case bottomLeft
    case topCenter
    case bottomCenter

}


public extension UIView {
    
    public func snapshotImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImage
    }
    
    public func snapshotView() -> UIImageView? {
        if let snapshotImage = snapshotImage() {
            return UIImageView(image: snapshotImage)
        } else {
            return nil
        }
    }
}


public class FFWalkthroughModel {
    
    public enum WalkthroughCuatomPrepareTypes {
        case before
        case after
        case none
    }
    
    public typealias CustomPrepare = (FFWalkthroughModel, UIView) -> ()
    
    public var highlightedView: UIView
    public var title: String?
    public var titleLocation: FFWalkthroughQuadrant = .autoselect
    public var customViews: [UIView]
    
    
    public var customPrepare: CustomPrepare?
    public var customPrepareType: WalkthroughCuatomPrepareTypes = .none
    
    
    public init(highlighted view: UIView, custom views: [UIView] = [], title: String? = nil, custom prepare: CustomPrepare? = nil){
        self.highlightedView = view
        self.title = title
        self.customViews = views
        self.customPrepare = prepare
        
        if views.count != 0 {
            self.customPrepareType = .before
        }
    }
}


public class FFWalkthroughView: UIView {
    
    public typealias Completion = (()->())
    
    public var elements: [FFWalkthroughModel] = []
    public var rootView: UIView?
    public var completion: Completion?
    public var needRemoveAfterComlete = true
    
    public var blurRadius: CGFloat = 3
    public var blurColor = UIColor(white: 0.11, alpha: 0.73)
    public var saturationDeltaFactorBlur: CGFloat = 1.8
    public var animationDuration: Double = 0.5
    
    
    public init(root view: UIView, elements: [FFWalkthroughModel], completion: Completion? = nil){
        super.init(frame: view.bounds)

        self.rootView = view
        self.elements = elements
        self.completion = completion
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.rootView = nil
        super.init(coder: aDecoder)
    }
    
    
    public func present(){
        if self.rootView == nil {
            fatalError("No rootView")
        }
        self.buildView()
        
        self.alpha = 0
        self.rootView?.addSubview(self)
        
        
        UIView.animate(withDuration: self.animationDuration, animations: {
            self.alpha = 1
        })
        
    }
    
    public class func quickDisplay(root view: UIView, highlighted hlView: UIView, text: String, location: FFWalkthroughQuadrant = .autoselect) {
        let model = FFWalkthroughModel(highlighted: hlView, custom: [], title: text)
        model.titleLocation = location
        let wt = FFWalkthroughView(root: view, elements: [model])
        wt.present()
    }
    
    private func buildView(){
        self.backgroundColor = UIColor(white: 1, alpha: 0)
        let snap = self.rootView!.snapshotView()!
        
        snap.image = snap.image!.applyBlur(withRadius: self.blurRadius, tintColor: self.blurColor, saturationDeltaFactor: saturationDeltaFactorBlur, maskImage: nil)
        
        self.addSubview(snap)
        
        
        for element in elements {
            
            let highLighted = element.highlightedView.snapshotView()!
            highLighted.frame = element.highlightedView.convert(element.highlightedView.bounds, to: self.rootView!)
            self.addSubview(highLighted)
            if element.customPrepareType == .before {
                element.customPrepare?(element, self)
                continue
            }
            
            if let title = element.title {
                self.addTitle(to: highLighted, with: title, quadrant: element.titleLocation)
            }
            
            for v in element.customViews {
                self.addSubview(v)
            }
            
            if element.customPrepareType == .after {
                element.customPrepare?(element, self.rootView!)
            }
        }
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(FFWalkthroughView.tappedOnScreen))
        self.addGestureRecognizer(recognizer)

    }
    
    private func addTitle(to view: UIView, with text: String, quadrant: FFWalkthroughQuadrant){
        let maxWidth: CGFloat = 200
        let maxHeight: CGFloat = 100
        let delta: CGFloat = 4
        
        let size = CGSize(width: maxWidth + delta, height: maxHeight + delta)
        let frame = view.frame
        var quadrantType: FFWalkthroughQuadrant = .autoselect
        
        if quadrant != .autoselect {
            quadrantType = quadrant
        }
        
        let toTop = frame.minY
        let toBottom = self.rootView!.frame.height - frame.maxY
        let toLeft = frame.minX
        let toRight = self.rootView!.frame.width - frame.maxX
        
        let arrow: AFCurvedArrowView = AFCurvedArrowView()
        
        let maxLabelHeight: CGFloat = 50
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: maxWidth, height: maxLabelHeight))
        arrow.addSubview(label)

        label.text = text
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = UIColor.white
        
        arrow.arrowHeadWidth = 5
        arrow.arrowHeadHeight = 10
        
        if quadrantType == .autoselect {
            // Separate on 6 quadrant and find appropriate by clockwise
            if toTop > size.height && toLeft > size.width {
                quadrantType = .topLeft
                
            } else if toTop > size.height && toRight > size.width {
                quadrantType = .topRight
                
            } else if toBottom > size.height && toRight > size.width {
                quadrantType = .bottomRight
                
            } else if toBottom > size.height && toLeft > size.width {
                quadrantType = .bottomLeft
                
            } else if toTop > size.height {
                quadrantType = .topCenter
                
            } else {
                quadrantType = .bottomCenter
            }
        }
        
        
        switch quadrantType {
        case .topLeft:
            arrow.frame = CGRect(x: toLeft - maxWidth, y: toTop - maxHeight, width: maxWidth, height: maxHeight)
            
            arrow.arrowHead = CGPoint(x: 1, y: 1)
            arrow.arrowTail = CGPoint(x: (label.frame.width / 2.0) / maxWidth, y: (label.frame.height + delta) / maxHeight)
            
            arrow.controlPoint1 = CGPoint(x: (label.frame.width / 2.0) / maxWidth, y: 0.7)
            

            break
        case .topRight:
            arrow.frame = CGRect(x: view.frame.maxX, y: toTop - maxHeight, width: maxWidth, height: maxHeight)
            
            let tailX = (label.frame.width / 2.0 + label.frame.minX) / maxWidth
            
            arrow.arrowHead = CGPoint(x: 0, y: 1)
            arrow.arrowTail = CGPoint(x: tailX, y: (label.frame.height + delta) / maxHeight)
            
            arrow.controlPoint1 = CGPoint(x: tailX, y: 0.7)
            break
            
        case .bottomRight:
            label.frame.origin = CGPoint(x: 0, y: maxHeight - maxLabelHeight)
            
            arrow.frame = CGRect(x: view.frame.maxX, y: view.frame.maxY, width: maxWidth, height: maxHeight)
            
            let tailX = (label.frame.width / 2.0) / maxWidth
            
            arrow.arrowHead = CGPoint(x: 0, y: 0)
            arrow.arrowTail = CGPoint(x: tailX, y: (maxHeight - maxLabelHeight - delta) / maxHeight)
            
            arrow.controlPoint1 = CGPoint(x: 0.2, y: 0.4)
            break
        case .bottomLeft:
            label.frame.origin = CGPoint(x: 0, y: maxHeight - maxLabelHeight)
            
            arrow.frame = CGRect(x: view.frame.minX - maxWidth, y: view.frame.maxY, width: maxWidth, height: maxHeight)
            
            let tailX = (label.frame.width / 2.0) / maxWidth
            
            arrow.arrowHead = CGPoint(x: 1, y: 0)
            arrow.arrowTail = CGPoint(x: tailX, y: (maxHeight - maxLabelHeight - delta) / maxHeight)
            
            arrow.controlPoint1 = CGPoint(x: 0.7, y: 0.4)
            break
        case .topCenter:
            arrow.frame = CGRect(x: view.frame.maxX, y: toTop - maxHeight, width: maxWidth, height: maxHeight)
            arrow.center = CGPoint(x: view.center.x, y: arrow.center.y)
            
            let tailX = (label.frame.width / 2.0 + label.frame.minX) / maxWidth
            
            arrow.arrowHead = CGPoint(x: 0.5, y: 1)
            arrow.arrowTail = CGPoint(x: tailX, y: (label.frame.height + delta) / maxHeight)
            arrow.controlPoint1 = CGPoint(x: 0.6, y: 0.8)
            
            break
        case .bottomCenter:
            label.frame.origin = CGPoint(x: 0, y: maxHeight - maxLabelHeight)
            
            arrow.frame = CGRect(x: view.frame.maxX, y: view.frame.maxY + delta * 2, width: maxWidth, height: maxHeight)
            arrow.center = CGPoint(x: view.center.x, y: arrow.center.y)
            
            
            let tailX = (label.frame.width / 2.0) / maxWidth
            
            arrow.arrowHead = CGPoint(x: 0.5, y: 0)
            arrow.arrowTail = CGPoint(x: tailX, y: (maxHeight - maxLabelHeight - delta) / maxHeight)
            
            arrow.controlPoint1 = CGPoint(x: 0.45, y: 0.4)
            
            break
            
        default:
            break
        }

        arrow.curveType = .quadratic
        arrow.lineWidth = 2
        self.addSubview(arrow)

    }
    
    @objc fileprivate func tappedOnScreen(){
        if let completion = self.completion{
            completion()
            self.removeFromSuperview()
        } else if self.needRemoveAfterComlete {
            
            UIView.animate(withDuration: self.animationDuration, animations: { 
                self.alpha = 0
            }, completion: { (completed) in
                if completed {
                    self.removeFromSuperview()
                }
            })

        }
    }
}
