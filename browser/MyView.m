
#import "MyView.h"

@interface MyView ()
@property (nonatomic,weak) ViewController *viewController;
@end

@implementation MyView

- (instancetype)initWithFrame:(NSRect)frameRect andViewController:(ViewController *)viewController {
    if (self = [super initWithFrame:frameRect]) {
        _viewController = viewController;
    }
    return self;
}

- (void)mouseDown:(NSEvent *)event {
    [self.viewController click];
}

@end
