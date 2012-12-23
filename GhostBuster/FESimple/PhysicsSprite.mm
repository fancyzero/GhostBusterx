//
//  PhysicsSprite.mm
//  ShotAndRun4
//
//  Created by Fancy Zero on 12-7-19.
//  Copyright __MyCompanyName__ 2012年. All rights reserved.
//


#import "PhysicsSprite.h"
#import "cocos2d.h"
#import "Box2D.h"
#import "GameBase.h"
#import "world.h"
#import "common.h"
#import "GameLayer.h"


#pragma mark - PhysicsSprite
@implementation PhysicsSprite
@synthesize m_color_mask = m_color_mask_;
@synthesize m_mask_color = m_mask_color_;
@synthesize m_zorder = m_zorder_;
@synthesize m_offset = m_offset_;
@synthesize m_phy_body = m_phy_body_;
@synthesize m_color_override_endtime = m_color_override_endtime_;



-(void) setM_position:(CGPoint)pos
{
	m_position_ = pos;
	[super setPosition:pos];
	[self set_physic_position: pos ];
}

-(CGPoint) m_position
{
	return m_position_;
}

-(void) setM_rotation:(float) rot
{
	m_rotation_ = rot;
	[super setRotation:rot];
	[self set_physic_rotation:rot ];
}

-(float) m_rotation
{
	return m_rotation_;
}

-(void) set_phy_body:(b2Body *)body
{
	m_phy_body_ = body;
}

-(void) init_shader
{
	CCGLProgram * p = [[CCShaderCache sharedShaderCache] programForKey:@"base_shader"];
	super.shaderProgram = p;
}

-(id) init
{
    self = [super init];
	m_anim_sequences_ = [ NSMutableDictionary new];
    m_mask_color_ = ccc4f(1.0,1.0,1.0,1.0);
	m_parent_ = NULL;
	m_component_def = NULL;
	m_color_mask_ = 0;
	m_color_override_endtime_ = 0;
	[self init_shader];
    return self;
}

-(int) init_by_sprite_component_def:(struct sprite_component_def*) def
{
	m_component_def = def;
	int ret;
	ret = [self init_physics: &def->m_phy_body ];
	if ( ret < 0 )
		return ret;
	
	ret = [ self init_animations: &def->m_spr_anim];
	
	[self play_anim_sequence:@"default"];

	return ret;
}

-(void) play_anim_sequence:(NSString *)name
{
    if ( m_current_anim_sequence_ != NULL )
        [ self stopAction:m_current_anim_sequence_ ];
    
    NSValue* seq_val = [ m_anim_sequences_ objectForKey:name ];
    CCAction* act = (CCAction*)[seq_val pointerValue ];
        
	m_current_anim_sequence_ = act;
	[ self runAction:act];
}
-(int) init_animations:(spr_anim_def*) anims
{
	
	for ( ANIM_SEQUENCES::iterator it = anims->m_anim_sequences.begin(); it != anims->m_anim_sequences.end(); ++it )
	{
		//anim_sequence_def* seq = new anim_sequence_def();//todo use another struct to save actions
		//*seq = (*it);
		//seq->filename = NULL;
		//seq->name = NULL;
		// seq->framenames = NULL;
		NSMutableArray *Frames = [NSMutableArray array];//todo memory leak?
		CCSpriteFrame* frame;
		
		if ( [[(*it).filename pathExtension] isEqualToString:@"plist"] )
		{
			[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:(*it).filename];
			NSArray* framenames = [(*it).frame_names componentsSeparatedByString:@","];
			for( int i=0; i < [framenames count]; i++ )
			{
				frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[framenames objectAtIndex:i]];
				[Frames addObject:frame];
				//NSLog(@"frame ratain count:%d",[frame retainCount]);
			}
		}
		else
		{
			CCTexture2D* tex = [ [ CCTextureCache  sharedTextureCache ] addImage:(*it).filename];

			
			if ( (*it).animated )
			{
				for(int i = 0; i < (*it).frame_cnt; ++i)
				{
					frame = [ CCSpriteFrame frameWithTexture:tex rect:CGRectMake( (i%(*it).cells_per_line)*((*it).cell_w+(*it).cell_pad_x),
																				 i/(*it).cells_per_line*((*it).cell_h+(*it).cell_pad_y),
																				 (*it).cell_w, (*it).cell_h) ];
					[Frames addObject:frame];
				}
			}
			else
			{
				frame = [ CCSpriteFrame frameWithTexture:tex rect:CGRectMake( 0,0, tex.contentSizeInPixels.width, tex.contentSizeInPixels.height )];
				//NSLog(@"frame ratain count:%d",[frame retainCount]);

				[Frames addObject:frame];
			}
		}
		CCAnimation *anim = [CCAnimation animationWithSpriteFrames:Frames delay:0.1f ];
		//NSLog(@"frames ratain count:%d",[Frames retainCount]);
		//[Frames release];
		CCAction*   act = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim ]];
		//NSLog(@"frames ratain count:%d",[act retainCount]);
		//seq->act = act;
		
		[m_anim_sequences_ setObject:[ NSValue valueWithPointer:act ] forKey:(*it).anim_name ];//todo use another struct to save actions
	}
	return 0;
	
}



