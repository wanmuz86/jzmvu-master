//
//  BottomSwipeView.m
//  myjam
//
//  Created by nazri on 12/24/12.
//  Copyright (c) 2012 me-tech. All rights reserved.
//

#import "BottomSwipeViewFavBox.h"
#import "AppDelegate.h"
#import "ASIWrapper.h"
#import <QuartzCore/QuartzCore.h>
#import "BoxViewController.h"

#define kFrameHeightOnKeyboardUp 540.0f

static int kLabelTagStart = 100;
static int kImageTagStart = 1000;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

@interface BottomSwipeViewFavBox ()

@end

@implementation BottomSwipeViewFavBox

@synthesize checkedCategories,contentSwitch,label,addNewFolder,animatedDistance,lblTagToSendOnTapRec,favFolderName,editFolder,
    replaceLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self reloadCategories];
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)reloadCategories
{
    NSLog(@"reload categories");
    [self.scroller setContentOffset:CGPointMake(0, 0) animated:NO];
    for (UIView *aView in [self.contentView subviews]) {
        if ([aView isKindOfClass:[UILabel class]] || [aView isKindOfClass:[UIImageView class]]) {
            [aView removeFromSuperview];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self beginProcessData];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self beginProcessData];
}

- (IBAction)firstButton:(id)sender
{
    NSLog(@"FirstButton Will Be Sent");
    
    UIButton *btn1 = (UIButton *)[self.view viewWithTag:1];
    UIButton *btn2 = (UIButton *)[self.view viewWithTag:2];
    btn1.backgroundColor = [UIColor darkGrayColor];
    btn2.backgroundColor = [UIColor clearColor];
    
    [self.activityView startAnimating];
    [label setText:@""];
    
    contentSwitch = @"0";
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self performSelector:@selector(setupCatagoryList) withObject:self afterDelay:0.5f];
}

- (IBAction)secondButton:(id)sender
{
    NSLog(@"SecondButton Will Be Sent");
    NSLog(@"Reload Data");
    
    UIButton *btn1 = (UIButton *)[self.view viewWithTag:1];
    UIButton *btn2 = (UIButton *)[self.view viewWithTag:2];
    btn1.backgroundColor = [UIColor clearColor];
    btn2.backgroundColor = [UIColor darkGrayColor];
    
    [self.activityView startAnimating];
    [label setText:@""];
    
    contentSwitch = @"1";
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self performSelector:@selector(setupCatagoryList) withObject:self afterDelay:0.5f];
}

- (void)beginProcessData
{
    isSearchDisabled = NO;
    
    checkedCategories = [[NSMutableDictionary alloc] init];
    
    // Do any additional setup after loading the view from its nib.
    [self.scroller setContentSize:self.contentView.frame.size];
    [self.scroller addSubview:self.contentView];
    [self.scroller bringSubviewToFront:self.activityView];
    [self.view addSubview:self.scroller];
    
    self.searchTextField.delegate = self;
    CGFloat buttonHeight = 35.0f;
    UIButton *myBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    myBtn.frame = CGRectMake((self.view.bounds.size.width/2)-(160/2), self.view.frame.size.height-(buttonHeight+15), 160, buttonHeight);    //your desired size
    myBtn.clipsToBounds = YES;
    myBtn.layer.cornerRadius = 12.0f;
    [myBtn.layer setBorderWidth:2];
    [myBtn.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    myBtn.backgroundColor = [UIColor colorWithHex:@"#D22042"];
    [myBtn setShowsTouchWhenHighlighted:YES];
    [myBtn setTitle:@"Continue" forState:UIControlStateNormal];
    [myBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [myBtn setTintColor:[UIColor whiteColor]];
    [myBtn addTarget:self action:@selector(handleContinueButton) forControlEvents:UIControlEventTouchUpInside];
    
    [self.closeSwipeButton addTarget:self action:@selector(bringBottomViewDown) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:myBtn];
    
    UISwipeGestureRecognizer *twoFingerSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(bringBottomViewDown)];
    [twoFingerSwipe setDirection:UISwipeGestureRecognizerDirectionDown];
    [twoFingerSwipe setDelaysTouchesBegan:YES];
    [twoFingerSwipe setNumberOfTouchesRequired:2];
    
    [[self view] addGestureRecognizer:twoFingerSwipe];
    
    
    UIPanGestureRecognizer *slideRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:nil];
    slideRecognizer.delegate = self;
    [self.contentView addGestureRecognizer:slideRecognizer];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self.view];
    NSLog(@"YES %f - %f",translation.y, translation.x);
    
    if(gestureRecognizer.numberOfTouches == 2){
        NSLog(@"2");
        if (translation.y > 0) {
            NSLog(@"slide down now");
            [self bringBottomViewDown];
            return YES;
        }
    }
    else{
        NSLog(@"%d",gestureRecognizer.numberOfTouches);
    }
    
    NSLog(@"NO");
    return NO;
}

