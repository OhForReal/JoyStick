//
//  GameScene.swift
//
import SpriteKit


class GameScene: SKScene {
    
    var viewController: GameViewController!
    
    var curSpeed: Int = 0
    var direction: Int = 0
    var increaseSpeed: Bool = false
    var isAuto: Bool = false
    let image = UIImage(named: "jStick")
    let substrateImage = UIImage(named: "jSubstrate")
    let directionStick = 🕹(diameter: 250) // from Emoji
    let speedStick = AnalogJoystick(diameter: 200) // from Class
    let speedLabel = SKLabelNode(text: "Speed: 3")
    let panelLabel = SKLabelNode(text: "Manual Mode")
    
    let autoModeBtn = SKSpriteNode(imageNamed: "auto")
    let manualModeBtn = SKSpriteNode(imageNamed: "manual")
    let stopBtn = SKSpriteNode(imageNamed: "brake")
    
    override func didMove(to view: SKView) {
                
        directionStick.stick.image = image
        speedStick.stick.image = image
        directionStick.substrate.image = substrateImage
        speedStick.substrate.image = substrateImage
        
        backgroundColor = UIColor.white
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        directionStick.position = CGPoint(x: directionStick.radius + 15, y: directionStick.radius + 15)
        addChild(directionStick)
        
        speedStick.position = CGPoint(x: self.frame.maxX - speedStick.radius - 15, y:speedStick.radius + 15)
        addChild(speedStick)
        
        let selfHeight = frame.height
        let btnsOffset: CGFloat = 10
        
        speedLabel.fontSize = 20
        speedLabel.fontColor = UIColor.blue
        speedLabel.fontName = "Arial-BoldMT"
        speedLabel.horizontalAlignmentMode = .left
        speedLabel.verticalAlignmentMode = .top
        speedLabel.position = CGPoint(x: frame.midX - 100, y: selfHeight - btnsOffset * 5)
        
        panelLabel.fontSize = 20
        panelLabel.fontColor = UIColor.blue
        panelLabel.fontName = "Arial-BoldMT"
        panelLabel.horizontalAlignmentMode = .left
        panelLabel.verticalAlignmentMode = .top
        panelLabel.position = CGPoint(x: frame.midX + 100, y: selfHeight - btnsOffset * 5)
        
        directionStick.trackingHandler = { [unowned self] data in
            var radians = Double(data.angular)
            radians = radians > 0 ? radians : (2 * Double.pi + radians)
            let degrees = radians * 360 / (2 * Double.pi)
            if (!self.isAuto) {
                if (degrees >= 315 || degrees < 45 ) {
                    self.direction = 1
                } else if (degrees >= 45 && degrees < 135) {
                    self.direction = 3
                } else if (degrees >= 135 && degrees < 225) {
                    self.direction = 2
                } else if (degrees >= 225 && degrees < 315) {
                    self.direction = 4
                }
            }
        }
        
        directionStick.stopHandler = { [unowned self] in
            if (!self.isAuto) {
                switch self.direction {
                    case 1:
                        self.panelLabel.text = "Move Forward"
                        let text = "1"
                        let d = text.data(using: String.Encoding.utf8)!
                        self.viewController.bleShield.write(d)
                    case 2:
                        self.panelLabel.text = "Move Backward"
                        let text = "2"
                        let d = text.data(using: String.Encoding.utf8)!
                        self.viewController.bleShield.write(d)
                    case 3:
                        let text = "3"
                        self.panelLabel.text = "Turn Left"
                        let d = text.data(using: String.Encoding.utf8)!
                        self.viewController.bleShield.write(d)
                    case 4:
                        let text = "4"
                        self.panelLabel.text = "Turn Right"
                        let d = text.data(using: String.Encoding.utf8)!
                        self.viewController.bleShield.write(d)
                    default:
                        let text = "5"
                        let d = text.data(using: String.Encoding.utf8)!
                        self.viewController.bleShield.write(d)
                    
                }
            }
        }
        
        speedStick.trackingHandler = { [unowned self] jData in
            var radians = Double(jData.angular)
            radians = radians > 0 ? radians : (2 * Double.pi + radians)
            let degrees = radians * 360 / (2 * Double.pi)
            if (degrees >= 135 && degrees <= 225) {
                self.increaseSpeed = false;
            } else if(degrees >= 315 || degrees <= 45){
                self.increaseSpeed = true
            }
        }
        
        speedStick.stopHandler = { [unowned self] in
            if (!self.isAuto) {
                if(self.increaseSpeed) {
                    if (self.curSpeed < 3) {
                        self.curSpeed = self.curSpeed + 1
                    }
                } else {
                    if (self.curSpeed > 0) {
                        self.curSpeed = self.curSpeed - 1
                    }
                }
                self.speedLabel.text = "Speed: " + String(self.curSpeed)
                let text = "l" + String(self.curSpeed)
                let d = text.data(using: String.Encoding.utf8)!
                self.viewController.bleShield.write(d)
            }
        }
        
        addChild(panelLabel)
        addChild(speedLabel)

        autoModeBtn.size = CGSize(width: 80, height: 80)
        autoModeBtn.position =  CGPoint(x: frame.midX - 50, y: frame.midY)
        addChild(autoModeBtn)
        
        manualModeBtn.size = CGSize(width: 80, height: 80)
        manualModeBtn.position =  CGPoint(x: frame.midX + 100, y: frame.midY)
        addChild(manualModeBtn)
        
        stopBtn.size = CGSize(width: 80, height: 80)
        stopBtn.position =  CGPoint(x: frame.midX + 20, y: frame.midY - 100)
        addChild(stopBtn)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        if let touch = touches.first {
            let node = atPoint(touch.location(in: self))
            switch node {
            case autoModeBtn:
                self.panelLabel.text = "Auto Mode"
                self.speedLabel.text = "Speed: 3"
                self.isAuto = true
                let text = "auto"
                let d = text.data(using: String.Encoding.utf8)!
                self.viewController.bleShield.write(d)
            case manualModeBtn:
                self.panelLabel.text = "Manual Mode"
                self.speedLabel.text = "Speed: 3"
                self.isAuto = false
                self.curSpeed = 3
                let text = "manual"
                let d = text.data(using: String.Encoding.utf8)!
                self.viewController.bleShield.write(d)
            case stopBtn:
                let text = "5"
                let d = text.data(using: String.Encoding.utf8)!
                self.viewController.bleShield.write(d)
            default:
                print("default")
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
}

extension UIColor {
    
    static func random() -> UIColor {
        return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1)
    }
}
