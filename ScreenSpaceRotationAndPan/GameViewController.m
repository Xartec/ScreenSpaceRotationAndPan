//
//  GameViewController.m
//  ScreenSpaceRotationAndPan
//
//  Created by Admin on 10/14/17.
//  Copyright © 2017 Xartec. All rights reserved.
//

#import "GameViewController.h"
#import <SceneKit/SceneKit.h>
#import <SpriteKit/SpriteKit.h>

@interface GameViewController ()


@end

@implementation GameViewController

@synthesize menuOverlayView;

SCNScene *scene;
SCNNode *aNode;
SCNNode *mainPlanet;
SCNNode *orangeMoon;
SCNNode *yellowMoon;
SCNNode *selectedNode;
BOOL panHorizontal;
CGPoint prevLoc;
int touchCount;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // create a new scene
    scene = [SCNScene sceneNamed:@"art.scnassets/ship.scn" inDirectory:nil options:[NSDictionary dictionaryWithObjectsAndKeys:@1, SCNSceneSourceLoadingOptionPreserveOriginalTopology, @1, SCNSceneSourceStrictConformanceKey, nil]];
    
    // create and add a camera to the scene
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.camera.zFar = 1000;
    cameraNode.camera.zNear = 1.0;
    [scene.rootNode addChildNode:cameraNode];
    
    // place the camera
    cameraNode.position = SCNVector3Make(0, 100, 200);
    cameraNode.position = SCNVector3Make(0, 0, 15);
    
    // create and add a light to the scene
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.light.intensity = 500;
    lightNode.position = SCNVector3Make(0, 10, 10);
    [scene.rootNode addChildNode:lightNode];
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor darkGrayColor];
    [scene.rootNode addChildNode:ambientLightNode];
    
    // retrieve the ship node
    mainPlanet = [scene.rootNode childNodeWithName:@"MainPlanet" recursively:YES];
    orangeMoon = [scene.rootNode childNodeWithName:@"orangeMoon" recursively:YES];
    yellowMoon = [scene.rootNode childNodeWithName:@"yellowMoon" recursively:YES];
    mainPlanet.position = SCNVector3Make(0, 0, 0);
    //mainPlanet.hidden = YES;
    
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // set the scene to the view
    scnView.scene = scene;
    
    // allows the user to manipulate the camera
    scnView.allowsCameraControl = YES;
    // scnView.autoenablesDefaultLighting = YES;
    
    // show statistics such as fps and timing information
    //  scnView.showsStatistics = YES;
    
    // configure the view
    scnView.backgroundColor = [UIColor grayColor];
    
    // add a tap gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    NSMutableArray *gestureRecognizers = [NSMutableArray array];
    [gestureRecognizers addObject:tapGesture];
    [gestureRecognizers addObject:panGesture];
    [gestureRecognizers addObjectsFromArray:scnView.gestureRecognizers];
    scnView.gestureRecognizers = gestureRecognizers;
    
    scnView.pointOfView.camera.screenSpaceAmbientOcclusionIntensity = 2.5;
    scnView.pointOfView.camera.screenSpaceAmbientOcclusionNormalThreshold = 0.20;
    scnView.pointOfView.camera.screenSpaceAmbientOcclusionDepthThreshold = 0.20;
    scnView.pointOfView.camera.screenSpaceAmbientOcclusionBias = 0.15;
    scnView.pointOfView.camera.screenSpaceAmbientOcclusionRadius = 1.0;
    
    //spritekit overlay
    self.menuOverlayView = [[MenuOverlayView alloc] initWithSize:scnView.frame.size];
    [self.menuOverlayView initMenu];
    scnView.overlaySKScene = self.menuOverlayView;
}

