//
//  LPWavyIndicator.m
//  aha
//
//  Created by Jack on 2017/11/10.
//  Copyright © 2017年 Jack. All rights reserved.
//

#import "LPWavyProgressIndicator.h"


@interface LPWavyProgressIndicator ()
{
    CGFloat y; // 当前高度
    CGFloat w; // 最小正周期T=2π/|w|
    CGFloat A; // 最大振幅
}

@property (nonatomic,strong) CAShapeLayer *sinLayer1;
@property (nonatomic,strong) CAShapeLayer *sinLayer2;
@property (nonatomic,strong) CAShapeLayer *circLayer;
@property (nonatomic,strong) CATextLayer *textLayer;
@property (nonatomic,strong) CAShapeLayer *maskLayer;
@property (nonatomic,strong) CADisplayLink *displayLink;
@property (nonatomic,strong) UIFont *font;

@end

static const float ratio = 0.03; // 保持最大振幅和波动速度在不同大小View中比例相同
static const float font_ratio = 0.18;
static const int light_water_color = 0xA6DEF7;
static const int dark_water_color = 0x3EA4C7;

@implementation LPWavyProgressIndicator

- (void)setupVar {
    A = [self getDefaultA];
    w = (2 * M_PI) / (([self width]) / 1.5);
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupVar];
        [self displayLink];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupVar];
        [self displayLink];
    }
    return self;
}

#pragma mark - Utils

+ (UIColor *)colorWithHEX:(NSInteger)hex alpha:(float)alpha{
    return [UIColor colorWithRed:((hex & 0xff0000) >> 16) / 255.0 green:((hex & 0xff00) >> 8) / 255.0 blue:(hex & 0xff) / 255.0 alpha:alpha];
}

+ (CGSize)sizeOfString:(NSString *)string font:(UIFont *)font{
    NSDictionary *attribute = @{NSFontAttributeName: font};
    
    CGSize resSize = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                        options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                     attributes:attribute
                                        context:nil].size;
    
    return resSize;
}

#pragma mark - Getter

- (CGFloat)minSize {
    return MIN(self.bounds.size.width, self.bounds.size.height);
}

- (CGFloat)width {
    return CGRectGetWidth(self.bounds);
}

- (CGFloat)height {
    return CGRectGetHeight(self.bounds);
}

- (CGFloat)getY {
    y = [self height] * 0.5 + [self minSize] * 0.5 - [self minSize] * self.progress;
    return y;
}

- (CGPoint)circleCenter {

    CGFloat x = [self width] * 0.5;
    CGFloat y = [self height] * 0.5;
    return CGPointMake(x, y);
}

- (CGFloat)getX1 {
    CGFloat r = [self minSize] * 0.5;
    CGFloat X = sqrt(pow(r,2) - pow(-[self getY] + ([self height] * 0.5),2));
    CGFloat x1 = [self width] * 0.5 - X;
    return x1;
}

- (CGFloat)getX2 {
    CGFloat r = [self minSize] * 0.5;
    CGFloat X = sqrt(pow(r,2) - pow(-[self getY] + ([self height] * 0.5),2));
    CGFloat x2 = [self width] * 0.5 + X;
    return x2;
}

- (CGFloat)getDefaultA {
    return ratio * [self minSize];
}

#pragma mark - Setter

- (void)setProgress:(float)progress {
    if (progress < 0.0f) {
        progress = fabsf(progress);
    }
    if (progress > 1.0f) {
        progress = 1.0f;
    }
    
    _progress = progress;
    NSString *progress_str = [NSString stringWithFormat:@"%.1f%%",progress * 100];
    self.textLayer.string = progress_str;
    [self updateTextlayerFrame];
    
    if (progress == 0.0f || progress == 1.0f) {
        A = 0;
    } else if (progress > 0.9 || progress < 0.1) {
        A = 2;
    } else {
        A = [self getDefaultA];
    }
    
    [self updateProgress];
}

#pragma mark - Lazy load

- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateDisplay:)];
        if ([_displayLink respondsToSelector:@selector(setPreferredFramesPerSecond:)]) {
            _displayLink.preferredFramesPerSecond = 10;
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            _displayLink.frameInterval = 10;
#pragma clang diagnostic pop
        }
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:UITrackingRunLoopMode];
    }
    return _displayLink;
}

- (CATextLayer *)textLayer {
    if (!_textLayer) {
        _textLayer = [[CATextLayer alloc] init];
        _textLayer.contentsScale = [UIScreen mainScreen].scale;
        _textLayer.foregroundColor = [UIColor blackColor].CGColor;
        _textLayer.alignmentMode = kCAAlignmentCenter;
        
        UIFont *font = [self font];
        CGFontRef fontRef = CGFontCreateWithFontName((__bridge CFStringRef)font.fontName);
        _textLayer.font = fontRef;
        _textLayer.fontSize = font.pointSize;
        CGFontRelease(fontRef);
    }
    return _textLayer;
}

