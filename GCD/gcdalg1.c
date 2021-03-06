/****************************************************************************/
/*                                                                          */
/*                                 GCDALG0                                  */
/*                          Euclid's GCD Algorithm                          */
/*                                                                          */
/****************************************************************************/

/*
   This file contains the function for the GCD algorithm.  It just implements
   Euclid's division algorithm.  The functions included are:
      GCD  -  compute the GCD of its arguments.


   Revision History:
      15 May 00  Glen George            Initial revision.
      16 May 02  Glen George            Updated comments.
*/



/* library include files */
#include  <stdio.h>
#include  <stdlib.h>

/* local include files */
#include  "gcdtest.h"




/*
   GCD(unsigned int, unsigned int)

   Description:      This function computes the GCD of its arguments.  If
                     either argument is zero, zero is returned.

   Arguments:        m (unsigned int) - first value for which to compute the
   				        GCD.
		     n (unsigned int) - second value for which to compute the
   				        GCD.
   Return Value:     (unsigned int) - GCD of the two arguments.

   Inputs:           None.
   Outputs:          None.

   Error Handling:   If either argument is zero (0), zero (0) is returned.

   Algorithms:       Euclid's Division Algorithm.
   Data Structures:  None.

   Last Modified:    15 May 00
*/

unsigned int  GCD(unsigned int a, unsigned int b)
{
    /* variables */
    unsigned int  r;		/* the remainder */

    int           iter_cnt = 0;	/* count the number of iterations */

    unsigned int k = 0;
    int t;
    // steins
    /* check to be sure neither argument is 0 */
    if ((a == 0) || (b == 0))
        /* have a zero argument - return with zero */
	return  0;
    /* loop to compute the GCD */

    // check lsb for even/odd
    // remove 2^n
    for (int i = 0; i <= 15; i++){
        iter_cnt++;
        if (a%2 ==0 && b%2==0)  {
            k++;
            a = a >> 1;
            b = b >> 1;
        }
    }

    // assign t

    iter_cnt++;
    if (a%2 == 1) {
        t = -b;
    } else {
        t = a;
    }

    // steins

    for (int i = 0; i <= 29; i++){ //TODO count??
    //while(t != 0){
        iter_cnt++;
        if (t != 0){
            if (t%2 == 0){
                t /= 2;
            }
            if (t%2 != 0){
                //iter_cnt++;
                if (t>0) {
                    a = t;
                } else {
                    b = -t;
                }
                t = a - b;
                /*
                if (t%2 ==0){
                    t /= 2;
                }*/
            }
        }
    }

    //for (int i = 0; i <= 45; i++){ //TODO count??
    /*
    while (b != 0){
        iter_cnt++;
        //if (t != 0){
            if (b%2 == 0){
                b /= 2;
            }
            else{
                if (a > b){
                    t = a; // swap a, b
                    a = b;
                    b = t;
                }
                b = b - a;
            }
        //}
    } */

    // put 2 back in
    for (int i = 0; i <= 15; i++){
        iter_cnt++;
        if (k != 0){
            a *= 2;
            k--;
        }
    }

    /* done computing the GCD, save the iteration count and return */
    addIterCnt(iter_cnt);

    return a;

}
