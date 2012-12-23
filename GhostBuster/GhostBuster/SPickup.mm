//
//  SPickup.m
//  GhostBuster
//
//  Created by Zero Fancy on 12-12-22.
//
//

#import "SPickup.h"
#import "GameBase.h"
#import	"world.h"
@implementation SPickup
-(id) init
{
	self = [super init];
	[self init_with_xml:@"sprites/base.xml:Cross" ];
	[[GameBase get_game].m_world add_gameobj:self];
	return self;
}

@end
