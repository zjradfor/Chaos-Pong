/* Keep the Ball in the Circle!
   A pong-like game where the playing area is a circle and there is only one player.
   Be careful of the shining stars that will put the ball off course
 */

import SpriteKit
import UIKit
import PlaygroundSupport

let width = 640 as CGFloat
let height = 480 as CGFloat
let ballRadius = 10 as CGFloat
let ballVelocity = 300 as CGFloat

// Collision types
enum CollisionTypes: UInt32 {
    case Ball = 1
    case Boundary = 2
    case Star = 3
    case Player = 4
}

// SpriteKit scene
class gameScene: SKScene, SKPhysicsContactDelegate {
    
    var score = 0
    //Screen elements
    var ball: SKShapeNode?
    var player: SKShapeNode?
    var scoreLabel = SKLabelNode()
    var playButton = SKSpriteNode()
    
    // init first start
    override func sceneDidLoad() {
        super.sceneDidLoad()
    
        playMusic()
        createBackground()
        createCircle()
        createPlayer()
        createScoreLabel()
        createBoundaries()
        showPlayButton()
        welcomeText()
        createBall(position: CGPoint(x: width / 2, y: height / 2))
        self.physicsWorld.contactDelegate = self
    }
    
    // create score label
    func createScoreLabel() {
        scoreLabel.fontSize = 40
        scoreLabel.position = CGPoint(x: width - 100, y: height - 50)
        self.addChild(scoreLabel)
    }
    
    // background music for the game
    func playMusic() {
        let song = SKAction.playSoundFileNamed("02 Penguin Pong.mp3", waitForCompletion: false)
        self.run(song)
    }
    
    func welcomeText() {
        let welcome = SKLabelNode(text: "Keep the Ball in the Circle!")
        welcome.fontSize = 40
        welcome.position = CGPoint(x: width / 2, y: height - 100)
        self.addChild(welcome)
        
        welcome.run(SKAction.sequence([SKAction.wait(forDuration: 6.0), SKAction.removeFromParent()]))
    }
    
    func showPlayButton() {
        playButton = SKSpriteNode(imageNamed: "right")
        playButton.position = CGPoint(x: width / 2, y: height / 2)
        
        player!.run(SKAction.rotate(byAngle: 2.0 * CGFloat(Double.pi), duration: 1.5)) {
             self.addChild(self.playButton)
        }
       
        let pulseUp = SKAction.scale(to: 1.1, duration: 1.5)
        let pulseDown = SKAction.scale(to: 0.9, duration: 1.5)
        self.playButton.run(SKAction.repeatForever(SKAction.sequence([pulseUp, pulseDown])))
    }
    
    func createBackground() {
        let background = SKShapeNode(rect: CGRect(x: 0, y: 0, width: width, height: height))
        background.fillColor = UIColor(red: 160, green: 160, blue: 160, alpha: 1.0)
        self.addChild(background)
    }
    
    func createCircle() {
        let circle = SKShapeNode(circleOfRadius: 220)
        circle.position = CGPoint(x: width / 2, y: height / 2)
        circle.fillColor = UIColor(red: 255, green: 51, blue: 153, alpha: 1.0)
        circle.strokeColor = UIColor.black
        self.addChild(circle)
    }
    
    // create ball
    func createBall(position: CGPoint) {
        let physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
        ball = SKShapeNode(circleOfRadius: ballRadius)
        physicsBody.categoryBitMask = CollisionTypes.Ball.rawValue
        physicsBody.collisionBitMask = CollisionTypes.Boundary.rawValue | CollisionTypes.Ball.rawValue | CollisionTypes.Player.rawValue | CollisionTypes.Star.rawValue
        physicsBody.affectedByGravity = false
        physicsBody.restitution = 1
        physicsBody.linearDamping = 0
        physicsBody.velocity = CGVector(dx: ballVelocity, dy: 0)
        ball!.physicsBody = physicsBody
        ball!.position = position
        ball!.fillColor = SKColor.white
    }
    
