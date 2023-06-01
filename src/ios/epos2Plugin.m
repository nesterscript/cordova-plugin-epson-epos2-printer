#import "epos2Plugin.h"
#import <UIKit/UIKit.h>
#import <Cordova/CDVAvailability.h>

static NSDictionary *printerTypeMap;
static NSDictionary *barcodeTypeMap;
static NSDictionary *langMap;
static NSDictionary *textLangMap;
static NSDictionary *symbolMap;
static NSDictionary *levelMap;

@interface epos2Plugin()<Epos2DiscoveryDelegate, Epos2PtrReceiveDelegate>
@end

@implementation epos2Plugin

- (void)pluginInitialize
{
    sendDataCallbackId = nil;
    printerTarget = nil;
    printerStatus = nil;
    printerConnected = NO;
    printerSeries = EPOS2_TM_P20;
    lang = EPOS2_MODEL_TAIWAN;
    textLang = EPOS2_LANG_ZH_TW;

    printerTypeMap = @{
        @"TM-M10":    [NSNumber numberWithInt:EPOS2_TM_M10],
        @"TM-M30":    [NSNumber numberWithInt:EPOS2_TM_M30],
        @"TM-P20":    [NSNumber numberWithInt:EPOS2_TM_P20],
        @"TM-P60":    [NSNumber numberWithInt:EPOS2_TM_P60],
        @"TM-P60II":  [NSNumber numberWithInt:EPOS2_TM_P60II],
        @"TM-P80":    [NSNumber numberWithInt:EPOS2_TM_P80],
        @"TM-T20":    [NSNumber numberWithInt:EPOS2_TM_T20],
        @"TM-T60":    [NSNumber numberWithInt:EPOS2_TM_T60],
        @"TM-T70":    [NSNumber numberWithInt:EPOS2_TM_T70],
        @"TM-T81":    [NSNumber numberWithInt:EPOS2_TM_T81],
        @"TM-T82":    [NSNumber numberWithInt:EPOS2_TM_T82],
        @"TM-T83":    [NSNumber numberWithInt:EPOS2_TM_T83],
        @"TM-T88":    [NSNumber numberWithInt:EPOS2_TM_T88],
        @"TM-T88VI":  [NSNumber numberWithInt:EPOS2_TM_T88],
        @"TM-T90":    [NSNumber numberWithInt:EPOS2_TM_T90],
        @"TM-T90KP":  [NSNumber numberWithInt:EPOS2_TM_T90KP],
        @"TM-U220":   [NSNumber numberWithInt:EPOS2_TM_U220],
        @"TM-U330":   [NSNumber numberWithInt:EPOS2_TM_U330],
        @"TM-L90":    [NSNumber numberWithInt:EPOS2_TM_L90],
        @"TM-H6000":  [NSNumber numberWithInt:EPOS2_TM_H6000],
		@"TM-T83III": [NSNumber numberWithInt:EPOS2_TM_T83III],
		@"TM-T100":   [NSNumber numberWithInt:EPOS2_TM_T100],
		@"TM-M30II":  [NSNumber numberWithInt:EPOS2_TM_M30II]
    };
    
    barcodeTypeMap = @{
        @"EPOS2_BARCODE_UPC_A":    [NSNumber numberWithInt:EPOS2_BARCODE_UPC_A],
        @"EPOS2_BARCODE_UPC_E":    [NSNumber numberWithInt:EPOS2_BARCODE_UPC_E],
        @"EPOS2_BARCODE_EAN13":    [NSNumber numberWithInt:EPOS2_BARCODE_EAN13],
        @"EPOS2_BARCODE_JAN13":    [NSNumber numberWithInt:EPOS2_BARCODE_JAN13],
        @"EPOS2_BARCODE_EAN8":  [NSNumber numberWithInt:EPOS2_BARCODE_EAN8],
        @"EPOS2_BARCODE_JAN8":    [NSNumber numberWithInt:EPOS2_BARCODE_JAN8],
        @"EPOS2_BARCODE_CODE39":    [NSNumber numberWithInt:EPOS2_BARCODE_CODE39],
        @"EPOS2_BARCODE_ITF":    [NSNumber numberWithInt:EPOS2_BARCODE_ITF],
        @"EPOS2_BARCODE_CODABAR":    [NSNumber numberWithInt:EPOS2_BARCODE_CODABAR],
        @"EPOS2_BARCODE_CODE93":    [NSNumber numberWithInt:EPOS2_BARCODE_CODE93],
        @"EPOS2_BARCODE_CODE128":    [NSNumber numberWithInt:EPOS2_BARCODE_CODE128],
        @"EPOS2_BARCODE_GS1_128":    [NSNumber numberWithInt:EPOS2_BARCODE_GS1_128],
        @"EPOS2_BARCODE_GS1_DATABAR_OMNIDIRECTIONAL":  [NSNumber numberWithInt:EPOS2_BARCODE_GS1_DATABAR_OMNIDIRECTIONAL],
        @"EPOS2_BARCODE_GS1_DATABAR_TRUNCATED":    [NSNumber numberWithInt:EPOS2_BARCODE_GS1_DATABAR_TRUNCATED],
        @"EPOS2_BARCODE_GS1_DATABAR_LIMITED":  [NSNumber numberWithInt:EPOS2_BARCODE_GS1_DATABAR_LIMITED],
        @"EPOS2_BARCODE_GS1_DATABAR_EXPANDED":   [NSNumber numberWithInt:EPOS2_BARCODE_GS1_DATABAR_EXPANDED]
    };

    langMap = @{
        @"EPOS2_MODEL_ANK":    [NSNumber numberWithInt:EPOS2_MODEL_ANK],
        @"EPOS2_MODEL_CHINESE":    [NSNumber numberWithInt:EPOS2_MODEL_CHINESE],
        @"EPOS2_MODEL_TAIWAN":    [NSNumber numberWithInt:EPOS2_MODEL_TAIWAN],
        @"EPOS2_MODEL_KOREAN":    [NSNumber numberWithInt:EPOS2_MODEL_KOREAN],
        @"EPOS2_MODEL_THAI":  [NSNumber numberWithInt:EPOS2_MODEL_THAI],
        @"EPOS2_MODEL_SOUTHASIA":  [NSNumber numberWithInt:EPOS2_MODEL_SOUTHASIA]
    };
    
    textLangMap = @{
        @"EPOS2_LANG_EN":    [NSNumber numberWithInt:EPOS2_LANG_EN],
        @"EPOS2_LANG_JA":    [NSNumber numberWithInt:EPOS2_LANG_JA],
        @"EPOS2_LANG_ZH_CN":    [NSNumber numberWithInt:EPOS2_LANG_ZH_CN],
        @"EPOS2_LANG_ZH_TW":    [NSNumber numberWithInt:EPOS2_LANG_ZH_TW],
        @"EPOS2_LANG_KO":    [NSNumber numberWithInt:EPOS2_LANG_KO],
        @"EPOS2_LANG_TH":    [NSNumber numberWithInt:EPOS2_LANG_TH],
        @"EPOS2_LANG_VI":    [NSNumber numberWithInt:EPOS2_LANG_VI],
        @"EPOS2_LANG_MULTI":    [NSNumber numberWithInt:EPOS2_LANG_MULTI],
        @"EPOS2_PARAM_DEFAULT":    [NSNumber numberWithInt:EPOS2_PARAM_DEFAULT]
    };

    symbolMap = @{
            @"EPOS2_SYMBOL_PDF417_STANDARD":    [NSNumber numberWithInt:EPOS2_SYMBOL_PDF417_STANDARD],
            @"EPOS2_SYMBOL_PDF417_TRUNCATED":    [NSNumber numberWithInt:EPOS2_SYMBOL_PDF417_TRUNCATED],
            @"EPOS2_SYMBOL_QRCODE_MODEL_1":    [NSNumber numberWithInt:EPOS2_SYMBOL_QRCODE_MODEL_1],
            @"EPOS2_SYMBOL_QRCODE_MODEL_2":    [NSNumber numberWithInt:EPOS2_SYMBOL_QRCODE_MODEL_2],
            @"EPOS2_SYMBOL_QRCODE_MICRO":    [NSNumber numberWithInt:EPOS2_SYMBOL_QRCODE_MICRO],
            @"EPOS2_SYMBOL_MAXICODE_MODE_2":  [NSNumber numberWithInt:EPOS2_SYMBOL_MAXICODE_MODE_2],
            @"EPOS2_SYMBOL_MAXICODE_MODE_3":    [NSNumber numberWithInt:EPOS2_SYMBOL_MAXICODE_MODE_3],
            @"EPOS2_SYMBOL_MAXICODE_MODE_5":    [NSNumber numberWithInt:EPOS2_SYMBOL_MAXICODE_MODE_5],
            @"EPOS2_SYMBOL_MAXICODE_MODE_6":    [NSNumber numberWithInt:EPOS2_SYMBOL_MAXICODE_MODE_6],
            @"EPOS2_SYMBOL_GS1_DATABAR_STACKED":    [NSNumber numberWithInt:EPOS2_SYMBOL_GS1_DATABAR_STACKED],
            @"EPOS2_SYMBOL_GS1_DATABAR_STACKED_OMNIDIRECTIONAL":    [NSNumber numberWithInt:EPOS2_SYMBOL_GS1_DATABAR_STACKED_OMNIDIRECTIONAL],
            @"EPOS2_SYMBOL_GS1_DATABAR_EXPANDED_STACKED":    [NSNumber numberWithInt:EPOS2_SYMBOL_GS1_DATABAR_EXPANDED_STACKED],
            @"EPOS2_SYMBOL_AZTECCODE_FULLRANGE":    [NSNumber numberWithInt:EPOS2_SYMBOL_AZTECCODE_FULLRANGE],
            @"EPOS2_SYMBOL_AZTECCODE_COMPACT":  [NSNumber numberWithInt:EPOS2_SYMBOL_AZTECCODE_COMPACT],
            @"EPOS2_SYMBOL_DATAMATRIX_SQUARE":    [NSNumber numberWithInt:EPOS2_SYMBOL_DATAMATRIX_SQUARE],
            @"EPOS2_SYMBOL_DATAMATRIX_RECTANGLE_8":  [NSNumber numberWithInt:EPOS2_SYMBOL_DATAMATRIX_RECTANGLE_8],
            @"EPOS2_SYMBOL_DATAMATRIX_RECTANGLE_12":   [NSNumber numberWithInt:EPOS2_SYMBOL_DATAMATRIX_RECTANGLE_12],
            @"EPOS2_SYMBOL_DATAMATRIX_RECTANGLE_16":   [NSNumber numberWithInt:EPOS2_SYMBOL_DATAMATRIX_RECTANGLE_16]
        };
    
    levelMap = @{
            @"EPOS2_LEVEL_0":    [NSNumber numberWithInt:EPOS2_LEVEL_0],
            @"EPOS2_LEVEL_1":    [NSNumber numberWithInt:EPOS2_LEVEL_1],
            @"EPOS2_LEVEL_2":    [NSNumber numberWithInt:EPOS2_LEVEL_2],
            @"EPOS2_LEVEL_3":    [NSNumber numberWithInt:EPOS2_LEVEL_3],
            @"EPOS2_LEVEL_4":  [NSNumber numberWithInt:EPOS2_LEVEL_4],
            @"EPOS2_LEVEL_5":    [NSNumber numberWithInt:EPOS2_LEVEL_5],
            @"EPOS2_LEVEL_6":    [NSNumber numberWithInt:EPOS2_LEVEL_6],
            @"EPOS2_LEVEL_7":    [NSNumber numberWithInt:EPOS2_LEVEL_7],
            @"EPOS2_LEVEL_8":    [NSNumber numberWithInt:EPOS2_LEVEL_8],
            @"EPOS2_PARAM_DEFAULT":    [NSNumber numberWithInt:EPOS2_PARAM_DEFAULT],
            @"EPOS2_LEVEL_L":    [NSNumber numberWithInt:EPOS2_LEVEL_L],
            @"EPOS2_LEVEL_M":    [NSNumber numberWithInt:EPOS2_LEVEL_M],
            @"EPOS2_LEVEL_Q":  [NSNumber numberWithInt:EPOS2_LEVEL_Q],
            @"EPOS2_LEVEL_H":    [NSNumber numberWithInt:EPOS2_LEVEL_H]
        };
}

