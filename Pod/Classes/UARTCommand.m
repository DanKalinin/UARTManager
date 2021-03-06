//
//  UARTCommand.m
//  UART
//
//  Created by Dan Kalinin on 14.09.15.
//  Copyright (c) 2015 Dan Kalinin. All rights reserved.
//

#import "UARTCommand.h"
#include <mach/mach_time.h>



@interface UARTCommand ()

@property UARTPacket *RXPacket;
@property BOOL executing;
@property NSError *error;
@property CBPeripheral *peripheral;
@property (copy) UARTCommandHandler success;
@property (copy) UARTCommandHandler failure;
@property (copy) UARTCommandHandler completion;
@property NSTimeInterval timeout;
@property NSTimer *timer;
@property dispatch_time_t startTime;
@property uint64_t time;
@property NSInteger seq;

@end



@implementation UARTCommand

- (instancetype)init {
    self = [super init];
    if (self) {
        static NSInteger seq = 0;
        self.seq = seq++;
    }
    return self;
}

- (void)sendToPeripheral:(CBPeripheral *)peripheral success:(UARTCommandHandler)success failure:(UARTCommandHandler)failure completion:(UARTCommandHandler)completion timeout:(NSTimeInterval)timeout {
    self.peripheral = peripheral;
    self.success = success;
    self.failure = failure;
    self.completion = completion;
    self.timeout = timeout;

    [self.peripheral.queue addObject:self];
    
    if (self.peripheral.queue.count == 1) {
        [self send];
    } else {
        NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"executing" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"seq" ascending:YES]];
        [self.peripheral.queue sortUsingDescriptors:sortDescriptors];
        
        if (self.deletePrevious) {
            NSInteger index = [self.peripheral.queue indexOfObject:self];
            if (index > 1) {
                index--;
                typeof(self) previousCommand = self.peripheral.queue[index];
                if ([previousCommand isEqualToCommand:self]) {
                    [self.peripheral.queue removeObjectAtIndex:index];
                }
            }
        }
    }
}

- (BOOL)isEqualToCommand:(UARTCommand *)command {
    return [NSStringFromClass([self class]) isEqualToString:NSStringFromClass([command class])];
}

- (BOOL)isRXPacket:(UARTPacket *)RXPacket responseToTXPacket:(UARTPacket *)TXPacket {
    return YES;
}

- (void)send {
    UARTCommand *command = self.peripheral.queue.firstObject;
    if (command) {
        command.executing = YES;
        command.startTime = mach_absolute_time();
        if ([command.peripheral writePacket:command.TXPacket]) {
            command.timer = [NSTimer scheduledTimerWithTimeInterval:command.timeout target:command selector:@selector(timeoutExpired) userInfo:nil repeats:NO];
            __weak typeof(command) cmd = command;
            command.peripheral.onPacketReceived = ^(UARTPacket *packet) {
                [cmd.timer invalidate];
                if ([cmd isRXPacket:packet responseToTXPacket:cmd.TXPacket]) {
                    cmd.RXPacket = packet;
                    [cmd finishWithSuccess:YES];
                } else {
                    cmd.error = [NSError UARTCommandRXTXPacketsMismatchError];
                    [cmd finishWithSuccess:NO];
                }
            };
        } else {
            command.error = command.TXPacket.error;
            [command finishWithSuccess:NO];
        }
    }
}

- (void)timeoutExpired {
    self.error = [NSError UARTCommandTimeoutExpirationError];
    [self finishWithSuccess:NO];
}

- (void)finishWithSuccess:(BOOL)success {
    if (self.peripheral.queue.count) {
        
        mach_timebase_info_data_t info;
        mach_timebase_info(&info);
        uint32_t k = info.numer / info.denom;
        self.time = k * (mach_absolute_time() - self.startTime);
        
        if (success) {
            self.error = nil;
            !self.success ? : self.success(self);
        } else {
            self.RXPacket = nil;
            !self.failure ? : self.failure(self);
        }
        !self.completion ? : self.completion(self);
        
        self.success = nil;
        self.failure = nil;
        self.completion = nil;
        self.peripheral.onPacketReceived = nil;
        [self.peripheral.queue removeObjectAtIndex:0];
        self.executing = NO;
        [self send];
    }
}

@end
