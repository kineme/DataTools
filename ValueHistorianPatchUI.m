#import "ValueHistorianPatchUI.h"
#import "ValueHistorianPatch.h"

@implementation ValueHistorianPatchUI

/* This method returns the NIB file to use for the inspector panel */
+(NSString*)viewNibName
{
    return @"ValueHistorianPatchUI";
}

/* This method specifies the title for the patch */
+(NSString*)viewTitle
{
    return @"ValueHistorianPatch";
}

- (IBAction)updatePortCount:(id)sender
{
	ValueHistorianPatch *p = (ValueHistorianPatch *)[self patch];
	if( [[sender title] isEqualToString:@"+"] )
	{
		[p addPortWithName: [portName stringValue]];
		[p stateUpdated];	// mark as changed
		// auto-erase name after addition -- not sure if that's annoying or not
		//[portName setStringValue: nil];
	}
	else if( [[sender title] isEqualToString:@"-"] )
		[p removePort];
}

- (IBAction)saveData:(id)sender
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setRequiredFileType: @"plist"];
	[savePanel setExtensionHidden: NO];
	[savePanel setCanSelectHiddenExtension: NO];
	[savePanel setAllowsOtherFileTypes: NO];
	[savePanel setDelegate: self];
	if([savePanel runModal] == NSFileHandlingPanelOKButton)
		[(ValueHistorianPatch *)[self patch] exportData: [savePanel filename]];
}

- (IBAction)loadData:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setRequiredFileType: @"plist"];
	[openPanel setExtensionHidden: NO];
	[openPanel setCanSelectHiddenExtension: NO];
	[openPanel setCanChooseDirectories: NO];
	[openPanel setAllowsMultipleSelection: NO];
	[openPanel setAllowsOtherFileTypes: NO];
	[openPanel setDelegate: self];
	if([openPanel runModal] == NSFileHandlingPanelOKButton)
		[(ValueHistorianPatch *)[self patch] importData: [[openPanel filenames] objectAtIndex: 0]];
}

// used with open panel, to disallow selection of non-plist types
- (BOOL)panel:(id)sender shouldShowFilename:(NSString *)filename
{
	// if it's a plist, it's good
	if([[filename pathExtension] isEqualToString: @"plist"])
		return YES;
	// if it's a directory, it's good
	NSDictionary *attrs = [[NSFileManager defaultManager] fileAttributesAtPath: filename traverseLink: YES];
	if([attrs fileType] == NSFileTypeDirectory)
		return YES;
	return NO;
}

@end