//
//  GameScene.m
//  ArcheryPhysics
//
//  Created by JOSE PILAPIL on 2016-07-26.
//  Copyright (c) 2016 JOSE PILAPIL. All rights reserved.
//

#import "GameScene.h"
@interface GameScene() <SKPhysicsContactDelegate>

@property NSDate *StartDate;
@property (nonatomic) SKSpriteNode * target;
@property (nonatomic) SKSpriteNode * obstacle;
@property int score;
@property int shotsFired;
@end

//set up categories for collision
static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t targetCategory        =  0x1 << 1;
static const uint32_t headCategory        =  0x1 << 2;
static const uint32_t obstacleCategory        =  0x1 << 3;


@implementation GameScene




static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

-(void)didMoveToView:(SKView *)view {
    [self addScoreLabel];
    [self shotsFiredLabel];
    /* Setup your scene here */
    SKSpriteNode *groundNode = [SKSpriteNode spriteNodeWithColor:[UIColor greenColor] size:CGSizeMake(view.frame.size.width, 20)];
    groundNode.position = CGPointMake(view.center.x, view.center.y /10);
    groundNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:groundNode.size];
    groundNode.physicsBody.dynamic = NO;
    groundNode.name = @"ground";
    
    SKSpriteNode *archerNode = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(30, 30)];
    archerNode.name= @"Archer";
    archerNode.position= CGPointMake(view.center.x/5, view.center.y +100);
    archerNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:archerNode.size];
    NSLog(@"CenterX:%f Center:y %f",view.center.x, view.center.y);
   
    [self addChild:groundNode];
    [self addChild:archerNode];
    
//    set up physics for collision
    self.physicsWorld.contactDelegate = self;
    
    

}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchBegan");
    self.StartDate = [NSDate date];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.shotsFired ++;
    SKLabelNode *shotsFired = (SKLabelNode*)[self childNodeWithName:@"shotsFire"];
    shotsFired.text = [NSString stringWithFormat:@"Shots Fired: %i", self.shotsFired];
//    [shotsFired removeFromParent];
    
//    [self shotsFiredLabel];
    
    NSTimeInterval ti = [[NSDate date] timeIntervalSinceDate:self.StartDate];
    NSLog(@"Time: %f", ti);
    // 1 - Choose one of the touches to work with
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    // 2 - Position the projectile
    SKNode *archer = [self childNodeWithName:@"Archer"];
    SKSpriteNode *projectile = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(10, 10)];
    projectile.position = CGPointMake(archer.position.x+20, archer.position.y+5);
    // 3 determine projectile offset to position
    CGPoint offset = rwSub(location, projectile.position);
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.restitution = .5;
    projectile.name = @"Arrow";
    
    // 4 - Bail out if you are shooting down or backwards
    if (offset.x <= 0) return;
    
    // 5 - OK to add now - we've double checked position
    [self addChild:projectile];
    
    // 6 - Get the direction of where to shoot
    CGPoint direction = rwNormalize(offset);
    
    // 7 - Make it shoot far enough to be guaranteed off screen
    float forceValue =  ti * 3; //Edit this value to get the desired force.
    CGPoint shootAmount = rwMult(direction, forceValue);
    
    //8 - Convert the point to a vector
    CGVector impulseVector = CGVectorMake(shootAmount.x, shootAmount.y);
    //This vector is the impulse you are looking for.
    
    //9 - Apply impulse to node.
    [projectile.physicsBody applyImpulse:impulseVector];
    
//    set up collision for projectile
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = headCategory | targetCategory | obstacleCategory;
    projectile.physicsBody.collisionBitMask = 0;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    
}

-(void)shoot
{
    SKNode *archer = [self childNodeWithName:@"Archer"];
    SKSpriteNode *arrow = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(10, 10)];
    arrow.position = CGPointMake(archer.position.x+5,archer.position.y+5);
}
-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

