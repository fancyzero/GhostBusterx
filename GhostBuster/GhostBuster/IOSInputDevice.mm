//
//  IOSInputDevice.m
//  ShotAndRun4
//
//  Created by Zero Fancy on 12-11-22.
//
//

#import "IOSInputDevice.h"
#import "Controller.h"
@implementation IOSInputDevice
-(id) init
{
	self = [super init];
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:TRUE];
	[[[CCDirector sharedDirector] touchDispatcher] addStandardDelegate:self priority:0];
	return self;
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if ( m_controller_ == NULL )
		return FALSE;
	CGPoint location = [touch locationInView:[touch view]];
	return [ m_controller_ on_touch_begin:location ];
	
}
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	if ( m_controller_ == NULL )
		return;
	CGPoint location = [touch locationInView:[touch view]];
	CGPoint prev_location = [touch previousLocationInView:[touch view]];
	[ m_controller_ on_touch_move:location :prev_location];
	
}
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	if ( m_controller_ == NULL )
		return;
	CGPoint location = [touch locationInView:[touch view]];
	[ m_controller_ on_touch_end:location ];
	
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( m_controller_ == NULL )
        return;
    std::vector<touch_info> touch_infos;
    for (UITouch* touch in touches)
    {
        touch_info ti;
        CGPoint location = [touch locationInView:[touch view]];
        
        ti.touch_pos = location;
        touch_infos.push_back(ti);
    }
    [m_controller_ on_touches_began:touch_infos];
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( m_controller_ == NULL )
        return;
    std::vector<touch_info> touch_infos;
    for (UITouch* touch in touches)
    {
        touch_info ti;
        CGPoint location = [touch locationInView:[touch view]];
        
        ti.touch_pos = location;
        touch_infos.push_back(ti);
    }
    [m_controller_ on_touches_ended:touch_infos];
}

@end