- (void)bringBottomViewDown
{
    AppDelegate *mydelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [mydelegate handleSwipeUp]; // Bring bottom view down
}

- (void)handleContinueButton
{
    NSLog(@"handleContinueButton");
    [self bringBottomViewDown];
    
    if (!isSearchDisabled) {
//        [self performSelectorOnMainThread:@selector(processCategoryFilter) withObject:nil waitUntilDone:NO];
//        [self processCategoryFilter];
        AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [DejalBezelActivityView activityViewForView:mydelegate.window withLabel:@"Loading ..." width:100];
        
        [self performSelector:@selector(processCategoryFilter) withObject:nil afterDelay:1.0];
    }
    
}

- (void)processCategoryFilter
{
    
    AppDelegate *mydelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    BoxViewController *box = [mydelegate.boxNavController.viewControllers objectAtIndex:0];
    NSMutableString *strData = [NSMutableString stringWithFormat:@""];
    int i = 0;
    for (id row in checkedCategories) {
        if (i == 0) {
            strData = [NSString stringWithFormat:@"%@",row];
        }else{
            strData = [NSString stringWithFormat:@"%@,%@",strData,row];
        }
        
        i++;
    }
    
    NSLog(@"data: %@",strData);
    
//    [hm.nv refreshTableItemsWithFilter:strData];
    [box.fbvc refreshTableItemsWithFilter:strData andSearchedText:self.searchTextField.text];
    
//    [DejalBezelActivityView removeViewAnimated:YES];
}

- (IBAction)clearButton:(id)sender
{
    if (!isSearchDisabled) {
        [checkedCategories removeAllObjects];
        self.searchTextField.text = @"";
    }
    
    [self handleContinueButton];
}

