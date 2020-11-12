//
//  ViewController.m
//  Bilibili
//
//  Created by 赵明明 on 2020/11/11.
// 之后大部分代码需要写在这个文件里

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "ImageProcess.h"

//@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *status_text;

@property (weak, nonatomic) IBOutlet UIButton *useModel;
@property (weak, nonatomic) IBOutlet UIImageView *image_1;
@property (weak, nonatomic) IBOutlet UIButton *get_image_button;

@property (weak, nonatomic) IBOutlet UIButton *button_getimage;
@property (weak, nonatomic) IBOutlet UITextField *textarea;
@property (nonatomic) UIImagePickerController *camera;
-(void) switchMOVtoMP:(NSURL *)inputURL;
+(NSString*)getCurrentTimes;

-(void)deleteVideo:(NSString *)path;
-(void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL outputURL:(NSURL*)outputURL;

- (void)calulateImageFileSize:(UIImage *)image;
// camera 拍照
- (void)takePhoto;
// 从相册读取
- (void)selectPhoto;
@end

@implementation ViewController

- (IBAction)useModel:(id)sender {
    NSLog(@"use model to process image");
    self.status_text.text=@"正在使用模型处理图片";
    UIImage *image = self.image_1.image;
    [self calulateImageFileSize:image];
    
    
    ImageProcess *p = [ImageProcess new];
    //testImageView.image=[p imageBlackToTransparent:testImageView.image:255:128:128];
    CGSize smallsize = CGSizeMake(200.0f, 200.0f);
    //image=[p scaleToSize:image:smallsize];
    //self.image_1.image = [p imageBlackToTransparent:image:255:128:128];
    //self.image_1.image=image;
    float* bias =(float*)malloc(1);
    float weightsarray[121];
    for(int i = 0;i<121;i++)
    {
        weightsarray[i]=1.0f/121.0f;
    }
    printf("%f\n",weightsarray[0]);
    printf("%f\n",weightsarray[1]);
    printf("%f\n",weightsarray[2]);
    printf("%f\n",weightsarray[3]);
    printf("%f\n",weightsarray[4]);
    printf("%f\n",weightsarray[5]);
    printf("%f\n",weightsarray[6]);
    
    memset(bias,0.0,1*sizeof(*bias));
    int padding=0;
    int stride=0;
    int kernel_size=11;
    //(UIImage* )passlayer:(UIImage*)image :(float*)weightsarray :(int)kernel_size :(int)bias :(int)padding :(int)stride
    image=[p passlayer:image:weightsarray:kernel_size:bias:padding:stride];
    self.image_1.image=image;
    self.status_text.text=@"已处理完,可以继续处理";
}

- (void)takePhoto{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    imagePickerController.delegate  = self;
    imagePickerController.allowsEditing=YES;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)selectPhoto{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing= YES;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}



- (IBAction)button_getimage:(id)sender {
    [self takePhoto];
}
- (IBAction)button_getAlbum:(id)sender {
    [self selectPhoto];
}

// 取消图片选择调用此方法
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"didCance.@%s,%d,%s",__FILE__,__LINE__,__func__);
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)calulateImageFileSize:(UIImage *)image {
    
    NSData *data = UIImagePNGRepresentation(image);
    if (!data) {
        data = UIImageJPEGRepresentation(image, 0.5);//需要改成0.5才接近原图片大小，原因请看下文
    }
    double dataLength = [data length] * 1.0;
    NSArray *typeArray = @[@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB", @"EB",@"ZB",@"YB"];
    NSInteger index = 0;
    while (dataLength > 1024) {
        dataLength /= 1024.0;
        index ++;
    }
    NSLog(@"image = %.3f %@",dataLength,typeArray[index]);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
        UIButton *btn=[UIButton new];
        [btn setTitle:@"start test" forState:UIControlStateNormal];
        [btn setBackgroundColor:UIColor.redColor];

        [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        btn.translatesAutoresizingMaskIntoConstraints=false;
        [self.view addSubview:btn];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:146]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:46]];
        [btn addTarget:nil action:@selector(btnclick) forControlEvents:UIControlEventTouchUpInside];
    

}

- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

