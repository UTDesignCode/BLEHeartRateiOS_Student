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


// FULLY IMPLEMENTED :)
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





/* FULLY IMPLEMENTED :)
 * Required Method. See Module 2 videos for more information
 * about the method and the parameters involved.
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    
    if ([central state] == CBManagerStatePoweredOff) {
        
        
        NSLog(@"Bluetooth is powered off. Please turn it on.");
        
        
    } else if ([central state] == CBManagerStatePoweredOn) {
        
        
        NSLog(@"Bluetooth is powered on. Ready to connect.");
        
        
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




/* FULLY IMPLEMENTED :)
 * This is our IBAction method for when our start button is tapped.
 * What we want to do here is to see if Bluetooth is on, and if it is, the
 * we initiate a scan for peripherals devices with the services we specify. If
 * Bluetooth is off, then we will present and alert similar to way we did in 
 * Module 1, App Lab 1: Text Input. For a refresher on presenting alerts, please
 * see those videos.
 */
- (IBAction)whenStartScanButtonIsTapped:(id)sender {
    
    
    /* If BLE powered on, start scan */
    if ([self.deviceManager state] == CBManagerStatePoweredOn) {
        
        
        /* Debugging statement for reference */
        NSLog(@"Button Pressed, State On!");
        
        /* Scan method called */
        [self.deviceManager scanForPeripheralsWithServices:self.services options:nil];
        
        
    } else {
    
    
    /* Debugging statement for reference */
    NSLog(@"Button Pressed, State Off, Showing Alert!");
    
    
    /* String variables for the various string parameters in the alert controllers */
    NSString *alertTitleText = [NSString stringWithFormat:@"Unable to Get Data."];
    NSString *alertMessageText = [NSString stringWithFormat:@"Please turn on Bluetooth and try again."];
    NSString *actionTitleText = [NSString stringWithFormat:@"Got it!"];
    
    
    /* Making an alert here with a title, message, and style */
    UIAlertController *BLEOffAlert = [UIAlertController alertControllerWithTitle:alertTitleText
                                                                              message:alertMessageText
                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    /* Making an alert action with title, style and handle */
    UIAlertAction *dismissBLEAlertAction = [UIAlertAction actionWithTitle:actionTitleText
                                                                 style:UIAlertActionStyleDestructive
                                                               handler:nil];
    
    /* Adding the dismissAlert action to our alert */
    [BLEOffAlert addAction:dismissBLEAlertAction];
    
    
    /* Presenting the BLEOffAlert with animation */
    [self presentViewController:BLEOffAlert animated:YES completion:nil];
    
    }
}






// FULLY IMPLEMENTED :)
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



// FULLY IMPLEMENTED :)
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





// FULLY IMPLEMENTED :)
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





// NOT IMPLEMENTED YET!
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
        
        
        
        
    } /* End of fast enumeration loop */
}



// NOT IMPLEMENTED YET!
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
        
        
        
        
        
        /* Step 2, Part 1: Making unsigned 32 bit integer variable and writing
         * a debug statement for reference to see what the value of this int is
         * before converting rawData to intger and then storing that in rawInt
         */
        
        
        
        
        
        
        /* Step 2, Part 2: */
       
        
        
        
        /* Step 3 + 4 */
        
        
        
        
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
        
        
        
        
        /* Step 2 + Debugging Statement for reference */
        
        
        
        
        
        /* Step 3 */
        
        
    }
    
    
    
    /* Step 1 + 2 for HRSensorLocationCharacteristic (sensor location) */
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HRSensorLocationCharacteristic]]) {
        
        
        
        /* Log the UUID of the characteristic and it's raw value for reference */
        NSLog(@"Characteristic UUID:  %@", characteristic.UUID.UUIDString);
        NSLog(@"Characteristic Value: %@", characteristic.value);
        
        
        
       
        
    }
    
    
    
    /* Step 1 + 2 for HRSensorLocationCharacteristic (sensor location) */
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HRBatteryLevelCharacteristic]]) {
        
        
        
        /* Log the UUID of the characteristic and it's raw value for reference */
        NSLog(@"Characteristic UUID:  %@", characteristic.UUID.UUIDString);
        NSLog(@"Characteristic Value: %@", characteristic.value);
        
        
        
        
    }
    
    
    
    
    
}

@end
