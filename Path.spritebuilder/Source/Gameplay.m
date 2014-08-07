//
//  Gameplay.m
//  Path
//
//  Created by Tim Lau on 7/14/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
// TODO: Bigger color selectors, bigger nodes, no white line connecting, menu, tutorials, animations, submit button showing
//

#import "Gameplay.h"
#import "Vertex.h"
#import"ColorSelector.h"
#import "HTPressableButton-master/Classes/HTPressableButton.h"
#import "HTPressableButton-master/Classes/UIColor+HTColor.h"


@implementation Gameplay{
    
    CCNode *_levelNode;
    CCNode *_contentNode;
    CCLabelTTF *_scoreLabel;
    
    
    NSMutableArray *_listOfVertices;
    NSMutableArray *colors;
    
    CCDrawNode *_static;
    
    int numOfColors;
    CCColor *currentColor;
    
    CCButton *_submit;
    
    CCLayoutBox *colorBox;
    
    int numOfVertices;
    int numVerticesColored;
    
    CCButton *backButton;
    CCButton *clearButton;
    
    int userLevel;
    
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
    //_scoreLabel.string = [NSString stringWithFormat:@"%d", points];
    
    //set the number of vertices uncolored to num of vertices
    numOfVertices = [_listOfVertices count];
    numVerticesColored = 0;

}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    
    
    NSNumber *currentLevel = [[NSUserDefaults standardUserDefaults] objectForKey:@"userLevel"];
    userLevel = [currentLevel intValue];
    
    if (currentLevel == nil)
    {
        userLevel = 1;
        [[NSUserDefaults standardUserDefaults] setObject:[[NSNumber alloc]initWithInt:userLevel] forKey:@"userLevel"];
        currentLevel = [[NSUserDefaults standardUserDefaults] objectForKey:@"userLevel"];
    }
    
    // load the level
    CCNode *level = [CCBReader load: [NSString stringWithFormat:@"Levels/Level%d",[currentLevel intValue]]];
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
        
        // draw the dot
        [map drawDot:s.position radius:15 color:[CCColor blackColor]];
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
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Level Properties" ofType:@"plist"];
    NSDictionary *levels = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSDictionary *levelProperties = [levels objectForKey:[NSString stringWithFormat:@"Level%d", [currentLevel intValue]]];
    NSArray *edges = [levelProperties objectForKey:@"Edges"];
    
    
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
    colorBox = [[CCLayoutBox alloc]init];
    colorBox.anchorPoint = ccp(0.5, 0.5);
    
    // one extra for black
    numOfColors = [[levelProperties objectForKey:@"Colors"] intValue];
    
    for (int i = 1; i <= numOfColors; i++){
        ColorSelector *c = [[ColorSelector alloc]initWithImageNamed:@"Images/ColorSelector.png"];
        c.color = possibleColors[i-1];
        //c.position = ccp(175 + (i-1)*50, 260);
        [c setScale: 1.0];
        c.visible = TRUE;
        c.used = FALSE;
        
        // c.name wasn't here and colors addObject: c because was NSMutableArray before
        [colorBox addChild:c];
        [colors addObject:c];
    }
    
    colorBox.direction = CCLayoutBoxDirectionHorizontal;
    colorBox.spacing = 25.f;
    [colorBox layout];
    [self addChild: colorBox];
    
    CCDirector *thisDirector = [CCDirector sharedDirector];
    colorBox.position = ccp([thisDirector viewSize].width/2.0, 35.0);
    
    currentColor = [CCColor clearColor];
    
#pragma mark buttons
    
    
    backButton = [[CCButton alloc]init];
    backButton.color = [[CCColor alloc] initWithUIColor:[UIColor ht_blueJeansColor]];
    [backButton setBackgroundColor:[[CCColor alloc] initWithUIColor: [UIColor ht_blueJeansDarkColor]] forState:CCControlStateHighlighted];
    
    //note: for the x coordinate, take the width of the button + displacement from side and then minus width
    clearButton = [[CCButton alloc] init];
    clearButton.color = [[CCColor alloc] initWithUIColor:[UIColor ht_blueJeansColor]];
    [clearButton setBackgroundColor:[[CCColor alloc] initWithUIColor: [UIColor ht_blueJeansDarkColor]] forState:CCControlStateHighlighted];

    
    [self addChild: backButton];
    [self addChild:clearButton];
    
    
}

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLoc = [touch locationInNode:_contentNode];
    
    //TODO: see if can optimize for loops
    
    for (ColorSelector *c in colors)
    {
        // c is in node space of color Box
        double distanceToColor = [self distanceBetweenPoint:[colorBox convertToWorldSpace:c.positionInPoints] andPoint: touchLoc];
        
        // custom set, need to find a way to scale
        if(distanceToColor < c.contentSize.width/2){
            currentColor = c.color;
            
            // if points not 0 and not clicking black and has not been used
            if (![self checkColorEquality:currentColor and:[CCColor blackColor]] && !c.used){
                c.used = TRUE;
                break;
            }
            
            //clicked black and number of colors left isn't more than max number
            else if([self checkColorEquality:currentColor and:[CCColor blackColor]]){
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
                // setting how many vertices uncolored
                
                // if number of colored vertices is greater than 0 and current color is not black and that has not been previously colored
                if (numVerticesColored < numOfVertices && ![self checkColorEquality:currentColor and:[CCColor blackColor]] && [self checkColorEquality:v.color and:[CCColor blackColor]]){
                    numVerticesColored++;
                }
                
                // if number of uncolored vertices is less than total number of vertices and current color is black and is not already black
                else if(numVerticesColored > 0 && [self checkColorEquality:currentColor and:[CCColor blackColor]] && ![self checkColorEquality:v.color and:[CCColor blackColor]]){
                    numVerticesColored--;
                }
                
                [_static drawDot:v.position radius:15 color:currentColor];
                v.color = currentColor;
                
                // only run bfs check when touching a vertex, so not in touchEnded
                if (numVerticesColored == numOfVertices)
                {
                    [self submit];
                }
                break;
            }
        }
    }
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

#pragma mark methods for buttons

- (void)clear {
    // reload this level
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
}

-(void)submit{
    Boolean isValidColoring = [self bfs: [_listOfVertices lastObject]];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Level Properties" ofType:@"plist"];
    NSDictionary *levels = [NSDictionary dictionaryWithContentsOfFile:path];
    
    if (isValidColoring){
        userLevel++;
        if (userLevel < [levels count]){
            [[NSUserDefaults standardUserDefaults] setObject:[[NSNumber alloc]initWithInt:userLevel] forKey:@"userLevel"];
            CCScene *mainScene = [CCBReader loadAsScene:@"SuccessScene"];
            [[CCDirector sharedDirector] replaceScene:mainScene];
        }
        else{
            CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
            [[CCDirector sharedDirector] replaceScene:mainScene];

        }
    }
}

- (void)back {
    CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:mainScene];
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