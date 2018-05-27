//
//  JRXMLDataParser.m
//  JRPictureDemo
//
//  Created by hqtech on 2018/5/27.
//  Copyright © 2018年 tulip. All rights reserved.
//

#import "JRXMLDataParser.h"

@interface JRXMLDataParser ()<NSXMLParserDelegate>

@property (nonatomic, strong) NSMutableArray<JRPictureModel *> *pictureModels;

// 当前标签的名字(临时存储正在解析的元素名)
@property (strong, nonatomic) NSString *currentTagName;

@end

@implementation JRXMLDataParser

- (NSMutableArray<JRPictureModel *> *)pictureModels {
    if (_pictureModels == nil) {
        _pictureModels = [NSMutableArray array];
    }
    return _pictureModels;
}

- (void)startParse {
    NSURL *url = [NSURL URLWithString:@"https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss"];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    parser.delegate = self;
    [parser parse];
}

// 文档开始时触发
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    NSLog(@"文档开始");
}

// 文档出错时触发
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"%@", parseError);
}

// 遇到一个开始标签时触发
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    
    // 记录正在解析的元素名称
    self.currentTagName = elementName;
    
    if ([elementName isEqualToString:@"item"]) {
        JRPictureModel *model = [[JRPictureModel alloc] init];
        [self.pictureModels addObject:model];
    }else if ([elementName isEqualToString:@"enclosure"]) {
        JRPictureModel *model = [self.pictureModels lastObject];
        model.imgUrl = [attributeDict objectForKey:@"url"];
    }
    
}

// 遇到字符串时候触发，该方法是解析元素文本内容主要场所
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([string isEqualToString:@""]) {
        return;
    }
    JRPictureModel *model = [self.pictureModels lastObject];
    
    if ([self.currentTagName isEqualToString:@"title"] && model) {
        model.title = [model.title stringByAppendingString:string];
    }else if ([self.currentTagName isEqualToString:@"description"] && model) {
        model.content = [model.content stringByAppendingString:string];
    }
    
}

// 遇到结束标签时触发，在该方法中主要是清理刚刚解析完成的元素产生的影响，以便于不影响接下来的解析
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    // 清理刚才解析的元素的名字，以便于记录接下来解析的元素的名字
    self.currentTagName = nil;
}

// 遇到文档结束时触发
- (void)parserDidEndDocument:(NSXMLParser *)parser {
    // 解析完成
    if (self.parseComplete) {
        self.parseComplete(self.pictureModels);
    }
}

@end
