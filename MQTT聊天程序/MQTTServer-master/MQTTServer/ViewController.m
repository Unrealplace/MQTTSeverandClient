//
//  ViewController.m
//  MQTTServer
//
//  Created by scinan on 15/10/16.
//  Copyright © 2015年 scinan. All rights reserved.
//

#import "ViewController.h"
#import "MQTTKit.h"


#define kMQTTServerHost @"iot.eclipse.org"
#define kTopic @"MQTTExample/Message"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *pushMessage;
@property (nonatomic, strong) MQTTClient *client;
@property (weak, nonatomic) IBOutlet UILabel *recieveLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSString *clientID = [UIDevice currentDevice].identifierForVendor.UUIDString;
    
    self.client = [[MQTTClient alloc] initWithClientId:clientID];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.client connectToHost:kMQTTServerHost andName:@"cbt" andPassword:@"1223" completionHandler:^(MQTTConnectionReturnCode code) {
            if (code == ConnectionAccepted)
            {
                NSLog(@"服务器启动成功");
                // 订阅
                [self.client subscribe:kTopic withCompletionHandler:^(NSArray *grantedQos) {
                    // The client is effectively subscribed to the topic when this completion handler is called
                    NSLog(@"subscribed to topic %@", kTopic);
                    NSLog(@"return:%@",grantedQos);
                }];
            }
        }];
    });
    
   
    
    __weak typeof(self) weakSelf = self;
    //MQTTMessage  里面的数据接收到的是二进制，这里框架将其封装成了字符串
    [self.client setMessageHandler:^(MQTTMessage* message)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             //接收到消息，更新界面时需要切换回主线程
             weakSelf.recieveLabel.text= message.payloadString;
         });
     }];
    
}
- (IBAction)push:(id)sender {
    NSString* payload = self.pushMessage.text;
    [self.client publishString:payload
                       toTopic:kTopic
                       withQos:AtMostOnce
                        retain:YES
             completionHandler:nil];
    NSLog(@"推送内容：%@",payload);
}


@end
