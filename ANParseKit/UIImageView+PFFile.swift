//
//  UIImageView+PFFile.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/31/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Parse

extension UIImageView {
    public func setImageWithPFFile(file: PFFile) {
        self.setImageFrom(urlString: file.url!, animated: true)
    }
}