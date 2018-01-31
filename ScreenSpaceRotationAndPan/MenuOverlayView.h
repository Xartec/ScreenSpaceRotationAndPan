//
//  menuOverlayView.h
//  SceneKitPointSize
//
//  Created by Admin on 1/26/17.
//  Copyright © 2017 Xartec All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MenuOverlayView : SKScene

@property SKLabelNode* camLabel;
@property SKLabelNode* instructLabel;
@property BOOL intro;

- (void)initMenu;

@end
