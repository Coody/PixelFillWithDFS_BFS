//
//  ViewController.m
//  testPixelFillWithoutRecursive
//
//  Created by CoodyChou on 2016/5/2.
//  Copyright © 2016年 CoodyChou. All rights reserved.
//

#import "ViewController.h"

#pragma mark - Pixel Unit
@interface PixelUnit : NSObject
@property (nonatomic , assign) CGPoint point;
@property (nonatomic , assign) NSUInteger color;
@property (nonatomic , assign) BOOL isDoneUpDown;
@property (nonatomic , assign) BOOL isDoneLeftRight;
@end

@implementation PixelUnit
-(instancetype)initWithX:(NSUInteger)x withY:(NSUInteger)y{
    self = [super init];
    if ( self ) {
//        _color = [UIColor colorWithRed:arc4random()%1
//                                 green:arc4random()%1
//                                  blue:arc4random()%1
//                                 alpha:1.0f];
        _point.x = x;
        _point.y = y;
        _color = arc4random()%2;
        _isDoneUpDown = NO;
        _isDoneLeftRight = NO;
    }
    return self;
}

@end

static NSUInteger const kMAX_FRAME = 2048;

#pragma mark - VC
@interface ViewController ()
@property (nonatomic , strong) UITextField *textfieldX;
@property (nonatomic , strong) UITextField *textfieldY;
@property (nonatomic , assign) NSUInteger newColor;
@property (nonatomic , assign) NSUInteger oldColor;// 廣度搜尋不用此 property
@property (nonatomic , strong) NSMutableArray *pixelArray;
@property (nonatomic , strong) NSMutableArray *theSameColorPixelArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor grayColor]];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSUInteger maxFrame = kMAX_FRAME*kMAX_FRAME;
    _pixelArray = [[NSMutableArray alloc] initWithCapacity:maxFrame];
    _theSameColorPixelArray = [[NSMutableArray alloc] initWithCapacity:maxFrame];
    
    for (int i = 0 ; i < maxFrame ; i++) {
        PixelUnit *unit = [[PixelUnit alloc] initWithX:i%kMAX_FRAME withY:i/kMAX_FRAME];
        [_pixelArray addObject:unit];
    }
    
//    [self show];
    
    [self createTextField];
    
}

-(void)show{
    NSLog(@"\n圖片:\n");
    int count = 0;
    for ( PixelUnit *unit in _pixelArray ) {
        count++;
        printf("%d" , (int)unit.color);
        if ( count >= kMAX_FRAME ) {
            printf("\n");
            count = 0;
        }
    }
}

-(void)createTextField{
    UILabel *labelX = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width*0.4 - 10),
                                                                (self.view.frame.size.height)*0.5,
                                                                20, 40)];
    [labelX setTextColor:[UIColor blackColor]];
    [labelX setText:@"X:"];
    [self.view addSubview:labelX];
    
    _textfieldX = [[UITextField alloc]
                               initWithFrame:CGRectMake(labelX.frame.origin.x + labelX.frame.size.width,
                                                        labelX.frame.origin.y,
                                                        labelX.frame.size.width, labelX.frame.size.height)];
    [self.view addSubview:_textfieldX];
    [_textfieldX setKeyboardType:(UIKeyboardTypeNumberPad)];
    [_textfieldX setTextColor:[UIColor blackColor]];
    [_textfieldX setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *labelY = [[UILabel alloc] initWithFrame:CGRectMake(_textfieldX.frame.origin.x + _textfieldX.frame.size.width + 10,
                                                                (self.view.frame.size.height)*0.5,
                                                                20, 40)];
    [labelY setTextColor:[UIColor blackColor]];
    [labelY setText:@"Y:"];
    [self.view addSubview:labelY];
    
    _textfieldY = [[UITextField alloc]
                               initWithFrame:CGRectMake(labelY.frame.origin.x + labelY.frame.size.width,
                                                        labelY.frame.origin.y,
                                                        labelY.frame.size.width, labelY.frame.size.height)];
    [self.view addSubview:_textfieldY];
    [_textfieldY setKeyboardType:(UIKeyboardTypeNumberPad)];
    [_textfieldY setTextColor:[UIColor blackColor]];
    [_textfieldY setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 80)*0.5, labelX.frame.origin.y + labelX.frame.size.height + 10, 80, 40)];
    [button setTitle:@"填滿！" forState:(UIControlStateNormal)];
    [button setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    [button setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:button];
    
    [button addTarget:self action:@selector(pressedButton) forControlEvents:(UIControlEventTouchUpInside)];
}

-(void)pressedButton{
    [self fillPointWithX:[_textfieldX.text integerValue] withY:[_textfieldY.text integerValue] withColor:4];
}


