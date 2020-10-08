//
//  airPodProScannerApp.swift
//  airPodProScanner
//
//  Created by shinp on 2020/10/07.
//

import SwiftUI
import CoreMotion

@main
struct airPodProScannerApp: App {
    let motion=CMHeadphoneMotionManager();
    let fps = 1000.0;
    
    var body: some Scene {
        WindowGroup {
        
            ContentView().onAppear(perform: onLoad)
        }
    }

    private func onLoad(){
        print("begin")
        guard motion.isDeviceMotionAvailable else { return }
        
        //motion.deviceMotionUpdateInterval = 1.0 / self.fps
        motion.startDeviceMotionUpdates(
            to: OperationQueue.current!,
            withHandler:
        {
            [self] motion,error  in
            guard let motion = motion,error == nil else { return }
            dumpData(data:motion)
        })
    }
    private func dumpData(data:CMDeviceMotion){
        print("TIMESTAMP:\(data.timestamp)") 
        print("X: \(rad2deg(rad:data.attitude.pitch))")
        print("Z: \(rad2deg(rad:data.attitude.roll))")
        print("Y: \(rad2deg(rad:data.attitude.yaw))")
    }

    private func rad2deg(rad:Double)->Double{
        return rad * 180 / Double.pi
    }

    init() {
        print("Start!")
    }
}
