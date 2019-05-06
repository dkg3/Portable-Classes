//
//  LinkedTextView.swift
//  PortableClasses
//
//  Created by david krauskopf-greene on 5/5/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit

class LinkedTextView: UITextView {

//    override func draw(_ rect: CGRect) {
//        // Get the current drawing context
//        let context: CGContext = UIGraphicsGetCurrentContext()!
//
//        // Set the line color and width
//        context.setStrokeColor(UIColor(red:0.0, green:0.0, blue:0.0, alpha:0.2).cgColor)
//        context.setLineWidth(1.0);
//
//        // Start a new Path
//        context.beginPath()
//
//        //Find the number of lines in our textView + add a bit more height to draw lines in the empty part of the view
//        let numberOfLines = ((self.contentSize.height + self.bounds.size.height) / self.font!.lineHeight) / 2
//
//        // Set the line offset from the baseline.
//        let baselineOffset:CGFloat = 5.0
//
//        // Iterate over numberOfLines and draw a line in the textView
//        for x in 1..<Int(numberOfLines) {
//            //0.5f offset lines up line with pixel boundary
//            context.move(to: CGPoint(x: self.bounds.origin.x, y: (self.font!.lineHeight * 2) * CGFloat(x) + baselineOffset))
//            context.addLine(to: CGPoint(x: CGFloat(self.bounds.size.width), y: (self.font!.lineHeight * 2) * CGFloat(x) + baselineOffset))
//        }
//
//        //Close our Path and Stroke (draw) it
//        context.closePath()
//        context.strokePath()
//    }

}