- (NSString *)returningAPIString
{
    return [NSString stringWithFormat:@"%@/api/fav_folder.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
}

- (NSString *)returningDataContent
{
    return [NSString stringWithFormat:@"{\"flag\":\"FAVOURITE_LIST\"}"];
}

- (void)setupCatagoryList
{
    NSLog(@"setupCatagoryList. checked %d",[checkedCategories count]);
    
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)]; //clear content first before reload
    
    [self.activityView startAnimating];
    
    NSDictionary *categories;
    
    NSString *urlString = [self returningAPIString];
    NSLog(@"(BottomSwipeView) Vardumping UrlString: %@",urlString);
    NSString *dataContent = [self returningDataContent];
    NSLog(@"(BottomSwipeView) Vardumping dataContent: %@",dataContent);
    
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"(BottomSwipeView) Vardumping response: %@",response);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] mutableCopy];
    NSLog(@"(BottomSwipeView) Vardumping resultsDictionary: %@",resultsDictionary);
    
    //BottomSwipeView Customization after action
    
    NSString *setList, *setId, *setIdName = nil;
    
    if ([contentSwitch isEqual: @"0"] || contentSwitch == nil)
    {
        setList = @"list";
        setId = @"fav_folder_id";
        setIdName = @"fav_folder_name";
    }
    else if([contentSwitch isEqual:@"1"])
    {
        setList = @"list";
        setId = @"fav_folder_id";
        setIdName = @"fav_folder_name";
    }
    
    
    if([resultsDictionary count])
    {
        NSString *status = [resultsDictionary objectForKey:@"status"];
        
        if ([status isEqualToString:@"ok"])
        {
            isSearchDisabled = NO;
            [self.searchTextField setEnabled:YES];
            
            categories = [resultsDictionary objectForKey:setList];
            
            CGFloat totalHeight = 10;
            CGRect labelFrame;
            CGRect imgFrame;
            
            CGFloat imgWidth = 10;
            CGFloat labelWidth = 130;
            CGFloat labelHeight = 17;
            CGFloat horizontalGap = 20;
            CGFloat verticalGap = 16;
            
            CGFloat leftX = 10;
            CGFloat leftY = 5;
            CGFloat rightX = leftX + labelWidth + horizontalGap;
            CGFloat rightY = 5;
            
            int item = 0;
            
            // setup label and check image
            if (![categories isEqual:[NSNull null]])
            {
                NSInteger count = 0;
                //if content is available
                
                for (id row in categories)
                {
                    count = count + 1;
                    if ((item%2) == 0)
                    { // left column
                        imgFrame = CGRectMake(leftX, leftY + 2, imgWidth, imgWidth);
                        labelFrame = CGRectMake( leftX + imgWidth + 5,
                                                leftY,
                                                labelWidth,
                                                labelHeight);
                        leftY += labelHeight + verticalGap;
                    
                    }
                    else
                    {
                        imgFrame = CGRectMake(rightX, rightY + 2, imgWidth, imgWidth);
                        labelFrame = CGRectMake( rightX + imgWidth + 5,
                                                rightY,
                                                labelWidth,
                                                labelHeight);
                        rightY += labelHeight + verticalGap;
                    }
                
                    UIImageView *imgView = [[UIImageView alloc] initWithFrame:imgFrame]; //create ImageView
                    imgView.tag = kImageTagStart + [[row objectForKey:setId] intValue];
                    imgView.image = [UIImage imageNamed:@"checkbox_on"];
                
                
                    // If already checked before no need to set hidden
                    if (![self isAlreadyChecked:imgView.tag]) {
                        [imgView setHidden:YES];
                    }
                
                    label = [[UILabel alloc] initWithFrame: labelFrame];
                    [label setTag:kLabelTagStart + [[row objectForKey:setId] intValue]];
                    [label setText: [row objectForKey:setIdName]];
                    [label setTextColor: [UIColor whiteColor]];
                    [label setBackgroundColor:[UIColor clearColor]];
                    [label setFont:[UIFont systemFontOfSize:12]];
                    [label setNumberOfLines:0];
                    [label sizeToFit];
                
                    label.userInteractionEnabled = YES;
                    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapCategory:)];
                    [label addGestureRecognizer:tapRecognizer];
                
                    // add img checkbox and label to contentView
                    [self.contentView addSubview: imgView];
                    [self.contentView addSubview: label];
                
                    item++;
                    [tapRecognizer release];
                    [imgView release];
                    [label release];
                }
                
                if ([contentSwitch isEqual:@"1"])
                {
                
                    if ((item%2) == 0)
                    { // left column
                        labelFrame = CGRectMake( leftX + imgWidth + 5,
                                                leftY,
                                                100,
                                                18);
                        leftY += labelHeight + verticalGap;
                    
                    }
                    else
                    {
                        labelFrame = CGRectMake( rightX + imgWidth + 5,
                                                rightY,
                                                100,
                                                18);
                        rightY += labelHeight + verticalGap;
                    }

                    addNewFolder = [[UITextField alloc]initWithFrame:labelFrame];
                    addNewFolder.delegate = self;
                    addNewFolder.tag = 1;
                    addNewFolder.text = @"Add a new folder here...";
                    addNewFolder.font = [UIFont fontWithName:@"Arial" size:12];
                    addNewFolder.backgroundColor = [UIColor whiteColor];
                    addNewFolder.layer.borderColor = [[UIColor blackColor]CGColor];
                    addNewFolder.layer.cornerRadius = 2.0f;
                    addNewFolder.layer.borderWidth = 2.0f;
                    addNewFolder.layer.masksToBounds = YES;
                    [addNewFolder setReturnKeyType:UIReturnKeyDone];
                
                    [self.contentView addSubview:addNewFolder];
                    [addNewFolder release];
                }
                
                // set scrollerview to fit size of catogery list
                totalHeight += leftY;
                [self.scroller setContentSize:CGSizeMake(self.contentView.frame.size.width, totalHeight)];
                
                if ((count == 0 || count == 1) && [contentSwitch isEqual:@"1"])
                {
                    CustomAlertView *appearTutorial = [[CustomAlertView alloc] initWithTitle:@"Favourites" message:@"Type your new or edit existing Fav name, then press DONE button at the right bottom of your keyboard when done." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [appearTutorial show];
                    [appearTutorial release];
                }
            }
            else
            {
                
                //if content is not available
                
                if ([contentSwitch isEqual:@"0"] || contentSwitch == nil)
                {
                    [self preparingDefaultFolder];
                }
                
                if ([contentSwitch isEqual:@"1"])
                {
                    
                    addNewFolder = [[UITextField alloc]initWithFrame:CGRectMake(5, 5, 140, 20)];
                    addNewFolder.delegate = self;
                    addNewFolder.text = @"Add a new folder here...";
                    addNewFolder.tag = 1;
                    addNewFolder.font = [UIFont fontWithName:@"Arial" size:14];
                    addNewFolder.backgroundColor = [UIColor whiteColor];
                    addNewFolder.layer.borderColor = [[UIColor blackColor]CGColor];
                    addNewFolder.layer.cornerRadius = 2.0f;
                    addNewFolder.layer.borderWidth = 2.0f;
                    addNewFolder.layer.masksToBounds = YES;
                    [addNewFolder setReturnKeyType:UIReturnKeyDone];
                
                    [self.contentView addSubview:addNewFolder];
                    [addNewFolder release];
                    
                    
                    
                }
                /*
                else if ([contentSwitch isEqual:@"1"])
                {
                    isSearchDisabled = YES;
                    [self.searchTextField setEnabled:NO];
                    
                    label = [[UILabel alloc] initWithFrame: CGRectMake(5, self.scroller.frame.size.height/2-30, self.scroller.frame.size.width-10, 44)];
                    [label setText:@"You don't have any existing folders yet."];
                    [label setTextColor: [UIColor whiteColor]];
                    [label setTextAlignment:NSTextAlignmentCenter];
                    [label setBackgroundColor:[UIColor clearColor]];
                    [label setFont:[UIFont systemFontOfSize:14]];
                    [label setNumberOfLines:0];
                    [self.contentView addSubview: label];
                    [self.scroller setContentSize:CGSizeMake(self.contentView.frame.size.width, self.scroller.frame.size.height)];
                }
                 */
            }
            
        }else{
            NSLog(@"Connection Failed");
            
            isSearchDisabled = YES;
            [self.searchTextField setEnabled:NO];
            
            label = [[UILabel alloc] initWithFrame: CGRectMake(5, self.scroller.frame.size.height/2-30, self.scroller.frame.size.width-10, 44)];
            [label setText:@"Connection Failed.\nPlease try again later."];
            [label setTextColor: [UIColor whiteColor]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setFont:[UIFont systemFontOfSize:14]];
            [label setNumberOfLines:0];
            [self.contentView addSubview: label];
            [self.scroller setContentSize:CGSizeMake(self.contentView.frame.size.width, self.scroller.frame.size.height)];
            
        }
    }
    [self.activityView stopAnimating];
    [DejalBezelActivityView removeViewAnimated:YES];
    
    [resultsDictionary release];
}

