//
//  PhyaicBodyDefManager.m
//  ShotAndRun4
//
//  Created by Zero Fancy on 12-9-1.
//
//

#import "PhysicBodyDefManager.h"
#include <vector>
#import "PhysicsSprite.h"
#import "SpriteXMLParser.h"
#import "CCFileUtils.h"

PhysicBodyDefManager* g_pddm = NULL;
@implementation PhysicBodyDefManager
+(PhysicBodyDefManager*) get_instance
{
	if ( g_pddm == NULL )
		g_pddm = [PhysicBodyDefManager new];
	return g_pddm;
}

-(struct phy_body_def*) get_phy_body_def:(NSString*) url
{
	if ( m_body_defs == NULL )
		m_body_defs = [NSMutableDictionary new];
	id v = [m_body_defs valueForKey: url];
	if ( v != NULL )
	{
		return (phy_body_def*)[v pointerValue];
	}
	else
	{
		NSString* filename;
		NSArray* tmp = [url componentsSeparatedByString:@":"];
		if ( [tmp count] < 2)
			return NULL;
		filename = [tmp objectAtIndex:0];
		NSURL *xmlURL = [NSURL fileURLWithPath:[[CCFileUtils sharedFileUtils] fullPathFromRelativePath:filename]];
		NSXMLParser* xmlparser = [[ NSXMLParser alloc ] initWithContentsOfURL:xmlURL];
		SpriteXMLParser* my_parser = [[ SpriteXMLParser alloc ] init:NULL];
		my_parser->m_phy_body_defs = m_body_defs;
		my_parser->m_filename = filename;
		[ xmlparser setDelegate:my_parser ];
		
		[ my_parser->m_parsers addObject:[ physic_body_database_parser new ]];
		
		[ xmlparser parse ];
		
		[ my_parser release];
		//[ xmlparser release];
	}
	v = [m_body_defs valueForKey: url];
	if ( v != NULL)
		return (phy_body_def*)[v pointerValue];
	else
		return NULL;
}
@end
