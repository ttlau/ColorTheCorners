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
    
    //set tags
    //int tagNumber = 0;
    
    for (Vertex *s in _listOfSprites.children){
        [_listOfVertices addObject: s];
        //s.tag = tagNumber;
        //tagNumber++;
        CGPoint vertexLoc = [_contentNode convertToWorldSpace:s.position];
        CCLOG(@"Vertex position x: %f y: %f",vertexLoc.x, vertexLoc.y);
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
        double distanceToVertex = [self distanceBetweenPoint:[_contentNode convertToWorldSpace:v.position] andPoint:touchLoc];
        CCLOG(@"Touch point: x: %f y: %f", touchLoc.x, touchLoc.y);
        //CCLOG(@"Distance: %f", distanceToVertex);
        
        if ( distanceToVertex < 15 && [_touchedVertices count] == 0){
            [_static drawDot:v.position radius:15 color:[CCColor magentaColor]];
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
        double distanceToVertex = [self distanceBetweenPoint:[_contentNode convertToWorldSpace:v.position] andPoint:touchLoc];
        CCLOG(@"Distance: %f", distanceToVertex);
        
        // if connected two vertices
        if ( distanceToVertex < 15 && ![_touchedVertices containsObject:v]){
            
            // destroy the dynamically drawn line
            [_dynamic clear];
            //[_static drawPolyWithVerts: v.position count:0 fillColor:[CCColor clearColor] borderWidth:3 borderColor:[CCColor magentaColor]];
            [_static drawDot:v.position radius:15 color:[CCColor magentaColor]];
            CCLOG(@"Touched a Vertex!");
            [_touchedVertices addObject:v];
            
            // points added for connected nodes
            points++;
            
            //draw the final segment, the start of it being from the first touched star to the second touched star
            [_static drawSegmentFrom:((Vertex*)[_touchedVertices objectAtIndex:[_touchedVertices count] - 2]).position to:((Vertex*)[_touchedVertices objectAtIndex:[_touchedVertices count] - 1]).position radius:5.0 color:[CCColor colorWithRed:1.0 green:0.286 blue:0.0]];
        }
    }
    
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    //update the score
    _scoreLabel.string = [NSString stringWithFormat:@"%d", points];
    _scoreLabel.visible = true;
    
    [_dynamic clear];
    
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

// distance formula for use in drawing lines
-(double)distanceBetweenPoint: (CGPoint) point1 andPoint: (CGPoint) point2
{
    double dx = (point2.x-point1.x);
    double dy = (point2.y-point1.y);
    double dist = dx*dx + dy*dy;
    return sqrt(dist);
}

@end