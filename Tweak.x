#import <Foundation/Foundation.h>

// Sleep Focus shows the Sleep Lock Screen as remote content (com.apple.SleepLockScreen),
// which requests a dark blurred background that CoverSheet renders as a dim layer.
static BOOL isSleepScreen(id vc) {
    return [[[vc valueForKey:@"_definition"] valueForKey:@"serviceName"] isEqualToString:@"com.apple.SleepLockScreen"];
}

// iOS 16+ (inline): an out-of-range style means no background.
%hook CSRemoteContentInlineViewController
- (long long)_backgroundStyle { return isSleepScreen(self) ? NSIntegerMax : %orig; }
%end

// iOS 15 (modal): style 0 maps to the plain background.
%hook CSRemoteContentModalViewController
- (long long)_backgroundStyle { return isSleepScreen(self) ? 0 : %orig; }
%end