-(void)btnclick
{
    printf("button click\n");
    _textarea.text=@"asdfsadf";
    
    bool canUse= [self isCameraAvailable];
        if(canUse)
        {
            NSLog(@"camera is availiable ");
            self.camera=[[UIImagePickerController alloc]init];
            
            self.camera.sourceType=UIImagePickerControllerSourceTypeCamera;
            self.camera.showsCameraControls=true;
            self.camera.mediaTypes=@[(NSString *)kUTTypeMovie];//typemovie with voice
            self.camera.allowsEditing=true;
          
            /*
             设置视频长度
             */
            self.camera.videoMaximumDuration=5;//seconds
         
            /*
             设置视频质量
             UIImagePickerControllerQualityTypeHigh = 0,       // highest quality
             UIImagePickerControllerQualityTypeMedium = 1,     // medium quality, suitable for transmission via Wi-Fi
             UIImagePickerControllerQualityTypeLow = 2,         // lowest quality, suitable for tranmission via cellular network
             UIImagePickerControllerQualityType640x480 NS_ENUM_AVAILABLE_IOS(4_0) = 3,    // VGA quality
             UIImagePickerControllerQualityTypeIFrame1280x720 NS_ENUM_AVAILABLE_IOS(5_0) = 4,
             UIImagePickerControllerQualityTypeIFrame960x540 NS_ENUM_AVAILABLE_IOS(5_0) = 5,
             */
            
            self.camera.videoQuality= UIImagePickerControllerQualityType640x480;
            
            
            
    //        CGFloat camScaleup=1.8;
    //        self.camera.cameraViewTransform=CGAffineTransformScale(self.camera.cameraViewTransform, camScaleup, camScaleup);
            
            self.camera.delegate=self;
            self.view.backgroundColor=UIColor.lightGrayColor;
            
            if(self.navigationController)
            {
                NSLog(@"have navigation");
                [self.navigationController presentViewController:self.camera animated:true completion:^(){}];
            }
            else{
                NSLog(@"no navigation");
                [self presentViewController:self.camera animated:true completion:nil];
            }
        }else{
            NSLog(@"can not use camera");
            
            
        }
        
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info
{
    
    
    [picker dismissViewControllerAnimated:true completion:nil];
    NSLog(@"didFinish.@%s,%d,%s",__FILE__,__LINE__,__func__);
    
    //拿到图片，可以进行任意处理。
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.image_1.image=image;
    
    
    
    NSString *urlStr =[NSString stringWithFormat:@"%@", [info objectForKey:UIImagePickerControllerMediaURL]];
    
    
    NSString *documentsDirPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject];
    NSURL *documentsDirUrl = [NSURL fileURLWithPath:documentsDirPath isDirectory:YES];
    
    NSString *temp=[ViewController getCurrentTimes];
    NSString *outputName=[temp stringByAppendingString:@".mp4"];
    NSURL *saveMovieFile = [NSURL URLWithString:outputName relativeToURL:documentsDirUrl];
    NSLog(@"saveMovieFile=%@",saveMovieFile);
    //[self convertVideoToLowQuailtyWithInputURL:[[NSURL alloc]initWithString:urlStr] outputURL:saveMovieFile];
    
}