-(void) clear_physics
{
	GameBase* game = [ GameBase get_game];
	if ( m_phy_body_ != NULL )
	{
		game.m_world.m_physics_world->DestroyBody(m_phy_body_);
	}
	m_phy_body_ = NULL;
	
}

-(int) init_physics:(phy_body_def*) def
{
	super.anchorPoint = def->anchor_point;
	if (def->m_phy_shapes.size() <= 0 )
		return 0;
	
	GameBase* game = [ GameBase get_game];
	
	float ptm = [ GameBase get_ptm_ratio];
	[ self clear_physics];
	//delete all fixturedef first



	b2BodyDef bodydef;

	bodydef.type = (b2BodyType)def->type;

	
	bodydef.position = b2Vec2( (m_position_.x + def->offset.x )/[GameBase get_ptm_ratio], (m_position_.y+def->offset.y)/[GameBase get_ptm_ratio] );
	bodydef.angle = CC_DEGREES_TO_RADIANS(m_rotation_);
	b2Body* bdy = game.m_world.m_physics_world->CreateBody(&bodydef);
	
	PHY_SHAPES::const_iterator it2 = def->m_phy_shapes.begin();
	for( ; it2 !=  def->m_phy_shapes.end(); ++it2 )
	{
		const phy_shape_def* s;
		b2Shape* b2s;
		s = &(*it2);
		
		b2CircleShape cs;
		b2PolygonShape ps;
		if ( s->type == pst_circle )
		{
			cs.m_type = b2Shape::e_circle;
			cs.m_radius = s->radius * scaleX_/ptm;
			cs.m_p.x = s->offset_x * scaleX_/ptm;
			cs.m_p.y = s->offset_y * scaleY_/ptm;
			b2s = &cs;
		}
		else if ( s->type == pst_box)
		{
			ps.SetAsBox(s->w * scaleX_/ptm, s->h * scaleY_/ptm,b2Vec2(s->offset_x*scaleX_/ptm,s->offset_y*scaleY_/ptm), s->rotation);
			ps.m_type = b2Shape::e_polygon;
			b2s = &ps;
		}
		else if ( s->type == pst_polygon)
		{
			ps.m_type = b2Shape::e_polygon;
			b2Vec2* vecs = new b2Vec2[s->float_array.size()/2];
			b2Vec2* p = vecs;
			for( std::vector<float>::const_iterator i = s->float_array.begin(); i != s->float_array.end(); )
			{
				p->x = (*i)* scaleX_/ptm;
				++i;
				p->y = (*i)* scaleY_/ptm;
				++i;
				p++;
			}
			ps.Set(vecs, s->float_array.size()/2);
			b2s = &ps;
			delete[] vecs;
		}
		b2FixtureDef fixtureDef;
		fixtureDef.shape = b2s;
		fixtureDef.isSensor = s->is_sensor;
		fixtureDef.userData = self;
		fixtureDef.density = 1;
        fixtureDef.restitution = def->restitution;
		bdy->CreateFixture(&fixtureDef);
		bdy->SetAwake(true);
	}
	m_phy_body_	= bdy;
	return 0;
}



