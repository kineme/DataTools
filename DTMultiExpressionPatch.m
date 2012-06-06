#import "DTMultiExpressionPatch.h"
#import "DTMultiExpressionPatchUI.h"


@implementation DTMultiExpressionPatch

+(BOOL)isSafe
{
	return YES;
}

+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier
{
	return NO;
}

+ (Class)inspectorClassWithIdentifier:(id)fp8
{
	return [DTMultiExpressionPatchUI class];
}

+(NSArray*)sourceTypes
{
	return [NSArray arrayWithObject:@"expression"];
}

- (id)initWithIdentifier:(id)identifier
{
	if(self = [super initWithIdentifier:identifier])
	{
		[[self userInfo] setObject:@"MultiExpression" forKey:@"name"];

		expressions = [NSMutableArray new];
		resultVariables = [NSMutableArray new];

		[self setSource:@"x=cos(t)\ny=sin(t)" ofType:@"expression"];
		[self compileSourceOfType:@"expression"];
	}
	return self;
}
- (void)dealloc
{
	[expressions release];
	[resultVariables release];
	[super dealloc];
}

- (BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments
{
	// needs to be keyed AND ordered, so standard NS* won't work.
	QCStructure *s = [[QCStructure alloc] init];
	GFList *results = [s _list];

	// set up input conditions
	for(QCPort *p in [self parameterPorts])
		[results addObject:[p value] forKey:[p key]];

	// evaluate expressions sequentially
	unsigned int i = 0;
	for(QCMathematicalExpression *expr in expressions)
	{
		// assign known variables
		NSArray *variables = [expr variables];
		
		unsigned int n = 0;
		for(NSString *i in variables)
		{
			NSString *v = i;
			[expr setVariable:[[results objectForKey:v] doubleValue] atIndex:n];
			n++;
		}

		// evaluate and assign result
		[results addObject:[NSNumber numberWithDouble:[expr evaluate]] forKey:[resultVariables objectAtIndex:i]];
		i++;
	}

	for(QCPort *p in [self resultPorts])
		[p setValue:[results objectForKey:[p key]]];

	[outputStructure setStructureValue:s];
	[s release];

	return YES;
}

@end


@implementation DTMultiExpressionPatch (QCProgrammablePatch)

+ (NSArray *)sourceTypes
{
	return [NSArray arrayWithObject:@"expression"];
}


- (id)compileSourceOfType:(NSString *)sourceType
{
	NSString *source = [self sourceOfType:sourceType];

	id QCMathematicalExpressionClass = objc_getClass("QCMathematicalExpression");
		
	[expressions removeAllObjects];
	[resultVariables removeAllObjects];
	GFList *inputParams = [GFList list];
	GFList *resultList = [GFList list];
	GFList *resultNameList = [GFList list];
	NSMutableDictionary *errors = [NSMutableDictionary dictionary];
	NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceCharacterSet];
	QCParameterInfo *parameterInfo = [QCParameterInfo infoWithType:3 size:1];
	
	// for each line...
	unsigned int lineNumber = 1;
	for(NSString *line in [source componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]])
	{
		if([line length])
		{
			// split into result-variable-name and expression-to-evaluate
			NSArray *c = [line componentsSeparatedByString:@"="];
			if( [c count] != 2 )
			{
				if([errors count] == 0)	// only report first error (but not if there aren't any expressions)
				{
					// @"error" key is a NSNumber bool -- true means error (red icon), false means warning (yellow icon)
					[errors setObject:(id)kCFBooleanFalse forKey:@"error"];
					// @"message" key is the stuff that gets printed.
					[errors setObject:@"No '=' found in expression." forKey:@"message"];
					// @"line" key is the line number to highlight (starts at 1, not zero ... Dijkstra would be pissed...)
					[errors setObject:[NSNumber numberWithUnsignedInt:lineNumber] forKey:@"line"];
				}
				
				continue;
			}

			NSString *resultVariable;
			{
				resultVariable = [c objectAtIndex:0];
				resultVariable = [resultVariable stringByTrimmingCharactersInSet:whitespaceCharacterSet];
				
				if( ![resultVariable length] )
				{
					if([errors count] == 0)
					{
						[errors setObject:(id)kCFBooleanFalse forKey:@"error"];
						[errors setObject:@"No variable name for assignment." forKey:@"message"];
						[errors setObject:[NSNumber numberWithUnsignedInt:lineNumber] forKey:@"line"];
					}
					continue;
				}
				
				if([c count] > 1)
				{
//					NSLog(@"first var `%@`,  second var `%@`", resultVariable, [[c objectAtIndex:1] stringByTrimmingCharactersInSet:whitespaceCharacterSet]);
					if( [resultVariable isEqualToString:[[c objectAtIndex:1] stringByTrimmingCharactersInSet:whitespaceCharacterSet]] )
					{
						if([errors count] == 0)
						{
							[errors setObject:(id)kCFBooleanTrue forKey:@"error"];
							[errors setObject:@"Equation's left and right sides cannot match." forKey:@"message"];
							[errors setObject:[NSNumber numberWithUnsignedInt:lineNumber] forKey:@"line"];	
						}
						continue;
					}
				}
				
				if( strspn([resultVariable UTF8String],"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789") != [resultVariable length] )
				{
					if([errors count] == 0)
					{
						[errors setObject:(id)kCFBooleanTrue forKey:@"error"];
						[errors setObject:@"Please use alphanumeric variable names." forKey:@"message"];
						[errors setObject:[NSNumber numberWithUnsignedInt:lineNumber] forKey:@"line"];
					}
					continue;
				}

				if([resultList objectForKey:resultVariable])
				{
					if([errors count] == 0)
					{
						[errors setObject:(id)kCFBooleanFalse forKey:@"error"];
						[errors setObject:[NSString stringWithFormat:@"Variable %@ was already declared.",resultVariable] forKey:@"message"];
						[errors setObject:[NSNumber numberWithUnsignedInt:lineNumber] forKey:@"line"];
					}
					continue;
				}

				if( [inputParams objectForKey:resultVariable] )
				{
					if([errors count] == 0)
					{
						[errors setObject:(id)kCFBooleanFalse forKey:@"error"];
						[errors setObject:@"The same variable name can't be used as both an input and an output." forKey:@"message"];
						[errors setObject:[NSNumber numberWithUnsignedInt:lineNumber] forKey:@"line"];
					}
					continue;
				}

				if( [QCProgrammablePatch respondsToSelector:@selector(isKeyValid:)] && ![QCProgrammablePatch isKeyValid:resultVariable] )
				{
					if([errors count] == 0)
					{
						[errors setObject:(id)kCFBooleanTrue forKey:@"error"];
						[errors setObject:@"Variable name failed [QCProgrammablePatch isKeyValid:]." forKey:@"message"];
						[errors setObject:[NSNumber numberWithUnsignedInt:lineNumber] forKey:@"line"];
					}
					continue;
				}
				
				[resultVariables addObject:resultVariable];
				[resultList addObject:parameterInfo forKey:resultVariable];
				[resultNameList addObject:line forKey:resultVariable];
			}
			NSString *exprString = [c objectAtIndex:1];

			// parse
			NSString *error=nil;
			QCMathematicalExpression *expr = [[QCMathematicalExpressionClass alloc] initWithString:exprString error:&error];
			if(error)
			{
				if([errors count] == 0)	// only report first error
				{
					// @"error" key is a NSNumber bool -- true means error (red icon), false means warning (yellow icon)
					[errors setObject:(id)kCFBooleanTrue forKey:@"error"];
					// @"message" key is the stuff that gets printed.
					[errors setObject:[error description] forKey:@"message"];
					// @"line" key is the line number to highlight (starts at 1, not zero ... Dijkstra would be pissed...)
					[errors setObject:[NSNumber numberWithUnsignedInt:lineNumber] forKey:@"line"];
				}
				continue;
			}
			
			[expressions addObject:expr];

			for(NSString *variable in [expr variables])
				if( [resultVariables indexOfObjectIdenticalTo:variable]==NSNotFound
					   && ![inputParams objectForKey:variable])
				{
					[inputParams addObject:parameterInfo forKey:variable];
				}

			[expr release];
		}
		++lineNumber;
	}
	
	[self setParameterList:inputParams];
	[self setResultList:resultList];

	for(QCNumberPort *p in [self resultPorts])
		[[p userInfo] setObject:[resultNameList objectForKey:[p key]] forKey:@"name"];

	return errors;
}

@end
