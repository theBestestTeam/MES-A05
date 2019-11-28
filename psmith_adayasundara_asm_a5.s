@  Programmer          : Paul Smith & Amy Dayasundara
@  Course code         : SENG2010
@  Date of Submission  : 2019-11-27
@  Description         : This file contains the assembly code for the blinking
@                        lights game function and the watchdog test function.


  .code   16              @ This directive selects the instruction set being generated.
                          @ The value 16 selects Thumb, with the value 32 selecting ARM.

  .text                   @ Tell the assembler that the upcoming section is to be considered
                          @ assembly language instructions - Code section (text -> ROM)


@ Function Declaration : int psadGame (int timer, char *range, char *target)
@ Description:
@
@ Input:                 r0, r1, r2 (r0 holds timer, r1 holds range, r2 holds target)
@ Returns:               none

@@ Function Header Block
  .align  2               @ Code alignment - 2^n alignment (n=2)
                          @ This causes the assembler to use 4 byte alignment

  .syntax unified         @ Sets the instruction set to the new unified ARM + THUMB
                          @ instructions. The default is divided (separate instruction sets)

  .global psadGame        @ Make the symbol name for the function visible to the linker

  .code   16              @ 16bit THUMB code (BOTH .code and .thumb_func are required)
  .thumb_func             @ Specifies that the following symbol is the name of a THUMB
                          @ encoded function. Necessary for interlinking between ARM and THUMB code.

psadGame:

  push {lr}                 @ lr value pushed to stack to account for function call

  ldr  r3, =timer           @ location of timer global variable stored in r3
  str  r0, [r3]             @ value stored into variable for later use

  ldr  r3, =range           @ location of range global variable stored in r3
  str  r1, [r3]             @ value stored into variable for later use

  ldr  r3, =rangeReset      @ location of rangeReset global variable stored in r3
  str  r1, [r3]             @ value stored into variable to reset range later

  ldr  r3, =target          @ location of target global variable stored in r3
  str  r2, [r3]             @ value stored into variable for later use

  ldr r3, =lastOn           @ location of lastOn global variable stored in r3
  mov r0, #1                @ value set to 1 for start of game function
  str r0, [r3]              @ value stored into variable for later use

  ldr r3, =gameTick         @ location of target global variable stored in r3
  mov r0, #0                @ value set to 0 to reset for start of game
  str r0, [r3]              @ value stored into variable for later use

  ldr r3, =lightCheck       @ location of target global variable stored in r3
  mov r0, #0                @ value set to 0 to reset for start of game
  str r0, [r3]              @ value stored into variable for later use

  ldr r3, =loseCheck        @ location of target global variable stored in r3
  mov r0, #0                @ value set to 0 to reset for start of game
  str r0, [r3]              @ value stored into variable for later use

  ldr  r3, =gameOn          @ location of gameOn global variable stored in r3
  mov r0, #1                @ value of 1 moved into register 0
  str  r0, [r3]             @ variable set to 1 to activate game mode

exit:                       @ exits to end of function
  pop {lr}                  @ link register restored to value from start of function
  bx lr                     @ Return (Branch eXchange) to the address in the link register (lr)

@@@@@@@
@ Function Declaration : void lightCalc()
@ Description:           function for activation of lights in a sequential order.
@
@ Input:                 none
@ Returns:               none

@@ Function Header Block
  .align  2               @ Code alignment - 2^n alignment (n=2)
                          @ This causes the assembler to use 4 byte alignment

  .syntax unified         @ Sets the instruction set to the new unified ARM + THUMB
                          @ instructions. The default is divided (separate instruction sets)

  .global lightCalc            @ Make the symbol name for the function visible to the linker

  .code   16              @ 16bit THUMB code (BOTH .code and .thumb_func are required)
  .thumb_func             @ Specifies that the following symbol is the name of a THUMB
                          @ encoded function. Necessary for interlinking between ARM and THUMB code.
lightCalc:
  push {r4-r9, lr}          @ registers pushed onto stack to preserve

  ldr r1, =LEDaddress       @ Load the GPIO address we need to turn off any light
  ldr r1, [r1]              @ Dereference r1 to get the value we want
  ldrh r0, [r1]             @ Get the current state of that GPIO (half word only)
  and r0, r0, #0x0          @ bitwise and performed to shut off any previous light
  strh r0, [r1]             @ Write the half word back to the memory address for the GPIO

  mov r0, #1                @ increment value loaded into r0
  mov r2 , #0x0100          @ lowest possible pin value loaded into r2
  ldr r6, =range            @ location of range global variable stored in r5
  ldr r5, [r6]              @ r6 is dereferenced
  ldrb r4, [r5]             @ present byte is loaded into r4
  subs r4, r4, #48          @ first light value reduced from ASSCII character to true value

