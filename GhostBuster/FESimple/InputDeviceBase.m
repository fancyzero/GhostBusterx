//
//  InputDeviceBase.m
//  ShotAndRun4
//
//  Created by Zero Fancy on 12-11-22.
//
//

#import "InputDeviceBase.h"

@implementation InputDeviceBase
-(void) set_controller :(Controller*) ctrl
{
	m_controller_ = ctrl;
}
-(void) set_controller2 :(Controller*) ctrl
{
	m_controller_ = ctrl;
}
-(Controller*)	get_controller
{
	return m_controller_;
}
@end
