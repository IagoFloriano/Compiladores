program proc1 (input, output); 
  var x, y: integer;      
  procedure p;             
     var z:integer;              

     procedure p1;
       var p2:integer;
       begin
         z := z - 1
       end;
     begin                   
       z:=x;                   
       p1;
       x:=x-1;           
       if (z>1)                   
         then p 
         else y:=1; 
       y:=y*z      
     end;
begin                     
   p;  
end.
