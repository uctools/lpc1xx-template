/* Un-comment DEBUG_ENABLE for IO support via the UART */
//#define DEBUG_ENABLE

/* Enable DEBUG_SEMIHOSTING along with DEBUG to enable IO support
   via semihosting */
//#define DEBUG_SEMIHOSTING

/* Board UART used for debug output */
#define DEBUG_UART LPC_USART

/* Crystal frequency into device */
#define CRYSTAL_MAIN_FREQ_IN (12000000)

/* Frequency on external clock in pin (not applicable to LPC11Uxx) */
#define EXTCLKIN_FREQ_IN (0)
