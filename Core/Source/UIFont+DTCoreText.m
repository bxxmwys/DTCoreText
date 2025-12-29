//
//  UIFont+DTCoreText.m
//  DTCoreText
//
//  Created by Oliver Drobnik on 11.12.12.
//  Copyright (c) 2012 Drobnik.com. All rights reserved.
//

#import "UIFont+DTCoreText.h"

#if TARGET_OS_IPHONE

@implementation UIFont (DTCoreText)

+ (UIFont *)fontWithCTFont:(CTFontRef)ctFont
{
    if (!ctFont) {
        return nil;
    }

    CGFloat fontSize = CTFontGetSize(ctFont);
    UIFont *font = nil;

    // 1) 正确路径：优先使用 PostScript 名
    NSString *postScriptName = (__bridge_transfer NSString *)CTFontCopyName(ctFont, kCTFontPostScriptNameKey);
    if (postScriptName.length > 0) {
        font = [UIFont fontWithName:postScriptName size:fontSize];
    }

    // 2) 兼容：若上面失败，再尝试 FullName（某些系统字体/老实现可能靠这个“碰巧”成功）
    if (!font) {
        NSString *fullName = (__bridge_transfer NSString *)CTFontCopyName(ctFont, kCTFontFullNameKey);
        if (fullName.length > 0) {
            font = [UIFont fontWithName:fullName size:fontSize];
        }
    }

    // 3) 兜底：用 CTFontDescriptor 的 attributes 生成 UIFontDescriptor
    if (!font) {
        CTFontDescriptorRef ctDesc = CTFontCopyFontDescriptor(ctFont);
        if (ctDesc) {
            NSDictionary *attrs = (__bridge_transfer NSDictionary *)CTFontDescriptorCopyAttributes(ctDesc);
            CFRelease(ctDesc);

            if (attrs.count > 0) {
                UIFontDescriptor *uiDesc = [UIFontDescriptor fontDescriptorWithFontAttributes:attrs];
                if (uiDesc) {
                    font = [UIFont fontWithDescriptor:uiDesc size:fontSize];
                }
            }
        }
    }

    // 4) 最终兜底：保证永不返回 nil，避免外部字典崩溃
    if (!font) {
        font = [UIFont systemFontOfSize:fontSize];
    }

    return font;
}

@end

#endif
