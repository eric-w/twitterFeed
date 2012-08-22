//
//  ViewController.m
//  twitterFeed
//
//  Created by Eric Weglarz on 8/21/12.
//  Copyright (c) 2012 Eric Weglarz. All rights reserved.
//

#import "ViewController.h"
#import "SBJson.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    twitterUsername = [[NSUserDefaults standardUserDefaults] objectForKey:@"twitterUserName"];
    if (twitterUsername != nil) {
        usernameTextField.text = twitterUsername;
        [self textFieldDidEndEditing:usernameTextField];
    }
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return !UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [indicatorView stopAnimating];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

-   (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData{
    NSString *responseString = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    if ([[responseString JSONValue] isKindOfClass:[NSDictionary class]] ) {
        NSDictionary *responseDictionary = [responseString JSONValue];
        NSString *errorString = [responseDictionary objectForKey:@"error"];
        if (errorString == nil) {
            NSArray *errorArray = [responseDictionary objectForKey:@"errors"];
            NSDictionary *errorDict = [errorArray objectAtIndex:0];
            errorString = [errorDict objectForKey:@"message"];
        }
        [indicatorView stopAnimating];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Twitter Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } else {
        NSArray *twitterArray = [responseString JSONValue];
        if (twitterArray.count == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Twitter Error" message:@"No Twitter messages for user." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            [indicatorView stopAnimating];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:usernameTextField.text forKey:@"twitterUserName"];
            twitterArrayCount = twitterArray.count;
            twitterResponseString = responseString;
            [feedTableView reloadData];
            [indicatorView stopAnimating];
        }
    }
}

#pragma mark - TableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return twitterArrayCount;
}

#pragma  mark - TableViewDataSource
-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    twitterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tweetCell"];
    if (indexPath.row % 2) {
        [cell.twitterTextView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0]];
    } else {
        [cell.twitterTextView setBackgroundColor:[UIColor whiteColor]];
    }
    NSArray *twitterArray = [twitterResponseString JSONValue];
    NSDictionary *tweetDictionary = [twitterArray objectAtIndex:indexPath.row];
    [cell.twitterTextView setText:[tweetDictionary objectForKey:@"text"]];
    return cell;
}

#pragma mark - TextFieldDelegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.length > 0) {
        NSString *requestString = [NSString stringWithFormat:@"https://api.twitter.com/1/statuses/user_timeline.json?include_entities=true&include_rts=true&screen_name=%@&count=20", textField.text];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]];
        NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (connection == nil) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Unable to connect to Twitter.  Check your internet connection and try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        } else {
            [indicatorView startAnimating];
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Username Error" message:@"Please enter a Twitter username" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
    }
}

@end
