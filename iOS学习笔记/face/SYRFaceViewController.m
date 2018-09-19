//
//  SYRFaceViewController.m
//  iOS学习笔记
//
//  Created by 单怡然 on 2018/8/24.
//  Copyright © 2018年 单怡然. All rights reserved.
//

#import "SYRFaceViewController.h"
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

@interface SYRFaceViewController ()
{
    double add;//定时器的增速
}
//创建全局属性
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, weak) UILabel *cLabel;
@end

@implementation SYRFaceViewController
{
    //捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
    AVCaptureDevice *device;
    //AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
    AVCaptureDeviceInput *captureInput;
    //session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
    AVCaptureSession *captureSession;
    //图像预览层，实时显示捕获的图像
    AVCaptureVideoPreviewLayer *captureLayer;
    //照片输出流,输出图片
    AVCaptureStillImageOutput *iStillImageOutput;
    
    UIImageView *outputImageView;
    //面部图片保存路径
    NSString *imageFilePath;
}
- (void)viewDidLoad {
    //设置背景色
    UIColor *backColor= [UIColor colorWithRed:44/255.0 green:44/255.0 blue:44/255.0 alpha:1];
    [self.view setBackgroundColor:backColor];
    NSLog(@"-->>>>>%@",self.view);
    //添加摄像设备
    [self setupCaptureSession];
    //添加进度条
    [self creatCircle];
    [self circleStart];
    //实时显示摄像头内容
    captureLayer = [AVCaptureVideoPreviewLayer layerWithSession: captureSession];
    captureLayer.frame = CGRectMake(40, START_POSITION+100, ScreenWidth-80, ScreenWidth-80);
    captureLayer.cornerRadius = captureLayer.frame.size.width/2.0;
    captureLayer.masksToBounds = YES;
    captureLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer: captureLayer];
    [super viewDidLoad];
}


#pragma mark-创建并配置一个摄像会话，并启动。
- (void)setupCaptureSession
{
    NSError *error = nil;
    //创建会话
    captureSession = [[AVCaptureSession alloc] init];
    //设置视频质量   高等
    captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    //初始化设备，这里使用前置的摄像头
    device = [self cameraWithPosition:AVCaptureDevicePositionFront];
    //初始化输入设备
    captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //将视频输出流添加到会话
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc]init];
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    //将视频输入流添加到会话
    captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                         error:&error];
    [captureSession addOutput:captureOutput];
    if (!captureInput) {
        //处理错误
        NSLog(@"初始化设备发生错误");
    }
    [captureSession addInput:captureInput];
    
    //设置FPS
    //captureOutput.minFrameDuration = CMTimeMake(1, 60);
    CMTime frameDuration = CMTimeMake(1, 60);
    NSArray *supportedFrameRateRanges = [device.activeFormat videoSupportedFrameRateRanges];
    BOOL frameRateSupported = NO;
    for (AVFrameRateRange *range in supportedFrameRateRanges) {
        if (CMTIME_COMPARE_INLINE(frameDuration, >=, range.minFrameDuration) &&
            CMTIME_COMPARE_INLINE(frameDuration, <=, range.maxFrameDuration)) {
            frameRateSupported = YES;
        }
    }
    if (frameRateSupported && [device lockForConfiguration:&error]) {
        [device setActiveVideoMaxFrameDuration:frameDuration];
        [device setActiveVideoMinFrameDuration:frameDuration];
        [device unlockForConfiguration];
    }
    //配置输出流output
    dispatch_queue_t queue;
    queue = dispatch_queue_create("cameraQueue", NULL);
    [captureOutput setSampleBufferDelegate:self queue:queue];
    //指定像素格式
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [captureOutput setVideoSettings:videoSettings];
    //启动会话
    [captureSession startRunning];
}

//第二步：实现AVCaptureVideoDataOutputSampleBufferDelegate协议方法
//当采样数据被写入缓冲区时调用
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    //抽取采样数据，合成UIImage对象
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    //image = [self rotateImage:image withOrientation:UIImageOrientationRight];
    [outputImageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
    //对每一帧图片进行人脸识别,延时2秒执行
    [NSThread sleepForTimeInterval:2.0];
    [self facedetect:image];
}

//抽取采样数据，合成UIImage对象
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // 释放context和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // 用Quartz image创建一个UIImage对象image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // 释放Quartz image对象
    CGImageRelease(quartzImage);
    //    UIImage *finalImage = [self rotateImage:image withOrientation:UIImageOrientationRight];
    //    return (finalImage);
    return (image);
}

