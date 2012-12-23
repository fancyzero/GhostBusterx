//
//  SpriteXMLParser.m
//  ShotAndRun3
//
//  Created by Fancy Zero on 12-4-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#include "Box2D.h"
#import "SpriteBase.h"
#import "SpriteXMLParser.h"
#import "PhysicBodyDefManager.h"
#import "SpriteDefManager.h"
#import "Common.h"

@implementation SPriteParserBase
-(void) on_node_begin:(NSString*) cur_path  nodename:(NSString *)node_name attributes:(NSDictionary *)attributes
{
}
-(void) on_node_end:(NSString*) cur_path  nodename:(NSString* ) node_name
{
}
-(void) dealloc
{
    //NSLog(@"SPriteParserBase dealloc");
    [super dealloc];
}

@end
@implementation SpriteXMLParser
-(id) init:(sprite_component_def*) def
{
	self = [ super init];
    m_cur_path = [ NSMutableString string ];
	//[m_cur_path retain];
    m_parsers = [ NSMutableArray new ];
	m_def = def;
    return self;
}
-(void)dealloc
{
	//int i = [m_cur_path retainCount];
	//[ m_cur_path release];
    for (SPriteParserBase* p in m_parsers) 
    {
        [ p release ];
    }

    [ m_parsers release ];
    [ super dealloc ];
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    //NSLog( @"start element: %@ %@", elementName, namespaceURI);

    for (SPriteParserBase* p in m_parsers) 
    {
        //NSLog(@"parser ref = %d", [ p retainCount ] );
        p->m_xmlparser = self;
        [ p on_node_begin:m_cur_path nodename:elementName attributes:attributeDict ];
    }
    [ m_cur_path appendFormat:@"/%@" , elementName];
    
       
    
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
    //NSLog( @"end element: %@ %@", elementName, namespaceURI);
    NSString* ss = [ m_cur_path stringByDeletingLastPathComponent ];
    m_cur_path = [ NSMutableString stringWithString:ss];
    for (SPriteParserBase* p in m_parsers) 
    {
        [ p on_node_end:m_cur_path nodename:elementName ];
    }    

}

@end

anim_sequence_def read_anim_sequence( NSDictionary* attributes )
{
	anim_sequence_def new_seq;
	if ( [[ attributes valueForKey:@"animated" ] boolValue] )
	{
		new_seq.cell_w = [[ attributes valueForKey:@"cellw" ] intValue];
		new_seq.cell_h = [[ attributes valueForKey:@"cellh" ] intValue];
		new_seq.cell_pad_x = [[ attributes valueForKey:@"cellpadx" ] intValue];
		new_seq.cell_pad_y = [[ attributes valueForKey:@"cellpady" ] intValue];
		new_seq.cells_per_line = [[ attributes valueForKey:@"cellsperline" ] intValue];
		new_seq.frame_cnt = [[ attributes valueForKey:@"framecount" ] intValue];
		new_seq.frame_speed = [[ attributes valueForKey:@"cellw" ] floatValue];
		new_seq.filename = [[ attributes valueForKey:@"texture"]copy];
		new_seq.anim_name = [[ attributes valueForKey:@"name"]copy];
		new_seq.animated = true;
		new_seq.frame_names=[[ attributes valueForKey:@"framenames"] copy];
	}
	else
	{
		new_seq.cell_w = 0;
		new_seq.cell_h = 0;
		new_seq.cell_pad_x = 0;
		new_seq.cell_pad_y = 0;
		new_seq.cells_per_line = 0;
		new_seq.frame_cnt = 1;
		new_seq.frame_speed = 0;
		new_seq.filename = [[ attributes valueForKey:@"texture"] copy];
		new_seq.anim_name = [[ attributes valueForKey:@"name"] copy];
		new_seq.animated = false;
		new_seq.frame_names=[[ attributes valueForKey:@"framenames"] copy];
	}
	[new_seq.frame_names retain];
	[new_seq.anim_name retain];
	[new_seq.filename retain];
	
	if ( [attributes valueForKey:@"anchor_x"] != NULL )
		new_seq.offset_x = [[attributes valueForKey:@"offsetx"] intValue];
	else
		new_seq.offset_x = -10000;
	if ( [attributes valueForKey:@"anchor_y"] != NULL )
		new_seq.offset_y = [[attributes valueForKey:@"offsety"] intValue];
	else
		new_seq.offset_y = -10000;
	return new_seq;
}
@implementation anim_parser

-(void) on_node_begin:(NSString *)cur_path nodename:(NSString *)node_name attributes:(NSDictionary *)attributes
{
    if ( [ cur_path isEqualToString:@"/xml/sprite_def/animation_def" ] )
    {
        if ( [ node_name isEqualToString:@"sequence" ] )
        {
   			m_xmlparser->m_def->m_spr_anim.m_anim_sequences.push_back(read_anim_sequence(attributes));
        }
    }
}
@end



