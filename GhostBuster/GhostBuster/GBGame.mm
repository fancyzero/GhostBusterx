//
//  GBGame.m
//  GhostBuster
//
//  Created by Zero Fancy on 12-12-15.
//
//
#import "cocos2d.h"
#import "GameBase.h"
#import "GBGame.h"
#import	"GBLevel.h"
#import "SpriteDefManager.h"
@implementation GBGame 
-(id) init
{
	self = [super init];
	[GameBase set_game:self];
	NSString *path = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:@"game_config.plist"];
	global_config = [NSDictionary dictionaryWithContentsOfFile:path];
	[global_config retain];

	return self;
}

-(id) get_config_value:(NSString*) key
{
	return [global_config valueForKey:key];
}
-(bool) init_shaders
{
    
	
	CCGLProgram *p = [[CCGLProgram alloc] initWithVertexShaderFilename:@"shaders/base.vs.fsh"
												fragmentShaderFilename:@"shaders/base.ps.fsh"];
    
	[p addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
	[p addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
	[p addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
    
	[p link];
	[p updateUniforms];
    
    [[CCShaderCache sharedShaderCache] addProgram:p forKey:@"base_shader"];
	[p release];
    
	CHECK_GL_ERROR_DEBUG();
    return true;
}

-(int) init_default //just need call onec per run
{
    [ self init_shaders];
	[ SpriteDefManager load_sprite_def_database:@"sprites/base.xml" ];
	[ SpriteDefManager load_sprite_component_def_database:@"sprite_components/base.xml" ];
	[super init_default];
	
    [self init_game ];
    
	
    return 0;
}


-(void) init_game
{
	
	[super init_game];

	m_level_ = [GBLevel new];

	[m_level_ reset];
	[m_level_ load_from_file:@"levels/level1.xml"];	
	
}
@end
