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
#import "NZTextEditor.h"
#import "NZTextEditorSubview.h"

@implementation NZTextEditor
{
	CGFloat subviewsMargin;
	BOOL destroying;
}

-(void)dealloc
{
	destroying = YES;
	[super dealloc];
}

-(CGFloat)subviewsMargin
{
	return subviewsMargin;
}

-(void)setSubviewsMargin:(CGFloat)value
{
	subviewsMargin = value;
	[self setNeedsLayout];
}

-(CGSize)sizeThatFits:(CGSize)size
{
	size = [super sizeThatFits:size];
	for (UIView * view in self.subviews)
		size.height = MAX(size.height, view.frame.origin.y + view.frame.size.height);
	return size;
}

-(void)didAddSubview:(UIView *)subview
{
	[self updateExclusionPaths];
}

-(void)willRemoveSubview:(UIView *)subview
{
	[self updateExclusionPaths];
}

-(void)updateExclusionPaths
{
	if (destroying)
		return;

	if (self.subviews.count == 0)
	{
		self.textContainer.exclusionPaths = @[];
		return;
	}

	NSMutableArray * subviewsRects = [[[NSMutableArray alloc] initWithCapacity:self.subviews.count] autorelease];
	for (UIView * view in self.subviews)
	{
		if (![view isKindOfClass:[NZTextEditorSubview class]])
			continue;

		[subviewsRects addObject:[UIBezierPath bezierPathWithRect:CGRectMake(
			view.frame.origin.x - subviewsMargin,
			view.frame.origin.y - subviewsMargin,
			view.frame.size.width + 2.0f * subviewsMargin,
			view.frame.size.height + 2.0f * subviewsMargin
		)]];
	}

	self.textContainer.exclusionPaths = subviewsRects;
}

-(BOOL)touchesShouldCancelInContentView:(UIView *)view
{
	return NO;
}

@end
