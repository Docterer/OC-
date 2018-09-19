//
//  SpeakToTxtViewController.m
//  iOS学习笔记
//
//  Created by 单怡然 on 2018/7/23.
//  Copyright © 2018年 单怡然. All rights reserved.
//

#import "SpeakToTxtViewController.h"
#import <Speech/Speech.h>

@interface SpeakToTxtViewController ()<SFSpeechRecognizerDelegate,SFSpeechRecognitionTaskDelegate>
@property (weak, nonatomic) UIButton *recordingBtn;
@property (weak, nonatomic) UILabel *titleLab;
@property (nonatomic ,strong) UILabel *recognizerLabel;
@property(nonatomic,strong)SFSpeechRecognizer * recognizer ;

@property(nonatomic, assign) BOOL touchUpFlag;
@property(nonatomic, strong) NSTimer *longPressTimer;
@property(nonatomic, assign) BOOL longPressFlag;


//语音识别功能
@property(nonatomic,strong)SFSpeechAudioBufferRecognitionRequest * recognitionRequest ;
@property(nonatomic,strong)SFSpeechRecognitionTask * recognitionTask ;
@property(nonatomic,strong)AVAudioEngine * audioEngine ;

@end

@implementation SpeakToTxtViewController

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        
        [self prefersStatusBarHidden];
        
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        
    }
    
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self selfSetting];
    [self addbutton];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addbutton
{
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(ScreenWidth/2-35, ScreenHeight-134, 70, 70);
    button.layer.cornerRadius = button.frame.size.width/2;
    [button setBackgroundColor:[UIColor grayColor]];
    //[button setBackgroundImage:[UIImage imageNamed:@"login-del"] forState:UIControlStateNormal];
    
//    [button addTarget:self action:@selector(offsetButtonTouchBegin:)forControlEvents:UIControlEventTouchDown];
//
//    [button addTarget:self action:@selector(offsetButtonTouchEnd:)forControlEvents:UIControlEventTouchUpInside];
    
    [button addTarget:self action:@selector(offsetButtonTouchEnd:)forControlEvents:UIControlEventTouchUpOutside];
    

    //button点击事件
    [button addTarget:self action:@selector(BtnClick:) forControlEvents:UIControlEventTouchUpInside];
    //button长按事件
//    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(btnLong:)];
//    longPress.minimumPressDuration = 0.5;
//    [button addGestureRecognizer:longPress];
    
    _recordingBtn = button;
    [button setTitle:@"开始" forState:UIControlStateNormal];
    [self.view addSubview:_recordingBtn];
}

- (void)selfSetting{
    //创建录音引擎
    self.audioEngine = [[AVAudioEngine alloc]init];
    // 这里需要先设置一个AVAudioEngine和一个语音识别的请求对象SFSpeechAudioBufferRecognitionRequest
    NSLocale *cale = [[NSLocale alloc]initWithLocaleIdentifier:@"zh-CN"];
    self.recognizer = [[SFSpeechRecognizer alloc]initWithLocale:cale];
    self.recordingBtn.enabled = false;
    
    //设置代理
    self.recognizer.delegate = self;
    //发送语音认证请求(首先要判断设备是否支持语音识别功能)
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        bool isButtonEnabled = NO;
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                isButtonEnabled = YES;
                NSLog(@"可以语音识别");
                break;
            case SFSpeechRecognizerAuthorizationStatusDenied:
                isButtonEnabled = NO;
                NSLog(@"用户被拒绝访问语音识别");
                break;
            case SFSpeechRecognizerAuthorizationStatusRestricted:
                isButtonEnabled = NO;
                NSLog(@"不能在该设备上进行语音识别");
                break;
            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                isButtonEnabled = NO;
                NSLog(@"没有授权语音识别");
                break;
            default:
                break;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.recordingBtn.enabled = isButtonEnabled;
            
        });
    }];
}

#pragma mark - delegate

- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available{
    if (available) {
        self.recordingBtn.enabled = YES;
    }else{
        
        self.recordingBtn.enabled = NO;
    }
}

#pragma mark - click
- (void)BtnClick:(UIButton *)sender {
    if ([self.audioEngine isRunning]) {
        [self.audioEngine stop];
        [self.recognitionRequest endAudio];
        self.recordingBtn.enabled = YES;
        [self.recordingBtn setTitle:@"开始" forState:UIControlStateNormal];
    }else{
        [self startRecording];
        [self.recordingBtn setTitle:@"停止" forState:UIControlStateNormal];
    }
}

