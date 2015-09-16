//
//  AppDelegate.swift
//  MemeMe
//
//  Created by Bill Dawson on 8/25/15.
//  Copyright (c) 2015 Bill Dawson. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var memes: [Meme] = []


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // TODO remove
        // Sample memes
        for m in Meme.samples() {
            saveNewMeme(m)
        }

        return true
    }

    func saveNewMeme(meme: Meme) {
        memes.append(meme)
    }

    func updateExistingMeme(existingMeme: Meme, withNewMeme updatedMeme: Meme) {
        if let index = find(memes, existingMeme) {
            memes.removeAtIndex(index)
            memes.insert(updatedMeme, atIndex: index)
        }
    }

    func deleteMeme(meme: Meme) {
        if let index = find(memes, meme) {
            memes.removeAtIndex(index)
        }
    }

}

