//
//  ViewController.h
//  twitterFeed
//
//  Created by Eric Weglarz on 8/21/12.
//  Copyright (c) 2012 Eric Weglarz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "twitterCell.h"

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    IBOutlet UITableView *feedTableView;
    IBOutlet UITextField *usernameTextField;
    NSString *twitterUsername;
    NSInteger twitterArrayCount;
    NSString *twitterResponseString;
    IBOutlet UIActivityIndicatorView *indicatorView;
}


@end
