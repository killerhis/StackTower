//
//  PurchasedViewController.m
//  PHLO
//
//  Created by Philips on 12/28/13.
//  Copyright (c) 2013 Leo. All rights reserved.
//

#define IS_IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad


#import "PurchasedViewController.h"
#import "Helper.h"
#import "defined.h"
#import "ViewController.h"

@interface PurchasedViewController ()

@property ( nonatomic , strong ) Helper *hlp;

@end

@implementation PurchasedViewController
@synthesize hlp;
@synthesize tt;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    

    
    hlp = [[Helper alloc] init];
    int saved  =   [[hlp getStringFromFile:@"settings.plist" What:@"ADS"] intValue];
    
       
    if (!saved)
    {
        @try {
            _productID = k_remove_ADS;
            [self getProductID];

        }
        @catch (NSException *exception) {
            NSLog(@"An error");
        }
       
        
        
    } else
    {
        NSLog(@"this item has been purchased");
    }

       
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)BuyProduct:(id)sender {
    NSLog(@"%s",__PRETTY_FUNCTION__);

    [tt startAnimating];
    
    [_buyButton setEnabled:NO];
    [_restoreButton setEnabled:NO];

    @try {
        SKPayment *payment  = [SKPayment paymentWithProduct:_product];
        [[SKPaymentQueue defaultQueue ] addTransactionObserver:self];
        
        [[SKPaymentQueue defaultQueue] addPayment:payment];

    }
    @catch (NSException *exception) {
        NSLog(@"an error");
    }
       
    
}

- (IBAction)restore:(id)sender {
    NSLog(@"%s",__PRETTY_FUNCTION__);

    
    [[SKPaymentQueue defaultQueue ] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    
}

- (IBAction)QuitTheScene {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void) getProductID
{
    NSLog(@"%s",__PRETTY_FUNCTION__);

    if ( [SKPaymentQueue canMakePayments])
    {
        NSLog(@"CAN");
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:_productID]];
        request.delegate = self;
        [request start];
        
    } else
    {
        _productDescription.text = @"please enable in app purcahse in your settings";
    }
}
-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Cannot connect to iTunes Store, Try Again!" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    
    NSLog(@"%@", error.description);
}

-(void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSArray *products = response.products;
    
    if ( products.count != 0 )
    {
        _product = products[0];
        _buyButton.enabled = YES;
        _restoreButton.enabled = YES;
        _productTitle.text = _product.localizedTitle;
        _productDescription.text = _product.localizedDescription;
        [tt stopAnimating];
        
    } else
    {
        _productTitle.text = @"product Not Found";
    }
    
    products = response.invalidProductIdentifiers;
    
    for ( SKProduct *product in products)
    {
        NSLog(@" Product Not found : %@", product);
    }
}

-(void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [self unlockPurchase];
}

-(void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
                
                
            case SKPaymentTransactionStatePurchasing:;
                break;
                
            case SKPaymentTransactionStateRestored:;
                break;
                
            case SKPaymentTransactionStateDeferred:;
                break;
                
                
            case SKPaymentTransactionStatePurchased:[self unlockPurchase];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
                
                
            case  SKPaymentTransactionStateFailed:NSLog(@"Transaction Faild");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ADS" message:@"There is something wrong! maybe you canceled the purchase OR it couldn't connect to the server! please try again later!" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
                break;
                
                
                

        }
    }
}

-(void) unlockPurchase
{
    
    
    NSLog(@"The purchased has been completed!");
    _buyButton.enabled = NO;
    [_buyButton setTitle:@"purchased" forState:UIControlStateDisabled];
    [hlp saveDataToFile:@"settings.plist" forTitle:@"ADS" what:@"1"];
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ADS" message:@"Congratulations‎! The ADS has been removed!" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    
}
- (void)viewDidUnload {
    [self setTt:nil];
    [self setRestoreButton:nil];
    [super viewDidUnload];
}
@end
