//
//  MoveCellTableViewController.m
//  MoveCellDemo
//
//  Created by tian on 14-4-17.
//  Copyright (c) 2014年 tian. All rights reserved.
//

#import "MoveCellTableViewController.h"
#define IS_IOS7 [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0
@interface MoveCellTableViewController ()
@property (nonatomic,strong) NSMutableArray *objects;
@end

@implementation MoveCellTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.objects = [[NSMutableArray alloc]init];
    for (NSInteger i=0; i<15; i++) {
        [self.objects addObject:[NSString stringWithFormat:@"test%ld",(long)i]];
    }
    NSLog(@"-----%@",self.objects);
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
    [self.tableView addGestureRecognizer:longPress];
}
- (void)longPressAction:(id)sender{
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state; //长按状态
    
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];//更具坐标获取当前的点击位置
    
    static  UIView *snapshot = nil ;//创建截图
    static  NSIndexPath *sourceIndexPath = nil;//开始移动的cell的IndexPath;
    
    
    switch (state) {
            //开始点击
        case UIGestureRecognizerStateBegan:
        {
            if (indexPath) {
                sourceIndexPath = indexPath;
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                
                //返回一个cell截图为UIView;
                snapshot = [self customSnapShotFromView:cell];
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.tableView addSubview:snapshot];
                //动画完成一个截图的拖拽效果
                [UIView animateWithDuration:0.15 animations:^{
                    
                    center.y = location.y;
                    snapshot.center = center;
                    //将截图放大
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    //将截图视图渐变
                    snapshot.alpha = 0.98;
                    
                    //
                    cell.backgroundColor = [UIColor clearColor];
                } completion:^(BOOL finished) {
                    
                }];
            }
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            //如果手势移动的距离对应到另外一个 index path，就需要告诉 table view，让其移动 rows,同时，你需要对 data source 进行更新
            //
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            //判断是否移动出初始化的cell,indexPath为当前选中的cell sourceIndexpath为正在"移动"的cell
            if (indexPath&&![indexPath isEqual:sourceIndexPath]) {
                //TODO:交换数据
                [self.objects exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                //交换了cell
                [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                //将Indexpath作为移动cell;
                sourceIndexPath = indexPath;
            }
        }
            break;
            
        default:{
            //当手势结束或者取消时，table view 和 data source 都是最新的。你所需要做的事情就是将 snapshot view 从 table view 中移除，并把 cell 的背景色还原为白色。
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [UIView animateWithDuration:0.15 animations:^{
               
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;//将视图初始化为原始状态
                snapshot.alpha = 0.0;
                cell.backgroundColor = [UIColor whiteColor];
                
            } completion:^(BOOL finished) {
                
                [snapshot removeFromSuperview];
               
                
            }];
            sourceIndexPath = nil;
        }
            break;
    }
    
}
#pragma mark-创建截图


- (UIView *)customSnapShotFromView:(UIView *)view
{
    
    if(IS_IOS7)
    {
        UIView *snapshot_IOS7 = [view snapshotViewAfterScreenUpdates:YES];
        snapshot_IOS7.layer.masksToBounds = NO;
        snapshot_IOS7.layer.cornerRadius = 0.0;
        snapshot_IOS7.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
        snapshot_IOS7.layer.shadowRadius = 5.0;
        snapshot_IOS7.layer.shadowOpacity = 0.4;
        
        return snapshot_IOS7;
    }
    else
    {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size,view.opaque, 0.0);
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage * snapshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIView *snapshotView = [[UIView alloc]initWithFrame:view.bounds];
        [snapshotView setBackgroundColor:[UIColor colorWithPatternImage:snapshot]];
        snapshotView.layer.masksToBounds = NO;
        snapshotView.layer.cornerRadius = 0.0;
        snapshotView.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
        snapshotView.layer.shadowRadius = 5.0;
        snapshotView.layer.shadowOpacity = 0.4;
        
        return snapshotView;
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return self.objects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   static NSString *cellId = @"CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = self.objects[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
