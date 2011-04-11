//
//  RootViewController.m
//  beatiful girls
//
//  Created by Alper Tayfun on 03-23-2011.
//  Copyright 2011 Alper Tayfun. All rights reserved.
//

#import "RootViewController.h"
#import "PhotoSet.h"

@implementation RootViewController

@synthesize photoSet = _photoSet;

@synthesize session = _session;
@synthesize loginDialog = _loginDialog;
@synthesize facebookName = _facebookName;
@synthesize posting = _posting;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight]; 
    //[infoButton addTarget:self action:@selector(showInfoView:) forControlEvents:UIControlEventTouchUpInside];
    //self.navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    
    
    
    self.navigationController.toolbar.backgroundColor = [UIColor blackColor];
    self.navigationBarStyle = UIBarStyleBlackTranslucent;
    self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
    self.photoSource = [PhotoSet samplePhotoSet];
    self.photoSet.title = @"Beatiful Girls";
    
    self.navigationItem.leftBarButtonItem = 
    [[[UIBarButtonItem alloc] initWithTitle:@"Share" 
                                      style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(addButtonPressed:)]
     autorelease];
    
    static NSString* kApiKey = @"d6ba5ed7797e20e1ea4cf298311bb890";
	static NSString* kApiSecret = @"3f64ad6af8a9c7fbab3ae66fb999b64a";
	_session = [[FBSession sessionForApplication:kApiKey secret:kApiSecret delegate:self] retain];
    [_session resume];

}
- (void)addButtonPressed:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Close" destructiveButtonTitle:nil otherButtonTitles:@"Share with Facebook",@"Share with Mail",@"Save my Photos", nil];
	[actionSheet showInView:self.view];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
	[actionSheet release];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%d",buttonIndex);
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0)
	{
        
        //NSURL    *aUrl  = [NSURL URLWithString:[_centerPhoto URLForVersion:TTPhotoVersionLarge]];
        //NSData   *data = [NSData dataWithContentsOfURL:aUrl];
        //UIImage  *img  = [[UIImage alloc] initWithData:data];
        
        //NSLog(@"photo:class %@", [img class]);
        
        //UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
        
        NSLog(@"Facebook");
		_posting = YES;
		// If we're not logged in, log in first...
		if (![_session isConnected]) {
			self.loginDialog = nil;
			_loginDialog = [[FBLoginDialog alloc] init];	
			[_loginDialog show];	
		}
		// If we have a session and a name, post to the wall!
		else if (_facebookName != nil) {
			[self postToWall];
		}
        
	}
    else if (buttonIndex == 1)
    {

        Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
        if (mailClass != nil)
        {
            // We must always check whether the current device is configured for sending emails
            if ([mailClass canSendMail])
            {
                [self displayComposerSheet];
            }
        }
        
    }
    else if (buttonIndex == 2)
    {
        NSURL    *aUrl  = [NSURL URLWithString:[_centerPhoto URLForVersion:TTPhotoVersionLarge]];
        NSData   *data = [NSData dataWithContentsOfURL:aUrl];
        UIImage  *img  = [[UIImage alloc] initWithData:data];
        
        NSLog(@"photo:class %@", [img class]);
        
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
    }
}

#pragma mark FBSessionDelegate methods

- (void)session:(FBSession*)session didLogin:(FBUID)uid {
	[self getFacebookName];
}

- (void)session:(FBSession*)session willLogout:(FBUID)uid {
	//_logoutButton.hidden = YES;
	_facebookName = nil;
}

#pragma mark Get Facebook Name Helper

- (void)getFacebookName {
	NSString* fql = [NSString stringWithFormat:
					 @"select uid,name from user where uid == %lld", _session.uid];
	NSDictionary* params = [NSDictionary dictionaryWithObject:fql forKey:@"query"];
	[[FBRequest requestWithDelegate:self] call:@"facebook.fql.query" params:params];
}

#pragma mark FBRequestDelegate methods

- (void)request:(FBRequest*)request didLoad:(id)result {
	if ([request.method isEqualToString:@"facebook.fql.query"]) {
		NSArray* users = result;
		NSDictionary* user = [users objectAtIndex:0];
		NSString* name = [user objectForKey:@"name"];
		self.facebookName = name;		
		//[_logoutButton setTitle:[NSString stringWithFormat:@"Facebook: Logout as %@", name] forState:UIControlStateNormal];
		if (_posting) {
			[self postToWall];
			_posting = NO;
		}
	}
}

