#import "StructureMaker.h"
#import "StructureMakerUI.h"


@implementation StructureMaker : QCPatch

+ (QCPatchExecutionMode)executionModeWithIdentifier:(id)identifier;
{
	return 0;
}

+ (BOOL)allowsSubpatchesWithIdentifier:(id)identifier;
{
	return NO;
}

+ (QCPatchTimeMode)timeModeWithIdentifier:(id)identifier;
{
	return 0;
}

+ (BOOL)isSafe
{
	return YES;
}

/* If you don't want an inspector panel, simply comment out this function */
+ (Class)inspectorClassWithIdentifier:(id)fp8
{
	return [StructureMakerUI class];
}

- (id)initWithIdentifier:(id)ident
{
	if(self = [super initWithIdentifier:ident])
	{
		if([ident isEqualTo:@"KinemeNamedStructureMaker"])
		{
			_named = TRUE;
			[[self userInfo] setObject:@"Kineme Named Struct Maker" forKey:@"name"];
		}
		else	// non-named
		{
			_named = FALSE;
			[[self userInfo] setObject:@"Kineme Struct Maker" forKey:@"name"];
		}
		[self addInput];	// add one input automatically
	}

	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	QCStructure *outStruct = nil;
	unsigned int i;
	BOOL noSkip = ![inputSkipEmptyInputs booleanValue];
	
	//NSLog(@"Building Structure... (%i %i)",_inputCount, _named);
	//if(__builtin_expect(_inputCount>0,1))
	{
		outStruct = [[QCStructure alloc] init];
		if(_named)
		{
			for(i=0; i<_inputCount; ++i)
			{
				// first, see if we've already inserted this key..
				while([outStruct memberForKey: [portNames[i] stringValue]])
				{
					// if so, modify it by adding a (dup) to the end
					[portNames[i] setStringValue: [NSString stringWithFormat:@"%@ (duplicate)",[portNames[i] stringValue]]];
				}
				if([ports[i] value])
					[outStruct addMember:[ports[i] value]  forKey:[portNames[i] stringValue]];
				else	// handle nil input
				{
					if(noSkip)
						[outStruct addMember:@"(unplugged)" forKey:[portNames[i] stringValue]];
				}
			}
		}
		else	// indexed
		{
			GFList *gfl = [outStruct _list];
			NSUInteger outputIndex = 0;
			for(i=0; i<_inputCount; ++i)
			{
				if([ports[i] value])
					[gfl insertObject:[ports[i] value] atIndex:outputIndex++ forKey:nil];
				else
				{
					if(noSkip)
						[gfl insertObject:@"(unplugged)" atIndex:outputIndex++ forKey:nil];
				}
			}
		}
	}

	[outputStructure setStructureValue:outStruct];
	[outStruct release];

	return YES;
}

- (BOOL)isNamed
{
	return _named;
}

- (BOOL)emptyExposed
{
	return _emptyExposed;
}

- (unsigned int)inputCount
{
	return _inputCount;
}

- (void)addInput
{
	_inputCount++;
	ports = (QCVirtualPort**)realloc(ports,sizeof(QCVirtualPort*)*_inputCount);
	ports[_inputCount-1] = [self createInputWithPortClass:[QCVirtualPort class] forKey:[NSString stringWithFormat:@"Input %i",_inputCount] attributes:nil];
	if(_named)
	{
		portNames = (QCStringPort**)realloc(portNames, sizeof(QCStringPort*)*_inputCount);
		portNames[_inputCount-1] = [self createInputWithPortClass:[QCStringPort class] forKey:[NSString stringWithFormat:@"Input %i Key",_inputCount] attributes:nil];
	}
}

- (void)delInput
{
	if(_inputCount > 1)
	{
		--_inputCount;
		[self deleteInputForKey:[NSString stringWithFormat:@"Input %i",1+_inputCount]];
		if(_named)
			[self deleteInputForKey:[NSString stringWithFormat:@"Input %i Key",1+_inputCount]];
	}
}

- (NSDictionary*)state
{
	unsigned int i;
	NSMutableDictionary *stateDict = [[NSMutableDictionary alloc] initWithCapacity:3];
	[stateDict addEntriesFromDictionary:[super state]];
	[stateDict setObject:[NSNumber numberWithInt:_inputCount] forKey:@"StructureMakerInputCount"];
	if(_named)
		for(i=0; i<_inputCount; ++i)
			[stateDict setObject:[portNames[i] stringValue] forKey:[NSString stringWithFormat:@"StructureMakerKey%04i",i]];
	[stateDict autorelease];
	return stateDict;
}

- (BOOL)setState:(NSDictionary*)state
{
	unsigned int i;
	i = [[state objectForKey:@"StructureMakerInputCount"] intValue];
	while( _inputCount < i)
		[self addInput];
	if(_named)
		for(i=0; i<_inputCount; ++i)
			[portNames[i] setStringValue: [state objectForKey:[NSString stringWithFormat:@"StructureMakerKey%04i",i]]];

	return [super setState:state];
}

@end
