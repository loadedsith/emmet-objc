//
//  NSTextView+ZenEditor.m
//  ZenCoding
//
//  Created by Сергей Чикуёнок on 2/6/12.
//  Copyright 2012 Аймобилко. All rights reserved.
//

#import "NSTextView+ZenEditor.h"
#import "ZenCodingTextProcessor.h"

@implementation NSTextView (NSTextView_ZenEditor)

- (NSUInteger) caretPos {
	NSRange sel = [self selectionRange];
	return sel.location;
}

- (void)setCaretPos:(NSUInteger)caretPos {
	[self setSelectedRange:NSMakeRange(caretPos, 0)];
}

- (NSRange) selectionRange {
    return [self selectedRange];
}

- (void) setSelectionRange:(NSRange)range {
    [self setSelectedRange:range];
}

- (NSString *)selection {
	return [[self content] substringWithRange:[self selectedRange]];
}

- (NSString *)content {
    return [self string];
}

- (NSString *)syntax {
    return DEFAULT_SYNTAX;
}

- (NSString *)profileName {
    return DEFAULT_PROFILE;
}

- (NSRange)currentLineRange {
    NSString *content = [self content];
	return [content lineRangeForRange:NSMakeRange(self.caretPos, 0)];
}

- (NSString *)currentLine {
	return [[self content] substringWithRange:[self currentLineRange]];
}

- (void) replaceContentWithValue:(NSString *)value from:(NSUInteger)start to:(NSUInteger)end withoutIndentation:(BOOL)indent{
	// check if range is in bounds
	if (end <= [[self string] length]) {
		ZenCodingTextProcessor *proc = [[ZenCodingTextProcessor alloc] initWithText:value];
		
		[self replaceCharactersInRange:NSMakeRange(start, end - start) withString:proc.processedText];
		
		ZCTabStop *firstTabStop = [proc.tabStops firstTabStop];
		if (firstTabStop != nil) {
			[self setSelectionRange:[firstTabStop rangeWithOffset:(int)start]];
		}
		
		[proc release];
	}
}

- (NSString *)prompt:(NSString *)label {
	return @"not implemented yet";
}

- (NSString *)filePath {
	return @"not implemented yet";
}

@end
