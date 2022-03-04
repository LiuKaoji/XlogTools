//
//  XLogViewer.m
//  XlogPlugin
//
//  Created by kaoji on 2020/5/6.
//  Copyright © 2020 kaoji. All rights reserved.
//

#import "XLogViewer.h"
#import "NSMutableAttributedString+Format.h"
#import "XLogFloatBtn.h"
#import "ICTextView.h"
#import "LavWordsView.h"


@interface XLogViewer ()
@property(nonatomic,copy)NSString *logPath;
@property(nonatomic,strong)ICTextView *textView;
@property (nonatomic, strong) UISearchBar *searchBar;//搜索框
@property (nonatomic, strong) UILabel *countLabel;//光标位置和搜索结果数量
@property (nonatomic, strong) UIToolbar *toolBar;//
@property (nonatomic, strong) NSMutableAttributedString *logAtt;//日志富文本
@property (nonatomic, assign) XLOG_TYPE logType;//日志富文本
@property (nonatomic, assign) CGFloat keyBoardHeight;//键盘a高度
@end

@implementation XLogViewer

@synthesize textView = _textView;
@synthesize toolBar = _toolBar;

-(void)setXlogItemPath:(NSString *)url{
    _logPath = url;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    UIButton *button = [[UIApplication sharedApplication].keyWindow viewWithTag:FloatBtnTag];
    button.hidden = YES;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    UIButton *button = [[UIApplication sharedApplication].keyWindow viewWithTag:FloatBtnTag];
    button.hidden = NO;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    
    NSURL *fileURL = [NSURL fileURLWithPath:_logPath];
    _logAtt = [[NSMutableAttributedString alloc] initWithURL:fileURL options:@{} documentAttributes:nil error:nil];
    BOOL isTimLog = [_logAtt.string containsString:@"TIM:"];
    _logType = isTimLog ?XLOG_TYPE_IM:XLOG_TYPE_LAV;
    isTimLog ?[self formatIMLogAndPreView]:[self formatLAVLogAndPreView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAction:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAction:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)setupUI{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.view.backgroundColor = [UIColor  blackColor];
    
    //与导航栏宽高一致
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, TOP_LAYOUT_GUIDE)];
    topView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    [self.view addSubview:topView];
    
    //关闭按钮
    UIImage *backImage = [UIImage imageWithContentsOfFile: [XLOG_RES stringByAppendingPathComponent:@"close.png"]];
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(8, TOP_LAYOUT_GUIDE - 41, 30, 30)];
    [closeBtn setImage:backImage forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(onClickBack) forControlEvents: UIControlEventTouchUpInside];
    [topView addSubview:closeBtn];
    
    //词汇按钮
    UIImage *wordsImage = [UIImage imageWithContentsOfFile: [XLOG_RES stringByAppendingPathComponent:@"words.png"]];
    UIButton *wordsBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 48, TOP_LAYOUT_GUIDE - 41, 30, 30)];
    [wordsBtn setImage:wordsImage forState:UIControlStateNormal];
    [wordsBtn addTarget:self action:@selector(onClickWords) forControlEvents: UIControlEventTouchUpInside];
    [topView addSubview:wordsBtn];
   
    //显示日志内容
    _textView = [[ICTextView alloc] init];
    _textView.backgroundColor = [UIColor  colorWithWhite:0.1 alpha:0.2];
    _textView.frame = CGRectMake(0, topView.frame.size.height, SCREENWIDTH, SCREENHEIGHT - topView.frame.size.height - (isBangsDevice?34:0));
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _textView.textColor = [UIColor whiteColor];
    _textView.editable = NO;
    _textView.circularSearch = YES;
    _textView.searchOptions = NSRegularExpressionCaseInsensitive;
    _textView.primaryHighlightColor = [UIColor colorWithWhite:1.0 alpha:.4];
    _textView.secondaryHighlightColor = [UIColor colorWithWhite:1.0 alpha:.8];
    _textView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    _textView.showsHorizontalScrollIndicator = YES;
    [self.view addSubview:_textView];
    
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(60, TOP_LAYOUT_GUIDE - 40, SCREENWIDTH - 120, 30)];
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;//去除他的边框线
    _searchBar.delegate = self;
    [topView addSubview:_searchBar];
    if ([_searchBar respondsToSelector:@selector(setInputAccessoryView:)])
    {
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        
        UIBarButtonItem *prevButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"上一个"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(searchPreviousMatch)];
        
        UIBarButtonItem *nextButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下一个"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(searchNextMatch)];
        
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UILabel *countLabel = [[UILabel alloc] init];
        countLabel.textAlignment = NSTextAlignmentRight;
        countLabel.textColor = [UIColor grayColor];
        
        UIBarButtonItem *counter = [[UIBarButtonItem alloc] initWithCustomView:countLabel];
        
        toolBar.items = [[NSArray alloc] initWithObjects:prevButtonItem, nextButtonItem, spacer, counter, nil];
        
        [(id)_searchBar setInputAccessoryView:toolBar];
        
        self.toolBar = toolBar;
        self.countLabel = countLabel;
        
    }

}

