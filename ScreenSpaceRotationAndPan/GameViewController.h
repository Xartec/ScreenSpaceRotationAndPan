//
//  GameViewController.h
//  ScreenSpaceRotationAndPan
//
//  Created by Admin on 10/14/17.
//  Copyright © 2017 Xartec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>
#include "MenuOverlayView.h"

@interface GameViewController : UIViewController <SCNSceneRendererDelegate>

@property MenuOverlayView *menuOverlayView;
//@property (strong, nonatomic) IBOutlet SCNView *myView;

@end

