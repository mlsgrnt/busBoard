//
//  blobView.swift
//  
//
//  Created by Blydro Klonk on 8/13/18.
//

import UIKit

class blobView: UIView {
    var color: UIColor?
    var type: String?
    
    func setBlobType(color: UIColor, type: String) {
        self.color = color
        self.type = type
    }
    
    func drawStandardBlob() {
        //main square block
        let path = UIBezierPath()
        path.move(to: CGPoint(x: (self.frame.size.width/2) - 10, y: 0.0))
        path.addLine(to: CGPoint(x: (self.frame.size.width/2) - 10, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: (self.frame.size.width/2) + 10, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: (self.frame.size.width/2) + 10, y: 0.0))
        path.close()
        
        color?.setFill()
        path.fill()
    }
    func drawStartBlob() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: (self.frame.size.width/2) - 10, y: self.frame.size.height/2))
        path.addLine(to: CGPoint(x: (self.frame.size.width/2) - 10, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: (self.frame.size.width/2) + 10, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: (self.frame.size.width/2) + 10, y: self.frame.size.height/2))
        path.close()
        
        color?.setFill()
        path.fill()
    }
    func drawEndBlob() {
        //main square block
        let path = UIBezierPath()
        path.move(to: CGPoint(x: (self.frame.size.width/2) - 10, y: 0.0))
        path.addLine(to: CGPoint(x: (self.frame.size.width/2) - 10, y: self.frame.size.height/2))
        path.addLine(to: CGPoint(x: (self.frame.size.width/2) + 10, y: self.frame.size.height/2))
        path.addLine(to: CGPoint(x: (self.frame.size.width/2) + 10, y: 0.0))
        path.close()
        
        color?.setFill()
        path.fill()
    }
    
    func drawBlob() {
        //large outer circle
        let circle = generateCircle(circleSize: 18)
        
        UIColor.white.setFill()
        circle.fill()
        UIColor.black.setStroke()
        circle.stroke()
    }
    
    func generateCircle(circleSize: CGFloat) -> UIBezierPath {
        return UIBezierPath(ovalIn: CGRect(x: (self.frame.size.width/2) - (circleSize/2), y: (self.frame.size.height/2) - (circleSize/2), width: circleSize, height: circleSize))
    }


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        switch self.type {
            case "start":
                self.drawStartBlob()
            case "end":
                self.drawEndBlob()
            case "mid":
                self.drawStandardBlob()
            default:
                self.drawStandardBlob()
        }
        
        //draw the middle
        self.drawBlob()
    }
}
