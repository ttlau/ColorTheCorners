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
    NSMutableArray *colors;
    
    CCDrawNode *_dynamic;
    CCDrawNode *_static;
    
    int numOfColors;
    CCColor *currentColor;
    
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
    points = numOfColors - 1;
    _scoreLabel.string = [NSString stringWithFormat:@"%d", points];
    

}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    
    // load the level
    CCNode *level = [CCBReader load:@"Levels/Level2"];
//    _levelNode.positionInPoints = ccp(0,0);
//    level.positionInPoints = ccp(0,0);
    [_levelNode addChild:level];
    
    // initialize variables
    _listOfVertices = [[NSMutableArray alloc] init];
    colors = [[NSMutableArray alloc] init];

#pragma mark populate list of vertices
    
    CCNode *_levelNodeChild = [_levelNode.children objectAtIndex:0];
    CCNode *_listOfSprites = [_levelNodeChild.children objectAtIndex:0];
    // CCNode *_extraStuff = [_listOfSprites.children objectAtIndex:0];
    
    // create dots
    CCDrawNode *map;
    map = [[CCDrawNode alloc]init];
    map.position = (ccp(0,0));
    [self addChild:map];
    
    // for tag numbers
    int tagNumber = 0;
    
    for (Vertex *s in _listOfSprites.children){
        
        // set the tag
        s.tag = tagNumber;
    
        CCLabelTTF *tagString;
        tagString = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%d", tagNumber] fontName: @"Helvetica" fontSize:30];
        [tagString setPosition:[s anchorPointInPoints]];
        [s addChild:tagString];
        
        tagNumber++;
        s.color = [CCColor blackColor];
        s.visible = FALSE;
        
        //[self drawRect:s.boundingBox];
        
        // draw the dot
        [map drawDot:s.position radius:7.5 color:[CCColor blackColor]];
        
        // add to list of vertices
        [_listOfVertices addObject: s];
    }
    
#pragma mark draw the edges
    
    NSArray *edges = @[@[@0, @1, @0, @1, @0], @[@1, @0, @1, @0, @1], @[@0, @1, @0, @1, @1], @[@1, @0, @1, @0, @1], @[@0, @1, @1, @1, @0]];
    
    
    int index = 0;
    int secondIndex = 0;
    
    
    while (index < [edges count])
    {
        secondIndex = 0;
        
        // because the adjacency matrix is symmetric, no need to double draw
        while(secondIndex < index)
        {
            if ([(NSNumber*)edges[index][secondIndex] isEqualToNumber:@1])
            {
                [map drawSegmentFrom:((Vertex*)[_listOfVertices objectAtIndex:index]).positionInPoints to:((Vertex*)[_listOfVertices objectAtIndex:secondIndex]).positionInPoints radius:2.0 color:[CCColor colorWithRed:1.0 green:0.286 blue:0.0]];
            }
            secondIndex++;
        }
        index++;
    }

#pragma draw the color options
    NSArray *possibleColors = @[[CCColor blackColor],[CCColor redColor], [CCColor orangeColor], [CCColor yellowColor], [CCColor greenColor], [CCColor blueColor], [CCColor purpleColor], [CCColor cyanColor], [CCColor magentaColor], [CCColor brownColor]];
    
    // one extra for black
    numOfColors = 4;
    for (int i = 1; i <= numOfColors; i++){
        CCSprite *c = [[CCSprite alloc]initWithImageNamed:@"Images/ColorSelector.png"];
        c.color = possibleColors[i-1];
        c.position = ccp(175 + (i-1)*50, 275);
        CGSize colorNodeSize = CGSizeMake(100.0, 100.0);
        [c setContentSize:colorNodeSize];
        c.visible = TRUE;
        
        [_levelNode addChild:c];
        [colors addObject:c];
    }
    
    currentColor = [CCColor clearColor];
    
    
}

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLoc = [touch locationInNode:_contentNode];
    
    //TODO: see if can optimize for loops
    
    for (CCSprite *c in colors)
    {
        double distanceToColor = [self distanceBetweenPoint:[_contentNode convertToWorldSpace:c.position] andPoint: touchLoc];
        if(distanceToColor < 15){
            currentColor = c.color;
            
            // if points not 0 and not clicking black
            if (points > 0 && !(c.color.red == 0 && c.color.blue == 0 && c.color.green == 0))
                points--;
            
            //clicked black and number of colors left isn't more than max number
            else if(points < (numOfColors-1) && (c.color.red == 0 && c.color.blue == 0 && c.color.green == 0)){
                points++;
            }
            else{
                continue;
            }
        }
    }
    
    for (Vertex *v in _listOfVertices)
    {
        double distanceToVertex = [self distanceBetweenPoint:[_contentNode convertToWorldSpace:v.position] andPoint:touchLoc];
        
        if ( distanceToVertex < 15){
            [_static drawDot:v.position radius:7.5 color:currentColor];
            v.color = currentColor;
        }
    }
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    CGPoint touchLoc = [touch locationInNode:_contentNode];
    
    //draws the lines
//    [_dynamic clear];
//    [_dynamic drawSegmentFrom:((Vertex*)[colors objectAtIndex:[colors count] - 1]).position to:touchLoc radius:5.0 color:[CCColor colorWithRed:1.0 green:0.286 blue:0.0]];
//    [_dynamic drawDot:touchLoc radius:15 color:[CCColor magentaColor]];
//    
//    for (Vertex *v in _listOfVertices)
//    {
//        double distanceToVertex = [self distanceBetweenPoint:[_contentNode convertToWorldSpace:v.position] andPoint:touchLoc];
//        
//        // if connected two vertices
//        if ( distanceToVertex < 15){
//            
//            // destroy the dynamically drawn line
//            [_dynamic clear];
//            //[_static drawPolyWithVerts: v.position count:0 fillColor:[CCColor clearColor] borderWidth:3 borderColor:[CCColor magentaColor]];
//            [_static drawDot:v.position radius:15 color:[CCColor magentaColor]];
//            CCLOG(@"Touched a Vertex!");
//            [colors addObject:v];
//            
//            // points added for connected nodes
//            points++;
//            
//            //draw the final segment, the start of it being from the first touched star to the second touched star
//            [_static drawSegmentFrom:((Vertex*)[colors objectAtIndex:[colors count] - 2]).position to:((Vertex*)[colors objectAtIndex:[colors count] - 1]).position radius:5.0 color:[CCColor colorWithRed:1.0 green:0.286 blue:0.0]];
//        }
//    }
    
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    //update the score
    _scoreLabel.string = [NSString stringWithFormat:@"%d", points];
    _scoreLabel.visible = true;
    
    
    [_dynamic clear];
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

- (void)drawRect:(CGRect)rect {
    
        CGContextRef context = UIGraphicsGetCurrentContext();
    
        CGContextSetLineWidth(context, 2.0);
    
        CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
        CGRect rectangle = CGRectMake(60,170,200,80);
    
        CGContextAddEllipseInRect(context, rectangle);
    
        CGContextStrokePath(context);
}

@end