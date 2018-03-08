//
//  PDFReaViewController.m
//  GoBangLZ
//
//  Created by k on 2018/2/26.
//  Copyright © 2018年 poor kid. All rights reserved.
//

#import "PDFReaViewController.h"
#import <QuickLook/QuickLook.h>

@interface PDFReaViewController ()<QLPreviewControllerDataSource>
@property (nonatomic,strong) NSURL *pdfURL;
@end

@implementation PDFReaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUIconfig];
}
- (void)setUIconfig
{
    self.title = @"PDf阅读";
    
    [self setQlVC];
    
}
- (void)setQlVC
{
    NSURL *pdfURl = [NSURL URLWithString:@"http://m.wiseisland.cn:3000/ms/ebook/eread?id=10211&oauth_token=e9634734c251a3f49d63a6bce6a9ab2a&oauth_token_secret=1bf4ecf590213be74e0ec58e4d628ec6"];
    self.pdfURL = pdfURl;
    //    if([QLPreviewController canPreviewItem:(id<QLPreviewItem>)pdfURl])
    //    {
    NSLog(@"%s ----> %@",__func__,pdfURl);
    QLPreviewController *qlVC = [[QLPreviewController alloc] init];
    qlVC.view.frame = self.view.bounds;
    qlVC.dataSource = self;
    qlVC.navigationController.navigationBar.userInteractionEnabled = YES;
    //        [self presentViewController:qlVC animated:YES completion:nil];
    [qlVC refreshCurrentPreviewItem];
    [self.view addSubview:qlVC.view];
    //    }
}
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}
- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return self.pdfURL;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
