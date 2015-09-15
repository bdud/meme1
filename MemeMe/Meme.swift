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

    static func samples() -> [Meme] {
        var memes = [Meme]()
        for i in 1...4 {
            memes.append(Meme(originalImage: UIImage(named: "proto-orig\(i)")!,
                memedImage: UIImage(named: "proto-memed\(i)")!,
                topText: "TOP", bottomText: "BOTTOM"))
        }
        return memes
    }

    func wrap() -> WrappedMeme {
        return WrappedMeme(meme:self)
    }
}

extension Meme: Equatable {}

func ==(lhs: Meme, rhs: Meme) -> Bool {
    return lhs.originalImage == rhs.originalImage &&
    lhs.memedImage == rhs.memedImage &&
    lhs.topText == rhs.topText &&
    lhs.bottomText == rhs.bottomText
}

// Needed for places where AnyObject is required, such as the
// userInfo parameter to postNotification

class WrappedMeme {
    let _wrapped: Meme

    init(meme: Meme) {
        _wrapped = meme
    }

    func unwrap() -> Meme {
        return _wrapped
    }
}