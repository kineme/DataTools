#import "DTSampleHoldPatch.h"


bool DTIsValueSerializable(id v)
{
	if(![v respondsToSelector:@selector(encodeWithCoder:)])
	{
		NSAlert *a = [NSAlert alertWithMessageText:@"Can't save current Sample & Hold value." defaultButton:@"Sorry" alternateButton:nil otherButton:nil informativeTextWithFormat:@"An instance of the Kineme Sample & Hold Patch is currently holding a value that can't be serialized (%@ doesn't respond to encodeWithCoder:), so this patch will restore with an empty value.",[v class]];
		[a runModal];
		return NO;
	}

	// @@@todo: see if there's some way to get QCMeshes to work..
	if(objc_getClass("QCMesh") && [[v class] isSubclassOfClass:objc_getClass("QCMesh")])
	{
		NSAlert *a = [NSAlert alertWithMessageText:@"Can't save current Sample & Hold value." defaultButton:@"Sorry" alternateButton:nil otherButton:nil informativeTextWithFormat:@"An instance of the Kineme Sample & Hold Patch is currently holding a QCMesh.  QCMeshes currently can't be serialized, so this patch will restore with an empty value.",[v class]];
		[a runModal];
		return NO;
	}
	
	if([[v class] isSubclassOfClass:[QCImage class]] && [v isInfinite])
	{
		NSAlert *a = [NSAlert alertWithMessageText:@"Can't save current Sample & Hold value." defaultButton:@"Sorry" alternateButton:nil otherButton:nil informativeTextWithFormat:@"An instance of the Kineme Sample & Hold Patch is currently holding an image with infinite dimensions.  Such images can't be saved, so this patch will restore with an empty value."];
		[a runModal];
		return NO;
	}

	if([[v class] isSubclassOfClass:[QCStructure class]])
		for(id s in [v _list])
			if(!DTIsValueSerializable(s))
				return NO;

	return YES;
}

@interface DTSampleHoldPatch ()
@property (retain) id priorValue; 
@end


@implementation DTSampleHoldPatch

@synthesize priorValue; 

+(BOOL)isSafe
{
	return YES;
}

+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier
{
	return NO;
}

-(id)initWithIdentifier:(id)identifier
{
	if(self = [super initWithIdentifier:identifier])
	{
		[[self userInfo] setObject:@"Kineme Sample & Hold" forKey:@"name"];

		self.priorValue = nil;
	}
	return self;
}

- (void) dealloc
{
	[priorValue release]; 
	[super dealloc]; 
}

-(BOOL)setup:(QCOpenGLContext*)context
{
	if(priorValue)
	{
		[outputValue setRawValue:priorValue];
	}

	return YES;
}

-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments
{
	// @@@todo: see if there's some sensible way to disable the upstream graph when sampling is disabled

	if([inputSampling booleanValue])
	{
		[outputValue setRawValue:[inputValue rawValue]];
		self.priorValue = [outputValue rawValue]; 
		[self stateUpdated];
	}

	return YES;
}


- (NSDictionary*)state
{
	NSMutableDictionary *stateDict = [[NSMutableDictionary alloc] initWithCapacity:2];
	[stateDict addEntriesFromDictionary:[super state]];

	if(priorValue)
		if(DTIsValueSerializable(priorValue))
		{
			// placing a QCImage directly into stateDict causes a "Property list invalid for format" error, but archiving it and then placing NSData in there does seem to work.
			NSData *d = [NSKeyedArchiver archivedDataWithRootObject:priorValue];
			[stateDict setObject:d forKey:@"data"];
		}

	[stateDict autorelease];
	return stateDict;
}
- (BOOL)setState:(NSDictionary*)state
{
	NSData *d = [state objectForKey:@"data"];
	if(d)
		self.priorValue = [[NSKeyedUnarchiver unarchiveObjectWithData:d] retain];

	return [super setState:state];
}


@end