// this method will only get called if the sprite is batched.
// return YES if the physics values (angles, position ) changed
// If you return NO, then nodeToParentTransform won't be called.
-(BOOL) dirty
{
    if ( m_phy_body_ == NULL )
        return NO;
	return YES;
}
-(void) set_shader_parameters
{
	if ( current_game_time() < m_color_override_endtime_ )
	{
		[ self set_shader_parameter: "u_mask_color" param_color:m_mask_color_];
		[ self set_shader_parameter: "u_color_mask" param_f1:m_color_mask_ ];
	}
	else
	{
//		[ self set_shader_parameter: "u_mask_color" param_color:m_mask_color_];
		[ self set_shader_parameter: "u_color_mask" param_f1:0 ];
	}
}

-(void) draw
{
//	CGRect rc = self.layer_bounding_box;
//	rc.origin = ccpMult(rc.origin, [ self get_layer].m_move_scale );
	CGRect rc;
	rc.size = [CCDirector sharedDirector].winSizeInPixels;
	rc.origin = ccp(0,0);
	if ( !CGRectIntersectsRect(rc, self.world_bounding_box ) )
		return;
	//if ( is_outof_acting_range(self.m_position, self.boundingBox ))
	//	return;
	CC_PROFILER_START_CATEGORY(kCCProfilerCategorySprite, @"CCSprite - draw");
    
	NSAssert(!batchNode_, @"If CCSprite is being rendered by CCSpriteBatchNode, CCSprite#draw SHOULD NOT be called");
    
	CC_NODE_DRAW_SETUP();
	[ self set_shader_parameters ];

    
	ccGLBlendFunc( blendFunc_.src, blendFunc_.dst );
    
	ccGLBindTexture2D( [texture_ name] );
    
	//
	// Attributes
	//
    
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_PosColorTex );
    
#define kQuadSize sizeof(quad_.bl)
	long offset = (long)&quad_;
    
	// vertex
	NSInteger diff = offsetof( ccV3F_C4B_T2F, vertices);
	glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, kQuadSize, (void*) (offset + diff));
    
	// texCoods
	diff = offsetof( ccV3F_C4B_T2F, texCoords);
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, (void*)(offset + diff));
    
	// color
	diff = offsetof( ccV3F_C4B_T2F, colors);
	glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (void*)(offset + diff));
    
    
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
	CHECK_GL_ERROR_DEBUG();
    
    
#if CC_SPRITE_DEBUG_DRAW == 1
	// draw bounding box
	CGPoint vertices[4]={
		ccp(quad_.tl.vertices.x,quad_.tl.vertices.y),
		ccp(quad_.bl.vertices.x,quad_.bl.vertices.y),
		ccp(quad_.br.vertices.x,quad_.br.vertices.y),
		ccp(quad_.tr.vertices.x,quad_.tr.vertices.y),
	};
	ccDrawPoly(vertices, 4, YES);
#elif CC_SPRITE_DEBUG_DRAW == 2
	// draw texture box
	CGSize s = self.textureRect.size;
	CGPoint offsetPix = self.offsetPosition;
	CGPoint vertices[4] = {
		ccp(offsetPix.x,offsetPix.y), ccp(offsetPix.x+s.width,offsetPix.y),
		ccp(offsetPix.x+s.width,offsetPix.y+s.height), ccp(offsetPix.x,offsetPix.y+s.height)
	};
	ccDrawPoly(vertices, 4, YES);
#endif // CC_SPRITE_DEBUG_DRAW
    
	CC_INCREMENT_GL_DRAWS(1);
    
	CC_PROFILER_STOP_CATEGORY(kCCProfilerCategorySprite, @"CCSprite - draw");
}

-(void) set_shader_parameter:(const GLchar*)name param_f1:(float) f1
{
    GLint loc = glGetUniformLocation( shaderProgram_->program_, name);
    if ( loc >=0 )
        [ shaderProgram_ setUniformLocation:loc withF1:f1];
}

