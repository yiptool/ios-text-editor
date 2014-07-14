/* vim: set ai noet ts=4 sw=4 tw=115: */
//
// Copyright (c) 2014 Nikolay Zapolnov (zapolnov@gmail.com).
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
#import "NZTextEditorSubview.h"
#import "NZTextEditor.h"

@implementation NZTextEditorSubview
{
	CGRect startFrame;
}

-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		self.userInteractionEnabled = YES;
		self.multipleTouchEnabled = YES;

		[self addGestureRecognizer:
			[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)] autorelease]];
		[self addGestureRecognizer:
			[[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)] autorelease]];
		[self addGestureRecognizer:
			[[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinch:)] autorelease]];
	}

	return self;
}

-(void)dealloc
{
//	self.tapCallback = nil;
//	self.tapCallbackTarget = nil;
	[super dealloc];
}

-(void)layoutSubviews
{
	[super layoutSubviews];
	for (UIView * subview in self.subviews)
		subview.frame = self.bounds;
}

-(CGSize)superviewSize
{
	CGSize superviewSize = self.superview.bounds.size;
	if ([self.superview respondsToSelector:@selector(superviewSize)])
	{
		CGSize superviewContentSize = [(id)self.superview contentSize];
		superviewSize.width = MAX(superviewSize.width, superviewContentSize.width);
		superviewSize.height = MAX(superviewSize.height, superviewContentSize.height);
	}
	return superviewSize;
}

-(BOOL)rectFitsToSuperview:(CGRect)rect
{
	CGSize superviewSize = self.superviewSize;
	return (
		rect.origin.x >= 0 &&
		rect.origin.y >= 0 &&
		rect.origin.x + rect.size.width <= superviewSize.width &&
		rect.origin.y + rect.size.height <= superviewSize.height
	);
}

-(CGRect)limitRectToSuperviewBounds:(CGRect)rect
{
	CGSize superviewSize = self.superviewSize;
	rect.size.width = MIN(rect.size.width, superviewSize.width);
	rect.size.height = MIN(rect.size.height, superviewSize.height);
	rect.origin.x = MIN(MAX(rect.origin.x, 0), superviewSize.width - rect.size.width);
	rect.origin.y = MIN(MAX(rect.origin.y, 0), superviewSize.height - rect.size.height);
	return rect;
}

/*
-(void)setTapCallbackTarget:(id)target withSelector:(SEL)sel
{
	self.tapCallback = sel;
	self.tapCallbackTarget = target;
}
*/

-(void)onTap:(UITapGestureRecognizer *)recognizer
{
	switch (recognizer.state)
	{
	case UIGestureRecognizerStateFailed:
	case UIGestureRecognizerStateCancelled:
	case UIGestureRecognizerStatePossible:
	case UIGestureRecognizerStateBegan:
	case UIGestureRecognizerStateChanged:
		break;

	case UIGestureRecognizerStateEnded:
//		[self.tapCallbackTarget performSelector: self.tapCallback withObject: self];
		break;
	}
}

-(void)onPan:(UIPanGestureRecognizer *)recognizer
{
	CGRect newFrame;
	CGPoint pos;

	switch (recognizer.state)
	{
	case UIGestureRecognizerStateFailed:
	case UIGestureRecognizerStatePossible:
		break;

	case UIGestureRecognizerStateBegan:
		startFrame = self.frame;
		break;

	case UIGestureRecognizerStateCancelled:
		self.frame = startFrame;
		break;

	case UIGestureRecognizerStateChanged:
	case UIGestureRecognizerStateEnded:
		pos = [recognizer locationInView:self];
		newFrame = self.frame;
		newFrame.origin.x = startFrame.origin.x + pos.x;
		newFrame.origin.y = startFrame.origin.y + pos.y;
		self.frame = [self limitRectToSuperviewBounds:newFrame];
		if ([self.superview respondsToSelector:@selector(updateExclusionPaths)])
			[(id)self.superview updateExclusionPaths];
		break;
	}
}

-(void)onPinch:(UIPinchGestureRecognizer *)recognizer
{
	CGRect newFrame;

	switch (recognizer.state)
	{
	case UIGestureRecognizerStateFailed:
	case UIGestureRecognizerStatePossible:
		break;

	case UIGestureRecognizerStateBegan:
		startFrame = self.frame;
		break;

	case UIGestureRecognizerStateCancelled:
		self.frame = startFrame;
		break;

	case UIGestureRecognizerStateChanged:
	case UIGestureRecognizerStateEnded:
		newFrame.size.width = startFrame.size.width * recognizer.scale;
		newFrame.size.height = startFrame.size.height * recognizer.scale;
		newFrame.origin.x = startFrame.origin.x - (newFrame.size.width - startFrame.size.width) * 0.5f;
		newFrame.origin.y = startFrame.origin.y - (newFrame.size.height - startFrame.size.height) * 0.5f;
		if ([self rectFitsToSuperview:newFrame])
		{
			self.frame = newFrame;
			if ([self.superview respondsToSelector:@selector(updateExclusionPaths)])
				[(id)self.superview updateExclusionPaths];
		}
		break;
	}
}

@end