#pragma mark - longPress
- (void)btnLong:(UIButton *)sender{
    
    if (!self.touchUpFlag) {
        self.longPressFlag = YES;
        NSLog(@"长按事件");
        [self startRecording];
    }
    //[self.longPressTimer invalidate];
}

-(void) offsetButtonTouchEnd:(id)sender{
    
    if (self.touchUpFlag) {
        NSLog(@"计时结束");
        self.longPressFlag = NO;
        [self.audioEngine stop];
        [self.recognitionRequest endAudio];
        self.recordingBtn.enabled = YES;
    }
    //[self.longPressTimer invalidate];
}

#pragma mark - function

- (void)startRecording{
    if (self.recognitionTask) {
        [self.recognitionTask cancel];
        self.recognitionTask = nil;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    bool  audioBool = [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    bool  audioBool1= [audioSession setMode:AVAudioSessionModeMeasurement error:nil];
    bool  audioBool2= [audioSession setActive:true withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    if (audioBool || audioBool1||  audioBool2) {
        NSLog(@"可以使用");
    }else{
        NSLog(@"这里说明有的功能不支持");
    }
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc]init];
    AVAudioInputNode *inputNode = self.audioEngine.inputNode;
    
    self.recognitionRequest.shouldReportPartialResults = true;
    
    //开始识别任务
    self.recognitionTask = [self.recognizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        // 识别结果，识别后的操作
        if (result == NULL) return;
        
        bool isFinal = false;
        if (result) {
            NSLog(@"->>>  %@",[[result bestTranscription] formattedString]);
            self.recognizerLabel.text = [[result bestTranscription] formattedString];
            isFinal = [result isFinal];
        }
        if (error || isFinal) {
            [self.audioEngine stop];
            [inputNode removeTapOnBus:0];
            self.recognitionRequest = nil;
            self.recognitionTask = nil;
            self.recordingBtn.enabled = true;
        }
    }];
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self.recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    [self.audioEngine prepare];
    bool audioEngineBool = [self.audioEngine startAndReturnError:nil];
    NSLog(@"%d",audioEngineBool);
}

#pragma mark- SFSpeechRecognitionTaskDelegate

// Called when the task first detects speech in the source audio
- (void)speechRecognitionDidDetectSpeech:(SFSpeechRecognitionTask *)task {
    NSLog(@"当任务首次检测到源音频中的语音时调用");
}

// Called for all recognitions, including non-final hypothesis
- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didHypothesizeTranscription:(SFTranscription *)transcription {
    NSLog(@"%s",__func__);
}

// Called only for final recognitions of utterances. No more about the utterance will be reported
- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishRecognition:(SFSpeechRecognitionResult *)recognitionResult {
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:18],
                                 };
    
    CGRect rect = [recognitionResult.bestTranscription.formattedString boundingRectWithSize:CGSizeMake(self.view.bounds.size.width - 100, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    self.recognizerLabel.text = recognitionResult.bestTranscription.formattedString;
    self.recognizerLabel.frame = CGRectMake(50, 120, rect.size.width, rect.size.height);
    
}

// Called when the task is no longer accepting new audio but may be finishing final processing
- (void)speechRecognitionTaskFinishedReadingAudio:(SFSpeechRecognitionTask *)task {
    NSLog(@"%s",__func__);
}

// Called when the task has been cancelled, either by client app, the user, or the system
- (void)speechRecognitionTaskWasCancelled:(SFSpeechRecognitionTask *)task {
    NSLog(@"%s",__func__);
}

// Called when recognition of all requested utterances is finished.
// If successfully is false, the error property of the task will contain error information
- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishSuccessfully:(BOOL)successfully {
    if (successfully) {
        NSLog(@"全部解析完毕");
    }
}

#pragma mark- getter

- (UILabel *)recognizerLabel {
    if (!_recognizerLabel) {
        _recognizerLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 120, self.view.bounds.size.width - 100, 200)];
        _recognizerLabel.numberOfLines = 0;
        _recognizerLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _recognizerLabel.adjustsFontForContentSizeCategory = YES;
        _recognizerLabel.textColor = [UIColor orangeColor];
        _recognizerLabel.layer.cornerRadius = 4.;//边框圆角大小
        _recognizerLabel.layer.masksToBounds = YES;
        _recognizerLabel.layer.borderColor = [UIColor colorWithRed:0.98 green:0.61 blue:0.21 alpha:1].CGColor;//边框颜色
        //_recognizerLabel.layer.borderColor = [UIColor blackColor].CGColor;
        _recognizerLabel.layer.borderWidth = 2;//边框宽度
        [self.view addSubview:_recognizerLabel];
        //[self.view bringSubviewToFront:_recognizerLabel];
    }
    return _recognizerLabel;
}

@end
