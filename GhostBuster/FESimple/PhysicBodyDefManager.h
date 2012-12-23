//
//  PhyaicBodyDefManager.h
//  ShotAndRun4
//
//  Created by Zero Fancy on 12-9-1.
//
//

#import <Foundation/Foundation.h>

@interface PhysicBodyDefManager : NSObject
{
	NSMutableDictionary*	m_body_defs;
}
+(PhysicBodyDefManager*) get_instance;

-(struct phy_body_def*) get_phy_body_def:(NSString*) url;//url=filename+bodyname

@end
