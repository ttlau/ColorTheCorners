//
//  Gameplay.m
//  Path
//
//  Created by Tim Lau on 7/14/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
// tutorials, animations
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
    CCLabelTTF *tutorialText;
    
    
    NSMutableArray *_listOfVertices;
    NSMutableArray *colors;
    
    CCDrawNode *_static;
    
    int numOfColors;
    CCColor *currentColor;
    
    CCButton *_submit;
    
    CCLayoutBox *colorBox;
    
    CCSprite *highlighter;
    
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
    
    if (userLevel == 1){
        [self presentWelcome];
    }

}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    
    
    NSNumber *currentLevel = [[NSUserDefaults standardUserDefaults] objectForKey:@"userLevel"];
    userLevel = [currentLevel intValue];
    
    // if currentLevel returns nil, set to the first level
    if (currentLevel == nil)
    {
        userLevel = 1;
        [[NSUserDefaults standardUserDefaults] setObject:[[NSNumber alloc]initWithInt:userLevel] forKey:@"userLevel"];
        currentLevel = [[NSUserDefaults standardUserDefaults] objectForKey:@"userLevel"];
    }
    
    // load the level
    CCNode *level = [CCBReader load: [NSString stringWithFormat:@"Levels/Level%d",[currentLevel intValue]]];
    [_levelNode addChild:level];
    
    
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
        [map drawDot:s.position radius:20 color:[CCColor blackColor]];
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
                [map drawSegmentFrom:((Vertex*)[_listOfVertices objectAtIndex:index]).positionInPoints to:((Vertex*)[_listOfVertices objectAtIndex:secondIndex]).positionInPoints radius:4.0 color:[CCColor colorWithRed:0.925 green:0.941 blue:0.945]];
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
    NSArray *possibleColors = @[[CCColor redColor], [CCColor orangeColor], [CCColor yellowColor], [CCColor greenColor], [CCColor blueColor], [CCColor purpleColor], [CCColor cyanColor], [CCColor magentaColor], [CCColor brownColor]];
    
    // create a layout box to group the color selectors together
    colorBox = [[CCLayoutBox alloc]init];
    colorBox.anchorPoint = ccp(0.5, 0.5);
    
    // from the plist, load the number of allowed colors
    numOfColors = [[levelProperties objectForKey:@"Colors"] intValue];
    //numOfColors = 10;
    
    // set properties of the dots and add them to the layout box
    for (int i = 1; i <= numOfColors; i++){
        ColorSelector *c = [[ColorSelector alloc]initWithImageNamed:@"Images/ColorSelector.png"];
        c.color = possibleColors[i-1];
        [c setScale: 1.0];
        c.visible = TRUE;
        c.used = FALSE;
        
        [colorBox addChild:c];
        [colors addObject:c];
    }
    
    // set properties of the layout box and draw them
    colorBox.direction = CCLayoutBoxDirectionHorizontal;
    colorBox.spacing = 25.f;
    [colorBox layout];
    
    [self addChild: colorBox];
    
    // make the color selector highlighter - basically tells which is current color being used
    ColorSelector *firstSelector = (ColorSelector*)colors[0];
    highlighter = [[CCSprite alloc]initWithImageNamed:@"Images/ColorSelectorHighlighter.png"];
    highlighter.color = [CCColor colorWithRed:.82 green: .859 blue: .741];
    highlighter.contentSize = CGSizeMake(firstSelector.contentSize.width, firstSelector.contentSize.height);
    highlighter.anchorPoint = ccp(0.5, 0.5);
    highlighter.position = firstSelector.positionInPoints;
    [firstSelector addChild: highlighter z: firstSelector.zOrder-1];
    
    // because drawing on Gameplay scene, which is the parent of everything else, need to use CCDirector to find middle of screen
    CCDirector *thisDirector = [CCDirector sharedDirector];
    colorBox.position = ccp([thisDirector viewSize].width/2.0, 50.0);
    
    // set the first color to the clearColor
    currentColor = [CCColor clearColor];
    