-(void) set_shader_parameter:(const GLchar*)name param_color:(ccColor4F) c
{
    GLint loc = glGetUniformLocation( shaderProgram_->program_, name);
    if ( loc >= 0 )
        [ shaderProgram_ setUniformLocation:loc withF1:c.r f2:c.g f3:c.b f4:c.a];
}
// returns the transform matrix according the Chipmunk Body values
-(CGAffineTransform) nodeToParentTransform
{
    if ( m_phy_body_ == NULL )
    {
        return [ super nodeToParentTransform ];
    }
	b2Vec2 pos  = m_phy_body_->GetPosition();
	
	float x = pos.x * [GameBase get_ptm_ratio];
	float y = pos.y * [GameBase get_ptm_ratio];
	
	if ( ignoreAnchorPointForPosition_ )
	{
		x += anchorPointInPoints_.x;
		y += anchorPointInPoints_.y;
	}
	
	// Make matrix
	float radians = m_phy_body_->GetAngle();
	float c = cosf(radians);
	float s = sinf(radians);
	
	if( ! CGPointEqualToPoint(anchorPointInPoints_, CGPointZero) ){
		x += c*-anchorPointInPoints_.x*scaleX_ + -s*-anchorPointInPoints_.y*scaleY_;
		y += s*-anchorPointInPoints_.x*scaleX_ + c*-anchorPointInPoints_.y*scaleY_;
	}
	
	// Rot, Translate Matrix
	transform_ = CGAffineTransformMake( c*scaleX_,  s*scaleX_,
									   -s*scaleY_,	c*scaleY_,
									   x,	y );
	
	return transform_;
}

-(void) dealloc
{
	[ self clear_physics];
	//NSLog(@"m_anim_sequences_ retaincount %d:",[ m_anim_sequences_ retainCount]);
	[ m_anim_sequences_ release];
	[super dealloc];
}
-(void)set_physic_position:(CGPoint) pos
{
    if ( m_phy_body_ == NULL )
        return;
	
    m_phy_body_->SetTransform( b2Vec2(pos.x/[ GameBase get_ptm_ratio ],pos.y/[ GameBase get_ptm_ratio ]), m_phy_body_->GetAngle() );
    m_phy_body_->SetAwake(TRUE);
}
-(void)set_physic_angular_velocity:(float) v
{
    if ( m_phy_body_ != NULL)
        m_phy_body_->SetAngularVelocity(v);

}

-(void) set_physic_fixed_rotation: (bool) fixed
{
	if ( m_phy_body_ != NULL)
		m_phy_body_->SetFixedRotation(fixed);
}
-(void)set_physic_angular_damping:(float) d
{
	if ( m_phy_body_ != NULL)
        m_phy_body_->SetAngularDamping(d);
}

-(void) set_physic_linear_velocity: (float)x :(float)y
{
	if ( m_phy_body_ != NULL)
        m_phy_body_->SetLinearVelocity( b2Vec2(x, y));
}

-(void) apply_linear_impulse:(float)speed_x speed_y:(float)speed_y
{
	if ( m_phy_body_ != NULL)
		m_phy_body_->ApplyLinearImpulse(b2Vec2(speed_x, speed_y), m_phy_body_->GetPosition());
}

-(void) apply_force_center:(float)force_x force_y:(float)force_y
{
	if ( m_phy_body_ != NULL)
		m_phy_body_->ApplyForce(b2Vec2(force_x, force_y), m_phy_body_->GetPosition() );
}

-(void) apply_torque:(float)t
{
	if ( m_phy_body_ != NULL)
		m_phy_body_->ApplyTorque(t);
}

-(void) clamp_physic_maxspeed: (float) max_speed
{
	if ( m_phy_body_ != NULL)
	{
		b2Vec2 v = m_phy_body_->GetLinearVelocity();
		b2Vec2 dir = v;
		dir.Normalize();
		float len = v.Length();
		if ( len > max_speed )
			len = max_speed;
		dir *= len;
		m_phy_body_->SetLinearVelocity(dir);
	}
}