bool read_phy_shapde_def( phy_shape_def* newshape, NSString* node_name, NSDictionary* attributes )
{

	bool sensor = [[ attributes valueForKey:@"is_sensor"] boolValue];

	if ( [ node_name isEqualToString:@"box" ] )
	{
		float w = [[ attributes valueForKey:@"width" ] floatValue];
		float h = [[ attributes valueForKey:@"height"] floatValue];

		newshape->type = pst_box;
		newshape->w = w;
		newshape->h = h;
		//newshape->offset_x = [[ attributes valueForKey:@"offset_x" ] floatValue];
		//newshape->offset_y = [[ attributes valueForKey:@"offset_y" ] floatValue];
		//newshape->rotation = [[ attributes valueForKey:@"rotation" ] floatValue];
		newshape->is_sensor = sensor;
		return true;
	}
	if ( [ node_name isEqualToString:@"circle" ] )
	{
		float r = [[ attributes valueForKey:@"radius" ] floatValue];
		

		newshape->type = pst_circle;
		newshape->radius = r;
		newshape->offset_x = newshape->offset_y = 0;
		newshape->is_sensor = sensor;
		return true;
	}
	if ( [ node_name isEqualToString:@"polygon" ] )
	{

		newshape->type = pst_polygon;
		newshape->offset_x = newshape->offset_y = 0;
		newshape->is_sensor = sensor;
		NSArray* floats = read_float_array( attributes, @"vertices");
		for ( int i=0; i < [floats count]; ++i)
		{
			newshape->float_array.push_back([[floats objectAtIndex:i]floatValue]);
		}
		return true;
	}
	return false;
}

bool read_phy_body_def(phy_body_def* body_def, NSString* node_name, NSDictionary* attributes)
{

	if ( [ node_name isEqualToString:@"body" ] )
	{
		body_def->anchor_point = read_CGPoint_value(attributes, @"anchor",ccp(0.5,0.5));
		if ( [attributes valueForKey:@"url"] != NULL)
		{
			
			phy_body_def *pdef = [[PhysicBodyDefManager get_instance] get_phy_body_def:[attributes valueForKey:@"url"]];
			if ( pdef != NULL )
				*body_def = *pdef;
		}
		if ( [attributes objectForKey:@"type"] != nil )
		{
			if ( [[ attributes valueForKey:@"type"] isEqualToString:@"dynamic"] )
				body_def->type = b2_dynamicBody;
			if ( [[ attributes valueForKey:@"type"] isEqualToString:@"static"] )
				body_def->type = b2_staticBody;
			if ( [[ attributes valueForKey:@"type"] isEqualToString:@"kinematic"] )
				body_def->type = b2_kinematicBody;
		}
		else
			body_def->type = b2_dynamicBody;
        body_def->restitution = [[attributes  valueForKey:@"restitution"] floatValue];
	}
	return true;
}
@implementation phy_parser

-(void) on_node_begin:(NSString *)cur_path nodename:(NSString *)node_name attributes:(NSDictionary *)attributes
{
	if ( [ cur_path isEqualToString:@"/xml/physics_def" ] )
	{
		read_phy_body_def(&m_xmlparser->m_def->m_phy_body, node_name, attributes);
	}
    if ( [ cur_path isEqualToString:@"/xml/physics_def/body" ] )
    {
		phy_shape_def def;
		if ( read_phy_shapde_def( &def, node_name, attributes) )
		{
			m_xmlparser->m_def->m_phy_body.m_phy_shapes.push_back(def);
		}
    }
}

@end

sprite_part_def read_sprite_part_def( NSDictionary* attributes)
{
	sprite_part_def spart;
	
	spart.m_desc = [attributes valueForKey:@"desc"];
	[spart.m_desc retain];
	spart.m_offset = read_CGPoint_value( attributes, @"offset", ccp(0,0));
	spart.m_rotation = read_float_value( attributes, @"rotation");
	return spart;
}

sprite_joint_def read_sprite_joint_def( NSDictionary* attributes)
{
	sprite_joint_def jdef;
	jdef.component_a = read_int_value(attributes, @"component_a");
	jdef.component_b = read_int_value(attributes, @"component_b");
	jdef.joint_flags[0] = read_bool_value(attributes, @"enable_limit");
	jdef.joint_params[0] = read_float_value(attributes, @"up_limit");
	jdef.joint_params[1] = read_float_value(attributes, @"low_limit");
	NSString* str = [ attributes valueForKey:@"type"];
	if ( [ str isEqualToString:@"revolute"])
	{
		jdef.joint_type = e_revoluteJoint;
	}
	return jdef;
}

@implementation sprite_component_assamble_parser

