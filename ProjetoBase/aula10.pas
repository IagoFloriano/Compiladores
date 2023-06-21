program proc1 (input, output);
  var x, y: integer;
  procedure p;
    var z:integer;

    procedure w;
      var j:integer;
      begin
        j := 2
      end;

    procedure p1;
      var p2:integer;
      begin
        p2:=12
      end;

    procedure p3;
      var p4: integer;
      begin
        p4:=813
      end;

    begin
      z:=x;
      x:=x-1;
      if (z>1)
        then x := y
        else y:=1;
      y:=y*z
    end;
begin
  x := 1;
  x := y
end.
