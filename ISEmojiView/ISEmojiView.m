//
//  ISEmojiView.m
//  ISEmojiViewSample
//
//  Created by isaced on 14/12/25.
//  Copyright (c) 2014年 isaced. All rights reserved.
//

#import "ISEmojiView.h"

static const CGFloat EmojiWidth = 43;
static const CGFloat EmojiHeight = 43;
static const CGFloat EmojiFontSize = 32;

@interface ISEmojiView()<UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *emojis;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation ISEmojiView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.90 alpha:1.0f];
        // init emojis
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ISEmojiList" ofType:@"plist"];
        self.emojis = [NSArray arrayWithContentsOfFile:plistPath];
        
        //init frames
        CGFloat pageControlFrameHeight = 25;
        CGFloat buttonBackspaceFrameWidth = 55;
        CGRect emojiFrame = CGRectMake(0,
                                       pageControlFrameHeight,
                                       frame.size.width - buttonBackspaceFrameWidth,
                                       frame.size.height - pageControlFrameHeight);
        
        CGRect pageControlFrame = CGRectMake(0,
                                             0,
                                             frame.size.width,
                                             pageControlFrameHeight);
        
        CGRect backButtonFrame = CGRectMake(frame.size.width - buttonBackspaceFrameWidth,
                                            pageControlFrameHeight,
                                            buttonBackspaceFrameWidth,
                                            frame.size.height - pageControlFrameHeight);
        
        //
        NSInteger rowNum = (CGRectGetHeight(emojiFrame) / EmojiHeight);
        NSInteger colNum = (CGRectGetWidth(emojiFrame) / EmojiWidth);
        NSInteger numOfPage = ceil((float)[self.emojis count] / (float)(rowNum * colNum));
        
        // init scrollview
        self.scrollView = [[UIScrollView alloc] initWithFrame:emojiFrame];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.delegate = self;
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(emojiFrame) * numOfPage,
                                                 CGRectGetHeight(emojiFrame));
        [self addSubview:self.scrollView];
        
        // add emojis
        
        NSInteger row = 0;
        NSInteger column = 0;
        NSInteger page = 0;
        
        NSInteger emojiPointer = 0;
        for (int i = 0; i < [self.emojis count]  - 1; i++) {
            
            // Pagination
            if (i % (rowNum * colNum) == 0) {
                page ++;    // Increase the number of pages
                row = 0;    // the number of lines is 0
                column = 0; // the number of columns is 0
            }else if (i % colNum == 0) {
                // NewLine
                row += 1;   // Increase the number of lines
                column = 0; // The number of columns is 0
            }
            
            CGRect currentRect = CGRectMake(((page-1) * emojiFrame.size.width) + (column * EmojiWidth) + 10,
                                            row * EmojiHeight,
                                            EmojiWidth,
                                            EmojiHeight);
            
            NSString *emoji = self.emojis[emojiPointer++];
                
            // init Emoji Button
            UIButton *emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
            emojiButton.titleLabel.font = [UIFont fontWithName:@"Apple color emoji" size:EmojiFontSize];
            [emojiButton setTitle:emoji forState:UIControlStateNormal];
            [emojiButton addTarget:self action:@selector(emojiButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                
            emojiButton.frame = currentRect;
            [self.scrollView addSubview:emojiButton];
            
            column++;
        }
        
        // add PageControl
        self.pageControl = [[UIPageControl alloc] init];
        self.pageControl.hidesForSinglePage = YES;
        self.pageControl.currentPage = 0;
        self.pageControl.backgroundColor = [UIColor clearColor];
        self.pageControl.numberOfPages = numOfPage;
        self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        self.pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
        CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:numOfPage];
        self.pageControl.center = CGPointMake(pageControlFrame.size.width/2.0f,
                                              pageControlFrame.size.height/2.0f + 3);
        [self.pageControl addTarget:self action:@selector(pageControlTouched:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.pageControl];
        
        [self initBackspaceButtonWithFrame:backButtonFrame];
    }
    return self;
}

- (void)initBackspaceButtonWithFrame:(CGRect)backSpaceFrame {
    
    ISDeleteButton *deleteButton = [ISDeleteButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setImage:[UIImage imageNamed:@"backspace"]
                  forState:UIControlStateNormal];
    
    [deleteButton addTarget:self
                     action:@selector(deleteButtonPressed:)
           forControlEvents:UIControlEventTouchUpInside];
    deleteButton.frame = CGRectMake(backSpaceFrame.origin.x,
                                    backSpaceFrame.origin.y - 25,
                                    backSpaceFrame.size.width,
                                    deleteButton.imageView.image.size.height + 25 * 2);
    deleteButton.tintColor = [UIColor blackColor];
    [self addSubview:deleteButton];

}

#pragma mark - Service methods

- (void)pageControlTouched:(UIPageControl *)sender {
    CGRect bounds = self.scrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * sender.currentPage;
    [self.scrollView scrollRectToVisible:bounds animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
    NSInteger newPageNumber = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (self.pageControl.currentPage == newPageNumber) {
        return;
    }
    self.pageControl.currentPage = newPageNumber;
}

- (void)emojiButtonPressed:(UIButton *)button {
    
    // Add a simple scale animation
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.byValue = @0.3;
    animation.duration = 0.1;
    animation.autoreverses = YES;
    [button.layer addAnimation:animation forKey:nil];
    
    // Callback
    if ([self.delegate respondsToSelector:@selector(emojiView:didSelectEmoji:)]) {
        NSString * emojiString = button.titleLabel.text;
        [self.delegate emojiView:self didSelectEmoji:emojiString];
    }
}

- (void)deleteButtonPressed:(UIButton *)button{
    // Add a simple scale animation
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.toValue = @0.9;
    animation.duration = 0.1;
    animation.autoreverses = YES;
    [button.layer addAnimation:animation forKey:nil];
    
    // Callback
    if ([self.delegate respondsToSelector:@selector(emojiView:didPressDeleteButton:)]) {
        [self.delegate emojiView:self didPressDeleteButton:button];
    }
}

@end

@implementation ISDeleteButton


@end