-(void)onClickBack{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)onClickWords{
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf = self;
    LavWordsView *wordsView = [[LavWordsView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.frame LogType:self.logType];
    [wordsView show];
    wordsView.wordsCallBack = ^(NSString * _Nonnull searchWord) {
        weakSelf.searchBar.text = searchWord;
        [weakSelf searchNextMatch];
    };
}


-(void)formatLAVLogAndPreView{
    
    //[_logAtt applyFont:[UIFont systemFontOfSize:30] forRange:[_logAtt.string rangeOfString:_logAtt.string]];
    [_logAtt applyColor:[UIColor whiteColor] forSubString:_logAtt.string];
    [_logAtt applyColor:[UIColor systemPinkColor] forSubString:@"~~~~~ begin of mmap ~~~~~"];
    [_logAtt applyColor:[UIColor systemPinkColor] forSubString:@"~~~~~ end of mmap ~~~~~"];
    
    NSMutableArray *exMatch_I = [_logAtt calculateSubStringCount:_logAtt.string str:@"[I]"];
    
    
    NSMutableAttributedString *breakChar = [[NSMutableAttributedString alloc] initWithString:@"\n"];
    if(exMatch_I.count){
        for (NSInteger i = 0; i<exMatch_I.count -1; i++) {
            [_logAtt insertAttributedString:breakChar atIndex:[exMatch_I[i] integerValue] + i];
        }
    }
    
    
    
    NSMutableArray *exMatch_E = [_logAtt calculateSubStringCount:_logAtt.string str:@"[E]"];
    if(exMatch_E.count){
        for (NSInteger i = 0; i<exMatch_E.count -1; i++) {
            [_logAtt insertAttributedString:breakChar atIndex:[exMatch_E[i] integerValue] + i];
        }
    }
    
    
    //第二次高亮时间颜色,需要重新计算 加了空格位置变了
    exMatch_I = [_logAtt calculateSubStringCount:_logAtt.string str:@"[I]"];
    exMatch_E = [_logAtt calculateSubStringCount:_logAtt.string str:@"[E]"];
    
    UIColor *formatColor  = [UIColor greenColor];
    
    if(exMatch_I.count){
        for (NSNumber * location in exMatch_I){
            NSRange range = NSMakeRange([location integerValue], 3);
            [_logAtt applyColor:formatColor forRange:NSMakeRange(range.location, 54)];
        }
        
    }
    
    if(exMatch_E.count){
        for (NSNumber * location in exMatch_E){
            NSRange range = NSMakeRange([location integerValue], 3);
            [_logAtt applyColor:formatColor forRange:NSMakeRange(range.location, 54)];
        }
    }
    
    
    
    _textView.attributedText = _logAtt;
}

-(void)formatIMLogAndPreView{
    
    
    [_logAtt applyColor:[UIColor whiteColor] forSubString:_logAtt.string];
    [_logAtt applyColor:[UIColor systemPinkColor] forSubString:@"~~~~~ begin of mmap ~~~~~"];
    [_logAtt applyColor:[UIColor systemPinkColor] forSubString:@"~~~~~ end of mmap ~~~~~"];
    
    NSMutableArray *exMatch_I = [_logAtt calculateSubStringCount:_logAtt.string str:@"TIM:"];
    
    NSMutableAttributedString *breakChar = [[NSMutableAttributedString alloc] initWithString:@"\n"];
    
    for (NSInteger i = 0; i<exMatch_I.count -1; i++) {
        [_logAtt insertAttributedString:breakChar atIndex:[exMatch_I[i] integerValue] + i];
    }
    
    //第二次高亮时间颜色
    exMatch_I = [_logAtt calculateSubStringCount:_logAtt.string str:@"TIM:"];

    UIColor *formatColor  = [UIColor greenColor];
    
    for (NSNumber * location in exMatch_I){
        NSRange range = NSMakeRange([location integerValue], 3);
        [_logAtt applyColor:formatColor forRange:NSMakeRange(range.location, 53)];
    }
    _textView.attributedText = _logAtt;
}

- (void)viewDidLayoutSubviews
{
    CGRect viewBounds = self.view.bounds;
    
    CGRect toolBarFrame = viewBounds;
    toolBarFrame.size.height = 34.0f;
    self.toolBar.frame = toolBarFrame;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    _Pragma("unused(searchBar, searchText)")
    [self searchNextMatch];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    _Pragma("unused(searchBar)")
    [self.textView becomeFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    _Pragma("unused(searchBar)")
    [self searchNextMatch];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = nil;
    [self.textView resetSearch];
    [self updateCountLabel];
}

#pragma mark - ICTextView

- (void)searchNextMatch
{
    [self searchMatchInDirection:ICTextViewSearchDirectionForward];
}

- (void)searchPreviousMatch
{
    [self searchMatchInDirection:ICTextViewSearchDirectionBackward];
}

- (void)searchMatchInDirection:(ICTextViewSearchDirection)direction
{
    NSString *searchString = self.searchBar.text;
    
    if (searchString.length)
        [self.textView scrollToString:searchString searchDirection:direction];
    else
        [self.textView resetSearch];
    
    [self updateCountLabel];
}

- (void)updateCountLabel
{
    ICTextView *textView = self.textView;
    UILabel *countLabel = self.countLabel;
    
    NSUInteger numberOfMatches = textView.numberOfMatches;
    countLabel.text = numberOfMatches ? [NSString stringWithFormat:@"%lu/%lu", (unsigned long)textView.indexOfFoundString + 1, (unsigned long)numberOfMatches] : @"0/0";
    [countLabel sizeToFit];
}

#pragma mark - Keyboard

- (void)keyboardAction:(NSNotification *)notification
{
    UIEdgeInsets newInsets = UIEdgeInsetsZero;
    newInsets.top = self.searchBar.frame.size.height;
    
    if (notification)
    {
        CGRect keyboardFrame;
        [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
        keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
        newInsets.bottom = self.view.frame.size.height - keyboardFrame.origin.y;
    }
    ICTextView *textView = self.textView;
    textView.contentInset = newInsets;
    textView.scrollIndicatorInsets = newInsets;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
@end
