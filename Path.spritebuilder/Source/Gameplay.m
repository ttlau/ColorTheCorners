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
    
    CCDrawNode *_static;
    
    int numOfColors;
    CCColor *currentColor;
    
    CCButton *_submit;
    
    int points;
    int numOfVertices;
    int numVerticesUncolored;
}

-(void)onEnter{
    
    [super onEnter];
    
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    //initializing static draw node
    _static = [[CCDrawNode alloc]init];
    _static.position = (ccp(0,0));
    [self addChild:_static];
    
    //set the points to number of colors left
    points = numOfColors - 1;
    _scoreLabel.string = [NSString stringWithFormat:@"%d", points];
    
    //set the number of vertices uncolored to num of vertices
    numOfVertices = [_listOfVertices count];
    numVerticesUncolored = numOfVertices;

}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    
    // load the level
    CCNode *level = [CCBReader load:@"Levels/Level2"];
    [_levelNode addChild:level];
    
    // changing the background color
    ((CCNodeGradient *)self.children[0]).startColor = [CCColor colorWithRed:.204 green:.596 blue:.859];
    ((CCNodeGradient *)self.children[0]).endColor = [CCColor colorWithRed: .161 green: .502 blue: .725];
    
    
    // initialize variables
    _listOfVertices = [[NSMutableArray alloc] init];
    colors = [[NSMutableArray alloc] init];

#pragma mark populate list of vertices
    
    CCNode *_levelNodeChild = [_levelNode.children objectAtIndex:0];
    CCNode *_listOfSprites = [_levelNodeChild.children objectAtIndex:0];
    
    // create dots
    CCDrawNode *map;
    map = [[CCDrawNode alloc]init];
    map.position = (ccp(0,0));
    [self addChild:map];
    
    // for tag numbers
    int tagNumber = 0;
    
    for (Vertex *s in _listOfSprites.children){
        
        // set properties
        s.tag = tagNumber;
        s.color = [CCColor blackColor];
        s.isConnected = FALSE;
        s.visible = FALSE;
        
        //[self drawRect:s.boundingBox];
        
        // draw the dot
        [map drawDot:s.position radius:7.5 color:[CCColor blackColor]];
        [map setZOrder: 1];
        
        // demonstrate number in array
        CCLabelTTF *tagString;
        tagString = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%d", tagNumber] fontName: @"Helvetica" fontSize:15];
        [tagString setPosition: s.positionInPoints];
        [_levelNode addChild:tagString];
        tagNumber++;
        
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
        NSMutableArray *childrenOfVertex = [[NSMutableArray alloc] init];
        // because the adjacency matrix is symmetric, no need to double draw
        while(secondIndex < index)
        {
            if ([(NSNumber*)edges[index][secondIndex] isEqualToNumber:@1])
            {
                [map drawSegmentFrom:((Vertex*)[_listOfVertices objectAtIndex:index]).positionInPoints to:((Vertex*)[_listOfVertices objectAtIndex:secondIndex]).positionInPoints radius:2.0 color:[CCColor colorWithRed:0.925 green:0.941 blue:0.945]];
                [map setZOrder:0];
                
                // second index are things that are connected to current vertex, with current vertex as origin point
                [childrenOfVertex addObject: _listOfVertices[secondIndex]];
            }
            secondIndex++;
        }
        // assign current vertex's linked nodes to temp array above
        ((Vertex *)_listOfVertices[index]).linkedNodes = [[NSSet alloc] initWithArray: childrenOfVertex];
        index++;
    }

#pragma mark draw the color options
    NSArray *possibleColors = @[[CCColor blackColor],[CCColor redColor], [CCColor orangeColor], [CCColor yellowColor], [CCColor greenColor], [CCColor blueColor], [CCColor purpleColor], [CCColor cyanColor], [CCColor magentaColor], [CCColor brownColor]];
    
    // one extra for black
    numOfColors = 4;
    for (int i = 1; i <= numOfColors; i++){
        CCSprite *c = [[CCSprite alloc]initWithImageNamed:@"Images/ColorSelector.png"];
        c.color = possibleColors[i-1];
        c.position = ccp(175 + (i-1)*50, 260);
        CGSize colorNodeSize = CGSizeMake(100.0, 100.0);
        [c setContentSize:colorNodeSize];
        c.visible = TRUE;
        
        [_levelNode addChild:c];
        [colors addObject:c];
    }
    
    currentColor = [CCColor clearColor];
    