// YANA'S CODE:
//Creating initial position for the target
-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        // 2
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        // 3
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        // 4
        //        self.target = [SKSpriteNode spriteNodeWithImageNamed:@"target"];
        
        self.target = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(40,80)];
        
        self.target.position = CGPointMake((self.frame.size.width-self.target.size.width/2), self.frame.size.height/2);
        
        //        adding head to the target
        SKSpriteNode *head = [self newHead];
        head.position = CGPointMake(0.0, 60.0);
        [self.target addChild:head];
        
        
        [self addChild:self.target];
                //   range of up and down movements for target
        int minY = (self.target.size.height / 2) + 20;
        int maxY = (self.frame.size.height - self.target.size.height / 2) - head.size.height;
//        int rangeY = maxY - minY;
        //        int actualY = (arc4random() % rangeY) + minY;
        
        //   speed of movement
        int minDuration = 4.0;
        int maxDuration = 4.0;
        
        SKAction * actionMoveUp = [SKAction moveTo:CGPointMake((self.frame.size.width-self.target.size.width/2), maxY) duration:minDuration];
        
        SKAction * actionMoveDown = [SKAction moveTo:CGPointMake((self.frame.size.width-self.target.size.width/2), minY) duration:minDuration];
        
        SKAction *updown = [SKAction sequence:@[actionMoveUp, actionMoveDown]];
        
        SKAction *updownForever = [SKAction repeatActionForever:updown];
        
        [self.target runAction: updownForever];
        
        ////        scaling the target
        //        SKAction *zoomIn = [SKAction scaleTo:0.5 duration:0.25];
        //        [self.target runAction:zoomIn];
        
////        set up physics for collision
//        self.physicsWorld.gravity = CGVectorMake(0,0);
//        self.physicsWorld.contactDelegate = self;
        
        self.target.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.target.size];
        self.target.physicsBody.dynamic = YES;
        self.target.physicsBody.affectedByGravity = NO;
        self.target.physicsBody.categoryBitMask = targetCategory;
        self.target.physicsBody.contactTestBitMask = projectileCategory;
        self.target.physicsBody.collisionBitMask = 0;
        
        head.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:head.size];
        head.physicsBody.dynamic = YES;
        head.physicsBody.affectedByGravity = NO;
        head.physicsBody.categoryBitMask = headCategory;
        head.physicsBody.contactTestBitMask = projectileCategory;
        head.physicsBody.collisionBitMask = 0;
        
        
//        obstacle object
        self.obstacle = [[SKSpriteNode alloc] initWithColor:[SKColor blueColor] size:CGSizeMake(40,40)];
        self.obstacle.position = CGPointMake(self.frame.size.width/4*3, self.frame.size.height/2);
        [self addChild:self.obstacle];
        int minYobst = (self.obstacle.size.height / 2) + 20;
        int maxYobst = (self.frame.size.height - self.obstacle.size.height / 2);
        int durationObst = 1.5;
        SKAction * actionMoveUpObst = [SKAction moveTo:CGPointMake((self.frame.size.width/4*3), maxYobst) duration:durationObst];
        SKAction * actionMoveDownObst = [SKAction moveTo:CGPointMake((self.frame.size.width/4*3), minYobst) duration:durationObst];
        SKAction *updownObst = [SKAction sequence:@[actionMoveDownObst, actionMoveUpObst]];
        SKAction *updownForeverObst = [SKAction repeatActionForever:updownObst];
        [self.obstacle runAction: updownForeverObst];
        
        self.obstacle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.obstacle.size];
        self.obstacle.physicsBody.dynamic = YES;
        self.obstacle.physicsBody.affectedByGravity = NO;
        self.obstacle.physicsBody.categoryBitMask = obstacleCategory;
        self.obstacle.physicsBody.contactTestBitMask = projectileCategory;
        self.obstacle.physicsBody.collisionBitMask = 0;


        
        

    }
    return self;
}


