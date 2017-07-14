
#import <Foundation/Foundation.h>

@protocol ViewModelDelegate;

@interface ViewModel : NSObject
- (instancetype)initWithDelegate:(id<ViewModelDelegate>)delegate;
- (void)open:(NSString *)address;
- (void)save:(NSString *)html withAddress:(NSString *)address;
- (void)openLatest;
- (void)reload:(NSString *)address;
- (void)undo;
@end

@protocol ViewModelDelegate <NSObject>
- (void)open:(NSString *)address;
- (void)openHTML:(NSString *)html withAddress:(NSString *)address;
@end
