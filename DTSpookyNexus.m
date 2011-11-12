#import "DTSpookyNexus.h"
#import <libkern/OSAtomic.h>

static NSMutableDictionary *spookyGlobalDictionary = nil;
static volatile DTSpookyNexus *_spookyNexusManager = nil;
static OSSpinLock nexusLock = OS_SPINLOCK_INIT;
static volatile uint32_t nexusUseCount = 0;

@implementation DTSpookyNexus

+(id)sharedNexusManager
{
	OSSpinLockLock(&nexusLock);
	{
		if(!_spookyNexusManager)
		{
			_spookyNexusManager = [DTSpookyNexus new];
			spookyGlobalDictionary = [NSMutableDictionary new];
		}
		++nexusUseCount;
	}
	OSSpinLockUnlock(&nexusLock);
	
	return _spookyNexusManager;
}

-(void)unuse
{
	OSSpinLockLock(&nexusLock);
	{
		--nexusUseCount;
		if(nexusUseCount == 0)
		{
			[_spookyNexusManager release];
			[spookyGlobalDictionary release];
			_spookyNexusManager = nil;
			spookyGlobalDictionary = nil; // so GC will clean it up
		}
	}
	OSSpinLockUnlock(&nexusLock);
}

-(id)objectForKey:(id)key
{
	return [spookyGlobalDictionary objectForKey:key];
}

-(void)setValue:(id)value forKey:(id)key
{
	[spookyGlobalDictionary setValue:value forKey:key];
}

-(void)removeObjectForKey:(id)key
{
	[spookyGlobalDictionary removeObjectForKey:key];
}

@end