-(void) on_node_begin:(NSString *)cur_path nodename:(NSString *)node_name attributes:(NSDictionary *)attributes
{
    if ( [ cur_path isEqualToString:@"/xml/sprite_components" ] )
    {
		sprite_part_def spart;

        if ( [ node_name isEqualToString:@"sprite_component" ] )
        {
			spart = read_sprite_part_def(attributes);
			m_xmlparser->m_sprite_part_defs->push_back(spart);
        }
    }
	if ( [ cur_path isEqualToString:@"xml/joints"] )
	{
		if ( [ node_name isEqualToString:@"joint" ] )
		{
			read_sprite_joint_def(attributes);
		}

	}
}


@end

@implementation physic_body_database_parser

-(void) on_node_begin:(NSString*) cur_path  nodename:(NSString *)node_name attributes:(NSDictionary *)attributes
{
	if ( [ cur_path isEqualToString:@"/bodies" ] )
	{
		if ( [ node_name isEqualToString:@"body" ] )
		{
			phy_body_def* bdd = new phy_body_def();
			current_body = bdd;
			bdd->anchor_point = read_CGPoint_value(attributes, @"anchor_rel",ccp(0,0));
			[m_xmlparser->m_phy_body_defs setObject:[NSValue valueWithPointer:bdd] forKey: [m_xmlparser->m_filename stringByAppendingFormat:@":%@",[attributes valueForKey:@"name"]]];

		}
	}
    if ( [ cur_path isEqualToString:@"/bodies/body" ] )
    {
		phy_shape_def newshape;
		if ( read_phy_shapde_def(&newshape, node_name, attributes) )
		{
			current_body->m_phy_shapes.push_back(newshape);
		}
	}
}

@end

@implementation sprite_database_loader

-(void) on_node_begin:(NSString*) cur_path  nodename:(NSString *)node_name attributes:(NSDictionary *)attributes
{
    if ( [ cur_path isEqualToString:@"/sprites" ] )
	{
		if ( [node_name isEqualToString:@"sprite"] )
		{
			assert(current_sprite_def == NULL);
			current_sprite_def = new sprite_def();
			current_sprite_def->m_parts.clear();
			current_sprite_def->m_joints.clear();
			m_sprite_name = [attributes valueForKey:@"name"];
		}
	}
	
    if ( [ cur_path isEqualToString:@"/sprites/sprite/sprite_components" ] )
	{
		if ( [node_name isEqualToString:@"sprite_component"] )
		{
			current_sprite_def->m_parts.push_back( read_sprite_part_def(attributes) );
		}
	}
	if ( [ cur_path isEqualToString:@"/sprites/sprite/joints" ] )
	{
		if ( [node_name isEqualToString:@"joint"] )
		{
			current_sprite_def->m_joints.push_back( read_sprite_joint_def(attributes) );
		}
	}

}
-(void) on_node_end:(NSString*) cur_path  nodename:(NSString* ) node_name
{
	if ( [ cur_path isEqualToString:@"/sprites" ] )
	{
		if ( [node_name isEqualToString:@"sprite"] )
		{
			NSString* keyname = [m_filename stringByAppendingFormat:@":%@" ,m_sprite_name];
			[SpriteDefManager add_sprite_def: current_sprite_def :keyname];
			current_sprite_def = NULL;
		}
			
	}
}
@end


@implementation sprite_component_database_loader                                          

-(void) on_node_begin:(NSString*) cur_path  nodename:(NSString *)node_name attributes:(NSDictionary *)attributes
{
    if ( [ cur_path isEqualToString:@"/sprite_components" ] )
	{
		if ( [node_name isEqualToString:@"sprite_component"] )
		{
			assert(current_def == NULL);
			current_def = new sprite_component_def();
			m_component_name = [attributes valueForKey:@"name"];
		}
	}
	
    if ( [ cur_path isEqualToString:@"/sprite_components/sprite_component/physics_def" ] )
	{
		if ( [node_name isEqualToString:@"body"] )
		{
			read_phy_body_def(&current_def->m_phy_body, node_name, attributes);
		}
	}
    if ( [ cur_path isEqualToString:@"/sprite_components/sprite_component/physics_def/body" ] )
	{
		phy_shape_def new_shape;
		if ( read_phy_shapde_def(&new_shape, node_name, attributes));
			current_def->m_phy_body.m_phy_shapes.push_back(new_shape);
	}
	
    if ( [ cur_path isEqualToString:@"/sprite_components/sprite_component/animation_def" ] )
	{
		phy_shape_def new_shape;
		current_def->m_spr_anim.m_anim_sequences.push_back(read_anim_sequence(attributes));
	}
}
-(void) on_node_end:(NSString*) cur_path  nodename:(NSString* ) node_name
{
	if ( [ cur_path isEqualToString:@"/sprite_components" ] )
	{
		if ( [node_name isEqualToString:@"sprite_component"] )
		{
			NSString* keyname = [m_filename stringByAppendingFormat:@":%@" ,m_component_name];
			[SpriteDefManager add_sprite_component_def: current_def :keyname];
			current_def = NULL;
		}
		
	}
}
@end