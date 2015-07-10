//
//  GJCFAudioDemoViewController.m
//  GJCommonFoundation
//
//  Created by ZYVincent on 14-9-17.
//  Copyright (c) 2014年 ganji.com. All rights reserved.
//

#import "GJCFAudioDemoViewController.h"
#import "TVGDebugQuickUI.h"

@interface GJCFAudioDemoViewController ()

@property (nonatomic,strong)GJCFAudioManager *audioManager;

@property (nonatomic,strong)GJCFAudioModel *currentAudioFile;

@property (nonatomic,strong)UIActivityIndicatorView *activeView;

@property (nonatomic,strong)UIProgressView *progressView;

@property (nonatomic,strong)NSString *audioUploadUrl;

@property (nonatomic,strong)NSString *audioDownloadUrl;

@property (nonatomic,strong)NSDictionary *userInfo;

@end

@implementation GJCFAudioDemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.audioManager = [[GJCFAudioManager alloc]init];
//    self.audioManager.recordDelegate = self;
//    self.audioManager.playerDelegate = self;
    
    UIButton *recordBtn = [TVGDebugQuickUI buttonAddOnView:self.view title:@"录制" target:self selector:@selector(recordNow)];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressRecord:)];
    [recordBtn addGestureRecognizer:longPress];
    recordBtn.gjcf_top = 88;
    recordBtn.gjcf_left = 0;
    
    UIButton *pauseBtn = [TVGDebugQuickUI buttonAddOnView:self.view title:@"暂停播放" target:self selector:@selector(pause)];
    pauseBtn.gjcf_top = 250;
    pauseBtn.gjcf_left = 0;
    
    UIButton *localDurationBtn = [TVGDebugQuickUI buttonAddOnView:self.view title:@"本地时间" target:self selector:@selector(localDuraion)];
    localDurationBtn.gjcf_top = 320;
    localDurationBtn.gjcf_left = 0;
    
    UIButton *recordFinishBtn = [TVGDebugQuickUI buttonAddOnView:self.view title:@"完成录制" target:self selector:@selector(endRecord)];
    recordFinishBtn.gjcf_top = 88;
    recordFinishBtn.gjcf_left = 100;
    
    UIButton *uploadBtn = [TVGDebugQuickUI buttonAddOnView:self.view title:@"上传" target:self selector:@selector(uploadNow)];
    uploadBtn.backgroundColor = [UIColor orangeColor];
    uploadBtn.gjcf_top = 170;
    uploadBtn.gjcf_left = 100;
    
    UIButton *goPlayBtn = [TVGDebugQuickUI buttonAddOnView:self.view title:@"继续播放" target:self selector:@selector(goPlay)];
    goPlayBtn.gjcf_top = 250;
    goPlayBtn.gjcf_left = 100;
    
    UIButton *remoteDurationBtn = [TVGDebugQuickUI buttonAddOnView:self.view title:@"远程时间" target:self selector:@selector(remoteDuration)];
    remoteDurationBtn.gjcf_top = 320;
    remoteDurationBtn.gjcf_left = 100;
    
    UIButton *playBtn = [TVGDebugQuickUI buttonAddOnView:self.view title:@"播放" target:self selector:@selector(playNow)];
    playBtn.gjcf_top = 88;
    playBtn.gjcf_left = 230;
    
    UIButton *downloadBtn = [TVGDebugQuickUI buttonAddOnView:self.view title:@"下载播放" target:self selector:@selector(downloadNow)];
    downloadBtn.gjcf_top = 170;
    downloadBtn.gjcf_left = 230;
    
    UIButton *cancelRecordBtn = [TVGDebugQuickUI buttonAddOnView:self.view title:@"取消录音" target:self selector:@selector(cancelRecord)];
    cancelRecordBtn.gjcf_top = 250;
    cancelRecordBtn.gjcf_left = 230;
    
    self.activeView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activeView.frame = (CGRect){100,310,80,80};
    self.activeView.hidden = YES;
    [self.view addSubview:self.activeView];
    
    self.progressView = [[UIProgressView alloc]init];
    self.progressView.frame = (CGRect){10,310,100,10};
    self.progressView.tintColor = [UIColor orangeColor];
    self.progressView.progress = 0.f;
    [self.view addSubview:self.progressView];
}

#pragma mark - 录音、播放动作
- (void)localDuraion
{
    NSLog(@"AudioLocalPath :%@",[self.audioManager getCurrentRecordAudioFile].localStorePath);
   NSTimeInterval localDuration =  [self.audioManager getDurationForLocalWavPath:[self.audioManager getCurrentRecordAudioFile].localStorePath];
    NSLog(@"localDuration :%lf",localDuration);
}