anotherInc:                 @ start of incrementation loop
  cmp r0, r4                @ base of 1 compared against value loaded from string
  bge noInc                 @ if equal or greater then it skips past incrementation
  LSL r2, r2, #1            @ if less than, bit shift occurs to activate next pin
  add r0, r0, #1            @ comparison value incremented for next loop
  b anotherInc              @ returns to beginning of loop

noInc:                      @ exits here should no incrementation occur
  ldr r3, =lastOn           @ loads lastOn globabl position into r3
  str r0, [r3]              @ stores last light value into r3 for other function use

  ldr r1, =LEDaddress       @ Load the GPIO address we need
  ldr r1, [r1]              @ Dereference r1 to get the value we want
  ldrh r0, [r1]             @ Get the current state of that GPIO (half word only)
  orr r0, r0, r2            @ Use bitwise OR (ORR) to set the bit at 0x0100  to activate desired light
  strh r0, [r1]             @ Write the half word back to the memory address for the GPIO

  add r5, #1                @ increments string position
  ldrb r0, [r5]             @ loads new position bit into r0
  cmp r0, #0                @ compares against 0
  bgt noReset               @ if greater than 0, not yet at end of string. Skips
  ldr r8, =rangeReset       @ if not greater, range is reset to original range
  ldr r7, [r8]              @ dereferenced to get the value
  mov r5, r7                @ moved into r5 for storage
noReset:                    @ exits here if not yet at end of string
  str r5, [r6]              @ next value in string stored into range variable for next run

  pop {r4-r9, lr}           @ link register restored to value from start of function
  bx lr                     @ Return (Branch eXchange) to the address in the link register (lr)


@@@@@@@
@ Function Declaration : void gameCheck()
@ Description:           function for the ending of the game should the
@                        player press the button. Checks if a win or a loss.
@
@ Input:                 none
@ Returns:               none

@@ Function Header Block
  .align  2               @ Code alignment - 2^n alignment (n=2)
                          @ This causes the assembler to use 4 byte alignment

  .syntax unified         @ Sets the instruction set to the new unified ARM + THUMB
                          @ instructions. The default is divided (separate instruction sets)

  .global gameCheck            @ Make the symbol name for the function visible to the linker

  .code   16              @ 16bit THUMB code (BOTH .code and .thumb_func are required)
  .thumb_func             @ Specifies that the following symbol is the name of a THUMB
                          @ encoded function. Necessary for interlinking between ARM and THUMB code.

gameCheck:
  push {r4-r5, lr}        @ registers pushed onto stack

  ldr r1, =lightCheck     @ lightcheck global variable loaded
  ldr r4, [r1]            @ value loaded into register
  cmp r4, #1              @ compared against value of 1
  bge winner              @ if greater than 0, game is currently in 'win' mode. Skips ahead

  ldr r1, =loseCheck      @ loseCheck global variable loaded
  ldr r5, [r1]            @ value loaded into register
  cmp r5, #1              @ compared against value of 1
  bge loseJump            @ if greater than 0, game is currently in 'lose' mode. Skips ahead

  ldr r1, =lastOn         @ lastOn global variable loaded
  ldr r0, [r1]            @ value loaded into register
  ldr r2, =target         @ target global variable loaded
  ldr r1, [r2]            @ value loaded into register
  cmp r0, r1              @ compared against each other to see if win or lose
  beq winner              @ if equal, player has won. Jumps to win section

loseJump:                 @ if in lose state, program will jump to here
  bl loser                @ calls the loser function
  ldr r1, =loseCheck      @ loseCheck global variable reloaded
  ldr r5, [r1]            @ value loaded into register
  cmp r5, #50             @ compared against value to measure timing of loss function
  bge endGame             @ if equal or greater, loss function is done. Skips ahead
  b keepChecking          @ if above condition not met, falls to here for jump to end of function

winner:                   @ if in win state, program will jump to here
  bl lightShow            @ calls the lightShow function to trigger win lights
  ldr r1, =lightCheck     @ lightCheck global variable reloaded
  ldr r4, [r1]            @ value loaded into register
  cmp r4, #75             @ compared against value to measure timing of loss function
  bge endGame             @ if equal or greater, win function is done. Skips ahead
  b keepChecking          @ if above condition not met, falls to here for jump to end of function

