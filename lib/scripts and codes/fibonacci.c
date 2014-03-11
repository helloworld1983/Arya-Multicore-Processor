void main()
{
   int first = 0, second = 1, c, next;
   int val[5]={0,0,0,0,0};
   int i = 0;
   int n = 5;
   int j = 1;
 
   for ( c = 0 ; c < n ; c++ )
   {
      if ( c <= j )
         next = c;
      else
      {
         next = first + second;
         first = second;
         second = next;
      }
      val[i] = next;
      //printf("%d\n",val[i]);
      i++;
   }
}
