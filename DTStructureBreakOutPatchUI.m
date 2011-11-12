#import "DTStructureBreakOutPatchUI.h"
#import "DTStructureBreakOutPatch.h"

@implementation DTStructureBreakOutPatchUI
/* This method returns the NIB file to use for the inspector panel */
+ (NSString *)viewNibName
{
    return @"DTStructureBreakOutPatchUI";
}

-(IBAction)configureFromInput:(id)sender
{
	[(DTStructureBreakOutPatch*)[self patch] configureFromInput];
}


@end
