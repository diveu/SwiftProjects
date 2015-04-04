//
//  FaceView.swift
//  Happiness
//
//  Created by Иван on 31.03.15.
//  Copyright (c) 2015 KKK. All rights reserved.
//

import UIKit

class FaceView: UIView {

    var lineWidth: CGFloat = 3 { didSet{ setNeedsDisplay() }}
    var scale: CGFloat = 0.90
    var color: UIColor = UIColor.blueColor() { didSet{ setNeedsDisplay() }}
    var faceCenter: CGPoint{
        return convertPoint(center, fromView: superview)
    }
    var faceRadius: CGFloat{
        return min(bounds.size.width, bounds.size.height) / 2 * scale
    }
    
    //private struct Scaling{
      //  static let
    //}
    
    override func drawRect(rect: CGRect) {
        var facePath = UIBezierPath(arcCenter: faceCenter, radius: faceRadius, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        facePath.lineWidth = lineWidth
        color.set()
        facePath.stroke()
    }
}