endGame:                  @ program jumps here if win/loss functions are finished
  ldr r1, =gameOn         @ gameOn global variable loaded
  ldr r0, [r1]            @ value loaded into register
  mov r0, #0              @ value of 0 loaded for game end
  str r0, [r1]            @ value stored into gameOn, ending the game

keepChecking:             @ program exits here if win/loss functions still necessary

  pop {r4-r5, lr}         @ link register values restored to value from start of function
  bx lr                   @ exits


@@@@@@@
@ Function Declaration : void loser()
@ Description:           function for the ending of the game should the
@                        player fail to activate win condition. Handles light
@                        activation.
@
@ Input:                 none
@ Returns:               none

@@ Function Header Block
  .align  2               @ Code alignment - 2^n alignment (n=2)
                          @ This causes the assembler to use 4 byte alignment

  .syntax unified         @ Sets the instruction set to the new unified ARM + THUMB
                          @ instructions. The default is divided (separate instruction sets)

  .global loser            @ Make the symbol name for the function visible to the linker

  .code   16              @ 16bit THUMB code (BOTH .code and .thumb_func are required)
  .thumb_func             @ Specifies that the following symbol is the name of a THUMB
                          @ encoded function. Necessary for interlinking between ARM and THUMB code.

loser:
  push {r4, lr}           @ appropriate registers stored onto stack

  ldr  r3, =loseCheck     @ Address of loseCheck global variable stored in r3
  ldr  r4, [r3]           @ Load r4 with the address pointed at by r3
  add  r4, r4, #1         @ Increment r4 by 1
  str  r4, [r3]           @ Store the current r4 value back into loseCheck for later comparison
  cmp r4, #1              @ compare value against 1
  ble firstLoseTick       @ if less than or equal to one, is first tick. Skips ahead
  b nextLoseCompare       @ if greater than, skips to next block

firstLoseTick:            @ exits here if on first cycle of loser
  ldr r1, =LEDaddress     @ Load the GPIO address we need
  ldr r1, [r1]            @ Dereference r1 to get the value we want
  ldrh r0, [r1]           @ Get the current state of that GPIO (half word only)
  and r0, r0, #0x0        @ ands the value to deactivate any lights that might be on
  strh r0, [r1]           @ Write the half word back to the memory address for the GPIO

  ldr r2, =target         @ target global variable loaded
  ldr r1, [r2]            @ value loaded into r1
  mov r0, #1              @ r0 loaded with 1 for comparison
  mov r2 , #0x0100        @ r2 loaded with lowest possible pin for light activation

anotherLoseInc:           @ exits here if light value needs further incrementation
  cmp r0, r1              @ target light value compared against r0 contents
  bge noLoseInc           @ if equal, no incrementation necessary. Skips
  LSL r2, r2, #1          @ if not equal, bits shifted left to next value to check
  add r0, r0, #1          @ r0 value incremented to match bit shift
  b anotherLoseInc        @ steps back to start of loop

noLoseInc:                @ exits here if not incrementation necessary
  ldr r1, =LEDaddress     @ Load the GPIO address we need
  ldr r1, [r1]            @ Dereference r1 to get the value we want
  ldrh r0, [r1]           @ Get the current state of that GPIO (half word only)
  orr r0, r0, r2          @ Use bitwise OR (ORR) to activated necessary light
  strh r0, [r1]           @ Write the half word back to the memory address for the GPIO

nextLoseCompare:          @ exits here if light activation was unnecessary
  cmp r4, #50             @ compare loseCheck value against 50
  blt stillLosing         @ if less than, skips ahead so as to leave light on

  ldr r1, =LEDaddress     @ Load the GPIO address we need
  ldr r1, [r1]            @ Dereference r1 to get the value we want
  ldrh r0, [r1]           @ Get the current state of that GPIO (half word only)
  and r0, r0, #0x0        @ shut off all lights as they are no longer necessary
  strh r0, [r1]           @ Write the half word back to the memory address for the GPIO

stillLosing:              @ exits here if lights needed to remain on

  pop {r4, lr}            @ link register restored to value from start of function
  bx lr                   @ exits


@@@@@@@
@ Function Declaration : void lightShow()
@ Description:           function for the ending of the game should the
@                        player succeed to activate win condition. Handles light
@                        activation.
@
@ Input:                 none
@ Returns:               none

