/*
 
 Phonegap DatePicker Plugin for using Cordova 3 and iOS 7
 https://github.com/sectore/phonegap3-ios-datepicker-plugin
 
 Based on a previous plugin version by Greg Allen and Sam de Freyssinet.
 
 Rewrite by Jens Krause (www.websector.de)
 
 MIT Licensed
 
 */

#import "DatePicker.h"
#import <Cordova/CDV.h>

@interface DatePicker ()

@property (nonatomic) UIPopoverController *datePickerPopover;

@property (nonatomic) IBOutlet UIView* datePickerContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *datePickerComponentsContainerVSpace;
@property (nonatomic) IBOutlet UIView* datePickerComponentsContainer;
@property (nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@end

@implementation DatePicker
{
    NSString *_mode;
    double _initDate;
    double _minDate;
    double _maxDate;
    NSInteger _minuteInterval;
    NSString *_positiveButtonText;
    NSString *_negativeButtonText;
    NSString *_setDateTitle;
    NSString *_setTimeTitle;
    
}

#define isIPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define ANIMATION_DURATION 0.3

#pragma mark - UIDatePicker

- (void)show:(CDVInvokedUrlCommand*)command
{
    NSMutableDictionary *options = [command argumentAtIndex:0];
    
    _initDate = -1;
    _minDate = -1;
    _maxDate = -1;
    _minuteInterval = 1;
    _positiveButtonText = @"Set";
    _negativeButtonText = @"Cancel";
    _setDateTitle = @"Set date";
    _setTimeTitle = @"Set time";
    
    if (isIPhone) {
        [self showForPhone: options];
    }
    else
    {
        [self showForPad: options];
    }
}

- (BOOL)showForPhone:(NSMutableDictionary *)options
{
    if(!self.datePickerContainer)
    {
        [[NSBundle mainBundle] loadNibNamed:@"DatePicker" owner:self options:nil];
    }
  
    [self readParametersFromOptionsDictionary:options];
    [self updateUIComponents];
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
  
    CGFloat width;
    CGFloat height;
  
    if(UIInterfaceOrientationIsLandscape(deviceOrientation)){
        width = self.webView.superview.frame.size.height;
        height= self.webView.superview.frame.size.width;
    } else {
        width = self.webView.superview.frame.size.width;
        height= self.webView.superview.frame.size.height;
    }

    self.datePickerContainer.frame = CGRectMake(0, 0, width, height);
  
    [self.webView.superview addSubview: self.datePickerContainer];
    [self.datePickerContainer layoutIfNeeded];

    CGRect frame = self.datePickerComponentsContainer.frame;
    self.datePickerComponentsContainer.frame = CGRectOffset(frame,
                                                          0,
                                                          frame.size.height );
  
  
    self.datePickerContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
  
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.datePickerComponentsContainer.frame = frame;
                         self.datePickerContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];

                     } completion:^(BOOL finished){
                     }];
  
    return true;
}

- (BOOL)showForPad:(NSMutableDictionary *)options
{
    self.datePickerPopover = [self createPopover:options];
    return true;
}

- (void)hide
{
    if (isIPhone)
    {
        CGRect frame = CGRectOffset(self.datePickerComponentsContainer.frame,
                                    0,
                                    self.datePickerComponentsContainer.frame.size.height);
    
        [UIView animateWithDuration:ANIMATION_DURATION
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.datePickerComponentsContainer.frame = frame;
                             self.datePickerContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
                       
                         } completion:^(BOOL finished) {
                             [self.datePickerContainer removeFromSuperview];
                         }];

    }
    else
    {
        [self.datePickerPopover dismissPopoverAnimated:YES];
    }
}

#pragma mark - Actions
- (IBAction)doneAction:(id)sender
{
    [self jsDateSelected];
    [self hide];
}
  
- (IBAction)cancelAction:(id)sender
{
    [self jsCancel];
    [self hide];
}

- (void)dateChangedAction:(id)sender
{
    [self jsDateSelected];
}

#pragma mark - JS API
- (void)jsCancel
{
    NSLog(@"JS Cancel is going to be executed");
    NSString* jsCallback = [NSString stringWithFormat:@"datePicker._dateSelectionCanceled();"];
    [self.commandDelegate evalJs:jsCallback];
}

- (void)jsDateSelected
{
    NSTimeInterval seconds = [self.datePicker.date timeIntervalSince1970];
    NSString* jsCallback = [NSString stringWithFormat:@"datePicker._dateSelected(\"%f\");", seconds];
    //NSLog(jsCallback);
    [self.commandDelegate evalJs:jsCallback];
}

#pragma mark - UIPopoverControllerDelegate methods
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
}

