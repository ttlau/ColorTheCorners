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
    NSMutableArray *_listOfVertices;
    
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
    
    // add bounding boxes for interaction around all nodes
    CCScene *_levelNodeChild = [_levelNode.children objectAtIndex:0];
    CCNode *_listOfSprites = [_levelNodeChild.children objectAtIndex:0];
    _listOfVertices = [[NSMutableArray alloc] init];
    
    for (CCSprite *s in _listOfSprites.children){
        CGRect absoluteBox = CGRectMake(s.position.x, s.position.y, [s boundingBox].size.width, [s boundingBox].size.height);
        [_listOfVertices addObject: [NSValue valueWithCGRect: absoluteBox]];
        
//        
//        // testing purposes
//        UIView *_currentView = [[UIView init] initWithFrame: absoluteBox];
//        [_currentView drawRect:absoluteBox];
        
    }
    
    
    //set the score to 0
    points = 0;
}

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    // set the beginning of the line
    CGPoint temp = [touch locationInNode:_contentNode];
    CGRect v;
    for (int i = 0; i < _listOfVertices.count; i++)
    {
        v = [[_listOfVertices objectAtIndex:i] CGRectValue];
        if (CGRectContainsPoint(v, temp))
        {
            // startPoint = temp;
            NSLog (@"Vertex Touched");
            return;
        }
    }
    
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
    
//    // draw the line with the given start and finish
//    CCColor *c = [CCColor colorWithRed:1.0 green:0.286 blue:0.0];
//    CCDrawNode *line = [CCDrawNode node];
//    [line drawSegmentFrom:startPoint to:endPoint radius:5.0 color:c];
//    [self addChild: line];
    
}

- (void)retry {
    // reload this level
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
}


@end