-(void)setLang:(CDVInvokedUrlCommand *)command
{
    if ([command.arguments count] > 1) {
        NSString *arg = [command.arguments objectAtIndex:1];
        NSNumber *match = [textLangMap objectForKey:arg];
        self->textLang = [match intValue];
    }
    if ([command.arguments count] > 0) {
        NSString *arg = [command.arguments objectAtIndex:0];
        NSNumber *match = [langMap objectForKey:arg];
        self->lang = [match intValue];
    }
    
    CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    [self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
}

- (void)startDiscover:(CDVInvokedUrlCommand *)command
{
    self.discoverCallbackId = command.callbackId;
    
    // stop running discovery first
    int result = EPOS2_SUCCESS;
    
    while (YES) {
        result = [Epos2Discovery stop];
        
        if (result != EPOS2_ERR_PROCESSING) {
            break;
        }
    }
    
    NSLog(@"[epos2] startDiscover: %@", command.callbackId);
    
    Epos2FilterOption *filteroption_ = [[Epos2FilterOption alloc] init];
    [filteroption_ setDeviceType:EPOS2_TYPE_PRINTER];
    [filteroption_ setDeviceModel:EPOS2_MODEL_ALL];
    
    result = [Epos2Discovery start:filteroption_ delegate:self];
    if (EPOS2_SUCCESS != result) {
        NSLog(@"[epos2] Error in startDiscover()");
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00001: Printer discovery failed"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

- (void) onConnection:(id)deviceObj eventType:(int)eventType
{
	NSLog(@"[epos2] onConnection: %@ (%d)", deviceObj, eventType);
}

- (void) onDiscovery:(Epos2DeviceInfo *)deviceInfo
{
    NSLog(@"[epos2] onDiscovery: %@ (%@)", [deviceInfo getTarget], [deviceInfo getDeviceName]);
    NSDictionary *info = @{
        @"target": [deviceInfo getTarget],
        @"deviceType": [NSNumber numberWithInt:[deviceInfo getDeviceType]],
        @"deviceName": [deviceInfo getDeviceName],
        @"ipAddress" : [deviceInfo getIpAddress],
        @"macAddress": [deviceInfo getMacAddress],
        @"bdAddress": [deviceInfo getBdAddress],
    };
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:info];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:self.discoverCallbackId];
}

- (void)stopDiscover:(CDVInvokedUrlCommand *)command
{
    NSLog(@"[epos2] stopDiscover()");
    int result = EPOS2_SUCCESS;
    
    while (YES) {
        result = [Epos2Discovery stop];
        
        if (result != EPOS2_ERR_PROCESSING) {
            break;
        }
    }
    
    if (EPOS2_SUCCESS != result) {
        NSLog(@"[epos2] Error in stopDiscover()");
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00002: Stopping discovery failed."];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}


-(void)connectPrinter:(CDVInvokedUrlCommand *)command
{
    NSString *target = [command.arguments objectAtIndex:0];
    int typeEnum = -1;
    
    // device type is provided
    if ([command.arguments count] > 1) {
        // map device type string to EPOS2_* constant
        typeEnum = [self printerTypeFromString:[command.arguments objectAtIndex:1]];
        NSLog(@"[epos2] set printerSeries to %@ (%d)", [command.arguments objectAtIndex:1], typeEnum);
        if (typeEnum >= 0) {
            printerSeries = typeEnum;
        }
    }
    
    int result = EPOS2_SUCCESS;
    
    // select BT device from accessory list
    if ([target length] == 0) {
        Epos2BluetoothConnection *btConnection = [[Epos2BluetoothConnection alloc] init];
        NSMutableString *BDAddress = [[NSMutableString alloc] init];
        result = [btConnection connectDevice:BDAddress];
        if (result == EPOS2_SUCCESS) {
            target = BDAddress;
        } else {
            CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00010: Bluetooth connection failed"];
            [self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
            return;
        }
    }
    
    NSLog(@"[epos2] connectPrinter(%@)", target);
    
    // check for existing connection
    if (printer != nil && printerConnected && ![printerTarget isEqual:target]) {
        CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00011: Printer already connected"];
        [self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
        return;
    }
    
    // store the provided target addrss
    printerTarget = target;
    
    if ([self _connectPrinter]) {
        CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
        [self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
    } else {
        CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00012: Connecting printer failed"];
        [self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
    }
}

- (void)disconnectPrinter:(CDVInvokedUrlCommand *)command
{
    int result = EPOS2_SUCCESS;
    CDVPluginResult *cordovaResult = nil;

    NSLog(@"[epos2] disconnectPrinter(%@)", printer);
  
    if (printer == nil) {
        cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
        [self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
        return;
    }
    
    result = [printer endTransaction];
    if (result != EPOS2_SUCCESS) {
        NSLog(@"[epos2] Error in Epos2Printer.endTransaction(): %d", result);
        cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00020: Ending transaction failed"];
    }
    
    result = [printer disconnect];
    if (result != EPOS2_SUCCESS) {
        NSLog(@"[epos2] Error in Epos2Printer.disconnect(): %d", result);
        cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00021: Disconnecting printer failed"];
    }
    [self finalizeObject];
    
    // return OK result
    if (cordovaResult == nil) {
        cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    }
    
    if (command != nil) {
        [self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
    }
}

-(BOOL)_connectPrinter
{
    int result = EPOS2_SUCCESS;
    
    if (printerTarget == nil) {
        return NO;
    }
    
    if (printerConnected) {
        return YES;
    }
    
    NSLog(@"[epos2] _connectPrinter() to %@", printerTarget);
    
    // initialize printer
    if (printer == nil) {
        printer = [[Epos2Printer alloc] initWithPrinterSeries:printerSeries lang:lang];
        [printer setReceiveEventDelegate:self];
    }
    
    result = [printer connect:printerTarget timeout:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        NSLog(@"[epos2] Error in Epos2Printer.connect(): %d", result);
        return NO;
    }
    
    result = [printer beginTransaction];
    if (result != EPOS2_SUCCESS) {
        NSLog(@"[epos2] Error in Epos2Printer.beginTransaction(): %d", result);
        [printer disconnect];
        return NO;
    }
    
    printerConnected = YES;
    return YES;
}

- (void)finalizeObject
{
    if (printer == nil) {
        return;
    }
    
    [printer clearCommandBuffer];
    
    [printer setReceiveEventDelegate:nil];
    
    printerConnected = NO;
    printerStatus = nil;
    printer = nil;
}

- (void)onPtrReceive:(Epos2Printer *)printerObj code:(int)code status:(Epos2PrinterStatusInfo *)status printJobId:(NSString *)printJobId
{
    CDVPluginResult *cordovaResult;
    NSLog(@"[epos2] onPtrReceive; code: %d, status: %@, printJobId: %@", code, status, printJobId);
    
    // send callback for sendData command
    if (sendDataCallbackId != nil) {
        if (code == EPOS2_SUCCESS) {
            cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
        } else {
            cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00050: Print job failed. Check the device."];
        }
        [self.commandDelegate sendPluginResult:cordovaResult callbackId:sendDataCallbackId];
    }
}

- (void)printLine:(CDVInvokedUrlCommand *)command
{
    // read command arguments
    long x1 = 0;
    long x2 = 100;
    int style = 0;

    if ([command.arguments count] > 0) {
        x1 = ((NSNumber *)[command.arguments objectAtIndex:0]).intValue;
    }
    if ([command.arguments count] > 1) {
        x2 = ((NSNumber *)[command.arguments objectAtIndex:1]).intValue;
    }
    if ([command.arguments count] > 2) {
        style = ((NSNumber *)[command.arguments objectAtIndex:2]).intValue;
    }
    
    // (re-)connect printer with stored information
    if (![self _connectPrinter]) {
        CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00013: Printer is not connected"];
        [self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
        return;
    }
    
    NSString *printCallbackId = command.callbackId;
        
    [self.commandDelegate runInBackground:^{
        int result = EPOS2_SUCCESS;
        CDVPluginResult *cordovaResult;
        
        result = [self->printer addPageBegin];
        if (result == EPOS2_SUCCESS) {
            result = [self->printer addPageArea:0 y:0 width:600 height:6];
        }
        if (result == EPOS2_SUCCESS) {
            result = [self->printer addPageDirection:EPOS2_DIRECTION_LEFT_TO_RIGHT];
        }
        if (result == EPOS2_SUCCESS) {
            result = [self->printer addPagePosition:0 y:0];
        }
        if (result == EPOS2_SUCCESS) {
            result = [self->printer addPageLine:x1 y1:0 x2:x2 y2:0 style:style];
        }
        if (result == EPOS2_SUCCESS) {
            result = [self->printer addPageEnd];
        }

        if (result != EPOS2_SUCCESS) {
            NSLog(@"[epos2] Error in Epos2Printer.addHLine(): %d", result);
            cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00040: Failed to add line data"];
        } else {
            cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
        }
        
        [self.commandDelegate sendPluginResult:cordovaResult callbackId:printCallbackId];
    }];
}

- (void)sendData:(CDVInvokedUrlCommand *)command
{
	int result = EPOS2_SUCCESS;

	NSLog(@"[epos2] sendData()");
	
	// (re-)connect printer with stored information
	if (![self _connectPrinter]) {
		CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00013: Printer is not connected"];
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
		return;
	}
	
	sendDataCallbackId = command.callbackId;
	
	// send data to printer
	result = [printer sendData:EPOS2_PARAM_DEFAULT];
	if (result != EPOS2_SUCCESS) {
		NSLog(@"[epos2] Error in Epos2Printer.sendData(): %d", result);
		CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00050: Print job failed. Check the device."];
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
	}
}

-(void)clearCommandBuffer:(CDVInvokedUrlCommand *)command
{
	int result = EPOS2_SUCCESS;
	
	// (re-)connect printer with stored information
	if (![self _connectPrinter]) {
		CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00013: Printer is not connected"];
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
		return;
	}
	
	result = [printer clearCommandBuffer];
	if (result != EPOS2_SUCCESS) {
		NSLog(@"[epos2] Error in Epos2Printer.clearCommandBuffer(): %d", result);
		CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00060: Clearing command buffer failed"];
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
	} else {
		CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
	}
}

- (void)getPrinterStatus:(CDVInvokedUrlCommand *)command
{
    // (re-)connect printer with stored information
    if (![self _connectPrinter]) {
        CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00013: Printer is not connected"];
        [self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
        return;
    }
    
    // request printer status
    printerStatus = [printer getStatus];
    
    // translate status into a dict for returning
    NSDictionary *info = @{
        @"online": [NSNumber numberWithInt:printerStatus.online],
        @"connection": [NSNumber numberWithInt:printerStatus.connection],
        @"coverOpen": [NSNumber numberWithInt:printerStatus.coverOpen],
        @"paper": [NSNumber numberWithInt:printerStatus.paper],
        @"paperFeed": [NSNumber numberWithInt:printerStatus.paperFeed],
        @"errorStatus": [NSNumber numberWithInt:printerStatus.errorStatus],
        @"isPrintable": [NSNumber numberWithBool:[self isPrintable:printerStatus]]
    };
    
    NSLog(@"[epos2] getPrinterStatus(): %@", info);
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:info];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)getSupportedModels:(CDVInvokedUrlCommand *)command
{
    NSArray *types = [printerTypeMap allKeys];
    NSLog(@"[epos2] getSupportedModels(): %@", types);
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:types];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (BOOL)isPrintable:(Epos2PrinterStatusInfo *)status
{
    if (status == nil) {
        return NO;
    }
    
    if (status.connection == EPOS2_FALSE) {
        return NO;
    } else if (status.online == EPOS2_FALSE) {
        return NO;
    } else if (status.coverOpen == EPOS2_TRUE) {
        return NO;
    } else if (status.paper == EPOS2_PAPER_EMPTY) {
        return NO;
    } else if (status.errorStatus != EPOS2_NO_ERR) {
        return NO;
    } else {
        ; // printer is ready
    }
    
    return YES;
}

- (int)printerTypeFromString:(NSString*)type
{
    NSNumber *match = [printerTypeMap objectForKey:type];
    if (match != nil) {
        return [match intValue];
    } else {
        return -1;
    }
}

// ************************************************************************************************
- (void) addFeedLine:(CDVInvokedUrlCommand *)command
{
	int result = EPOS2_SUCCESS;
	int line = ((NSNumber *)[command.arguments objectAtIndex:0]).intValue;
	
	result = [printer addFeedLine:line];
	if (result != EPOS2_SUCCESS) {
		NSLog(@"[epos2] Error in Epos2Printer.addFeedLine(): %d", result);
		CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00030: Adding feed line failed"];
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
		return;
	}
	
	CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
	[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
}

- (void) addFeedPosition:(CDVInvokedUrlCommand *)command
{
	int result = EPOS2_SUCCESS;
	int position = ((NSNumber *)[command.arguments objectAtIndex:0]).intValue;
	
	result = [printer addFeedPosition:position];
	if (result != EPOS2_SUCCESS) {
		NSLog(@"[epos2] Error in Epos2Printer.addFeedPosition(): %d", result);
		CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00031: Adding feed position failed"];
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
		return;
	}
	
	CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
	[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];	
}

- (void)addTextAlign:(CDVInvokedUrlCommand *)command
{
	int result = EPOS2_SUCCESS;
	int align = ((NSNumber *)[command.arguments objectAtIndex:0]).intValue;
	
	result = [printer addTextAlign:align];
	if (result != EPOS2_SUCCESS) {
		NSLog(@"[epos2] Error in Epos2Printer.addTextAlign(): %d", result);
		CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00032: Adding text align failed"];
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
		return;
	}
	
	CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
	[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];	
}

- (void)addTextFont:(CDVInvokedUrlCommand *)command
{
	int result = EPOS2_SUCCESS;
	int font = ((NSNumber *)[command.arguments objectAtIndex:0]).intValue;
	
	result = [printer addTextFont:font];
	if (result != EPOS2_SUCCESS) {
		NSLog(@"[epos2] Error in Epos2Printer.addTextFont(): %d", result);
		CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00033: Adding text font failed"];
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
		return;
	}
	
	CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
	[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];	
}

- (void)addTextSize:(CDVInvokedUrlCommand *)command
{
	int result = EPOS2_SUCCESS;
	int width = ((NSNumber *)[command.arguments objectAtIndex:0]).intValue;
	int height = ((NSNumber *)[command.arguments objectAtIndex:1]).intValue;
	
	result = [printer addTextSize:width height:height];
	if (result != EPOS2_SUCCESS) {
		NSLog(@"[epos2] Error in Epos2Printer.addTextSize(): %d", result);
		CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00033: Adding text size failed"];
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
		return;
	}
	
	CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
	[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];	
}

- (void)addTextStyle:(CDVInvokedUrlCommand *)command
{
	// (re-)connect printer with stored information
    if (![self _connectPrinter]) {
        CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00013: Printer is not connected"];
        [self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
        return;
    }
	int reverse = ((NSNumber *)[command.arguments objectAtIndex:0]).intValue;
	int ul = EPOS2_PARAM_DEFAULT;
	int em = EPOS2_PARAM_DEFAULT;
	int color = EPOS2_PARAM_DEFAULT;

	    // read optional arguments
    if ([command.arguments count] > 1) {
		ul = ((NSNumber *)[command.arguments objectAtIndex:1]).intValue;
    }

    if ([command.arguments count] > 2) {
        em = ((NSNumber *)[command.arguments objectAtIndex:2]).intValue;
    }

    if ([command.arguments count] > 3) {
        color = ((NSNumber *)[command.arguments objectAtIndex:3]).intValue;
    }

	int result = EPOS2_SUCCESS;
	CDVPluginResult *cordovaResult = nil;
	
	result = [printer addTextStyle:reverse ul:ul em:em color:color];
	if (result != EPOS2_SUCCESS) {
		NSLog(@"[epos2] Error in Epos2Printer.addTextStyle(): %d", result);
		cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00030: Adding text style failed"];
	}
	
	// return OK result
	if (cordovaResult == nil) {
		cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
	}
	
	if (command != nil) {
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
	}

}

- (void)addHLine:(CDVInvokedUrlCommand *)command
{
	// read command arguments
    long x1 = ((NSNumber *)[command.arguments objectAtIndex:0]).intValue;
	long x2 = 100;
	int style = 0;
	
	if ([command.arguments count] > 1) {
		x2 = ((NSNumber *)[command.arguments objectAtIndex:1]).intValue;
	}
	if ([command.arguments count] > 2) {
		style = ((NSNumber *)[command.arguments objectAtIndex:2]).intValue;
	}
	
	// (re-)connect printer with stored information
	if (![self _connectPrinter]) {
		CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00013: Printer is not connected"];
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
		return;
	}
	
	NSString *printCallbackId = command.callbackId;
		
	[self.commandDelegate runInBackground:^{
		int result = EPOS2_SUCCESS;
		CDVPluginResult *cordovaResult;
		
        result = [self->printer addHLine:x1 x2:x2 style:style];
		
		if (result != EPOS2_SUCCESS) {
			NSLog(@"[epos2] Error in Epos2Printer.addHLine(): %d", result);
			cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00040: Failed to add line data"];
		} else {
			cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
		}
		
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:printCallbackId];
	}];
}

- (void)addLineSpace:(CDVInvokedUrlCommand *)command
{
	// read command arguments
	long space = ((NSNumber *)[command.arguments objectAtIndex:0]).intValue;
	
	// (re-)connect printer with stored information
	if (![self _connectPrinter]) {
		CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00013: Printer is not connected"];
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
		return;
	}
	
	NSString *printCallbackId = command.callbackId;
		
	[self.commandDelegate runInBackground:^{
		int result = EPOS2_SUCCESS;
		CDVPluginResult *cordovaResult;
		
        result = [self->printer addLineSpace:space];
		
		if (result != EPOS2_SUCCESS) {
			NSLog(@"[epos2] Error in Epos2Printer.addLineSpace(): %d", result);
			cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00040: Failed to add line space"];
		} else {
			cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
		}
		
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:printCallbackId];
	}];
}

- (void)addText:(CDVInvokedUrlCommand *)command
{
	// read command arguments
	NSString *data = [command.arguments objectAtIndex:0];
	
	// (re-)connect printer with stored information
	if (![self _connectPrinter]) {
		CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00013: Printer is not connected"];
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
		return;
	}
	
	NSString *printCallbackId = command.callbackId;
		
	[self.commandDelegate runInBackground:^{
		int result = EPOS2_SUCCESS;
		CDVPluginResult *cordovaResult;
		
        result = [self->printer addText:data];
		
		if (result != EPOS2_SUCCESS) {
			NSLog(@"[epos2] Error in Epos2Printer.addText(): %d", result);
			cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00040: Failed to add text data"];
		} else {
			cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
		}
		
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:printCallbackId];
	}];
}

- (void)addSymbol:(CDVInvokedUrlCommand *)command
{
    // read command arguments
    NSString *data = [command.arguments objectAtIndex:0];
    NSString *type = [command.arguments objectAtIndex:1];
    NSNumber *bType = [symbolMap objectForKey:type];
    NSNumber *level = [NSNumber numberWithInt:EPOS2_PARAM_DEFAULT];
    long width = 3;
    long height = 3;
    long size = 0;
    
    if ([command.arguments count] > 2) {
        NSString *levelStr = ((NSString *)[command.arguments objectAtIndex:2]);
        level = [levelMap objectForKey:levelStr];
    }
    if ([command.arguments count] > 3) {
        width = ((NSNumber *)[command.arguments objectAtIndex:3]).intValue;
    }
    if ([command.arguments count] > 4) {
        height = ((NSNumber *)[command.arguments objectAtIndex:4]).intValue;
    }
    if ([command.arguments count] > 5) {
        size = ((NSNumber *)[command.arguments objectAtIndex:5]).intValue;
    }

    // (re-)connect printer with stored information
    if (![self _connectPrinter]) {
        CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00013: Printer is not connected"];
        [self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
        return;
    }
    
    NSString *printCallbackId = command.callbackId;
        
    [self.commandDelegate runInBackground:^{
        int result = EPOS2_SUCCESS;
        CDVPluginResult *cordovaResult;
        
        result = [self->printer addSymbol:data
                                type:bType.intValue
                                level:level.intValue
                                width:width
                                height:height
                                size:size];
        if (result != EPOS2_SUCCESS) {
            NSLog(@"[epos2] Error in Epos2Printer.addSymbol(): %d", result);
            cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00040: Failed to add barcode data"];
        } else {
            cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
        }
        
        [self.commandDelegate sendPluginResult:cordovaResult callbackId:printCallbackId];
    }];
}

- (void)addPageBegin:(CDVInvokedUrlCommand *)command
{
	// (re-)connect printer with stored information
	if (![self _connectPrinter]) {
		CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00013: Printer is not connected"];
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
		return;
	}
	
	NSString *printCallbackId = command.callbackId;
		
	[self.commandDelegate runInBackground:^{
		int result = EPOS2_SUCCESS;
		CDVPluginResult *cordovaResult;
		
        result = [self->printer addPageBegin];
		
		if (result != EPOS2_SUCCESS) {
			NSLog(@"[epos2] Error in Epos2Printer.addPageBegin(): %d", result);
			cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00040: Failed to add page begin"];
		} else {
			cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
		}
		
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:printCallbackId];
	}];
}

- (void)addPageEnd:(CDVInvokedUrlCommand *)command
{
	// (re-)connect printer with stored information
	if (![self _connectPrinter]) {
		CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00013: Printer is not connected"];
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
		return;
	}
	
	NSString *printCallbackId = command.callbackId;
		
	[self.commandDelegate runInBackground:^{
		int result = EPOS2_SUCCESS;
		CDVPluginResult *cordovaResult;
		
        result = [self->printer addPageEnd];
		
		if (result != EPOS2_SUCCESS) {
			NSLog(@"[epos2] Error in Epos2Printer.addPageEnd(): %d", result);
			cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00040: Failed to add page end"];
		} else {
			cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
		}
		
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:printCallbackId];
	}];
}

- (void)addPageArea:(CDVInvokedUrlCommand *)command
{
	// read command arguments
	long x = ((NSNumber *)[command.arguments objectAtIndex:0]).intValue;
	long y = ((NSNumber *)[command.arguments objectAtIndex:1]).intValue;
	long width = ((NSNumber *)[command.arguments objectAtIndex:2]).intValue;
	long height = ((NSNumber *)[command.arguments objectAtIndex:3]).intValue;
	
	// (re-)connect printer with stored information
	if (![self _connectPrinter]) {
		CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00013: Printer is not connected"];
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
		return;
	}
	
	NSString *printCallbackId = command.callbackId;
		
	[self.commandDelegate runInBackground:^{
		int result = EPOS2_SUCCESS;
		CDVPluginResult *cordovaResult;
		
        result = [self->printer addPageArea:x y:y width:width height:height];
		
		if (result != EPOS2_SUCCESS) {
			NSLog(@"[epos2] Error in Epos2Printer.addPageArea(): %d", result);
			cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00040: Failed to add page area"];
		} else {
			cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
		}
		
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:printCallbackId];
	}];
}

- (void)addPageDirection:(CDVInvokedUrlCommand *)command
{
	// read command arguments
	int direction = ((NSNumber *)[command.arguments objectAtIndex:0]).intValue;
	
	// (re-)connect printer with stored information
	if (![self _connectPrinter]) {
		CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00013: Printer is not connected"];
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
		return;
	}
	
	NSString *printCallbackId = command.callbackId;
		
	[self.commandDelegate runInBackground:^{
		int result = EPOS2_SUCCESS;
		CDVPluginResult *cordovaResult;
		
        result = [self->printer addPageDirection:direction];
		
		if (result != EPOS2_SUCCESS) {
			NSLog(@"[epos2] Error in Epos2Printer.addPageDirection(): %d", result);
			cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00040: Failed to add page direction"];
		} else {
			cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
		}
		
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:printCallbackId];
	}];
}

- (void)addPagePosition:(CDVInvokedUrlCommand *)command
{
	// read command arguments
	long x = ((NSNumber *)[command.arguments objectAtIndex:0]).intValue;
	long y = ((NSNumber *)[command.arguments objectAtIndex:1]).intValue;
	
	// (re-)connect printer with stored information
	if (![self _connectPrinter]) {
		CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00013: Printer is not connected"];
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
		return;
	}
	
	NSString *printCallbackId = command.callbackId;
		
	[self.commandDelegate runInBackground:^{
		int result = EPOS2_SUCCESS;
		CDVPluginResult *cordovaResult;
		
        result = [self->printer addPagePosition:x y:y];
		
		if (result != EPOS2_SUCCESS) {
			NSLog(@"[epos2] Error in Epos2Printer.addPagePosition(): %d", result);
			cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00040: Failed to add page position"];
		} else {
			cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
		}
		
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:printCallbackId];
	}];
}

- (void)addPageLine:(CDVInvokedUrlCommand *)command
{
	// read command arguments
	long x1 = ((NSNumber *)[command.arguments objectAtIndex:0]).intValue;
	long y1 = ((NSNumber *)[command.arguments objectAtIndex:1]).intValue;
	long x2 = 100;
	long y2 = 100;
	int style = 0;
	
	if ([command.arguments count] > 2) {
		x2 = ((NSNumber *)[command.arguments objectAtIndex:2]).intValue;
	}
	if ([command.arguments count] > 3) {
		y2 = ((NSNumber *)[command.arguments objectAtIndex:3]).intValue;
	}
	if ([command.arguments count] > 4) {
		style = ((NSNumber *)[command.arguments objectAtIndex:4]).intValue;
	}
	
	// (re-)connect printer with stored information
	if (![self _connectPrinter]) {
		CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00013: Printer is not connected"];
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
		return;
	}
	
	NSString *printCallbackId = command.callbackId;
		
	[self.commandDelegate runInBackground:^{
		int result = EPOS2_SUCCESS;
		CDVPluginResult *cordovaResult;
		
        result = [self->printer addPageLine:x1 y1:y1 x2:x2 y2:y2 style:style];
		
		if (result != EPOS2_SUCCESS) {
			NSLog(@"[epos2] Error in Epos2Printer.addPageLine(): %d", result);
			cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00040: Failed to add line data"];
		} else {
			cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
		}
		
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:printCallbackId];
	}];
}

//- (void)addPageRectangle:(CDVInvokedUrlCommand *)command
//{
//	// read command arguments
//	long x = ((NSNumber *)[command.arguments objectAtIndex:0]).intValue;
//	long y = ((NSNumber *)[command.arguments objectAtIndex:1]).intValue;
//	long width = ((NSNumber *)[command.arguments objectAtIndex:2]).intValue;
//	long height = ((NSNumber *)[command.arguments objectAtIndex:3]).intValue;
//	int style = 0;
//
//	if ([command.arguments count] > 4) {
//		style = ((NSNumber *)[command.arguments objectAtIndex:4]).intValue;
//	}
//
//	// (re-)connect printer with stored information
//	if (![self _connectPrinter]) {
//		CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00013: Printer is not connected"];
//		[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
//		return;
//	}
//
//	NSString *printCallbackId = command.callbackId;
//
//	[self.commandDelegate runInBackground:^{
//		int result = EPOS2_SUCCESS;
//		CDVPluginResult *cordovaResult;
//
//		result = [printer addPageRectangle:x y:y width:width height:height style:style];
//
//		if (result != EPOS2_SUCCESS) {
//			NSLog(@"[epos2] Error in Epos2Printer.addPageRectangle(): %d", result);
//			cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00040: Failed to add page rectangle"];
//		} else {
//			cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
//		}
//
//		[self.commandDelegate sendPluginResult:cordovaResult callbackId:printCallbackId];
//	}];
//}

- (void)addCut:(CDVInvokedUrlCommand *)command
{
	int result = EPOS2_SUCCESS;
	int type = ((NSNumber *)[command.arguments objectAtIndex:0]).intValue;
	
	NSLog(@"[epos2] addCut(%d)", type);
	
	result = [printer addCut:type];
	if (result != EPOS2_SUCCESS) {
		NSLog(@"[epos2] Error in Epos2Printer.addCut(): %d", result);
		CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00032: Adding cut failed"];
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
		return;
	}
	
	CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
	[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];	
}

- (void)addPulse:(CDVInvokedUrlCommand *)command
{
	// (re-)connect printer with stored information
	if (![self _connectPrinter]) {
		CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00013: Printer is not connected"];
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
		return;
	}
	int drawer = ((NSNumber *)[command.arguments objectAtIndex:0]).intValue;
	int time = ((NSNumber *)[command.arguments objectAtIndex:1]).intValue;
	
	NSLog(@"[epos2] addPulse(%d, %d)", drawer, time);
	
	int result = [printer addPulse:drawer time:time];
	if (result != EPOS2_SUCCESS) {
		NSLog(@"[epos2] Error in Epos2Printer.addPulse(): %d", result);
		CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error 0x00014: Adding pulse failed"];
		[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
		return;
	}
	
	CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
	[self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
}

@end