#pragma mark-原生面部识别
//IOS原生面部识别
- (void)facedetect :(UIImage *)image{
    
    NSDictionary *imageOptions =  [NSDictionary dictionaryWithObject:@(5) forKey:CIDetectorImageOrientation];
    CIImage *personciImage = [CIImage imageWithCGImage:image.CGImage];
    NSDictionary *opts = [NSDictionary dictionaryWithObject:
                          CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    CIDetector *faceDetector=[CIDetector detectorOfType:CIDetectorTypeFace context:nil options:opts];
    NSArray *features = [faceDetector featuresInImage:personciImage options:imageOptions];
    
    if (features.count > 0) {
        //关闭摄像头会话
        //[captureSession stopRunning];
        NSLog(@"测到了 %lu 张脸",(unsigned long)features.count);
        [self beginDetectorFacewithImage:image];
        //保存图片到相册
        [self jpgToPng:image];
        //NSLog(@"output,mdata:%@",image);
    } else {
        //未检测到人脸
    }
}

#pragma mark -人脸标注
- (void)beginDetectorFacewithImage:(UIImage *)image
{
    //1 将UIImage转换成CIImage
    CIImage* ciimage = [CIImage imageWithCGImage:image.CGImage];
    //创建图形上下文
    CIContext * context = [CIContext contextWithOptions:nil];
    //缩小图片，默认照片的图片像素很高，需要将图片的大小缩小为我们现实的ImageView的大小，否则会出现识别五官过大的情况
//    float factor = self.view.bounds.size.width/image.size.width;
//    ciimage = [ciimage imageByApplyingTransform:CGAffineTransformMakeScale(factor, factor)];
    
    //2.设置人脸识别精度CIDetectorAccuracyHigh
//    NSDictionary* opts = [NSDictionary dictionaryWithObject:
//                          CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    //人脸追踪设置CIDetectorTracking
    NSDictionary* opts = [NSDictionary dictionaryWithObject:
                          CIDetectorTracking forKey:CIDetectorAccuracy];
    //3.创建人脸探测器
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:context options:opts];
    //4.获取人脸识别数据
    //NSArray* features = [detector featuresInImage:ciimage];
    //5.分析人脸识别数据
    
    //得到面部数据
    NSArray* features = [detector featuresInImage:ciimage];
    /*
    for (CIFaceFeature *f in features)
    {
        CGRect aRect = f.bounds;
        NSLog(@"%f, %f, %f, %f", aRect.origin.x, aRect.origin.y, aRect.size.width, aRect.size.height);
        
        //眼睛和嘴的位置
        if(f.hasLeftEyePosition) NSLog(@"Left eye %g %g\n", f.leftEyePosition.x, f.leftEyePosition.y);
        if(f.hasRightEyePosition) NSLog(@"Right eye %g %g\n", f.rightEyePosition.x, f.rightEyePosition.y);
        if(f.hasMouthPosition) NSLog(@"Mouth %g %g\n", f.mouthPosition.x, f.mouthPosition.y);
    }
     */
    for (CIFaceFeature *faceFeature in features){
        
        //注意坐标的换算，CIFaceFeature计算出来的坐标的坐标系的Y轴与iOS的Y轴是相反的,需要自行处理
        // 标出脸部
        CGFloat faceWidth = faceFeature.bounds.size.width;
        UIView* faceView = [[UIView alloc] initWithFrame:faceFeature.bounds];
        faceView.frame = CGRectMake(faceView.frame.origin.x, self.view.bounds.size.height-faceView.frame.origin.y - faceView.bounds.size.height, faceView.frame.size.width, faceView.frame.size.height);
        faceView.layer.borderWidth = 1;
        faceView.layer.borderColor = [[UIColor redColor] CGColor];
        [self.view addSubview:faceView];
        [self.view bringSubviewToFront:faceView];
        // 标出左眼
        if(faceFeature.hasLeftEyePosition) {
            UIView* leftEyeView = [[UIView alloc] initWithFrame:
                                   CGRectMake(faceFeature.leftEyePosition.x-faceWidth*0.15,
                                              captureLayer.bounds.size.height-(faceFeature.leftEyePosition.y-faceWidth*0.15)-faceWidth*0.3, faceWidth*0.3, faceWidth*0.3)];
            [leftEyeView setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.3]];
            //            [leftEyeView setCenter:faceFeature.leftEyePosition];
            leftEyeView.layer.cornerRadius = faceWidth*0.15;
            [self.view addSubview:leftEyeView];
            [self.view bringSubviewToFront:leftEyeView];
        }
        // 标出右眼
        if(faceFeature.hasRightEyePosition) {
            UIView* leftEye = [[UIView alloc] initWithFrame:
                               CGRectMake(faceFeature.rightEyePosition.x-faceWidth*0.15,
                                          captureLayer.bounds.size.height-(faceFeature.rightEyePosition.y-faceWidth*0.15)-faceWidth*0.3, faceWidth*0.3, faceWidth*0.3)];
            [leftEye setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.3]];
            leftEye.layer.cornerRadius = faceWidth*0.15;
            [self.view addSubview:leftEye];
            [self.view bringSubviewToFront:leftEye];
        }
        // 标出嘴部
        if(faceFeature.hasMouthPosition) {
            UIView* mouth = [[UIView alloc] initWithFrame:
                             CGRectMake(faceFeature.mouthPosition.x-faceWidth*0.2,
                                        captureLayer.bounds.size.height-(faceFeature.mouthPosition.y-faceWidth*0.2)-faceWidth*0.4, faceWidth*0.4, faceWidth*0.4)];
            [mouth setBackgroundColor:[[UIColor greenColor] colorWithAlphaComponent:0.3]];
            
            mouth.layer.cornerRadius = faceWidth*0.2;
            [self.view addSubview:mouth];
            [self.view bringSubviewToFront:mouth];
        }
        
    }
}