//initialize head
- (SKSpriteNode *)newHead
{
    SKSpriteNode *head = [[SKSpriteNode alloc] initWithColor:[SKColor orangeColor] size:CGSizeMake(40,40)];
    return head;
}

// collision method
- (void)projectile:(SKSpriteNode *)projectile didCollideWithTarget:(SKSpriteNode *)target {
    NSLog(@"Hit");
    self.score ++;
    
    SKLabelNode *score = (SKLabelNode*)[self childNodeWithName:@"score"];
    [score removeFromParent];
    
    score.text = [NSString stringWithFormat:@"Score: %i", self.score];
    [projectile removeFromParent];
    SKAction *blink = [SKAction sequence:@[
                                           [SKAction fadeOutWithDuration:0.50],
                                           [SKAction fadeInWithDuration:0.50]]];
    
    SKAction *blinkTwice = [SKAction repeatAction:blink count:2];
    [self addScoreLabel];
    [self.target runAction:blinkTwice];
}

- (void)projectile:(SKSpriteNode *)projectile didCollideWithHead:(SKSpriteNode *)head {
    NSLog(@"Hit Head");
    self.score +=2;
    SKLabelNode *score = (SKLabelNode*)[self childNodeWithName:@"score"];
    score.text = [NSString stringWithFormat:@"Score: %i", self.score];
    [projectile removeFromParent];

    SKAction *hover = [SKAction sequence:@[
//                                           [SKAction waitForDuration:0.25],
                                           [SKAction moveByX:15 y:00 duration:0.05],
//                                           [SKAction waitForDuration:0.25],
                                           [SKAction moveByX:-30.0 y:00 duration:0.05],
                                            [SKAction moveByX:30.0 y:00 duration:0.05],
                                           [SKAction moveByX:-15.0 y:00 duration:0.05]]];
    [head runAction: hover];
}

- (void)projectile:(SKSpriteNode *)projectile didCollideWithObst:(SKSpriteNode *)obsticle {
    NSLog(@"Hit obsticle");
    [projectile removeFromParent];
    
    SKAction *zoomInOut = [SKAction sequence:@[[SKAction scaleTo:0.5 duration:0.1],
                                               [SKAction scaleTo: 1.0 duration:0.1]]];
    [self.obstacle runAction: zoomInOut];
}


// contact delegate method

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if (firstBody.categoryBitMask == projectileCategory &&
        secondBody.categoryBitMask == targetCategory)
    {
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithTarget:(SKSpriteNode *) secondBody.node];
    }
    
    if (firstBody.categoryBitMask == projectileCategory &&
             secondBody.categoryBitMask == headCategory)
    {
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithHead:(SKSpriteNode *) secondBody.node];
    }
    
    if (firstBody.categoryBitMask == projectileCategory &&
        secondBody.categoryBitMask == obstacleCategory)
    {
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithObst:(SKSpriteNode *) secondBody.node];
    }

}



-(void)didSimulatePhysics
{
    
    
}
-(void)shotsFiredLabel
{
    SKNode *score = [self childNodeWithName:@"score"];
    SKLabelNode *shotsFired = [SKLabelNode labelNodeWithText:[NSString stringWithFormat:@"Shots Fired: %d",self.shotsFired]];
    
    shotsFired.position = CGPointMake(score.position.x,score.position.y- 40);
    shotsFired.fontColor = [UIColor blueColor];
    shotsFired.name = @"shotsFire";
    [self addChild:shotsFired];
}

-(void)addScoreLabel{
    
    SKLabelNode *scoreNode = [SKLabelNode labelNodeWithText:[NSString stringWithFormat:@"Score: %d",self.score]];
    
    scoreNode.position = CGPointMake(self.view.center.x,self.view.center.y+ 150);
    scoreNode.fontColor = [UIColor blueColor];
    scoreNode.name = @"score";
    [self addChild:scoreNode];
}

@end
