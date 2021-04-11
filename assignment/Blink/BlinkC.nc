 // BlinkC.nc 模块组件
#include "Timer.h"

module BlinkC @safe()
{
  //声明该程序需要用到的全部接口
  uses interface Timer<TMilli> as Timer0;
  uses interface Timer<TMilli> as Timer1;
  uses interface Timer<TMilli> as Timer2;
  uses interface Leds;
  uses interface Boot;
}
//    在实现部分，需要实现所有我们用到的接口的事件，在这个程序
// 里，我们只是使用了接口，而作为这些接口的用户，我们只需要负责
// 去实现他们的时间，这些接口内的命令，则由接口的提供者负责实现

implementation
{
  //event时间必须在使用方中实现

// 这里主要是两个事件，一个是Boot接口的booted事件，另一个是
// 计时器被触发的fired事件，在booted事件中，也就是程序启动之//后， 我们的主要任务就一个，启动三个计时器：
// 三个计时器分别是每一秒，每两秒，每三秒


//     这里面startPeriodic是一个启动计时器的命令，
// 呼叫命令需要使用call关键字。因为是命令，所以它们由
// 接口的提供者负责实现，我们只负责使用。另一个需要我们处理的
// 事件就是计时器的触发，因为有三个计时器，所以要三个触发事件
  event void Boot.booted()
  {
    call Timer0.startPeriodic( 1000 );
    call Timer1.startPeriodic( 2000 );
    call Timer2.startPeriodic( 4000 );
  }

// （1）触发事件1：
  event void Timer0.fired()
  {
    dbg("BlinkC", "Timer 0 fired @ %s.\n", sim_time_string());
    // 切换0号发光二极管的状态，亮的变灭，灭的点亮
    // led0Toggle属于Leds接口的三个命令，用call即可
    call Leds.led0Toggle();
  }
 
// （2）触发事件2：

  event void Timer1.fired()
  {
    dbg("BlinkC", "Timer 1 fired @ %s \n", sim_time_string());
    call Leds.led1Toggle();
  }
 
// （3）触发事件3：

  event void Timer2.fired()
  {
    dbg("BlinkC", "Timer 2 fired @ %s.\n", sim_time_string());
    call Leds.led2Toggle();
  }
}