//BlinkAppC.nc 配置
// 这个组件本身并不使用或者提供任何接口，所以在其声明部分为空
configuration BlinkAppC
{
}
/* 而在实现部分则需要实现对组件的连接，因为BlinkC模块使用了
   Boot，Leds和Timer接口，所以必须指明这些接口都是由其他哪些
 组件提供的，所以 */

implementation
{
/*   先用component关键字标明程序中总共需要用到哪几个组件。其中
   包括我们自己编写的BlinkC模块。还有负责提供Boot接口的
   MainC组件，负责提供Leds接口的LedsC组件。还有提供Boot
   接口的Tim而MillIC，其属于泛型配置，支持被实例化。 
   因为我们需要用到三个计时器，所以需要使用new 关键字
*/

components MainC, BlinkC, LedsC;

/* 需要三个精度为毫秒（TMilli）的计时器接口（Timer）
   分别使用as关键字重命名为Timer0，1，2. */

components new TimerMilliC() as Timer0;
components new TimerMilliC() as Timer1;
components new TimerMilliC() as Timer2;

/* 接口的使用方和提供方声明	 	 
    组件提供的，所以件间的连接。BlinkC使用了Boot接口，而MainC正好提供了
 BlinkC所需的Boot接口，所以我们将他们进行连接。箭头所指向方向为使用者指向提供者。   
 */

BlinkC.Boot -> MainC.Boot; // 程序启动负责初始化的接口Boot

// 计数器的连接
BlinkC.Timer0 -> Timer0;
BlinkC.Timer1 -> Timer1;
BlinkC.Timer2 -> Timer2;

// 既然需要点亮发光二极管，自然需要一个操控发光二极管的接口，leds
BlinkC.Leds -> LedsC.leds;
}