- (CAShapeLayer *)sinLayer1 {
    if (!_sinLayer1) {
        _sinLayer1 = [CAShapeLayer layer];
        _sinLayer1.lineWidth = 0.2f;
        _sinLayer1.fillColor = [self.class colorWithHEX:dark_water_color alpha:0.5].CGColor;
        _sinLayer1.strokeColor = [self.class colorWithHEX:dark_water_color alpha:0.5].CGColor;
    }
    return _sinLayer1;
}

- (CAShapeLayer *)sinLayer2 {
    if (!_sinLayer2) {
        _sinLayer2 = [CAShapeLayer layer];
        _sinLayer2.lineWidth = 0.2f;
        _sinLayer2.fillColor = [self.class colorWithHEX:light_water_color alpha:0.8].CGColor;
        _sinLayer2.strokeColor = [self.class colorWithHEX:light_water_color alpha:0.8].CGColor;
    }
    return _sinLayer2;
}

- (CAShapeLayer *)circLayer {
    if (!_circLayer) {
        _circLayer = [CAShapeLayer layer];
        _circLayer.lineWidth = 1.f;
        _circLayer.fillColor = [UIColor clearColor].CGColor;
        _circLayer.strokeColor = [self.class colorWithHEX:light_water_color alpha:1].CGColor;
    }
    return _circLayer;
}

- (CAShapeLayer *)maskLayer {
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.lineWidth = .5f;
        _maskLayer.fillColor = [UIColor blackColor].CGColor; // 不显示，表示实心区域
        _maskLayer.strokeColor = [self.class colorWithHEX:light_water_color alpha:1].CGColor;
    }
    return _maskLayer;
}

- (UIFont *)font {
    if (!_font) {
        _font = [UIFont systemFontOfSize:font_ratio * [self minSize]];
    }
    return _font;
}

#pragma mark - Private

- (void)updateTextlayerFrame {
    CGSize size = [self.class sizeOfString:self.textLayer.string font:self.font];
    size.width += 1.0;
    CGFloat x = ([self width] - size.width) * 0.5;
    CGFloat y = ([self height] - size.height) * 0.5;
    self.textLayer.frame = CGRectMake(x, y, size.width, size.height);
}

- (void)updateSinLayer1 {
    // f(x)=Asin（ωx+ψ）最小正周期T=2π/|ω|
    
    /**
     *         1.5Pi
     *    pi            0
     *         0.5Pi
     */
    
    CGFloat y = [self getY];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 0, y);
    CGFloat line_y = y;
    //正弦曲线公式为： y=Asin(ωx+φ)+k;
    for (float x = 0.0f; x <= [self width] ; x++) {
        line_y = A * sin(w * x + deta) + y;
        CGPathAddLineToPoint(path, nil, x, line_y);
    }
    
    CGPathAddLineToPoint(path, nil, [self width], self.bounds.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.bounds.size.height);
    CGPathCloseSubpath(path);
    self.sinLayer1.path = path;
    CGPathRelease(path);
}

- (void)updateSinLayer2 {
    CGFloat y = [self getY];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 0, y);
    CGFloat line_y = y;
    //正弦曲线公式为： y=Asin(ωx+φ)+k;
    for (float x = 0.0f; x <= [self width] ; x++) {
        line_y = A * cos(w * x + deta) + y;
        CGPathAddLineToPoint(path, nil, x, line_y);
    }
    
    CGPathAddLineToPoint(path, nil, [self width], self.bounds.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.bounds.size.height);
    CGPathCloseSubpath(path);
    self.sinLayer2.path = path;
    CGPathRelease(path);
}

#pragma mark - Override

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundColor = [UIColor clearColor];
    
    // 1 mask
    self.maskLayer.frame = self.bounds;
    self.maskLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake([self width] * 0.5, [self height] * 0.5)
                                                         radius:0.5 * [self minSize]
                                                     startAngle:0
                                                       endAngle:M_PI * 2.0
                                                      clockwise:YES].CGPath;
    [self.layer setMask:self.maskLayer];
    
    // 2 circle
    self.circLayer.frame = self.bounds;
    self.circLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake([self width] * 0.5, [self height] * 0.5)
                                                     radius:0.5 * [self minSize]
                                                 startAngle:0
                                                   endAngle:M_PI * 2.0
                                                  clockwise:YES].CGPath;
    [self.layer addSublayer:self.circLayer];
    
    // 3  wave
    self.sinLayer2.frame = self.bounds;
    [self.layer addSublayer:self.sinLayer2];
    
    // 4 wave
    self.sinLayer1.frame = self.bounds;
    [self.layer addSublayer:self.sinLayer1];
    
    // 5 Text
    [self updateTextlayerFrame];
    [self.layer addSublayer:self.textLayer];
}

// 控制速度
static float deta = 0;

- (void)updateProgress {
    
    [UIView animateWithDuration:0.3 animations:^{
        [self updateSinLayer1];
        [self updateSinLayer2];
    }];
}

#pragma mark - Action

- (void)updateDisplay:(CADisplayLink *)displayLink {
    
    deta += w * (ratio * [self minSize]);
    [self updateProgress];
}

@end
