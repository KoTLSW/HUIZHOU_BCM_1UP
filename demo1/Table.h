//
//  Table.h
//  demo1
//
//  Created by mac on 2017/8/23.
//  Copyright © 2017年 maceastwin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Item.h"
@interface Table : NSViewController
@property(readwrite,copy)NSMutableArray* arrayDataSource;
@property (strong) IBOutlet NSView *custom;
@property (weak) IBOutlet NSScrollView *scrollview;
@property (weak) IBOutlet NSTableView *table;
//=============================================
- (id)init:(NSView*)parent DisplayData:(NSArray*)arrayData;

-(void)SelectRow:(int)rowindex;

-(void)flushTableRow:(Item*)item RowIndex:(NSInteger)rowIndex;

-(void)ClearTable;
//=============================================

@end
