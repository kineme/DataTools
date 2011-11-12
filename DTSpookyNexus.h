#import <Cocoa/Cocoa.h>

@interface DTSpookyNexus : NSObject
+(id)sharedNexusManager;
-(void)unuse;
-(id)objectForKey:(id)key;
-(void)setValue:(id)value forKey:(id)key;
-(void)removeObjectForKey:(id)key;
@end
