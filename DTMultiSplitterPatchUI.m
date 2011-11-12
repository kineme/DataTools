#import "DTTableView.h"
#import "DTMultiSplitterPatch.h"
#import "DTMultiSplitterPatchUI.h"

@implementation DTMultiSplitterPatchUI
/* This method returns the NIB file to use for the inspector panel */
+ (NSString *)viewNibName
{
    return @"DTMultiSplitterPatchUI";
}



-(IBAction)addPort:(id)sender
{
//	NSLog(@"addPort: %@", sender);
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return ((DTMultiSplitterPatch *)[self patch]).portCount;
}

-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	
	return @"!!!BUG!!!";
}

-(void)tableView:(DTTableView*)tv didReceiveDeleteKey:(NSEvent*)event
{
//	NSLog(@"delete");
}

@end