- (void)preparingDefaultFolder
{
    //prepare to create default folder if there is no single folder yet.
    
    NSLog(@"No single folder detected. Create new one for user");
    
    [self.activityView startAnimating];
    [self storeOrModifyFavFolder:1 withFolderName:@"My Fav Folder" andFolderID:nil];
    
}

- (void)storeOrModifyFavFolder:(NSInteger)tagID withFolderName:(NSString *)folderName andFolderID:(NSInteger)folderID
{
    NSLog(@"(storeOrModifyFavFolder) recheck value tagID %d, Folder Name %@, and folderID %d",tagID,folderName,folderID);
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/fav_folder.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
    NSLog(@"(storeOrModifyFavFolder) Vardumping UrlString: %@",urlString);
    
    NSString *dataContent = nil;
    
    if (tagID == 1)
    {
        dataContent = [NSString stringWithFormat:@"{\"flag\":\"NEW_FAV\",\"fav_folder_name\":\"%@\"}",folderName];
    }
    else if (tagID == 2)
    {
        dataContent = [NSString stringWithFormat:@"{\"flag\":\"EDIT_FAV\",\"fav_folder_name\":\"%@\",\"fav_folder_id\":\"%d\"}",folderName,folderID-kLabelTagStart];
    }
    NSLog(@"(storeOrModifyFavFolder) Vardumping dataContent: %@",dataContent);
    
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"(storeOrModifyFavFolder) Vardumping response: %@",response);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] mutableCopy];
    NSLog(@"(storeOrModifyFavFolder) Vardumping resultsDictionary: %@",resultsDictionary);
    
    if([resultsDictionary count])
    {
        NSString *status = [resultsDictionary objectForKey:@"status"];
        
        if ([status isEqual:@"ok"])
        {
            [self reloadCategories];
            [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [self.activityView startAnimating];
            [label setText:@""];
        
            [self performSelector:@selector(setupCatagoryList) withObject:self afterDelay:0.5f];
        }
    }
    
}

- (BOOL)isAlreadyChecked:(int)key
{
    if ([checkedCategories objectForKey:[NSString stringWithFormat:@"%d",key-kImageTagStart]]) {
        return YES;
    }
    
    return NO;
}