- (void) handlePan:(UIPanGestureRecognizer*)gestureRecognize {
    SCNView *scnView = (SCNView *)self.view;
    CGPoint delta = [gestureRecognize translationInView:self.view];
    CGPoint loc = [gestureRecognize locationInView:self.view];
    if (gestureRecognize.state == UIGestureRecognizerStateBegan) {
        prevLoc = loc;
        touchCount = (int)gestureRecognize.numberOfTouches;
        
    } else if (gestureRecognize.state == UIGestureRecognizerStateChanged) {
        delta = CGPointMake(loc.x -prevLoc.x, loc.y -prevLoc.y);
        prevLoc = loc;
        if (touchCount != (int)gestureRecognize.numberOfTouches) {
            return;
        }
        
        SCNMatrix4 rotMat;
        if (touchCount == 2) { //create move/translate matrix
            rotMat = SCNMatrix4MakeTranslation(delta.x*0.025, delta.y*-0.025, 0);
        } else { //create rotate matrix
            SCNMatrix4 rotMatX = SCNMatrix4Rotate(SCNMatrix4Identity, (1.0f/100)*delta.y , 1, 0, 0);
            SCNMatrix4 rotMatY = SCNMatrix4Rotate(SCNMatrix4Identity, (1.0f/100)*delta.x , 0, 1, 0);
            rotMat = SCNMatrix4Mult(rotMatX, rotMatY);
        }
        
        //get the translation matrix of the child node
        SCNMatrix4 transMat = SCNMatrix4MakeTranslation(selectedNode.position.x, selectedNode.position.y, selectedNode.position.z);
        
        //move the child node to the origin of its parent (but keep its local rotation)
        selectedNode.transform = SCNMatrix4Mult(selectedNode.transform, SCNMatrix4Invert(transMat));
        
        //apply the "rotation" of the parent node extra
        SCNMatrix4 parentNodeTransMat = SCNMatrix4MakeTranslation(selectedNode.parentNode.worldPosition.x, selectedNode.parentNode.worldPosition.y, selectedNode.parentNode.worldPosition.z);
        
        SCNMatrix4 parentNodeMatWOTrans = SCNMatrix4Mult(selectedNode.parentNode.worldTransform, SCNMatrix4Invert(parentNodeTransMat));
        
        selectedNode.transform = SCNMatrix4Mult(selectedNode.transform, parentNodeMatWOTrans);
        
        //apply the inverse "rotation" of the current camera extra
        SCNMatrix4 camorbitNodeTransMat = SCNMatrix4MakeTranslation(scnView.pointOfView.worldPosition.x, scnView.pointOfView.worldPosition.y, scnView.pointOfView.worldPosition.z);
        SCNMatrix4 camorbitNodeMatWOTrans = SCNMatrix4Mult(scnView.pointOfView.worldTransform, SCNMatrix4Invert(camorbitNodeTransMat));
        selectedNode.transform = SCNMatrix4Mult(selectedNode.transform,SCNMatrix4Invert(camorbitNodeMatWOTrans));
        
        //perform the rotation based on the pan gesture
        selectedNode.transform = SCNMatrix4Mult(selectedNode.transform, rotMat);
        
        //remove the extra "rotation" of the current camera
        selectedNode.transform = SCNMatrix4Mult(selectedNode.transform, camorbitNodeMatWOTrans);
        //remove the extra "rotation" of the parent node (we can use the transform because parent node is at world origin)
        selectedNode.transform = SCNMatrix4Mult(selectedNode.transform,SCNMatrix4Invert(parentNodeMatWOTrans));
        
        //add back the local translation mat
        selectedNode.transform = SCNMatrix4Mult(selectedNode.transform, transMat);
        
    }
}

- (void) handleTap:(UIGestureRecognizer*)gestureRecognize {
    if (self.menuOverlayView.intro) {
        [self.menuOverlayView.instructLabel removeFromParent];
    }
    
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    // check what nodes are tapped
    CGPoint p = [gestureRecognize locationInView:scnView];
    NSArray *hitResults = [scnView hitTest:p options:nil];
    
    if (p.x > scnView.frame.size.width-100 || p.y < 100) {//tapped top right corner of screen
        scnView.allowsCameraControl = !scnView.allowsCameraControl;
        if (scnView.allowsCameraControl) {
            self.menuOverlayView.camLabel.text = [NSString stringWithFormat:@"Camera Mode"];
        } else {
            self.menuOverlayView.camLabel.text = [NSString stringWithFormat:@"Object Mode"];
        }
    }
    
    // check that we clicked on at least one object
    if([hitResults count] > 0){
        // retrieved the first clicked object
        SCNHitTestResult *result = [hitResults objectAtIndex:0];
        
        // get its material
        SCNMaterial *material = result.node.geometry.firstMaterial;
        
        selectedNode = result.node;
        
        // highlight it
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.3];
        
        // on completion - unhighlight
        [SCNTransaction setCompletionBlock:^{
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.3];
            material.emission.contents = [UIImage imageNamed:@"art.scnassets/texture.png"];
            [SCNTransaction commit];
        }];
        
        material.emission.contents = [UIColor whiteColor];
        
        [SCNTransaction commit];
    }
    
}


- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end

