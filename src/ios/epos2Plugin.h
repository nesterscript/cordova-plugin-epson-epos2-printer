#import <Cordova/CDVPlugin.h>
#import "ePOS2.h"

@interface epos2Plugin : CDVPlugin
{
	Epos2Printer *printer;
	Epos2PrinterStatusInfo *printerStatus;
	NSString *sendDataCallbackId;
	NSString *printerTarget;
	BOOL printerConnected;
	int printerSeries;
	int lang;
	int textLang;
}

@property(nonatomic, strong) NSString *discoverCallbackId;

// The hooks for our plugin commands
- (void)setLang:(CDVInvokedUrlCommand *)command;
- (void)startDiscover:(CDVInvokedUrlCommand *)command;
- (void)stopDiscover:(CDVInvokedUrlCommand *)command;
- (void)connectPrinter:(CDVInvokedUrlCommand *)command;
- (void)disconnectPrinter:(CDVInvokedUrlCommand *)command;
- (void)printLine:(CDVInvokedUrlCommand *)command;
- (void)sendData:(CDVInvokedUrlCommand *)command;

- (void)addTextAlign:(CDVInvokedUrlCommand *)command;
- (void)addLineSpace:(CDVInvokedUrlCommand *)command;
- (void)addTextFont:(CDVInvokedUrlCommand *)command;
- (void)addTextSize:(CDVInvokedUrlCommand *)command;
- (void)addTextStyle:(CDVInvokedUrlCommand *)command;

- (void)addHLine:(CDVInvokedUrlCommand *)command;
- (void)addFeedLine:(CDVInvokedUrlCommand *)command;
- (void)addFeedPosition:(CDVInvokedUrlCommand *)command;
- (void)addText:(CDVInvokedUrlCommand *)command;

- (void)addSymbol:(CDVInvokedUrlCommand *)command;

- (void)addPageBegin:(CDVInvokedUrlCommand *)command;
- (void)addPageEnd:(CDVInvokedUrlCommand *)command;
- (void)addPageArea:(CDVInvokedUrlCommand *)command;
- (void)addPageDirection:(CDVInvokedUrlCommand *)command;
- (void)addPagePosition:(CDVInvokedUrlCommand *)command;
- (void)addPageLine:(CDVInvokedUrlCommand *)command;
- (void)addPageRectangle:(CDVInvokedUrlCommand *)command;

- (void)addCut:(CDVInvokedUrlCommand *)command;
- (void)addPulse:(CDVInvokedUrlCommand *)command;
@end