#pragma mark - 填滿顏色到這個區塊
-(void)fillPointWithX:(NSUInteger)x withY:(NSUInteger)y withColor:(NSUInteger)color{
    if( x < kMAX_FRAME && y < kMAX_FRAME && ((PixelUnit *)(_pixelArray[x+kMAX_FRAME*y])).color != color){
        
        
        // 廣度搜尋的方法
        NSDate *methodStart1 = [NSDate date];
        
        _newColor = color;
        PixelUnit *unit  = _pixelArray[x+kMAX_FRAME*y];
        [_theSameColorPixelArray addObject:unit];
        
        while ( [_theSameColorPixelArray count] > 0 ) {
            
            PixelUnit *firstUnit = [_theSameColorPixelArray firstObject];
            [self startFill:firstUnit];
            
        }
        NSDate *methodFinish = [NSDate date];
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart1];
        NSLog(@"廣度搜尋時間 = %f", executionTime);
//        [self show];
        
        // 遞迴的方法
        _oldColor = _newColor;
        _newColor = 8;
        NSDate *methodStart2 = [NSDate date];
        [self fillPoint:_pixelArray[x+kMAX_FRAME*y]];
        methodFinish = [NSDate date];
        executionTime = [methodFinish timeIntervalSinceDate:methodStart2];
        NSLog(@"遞迴時間 = %f", executionTime);
//        [self show];
    }
    else{
        NSLog(@"請選擇畫布中的一點，且顏色必須選擇不一樣");
    }
}

/**
 * @brief   - 廣度搜尋，不使用遞迴，只使用迴圈來增加填色效能
 * @details - 演算法的方式就是：找到所有此節點左邊最遠相鄰的節點是哪些，把這些點加入陣列，然後搜尋右邊、再來搜尋上面、再來搜尋下面，把這些節點加入陣列。
 */
-(void)startFill:(PixelUnit *)pixelUnit{
    if ( pixelUnit.isDoneLeftRight == NO ) {
        // 往左邊找
        for ( int i = pixelUnit.point.x ; ;  ) {
            i--;
            if ( i >= 0 ) {
                PixelUnit *leftUnit = _pixelArray[i+(int)pixelUnit.point.y*kMAX_FRAME];
                if ( leftUnit.color == pixelUnit.color && (leftUnit.isDoneUpDown == NO || leftUnit.isDoneLeftRight == NO )) {
                    [self addUnit:leftUnit];
                }
                else{
                    break;
                }
            }
            else{
                break;
            }
        }
        
        // 往右邊找
        for ( int i = pixelUnit.point.x ; ; ) {
            i++;
            if ( i < kMAX_FRAME ) {
                PixelUnit *rightUnit = _pixelArray[i+(int)pixelUnit.point.y*kMAX_FRAME];
                if ( rightUnit.color == pixelUnit.color && (rightUnit.isDoneUpDown == NO || rightUnit.isDoneLeftRight == NO ) ) {
                    [self addUnit:rightUnit];
                }
                else{
                    break;
                }
            }
            else{
                break;
            }
        }
    }
    pixelUnit.isDoneLeftRight = YES;
    
    if ( pixelUnit.isDoneUpDown == NO ) {
        // 往上邊找
        for ( int j = pixelUnit.point.y ; ;  ) {
            j--;
            if ( j >= 0 ) {
                PixelUnit *upUnit = _pixelArray[(int)pixelUnit.point.x + j*kMAX_FRAME];
                if ( upUnit.color == pixelUnit.color && (upUnit.isDoneUpDown == NO || upUnit.isDoneLeftRight == NO )) {
                    [self addUnit:upUnit];
                }
                else{
                    break;
                }
            }
            else{
                break;
            }
        }
        
        // 往下邊找
        for ( int j = pixelUnit.point.y ; ; ) {
            j++;
            if ( j < kMAX_FRAME ) {
                PixelUnit *downUnit = _pixelArray[(int)pixelUnit.point.x + j*kMAX_FRAME];
                if ( downUnit.color == pixelUnit.color && (downUnit.isDoneUpDown == NO || downUnit.isDoneLeftRight == NO )) {
                    [self addUnit:downUnit];
                }
                else{
                    break;
                }
            }
            else{
                break;
            }
        }
    }
    pixelUnit.isDoneUpDown = YES;
    pixelUnit.color = _newColor;
    [_theSameColorPixelArray removeObject:pixelUnit];
    
#ifdef D_Show_Progress
    NSLog(@"\n 填色:(%d)\n" , (int)_newColor);
    [self show];
#endif
}

-(void)addUnit:(PixelUnit *)unit{
    [_theSameColorPixelArray addObject:unit];
}


#pragma mark - recoursive 的方法
-(void)fillPoint:(PixelUnit *)unit{
    
    if ( unit.color == _oldColor ) {
        unit.color = _newColor;
        if ( (int)unit.point.x - 1 >= 0 ) {
            [self fillPoint:_pixelArray[(int)unit.point.x - 1 + (int)unit.point.y*kMAX_FRAME]];
        }
        if ( (int)unit.point.x + 1 < kMAX_FRAME ) {
            [self fillPoint:_pixelArray[(int)unit.point.x + 1 + (int)unit.point.y*kMAX_FRAME]];
        }
        if ( (int)unit.point.y - 1 >= 0 ) {
            [self fillPoint:_pixelArray[(int)unit.point.x + ((int)unit.point.y - 1)*kMAX_FRAME]];
        }
        if ( (int)unit.point.y + 1 < kMAX_FRAME ) {
            [self fillPoint:_pixelArray[(int)unit.point.x + ((int)unit.point.y + 1)*kMAX_FRAME]];
        }
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
