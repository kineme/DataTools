#import "DTTableView.h"

@implementation DTTableView
-(void)keyDown:(NSEvent*)event
{
	int charCode = [[event charactersIgnoringModifiers] characterAtIndex:0];
	if(charCode == NSDeleteCharacter || charCode == NSDeleteFunctionKey)
	{
		id delegate = [self delegate];
		if([delegate respondsToSelector:@selector(tableView:didReceiveDeleteKey:)])
			[delegate tableView:self didReceiveDeleteKey:event];
	}
	else
		[super keyDown:event];
}
@end