#pragma mark - Factory methods
- (UIPopoverController *)createPopover:(NSMutableDictionary *)options
{
    CGFloat pickerViewWidth = 320.0f;
    CGFloat pickerViewHeight = 216.0f;
    UIView *datePickerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pickerViewWidth, pickerViewHeight)];
  
    CGRect frame = CGRectMake(0, 0, 0, 0);
    if(!self.datePicker){
        self.datePicker = [self createDatePicker:options frame:frame];
        [self.datePicker addTarget:self action:@selector(dateChangedAction:) forControlEvents:UIControlEventValueChanged];
    }
    
    [self readParametersFromOptionsDictionary:options];
    [self updateUIComponents];
    [datePickerView addSubview:self.datePicker];
  
    UIViewController *datePickerViewController = [[UIViewController alloc]init];
    datePickerViewController.view = datePickerView;
  
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:datePickerViewController];
    popover.delegate = self;
    [popover setPopoverContentSize:CGSizeMake(pickerViewWidth, pickerViewHeight) animated:NO];
  
    CGFloat x = [[options objectForKey:@"x"] intValue];
    CGFloat y = [[options objectForKey:@"y"] intValue];
    CGRect anchor = CGRectMake(x, y, 1, 1);
    [popover presentPopoverFromRect:anchor inView:self.webView.superview  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
  
    return popover;
}

-(void) readParametersFromOptionsDictionary:(NSMutableDictionary*)options
{
    if([self doesDictionaryContainsKey:options andKey:@"mode"])
    {
        _mode = [options objectForKey:@"mode"];
    }
    if([self doesDictionaryContainsKey:options andKey:@"date"])
    {
        _initDate = [[options objectForKey:@"date"] doubleValue];
    }
    if([self doesDictionaryContainsKey:options andKey:@"minDate"])
    {
        _minDate = [[options objectForKey:@"minDate"] doubleValue];
    }
    if([self doesDictionaryContainsKey:options andKey:@"maxDate"])
    {
        _maxDate = [[options objectForKey:@"maxDate"] doubleValue];
    }
    if([self doesDictionaryContainsKey:options andKey:@"minuteInterval"])
    {
        _minuteInterval = [[options objectForKey:@"minuteInterval"] integerValue];
    }
    
    if([self doesDictionaryContainsKey:options andKey:@"negativeButtonText"])
    {
        _negativeButtonText = [options objectForKey:@"negativeButtonText"];
    }
    
    if([self doesDictionaryContainsKey:options andKey:@"positiveButtonText"])
    {
        _positiveButtonText = [options objectForKey:@"positiveButtonText"];
    }
}

-(BOOL) doesDictionaryContainsKey:(NSDictionary*)dict andKey:(NSString*)key
{
    if([dict objectForKey:key])
    {
        return YES;
    }
    return NO;
}

- (UIDatePicker *)createDatePicker:(NSMutableDictionary *)options frame:(CGRect)frame
{
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:frame];
    return datePicker;
}

-(void) updateUIComponents
{
    // picker
    if ([_mode isEqualToString:@"date"]) {
        self.datePicker.datePickerMode = UIDatePickerModeDate;
    }
    else if ([_mode isEqualToString:@"time"])
    {
        self.datePicker.datePickerMode = UIDatePickerModeTime;
    } else
    {
        self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    }
    
    self.datePicker.timeZone = [NSTimeZone defaultTimeZone];
    self.datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    
    self.datePicker.date = [NSDate dateWithTimeIntervalSince1970:_initDate / 1000];
    self.datePicker.minimumDate = [NSDate dateWithTimeIntervalSince1970:_minDate / 1000];
    self.datePicker.maximumDate = [NSDate dateWithTimeIntervalSince1970:_maxDate / 1000];
    self.datePicker.minuteInterval = _minuteInterval;
    
    // buttons
    [self.doneButton setTitle:_positiveButtonText];
    [self.cancelButton setTitle:_negativeButtonText];
}

- (NSDateFormatter *)createISODateFormatter:(NSString *)format timezone:(NSTimeZone *)timezone
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // Locale needed to avoid formatter bug on phones set to 12-hour
    // time to avoid it adding AM/PM to the string we supply
    // See: http://stackoverflow.com/questions/6613110/what-is-the-best-way-to-deal-with-the-nsdateformatter-locale-feature
    NSLocale *loc = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale: loc];
    [dateFormatter setTimeZone:timezone];
    [dateFormatter setDateFormat:format];
  
    return dateFormatter;
}

#pragma mark - Utilities

/*! Converts a hex string into UIColor
 It based on http://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
 
  @param hexString The hex string which has to be converted
 */
- (UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