//-(void) switchMOVtoMP:(NSString *)inputStr
-(void) switchMOVtoMP:(NSURL *)inputUrl
{
//    NSURL *inputUrl = [[NSURL alloc]initWithString:inputStr];
    NSLog(@"mov转mp4 ==》%@",inputUrl);
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:inputUrl options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];

    NSString *documentsDirPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject];
    NSURL *documentsDirUrl = [NSURL fileURLWithPath:documentsDirPath isDirectory:YES];

    NSString *temp=[ViewController getCurrentTimes];
    NSString *outputName=[temp stringByAppendingString:@".mp4"];

    NSURL *saveMovieFile = [NSURL URLWithString:outputName relativeToURL:documentsDirUrl];
    exportSession.outputURL =saveMovieFile;
    exportSession.outputFileType =AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse= YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(){
        int exportStatus = exportSession.status;
        switch (exportStatus) {
            case AVAssetExportSessionStatusFailed: {
                    NSError *exportError = exportSession.error;
                    NSLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
                    break;
                    }
                case AVAssetExportSessionStatusCompleted: {
                NSLog(@"视频转码成功");
                }
                
        }
   
    }];
    
}
+(NSString*)getCurrentTimes{
   
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    //现在时间,你可以输出来看下是什么格式
    NSDate *datenow = [NSDate date];
    
    NSString *currentTimeString = [formatter stringFromDate:datenow];

    currentTimeString=[currentTimeString stringByReplacingOccurrencesOfString:@"-"withString:@""];
    currentTimeString=[currentTimeString stringByReplacingOccurrencesOfString:@" "withString:@""];
    currentTimeString=[currentTimeString stringByReplacingOccurrencesOfString:@":"withString:@""];
    return currentTimeString;
    
}
-(void)deleteVideo:(NSString *)path;
{
    
}
-(void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)outputURL
{
    
    //setup video writer
    AVAsset *videoAsset = [[AVURLAsset alloc] initWithURL:inputURL options:nil];
    
    AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
   
    CGSize videoSize = videoTrack.naturalSize;
    //1250000
    NSDictionary *videoWriterCompressionSettings =  [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:440000], AVVideoAverageBitRateKey,
                                                     [NSNumber numberWithInt:20],AVVideoMaxKeyFrameIntervalKey,
                                                     AVVideoProfileLevelH264Baseline30,AVVideoProfileLevelKey, //标清AVVideoProfileLevelH264Baseline30
                                                     [NSNumber numberWithInt:34],AVVideoExpectedSourceFrameRateKey,
                                                     nil];
    
    
    NSDictionary *videoWriterSettings;
    if (@available(iOS 11.0, *)) {
        videoWriterSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecTypeH264, AVVideoCodecKey, videoWriterCompressionSettings, AVVideoCompressionPropertiesKey, [NSNumber numberWithFloat:videoSize.width], AVVideoWidthKey, [NSNumber numberWithFloat:videoSize.height], AVVideoHeightKey, nil];
        
      
    } else {
        // Fallback on earlier versions
         videoWriterSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey, videoWriterCompressionSettings, AVVideoCompressionPropertiesKey, [NSNumber numberWithFloat:videoSize.width], AVVideoWidthKey, [NSNumber numberWithFloat:videoSize.height], AVVideoHeightKey, nil];
        
    }
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoWriterSettings];
    
    videoWriterInput.expectsMediaDataInRealTime = YES;
    
    videoWriterInput.transform = videoTrack.preferredTransform;
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:outputURL fileType:AVFileTypeQuickTimeMovie error:nil];
    
    [videoWriter addInput:videoWriterInput];
    
    //setup video reader
    NSDictionary *videoReaderSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    AVAssetReaderTrackOutput *videoReaderOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:videoReaderSettings];
    
    AVAssetReader *videoReader = [[AVAssetReader alloc] initWithAsset:videoAsset error:nil];
    
    [videoReader addOutput:videoReaderOutput];
    
    //setup audio writer
    AVAssetWriterInput* audioWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeAudio
                                            outputSettings:nil];
    
    audioWriterInput.expectsMediaDataInRealTime = NO;
    
    [videoWriter addInput:audioWriterInput];
    
    //setup audio reader
    AVAssetTrack* audioTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    
    AVAssetReaderOutput *audioReaderOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
    
    AVAssetReader *audioReader = [AVAssetReader assetReaderWithAsset:videoAsset error:nil];
    
    [audioReader addOutput:audioReaderOutput];
    
    [videoWriter startWriting];
    
    //start writing from video reader
    [videoReader startReading];
    
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    dispatch_queue_t processingQueue = dispatch_queue_create("processingQueue1", NULL);
    
    [videoWriterInput requestMediaDataWhenReadyOnQueue:processingQueue usingBlock:
     ^{
         
         while ([videoWriterInput isReadyForMoreMediaData]) {
             
             CMSampleBufferRef sampleBuffer;
             
             if ([videoReader status] == AVAssetReaderStatusReading &&
                 (sampleBuffer = [videoReaderOutput copyNextSampleBuffer])) {
                 
                 [videoWriterInput appendSampleBuffer:sampleBuffer];
                 CFRelease(sampleBuffer);
             }
             
             else {
                 
                 [videoWriterInput markAsFinished];
                 
                 if ([videoReader status] == AVAssetReaderStatusCompleted) {
                     
                     //start writing from audio reader
                     [audioReader startReading];
                     
                     [videoWriter startSessionAtSourceTime:kCMTimeZero];
                     
                     dispatch_queue_t processingQueue = dispatch_queue_create("processingQueue2", NULL);
                     
                     [audioWriterInput requestMediaDataWhenReadyOnQueue:processingQueue usingBlock:^{
                         
                         while (audioWriterInput.readyForMoreMediaData) {
                             
                             CMSampleBufferRef sampleBuffer;
                             
                             if ([audioReader status] == AVAssetReaderStatusReading &&
                                 (sampleBuffer = [audioReaderOutput copyNextSampleBuffer])) {
                                 
                                 [audioWriterInput appendSampleBuffer:sampleBuffer];
                                 CFRelease(sampleBuffer);
                             }
                             
                             else {
                                 
                                 [audioWriterInput markAsFinished];
                                 
                                 if ([audioReader status] == AVAssetReaderStatusCompleted) {
                                     
                                     [videoWriter finishWritingWithCompletionHandler:^(){

                                         
//                                          [self switchMOVtoMP:outputURL];
                                     }];
                                     
                                 }
                             }
                         }
                         
                     }
                      ];
                 }
             }
         }
     }
     ];
}


@end

