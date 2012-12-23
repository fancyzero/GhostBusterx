//
//  SpriteXMLParser.h
//  ShotAndRun3
//
//  Created by Fancy Zero on 12-4-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpriteXMLParser : NSObject<NSXMLParserDelegate> 
{
    @public
    NSMutableString*		m_cur_path;
    NSMutableArray*			m_parsers;
	struct sprite_component_def*	m_def;
	std::vector<sprite_part_def>* m_sprite_part_defs;
	SPRITEJOINTDEFS*			  m_sprite_joint_defs;
	NSMutableDictionary*	m_phy_body_defs;//for phybody def db
	NSString*				m_filename;
}

-(id) init:( sprite_component_def*) def;
-(void) dealloc;
@end

@interface SPriteParserBase : NSObject
{
    @public
    SpriteXMLParser* m_xmlparser;
}
-(void) on_node_begin:(NSString*) cur_path  nodename:(NSString *)node_name attributes:(NSDictionary *)attributes;
-(void) on_node_end:(NSString*) cur_path  nodename:(NSString* ) node_name;
@end

@interface anim_parser : SPriteParserBase 
-(void) on_node_begin:(NSString*) cur_path  nodename:(NSString *)node_name attributes:(NSDictionary *)attributes;

@end

@interface phy_parser : SPriteParserBase
{
	phy_body_def* current_body;
}
-(void) on_node_begin:(NSString*) cur_path  nodename:(NSString *)node_name attributes:(NSDictionary *)attributes;

@end

@interface sprite_component_assamble_parser : SPriteParserBase
{
}
-(void) on_node_begin:(NSString*) cur_path  nodename:(NSString *)node_name attributes:(NSDictionary *)attributes;

@end

@interface physic_body_database_parser : SPriteParserBase
{
	phy_body_def* current_body;
}
-(void) on_node_begin:(NSString*) cur_path  nodename:(NSString *)node_name attributes:(NSDictionary *)attributes;

@end

@interface sprite_database_loader : SPriteParserBase
{
	@public
	sprite_def*	current_sprite_def;
	NSString*	m_filename;
	NSString*	m_sprite_name;
}
-(void) on_node_begin:(NSString*) cur_path  nodename:(NSString *)node_name attributes:(NSDictionary *)attributes;
-(void) on_node_end:(NSString*) cur_path  nodename:(NSString* ) node_name;
@end


@interface sprite_component_database_loader : SPriteParserBase
{
@public
	sprite_component_def*	current_def;
	NSString*	m_filename;
	NSString*	m_component_name;
}
-(void) on_node_begin:(NSString*) cur_path  nodename:(NSString *)node_name attributes:(NSDictionary *)attributes;
-(void) on_node_end:(NSString*) cur_path  nodename:(NSString* ) node_name;
@end