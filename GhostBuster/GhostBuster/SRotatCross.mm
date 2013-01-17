//
//  SRotat_Cross.m
//  GhostBuster
//
//  Created by Zero Fancy on 13-1-17.
//
//

#import "SRotatCross.h"
#import	"GameBase.h"
@implementation SRotatCross
-(void) update:(float)delta_time
{
	[ super update:delta_time];
	[self set_collision_filter:1+2+4+8+16+32 cat:1];
	[self set_physic_angular_velocity:0 :0.5];
	//[self set_physic_rotation:0 :[GameBase current_time] * 180 ];
}
@end
