#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

static NSString *const kTargetBundleID = @"com.apple.Notes";

static void terminateNotesApp(NSRunningApplication *app) {
    if ([app.bundleIdentifier isEqualToString:kTargetBundleID]) {
        [app forceTerminate];
    }
}

static void terminateAllNotes(void) {
    for (NSRunningApplication *app in [[NSWorkspace sharedWorkspace] runningApplications]) {
        terminateNotesApp(app);
    }
}

@interface NotesKiller : NSObject
@end

@implementation NotesKiller

- (instancetype)init {
    self = [super init];
    if (self) {
        NSNotificationCenter *center = [[NSWorkspace sharedWorkspace] notificationCenter];
        [center addObserver:self
                   selector:@selector(handleAppEvent:)
                       name:NSWorkspaceDidLaunchApplicationNotification
                     object:nil];
        [center addObserver:self
                   selector:@selector(handleAppEvent:)
                       name:NSWorkspaceDidActivateApplicationNotification
                     object:nil];
        terminateAllNotes();
    }
    return self;
}

- (void)handleAppEvent:(NSNotification *)notification {
    NSRunningApplication *app = notification.userInfo[NSWorkspaceApplicationKey];
    if (app) {
        terminateNotesApp(app);
    }
}

@end

int main(int argc, const char * argv[]) {
    (void)argc;
    (void)argv;
    @autoreleasepool {
        [[NotesKiller alloc] init];
        [[NSRunLoop mainRunLoop] run];
    }
    return 0;
}
