#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SBSRemoteContentDefinition : NSObject
@property (nonatomic, readonly, copy) NSString *serviceName;
@end

@interface CSRemoteContentInlineViewController : UIViewController {
    SBSRemoteContentDefinition *_definition;
}
@end

@interface CSRemoteContentModalViewController : UIViewController {
    SBSRemoteContentDefinition *_definition;
}
@end

static BOOL isSleepLockScreen(SBSRemoteContentDefinition *definition) {
    return [definition.serviceName isEqualToString:@"com.apple.SleepLockScreen"];
}

// With Sleep Focus on, the Lock Screen is the "Sleep Lock Screen" hosted as
// remote content (com.apple.SleepLockScreen). Its preferences request a
// dark blurred background (style 3), which CoverSheet turns into a dim layer.

// iOS 16+: hosted inline. An out-of-range style makes CoverSheet use no background.
%hook CSRemoteContentInlineViewController

- (long long)_backgroundStyle {
    if (isSleepLockScreen(MSHookIvar<SBSRemoteContentDefinition *>(self, "_definition"))) {
        return NSIntegerMax;
    }
    return %orig;
}

%end

// iOS 15: hosted as a modal. Style 0 maps to the plain (non-dimmed) background.
%hook CSRemoteContentModalViewController

- (long long)_backgroundStyle {
    if (isSleepLockScreen(MSHookIvar<SBSRemoteContentDefinition *>(self, "_definition"))) {
        return 0;
    }
    return %orig;
}

%end
