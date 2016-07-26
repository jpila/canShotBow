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

@end

//set up categories for collision
static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t targetCategory        =  0x1 << 1;

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
    NSTimeInterval ti = [[NSDate date] timeIntervalSinceDate:self.StartDate];
    NSLog(@"Time: %f", ti);
    // 1 - Choose one of the touches to work with
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    // 2 - Position the projectile
    SKNode *archer = [self childNodeWithName:@"Archer"];
    SKSpriteNode *projectile = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(10, 10)];
    projectile.position = CGPointMake(archer.position.x+5, archer.position.y+5);
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
    projectile.physicsBody.contactTestBitMask = targetCategory;
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
        
        SKNode *ground = [self childNodeWithName:@"ground"];
        //   range of up and down movements for target
        int minY = (self.target.size.height / 2) + 20;
        int maxY = (self.frame.size.height - self.target.size.height / 2) - head.size.height;
        int rangeY = maxY - minY;
        //        int actualY = (arc4random() % rangeY) + minY;
        
        //   speed of movement
        int minDuration = 2.0;
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
    }
    return self;
}


//initialize head
- (SKSpriteNode *)newHead
{
    SKSpriteNode *head = [[SKSpriteNode alloc] initWithColor:[SKColor orangeColor] size:CGSizeMake(40,40)];
//    SKAction *blink = [SKAction sequence:@[
//                                           [SKAction fadeOutWithDuration:0.50],
//                                           [SKAction fadeInWithDuration:0.50]]];
//    SKAction *blinkForever = [SKAction repeatActionForever:blink];
//    [head runAction: blinkForever];
    return head;
}

// collision method
- (void)projectile:(SKSpriteNode *)projectile didCollideWithTarget:(SKSpriteNode *)target {
    NSLog(@"Hit");
//    [projectile removeFromParent];
    SKAction *blink = [SKAction sequence:@[
                                           [SKAction fadeOutWithDuration:0.50],
                                           [SKAction fadeInWithDuration:0.50]]];
    
    SKAction *blinkTwice = [SKAction repeatAction:blink count:2];
    
    [self.target runAction:blinkTwice];
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
}


@end
