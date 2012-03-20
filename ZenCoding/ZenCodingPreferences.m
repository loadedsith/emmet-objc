//
//  ZenCodingPreferences.m
//  ZenCoding
//
//  Created by Сергей Чикуёнок on 3/9/12.
//  Copyright (c) 2012 Аймобилко. All rights reserved.
//

#import "ZenCodingPreferences.h"
#import "ZenCodingArrayTransformer.h"
#import "ZenCodingTildePathTransformer.h"
#import "ZenCodingSnippetEditor.h"
#import "ZenCodingDefaultsKeys.h"
#import "ZenCodingNotifications.h"

@interface ZenCodingPreferences ()
- (void)updateOutputPrefsContext;
- (NSArrayController *)contextControllerFromSender:(id)sender;
- (NSString *)nibNameFromSender:(id)sender;
- (NSMutableArray *)contentForController:(NSString *)preferenceName;
@end

@implementation ZenCodingPreferences
@synthesize outputContext;
@synthesize snippetsController;
@synthesize abbreviationsController;
@synthesize variablesController;
@synthesize syntaxList;
@synthesize extensionsPathField;
@synthesize snippetsView;
@synthesize abbreviationsView;
@synthesize variablesView;
@synthesize syntaxPopup;

+ (void)initialize {
	ZenCodingArrayTransformer *caseTransformer = [[[ZenCodingArrayTransformer alloc] initWithArray:[NSArray arrayWithObjects:@"lower", @"upper", @"asis", nil]] autorelease];
	
	ZenCodingArrayTransformer *quotesTransformer = [[[ZenCodingArrayTransformer alloc] initWithArray:[NSArray arrayWithObjects:@"single", @"double", nil]] autorelease];
	
	ZenCodingArrayTransformer *selfClosingTransformer = [[[ZenCodingArrayTransformer alloc] initWithArray:[NSArray arrayWithObjects:@"html", @"xml", @"xhtml", nil]] autorelease];
	ZenCodingTildePathTransformer *pathTransformer = [[ZenCodingTildePathTransformer new] autorelease];
	
	
	[NSValueTransformer setValueTransformer:caseTransformer forName:@"ZenCodingCaseTransformer"];
	[NSValueTransformer setValueTransformer:quotesTransformer forName:@"ZenCodingQuotesTransformer"];
	[NSValueTransformer setValueTransformer:selfClosingTransformer forName:@"ZenCodingSelfClosingTransformer"];
	[NSValueTransformer setValueTransformer:pathTransformer forName:@"ZenCodingTildePathTransformer"];
}

- (id)init {
    return [super initWithWindowNibName:@"Preferences"];
}

- (void)awakeFromNib {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *output = [defaults dictionaryForKey:Output];
	
	if (output) {
		outputPreferences = [output mutableCopy];
	} else {
		outputPreferences = [NSMutableDictionary new];
	}
	
	[snippetsController setContent:[self contentForController:Snippets]];
	[abbreviationsController setContent:[self contentForController:Abbreviations]];
	[variablesController setContent:[self contentForController:Variables]];
}

- (void)windowDidLoad
{
	NSWindow *window = [self window];
    [window setHidesOnDeactivate:NO];
    [window setExcludedFromWindowsMenu:YES];
	
	[snippetsView setTarget:self];
	[snippetsView setDoubleAction:@selector(editSnippet:)];
	
	[abbreviationsView setTarget:self];
	[abbreviationsView setDoubleAction:@selector(editSnippet:)];
	
	[variablesView setTarget:self];
	[variablesView setDoubleAction:@selector(editSnippet:)];
	
	[syntaxList addObserver:self 
				 forKeyPath:@"selectionIndexes" 
					options:NSKeyValueObservingOptionNew 
					context:NULL];
	
	[self updateOutputPrefsContext];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PreferencesWindowOpened object:self];
	
	[super windowDidLoad];
}

