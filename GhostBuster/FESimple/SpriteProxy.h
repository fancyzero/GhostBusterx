

#include <vector>

@class SpriteBase;
@class PhysicsSprite;
@interface SpriteProxyBase : NSObject
{
	@protected
	SpriteBase* m_sprite_;
};
-(void) set_sprite:(SpriteBase*) sprite;
@end


@interface SpriteHitProxy : SpriteProxyBase
{
	CGPoint m_picked_offset_;
}
-(std::vector<PhysicsSprite*>) pick :( CGPoint) loc;
-(void) set_picked_offset:(CGPoint) offset;
-(CGPoint) get_picked_offset;
-(void) set_selected:(BOOL) selected;
@end


