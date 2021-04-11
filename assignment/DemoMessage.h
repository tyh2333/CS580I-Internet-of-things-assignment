#ifndef __DEMOAPP_H
#define __DEMOAPP_H
enum{ AM_DEMO_MESSAGE = 150 };
typedef nx_struct demo_message
{
	nx_uint16_t NodeId;
 	nx_uint16_t tem;
  	nx_uint16_t lig;
  	nx_uint16_t hum;
  	nx_uint16_t temBool;
  	nx_uint16_t ligBool;
  	nx_uint16_t humBool;

} demo_pkt;
#endif // __DEMOAPP_H