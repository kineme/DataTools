@interface DTOrderManager : NSObject
{
	NSMutableDictionary *contexts;
}

+ (DTOrderManager *)sharedManager;
- (NSUInteger)orderForContext:(QCContext*)context channel:(NSString *)channel time:(double)t;
- (void)invalidateContext:(QCContext*)context;
- (void)unuse;
@end
