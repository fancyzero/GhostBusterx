//
//  GameLayer.m
//  ShotAndRun4
//
//  Created by Zero Fancy on 12-10-21.
//
//

#import "GameLayer.h"

@implementation GameLayer
@synthesize m_move_scale = m_move_scale_;
-(id) init
{
	self = [super init];
	m_move_scale_ = 1;
	return self;
}
@end