- (void)handleTapCategory:(id)sender
{
    
    NSLog(@"tapped on label %d",[(UIGestureRecognizer *)sender view].tag);
    int imgTag = kImageTagStart + [(UIGestureRecognizer *)sender view].tag - kLabelTagStart;
    int labelTag = [(UIGestureRecognizer *)sender view].tag;
    
    NSString *val = [NSString stringWithFormat:@"%d", imgTag-kImageTagStart];
    
    UIImageView *imgv = (UIImageView *)[self.view viewWithTag:imgTag];
    UILabel *aLabel = (UILabel *)[self.view viewWithTag:labelTag];
    CGRect imgFrame = aLabel.frame;
    
    
    /*
    UITextField *aEditTextField = [[UITextField alloc] initWithFrame:imgFrame];
    
    aEditTextField.text = @"";
    aEditTextField.delegate = self;
    aEditTextField.font = [UIFont fontWithName:@"Arial" size:12];
    aEditTextField.backgroundColor = [UIColor whiteColor];
    aEditTextField.layer.borderColor = [[UIColor blackColor]CGColor];
    aEditTextField.layer.cornerRadius = 2.0f;
    aEditTextField.layer.borderWidth = 2.0f;
    aEditTextField.layer.masksToBounds = YES;
    [aEditTextField setReturnKeyType:UIReturnKeyDone];

    
    [self.contentView addSubview:aEditTextField];
    [aEditTextField setText:aLabel.text];
    
    */
    
    if (contentSwitch == nil || [contentSwitch isEqual:@"0"])
    {
        if ([imgv isHidden])
        {
            [imgv setHidden:NO];
            [checkedCategories setObject:val forKey:val];
        }
        else
        {
            [imgv setHidden:YES];
            [checkedCategories removeObjectForKey:val];
        }
        lblTagToSendOnTapRec = 0;
        //favFolderName = addNewFolder.text;
    }
    else if([contentSwitch isEqual:@"1"])
    {
        [aLabel setHidden:YES];
        [imgv setHidden:YES];
        
        editFolder = [[UITextField alloc] initWithFrame:CGRectMake(imgFrame.origin.x, imgFrame.origin.y, 100, imgFrame.size.height)];
        editFolder.text = aLabel.text;
        editFolder.tag = 2;
        editFolder.delegate = self;
        editFolder.font = [UIFont fontWithName:@"Arial" size:12];
        editFolder.backgroundColor = [UIColor whiteColor];
        editFolder.layer.borderColor = [[UIColor blackColor]CGColor];
        editFolder.layer.cornerRadius = 2.0f;
        editFolder.layer.borderWidth = 2.0f;
        editFolder.layer.masksToBounds = YES;
        [editFolder setReturnKeyType:UIReturnKeyDone];
        
        [self.contentView addSubview:editFolder];
        //[editFolder release];
        lblTagToSendOnTapRec = [(UIGestureRecognizer *)sender view].tag;
        //favFolderName = addNewFolder.text;
    }

}

#pragma mark -
#pragma mark Textfield Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //    textField.contentInset = UIEdgeInsetsZero;
    
    addNewFolder.text = @"";
    
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if(heightFraction < 0.0){
        
        heightFraction = 0.0;
        
    }else if(heightFraction > 1.0){
        
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown){
        
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
        
    }else{
        
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"textfield tag: %d",textField.tag);
    NSLog(@"Check label tag: %d",lblTagToSendOnTapRec);
//    NSLog(@"Fav Folder Name AddNewFolder: %@",addNewFolder.text);
//    NSLog(@"Fav Folder Name EditExistingFolder: %@",editFolder.text);
    
    if ([addNewFolder.text length])
    {
        [self storeOrModifyFavFolder:textField.tag withFolderName:addNewFolder.text andFolderID:lblTagToSendOnTapRec];
    }
    else if ([editFolder.text length])
    {
        [self storeOrModifyFavFolder:textField.tag withFolderName:editFolder.text andFolderID:lblTagToSendOnTapRec];
    }
    
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
//    [checkedCategories release];
    [_scroller release];
    [_contentView release];
    [_activityView release];
    [_continueButton release];
    [_searchTextField release];
    [_closeSwipeButton release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setScroller:nil];
    [self setContentView:nil];
    [self setActivityView:nil];
    [self setContinueButton:nil];
    [self setSearchTextField:nil];
    [self setCloseSwipeButton:nil];
    [super viewDidUnload];
}
@end
