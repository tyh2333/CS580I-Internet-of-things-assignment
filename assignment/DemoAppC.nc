#include "DemoMessage.h" 
#define NEW_PRINTF_SEMANTICS
#include "printf.h"
configuration DemoAppC{} 
/* 而在实现部分则需要实现对组件的连接，因为BlinkC模块使用了
   Boot，Leds和Timer接口，所以必须指明这些接口都是由其他哪些
 组件提供的，所以 */
implementation
{
	// General
	components DemoP, MainC, LedsC;
	DemoP.Boot -> MainC;
	DemoP.Leds -> LedsC;
	
	// Timers
	components new TimerMilliC() as Timer_tem;
	components new TimerMilliC() as Timer_lig;
	components new TimerMilliC() as Timer_hum;
	DemoP.Timer_tem -> Timer_tem;
	DemoP.Timer_lig -> Timer_lig;
	DemoP.Timer_hum -> Timer_hum;

	// Temperature and Humidity
	components new SensirionSht11C() as TempAndHumid;
	DemoP.TemRead -> TempAndHumid.Temperature;
	DemoP.HumRead -> TempAndHumid.Humidity;

	// Light
	components new HamamatsuS10871TsrC() as LightSensor;
	DemoP.LigRead -> LightSensor;

	// Radio Send and Receive 
	components ActiveMessageC; // 无线数据发送
	// AMSenderC provides AMSend interface
	components new AMSenderC(AM_DEMO_MESSAGE);//AM_DEMO_MESSAGE defined in DemoMessage.h
	DemoP.RadioAMSend -> AMSenderC;

	// AMReceiverC provides Receive interface
	components new AMReceiverC(AM_DEMO_MESSAGE);//AM_DEMO_MESSAGE defined in DemoMessage.h
	DemoP.Receive -> AMReceiverC;
	DemoP.Packet 	   -> ActiveMessageC;
	DemoP.RadioControl -> ActiveMessageC;

	// for printf
	components PrintfC;
	components SerialStartC;
}



