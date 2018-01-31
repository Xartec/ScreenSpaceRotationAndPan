//
//  menuOverlayView.m
//  SceneKitPointSize
//
//  Created by Admin on 1/26/17.
//  Copyright © 2017 Xartec All rights reserved.
//

#import "MenuOverlayView.h"


@implementation MenuOverlayView

- (void)initMenu {
    
    self.camLabel = [[SKLabelNode alloc] initWithFontNamed:@"AvenirNext-DemiBold"];
    self.camLabel.fontColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1.0];
    self.camLabel.fontSize = 12;
    self.camLabel.text = [NSString stringWithFormat:@"Camera Mode"];
    self.camLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    self.camLabel.position = CGPointMake(self.size.width -10, self.size.height -16);
    [self addChild:self.camLabel];
    
    self.instructLabel = [[SKLabelNode alloc] initWithFontNamed:@"AvenirNext-DemiBold"];
    self.instructLabel.fontColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
    self.instructLabel.fontSize = 14;
    self.instructLabel.text = @"1. Pan with 1 finger to rotate, 2 fingers to move. 2. Tap the Camera Mode label to switch between auto camera controls and Object Mode. 3. Tap an object to select it.";
    self.instructLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    self.instructLabel.position = CGPointMake(self.size.width/2, 16);
    [self addChild:self.instructLabel];
    
    self.intro = YES;
}

@end
