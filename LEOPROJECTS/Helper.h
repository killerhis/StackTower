//
//  Helper.h
//  Tapcraft
//
//  Created by Philips - sanny on 1/2/13.
//
//

#import <Foundation/Foundation.h>

@interface Helper : NSObject
-(BOOL) makeFileWithName:(NSString*)Filename andWriteToIt:(NSDictionary*) dic;
-(BOOL) copyThisFileToRoot:(NSString*) fileName;
-(NSString*) getStringFromFile:(NSString*)filePath What:(NSString*) this;
-(void) saveDataToFile:(NSString*) filename forTitle:(NSString*)title what:(NSString*) this;
-(NSDictionary*) settings;
@end

