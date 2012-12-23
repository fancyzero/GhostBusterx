//
//  SGhost.m
//  GhostBuster
//
//  Created by Zero Fancy on 12-12-15.
//
//

#import "SGhost.h"
#import "ShortestPathStep.h"
#import "GBLevel.h"
#import "GameBase.h"
#import "Common.h"
#import "SPlayer.h"
#import "World.h"
#import "CCTMXTiledMap.h"
#import "GBGame.h"

@implementation SGhost


@synthesize shortestPath;
@synthesize pendingMove;

- (id)init
{
    self = [super init];
	GBGame* game =(GBGame*) [GameBase get_game];
    m_speed = [[ game get_config_value:@"ghost_move_speed"] floatValue];
	
    [self init_with_xml:@"sprites/base.xml:Ghost" ];
	
    if (self)
    {
        self.m_name = @"Ghost";
        m_cur_start = ccp(-1,-1);
		m_cur_dest = ccp(-1,-1);
		
    }
	[self clear_closed_steps];
    m_next_change_target_time = 0;
    [self set_scale:1 :1];
    [ self set_role:role_ghost];
	[[GameBase get_game].m_world add_gameobj:self];
	[ self set_collision_filter:1+2+4+8+32 cat:1];
	[self set_physic_fixed_rotation:0 :true];
    return self;
}

-(void) update:(float)delta_time
{
	[super update:delta_time];
	GameBase* game = [GameBase get_game];
	if ( [game is_editor])
		return;
	GBLevel* level = (GBLevel*)[GameBase get_game].m_level;
	if ( [level pending_restart])
        return;
    self.m_name = @"Ghost";
	
	
	NSMutableArray* tmp = [game.m_world find_objs_by_name:@"Player"];
	NSMutableArray* players = [NSMutableArray array];
	for (GBSpriteBase* s in tmp)
	{
		if ( s->m_role == role_player )
		{
			[players addObject:s];

		}
	}

    if ( players.count > 0 && ( m_target >= players.count || current_game_time() > m_next_change_target_time) )
    {
        m_next_change_target_time += rand() %5+10;
        m_target = rand() % players.count;

    }
	else
	{
		if ( current_game_time() > m_next_change_target_time )
		{
			CGPoint desttile;
			desttile = level->m_walkable_tiles[rand() % level->m_walkable_tiles.size()];
			m_cur_dest = [level positionForTileCoord:desttile];
			m_next_change_target_time += rand() %2+2;
		}
	}
	if ( m_target < players.count )
	{
	SPlayer* player = [players objectAtIndex:m_target];
	m_cur_dest = player.m_position;
	}
	//if ( rand() % 60 == 0 )
	
	[ self moveToward : m_cur_dest ];
	
	//float movelen = delta_time*m_speed;
	
	if ( shortestPath != nil && shortestPath.count > 0 )
	{
		//while ( movelen > 0 && shortestPath.count > 0 )
		{
			//float curlen = 0;
			//float lentogo = 0;
			ShortestPathStep* step = [shortestPath objectAtIndex:0];
			CGPoint nextstep =  [ level positionForTileCoord:step.position];
			
			//curlen = ccpLength(ccpSub(self.m_position,nextstep));
			//if ( movelen > curlen )
			//	lentogo = curlen;
			//else
			//	lentogo = movelen;
			//movelen -= lentogo;
			CGPoint dir = get_dir_from_2vector( self.m_position, nextstep );
			//CGPoint pt = ccpMult(dir, lentogo);
			
			[self set_physic_linear_velocity:0 :dir.x * m_speed/[GameBase get_ptm_ratio] :dir.y*m_speed/[GameBase get_ptm_ratio] ];
			//pt = ccpAdd( self.m_position, pt );
			//[ self set_position:pt.x y:pt.y];
			//[ self set_rotation:-dir_to_angle(dir)];
			//if ( lentogo >= curlen )
			//	[shortestPath removeObjectAtIndex:0];
		}
		
	}
	else
	{
		[self set_physic_linear_velocity:0 :0 :0];
	}
}