-(void) set_physic_linear_damping :(float) damping
{
	if ( m_phy_body_ != NULL )
		m_phy_body_->SetLinearDamping(damping);
}
-(void) set_physic_rotation:(float) angle
{
    if ( m_phy_body_ != NULL )
	{
		b2Vec2 pos = m_phy_body_->GetPosition();
		
		m_phy_body_->SetTransform( pos, angle*0.01745329252f );
		m_phy_body_->SetAwake(TRUE);
	}
}
-(float) get_physic_angular_velocity
{
	if ( m_phy_body_ != NULL)
	{
		return m_phy_body_->GetAngularVelocity();
	}
	else
	{
		return 0;
	}
}
-(CGPoint) get_physic_linear_velocity
{
	CGPoint ret;
	ret.x = ret.y = 0;
	if ( m_phy_body_ != NULL )
	{
		ret.x = m_phy_body_->GetLinearVelocity().x;
		ret.y = m_phy_body_->GetLinearVelocity().y;
		return ret;
	}
	else
	{
		return ret;
	}
}

-(CGPoint) get_physic_position
{
	if ( m_phy_body_ == NULL)
	{
		CGPoint ret;
		ret.x = ret.y = 0;
		return ret;
	}
	float ptm = [ GameBase get_ptm_ratio];
	CGPoint ret;
	ret.x = m_phy_body_->GetPosition().x*ptm;
	ret.y = m_phy_body_->GetPosition().y*ptm;
	return ret;
}

-(float) get_physic_rotation
{
	if ( m_phy_body_ == NULL )
		return 0;
	return m_phy_body_->GetAngle()/0.01745329252f;
}

-(void) sync_physic_to_sprite
{
	if ( m_phy_body_ != NULL )
	{
		m_position_ = [ self get_physic_position];
		m_rotation_ = [ self get_physic_rotation];
		[self setPosition:m_position_];
		[self setRotation:m_rotation_];

	}
	
}

-(void) set_collision_filter:(int)mask  cat:(int) cat
{
	if ( m_phy_body_ )
	{
		b2Fixture* fix = m_phy_body_->GetFixtureList();
		while (fix)
		{
			b2Filter ft;
			ft.maskBits = mask;
			ft.categoryBits = cat;
			ft.groupIndex = 0;
			
			fix->SetFilterData(ft);
			fix = fix->GetNext();
		}

	}
}

struct fixture_def
{
	b2Filter filter;
};

-(void) set_scale:(float) scalex :(float)scaley
{
	super.scaleX = scalex;
	super.scaleY = scaley;

	if ( (m_component_def != NULL) )
	{
		//back up some data
		std::vector<fixture_def> fixture_def_backup;
		b2Vec2	velocity_speed;
		float	angular_speed;
		if ( m_phy_body_ != NULL)
		{
			b2Fixture* f = m_phy_body_->GetFixtureList();

			velocity_speed = m_phy_body_->GetLinearVelocity();
			angular_speed = m_phy_body_->GetAngularVelocity();
			
			while( f != NULL )
			{
				fixture_def fdef;
				fdef.filter = f->GetFilterData();
				fixture_def_backup.push_back(fdef);
				f = f->GetNext();
			}
		}
		[ self init_physics: &m_component_def->m_phy_body];
		
		if ( m_phy_body_ != NULL)
		{
			b2Fixture* f = m_phy_body_->GetFixtureList();
			int idx = 0;
			while( f != NULL )
			{
				if ( idx > fixture_def_backup.size())
					break;
				f->SetFilterData(fixture_def_backup[idx].filter);
				f = f->GetNext();
				idx ++;
			}
			m_phy_body_->SetLinearVelocity(velocity_speed);
		}
	}
}

-(void) set_color_override :( ccColor4F ) color mask:(float) mask  duration:(float) duration
{
	m_color_mask_ = mask;
	m_mask_color_ = color;
	m_color_override_endtime_ = duration + current_game_time();
}

-(CGRect) world_bounding_box
{
	CGRect rect = CGRectMake(0, 0, contentSize_.width, contentSize_.height);
	return CGRectApplyAffineTransform(rect, [self nodeToWorldTransform]);
}

-(CGRect) layer_bounding_box
{
	CGRect rect = CGRectMake(0, 0, contentSize_.width, contentSize_.height);
	CGAffineTransform t = convert_transform_to_layer_space(self);
	return CGRectApplyAffineTransform( rect, t );
}

-(GameLayer*) get_layer
{
	CCNode *p ;
	for ( p = self.parent; p != nil; p = p.parent)
	{
		if ( [p isKindOfClass: [GameLayer class]] )
			break;
	}
	return (GameLayer*)p;
}
@end