#pragma mark Post to Wall Helper

- (void)postToWall {
	
    //NSLog(@"photo: %@", [_centerPhoto URLForVersion:TTPhotoVersionLarge]);
	FBStreamDialog* dialog = [[[FBStreamDialog alloc] init] autorelease];
	dialog.userMessagePrompt = @"Enter your message:";
	//dialog.attachment = [NSString stringWithFormat:@"{\"name\":\"%@ Beatiful Girls for iPhone Kullanıyor. Sende denemek ister misin ?\"}",
	//					 _facebookName];
    
    dialog.attachment = [NSString stringWithFormat:@"{\"name\":\"%@ Beatiful Girls for iPhone Kullanıyor.\",\"href\":\"%@\",\"caption\":\"\",\"description\":\"\",\"media\":[{\"type\":\"image\",\"src\":\"%@\",\"href\":\"%@\"}]}",_facebookName,[_centerPhoto URLForVersion:TTPhotoVersionLarge],[_centerPhoto URLForVersion:TTPhotoVersionLarge],[_centerPhoto URLForVersion:TTPhotoVersionLarge]];
	dialog.actionLinks = @"[{\"text\":\"Sende Uygulamayı indir !\",\"href\":\"http://www.bgformobile.com/iphone/\"}]";
	[dialog show];
	
}


#pragma mail compose delegate

-(void)launchMailAppOnDevice
{
	NSString *recipients = @"mailto:first@example.com?cc=second@example.com,third@example.com&subject=Hello from California!";
	NSString *body = @"&body=It is raining in sunny California!";
	
	NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

- (void)receivedObject:(NSDictionary *)dictionary forRequest:(NSString *)connectionIdentifier {
	
	NSLog(@"Recieved Object: %@", dictionary);
}

- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)connectionIdentifier {
	
	NSLog(@"Direct Messages Received: %@", messages);
}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier {
	
	NSLog(@"User Info Received: %@", userInfo);
}

- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)connectionIdentifier {
	
	NSLog(@"Misc Info Received: %@", miscInfo);
}


-(IBAction)showPicker:(id)sender
{
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail])
		{
			[self displayComposerSheet];
		}
	}
}

-(void)displayComposerSheet 
{
	
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@"Beatiful Girls for Mobile"];
	
    NSString *bodys = [NSString stringWithFormat:@"<img src='%@' alt='%@'><br><br><br>Beatiful Girls for iPhone kullanıyorum.<br><br><br>",[_centerPhoto URLForVersion:TTPhotoVersionLarge],[_centerPhoto URLForVersion:TTPhotoVersionLarge]];
    
	NSString *emailBody = bodys;
    
	[picker setMessageBody:emailBody isHTML:YES];
	
	[self presentModalViewController:picker animated:YES];
    [picker release];
}



- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			//message.text = @"Result: canceled";
			NSLog(@"Result: canceled");
			break;
		case MFMailComposeResultSaved:
			//message.text = @"Result: saved";
			NSLog(@"Result: saved");
			break;
		case MFMailComposeResultSent:
			//message.text = @"Result: sent";
			NSLog(@"Result: sent");
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Mail Gönderildi" message:@"Mailiniz gönderilmiştir." delegate:self cancelButtonTitle:nil otherButtonTitles:nil] autorelease];
			// optional - add more buttons:
			[alert addButtonWithTitle:@"Yes"];
			[alert show];
			break;
		case MFMailComposeResultFailed:
			//message.text = @"Result: failed";
			alert = [[[UIAlertView alloc] initWithTitle:@"Mail Gönderilemedi" message:@"Eğer ki bu hatayı görüyorsanız lütfen ilk önce mail hesabınızı kontrol ediniz." delegate:self cancelButtonTitle:nil otherButtonTitles:nil] autorelease];
			NSLog(@"Result: failed");
			break;
		default:
			//message.text = @"Result: not sent";
			alert = [[[UIAlertView alloc] initWithTitle:@"Mail Gönderilemedi" message:@"Eğer ki bu hatayı görüyorsanız lütfen ilk önce mail hesabınızı kontrol ediniz." delegate:self cancelButtonTitle:nil otherButtonTitles:nil] autorelease];
			NSLog(@"Result: not sent");
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [super dealloc];
}

@end
