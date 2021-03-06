//
//  ReadCollectionCell.m
//  UICollectionVIewDemo
//
//  Created by HD on 16/7/12.
//  Copyright © 2016年 hongli. All rights reserved.
//

#import "ReadCollectionCell.h"
#import "BookModel.h"

@implementation ReadCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];

        self.imageView = [[UIImageView alloc]init];
        self.imageView.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.imageView];
        self.bookNameLabel = [[UILabel alloc]init];
        self.bookNameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.bookNameLabel];
        self.txtBookName = [[UILabel alloc]init];
        self.txtBookName.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.txtBookName];
        self.txtSign = [[UILabel alloc]init];
        //self.txtSign.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.txtSign];
    }
    
    return self;
}

// 系统api
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat titleHeight = 20;
    
    self.imageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-titleHeight);
    self.bookNameLabel.frame = CGRectMake(self.imageView.frame.origin.x, CGRectGetMaxY(self.imageView.frame), CGRectGetWidth(self.frame), titleHeight);
    self.txtBookName.frame = CGRectMake(self.imageView.frame.origin.x, CGRectGetMaxY(self.imageView.frame)/4, CGRectGetWidth(self.frame), titleHeight);
    self.txtSign.frame = CGRectMake(0, CGRectGetMaxY(self.imageView.frame)-titleHeight, CGRectGetWidth(self.frame), titleHeight);
    

}

// 自定义方法
- (void)configBookCellModel:(BookModel *)model
{
    UIImage *coverimg = nil;
    if(model.bookType == BookTypePDF){
        NSString* fileStr  = [[NSBundle mainBundle] pathForResource:model.bookName ofType:@"pdf"];
        CGPDFDocumentRef pdfDocumentRef = [self pdfRefByFilePath:fileStr];
        coverimg  = [self imageFromPDFWithDocumentRef:pdfDocumentRef];
        [self.txtBookName setHidden:YES];
        [self.txtSign setHidden:YES];
    }else if (model.bookType==BookTypeTXT){
        self.imageView.backgroundColor = [UIColor colorWithRed:50/255.0 green:155/255.0 blue:213/255.0 alpha:1.0];
        self.txtSign.text = @"TXT";
        self.txtBookName.text = model.bookName;
    }else{
        //解压epub文件
        [LSYReadModel getLocalModelWithURL:[[NSBundle mainBundle] URLForResource:model.bookName withExtension:@"epub"]];
        coverimg = [UIImage imageWithContentsOfFile:[[NSUserDefaults standardUserDefaults]stringForKey:model.bookName]];
        if(coverimg==nil){
            self.imageView.backgroundColor = [UIColor colorWithRed:20/255.0 green:155/255.0 blue:213/255.0 alpha:1.0];
            self.txtSign.text = @"EPUB";
            self.txtBookName.text = model.bookName;
        }
    }
    //添加边框
    self.imageView.image = coverimg;
    [self.imageView.layer setBorderColor: [[UIColor blackColor] CGColor]];
    [self.imageView.layer setBorderWidth: 1.0];
    self.bookNameLabel.text = model.bookName;
    
    
    self.txtSign.textColor = [UIColor whiteColor];
//    这里只是说明BookType 用途，按正常的应该是解压epub 格式或者初始化pdf 之后 截图保存本地，然后把对应的封面存到数据，取值的时候直接使用 cover 这个属性
}


// 下面的方法应该放在一个工具类里面
//获取PDF封面
- (UIImage *)imageFromPDFWithDocumentRef:(CGPDFDocumentRef)documentRef {
    CGPDFPageRef pageRef = CGPDFDocumentGetPage(documentRef, 1);
    CGRect pageRect = CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox);
    UIGraphicsBeginImageContext(pageRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, CGRectGetMinX(pageRect),CGRectGetMaxY(pageRect));
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, -(pageRect.origin.x), -(pageRect.origin.y));
    CGContextDrawPDFPage(context, pageRef);
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImage;
}


//获取本地的PDF文件
- (CGPDFDocumentRef)pdfRefByFilePath:(NSString *)aFilePath
{
    CFStringRef path;
    CFURLRef url;
    CGPDFDocumentRef document;
    
    path = CFStringCreateWithCString(NULL, [aFilePath UTF8String], kCFStringEncodingUTF8);
    url = CFURLCreateWithFileSystemPath(NULL, path, kCFURLPOSIXPathStyle, NO);
    document = CGPDFDocumentCreateWithURL(url);
    
    CFRelease(path);
    CFRelease(url);
    
    return document;
}

@end
