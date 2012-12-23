//
//  SpriteDefManager.m
//  ShotAndRun3
//
//  Created by Fancy Zero on 12-6-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SpriteDefManager.h"
#import "SpriteBase.h"
#import "SpriteXMLParser.h"
#import "CCFileUtils.h"
#import "GameBase.h"
#import "SpriteXMLParser.h"


NSMutableDictionary* sprite_defs = NULL;
NSMutableDictionary* sprite_component_defs = NULL;
@implementation SpriteDefManager

+(void) add_sprite_component_def: ( struct sprite_component_def*) def :(NSString*) name
{
	if ( sprite_component_defs == NULL )
        sprite_component_defs = [ NSMutableDictionary new];
	[ sprite_component_defs setObject:[ NSValue valueWithPointer:def] forKey:name];
}

+(void) add_sprite_def: ( struct sprite_def*) def :(NSString*) name
{
	if ( sprite_defs == NULL )
        sprite_defs = [ NSMutableDictionary new];
	[ sprite_defs setObject:[ NSValue valueWithPointer:def] forKey:name];
}

+(struct sprite_def*) load_sprite_def : (NSString*) filename
{
	if ( sprite_defs == NULL )
        sprite_defs = [ NSMutableDictionary new];
    if ( [ sprite_defs valueForKey:filename ] != NULL )
        return (struct sprite_def*)[[ sprite_defs valueForKey:filename ] pointerValue ];
    sprite_def* def = new sprite_def();
	
    NSURL *xmlURL = [NSURL fileURLWithPath:[[CCFileUtils sharedFileUtils] fullPathFromRelativePath:filename]];
    NSXMLParser* xmlparser = [[ NSXMLParser alloc ] initWithContentsOfURL:xmlURL];
    SpriteXMLParser* my_parser = [[ SpriteXMLParser alloc ] init:NULL];
    my_parser->m_sprite_part_defs = &def->m_parts;
    [ xmlparser setDelegate:my_parser ];
    
    [ my_parser->m_parsers addObject:[ sprite_component_assamble_parser new ]];

    [ xmlparser parse ];
	
    [ my_parser release];
	[ xmlparser release ];
    [ sprite_defs setObject: [ NSValue valueWithPointer:def] forKey:filename];
    return def;
}




+( sprite_component_def*) load_sprite_component_def : (NSString*) filename
{
    if ( sprite_component_defs == NULL )
        sprite_component_defs = [ NSMutableDictionary new];
    if ( [ sprite_component_defs valueForKey:filename ] != NULL )
	{
		struct sprite_component_def* def;
		def = (struct sprite_component_def*)[[ sprite_component_defs valueForKey:filename ] pointerValue ];
        return def;
	}
    sprite_component_def* def = new sprite_component_def();

    NSURL *xmlURL = [NSURL fileURLWithPath:[[CCFileUtils sharedFileUtils] fullPathFromRelativePath:filename]];
    NSXMLParser* xmlparser = [[ NSXMLParser alloc ] initWithContentsOfURL:xmlURL];
    SpriteXMLParser* my_parser = [[ SpriteXMLParser alloc ] init:def];
    
    [ xmlparser setDelegate:my_parser ];
    
    [ my_parser->m_parsers addObject:[ phy_parser new ]];
    [ my_parser->m_parsers addObject:[ anim_parser new ]];
	
	
    [ xmlparser parse ];
    [ my_parser release];
	[ xmlparser release ];
    [ sprite_component_defs setObject: [ NSValue valueWithPointer:def] forKey:filename];
	NSLog(@"xmlurl retain count :%d", [ xmlURL retainCount ]);
    return def;
}

+(void) load_sprite_def_database:(NSString*) filename
{
	NSURL *xmlURL = [NSURL fileURLWithPath:[[CCFileUtils sharedFileUtils] fullPathFromRelativePath:filename]];
    NSXMLParser* xmlparser = [[ NSXMLParser alloc ] initWithContentsOfURL:xmlURL];
    SpriteXMLParser* my_parser = [[ SpriteXMLParser alloc ] init:NULL];
    [ xmlparser setDelegate:my_parser ];
    sprite_database_loader* loader = [ sprite_database_loader new ];
	loader->m_filename = filename;
	loader->current_sprite_def = NULL;
    [ my_parser->m_parsers addObject:loader];

    [ xmlparser parse ];
    [ my_parser release];
	[ xmlparser release ];
}

+(void) load_sprite_component_def_database:(NSString*) filename
{
	NSURL *xmlURL = [NSURL fileURLWithPath:[[CCFileUtils sharedFileUtils] fullPathFromRelativePath:filename]];
    NSXMLParser* xmlparser = [[ NSXMLParser alloc ] initWithContentsOfURL:xmlURL];
    SpriteXMLParser* my_parser = [[ SpriteXMLParser alloc ] init:NULL];
    [ xmlparser setDelegate:my_parser ];
    sprite_component_database_loader* loader = [ sprite_component_database_loader new ];
	loader->m_filename = filename;
	loader->current_def = NULL;
    [ my_parser->m_parsers addObject:loader];
	
    [ xmlparser parse ];
    [ my_parser release];
	[ xmlparser release ];
}
@end
