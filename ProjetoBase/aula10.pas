program proc1 (input, output); 
  var x, y: integer;      
  function p:integer;             
     var z:integer;              
     begin                   
       z:=x;                   
       x:=x-1;           
       if (z>1)                   
         then p 
         else y:=1; 
       y:=y*z ;     
       p := 1
     end;

   procedure p2(var a:integer);
   var a2:integer;
   begin
     a2 := a;
     a := a * a2
   end;
begin                     
   read(x);            
   p2(p);
   write (x,p)             
end.