@@ Function Header Block
  .align  2               @ Code alignment - 2^n alignment (n=2)
                          @ This causes the assembler to use 4 byte alignment

  .syntax unified         @ Sets the instruction set to the new unified ARM + THUMB
                          @ instructions. The default is divided (separate instruction sets)

  .global lightShow       @ Make the symbol name for the function visible to the linker

  .code   16              @ 16bit THUMB code (BOTH .code and .thumb_func are required)
  .thumb_func             @ Specifies that the following symbol is the name of a THUMB
                          @ encoded function. Necessary for interlinking between ARM and THUMB code.

lightShow:
  push {r4-r6, lr}

  ldr  r6, =lightCheck    @ Address of lightcheck global variable stored in r6
  ldr  r5, [r6]           @ Load r5 with the value pointed at by r6
  add  r5, r5, #1         @ Increment r5 by 1
  str  r5, [r6]           @ Store the current r5 value back to the address pointed at by r6

  cmp r5, #1              @ compares value against 1
  beq lightsOn            @ if equal to 1, first run. Jumps to turn on lights
  cmp r5, #25             @ compares value against 25
  beq lightsOff           @ if equal, it is 25th run. Jumps to turn off lights
  cmp r5, #50             @ compares value against 50
  beq lightsOn            @ if equal, it is 50th run. Repeats light activation
  cmp r5, #75             @ compares against 75
  beq lightsOff           @ if equal, it is end of game. Lights deactivated
  b keepGoing             @ if none of upper conditions met, jumps past light activation/deactivation

lightsOn:
  ldr r1, =LEDaddress       @ Load the GPIO address we need
  ldr r1, [r1]              @ Dereference r1 to get the value we want
  ldrh r0, [r1]             @ Get the current state of that GPIO (half word only)
  orr r0, r0, #0xFF00       @ Use bitwise OR (ORR) to set all lights on
  strh r0, [r1]             @ Write the half word back to the memory address for the GPIO
  b keepGoing               @ branch here to skip light deactivation

lightsOff:
  ldr r1, =LEDaddress       @ Load the GPIO address we need
  ldr r1, [r1]              @ Dereference r1 to get the value we want
  ldrh r0, [r1]             @ Get the current state of that GPIO (half word only)
  and r0, r0, #0x0          @ ands value to deactivate all lights
  strh r0, [r1]             @ Write the half word back to the memory address for the GPIO

keepGoing:                  @ exits here if no more changes necessary

  pop {r4-r6, lr}           @ register values restored
  bx lr                     @ exits

  @@@@@@@
  @ Function Declaration : void watchFunc()
  @ Description:           function for the testing of the watchdog functionality.
  @                        Initializes values for the test.
  @
  @ Input:                 none
  @ Returns:               none

  @@ Function Header Block
    .align  2               @ Code alignment - 2^n alignment (n=2)
                            @ This causes the assembler to use 4 byte alignment

    .syntax unified         @ Sets the instruction set to the new unified ARM + THUMB
                            @ instructions. The default is divided (separate instruction sets)

    .global watchFunc            @ Make the symbol name for the function visible to the linker

    .code   16              @ 16bit THUMB code (BOTH .code and .thumb_func are required)
    .thumb_func             @ Specifies that the following symbol is the name of a THUMB
                            @ encoded function. Necessary for interlinking between ARM and THUMB code.

  watchFunc:
    push {r4-r9, lr}          @ pushes values onto stack for preservation

    ldr  r3, =timer           @ location of timer global variable stored in r3
    str  r0, [r3]             @ value set to 0 to reset for function

    ldr r3, =watchdogLights   @ default light range in global watchdogLights variable loaded into r3
    ldr r2, [r3]              @ dereferenced to get the value
    mov r0, r2                @ moved into r0

    ldr  r3, =range           @ location of range global variable stored in r3
    str  r0, [r3]             @ watchdogLights value stored into range

    ldr  r3, =rangeReset      @ location of rangeReset global variable stored in r3
    str  r0, [r3]             @ watchdogLights value stored into rangeReset for reset in lightShow function

    ldr  r3, =watchdogFunc    @ location of watchdogFunc global variable stored in r3
    mov r0, #1                @ value of 1 moved into register 0
    str  r0, [r3]             @ value set to 1 to activate watchdog testing function

    pop {r4-r9, lr}           @ registers restored
    bx lr                     @ exits

LEDaddress:
  .word 0x48001014

  .end
