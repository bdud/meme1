//
//  Meme.swift
//  MemeMe
//
//  Created by Bill Dawson on 9/1/15.
//  Copyright (c) 2015 Bill Dawson. All rights reserved.
//

import UIKit

struct Meme {
    var originalImage: UIImage
    var memedImage: UIImage
    var topText: String
    var bottomText: String

    static func proto() -> Meme {
        return Meme(originalImage: UIImage(named: "proto-orig")!,
            memedImage: UIImage(named: "proto-memed")!,
            topText: "PROTO MEME TOP",
            bottomText: "PROTO MEME BOTTOM")
    }
}