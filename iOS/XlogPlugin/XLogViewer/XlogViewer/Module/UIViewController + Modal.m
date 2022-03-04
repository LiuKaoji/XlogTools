//
//  UIViewController.m
//  XlogViewer
//
//  Created by Kaoji on 2020/6/27.
//  Copyright © 2020 Kaoji. All rights reserved.
//

#import "UIViewController + Modal.h"
#import <objc/runtime.h>

@implementation UIViewController (Modal)

+(void)load{
    [super load];
    SEL exchangeSEL = @selector(kaoji_presentViewController:Animated:Completion:);
    SEL originSEL   = @selector(presentViewController:animated:completion:);
    method_exchangeImplementations(class_getInstanceMethod(self.class, originSEL), class_getInstanceMethod(self.class, exchangeSEL));
}

-(void)kaoji_presentViewController:(UIViewController *)viewControllerToPresent Animated:(BOOL)animated Completion:(void (^__nullable)(void))completion{
    
    if (@available(iOS 13, *)) {
        if(UIModalPresentationPageSheet == viewControllerToPresent.modalPresentationStyle){
            viewControllerToPresent.modalPresentationStyle = UIModalPresentationFullScreen;
        }
    }
    [self kaoji_presentViewController:viewControllerToPresent Animated:animated Completion:completion];
}
@end