- (void)remoteDuration
{
    NSString *audioUrl = @"http://image.ganjistatic1.com/gjfs08/M05/44/89/wKhzWFQj31u6nyQoAAAXZvKSSts951.amr";

    [self.audioManager getDurationForRemoteUrl:audioUrl withFinish:^(NSString *remoteUrl, NSTimeInterval duration) {
        
        NSLog(@"remoteUrl duration %lf",duration);
        
    } withFaildBlock:^(NSString *remoteUrl, NSError *error) {
       
        NSLog(@"remoteUrl duration faild:%@",error);

    }];
}

- (void)longPressRecord:(UILongPressGestureRecognizer *)longGesture
{
    if (longGesture.state == UIGestureRecognizerStateBegan) {
        
        [self.audioManager startRecordWithLimitDuration:20];

    }else if(longGesture.state == UIGestureRecognizerStateCancelled || longGesture.state == UIGestureRecognizerStateEnded){
        
        [self.audioManager finishRecord];
    }
}

- (void)recordNow
{
    self.activeView.hidden = NO;
    [self.activeView startAnimating];
    
    [self.audioManager startRecordWithLimitDuration:20];
}

- (void)endRecord
{
    [self.audioManager finishRecord];
    
    [self.activeView stopAnimating];
    self.activeView.hidden = YES;
}

- (void)playNow
{
    self.activeView.hidden = NO;
    [self.activeView startAnimating];
    
    [self.audioManager playCurrentRecodFile];
}

- (void)uploadNow
{
    if (!self.userInfo) {
        NSLog(@"请先登录");
    }
    
    [self.audioManager startUploadCurrentRecordFile];
}

- (void)downloadNow
{
    /* 开始下载音频文件 */
    NSString *audioUrl = @"http://image.ganjistatic1.com/gjfs08/M05/44/89/wKhzWFQj31u6nyQoAAAXZvKSSts951.amr";
    [self.audioManager playRemoteAudioFileByUrl:audioUrl];
}

- (void)pause
{
    [self.audioManager pausePlayCurrentAudio];
}

- (void)goPlay
{
    [self.audioManager startPlayFromLastStopTimestamp];
}

- (void)cancelRecord
{
    [self.audioManager cancelCurrentRecord];
}

#pragma mark - AudioPlayerDelegate
- (void)audioPlayer:(GJCFAudioPlayer *)audioPlay didFinishPlayAudio:(GJCFAudioModel *)audioFile
{
    self.activeView.hidden = YES;
    [self.activeView stopAnimating];
    
    NSLog(@"语音播放完成:%@",audioFile.localStorePath);
}

- (void)audioPlayer:(GJCFAudioPlayer *)audioPlay playingProgress:(CGFloat)progressValue
{
    NSLog(@"语音播放进度 %f",progressValue);
    self.progressView.progress = progressValue;
}

- (void)audioPlayer:(GJCFAudioPlayer *)audioPlay didOccusError:(NSError *)error
{
    NSLog(@"语音播放错误:%@",error);
}

- (void)audioPlayer:(GJCFAudioPlayer *)audioPlay didUpdateSoundMouter:(CGFloat)soundMouter
{
    
}

#pragma mark - AudioRecordDelegate
- (void)audioRecord:(GJCFAudioRecord *)audioRecord didFaildByMinRecordDuration:(NSTimeInterval)minDuration
{
    NSLog(@"要求录音最小时间%lf",minDuration);
}

- (void)audioRecord:(GJCFAudioRecord *)audioRecord didOccusError:(NSError *)error
{
    [self.activeView stopAnimating];
    self.activeView.hidden = YES;
    
    NSLog(@"录音发生错误:%@",error);
}

- (void)audioRecord:(GJCFAudioRecord *)audioRecord finishRecord:(GJCFAudioModel *)resultAudio
{
    if (self.currentAudioFile) {
        self.currentAudioFile = nil;
    }
    NSLog(@"完成录音:%@",resultAudio);
    self.currentAudioFile = resultAudio;
    
    self.activeView.hidden = YES;
    [self.activeView stopAnimating];
}

- (void)audioRecord:(GJCFAudioRecord *)audioRecord limitDurationProgress:(CGFloat)progress
{
    self.progressView.progress = progress;
}
- (void)audioRecord:(GJCFAudioRecord *)audioRecord soundMeter:(CGFloat)soundMeter
{
    NSLog(@"录音输入量:%f",soundMeter);
}

- (void)audioRecordDidCancel:(GJCFAudioRecord *)audioRecord
{
    NSLog(@"录音取消");
}

@end
