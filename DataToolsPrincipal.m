#import "DataToolsPrincipal.h"

#import <objc/runtime.h>
#import <objc/message.h>

#import "DTMultiExpressionPatch.h"
#import "DTStructureEqualPatch.h"
#import "DTStructurePushPatch.h"
#import "DTStructurePopPatch.h"
#import "DTStructureCombinePatch.h"
#import "DTStructureBreakOutPatch.h"
#import "DTStructureKeyPatch.h"
#import "DTMultiSplitterPatch.h"
#import "DTOrderPatch.h"
#import "DTArrayPatch.h"
#import "DTSampleHoldPatch.h"
#import "DTConvertToDataPatch.h"
#import "DTConvertFromDataPatch.h"
#import "DTStringToDataPatch.h"
#import "DTImageToDataPatch.h"

#import "SpookySendPatch.h"
#import "SpookyReceivePatch.h"

#import "StructureMaker.h"

#import "ValueHistorianPatch.h"



NSDictionary *DTSplitterAttributes(id self, SEL sel, NSString *identifier)
{
	struct objc_super super_data = { self, class_getSuperclass(object_getClass(self)) };
	NSMutableDictionary *d = [objc_msgSendSuper(&super_data,@selector(attributesWithIdentifier:),identifier) mutableCopy];

	// set the name based on the identifier (minus the "QC" prefix and "Port" suffix)
	[d
		setObject:[[identifier substringWithRange:NSMakeRange(2,[identifier length]-6)] stringByAppendingString:@" Splitter"]
		forKey:@"name"
	];

	[d setObject:[NSArray arrayWithObject:@"Kineme DataTools Splitters"] forKey:@"categories"];

	return d;
}
id DTSplitterInit(id self, SEL sel, NSString *identifier)
{
	struct objc_super super_data = { self, class_getSuperclass(object_getClass(self)) };
	if(self=objc_msgSendSuper(&super_data,@selector(initWithIdentifier:),identifier))
		[self setPortClass:NSClassFromString(identifier)];

	return self;
}




@implementation DataToolsPrincipal

+(void)registerNodesWithManager:(QCNodeManager*)manager
{
	KIEnsureSystemVersion;

	KIRegisterPatch(DTMultiExpressionPatch);
	KIRegisterPatch(DTStructureEqualPatch);
	KIRegisterPatch(DTStructurePushPatch);
	KIRegisterPatch(DTStructurePopPatch);
	KIRegisterPatch(DTStructureCombinePatch);
	KIRegisterPatch(DTStructureBreakOutPatch);
	KIRegisterPatch(DTStructureKeyPatch);
//	KIRegisterPatch(DTMultiSplitterPatch);
	KIRegisterPatch(SpookySendPatch);
	KIRegisterPatch(SpookyReceivePatch);
	KIRegisterPatch(DTOrderPatch);
//	KIRegisterPatch(DTArrayPatch);	// @@@ still some major usability issues
	KIRegisterPatch(DTSampleHoldPatch);
	KIRegisterPatchIdentifier(StructureMaker,@"KinemeNamedStructureMaker");
	KIRegisterPatchIdentifier(StructureMaker,@"KinemeStructureMaker");
	KIRegisterPatch(ValueHistorianPatch);
	KIRegisterPatch(DTConvertToDataPatch); 
	KIRegisterPatch(DTConvertFromDataPatch); 
	KIRegisterPatch(DTStringToDataPatch);
	KIRegisterPatch(DTImageToDataPatch);

/* disabled for now, since this hack results in input splitters that require DataTools (which is kinda misleading)
	{
		// synthesize a QCSplitter subclass...
		Class QCSplitterClass = objc_getClass("QCSplitter");
		Class DTSplitterClass = objc_allocateClassPair(QCSplitterClass,"DTSplitterPatch",0);
		if(DTSplitterClass)
		{
			class_addMethod(DTSplitterClass->isa, @selector(attributesWithIdentifier:), (IMP)DTSplitterAttributes, "@@:@");
			class_addMethod(DTSplitterClass, @selector(initWithIdentifier:), (IMP)DTSplitterInit, "@@:@");
			objc_registerClassPair(DTSplitterClass);
		}
		else
			SLog(NSLocalizedString(@"Failed to create class DTSplitterPatch.",@""));

		// ...and create some specific instances of it in the patch list
		KIRegisterPatchIdentifier(DTSplitterClass,@"QCBooleanPort");
		KIRegisterPatchIdentifier(DTSplitterClass,@"QCColorPort");
		KIRegisterPatchIdentifier(DTSplitterClass,@"QCImagePort");
		KIRegisterPatchIdentifier(DTSplitterClass,@"QCIndexPort");
		KIRegisterPatchIdentifier(DTSplitterClass,@"QCInteractionPort");
		KIRegisterPatchIdentifier(DTSplitterClass,@"QCMeshPort");
		KIRegisterPatchIdentifier(DTSplitterClass,@"QCNumberPort");
		KIRegisterPatchIdentifier(DTSplitterClass,@"QCStringPort");
		KIRegisterPatchIdentifier(DTSplitterClass,@"QCStructurePort");
	}
*/
}

@end
