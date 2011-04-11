//
//  RootViewController.h
//  beatiful girls
//
//  Created by Alper Tayfun on 03-23-2011.
//  Copyright 2011 Alper Tayfun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import <Three20/Three20.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class PhotoSet;
@class FBSession;


@interface RootViewController : TTPhotoViewController <UIActionSheetDelegate,FBSessionDelegate, FBRequestDelegate,MFMailComposeViewControllerDelegate> {

    //IBOutlet UIImageView *imgview22;
    PhotoSet *_photoSet;
    FBSession* _session;
	FBLoginDialog *_loginDialog;
	NSString *_facebookName;
	BOOL _posting;


}

//@property (nonatomic,retain) IBOutlet UIImageView *imgview22;
@property (nonatomic, retain) PhotoSet *photoSet;
@property (nonatomic, retain) FBSession *session;
@property (nonatomic, retain) FBLoginDialog *loginDialog;
@property (nonatomic, copy) NSString *facebookName;
@property (nonatomic, assign) BOOL posting;

- (void)postToWall;
- (void)getFacebookName;

- (void)displayComposerSheet;
- (void)launchMailAppOnDevice;
@end
