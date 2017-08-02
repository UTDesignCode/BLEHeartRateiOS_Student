//
//  HeartRateDetailsTableViewController.h
//  BLEHeartRateiOS, Student Copy
//
//  See License Agreement Document for
//  details about your usage of this software.
//
//  Created by Khan, Mohammad on 8/2/17.
//  Copyright © 2017 Khan, Mohammad. All rights reserved.
//



#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "UUIDList.h"



@interface HeartRateDetailsTableViewController : UITableViewController <CBPeripheralDelegate, CBCentralManagerDelegate>



/* Array for taking the string UUID representations in UUIDList.h
 * and making them of CBUUID type so we can work with them in Core Bluetooth
 */
@property(atomic, strong) NSArray *services;
@property(atomic, strong) NSArray *characteristics;



/* Core Bluetooth Property Declaration */
@property(atomic, strong) CBCentralManager *deviceManager;
@property(atomic, strong) CBPeripheral *mspSensor;



/* Data Values for each characteristic data from BLE */
@property(atomic, strong) NSNumber *heartRateValue;
@property(atomic, strong) NSString *heartRateString;
@property(atomic, strong) NSString *dateString;
@property(atomic, strong) NSString *sensorLocationString;
@property(atomic, strong) NSString *batteryLevelString;



/* User Interface elements for viewing our data on the screen */
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *sensorLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryLevelLabel;





@end
