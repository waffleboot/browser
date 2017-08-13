
#import <Foundation/Foundation.h>

@protocol ViewModelDelegate;

@interface ViewModel : NSObject
- (instancetype)initWithDelegate:(id<ViewModelDelegate>)delegate;
- (void)openPageWithAddress:(NSString *)address;
- (void)savePageHTML:(NSString *)html withAddress:(NSString *)address;
- (void)reload:(NSString *)address;
- (void)openRecentAddress;
- (NSString *)html:(NSString *)address;
- (void)undo;
@end

@protocol ViewModelDelegate <NSObject>
- (void)openPageWithHTML:(NSString *)html baseURL:(NSURL *)baseUrl;
- (void)openPageWithURL:(NSURL *)url;
@end
