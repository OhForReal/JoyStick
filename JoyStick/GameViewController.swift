//
//  GameViewController.swift
//

import UIKit
import SpriteKit
import CoreMotion

class GameViewController: UIViewController {
    
    lazy var bleShield:BLE = (UIApplication.shared.delegate as! AppDelegate).bleShield
    
    let motionManager = CMMotionManager()
    
    var preRoll = 0.0
    var prePitch = 0.0
    var preYaw = 0.0
    
    var scene: GameScene? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scene = GameScene(size: self.view.bounds.size)
        scene?.backgroundColor = .white
        scene?.viewController = self
        
        let text = "a"
        let d = text.data(using: String.Encoding.utf8)!
        bleShield.write(d)
        
        if let skView = self.view as? SKView {
            skView.showsFPS = false
            skView.showsNodeCount = false
            skView.ignoresSiblingOrder = true
            skView.presentScene(scene)
        }
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates()
            motionManager.startDeviceMotionUpdates(
                to: OperationQueue.current!, withHandler: {
                    (deviceMotion, error) -> Void in

                    if(error == nil) {
                        self.handleDeviceMotionUpdate(deviceMotion: deviceMotion!)
                    } else {
                        //handle the error
                    }
            })
        }
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask  {
        return UIDevice.current.userInterfaceIdiom == .phone ? .allButUpsideDown : .all
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func handleDeviceMotionUpdate(deviceMotion:CMDeviceMotion) {
        let attitude = deviceMotion.attitude
        let roll = degrees(radians: attitude.roll)
        if (roll > preRoll + 50 || roll < preRoll - 50) {
            if (roll < preRoll) {
                let text = "1"
                let d = text.data(using: String.Encoding.utf8)!
                bleShield.write(d)
                self.scene?.panelLabel.text = "Move Forward"
            } else {
                let text = "2"
                let d = text.data(using: String.Encoding.utf8)!
                bleShield.write(d)
                self.scene?.panelLabel.text = "Move Back"
            }
            preRoll = roll
        }
        let pitch = degrees(radians: attitude.pitch)
        if (pitch > prePitch + 50 || pitch < prePitch - 50) {
            if (pitch > prePitch) {
                let text = "3"
                let d = text.data(using: String.Encoding.utf8)!
                bleShield.write(d)
                self.scene?.panelLabel.text = "Move Left"
            } else {
                let text = "4"
                let d = text.data(using: String.Encoding.utf8)!
                bleShield.write(d)
                self.scene?.panelLabel.text = "Move Right"
            }
            prePitch = pitch
        }
    }
    
    func degrees(radians:Double) -> Double {
        return 180 / .pi * radians
    }
    
    func radiansToDegrees(_ radians: Double) -> Double {
        return radians * (180.0 / Double.pi)
    }
}