#pragma mark submit button
    
    // make submit button invisible
    _submit.visible = FALSE;
    
    
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
            if (points > 0 && ![self checkColorEquality:currentColor and:[CCColor blackColor]]){
                points--;
                break;
            }
            
            //clicked black and number of colors left isn't more than max number
            else if(points < (numOfColors-1) && [self checkColorEquality:currentColor and:[CCColor blackColor]]){
                points++;
                break;
            }
        }
    }
    
    for (Vertex *v in _listOfVertices)
    {
        double distanceToVertex = [self distanceBetweenPoint:[_contentNode convertToWorldSpace:v.position] andPoint:touchLoc];
        
        if (distanceToVertex < 15){
            // if current color is clear, player has not chosen a color
            if ([self checkColorEquality:currentColor and:[CCColor clearColor]])
            {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"You must select a color first!" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
//                [alert show];
                break;
            }
            else if (![self checkColorEquality:currentColor and: v.color]) {
                [_static drawDot:v.position radius:7.5 color:currentColor];
                v.color = currentColor;
                
                // setting how many vertices uncolored
                
                // if number of uncolored vertices is greater than 0 and current color is not black
                if (numVerticesUncolored > 0 && ![self checkColorEquality:currentColor and:[CCColor blackColor]]){
                    numVerticesUncolored--;
                    break;
                }
                
                // if number of uncolored vertices is less than total number of vertices and current color is black
                else if(numVerticesUncolored < numOfVertices && [self checkColorEquality:currentColor and:[CCColor blackColor]]){
                    numVerticesUncolored++;
                    break;
                }
            }
        }
    }
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    //update the score
    _scoreLabel.string = [NSString stringWithFormat:@"%d", points];
    _scoreLabel.visible = true;
    
    if (numVerticesUncolored == 0)
    {
        _submit.visible = TRUE;
    }
    else{
        _submit.visible = FALSE;
    }
}

- (void)clear {
    // reload this level
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
}

-(void)submit{
    Boolean isValidColoring = [self bfs: [_listOfVertices lastObject]];
    CCLabelTTF *message;
    if (isValidColoring){
        message = [[CCLabelTTF alloc] initWithString:@"Yay you win!" fontName: @"Helvetica" fontSize:15];
    }
    else{
        message = [[CCLabelTTF alloc] initWithString:@"Aww try again" fontName: @"Helvetica" fontSize:15];
    }
    [message setPosition: CGPointMake(self.contentSizeInPoints.width/2, self.contentSizeInPoints.height/2)];
    [_levelNode addChild:message];
}

#pragma mark helper functions

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

- (Boolean)checkColorEquality : (CCColor*)colorOne and: (CCColor*)colorTwo{
    if (colorOne.red != colorTwo.red){
        return false;
    }
    if (colorOne.green != colorTwo.red){
        return false;
    }
    if(colorOne.blue != colorTwo.red){
        return false;
    }
    if(colorOne.alpha != colorTwo.alpha){
        return false;
    }
    return true;
}

- (Boolean)bfs: (Vertex*)startingVertex{
    
    NSMutableSet *visitedNodes = [NSMutableSet setWithObject:startingVertex];
    NSMutableArray *queue = [NSMutableArray arrayWithObject:startingVertex];
    CCColor *colorToCheckAgainst;
    
    while ([queue count] > 0)
    {
        NSSet *newNodes = ((Vertex *)[queue objectAtIndex:0]).linkedNodes;
        colorToCheckAgainst = ((Vertex *)[queue objectAtIndex:0]).color;
        for (Vertex *newNode in newNodes)
        {
            if (newNode.color.red == colorToCheckAgainst.red && newNode.color.green == colorToCheckAgainst.green && newNode.color.blue == colorToCheckAgainst.blue){
                return FALSE;
            }
            if (![visitedNodes containsObject:newNode])
            {
                [visitedNodes addObject:newNode];
                [queue addObject:newNode];
            }
        }
        
        [queue removeObjectAtIndex:0];
    }
    
    return TRUE;
}

@end