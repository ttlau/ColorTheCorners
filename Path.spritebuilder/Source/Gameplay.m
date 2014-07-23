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
    NSMutableArray *_touchedVertices;
    
    CCDrawNode *_dynamic;
    CCDrawNode *_static;
    
    int points;
}

-(void)onEnter{
    
    [super onEnter];
    
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    //initializing dynamic draw node
    _dynamic = [[CCDrawNode alloc]init];
    _dynamic.position = (ccp(0,0));
    [self addChild:_dynamic];
    
    //initializing static draw node
    _static = [[CCDrawNode alloc]init];
    _static.position = (ccp(0,0));
    [self addChild:_static];
    
    //set the score to 0
    points = 0;

}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    
    // load the level
    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode addChild:level];
    
    // initialize variables
    _listOfVertices = [[NSMutableArray alloc] init];
    _touchedVertices = [[NSMutableArray alloc] init];

    // populate list of vertices
    CCScene *_levelNodeChild = [_levelNode.children objectAtIndex:0];
    CCNode *_listOfSprites = [_levelNodeChild.children objectAtIndex:0];
    
    for (Vertex *s in _listOfSprites.children){
        [_listOfVertices addObject: s];
    }
}

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
//    // set the beginning of the line
//    CGPoint temp = [touch locationInNode:_contentNode];
//    CGRect v;
//    for (int i = 0; i < _listOfVertices.count; i++)
//    {
//        v = [[_listOfVertices objectAtIndex:i] CGRectValue];
//        if (CGRectContainsPoint(v, temp))
//        {
//            // startPoint = temp;
//            NSLog (@"Vertex Touched");
//            return;
//        }
//    }
    
    CGPoint touchLoc = [touch locationInNode:_contentNode];
    
    for (Vertex *v in _listOfVertices)
    {
        double distanceToVertex = [_contentNode distanceBetweenPoint:v.position andPoint:touchLoc];
        CCLOG(@"Distance: %f", distanceToVertex);
        
        if ( distanceToVertex < 15 && [_touchedVertices count] == 0){
            [_dynamic drawDot:v.position radius:15 color:[CCColor magentaColor]];
            CCLOG(@"Touched a Vertex!");
            [_touchedVertices addObject:v];

        }
    }
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ( [_touchedVertices count] == 0 )
    {
        return;
    }
    
    CGPoint touchLoc = [touch locationInNode:_contentNode];
    
    //draws the lines
    [_dynamic clear];
    [_dynamic drawSegmentFrom:((Vertex*)[_touchedVertices objectAtIndex:[_touchedVertices count] - 1]).position to:touchLoc radius:5.0 color:[CCColor colorWithRed:1.0 green:0.286 blue:0.0]];
    [_dynamic drawDot:touchLoc radius:15 color:[CCColor magentaColor]];
    
    for (Vertex *v in _listOfVertices)
    {
        double distanceToVertex = [_contentNode distanceBetweenPoint:v.position andPoint:touchLoc];
        CCLOG(@"Distance: %f", distanceToVertex);
        
        // if connected two vertices
        if ( distanceToVertex < 15 && ![_touchedVertices containsObject:v]){
            
            [_static drawDot:v.position radius:15 color:[CCColor magentaColor]];
            CCLOG(@"Touched a Vertex!");
            [_touchedVertices addObject:v];
            
            //draw the final segment, the start of it being from the first touched star to the second touched star
            [_static drawSegmentFrom:((Vertex*)[_touchedVertices objectAtIndex:[_touchedVertices count] - 2]).position to:((Vertex*)[_touchedVertices objectAtIndex:[_touchedVertices count] - 1]).position radius:5.0 color:[CCColor colorWithRed:1.0 green:0.286 blue:0.0]];
        }
    }
    
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