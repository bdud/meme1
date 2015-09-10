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
        // Sample meme
        for m in Meme.protos() {
            saveMeme(m)
        }

        return true
    }

    func saveMeme(meme: Meme) {
        memes.append(meme)
    }

}

