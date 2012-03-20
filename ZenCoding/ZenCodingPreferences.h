//
//  ZenCodingPreferences.h
//  ZenCoding
//
//  Created by Сергей Чикуёнок on 3/9/12.
//  Copyright (c) 2012 Аймобилко. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ZenCodingPreferences : NSWindowController {
    NSButton *pickExtensionsFolder;
	NSArrayController *syntaxList;
	NSTextField *extensionsPathField;
	NSTableView *snippetsView;
	NSTableView *abbreviationsView;
	NSTableView *variablesView;
	NSPopUpButton *syntaxPopup;
	NSObjectController *outputContext;
	NSArrayController *snippetsController;
	NSArrayController *abbreviationsController;
	NSArrayController *variablesController;
	
	NSMutableDictionary *outputPreferences;
	
	// pointer to currently edited array controller (snippets or abbreviations)
	NSArrayController *contextController;
}

@property (assign) IBOutlet NSArrayController *syntaxList;
@property (assign) IBOutlet NSTextField *extensionsPathField;
@property (assign) IBOutlet NSTableView *snippetsView;
@property (assign) IBOutlet NSTableView *abbreviationsView;
@property (assign) IBOutlet NSTableView *variablesView;
@property (assign) IBOutlet NSPopUpButton *syntaxPopup;
@property (assign) IBOutlet NSObjectController *outputContext;
@property (assign) IBOutlet NSArrayController *snippetsController;
@property (assign) IBOutlet NSArrayController *abbreviationsController;
@property (assign) IBOutlet NSArrayController *variablesController;

+ (void)loadDefaults;

- (IBAction)pickExtensionsFolder:(id)sender;
- (IBAction)addSnippet:(id)sender;
- (IBAction)editSnippet:(id)sender;
- (IBAction)removeSnippet:(id)sender;

@end