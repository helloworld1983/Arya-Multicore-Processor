//#include <stdio.h>
 
void main()
{
  int n, c, d, swap;
 
 // printf("Enter number of elements\n");
  //scanf("%d", &n);
 
  //printf("Enter %d integers\n", n);
 
  //for (c = 0; c < n; c++)
    //scanf("%d", &array[c]);
 n = 5;
 int array[5] = {3,4,6,5,2};
  for (c = 0 ; c < ( n - 1 ); c++)
  {
    for (d = 0 ; d < n - c - 1; d++)
    {
      if (array[d] > array[d+1]) /* For decreasing order use < */
      {
        swap       = array[d];
        array[d]   = array[d+1];
        array[d+1] = swap;
      }
    }
  }
 
//  printf("Sorted list in ascending order:\n");
 
//  for ( c = 0 ; c < n ; c++ )
//     printf("%d\n", array[c]);
 
}