- (BOOL)windowShouldClose:(NSWindow *)window {
	// save output preferences
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:outputPreferences forKey:Output];
	[defaults setObject:[snippetsController content] forKey:Snippets];
	[defaults setObject:[abbreviationsController content] forKey:Abbreviations];
	[defaults setObject:[variablesController content] forKey:Variables];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PreferencesWindowClosed object:self];
	
    return [window makeFirstResponder:nil]; // validate editing
}

- (IBAction)pickExtensionsFolder:(id)sender {
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseFiles:NO];
	[panel setCanChooseDirectories:YES];
	[panel setAllowsMultipleSelection:NO];

	[panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
	    if (result == NSOKButton) {
			NSURL *url = [[panel URLs] objectAtIndex:0];
			if (url != nil) {
				NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				[defaults setValue:[url path] forKey:ExtensionsPath];
			}
			
	    }
	}];
	
}
+ (void)loadDefaults {
	//// reset defaults
//	NSDictionary *defaultsDictionary = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
//	for (NSString *key in [defaultsDictionary allKeys]) {
//		[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
//	}
//	[[NSUserDefaults standardUserDefaults] synchronize];
	//// /reset defaults
	
	
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"PreferencesDefaults2" ofType:@"plist"];
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:prefs];
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:prefs];
	[prefs release];
}


#pragma mark Snippet editing
- (IBAction)addSnippet:(id)sender {
	contextController = [self contextControllerFromSender:sender];
	
	if (contextController) {
		ZenCodingSnippetEditor *editor = [[ZenCodingSnippetEditor alloc] initWithWindowNibName:[self nibNameFromSender:sender]];
		NSDictionary *snippet = [editor openAddDialogForWindow:[self window]];
		if (snippet) {
			[contextController addObject:snippet];
			[snippet release];
		}
		[editor release];
	}
}

- (IBAction)removeSnippet:(id)sender {
	contextController = [self contextControllerFromSender:sender];
	
	if (contextController) {
		NSArray *selectedSnippets = [contextController selectedObjects];
		if ([selectedSnippets count]) {
			[contextController removeObjects:selectedSnippets];
		}
	}
	
}

- (void)editSnippet:(id)sender {
	contextController = [self contextControllerFromSender:sender];
	if (contextController) {
		ZenCodingSnippetEditor *editor = [[ZenCodingSnippetEditor alloc] initWithWindowNibName:[self nibNameFromSender:sender]];
		NSDictionary *snippet = [[contextController selectedObjects] objectAtIndex:0];
		
		if (snippet) {
			NSDictionary *editedSnippet = [editor openEditDialog:snippet forWindow:[self window]];
			if (editedSnippet) {
				[editedSnippet enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop){
					[snippet setValue:value forKey:key];
				}];
				
				[editedSnippet release];
			}
		}
		
		[editor release];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqual:@"selectionIndexes"] && object == syntaxList) {
		[self updateOutputPrefsContext];
	}
}

- (void)updateOutputPrefsContext {
	NSArray *syntaxArr = [syntaxList selectedObjects];
	if (syntaxArr && [syntaxArr count]) {
		NSDictionary *syntax = [[syntaxList selectedObjects] objectAtIndex:0];
		NSString *syntaxId = [syntax valueForKey:@"id"];
		[outputContext setContent:[outputPreferences objectForKey:syntaxId]];
	}
}

- (NSArrayController *)contextControllerFromSender:(id)sender {
	switch ([sender tag]) {
		case 1:
			return abbreviationsController;
		case 2:
			return snippetsController;
		case 3:
			return variablesController;
	}
	
	return nil;
}


- (NSString *)nibNameFromSender:(id)sender {
	if ([sender tag] == 3) {
		return @"VariableEditor";
	}
	
	return @"SnippetEditor";
}

- (NSMutableArray *)contentForController:(NSString *)preferenceName {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *_val = [defaults arrayForKey:preferenceName];
	NSMutableArray *result;
	if (_val) {
		result = [_val mutableCopy];
	} else {
		result = [NSMutableArray new];
	}
	
	return [result autorelease];
}

- (void)dealloc {
	[outputPreferences release];
	[super dealloc];
}

@end