    // create player
    func createPlayer() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: -220))
        path.addLine(to: CGPoint(x: 0, y: -210))
        path.addArc(withCenter: CGPoint.zero, radius: 210, startAngle: CGFloat(3.0 * (Double.pi / 2)), endAngle: CGFloat(0), clockwise: true)
        path.addLine(to: CGPoint(x: 220, y: 0))
        path.addArc(withCenter: CGPoint.zero, radius: 220, startAngle: CGFloat(0.0), endAngle: CGFloat(3.0 * (Double.pi / 2)), clockwise: false)
        
        player = SKShapeNode(path: path.cgPath)
        player!.position = CGPoint(x: size.width / 2, y: size.height / 2)
        player!.fillColor = .yellow
        player!.strokeColor = .yellow
        addChild(player!)
        
        let sectionBody = SKPhysicsBody(edgeLoopFrom: path.cgPath)
        sectionBody.affectedByGravity = false
        sectionBody.isDynamic = false
        sectionBody.categoryBitMask = CollisionTypes.Player.rawValue
        sectionBody.collisionBitMask = CollisionTypes.Ball.rawValue
        sectionBody.contactTestBitMask = CollisionTypes.Ball.rawValue
        player!.physicsBody = sectionBody
    }
    
    // create boundaries
    func createBoundaries() {
        createBoundary(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 1, height: height)))
        createBoundary(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: width, height: 1)))
        createBoundary(rect: CGRect(origin: CGPoint(x: 0, y: height - 1), size: CGSize(width: width, height: 1)))
        createBoundary(rect: CGRect(origin: CGPoint(x: width - 1, y: 0), size: CGSize(width: 1, height: height)))
    }
    
    func createBoundary(rect: CGRect) {
        let node = SKShapeNode(rect: rect)
        node.fillColor = SKColor.white
        node.physicsBody = getBoundaryPhysicsBody(rect: rect)
        self.addChild(node)
    }
    
    // hande boundary collisions
    func getBoundaryPhysicsBody(rect: CGRect) -> SKPhysicsBody {
        let physicsBody = SKPhysicsBody(rectangleOf: rect.size, center: CGPoint(x: rect.midX, y: rect.midY))
        physicsBody.affectedByGravity = false
        physicsBody.isDynamic = false
        physicsBody.collisionBitMask = CollisionTypes.Ball.rawValue
        physicsBody.categoryBitMask = CollisionTypes.Boundary.rawValue
        physicsBody.contactTestBitMask = CollisionTypes.Ball.rawValue
        return physicsBody
    }
    
    func addStar() {
        let star = SKSpriteNode(imageNamed: "star")
        let actualX = CGFloat.random(min: width / 2 - 80, max: width / 2 + 80)
        let actualY = CGFloat.random(min: height / 2 - 80, max: height / 2 + 80)
        star.position = CGPoint(x: actualX, y: actualY)
        star.size = CGSize(width: 30, height: 30)
        addChild(star)
        
        let physicsBody = SKPhysicsBody(circleOfRadius: 10)
        physicsBody.affectedByGravity = false
        physicsBody.isDynamic = false
        physicsBody.collisionBitMask = CollisionTypes.Ball.rawValue
        physicsBody.categoryBitMask = CollisionTypes.Star.rawValue
        star.physicsBody = physicsBody
        
        let starAction = SKAction.scale(to: 0.4, duration: 1.0)
        star.run(SKAction.sequence([starAction, SKAction.removeFromParent()]))
    }
    
    
    // start new game
    func startNewGame() {
        score = 0
        scoreLabel.text = "Score: " + "0"
        
        let startLabel = SKLabelNode(text: "Game Over")
        startLabel.position = CGPoint(x: width / 2, y: height / 2)
        startLabel.fontSize = 160
        self.addChild(startLabel)

        // countdown
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        
        startLabel.text = "3"
        startLabel.run(SKAction.sequence([fadeIn, fadeOut]), completion: {
            startLabel.text = "2"
            startLabel.run(SKAction.sequence([fadeIn, fadeOut]), completion: {
                startLabel.text = "1"
                startLabel.run(SKAction.sequence([fadeIn, fadeOut]), completion: {
                    startLabel.text = "0"
                    startLabel.run(SKAction.sequence([fadeIn, fadeOut]), completion: {
                        startLabel.removeFromParent()
                        self.ball!.position = CGPoint(x: 30, y: height / 2)
                        self.addChild(self.ball!)
                    })
                })
            })
        })
        player!.run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addStar), SKAction.wait(forDuration: 2.0)])))
        
    }
    
    // move player
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in:self)
            let centerOffset = CGPoint(x: location.x - view!.bounds.midX, y: location.y - view!.bounds.midY)
            let angle = atan2(centerOffset.y, centerOffset.x)

            player!.run(SKAction.rotate(toAngle: angle, duration: 0.2, shortestUnitArc: true))
            
            }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if (playButton.contains(touch.location(in: self))) {
                playButton.removeFromParent()
                startNewGame()
            }
        }
    }
    
    // game over
    func gameOver() {
        ball!.removeFromParent()
        player!.removeAllActions()
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.position = CGPoint(x: width / 2, y: height / 2)
        gameOverLabel.fontSize = 80
        self.addChild(gameOverLabel)
            
        // animation
        let rotateAction = SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)
        gameOverLabel.run(SKAction.repeat(rotateAction, count: 2))
        gameOverLabel.run(SKAction.scale(to: 0, duration: 2.5), completion: {
            gameOverLabel.removeFromParent()
            self.showPlayButton()
        })
    }
    
    // score
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == CollisionTypes.Player.rawValue || contact.bodyB.categoryBitMask == CollisionTypes.Player.rawValue {
            score += 1
            scoreLabel.text = "Score: " + String(score)
            ball?.fillColor = UIColor.random()
            ball?.strokeColor = UIColor.random()
            self.run(SKAction.playSoundFileNamed("Ting.mp3", waitForCompletion: false))
        }
        if contact.bodyA.categoryBitMask == CollisionTypes.Boundary.rawValue || contact.bodyB.categoryBitMask == CollisionTypes.Boundary.rawValue {
            gameOver()
            self.run(SKAction.playSoundFileNamed("Slip.mp3", waitForCompletion: false))
        }
        if contact.bodyA.categoryBitMask == CollisionTypes.Star.rawValue || contact.bodyB.categoryBitMask == CollisionTypes.Star.rawValue {
            self.run(SKAction.playSoundFileNamed("Clang.mp3", waitForCompletion: false))
        }
    }
    
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red: .random(), green: .random(), blue: .random(), alpha: 1.0)
    }
}

let sceneView = SKView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 640, height: 480)))
let scene = gameScene(size: sceneView.frame.size)
sceneView.presentScene(scene)

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
