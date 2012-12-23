#import "cocos2d.h"
#import "Box2D.h"
#import "PhysicsDebuger.h"
#import "World.h"
#import "GameBase.h"
@implementation physics_debug_sprite
-(void) draw
{
    //glDisable(GL_TEXTURE_2D);
	//glDisableClientState(GL_COLOR_ARRAY);
	//glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    //glPushMatrix();
    //glScalef( CC_CONTENT_SCALE_FACTOR(), CC_CONTENT_SCALE_FACTOR(), 1.0f);
    
    [ GameBase get_game ].m_world.m_physics_world->DrawDebugData();
    //glPopMatrix();
    //glEnable(GL_TEXTURE_2D);
    //glEnableClientState(GL_COLOR_ARRAY);
    //glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}
@end