#pragma mark -创建进度条
- (void)creatCircle
{
    //创建出CAShapeLayer
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.frame = CGRectMake(38, START_POSITION+98, ScreenWidth-76, ScreenWidth-76);
    //self.shapeLayer.position = self.view.center;
    self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
    //设置线条的宽度和颜色
    self.shapeLayer.lineWidth = 3.0f;
    UIColor *testColor1= [UIColor colorWithRed:101/255.0 green:236/255.0 blue:211/255.0 alpha:1];
    self.shapeLayer.strokeColor = testColor1.CGColor;
    //设置stroke起始点
    self.shapeLayer.strokeStart = 0;
    self.shapeLayer.strokeEnd = 0;
    add = 0.1;
    //创建出圆形贝塞尔曲线
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, ScreenWidth-76, ScreenWidth-76)];
    //让贝塞尔曲线与CAShapeLayer产生联系
    self.shapeLayer.path = circlePath.CGPath;
    //添加并显示
    [self.view.layer addSublayer:self.shapeLayer];
}

- (void)circleAnimationTypeOne
{
    if (self.shapeLayer.strokeEnd > 1 && self.shapeLayer.strokeStart < 1) {
        self.shapeLayer.strokeStart += add;
    }else if(self.shapeLayer.strokeStart == 0){
        self.shapeLayer.strokeEnd += add;
    }
    
    if (self.shapeLayer.strokeEnd == 0) {
        self.shapeLayer.strokeStart = 0;
    }
    
    if (self.shapeLayer.strokeStart == self.shapeLayer.strokeEnd) {
        self.shapeLayer.strokeEnd = 0;
    }
}

- (void)circleAnimationTypeTwo
{
    CGFloat valueOne = arc4random() % 100 / 100.0f;
    CGFloat valueTwo = arc4random() % 100 / 100.0f;
    
    self.shapeLayer.strokeStart = valueOne < valueTwo ? valueOne : valueTwo;
    self.shapeLayer.strokeEnd = valueTwo > valueOne ? valueTwo : valueOne;
}

- (void)circleStart{
    //用定时器模拟数值输入的情况
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                              target:self
                                            selector:@selector(circleAnimationTypeOne)
                                            userInfo:nil
                                             repeats:YES];
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}

#pragma mark-save image to Photo
//image  jpg格式转PNG
- (void)jpgToPng:(UIImage*)image
{
    NSData * data = UIImagePNGRepresentation(image);
    UIImage * imagePng = [UIImage imageWithData:data];
    // 保存至相册
    UIImageWriteToSavedPhotosAlbum(imagePng, nil, nil, nil);
}

#pragma mark -图片翻转
- (UIImage *)rotateImage:(UIImage *)image withOrientation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation)
    {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    
    return newPic;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
