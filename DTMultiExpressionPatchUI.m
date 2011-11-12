#import "DTMultiExpressionPatch.h"
#import "DTMultiExpressionPatchUI.h"

@implementation DTMultiExpressionPatchUI

+ (NSString *)viewNibName
{
    return @"DTMultiExpressionPatchUI";
}

-(NSString*)viewTitle
{
	return @"Expressions";
}

- (void)setupViewForPatch:(DTMultiExpressionPatch *)patch
{
	[super setupViewForPatch:patch];
	[programmablePatchView setProgrammablePatch:patch sourceType:@"expression"];
}

-(void)resetView
{
	[programmablePatchView setProgrammablePatch:nil sourceType:nil];
	[super resetView];
}

@end