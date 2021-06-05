//
//  AppDelegate.swift
//  DominantColor
//
//  Created by Indragie on 12/18/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

import Cocoa
import DominantColor

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, DragAndDropImageViewDelegate {
    @IBOutlet var window: NSWindow!
    @IBOutlet var box1: NSBox!
    @IBOutlet var box2: NSBox!
    @IBOutlet var box3: NSBox!
    @IBOutlet var box4: NSBox!
    @IBOutlet var box5: NSBox!
    @IBOutlet var box6: NSBox!
    @IBOutlet var imageView: DragAndDropImageView!

    var image: NSImage?

    func applicationDidFinishLaunching(aNotification _: NSNotification) {}

    // MARK: DragAndDropImageViewDelegate

    @IBAction func runBenchmark(_: NSButton) {
        if let image = image {
            let nValues: [Int] = [100, 1000, 2000, 5000, 10000]
            let CGImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
            for n in nValues {
                let ns = dispatch_benchmark(5) {
                    _ = dominantColorsInImage(CGImage, maxSampledPixels: n)
                }
                print("n = \(n) averaged \(ns / 1_000_000) ms")
            }
        }
    }

    func dragAndDropImageView(imageView: DragAndDropImageView, droppedImage image: NSImage?) {
        if let image = image {
            imageView.image = image

            self.image = image
            let colors = image.dominantColors()
            let boxes = [box1, box2, box3, box4, box5, box6]

            for box in boxes {
                box?.fillColor = .clear
            }
            for i in 0 ..< min(colors.count, boxes.count) {
                boxes[i]?.fillColor = colors[i]
            }
        }
    }
}
