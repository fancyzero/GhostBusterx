//
//  IOSInputDevice.h
//  ShotAndRun4
//
//  Created by Zero Fancy on 12-11-22.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "InputDeviceBase.h"
@class Controller;


@interface IOSInputDevice : InputDeviceBase<CCTargetedTouchDelegate,CCStandardTouchDelegate>
{

}
-(id) init;
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event;

//- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event;

@end
