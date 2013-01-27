//
//  SPlayer.h
//  GhostBuster
//
//  Created by Zero Fancy on 12-12-16.
//
//

#import "GBSpriteBase.h"
@class CCLabelTTF;
@interface SPlayer : GBSpriteBase<CCTargetedTouchDelegate>
{
	@public
	CGPoint movedir;
	CGPoint m_touch_begin_pos;
    float   m_inter_collision_radius;
    float   m_wall_collision_radius;
    int m_id;
	float	m_alive_counter;
	CCLabelTTF*		m_alive_counter_label;
	float  m_dir_controller_length;
	float  m_score;

}
-(id) init_with_id:(int) id;
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event;
-(void) set_id:(int) id;
@end
