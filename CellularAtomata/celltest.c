/****************************************************************************/
/*                                                                          */
/*                                  GCDTEST                                 */
/*                      Test Program for GCD Algorithms                     */
/*                                                                          */
/****************************************************************************/

/*

*/



/* library include files */
#include  <limits.h>
#include  <stdio.h>
#include  <stdlib.h>
#include <math.h>
#include <string.h>

/* local include files */
#include  "celltest.h"




int  main(int narg, char *args[])
{
    /* variables */
    long int      test_cnt;	    /* number of tests to perform */

    unsigned int  k;

    long int      error_cnt = 0;    /* number of errors */
    long int      i;		    /* general loop index */

    int rowsize = 3;
    int colsize = 3;

    int state[9];
    int nextState[9];
    // generate and print all possible initial dead/alive states (integers 0 to 2^n-1)
    for (i = 0; i <= pow(2, rowsize * colsize + 1)-1; i++){
        printf("\"");
        for (int c = rowsize*colsize-1; c >= 0; c--)
          {
            k = i >> c;

            if (k & 1)
              printf("1");
            else
              printf("0");
          }
          printf("\",");

          if (i%5 == 0){
              printf("\n");
          }
    }

    printf("\n\n\n\n");

    // generate states after n cell cycles
    for (i = 0; i <= pow(2, rowsize * colsize)-1; i++){

        for (int c = rowsize*colsize-1; c >= 0; c--) // generate initial state
          {
            k = i >> c;

            if (k & 1)
              state[rowsize*colsize - 1 - c] = 1;
            else
              state[rowsize*colsize - 1 - c] = 0;
          }

          for (int n = 0; n < 10; n++){ // test for 10 cycles
              //printf("\"");
              //0
              if (state[1] + state[3] + state[4] == 3){
                  nextState[0] = 1;
                 //printf("1");
              } else if (state[1] + state[3] + state[4] == 2){
                    nextState[0] = state[0];
                    //printf("%d", state[0]);
              } else {
                  nextState[0] = 0;
                  //printf("0");
              }

              //1
              if (state[0] + state[2] + state[3] + state[4] + state[5] == 3){
                  nextState[1] = 1;
                  //printf("1");
              } else if (state[0] + state[2] + state[3] + state[4] + state[5] == 2){
                  nextState[1] = state[1];
                  //printf("%d", state[1]);
              } else {
                  nextState[1] = 0;
                  //printf("0");
              }

              //2
              if (state[1] + state[4] + state[5] == 3){
                  nextState[2] = 1;
                  //printf("1");
              } else if (state[1] + state[4] + state[5] == 2){
                  nextState[2] = state[2];
                    //printf("%d", state[2]);
              } else {
                  nextState[2] = 0;
                  //printf("0");
              }

              //3
              if (state[0] + state[1] + state[4] + state[6] + state[7] == 3){
                  nextState[3] = 1;
                  //printf("1");
              } else if (state[0] + state[1] + state[4] + state[6] + state[7] == 2){
                  nextState[3] = state[3];
                    //printf("%d", state[3]);
              } else {
                  nextState[3] = 0;
                  //printf("0");
              }

              //4
              if (state[0] + state[1] + state[2] + state[3] + state[5] + state[6] + state[7] + state[8] == 3){
                  nextState[4] = 1;
                  //printf("1");
              } else if (state[0] + state[1] + state[2] + state[3] + state[5] + state[6] + state[7] + state[8] == 2){
                  nextState[4] = state[4];
                    //printf("%d", state[4]);
              } else {
                  nextState[4] = 0;
                  //printf("0");
              }

              //5
              if (state[1] + state[2] + state[4] + state[7] + state[8] == 3){
                  nextState[5] = 1;
                  //printf("1");
              } else if (state[1] + state[2] + state[4] + state[7] + state[8] == 2){
                  nextState[5] = state[5];
                    //printf("%d", state[5]);
              } else {
                  nextState[5] = 0;
                  //printf("0");
              }

              //6
              if (state[3] + state[4] + state[7] == 3){
                  nextState[6] = 1;
                  //printf("1");
              } else if (state[3] + state[4] + state[7] == 2){
                  nextState[6] = state[6];
                    //printf("%d", state[6]);
              } else {
                  nextState[6] = 0;
                  //printf("0");
              }

              //7
              if (state[3] + state[4] + state[5] + state[6] + state[8] == 3){
                  nextState[7] = 1;
                  //printf("1");
              } else if (state[3] + state[4] + state[5] + state[6] + state[8] == 2){
                  nextState[7] = state[7];
                    //printf("%d", state[7]);
              } else {
                  nextState[7] = 0;
                  //printf("0");
              }

              //8
              if (state[4] + state[5] + state[7] == 3){
                  nextState[8] = 1;
                  //printf("1");
              } else if (state[4] + state[5] + state[7] == 2){
                  nextState[8] = state[8];
                    //printf("%d", state[8]);
              } else {
                  nextState[8] = 0;
                  //printf("0");
              }

              for(int n = 0; n <= 8; n++){
                  state[n] = nextState[n];
              }
              //printf("\",");
          }
          printf("\"");
          for(int n = 0; n <= 8; n++){
              printf("%d", state[n]);
          }
          printf("\",");

          if (i%5 == 0){
              printf("\n");
          }
    }
        return  GOOD_EXIT;

}
