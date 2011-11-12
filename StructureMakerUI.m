#import "StructureMakerUI.h"

#import "StructureMaker.h"

@implementation StructureMakerUI

/* This method returns the NIB file to use for the inspector panel */
+(NSString*)viewNibName
{
    return @"StructureMakerUI";
}

/* This method specifies the title for the patch */
+(NSString*)viewTitle
{
    return @"Settings";
}

- (void)setupViewForPatch:(StructureMaker*)patch
{
	[textField setIntValue: [patch inputCount]];
	[stepper setIntValue:   [patch inputCount]];
	[super setupViewForPatch:patch];
}

- (IBAction)stepInputCount:(id)sender
{
	NSStepper *step = (NSStepper*)sender;
	if( [sender intValue] > 0)
		[textField setIntValue:[step intValue]];
	else
		[sender setIntValue: 1];

	StructureMaker *patch = (StructureMaker *)[self patch];
	while( [sender intValue] > [patch inputCount] )
	{
		//NSLog(@"Adding input;  Currently at %i, going to %i",[[self patch] inputCount], [sender intValue]);
		[patch addInput];
	}
	while( [sender intValue] < [patch inputCount] && [sender intValue] > 0)
		[patch delInput];
}

- (IBAction)textInputCount:(id)sender
{
	StructureMaker *patch = (StructureMaker *)[self patch];
	[patch disableNotifications];
	[stepper setIntValue:[sender intValue]];
	while( [sender intValue] > [patch inputCount] )
		[patch addInput];
	while( [sender intValue] < [patch inputCount] && [sender intValue] > 0)
		[patch delInput];
	[patch enableNotifications];
}

- (IBAction)emptyInputPort:(id)sender
{
}

@end