#pragma mark buttons
    
    // initialize the back button
    backButton = [[CCButton alloc]init];
    backButton.color = [[CCColor alloc] initWithUIColor:[UIColor ht_blueJeansColor]];
    [backButton setBackgroundColor:[[CCColor alloc] initWithUIColor: [UIColor ht_blueJeansDarkColor]] forState:CCControlStateHighlighted];
    
    //note: for the x coordinate, take the width of the button + displacement from side and then minus width
    clearButton = [[CCButton alloc] init];
    clearButton.color = [[CCColor alloc] initWithUIColor:[UIColor ht_blueJeansColor]];
    [clearButton setBackgroundColor:[[CCColor alloc] initWithUIColor: [UIColor ht_blueJeansDarkColor]] forState:CCControlStateHighlighted];

    // add the CCButtons as children of the gameplay scene
    [self addChild: backButton];
    [self addChild:clearButton];

#pragma mark making the level pretty
    
    // changing the background color
    ((CCNodeGradient *)self.children[0]).startColor = [CCColor colorWithRed:.204 green:.596 blue:.859];
    ((CCNodeGradient *)self.children[0]).endColor = [CCColor colorWithRed: .161 green: .502 blue: .725];
    
    
}

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLoc = [touch locationInNode:_contentNode];
    
    if ([self withinLayoutBox:touchLoc]){
    
#pragma mark check which color was selected
        for (ColorSelector *c in colors)
        {
            // c is in node space of color Box
            double distanceToColor = [self distanceBetweenPoint:[colorBox convertToWorldSpace:c.positionInPoints] andPoint: touchLoc];
        
            // custom set, need to find a way to scale
            if(distanceToColor < c.contentSize.width/2){
                currentColor = c.color;
                id moveAction = [CCActionMoveTo actionWithDuration:.5 position:c.positionInPoints];
            
                [highlighter runAction:[CCActionSequence actions:moveAction,nil]];
                
                if (userLevel == 1 && [self checkColorEquality:currentColor and:[CCColor redColor]]){
                    tutorialText.visible = FALSE;
                    [tutorialText setString: @"Place it here!"];
                    tutorialText.position = [_contentNode convertToWorldSpace:((Vertex*)_listOfVertices[0]).position];
                    tutorialText.visible = TRUE;
                }
                
                break;
            }
        }
    }
    
    else{

#pragma mark check which vertex was touched
        for (Vertex *v in _listOfVertices)
        {
            double distanceToVertex = [self distanceBetweenPoint:[_contentNode convertToWorldSpace:v.position] andPoint:touchLoc];
        
            if (distanceToVertex < 15){
            
                // if current color is not equal to the vertex color (prevent extraneous dots being created)
                if (![self checkColorEquality:currentColor and: v.color]) {
                
                    // if number of colored vertices is less than total number of verticesnand that has not been previously colored
                    if (numVerticesColored < numOfVertices && [self checkColorEquality:v.color and:[CCColor blackColor]])
                    {
                        numVerticesColored++;
                    }
                
                 
                    // drawing the dot and setting the invisible vertex color
                    [_static drawDot:v.position radius:20 color:currentColor];
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
    
    // load in the path of NSUserDefaults
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Level Properties" ofType:@"plist"];
    NSDictionary *levels = [NSDictionary dictionaryWithContentsOfFile:path];
    
    if (isValidColoring){
        
        // go to the next level
        userLevel++;
        
        // if user still has levels to complete
        if (userLevel <= [levels count]){
            [[NSUserDefaults standardUserDefaults] setObject:[[NSNumber alloc]initWithInt:userLevel] forKey:@"userLevel"];
            CCScene *mainScene = [CCBReader loadAsScene:@"SuccessScene"];
            [[CCDirector sharedDirector] replaceScene:mainScene withTransition: [CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1]];
        }
        
        // else load the end scene
        else{
            CCScene *mainScene = [CCBReader loadAsScene:@"EndScene"];
            [[CCDirector sharedDirector] replaceScene:mainScene withTransition: [CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1]];
        }
    }
}

- (void)back {
    CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:mainScene withTransition: [CCTransition transitionPushWithDirection:CCTransitionDirectionDown duration:1]];
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

-(Boolean)withinLayoutBox: (CGPoint)touch{
    float minX = colorBox.position.x - colorBox.contentSize.width/2;
    float maxX = colorBox.position.x + colorBox.contentSize.width/2;
    float minY = colorBox.position.y - colorBox.contentSize.height/2;
    float maxY = colorBox.position.y + colorBox.contentSize.height/2;
    return (touch.x >= minX && touch.x <= maxX && touch.y >= minY && touch.y <= maxY);
}

/* attempt at drawing circles
- (void)drawRect:(CGRect)rect {
    
        CGContextRef context = UIGraphicsGetCurrentContext();
    
        CGContextSetLineWidth(context, 2.0);
    
        CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
        CGRect rectangle = CGRectMake(60,170,200,80);
    
        CGContextAddEllipseInRect(context, rectangle);
    
        CGContextStrokePath(context);
}
*/


// colors are equal only when RGBA of both colors are equal
- (Boolean)checkColorEquality : (CCColor*)colorOne and: (CCColor*)colorTwo{
    if (colorOne.red != colorTwo.red){
        return false;
    }
    if (colorOne.green != colorTwo.green){
        return false;
    }
    if(colorOne.blue != colorTwo.blue){
        return false;
    }
    if(colorOne.alpha != colorTwo.alpha){
        return false;
    }
    return true;
}


// running BFS on the graph to check all permutations of vertex color equality
- (Boolean)bfs: (Vertex*)startingVertex{
    
    // list of the visited nodes
    NSMutableSet *visitedNodes = [NSMutableSet setWithObject:startingVertex];
    
    // the queue from which we pop off the next vertex to visit
    NSMutableArray *queue = [NSMutableArray arrayWithObject:startingVertex];
    
    // the color we need to see if anything else is equal to
    CCColor *colorToCheckAgainst;
    
    // run bfs while still have vertices to relax
    while ([queue count] > 0)
    {
        // get all the adjacent vertices of current vertex
        NSSet *newNodes = ((Vertex *)[queue objectAtIndex:0]).linkedNodes;
        
        // set the color to check against to the current vertex's color
        colorToCheckAgainst = ((Vertex *)[queue objectAtIndex:0]).color;
        
        // relax and check all nodes
        for (Vertex *newNode in newNodes)
        {
            // if two adjacent nodes equal in color, return false
            if ([self checkColorEquality:newNode.color and:colorToCheckAgainst]){
                return FALSE;
            }
            
            // if a new node that we haven't relaxed, add to the queu and visitedNodes
            if (![visitedNodes containsObject:newNode])
            {
                [visitedNodes addObject:newNode];
                [queue addObject:newNode];
            }
        }
        
        // check the next vertex
        [queue removeObjectAtIndex:0];
    }
    
    // all vertices have been checked and therefore must be true
    return TRUE;
}

#pragma mark tutorial 

-(void)presentWelcome{
    
    tutorialText = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"Welcome!"] fontName: @"Papyrus" fontSize:30];
    [tutorialText setPosition: ccp(([CCDirector sharedDirector].viewSize).width/2, 275)];
    [self addChild:tutorialText];
    
    
    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(removeWelcomeText:)
                                   userInfo:nil
                                    repeats:NO];
}

-(void)removeWelcomeText: (NSTimer*)timer{
    
    tutorialText.visible = NO;
    [tutorialText setString:@"Start by choosing the red dot!"];
    tutorialText.fontSize = 15;
    [tutorialText setPosition: ccp(colorBox.position.x, colorBox.position.y-35)];
    tutorialText.visible = YES;
}

@end