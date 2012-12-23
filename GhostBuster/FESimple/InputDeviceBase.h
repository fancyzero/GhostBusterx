//
//  InputDeviceBase.h
//  ShotAndRun4
//
//  Created by Zero Fancy on 12-11-22.
//
//

#import <Foundation/Foundation.h>
@class Controller;
@interface InputDeviceBase : NSObject
{
@protected
	Controller* m_controller_;
}

-(Controller*) get_controller;
-(void) set_controller :(Controller*) ctrl;
-(void) set_controller2 :(Controller*) ctrl;
@end