-(void) clear_closed_steps
{
	spClosedSteps.clear();
	GBLevel* level = (GBLevel*)[GameBase get_game].m_level;
	spClosedSteps.resize([level get_mapsize].width * [level get_mapsize].height);
}
- (void)dealloc
{
	
	[shortestPath release];
	shortestPath = nil;
	
	[pendingMove release]; pendingMove = nil;
	[super dealloc];
}
-(void) add_to_closed_step:(ShortestPathStep*) step
{
	if ( step == NULL )
		return;
	GBLevel* level = (GBLevel*)[GameBase get_game].m_level;
	int x = step.position.x;
	int y = step.position.y;
	spClosedSteps[ (int)(x + y *[level get_mapsize].width) ] = step;
	
	[step retain];
}

-(bool) closed_step_contains:(ShortestPathStep*) step
{
	if ( step == NULL )
		return false;
	GBLevel* level = (GBLevel*)[GameBase get_game].m_level;
	int x = step.position.x;
	int y = step.position.y;
	
	return spClosedSteps[ (int)(x + y *[level get_mapsize].width) ] != NULL;
}

- (void)moveToward:(CGPoint)target
{
	
	// Init shortest path properties
	
	[ self clear_closed_steps];
	GBLevel* level = (GBLevel*)[GameBase get_game].m_level;
	spClosedSteps.resize([level get_mapsize].width * [level get_mapsize].height);
	spOpenSteps = [NSMutableArray array];
	
	
	
	// Get current tile coordinate and desired tile coord
	CGPoint fromTileCoord = [level tileCoordForPosition:self.m_position];
    CGPoint toTileCoord = [level tileCoordForPosition:target];
	//if ( m_cur_dest.x == toTileCoord.x && m_cur_dest.y == toTileCoord.y && m_cur_start.x == fromTileCoord.x && m_cur_start.y == fromTileCoord.y )
	//	return;
	//m_cur_start = fromTileCoord;
	//m_cur_dest	= toTileCoord;
	
	[self.shortestPath release];
	self.shortestPath = nil;
	//if ( ![level raycast :self.m_position :target ] )
	//{
	//	self.shortestPath = [NSMutableArray array];
	//	ShortestPathStep* step = [[ShortestPathStep alloc] initWithPosition:toTileCoord];
	//	[self.shortestPath insertObject:step atIndex:0]; // Always insert at index 0 to reverse the path
	
	//	return;
	
	//}
	// Check that there is a path to compute ;-)
	if (CGPointEqualToPoint(fromTileCoord, toTileCoord))
	{
		self.shortestPath = [NSMutableArray array];
		[self.shortestPath retain];
		ShortestPathStep* step = [[ShortestPathStep alloc] initWithPosition:toTileCoord];
		[self.shortestPath insertObject:step atIndex:0]; // Always insert at index 0 to reverse the path
		
		return;
	}
	
	
	// Must check that the desired location is walkable
	// In our case it's really easy, because only wall are unwalkable
	
	
	// Start by adding the from position to the open list
	[self insertInOpenSteps:[[ShortestPathStep alloc] initWithPosition:fromTileCoord]];
	
	do {
		// Get the lowest F cost step
		// Because the list is ordered, the first step is always the one with the lowest F cost
		ShortestPathStep *currentStep = [spOpenSteps objectAtIndex:0];
		
		// Add the current step to the closed set
		[self add_to_closed_step:currentStep];
		//		[spClosedSteps addObject:currentStep];
		
		// Remove it from the open list
		// Note that if we wanted to first removing from the open list, care should be taken to the memory
		[spOpenSteps removeObjectAtIndex:0];
		
		// If the currentStep is at the desired tile coordinate, we have done
		if (CGPointEqualToPoint(currentStep.position, toTileCoord)) {
			[self constructPathAndStartAnimationFromStep:currentStep];
			spOpenSteps = nil; // Set to nil to release unused memory
			[self clear_closed_steps];
			break;
		}
		
		// Get the adjacent tiles coord of the current step
		NSArray *adjSteps = [level walkableAdjacentTilesCoordForTileCoord:currentStep.position];
		for (NSValue *v in adjSteps) {
            
			ShortestPathStep *step = [[ShortestPathStep alloc] initWithPosition:[v CGPointValue]];
			
			// Check if the step isn't already in the closed set
			if ([self closed_step_contains: step]) {
				[step release]; // Must releasing it to not leaking memory ;-)
				continue; // Ignore it
			}
			
			// Compute the cost form the current step to that step
			int moveCost = [self costToMoveFromStep:currentStep toAdjacentStep:step];
			
			// Check if the step is already in the open list
			NSUInteger index = [spOpenSteps indexOfObject:step];
			
			if (index == NSNotFound) { // Not on the open list, so add it
				
				// Set the current step as the parent
				step.parent = currentStep;
				
				// The G score is equal to the parent G score + the cost to move from the parent to it
				step.gScore = currentStep.gScore + moveCost;
				
				// Compute the H score which is the estimated movement cost to move from that step to the desired tile coordinate
				step.hScore = [self computeHScoreFromCoord:step.position toCoord:toTileCoord];
				
				// Adding it with the function which is preserving the list ordered by F score
				[self insertInOpenSteps:step];
				
				// Done, now release the step
				[step release];
			}
			else { // Already in the open list
				
				[step release]; // Release the freshly created one
				step = [spOpenSteps objectAtIndex:index]; // To retrieve the old one (which has its scores already computed ;-)
				
				// Check to see if the G score for that step is lower if we use the current step to get there
				if ((currentStep.gScore + moveCost) < step.gScore) {
					
					// The G score is equal to the parent G score + the cost to move from the parent to it
					step.gScore = currentStep.gScore + moveCost;
					
					// Because the G Score has changed, the F score may have changed too
					// So to keep the open list ordered we have to remove the step, and re-insert it with
					// the insert function which is preserving the list ordered by F score
					
					// We have to retain it before removing it from the list
					[step retain];
					
					// Now we can removing it from the list without be afraid that it can be released
					[spOpenSteps removeObjectAtIndex:index];
					
					// Re-insert it with the function which is preserving the list ordered by F score
					[self insertInOpenSteps:step];
					
					// Now we can release it because the oredered list retain it
					[step release];
				}
			}
		}
		
	} while ([spOpenSteps count] > 0);
	
}

