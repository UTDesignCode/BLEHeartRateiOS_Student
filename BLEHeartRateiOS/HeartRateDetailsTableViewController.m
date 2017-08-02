//
//  HeartRateDetailsTableViewController.m
//  BLEHeartRateiOS, Student Copy
//
//  See License Agreement Document for
//  details about your usage of this software.
//
//  Created by Khan, Mohammad on 8/2/17.
//  Copyright © 2017 Khan, Mohammad. All rights reserved.
//



#import "HeartRateDetailsTableViewController.h"

@interface HeartRateDetailsTableViewController ()

@end



@implementation HeartRateDetailsTableViewController



- (void)viewDidLoad {
    
    
    /* Method provided to us by system:
     * Called after the controller's view is loaded into memory.
     */
    [super viewDidLoad];
    
    
    
    /* Initializing the deviceManager with delegate on the main queue
     * See Module 2 videos on Delegation, Protocols, and the Core Bluetooth
     * Framework for more information.
     */
    self.deviceManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    
    
    
    /* Initializing the services array with the HRService UUID string which
     * is turned into a CBUUID type using the UUIDWithString method. This is done
     * so so we our string UUIDs can work with the Core Bluetooth framework
     */
    self.services = @[[CBUUID UUIDWithString:HRService]];
    
    
}





/* Required Method. See Module 2 videos for more information
 * about the method and the parameters involved.
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    
    if ([central state] == CBManagerStatePoweredOff) {
        
        
        NSLog(@"Bluetooth is powered off. Please turn it on.");
        
        
    } else if ([central state] == CBManagerStatePoweredOn) {
        
        
        /* If state == on, then, we will use scan for services
         * and the services we are scanning for are in the services
         * array initialized earlier.
         */
        NSLog(@"Bluetooth is powered on. Ready to connect.");
        [central scanForPeripheralsWithServices:self.services options:nil];
        
        
    } else if ([central state] == CBManagerStateResetting) {
        
        
        NSLog(@"Bluetooth connection lost. Please standby.");
        
        
    } else if ([central state] == CBManagerStateUnauthorized) {
        
        
        NSLog(@"The app is not authorized to use Bluetooth Low Energy.");
        
    } else if ([central state] == CBManagerStateUnknown) {
        
        
        NSLog(@"The current state is unknown. Please standby.");
        
    } else if([central state] == CBManagerStateUnsupported) {
        
        
        NSLog(@"The platform is unsupported.");
        
    }
    
}





- (void) centralManager:(CBCentralManager *)central
  didDiscoverPeripheral:(CBPeripheral *)peripheral
      advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                   RSSI:(NSNumber *)RSSI {
    
    
    
    /* The sensortag will be the peripheral device and the delegate is set.
     * See Module 2 videos on Delegation, Protocols, and the Core Bluetooth
     * Framework for more information.
     */
    self.mspSensor = peripheral;
    self.mspSensor.delegate = self;
    
    
    
    
    /* Establishing connection with peripheral device */
    [self.deviceManager connectPeripheral:self.mspSensor options:nil];
    
    
    
    
    /* Debugging Statements */
    NSLog(@"If you see this, the connectPeripheral method was called.");
    NSLog(@"Peripheral Name: %@", peripheral.name);
    
    
    
    
    
}




- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    
    /* WORKFLOW FOR THIS METHOD
     * At this point, we have connected to the peripheral device and can now start
     * discovering services.
     *
     * Step 1: Used discoverServices method
     */
    
    
    
    /* Debugging statement */
    NSLog(@"The MSP Heart Rate Monitor is connected.");
    
    
    /* Step 1 */
    [peripheral discoverServices:self.services];
    
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    
    
    /* WORKFLOW FOR THIS METHOD
     * At this point, we have discovered the services for our peripheral device and now
     * we can begin to discover characteristics. The workflow
     * steps for this are:
     *
     * Step 1: Fast Enumeration technique to cycle through the services we found
     * Step 2: Use discoverCharacteristics:forService method
     */
    
    
    
    /* Step 1 */
    
    for (CBService *MSPService in peripheral.services) {
        
        /* Debugging statement */
        NSLog(@"Discovered Services: %@", MSPService.UUID);
        
        
        /* Step 2 */
        [peripheral discoverCharacteristics:nil forService:MSPService];
        
    }
    
    
    
}





- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    
    /* WORKFLOW FOR THIS METHOD
     * At this point, we have discovered the characteristics for our HRService and now
     * we can begin to read the value for the characteristics in our HRService. The workflow
     * steps for this are:
     *
     * Step 1: Fast Enumeration technique to cycle through the characteristics we found
     * Step 2: Compare to see if the UUID matches the characteristic UUID in our UUIDList.h file
     * Step 3: Call readValueForCharacteristic method for this characteristic
     * Step 4: Repeat for all characteristics in our HRService.
     */
    
    
    
    /* Step 1:
     * A service has a property called characteristics, which is the array
     * of characteristics for that service. We are using the fast enumeration
     * technique to cycle through each of the elements in the characteristics
     * array.
     */
    for (CBCharacteristic *MSPCharacteristic in service.characteristics) {
        
        
        /* Step 2 + 3 for HRValueCharacteristic (heart rate value) */
        
        if ([MSPCharacteristic.UUID isEqual:[CBUUID UUIDWithString:HRValueCharacteristic]]) {
            
            NSLog(@"HRValueCharacteristic Read Call");
            [peripheral readValueForCharacteristic:MSPCharacteristic];
            
        }
        
        
        
        /* Step 2 + 3 for HRDateCharacteristic (sample date) */
        
        if ([MSPCharacteristic.UUID isEqual:[CBUUID UUIDWithString:HRDateCharacteristic]]) {
            
            NSLog(@"HRDateCharacteristic Read Call");
            [peripheral readValueForCharacteristic:MSPCharacteristic];
            
        }
        
        
        
        /* Step 2 + 3 for HRSensorLocationCharacteristic (body sensor location) */
        
        if ([MSPCharacteristic.UUID isEqual:[CBUUID UUIDWithString:HRSensorLocationCharacteristic]]) {
            
            NSLog(@"HRSensorLocationCharacteristic Read Call");
            [peripheral readValueForCharacteristic:MSPCharacteristic];
            
        }
        
        
        
        /* Step 2 + 3 for HRBatteryLevelCharacteristic (battery level) */
        
        if ([MSPCharacteristic.UUID isEqual:[CBUUID UUIDWithString:HRBatteryLevelCharacteristic]]) {
            
            NSLog(@"HRBatteryLevelCharacteristic Read Call");
            [peripheral readValueForCharacteristic:MSPCharacteristic];
            
        }
        
        
        
    } /* End of fast enumeration loop */
}




- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    
    /* WORKFLOW FOR THIS METHOD
     * In the previous method, we called readValueForCharacteristic method.
     * When you call this method to read the value of a characteristic, the peripheral calls the
     * peripheral:didUpdateValueForCharacteristic:error: which is the method we are in currently. In this
     * method we will do the following:
     *
     * Step 1: See if the UUID of the characteristics we found match any in the UUIDList.h file
     * Step 2: Perform data processing operations using several classes on iOS depending upon the data type
     * Step 3: Repeat for all characteristic data
     */
    
    
    
    
    /* Step 1 + 2 for HRValueCharacteristic (heart rate value) */
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HRValueCharacteristic]]) {
        
        
        /* Log the UUID of the characteristic and it's raw value for reference */
        NSLog(@"Characteristic UUID:  %@", characteristic.UUID.UUIDString);
        NSLog(@"Characteristic Value: %@", characteristic.value);
        
        
        /* Data Processing Workflow for a Numerical Value
         * Based on the logging statements, we see that our heart rate value is 5a000000.
         * This value is stored as an NSData type in the Core Bluetooth framework. Our job
         * is to do the following:
         *
         * Step 1: Make an NSData variable to store the raw value
         * Step 2: Turn this value into an unsigned 32 bit integer
         * Step 3: Turn the unsigned 32 bit integer value into an NSNumber
         * Step 4: Turn NSNumber value to a string value and display it inside our label
         *
         * NOTE: There might be other techniques do this workflow, this is just one way of
         * peforming this operation.
         */
        
        
        
        /* Step 1 */
        NSData *rawData = characteristic.value;
        
        
        /* Step 2, Part 1: Making unsigned 32 bit integer variable and writing
         * a debug statement for reference to see what the value of this int is
         * before converting rawData to intger and then storing that in rawInt
         */
        uint32_t rawInt = 0;
        NSLog(@"rawInt Value Before: %d", rawInt);
        
        /* https://forums.developer.apple.com/thread/83827?sr=stream&ru=413442 */
        [rawData getBytes:&rawInt length:sizeof(rawInt)];
        NSLog(@"rawInt Value After: %d", rawInt);
        
        
        /* Step 3 + 4 */
        self.heartRateValue = [[NSNumber alloc]initWithUnsignedInt:rawInt];
        [self.heartRateLabel setText:[self.heartRateValue stringValue]];
        
    }
    
    
    
    
    
    
    
    /* Step 1 + 2 for HRDateCharacteristic (date) */
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HRDateCharacteristic]]) {
        
        
        
        /* Data Processing Workflow for a Text Value
         * Based on the logging statement and the third party Bluetooth app, we know
         * that our string is encoded in the UTF8String format. So our job is to take
         * that raw data and turn it into a string for displaying.
         *
         * Step 1: Make an NSData variable to store the raw value
         * Step 2: Turn this rawData into a UTF8String type and store this value
         * Step 3: Set the label in the UI to this string
         *
         * NOTE: There might be other techniques do this workflow, this is just one way of
         * peforming this operation.
         */
        
        
        
        /* Log the UUID of the characteristic and it's raw value for reference */
        NSLog(@"Characteristic UUID:  %@", characteristic.UUID.UUIDString);
        NSLog(@"Characteristic Value: %@", characteristic.value);
        
        
        /* Step 1 */
        NSData *rawData = characteristic.value;
        
        
        
        /* Step 2 + Debugging Statement for reference */
        self.dateString = [[NSString alloc] initWithData:rawData encoding:NSUTF8StringEncoding];
        NSLog(@"Date: %@",self.dateString);
        
        
        
        /* Step 3 */
        self.dateLabel.text = self.dateString;
        
    }
    
    
    
    /* Step 1 + 2 for HRSensorLocationCharacteristic (sensor location) */
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HRSensorLocationCharacteristic]]) {
        
        
        /* Data Processing Workflow for a Text Value
         * Based on the logging statement and the third party Bluetooth app, we know
         * that our string is encoded in the UTF8String format. So our job is to take
         * that raw data and turn it into a string for displaying.
         *
         * Step 1: Make an NSData variable to store the raw value
         * Step 2: Turn this rawData into a UTF8String type and store this value
         * Step 3: Set the label in the UI to this string
         *
         * NOTE: There might be other techniques do this workflow, this is just one way of
         * peforming this operation.
         */
        
        
        
        /* Log the UUID of the characteristic and it's raw value for reference */
        NSLog(@"Characteristic UUID:  %@", characteristic.UUID.UUIDString);
        NSLog(@"Characteristic Value: %@", characteristic.value);
        
        
        
        /* Step 1 */
        NSData *rawData = characteristic.value;
        
        
        /* Step 2 + Debugging Statement for reference */
        self.sensorLocationString = [[NSString alloc] initWithData:rawData encoding:NSUTF8StringEncoding];
        NSLog(@"Sensor Location: %@",self.sensorLocationString);
        
        
        
        /* Step 3 */
        self.sensorLocationLabel.text = self.sensorLocationString;
        
    }
    
    
    
    /* Step 1 + 2 for HRSensorLocationCharacteristic (sensor location) */
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HRBatteryLevelCharacteristic]]) {
        
        
        
        /* Log the UUID of the characteristic and it's raw value for reference */
        NSLog(@"Characteristic UUID:  %@", characteristic.UUID.UUIDString);
        NSLog(@"Characteristic Value: %@", characteristic.value);
        
        
        /* Step 1 */
        NSData *rawData = characteristic.value;
        
        
        
        /* Step 2 + Debugging Statement for reference */
        self.batteryLevelString = [[NSString alloc] initWithData:rawData encoding:NSUTF8StringEncoding];
        NSLog(@"Battery Level: %@",self.batteryLevelString);
        
        
        
        /* Step 3 */
        self.batteryLevelLabel.text = self.batteryLevelString;
        
    }
    
    
    
    
    
}

@end
