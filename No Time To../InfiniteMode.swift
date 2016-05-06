//
//  InfiniteMode.swift
//  No Time To...
//
//  Created by Justin Buergi on 5/3/16.
//  Copyright © 2016 Justking Games. All rights reserved.
//

import Foundation
import SpriteKit

class infiniteMode: SKScene {
    let lowEnemyZPosition: CGFloat = 6
    let midEnemyZPosition: CGFloat = 7
    let highEnemyZPosition: CGFloat = 5
    
    var player: Player!
    var state: StateHolder = StateHolder()
    
    var baseSwipe: primeSwipe = primeSwipe(imageNamed: "baseChoices.png")

    
    var currentLevel: Int = 1
    var currentRound: Int = 1
    
    var timeSinceLastUpdate: CFTimeInterval = 0
    var timeOfLastUpdate: CFTimeInterval = 0
    var timeOfLastAttack: CFTimeInterval = 0
    var timeBattleBegan: CFTimeInterval = 0
    var timeBattleEnded: CFTimeInterval  = 0
    
    var timeBonus: SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")
    
    var highEnemy: BaseEnemy = BaseEnemy(imageNamed: "fitCreature.png")
    var midEnemy: BaseEnemy = BaseEnemy(imageNamed: "fitCreature.png")
    var lowEnemy: BaseEnemy = BaseEnemy(imageNamed: "fitCreature.png")
    
    var wasKilledByADemonWhoToreItselfFreeFromAHumanSoul: Bool = false
    
    var battleTimerBar: ProgressBar = ProgressBar(imageNamed: "black.png")
    var battleTimerBarFraction: Float = 1.0
    
    let GO: SKSpriteNode = SKSpriteNode(imageNamed: "GO.png")
    let deadPlayer: SKSpriteNode = SKSpriteNode(imageNamed: "dead2.png")
    
    let DOD: SKSpriteNode = SKSpriteNode(imageNamed: "dodge.png")
    
    var swipeNode: SKSpriteNode = SKSpriteNode(imageNamed: "slide.png")
    var swipeAction: SKAction = SKAction()
    var swipeBoolDone: Bool = false
    
    var allEnemiesDead = false
    
    
    var initialTouch: CGPoint = CGPointMake(0, 0)
    var finalTouch: CGPoint = CGPointMake(0, 0)
    var waitForEnd: SKAction = SKAction()
    
    
    let boss1: Boss1 = Boss1(imageNamed: "creatureCircle2.png")
    
