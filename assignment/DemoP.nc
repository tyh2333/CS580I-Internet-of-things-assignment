#include "DemoMessage.h"
#include <stdio.h>
#include "printf.h"
#include <Timer.h>
#include <string.h>
module DemoP
{// 声明该程序需要用到的全部接口
	uses { // General
		interface Boot;
		interface Leds;
	} 
	uses { //Timers
	    interface Timer<TMilli> as Timer_tem; // every 1 sec
  		interface Timer<TMilli> as Timer_lig; // every 2 sec
  		interface Timer<TMilli> as Timer_hum; // every 4 sec
	}
	uses { //  Sensors For Reading tem, light, hum
		interface Read<uint16_t> as TemRead;
		interface Read<uint16_t> as LigRead;
		interface Read<uint16_t> as HumRead;
	}
	uses { // Networking
		interface Packet; // manage data packet
		interface AMSend as RadioAMSend;
		interface SplitControl as RadioControl;
		interface Receive; // provide by ActiveMessageC, for receiving data	 
	}
}
implementation
{
	bool Busy = FALSE; // 表示天线是否忙碌
	message_t pkt; // mote1 发送的数据包
	uint16_t centigrade, humidity, luminance;
	uint8_t temBool, ligBool, humBool;
	message_t *receivedBuf; // mote2 收到的数据包
	
	task void sendPacket(); // send package
	/*****************************************************/
					// 1.Boot
	/*****************************************************/
	event void Boot.booted() {
		call RadioControl.start(); // two mote both need to turn on radio
		if(TOS_NODE_ID == 1)
		{	// if TOS_NODE_ID == 1: call Timers，only mote1 read
			call Timer_tem.startPeriodic( 1000 );
   			call Timer_lig.startPeriodic( 2000 );
   			call Timer_hum.startPeriodic( 4000 );
		}
	}
	/*****************************************************/
					// 2. RadioControl 
	/*****************************************************/
	event void RadioControl.startDone(error_t err) 
	{
		if(err != SUCCESS) call RadioControl.start();//if failed, redo	
	}
	// Do nothing in stopDone, but must implement.
	event void RadioControl.stopDone(error_t err){}
	/*****************************************************/
					// 3. Timers
	/*****************************************************/
	event void Timer_tem.fired() {
	    call TemRead.read();
	}
	event void Timer_lig.fired() {
		call LigRead.read();
	}
	event void Timer_hum.fired() {
		call HumRead.read();
	}
	/*****************************************************/
					// 4. TemRead readDone
	/*****************************************************/

	event void TemRead.readDone(error_t result, uint16_t val){
		centigrade = val; 
 		temBool = TRUE;
		ligBool = FALSE; 
 		humBool = FALSE;
    	call Leds.led0Toggle(); 
 		post sendPacket();// using task to send data
	}
	/*****************************************************/
					// 5. LigRead readDone
	/*****************************************************/
	event void LigRead.readDone(error_t result, uint16_t val){
		luminance = val; 
 		temBool = FALSE;
 		ligBool = TRUE; 
		humBool = FALSE;
 		call Leds.led1Toggle();
 		post sendPacket();// using task to send data
	}
	/*****************************************************/
					// 6. HumRead readDone
	/*****************************************************/
	event void HumRead.readDone(error_t result, uint16_t val){
		humidity = val;
 		temBool = FALSE;
 		ligBool = FALSE; 
 		humBool = TRUE;
 		call Leds.led2Toggle();
 		post sendPacket();// using task to send data
	}
	/*****************************************************/
					// 8. tasks : sendPacket
	/*****************************************************/
	task void sendPacket() // similar to functions，call by cmd 'post'
	{
		if (Busy == FALSE) {
            // Create Packet
            demo_pkt* msg = call Packet.getPayload(& pkt, sizeof(demo_pkt));
            msg->tem = centigrade;
            msg->lig = luminance;
            msg->hum = humidity;
            msg->temBool = temBool;
            msg->ligBool = ligBool;
            msg->humBool = humBool;
			// Send Packet
            if (call RadioAMSend.send(2,
            	&pkt, sizeof(demo_pkt)) == SUCCESS) {
                Busy = TRUE;
            }
        }
	}
	/*****************************************************/
					// 9. RadioAMSend.SendDone
	/*****************************************************/
	event void RadioAMSend.sendDone(message_t * msg, error_t err)
	{
		if(err != SUCCESS)
			post sendPacket(); // resent if failed.
		else
			Busy = FALSE; // After sendDone, we need to change busy flag
	}
	/*****************************************************/
						// 10. Receive 
	/*****************************************************/
	/*
	* @param  'message_t* ONE msg'        the receied packet
    * @param  'void* COUNT(len) payload'  a pointer to the packet's payload
    * @param  len      the length of the data region pointstack to use for the next
    *                  received packet.ed to by payload
    * @return 'message_t* ONE'        a packet buffer for the 
	*/
	event message_t * Receive.receive(message_t * msg, void * payload, uint8_t len)
	{
		demo_pkt * newPayload = (demo_pkt *)payload; 
		// 收到不同的值toggle对应的led
		if(newPayload->temBool == TRUE){
			printf("cur tem is %u\r\n", newPayload->tem);
    		call Leds.led0Toggle();// means tem is new, toggle after transmission
		}
		if(newPayload->ligBool == TRUE){
			printf("cur lig is %u \r\n", newPayload->lig);
    		call Leds.led1Toggle();// means lig is new, toggle after transmission
		}
		if(newPayload->humBool == TRUE){
			printf("cur hum is %u \r\n", newPayload->hum);
    		call Leds.led2Toggle();// means hum is new,toggle after transmission
		}
		printfflush();
		receivedBuf = msg;
		return msg; 
	}
}