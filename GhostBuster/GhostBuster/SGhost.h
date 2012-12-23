//
//  SGhost.h
//  GhostBuster
//
//  Created by Zero Fancy on 12-12-15.
//
//

#import "GBSpriteBase.h"
#include <vector>

@class ShortestPathStep;
@interface SGhost : GBSpriteBase
{
	CGPoint m_cur_start;
	CGPoint m_cur_dest;
	
	std::vector<ShortestPathStep*> spClosedSteps;
	NSMutableArray* spOpenSteps;
    float m_next_change_target_time;
    int m_target;
}

@property (nonatomic, retain) NSMutableArray *shortestPath;
@property (nonatomic, retain) NSValue *pendingMove;

- (void)insertInOpenSteps:(ShortestPathStep *)step;
- (int)computeHScoreFromCoord:(CGPoint)fromCoord toCoord:(CGPoint)toCoord;
- (int)costToMoveFromStep:(ShortestPathStep *)fromStep toAdjacentStep:(ShortestPathStep *)toStep;
- (void)constructPathAndStartAnimationFromStep:(ShortestPathStep *)step;

@end
