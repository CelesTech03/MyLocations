//
//  UIImage+Resize.swift
//  MyLocations
//
//  Created by Celeste Urena on 11/2/22.
//

import UIKit

extension UIImage {
    
    /* Calculates how big the image should be in orer to fit inside the bounds rectangle. Then creates a new image context and draws the image into that */
    func resized(withBounds bounds: CGSize) -> UIImage {
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio = min(horizontalRatio, verticalRatio)
        let newSize = CGSize(
            width: size.width * ratio,
            height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
