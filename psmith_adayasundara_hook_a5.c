/*
* Programmer          : Paul Smith & Amy Dayasundara
* Course code         : SENG2010
* Date of Submission  : 2019-11-27
* Description         : This file contains the C code for the psadA5
*                       function and psadWatch test
*/

#include <stdio.h>
#include <stdint.h>
#include <ctype.h>
#include "stm32f3xx_hal.h"
#include "stm32f3_discovery.h"
#include "stm32f3_discovery_accelerometer.h"
#include "stm32f3_discovery_gyroscope.h"
#include "common.h"
//#include "main.c"

//global variable for game
extern volatile uint32_t gameCount;


void psadGame(int timer, char *range, int target);
void mes_InitIWDG(int countDown);
void mes_IWDGStart();
void lightShow();
void watchFunc(int timer, int count);


//int noDelay(int timer);
//  int tilt(int timer, char *range, char *target); Old version

void psadA5(int action)
{
  if(action==CMD_SHORT_HELP) return;
  if(action==CMD_LONG_HELP) {
    printf("Game Test\n\n"
   "This command tests new game function\n"
   );
    return;
    }

    //first parameter of game function is gathered (timer value)
    uint32_t timer;
    int fetch_status;
    fetch_status = fetch_uint32_arg(&timer);
    if(fetch_status) {
      timer = 300;
    }

    //second parameter of game function is gathered (range of game numbers)
    char *range;
    fetch_status = fetch_string_arg(&range);
    if(fetch_status) {
      range = "12345678";
    }

    //third parameter of game function is gathered (target value)
    uint32_t target;
    fetch_status = fetch_uint32_arg(&target);
    if(fetch_status) {
      target = 2;
    }

    //game function is called with necessary parameters
    psadGame(timer, range, target);
}

void psadWatch(int action)
{
  uint32_t timer;
  int fetch_status;
  fetch_status = fetch_uint32_arg(&timer);
  if(fetch_status) {
    timer = 250; //defaults to 500ms
  }

  uint32_t count;
  fetch_status = fetch_uint32_arg(&count);
  if(fetch_status) {
    count = 500; //defaults to 500ms
  }
  mes_InitIWDG(count);
  mes_IWDGStart();
  watchFunc(timer, count);
}

void lightTest()
{
  lightShow();
}

ADD_CMD("psadA5", psadA5,"Test the new tilt game function")
ADD_CMD("psadWatch", psadWatch, "Test the watchdog feature")
