//
//  ShotestPathStep.h
//  GhostBuster
//
//  Created by Zero Fancy on 12-12-15.
//
//

#import <Foundation/Foundation.h>

// A class that represents a step of the computed path
@interface ShortestPathStep : NSObject
{
	CGPoint position;
	int gScore;
	int hScore;
    ShortestPathStep *parent;
}

@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) int gScore;
@property (nonatomic, assign) int hScore;
@property (nonatomic, assign) ShortestPathStep *parent;

- (id)initWithPosition:(CGPoint)pos;
- (int)fScore;

@end

