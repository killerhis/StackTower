//
//  PurchasedViewController.h
//  PHLO
//
//  Created by Philips on 12/28/13.
//  Copyright (c) 2013 Leo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface PurchasedViewController : UIViewController < SKPaymentTransactionObserver,SKProductsRequestDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *tt;

@property ( nonatomic, strong) SKProduct *product;
@property ( nonatomic, strong) NSString *productID;
@property (weak, nonatomic) IBOutlet UILabel *productTitle;
@property (weak, nonatomic) IBOutlet UILabel *productDescription;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
- (IBAction)BuyProduct:(id)sender;
- (IBAction)restore:(id)sender;
- (IBAction)QuitTheScene;

@property (weak, nonatomic) IBOutlet UIButton *restoreButton;
-(void) getProductID;
@end
