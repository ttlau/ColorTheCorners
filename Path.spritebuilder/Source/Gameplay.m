//
//  Gameplay.m
//  Path
//
//  Created by Tim Lau on 7/14/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Vertex.h"

@implementation Gameplay{
    
    CCNode *_levelNode;
    CCNode *_contentNode;
    CCLabelTTF *_scoreLabel;
    Vertex *_currentVertex;
    
    int points;
}
CGPoint startPoint;
CGPoint endPoint;


// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    // load the level
    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode addChild:level];
    
    //set the score to 0
    points = 0;
}

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    // set the beginning of the line
    startPoint = [touch locationInNode:_contentNode];
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    // whenever touches move, update the position of the end point
    endPoint = [touch locationInNode:_contentNode];
    
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    //update the score
    points++;
    _scoreLabel.string = [NSString stringWithFormat:@"%d", points];
    _scoreLabel.visible = true;
    
    // draw the line with the given start and finish
    CCColor *c = [CCColor colorWithRed:1.0 green:0.286 blue:0.0];
    CCDrawNode *line = [CCDrawNode node];
    [line drawSegmentFrom:startPoint to:endPoint radius:5.0 color:c];
    [self addChild: line];
    
}

- (void)retry {
    // reload this level
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
}


@end