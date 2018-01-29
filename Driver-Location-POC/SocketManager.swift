//
//  ViewController.swift
//  Driver-Location-POC
//
//  Created by Vinayak Kini on 12/28/17.
//  Copyright © 2017 Vinayak Kini. All rights reserved.
//


import UIKit

class Socket: NSObject {
    
    var inputStream: InputStream!
    var outputStream: OutputStream!
    var username = ""
    
    func setupNetworkCommunication() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, "localhost" as CFString, 60, &readStream, &writeStream)
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        outputStream.delegate = self
        
        inputStream.schedule(in: .main, forMode: .commonModes)
        outputStream.schedule(in: .main, forMode: .commonModes)
        
        inputStream.open()
        outputStream.open()
    }
    
    func join(username: String) {
        guard let data = "iam:\(username)".data(using: .ascii) else { return }
        self.username = username
        _ = data.withUnsafeBytes { outputStream.write($0, maxLength: data.count) }
    }
    
    func send(message: String) {
        guard let data = "msg:\(message)".data(using: .ascii) else { return }
        _ = data.withUnsafeBytes { outputStream.write($0, maxLength: data.count) }
    }
    
    func stopSession() {
        inputStream.close()
        outputStream.close()
    }
}

extension Socket: StreamDelegate {
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            print("new message received")
        case Stream.Event.endEncountered:
            stopSession()
        case Stream.Event.errorOccurred:
            print("error occurred")
        case Stream.Event.hasSpaceAvailable:
            print("has space available")
        default:
            print("some other event...")
            
        }
    }
}
