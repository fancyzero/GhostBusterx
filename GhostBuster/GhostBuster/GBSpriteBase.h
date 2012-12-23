//
//  GBSpriteBase.h
//  GhostBuster
//
//  Created by FancyZero on 12-12-18.
//
//

#import "SpriteBase.h"
enum GBRole
{
    role_ghost,
    role_player,
};
@interface GBSpriteBase : SpriteBase
{
            float m_speed;
    int m_role;
}
-(int) get_role;
-(void) set_role:(int) role;
@end
