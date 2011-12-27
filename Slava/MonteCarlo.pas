program Monte;
uses Crt,Utils;
var i: Integer;
    N: Integer;
    a,b,sf,u: Real;
    t: Integer;

function f(x: Real): Real;
begin
f:=x*x;
//f:=sin(x)/x;
end;

function F_(x: Real): Real;
begin
F_:=x*x*x/3;
//If x>0 then F_:=pi else F_:=0;
end;

begin
Sleep(100);
Randomize;
N:=1000000; sf:=0; a:=0; b:=10;
t:=Milliseconds;
for i:=1 to N do begin
  u:=Random*(b-a)+a;
  sf:=sf+f(u);
end;
t:=Milliseconds-t;
WriteLn(FloatToStr((b-a)/N*sf));
WriteLn(FloatToStr(F_(b)-F_(a)));
WriteLn( FloatToStr( ( (b-a)/N*sf-F_(b)+F_(a) )/(F_(b)-F_(a)) )+'%   (Относительная погрешность)' );
WriteLn(IntToStr(t)+' мс');
end.