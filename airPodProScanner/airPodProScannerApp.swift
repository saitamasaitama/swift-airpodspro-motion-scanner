//
//  airPodProScannerApp.swift
//  airPodProScanner
//
//  Created by shinp on 2020/10/07.
//
import Foundation
import SwiftUI
import CoreMotion
import Network

//JSON変換用
struct motiondata:Codable {
    public static func FromMotion(mot:CMDeviceMotion)->motiondata{
        
        let result=motiondata(
            timestamp: mot.timestamp,
            attitude:Attitude(
                yaw : rad2deg(rad: mot.attitude.yaw) ,
                roll: rad2deg(rad: mot.attitude.roll) ,
                pitch: rad2deg(rad: mot.attitude.pitch) 
            )
        )
        return result
    }
    public let timestamp:Double;
    public let attitude:Attitude;
    
}

struct Attitude:Codable {
    public let yaw:Double;
    public let roll:Double;
    public let pitch:Double;
}
func rad2deg(rad:Double)->Double{
    return rad * 180 / Double.pi
}

@main
struct airPodProScannerApp: App {
    let airpods=CMHeadphoneMotionManager();
    let connection = NWConnection(
	host: "192.168.50.23",
	port: 7777, 
	using: NWParameters.udp
    )
    var running=true
     var body: some Scene {
        WindowGroup {
            ContentView().onAppear(perform: onLoad)
        }
    }

    private func onLoad(){
        print("onLoad")
        
        /*
        connection.stateUpdateHandler = { (state: NWConnection.State) in
            guard state != .ready else { return }
            print("connection is ready")
        }
         */
        
        print("ready AirPods")
        let connectionQueue = DispatchQueue(label: "com.shu223.NetworkPlayground.sender")
        connection.start(queue: connectionQueue)
        
        guard airpods.isDeviceMotionAvailable else { return }
        //motion.deviceMotionUpdateInterval = 1.0 / self.fps
        airpods.startDeviceMotionUpdates(
            to: OperationQueue.current!,
            withHandler:dumpData
        )
        
    }

    private func dumpData(mot:Optional<CMDeviceMotion>,err:Optional<Error>){
        
        
        guard let data:CMDeviceMotion = mot , err == nil else { return }
        
        let json:Data=try! JSONEncoder().encode(motiondata.FromMotion(mot: data));
        let jsontext:String = String(data:json,encoding: .utf8)!
        print(jsontext);
        /*
        print("TIMESTAMP:\(data.timestamp)")
        print("YAW: \(String(format: "%5.2f",rad2deg(rad:data.attitude.yaw)))")
        print("PITCH: \(String(format: "%5.2f",rad2deg(rad:data.attitude.pitch)))")
        print("ROLL: \(String(format: "%5.2f",rad2deg(rad:data.attitude.roll)))")
        */

        //UDP送信する
        connection.send(content: json,
            completion: NWConnection.SendCompletion.contentProcessed{
            (error: NWError?) in
            print("送信")
        })
    }

    private func data2bytes(){
    }
    
    private func sendUDP(){
    }

    private func sendMessage() {

    	let data = "Example Send Data".data(using: .utf8)
    	let completion = NWConnection.SendCompletion.contentProcessed { 
		(error: NWError?) in
        	print("送信完了")
    	}
    	self.connection.send(content: data, completion: completion)
        startConnection()
    }
    
    func startConnection() {
        let myQueue = DispatchQueue(label: "ExampleNetwork")
       connection.stateUpdateHandler = { (newState) in
            switch(newState) {
            case .ready:
                print("ready")
                sendMessage()
            case .waiting(let error):
                print("waiting")
                print(error)
            case .failed(let error):
                print("failed")
                print(error)
            default:
                print("defaults")
                break
            }
        }
        connection.start(queue: myQueue)
    }


    init() {
    }
}
//var running = true
/*
*/
