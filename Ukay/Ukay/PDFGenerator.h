//
//  PDFGenerator.h
//  Ukay
//
//  Created by David Mazzitelli on 4/28/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFGenerator : NSObject

+ (void)createPDFfromUIView:(UIView *)view andImages:(NSArray *)images saveToDocumentsWithFileName:(NSString *)filename showAlert:(BOOL)showAlert;

@end
