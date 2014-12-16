/*
 Phonegap DatePicker Plugin for using Cordova 3 and iOS 7
 https://github.com/sectore/phonegap3-ios-datepicker-plugin
 
 Based on a previous plugin version by Greg Allen and Sam de Freyssinet and Jens Krause and Jens Krause.
 
 Rewrite by Francesco Verheye
 
 MIT Licensed
*/

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>

@interface DatePickerPlugin : CDVPlugin <UIPopoverControllerDelegate> {
    
}

- (void)show:(CDVInvokedUrlCommand*)command;

@end