// Insert a path step (ShortestPathStep) in the ordered open steps list (spOpenSteps)
- (void)insertInOpenSteps:(ShortestPathStep *)step
{
	int stepFScore = [step fScore]; // Compute only once the step F score's
	int count = [spOpenSteps count];
	int i = 0; // It will be the index at which we will insert the step
	for (; i < count; i++) {
		if (stepFScore <= [[spOpenSteps objectAtIndex:i] fScore]) { // if the step F score's is lower or equals to the step at index i
			// Then we found the index at which we have to insert the new step
			break;
		}
	}
	// Insert the new step at the good index to preserve the F score ordering
	[spOpenSteps insertObject:step atIndex:i];
}

// Compute the H score from a position to another (from the current position to the final desired position
- (int)computeHScoreFromCoord:(CGPoint)fromCoord toCoord:(CGPoint)toCoord
{
	// Here we use the Manhattan method, which calculates the total number of step moved horizontally and vertically to reach the
	// final desired step from the current step, ignoring any obstacles that may be in the way
	return abs(toCoord.x - fromCoord.x) + abs(toCoord.y - fromCoord.y);
}

// Compute the cost of moving from a step to an adjecent one
- (int)costToMoveFromStep:(ShortestPathStep *)fromStep toAdjacentStep:(ShortestPathStep *)toStep
{
	return ((fromStep.position.x != toStep.position.x) && (fromStep.position.y != toStep.position.y)) ? 14 : 10;
}

- (void)constructPathAndStartAnimationFromStep:(ShortestPathStep *)step
{
	self.shortestPath = [NSMutableArray array];
	[self.shortestPath retain];
	do {
		//[step retain];
		//NSLog( @"step refcount %d", [step retainCount]);
		if (step.parent != nil) { // Don't add the last step which is the start position (remember we go backward, so the last one is the origin position ;-)
			[self.shortestPath insertObject:step atIndex:0]; // Always insert at index 0 to reverse the path
		}
		step = step.parent; // Go backward
	} while (step != nil); // Until there is not more parent
	
	// Call the popStepAndAnimate to initiate the animations
}
@end
