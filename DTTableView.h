@interface DTTableView : NSTableView
@end

@interface NSObject (DTTableViewDelegate)
-(void)tableView:(DTTableView*)tv didReceiveDeleteKey:(NSEvent*)event;
@end
