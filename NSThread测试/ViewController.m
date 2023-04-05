//
//  ViewController.m
//  NSThread测试
//
//  Created by 翟旭博 on 2023/3/29.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) int ticketSurplusCount;
@property (nonatomic, strong) NSThread *ticketSaleWindow1;
@property (nonatomic, strong) NSThread *ticketSaleWindow2;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //*****先创建线程，再启动线程
    // 1. 创建线程
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    // 2. 启动线程
    [thread start];    // 线程一启动，就会在线程thread中执行self的run方法
    
    //*****创建线程后自动启动线程
    // 1. 创建线程后自动启动线程
    [NSThread detachNewThreadSelector:@selector(run) toTarget:self withObject:nil];
    
    //*****隐式创建并启动线程
    // 1. 隐式创建并启动线程
    [self performSelectorInBackground:@selector(run) withObject:nil];
    
    
    
    //创建一个线程下载图片
    self.imageView = [[UIImageView alloc] init];
    self.imageView.backgroundColor = [UIColor orangeColor];
    self.imageView.frame = CGRectMake(100, 100, 100, 100);
    [self.view addSubview:self.imageView];
    //[self downloadImageOnSubThread];
    
    
    //初始化火车票数量、卖票窗口(非线程安全)、并开始卖票
    //[self initTicketStatusNotSave];
    //初始化火车票数量、卖票窗口(线程安全)、并开始卖票
    //[self initTicketStatusSave];
    
    [self qualityOfServiceStudy];
}
// 新线程调用方法，里边为需要执行的任务
- (void)run {
     NSLog(@"%@", [NSThread currentThread]);
}

//创建一个线程下载图片
- (void)downloadImageOnSubThread {
    // 在创建的子线程中调用downloadImage下载图片
    [NSThread detachNewThreadSelector:@selector(downloadImage) toTarget:self withObject:nil];
}

/**
 * 下载图片，下载完之后回到主线程进行 UI 刷新
 */
- (void)downloadImage {
    NSLog(@"current thread -- %@", [NSThread currentThread]);
    
    // 1. 获取图片 imageUrl
    NSURL *imageUrl = [NSURL URLWithString:@"https://img-blog.csdnimg.cn/0d000aba1bf946ebbd37e66872cfd3bb.png"];
    
    // 2. 从 imageUrl 中读取数据(下载图片) -- 耗时操作
    NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
    // 通过二进制 data 创建 image
    UIImage *image = [UIImage imageWithData:imageData];
    
    // 3. 回到主线程进行图片赋值和界面刷新
    [self performSelectorOnMainThread:@selector(refreshOnMainThread:) withObject:image waitUntilDone:YES];
}
/**
 * 回到主线程进行图片赋值和界面刷新
 */
- (void)refreshOnMainThread:(UIImage *)image {
    NSLog(@"current thread -- %@", [NSThread currentThread]);
    // 赋值图片到imageview
    self.imageView.image = image;
}


/**
 * 初始化火车票数量、卖票窗口(非线程安全)、并开始卖票
 */
- (void)initTicketStatusNotSave {
    // 1. 设置剩余火车票为 10
    self.ticketSurplusCount = 10;
    
    // 2. 设置北京火车票售卖窗口的线程
    self.ticketSaleWindow1 = [[NSThread alloc]initWithTarget:self selector:@selector(saleTicketNotSafe) object:nil];
    self.ticketSaleWindow1.name = @"北京火车票售票窗口";
    
    // 3. 设置上海火车票售卖窗口的线程
    self.ticketSaleWindow2 = [[NSThread alloc]initWithTarget:self selector:@selector(saleTicketNotSafe) object:nil];
    self.ticketSaleWindow2.name = @"上海火车票售票窗口";
    
    // 4. 开始售卖火车票
    [self.ticketSaleWindow1 start];
    [self.ticketSaleWindow2 start];

}

/**
 * 售卖火车票(非线程安全)
 */
- (void)saleTicketNotSafe {
    while (1) {
        //如果还有票，继续售卖
        if (self.ticketSurplusCount > 0) {
            self.ticketSurplusCount --;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%d 窗口：%@", self.ticketSurplusCount, [NSThread currentThread].name]);
            [NSThread sleepForTimeInterval:0.2];
        }
        //如果已卖完，关闭售票窗口
        else {
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}

/**
 * 初始化火车票数量、卖票窗口(线程安全)、并开始卖票
 */
- (void)initTicketStatusSave {
    // 1. 设置剩余火车票为 10
    self.ticketSurplusCount = 10;
    
    // 2. 设置北京火车票售卖窗口的线程
    self.ticketSaleWindow1 = [[NSThread alloc]initWithTarget:self selector:@selector(saleTicketSafe) object:nil];
    self.ticketSaleWindow1.name = @"北京火车票售票窗口";
    
    // 3. 设置上海火车票售卖窗口的线程
    self.ticketSaleWindow2 = [[NSThread alloc]initWithTarget:self selector:@selector(saleTicketSafe) object:nil];
    self.ticketSaleWindow2.name = @"上海火车票售票窗口";
    
    // 4. 开始售卖火车票
    [self.ticketSaleWindow1 start];
    [self.ticketSaleWindow2 start];
    
}

/**
 * 售卖火车票(线程安全)
 */
- (void)saleTicketSafe {
    while (1) {
        // 互斥锁
        @synchronized (self) {
            //如果还有票，继续售卖
            if (self.ticketSurplusCount > 0) {
                self.ticketSurplusCount --;
                NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%d 窗口：%@", self.ticketSurplusCount, [NSThread currentThread].name]);
                [NSThread sleepForTimeInterval:0.2];
            }
            //如果已卖完，关闭售票窗口
            else {
                NSLog(@"所有火车票均已售完");
                break;
            }
        }
    }
}

//qualityOfService属性：设置线程优先级
- (void)qualityOfServiceStudy {
    NSThread *thread1 = [[NSThread alloc] initWithBlock:^{
        NSLog(@"\n 线程：%@ start",[NSThread currentThread]);
    }];
    thread1.name = @"测试线程 1 ";
    [thread1 start];
    
    NSThread *thread2 = [[NSThread alloc] initWithBlock:^{
        NSLog(@"\n 线程：%@ start",[NSThread currentThread]);
    }];
    thread2.qualityOfService = NSQualityOfServiceUserInteractive;
    thread2.name = @"测试线程 2 ";
    [thread2 start];
}
@end
