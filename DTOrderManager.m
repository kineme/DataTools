#import "DTOrderManager.h"
#import <libkern/OSAtomic.h>

static DTOrderManager *dtOrderManagerSingleton = nil;
static int32_t dtOrderManagerInstances = 0;
static OSSpinLock dtOrderManagerInitLock = OS_SPINLOCK_INIT;

@implementation DTOrderManager

+ (DTOrderManager *)sharedManager
{
	OSSpinLockLock(&dtOrderManagerInitLock);
	{
		if(!dtOrderManagerSingleton)
		{
			dtOrderManagerSingleton = [[DTOrderManager allocWithZone:NULL] init];
		}
		OSAtomicIncrement32(&dtOrderManagerInstances);
	}
	OSSpinLockUnlock(&dtOrderManagerInitLock);

	return dtOrderManagerSingleton;
}

- (NSUInteger)orderForContext:(QCContext*)context channel:(NSString *)channel time:(double)t
{
	NSMutableDictionary *c = [contexts objectForKey:[context description]];
	if(!c)
	{
		c = [[NSMutableDictionary alloc] init];
		[contexts setObject:c forKey:[context description]];
		[c release];
	}

	NSUInteger o;
	NSString *timeKey = [channel stringByAppendingString:@"_time"];
	NSString *orderKey = [channel stringByAppendingString:@"_order"];
	if( fabs([[c objectForKey:timeKey] doubleValue]-t) > 0.00001f )
	{
		[c setObject:[NSNumber numberWithDouble:t] forKey:timeKey];
		o = 0;
	}
	else
		o = [[c objectForKey:orderKey] unsignedIntegerValue];

	[c setObject:[NSNumber numberWithUnsignedInteger:o+1] forKey:orderKey];
	return o;
}

- (void)invalidateContext:(QCContext*)context
{
	[contexts removeObjectForKey:[context description]];
}

- (void)unuse
{
	OSSpinLockLock(&dtOrderManagerInitLock);
	if( !OSAtomicDecrement32(&dtOrderManagerInstances) )
	{
		[contexts release];
		[dtOrderManagerSingleton release];
		dtOrderManagerSingleton = nil;
	}
	OSSpinLockUnlock(&dtOrderManagerInitLock);
}

- (id)init
{
	if(self=[super init])
	{
		contexts = [[NSMutableDictionary alloc] init];
	}
	return self;
}

@end