    override func didMoveToView(view: SKView) {
        currentRound = 1
        
        createSprite(baseSwipe, andWithPosition: CGPointMake(self.frame.size.width/2.0, self.frame.size.height * 3.0/20.0), andWithZPosition: 5.0, andWithString: "swipe", andWithSize: 4.0, andWithParent: self)
        baseSwipe.setUpChoices()
        baseSwipe.swipeStateC(state.currentSwipeState)
        
        
        
        player = Player(imageNamed: "playerRight1.png")
        player.isFacing = RIGHT
        player.changeDirection()
        player.returnToIdle()
        self.createSprite(player, andWithPosition: CGPointMake(self.player.position.x, self.frame.size.height/2 + 80), andWithZPosition: 2, andWithString: "player", andWithSize: 4, andWithParent: self)
        player.position = CGPointMake(self.frame.size.width/2 - 150, self.frame.size.height/2)
        player.startPosition = player.position
        //self.addSwiping()
        self.backgroundColor = UIColor.blackColor()
        self.backgroundColor = UIColor(red: 0.0, green: 107.0/255.0, blue: 0.0, alpha: 1.0)
        
        self.createSprite(swipeNode, andWithPosition: CGPointMake(player.position.x, self.frame.size.height/2), andWithZPosition: 25, andWithString: "swipe", andWithSize: 4, andWithParent: self)
        
        swipeAction = SKAction.repeatActionForever(SKAction.sequence([SKAction.moveToX(self.frame.size.width/2 + 140, duration: 1.2), SKAction.waitForDuration(0.25), SKAction.runBlock({self.swipeNode.position = CGPointMake(self.player.position.x, self.frame.size.height/2)}), SKAction.waitForDuration(0.25)]))
        swipeNode.runAction(swipeAction)
        
        self.createEnemy()
        self.setUpProgress()
        
        highEnemy.Progress_bar.hidden = true
        midEnemy.Progress_bar.hidden = true
        lowEnemy.Progress_bar.hidden = true
        
        self.setUpTiles()
        
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(infiniteMode.gameLoop), userInfo: nil, repeats: false)
        
 
        let home = SKSpriteNode(imageNamed: "house.png")
        self.createSprite(home, andWithPosition: CGPointMake(self.frame.size.width * 0.95, self.frame.size.height * 0.95), andWithZPosition: 20, andWithString: "home", andWithSize: 2, andWithParent: self)
    }
 
    func setUpTiles(){
        for(var i = -20; i < Int(self.frame.size.width) + 20; i+=88){
            for(var j = -20; j < Int(self.frame.size.width) + 20; j+=88){
                let a: SKSpriteNode = SKSpriteNode(imageNamed: "tileDark.png")
                self.createSprite(a, andWithPosition: CGPointMake(CGFloat(i), CGFloat(j)), andWithZPosition: 0, andWithString: "tile", andWithSize: 4, andWithParent: self)
            }
        }
    }
    
    func setUpProgress(){
        self.createSprite(battleTimerBar, andWithPosition: CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.95), andWithZPosition: 10, andWithString: "progress", andWithSize: 4, andWithParent: self)
        battleTimerBar.createBar(self.frame.size.width * 0.75, andHeight: 25.0, andType: timerProgress)
        battleTimerBar.updateBar(battleTimerBarFraction)
        NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: #selector(infiniteMode.updateProgressTimer), userInfo: nil, repeats: false)
    }
    
    func updateProgressTimer(){
        if(currentRound != 4 && currentRound != 5){
            if((lowEnemy.hidden == true || lowEnemy.name == "dud") && (midEnemy.hidden == true || midEnemy.name == "dud") && (highEnemy.hidden == true || highEnemy.name == "dud")){
                
            }else if(swipeBoolDone  == true && wasKilledByADemonWhoToreItselfFreeFromAHumanSoul == false && allEnemiesDead == false){
                battleTimerBarFraction -= 0.02
            }
            battleTimerBar.updateBar(battleTimerBarFraction)
        }
        NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(infiniteMode.updateProgressTimer), userInfo: nil, repeats: false)
    }
    
    func gameLoop() {
        if(swipeBoolDone == false){
            highEnemy.Progress_bar.hidden = true
            midEnemy.Progress_bar.hidden = true
            lowEnemy.Progress_bar.hidden = true
            
            highEnemy.progressFraction = 0.0
            midEnemy.progressFraction = 0.0
            lowEnemy.progressFraction = 0.0
        }else{
            highEnemy.Progress_bar.hidden = false
            midEnemy.Progress_bar.hidden = false
            lowEnemy.Progress_bar.hidden = false
        }
        
        
        if(wasKilledByADemonWhoToreItselfFreeFromAHumanSoul == false && swipeBoolDone == true){
            if(highEnemy.hidden == false && player.Health > 0){
                self.enemyHighAttack()
            }
            if(midEnemy.hidden == false && player.Health > 0){
                self.enemyMidAttack()
            }
            if(lowEnemy.hidden == false && player.Health > 0){
                self.enemyLowAttack()
            }
            
            if(currentRound == 4 && boss1.name != "dud" && player.Health > 0 && boss1.name != "did"){
                print("st11")
                if(boss1.progressFraction >= 1.0){
                    print("Strike")
                    boss1.strikeAt(player.position)
                    player.doDamage(boss1.Strength)
                    boss1.progressFraction = 0.0
                }
            }
            if(boss1.name == "dud"){
                boss1.name = "did"
                self.runAction(SKAction.sequence([SKAction.waitForDuration(5.0), SKAction.runBlock({self.nextRound()})]))
                
            }
            
            if((lowEnemy.hidden == true || lowEnemy.name == "dud") && (midEnemy.hidden == true || midEnemy.name == "dud") && (highEnemy.hidden == true || highEnemy.name == "dud")){
                if(allEnemiesDead == false){
                    allEnemiesDead = true
                    print("victory")
                    self.runAction(SKAction.sequence([SKAction.waitForDuration(0.75), SKAction.runBlock({self.nextRound()})]))
                }
            }else if(player.Health <= 0 || battleTimerBarFraction <= 0.0){
                player.Health = 100
                battleTimerBarFraction = 0.0
                wasKilledByADemonWhoToreItselfFreeFromAHumanSoul = true
                // self.playerLost()
                
                self.player.hidden = true
                self.runAction(SKAction.sequence([SKAction.waitForDuration(0.75), SKAction.runBlock({self.playerLost()})]))
                
            }
        }
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(infiniteMode.gameLoop), userInfo: nil, repeats: false)
    }
    func playerLost(){
        self.enumerateChildNodesWithName("tile"){
            node, stop in
            let node2: SKSpriteNode = node as! SKSpriteNode
            node2.texture = SKTexture(imageNamed: "tileBlack.png")
            node2.texture!.filteringMode = SKTextureFilteringMode.Nearest
        }
        DOD.removeFromParent()
        battleTimerBarFraction = 1.0
        player.hidden = true
        highEnemy.hidden = true
        midEnemy.hidden = true
        lowEnemy.hidden = true
        
        battleTimerBar.hidden = true
        
        self.createSprite(GO, andWithPosition: CGPointMake(self.frame.size.width/2, self.frame.size.height/2 + 180), andWithZPosition: 2, andWithString: "go", andWithSize: 5, andWithParent: self)
        
        self.createSprite(deadPlayer, andWithPosition: CGPointMake(self.frame.size.width/2, self.frame.size.height/2), andWithZPosition: 2, andWithString: "go", andWithSize: 5, andWithParent: self)
        wasKilledByADemonWhoToreItselfFreeFromAHumanSoul = true
        self.runAction(SKAction.sequence([SKAction.waitForDuration(1.0), SKAction.runBlock({self.resetGame()})]))
    }
    func resetGame() {
        
        //currentRound = 1
        //self.size = CGSizeMake(44, 44)
        
        boss1.killMe()
        //boss1.removeFromParent()
        //self.size = CGSizeMake(44, 44)
        
        self.destroyEnemies()
        self.createEnemy()
        
        GO.removeFromParent()
        GO.size = CGSizeMake(52, 7 )
        deadPlayer.removeFromParent()
        deadPlayer.size = CGSizeMake(22, 20)
        
        self.player.hidden = false
        self.player.isDefending = false
        
        self.player.Health = 100
        self.player.HP_bar.updateBar(1.0)
        
        battleTimerBarFraction = 1.0
        battleTimerBar.hidden = false
        
        baseSwipe.highEnemyKilled = false
        baseSwipe.midEnemyKilled = false
        baseSwipe.lowEnemyKilled = false
        
        wasKilledByADemonWhoToreItselfFreeFromAHumanSoul = false
        
        self.enumerateChildNodesWithName("tile"){
            node, stop in
            let node2: SKSpriteNode = node as! SKSpriteNode
            node2.texture = SKTexture(imageNamed: "tileDark.png")
            node2.texture!.filteringMode = SKTextureFilteringMode.Nearest
        }
        
    }
    func nextRound(){
        currentRound+=1
        
        self.destroyEnemies()
        self.createEnemy()
        
        self.player.Health = self.player.Health + self.player.Health/0.25
        if(self.player.Health > 100){
            self.player.Health = 100
        }
        self.player.HP_bar.updateBar(self.player.Health/100.0)
        self.player.isDefending = false
        
        battleTimerBarFraction = 1.0
        battleTimerBar.hidden = false
        
        baseSwipe.highEnemyKilled = false
        baseSwipe.midEnemyKilled = false
        baseSwipe.lowEnemyKilled = false
        
        allEnemiesDead = false
    }
    
    func enemyHighAttack(){
        if(highEnemy.progressFraction >= 1.0){
            // print("Strike")
            highEnemy.strikeAt(player.position)
            player.doDamage(highEnemy.Strength)
            highEnemy.progressFraction = 0.0
        }
    }
    func enemyMidAttack() {
        if(midEnemy.progressFraction >= 1.0){
            //print("Strike")
            midEnemy.strikeAt(player.position)
            player.doDamage(midEnemy.Strength)
            midEnemy.progressFraction = 0.0
        }
    }
    func enemyLowAttack(){
        if(lowEnemy.progressFraction >= 1.0){
            //print("Strike")
            lowEnemy.strikeAt(player.position)
            player.doDamage(lowEnemy.Strength)
            lowEnemy.progressFraction = 0.0
        }
    }
    
    
    func createEnemy() {
        
        let cre1: BaseEnemy = BaseEnemy(imageNamed: "fitCreature.png")
        self.createSprite(cre1, andWithPosition: CGPointMake(self.frame.size.width/2 + 200, self.frame.size.height/2 + 180), andWithZPosition: 2, andWithString: "BaseEnemy", andWithSize: 4.0, andWithParent: self)
        
        let cre2: BaseEnemy = BaseEnemy(imageNamed: "fitCreature.png")
        self.createSprite(cre2, andWithPosition: CGPointMake(self.frame.size.width/2 + 200, self.frame.size.height/2), andWithZPosition: 2, andWithString: "BaseEnemy", andWithSize: 4.0, andWithParent: self)
        
        let cre3: BaseEnemy = BaseEnemy(imageNamed: "fitCreature.png")
        self.createSprite(cre3, andWithPosition: CGPointMake(self.frame.size.width/2 + 200, self.frame.size.height/2 - 180), andWithZPosition: 2, andWithString: "BaseEnemy", andWithSize: 4.0, andWithParent: self)
        
        highEnemy = cre1
        midEnemy = cre2
        lowEnemy = cre3
        
        highEnemy.zPosition = CGFloat(highEnemyZPosition)
        midEnemy.zPosition = CGFloat(midEnemyZPosition)
        lowEnemy.zPosition = CGFloat(lowEnemyZPosition)
        

        highEnemy.begin(SHADOW, andWithStartValue: 0.0)
        midEnemy.begin(SHADOW, andWithStartValue: 0.0)
        lowEnemy.begin(SHADOW, andWithStartValue: 0.0)
            
        //self.enemyAttack()
        
    }
    func destroyEnemies(){
        highEnemy.removeAllActions()
        highEnemy.isCharging = false
        highEnemy.chargeCount = 3
        
        midEnemy.removeAllActions()
        midEnemy.isCharging = false
        midEnemy.chargeCount = 3
        
        lowEnemy.removeAllActions()
        lowEnemy.isCharging = false
        lowEnemy.chargeCount = 3
        
        highEnemy.removeFromParent()
        midEnemy.removeFromParent()
        lowEnemy.removeFromParent()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            let touchedNode = self.nodeAtPoint(location)
            if(touchedNode.name == "home"){
                touchedNode.name = "gone"
                let nextScene = GameScene(size: self.size)
                self.scene?.view?.presentScene(nextScene)
            }else{
                initialTouch = location
                
            }// print("Begin")
            //print(touch.locationInNode(self))
        }
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            //print("mid")
            //print(touch.locationInNode(self))
            finalTouch = location
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            //print("end")
            //print(touch.locationInNode(self))
            finalTouch = location
            self.pseudoSwipe()
        }
    }
    
    func pseudoSwipe(){
        if(initialTouch.x - finalTouch.x > 200 && player.isDefending == false){
            print(initialTouch.x - finalTouch.x )
            print("swiped Left")
            player.isDefending = true
            player.dodge()
            
            baseSwipe.leftArrow.colorBlendFactor = 1.0
            baseSwipe.leftArrow.color = UIColor.redColor()
            self.runAction(SKAction.sequence([SKAction.waitForDuration(0.1), SKAction.runBlock({self.baseSwipe.leftArrow.colorBlendFactor = 0.0})]))
            
        }else if(initialTouch.x - finalTouch.x < -200){
            print(initialTouch.x - finalTouch.x )
            print("swiped right")
            print(initialTouch.y - finalTouch.y)
            
            baseSwipe.rightArrow.colorBlendFactor = 1.0
            baseSwipe.rightArrow.color = UIColor.redColor()
            self.runAction(SKAction.sequence([SKAction.waitForDuration(0.1), SKAction.runBlock({self.baseSwipe.rightArrow.colorBlendFactor = 0.0})]))
            
            print(initialTouch.y - finalTouch.y)
            if(initialTouch.y - finalTouch.y > 125){
                print("Swiped down")
                self.attackEnemy(lowEnemy)
            }else if(initialTouch.y - finalTouch.y < -125){
                print("swiped up")
                self.attackEnemy(highEnemy)
            }else{
                self.attackEnemy(midEnemy)
            }
            if(swipeBoolDone == false){
                swipeNode.removeAllActions()
                swipeNode.removeFromParent()
                
                highEnemy.progressFraction = 0.0
                midEnemy.progressFraction = 0.0
                lowEnemy.progressFraction = 0.0
            }
            swipeBoolDone = true
            
            print("swipe")
            // self.attackEnemy(midEnemy)
            
            
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if(timeBattleBegan == 0){
            timeBattleBegan = currentTime
        }else if(currentRound == 5 && timeBattleEnded == 0){
            timeBattleEnded = currentTime
            print("Done")
            print(timeBattleBegan)
            print(timeBattleEnded)
            print(timeBattleEnded - timeBattleBegan)
            //50 = B
            let battleTime = timeBattleEnded - timeBattleBegan
            if(currentLevel == 1){
                let def=NSUserDefaults()
                if(battleTime < 35){
                    print("S")
                    def.setInteger(1, forKey: "level1Grade")
                }else if(battleTime >= 35 && battleTime < 45){
                    print("A")
                    def.setInteger(2, forKey: "level1Grade")
                }else if(battleTime >= 45 && battleTime < 55){
                    print("B")
                    def.setInteger(3, forKey: "level1Grade")
                }else if(battleTime >= 55 && battleTime < 65){
                    print("C")
                    def.setInteger(4, forKey: "level1Grade")
                }else if(battleTime >= 65 && battleTime < 75){
                    print("D")
                    def.setInteger(5, forKey: "level1Grade")
                }else if(battleTime >= 75){
                    print("F")
                    def.setInteger(6, forKey: "level1Grade")
                }
            }
        }
    }
    
    func handleSwipe(gesture: UIGestureRecognizer) {
        if(midEnemy.type != GOODSLIME){// && isMultiAttacking == false){
            if let swipeGesture = gesture as? UISwipeGestureRecognizer {
                switch state.currentTurn {
                case .playersTurn:
                    //slimeSwipe.hidden = true
                    baseSwipe.hidden = false
                    self.performPersonSwipe(swipeGesture)
                    break
                case .slimesTurn:
                    print("slime")
                    //slimeSwipe.hidden = false
                    baseSwipe.hidden = true
                    //self.performSlimeSwipe(swipeGesture)
                    break
                }
            }
        }
    }
    func attackEnemy(whichEnemy: BaseEnemy) {
        print("Attakc enemy")
        if(currentRound  != 4 && currentRound != 5 &&                     wasKilledByADemonWhoToreItselfFreeFromAHumanSoul == false){
            
            if(whichEnemy.zPosition == highEnemyZPosition){
                if(whichEnemy.name != "dud" && whichEnemy.hidden == false){
                    player.strikeAt(UP, andWithBool: true)
                }else{
                    player.strikeAt(UP, andWithBool: false)
                }
            }else if(whichEnemy.zPosition == midEnemyZPosition){
                if(whichEnemy.name != "dud" && whichEnemy.hidden == false){
                    player.strikeAt(RIGHT, andWithBool: true)
                }else{
                    player.strikeAt(RIGHT, andWithBool: false)
                }
            }else{
                if(whichEnemy.name != "dud" && whichEnemy.hidden == false){
                    player.strikeAt(DOWN, andWithBool: true)
                }else{
                    player.strikeAt(DOWN, andWithBool: false)
                }
            }
            
            if(timeOfLastAttack != 0){
                print("attack time")
                var timeSinceAttack: Float = Float(timeOfLastUpdate - timeOfLastAttack) * 0.5
                //print(timeSinceAttack)///.86
                if(timeSinceAttack > 1.0){
                    timeSinceAttack = 1.0
                }
                let damage: Float = player.Strength/timeSinceAttack
                if(whichEnemy.name != "dud" && whichEnemy.hidden == false){
                    self.doDamageDirectly(whichEnemy, withAttack: damage)
                }
                //print(damage)//40
                //print(player.Strength)//35
                print(Int(10 * (damage/player.Strength)))
                
                timeBonus.text = "Time Bonus: " + String(Int(10 * (damage/player.Strength)) - 10)
            }else{
                if(whichEnemy.name != "dud" && whichEnemy.hidden == false){
                    self.doDamageDirectly(whichEnemy, withAttack: player.Strength)
                }
            }
            
            timeOfLastAttack = timeOfLastUpdate
            state.currentSwipeState = swipeState.Base
            player.isDefending = false
            
            /*if(slimeUnlocked == true){
             currentTurn = .slimesTurn
             }*/
        }
    }
    func doDamageDirectly(withEnemy: BaseEnemy, withAttack Attack: Float){
        print(Attack)
        if(withEnemy.doDamage(Attack, withType: 1) == true){
            if(withEnemy.zPosition == lowEnemyZPosition){
                baseSwipe.lowEnemyKilled = true
            }else if(withEnemy.zPosition == midEnemyZPosition){
                baseSwipe.midEnemyKilled = true
            }else if(withEnemy.zPosition == highEnemyZPosition){
                baseSwipe.highEnemyKilled = true
            }
        }
    }
    func performPersonSwipe(swipeGesture: UISwipeGestureRecognizer){
        print("players turn")
        
        let point: CGPoint = swipeGesture.locationInView(swipeGesture.view!)
        if swipeGesture.state == .Began {
            print("BEGANNNN")
            print(NSStringFromCGPoint(point))
        }
        else if swipeGesture.state == .Ended {
            print("ENDEDDD")
            print(NSStringFromCGPoint(point))
        }
        
        switch state.currentSwipeState {
        case .Base:
            print("base")
            if(swipeBoolDone == false){
                swipeNode.removeAllActions()
                swipeNode.removeFromParent()
                
                highEnemy.progressFraction = 0.0
                midEnemy.progressFraction = 0.0
                lowEnemy.progressFraction = 0.0
            }
            swipeBoolDone = true
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.Up:
                print("Special")
                if(baseSwipe.special1Unlocked == true || baseSwipe.special2Unlocked == true || baseSwipe.special3Unlocked == true){
                    // state.currentSwipeState = swipeState.Special
                }
                break
            case UISwipeGestureRecognizerDirection.Down:
                print("Defend")
                player.isDefending = true
                break
            case UISwipeGestureRecognizerDirection.Left:
                print("Escape")
                //self.leaveBattle()
                break
            case UISwipeGestureRecognizerDirection.Right:
                print("Attack")
                if (currentRound == 1 && baseSwipe.midEnemyKilled == false) {
                    print("swipe")
                    self.attackEnemy(midEnemy)
                }else{
                    self.state.currentSwipeState = swipeState.Target
                }
                break
            default:
                break
            }
        case .Special:
            print("special")
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Up:
                print("Special2")
                if(baseSwipe.special2Unlocked == true){
                    state.currentSwipeState = swipeState.Target
                    //self.multiStrikeAttack()
                }
                break
            case UISwipeGestureRecognizerDirection.Down:
                print("Back")
                state.currentSwipeState = swipeState.Base
                break
            case UISwipeGestureRecognizerDirection.Left:
                print("Special1")
                if(baseSwipe.special1Unlocked == true){
                    state.currentSwipeState = swipeState.Target
                }
                break
            case UISwipeGestureRecognizerDirection.Right:
                print("Special3")
                if(baseSwipe.special3Unlocked == true){
                    state.currentSwipeState = swipeState.Target
                }
                break
            default:
                break
            }
        case .Target:
            print("target")
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Up:
                print("Attack Top")
                if(baseSwipe.highEnemyKilled == false){
                    self.attackEnemy(highEnemy)
                }
                break
            case UISwipeGestureRecognizerDirection.Down:
                print("Attack Low")
                if(baseSwipe.lowEnemyKilled == false){
                    self.attackEnemy(lowEnemy)
                }
                break
            case UISwipeGestureRecognizerDirection.Right:
                print("Attack Mid")
                if(baseSwipe.midEnemyKilled == false){
                    self.attackEnemy(midEnemy)
                }
                break
            case UISwipeGestureRecognizerDirection.Left:
                print("Back")
                state.currentSwipeState = swipeState.Base
                break
            default:
                break
            }
        }
        baseSwipe.swipeStateC(state.currentSwipeState)
    }
    
    func createSprite(withSprite:SKSpriteNode, andWithPosition aPosition:CGPoint, andWithZPosition zPos: CGFloat, andWithString theString: String, andWithSize aSize: CGFloat, andWithParent parent: AnyObject) {
        withSprite.size = (withSprite.texture?.size())!
        withSprite.position = aPosition
        withSprite.zPosition = zPos
        withSprite.name = theString
        
        withSprite.size = CGSizeMake(withSprite.size.width * aSize, withSprite.size.height * aSize)
        withSprite.texture!.filteringMode = SKTextureFilteringMode.Nearest
        
        parent.addChild(withSprite)
    }
}