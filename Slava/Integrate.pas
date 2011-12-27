program Integrate;
uses Crt,GraphABC,Utils;
const dx = 0.001;
      py = -120;
var x,S,a,b,mx,my,de: Real;
    t: Integer;

function f(x: Real): Real;
begin
f:=sin(x*x);
end;

function F__(x: Real): Real;
begin
If x<>0 then F__:=arctan(power(abs(x-0.3),2.1)/2)/2.7*(1-sin(x*x)/5/power(x+0.5,2)){*power(x,0.01)}*arctan(x)/1.4568 else F__:=0;
end;

function F_(x: Real): Real;
begin
//F_:=x*x*x/3;
If x<>0 then F_:=F__(x)+(1-cos(x*x))/x/2 else F_:=0;
end;

procedure SetPixelM(x,y: Integer; c: ColorType);
begin
If (x>=0) and (x<WindowWidth) and (y>=0) and (y<WindowHeight) then SetPixel(x,y,c);
end;

begin
a:=0; b:=+1000;
mx:=(b-a)/WindowWidth;
my:=500;
S:=0; x:=a;
t:=Milliseconds;
while x<=b do begin
   S:=S+f(x)*dx;
   de:=de+abs(S-F_(x));
  SetPixelM(Round(x/mx),Round(WindowHeight-S*my-py),clBlack);
  SetPixelM(Round(x/mx),Round(WindowHeight-F_(x)*my-py),clRed);
  //SetPixel(Round(x/mx),Round(WindowHeight-(S-F_(x))*my-py),clBlue);
  //SetPixel(Round(x/mx),Round(WindowHeight-F__(x)*my-py),clGreen);
   //SetPixel(Round(x/mx),Round(WindowHeight-(-S+F_(x)+F__(x))*my*20-py),clSkyBlue);
   //SetPixel(Round(x/mx),Round(WindowHeight-F___(x)*my*20-py),clGray);
   x:=x+dx;
end;
t:=Milliseconds-t;
WriteLn(FloatToStr(S));
If F_(b)<>F_(a) then WriteLn(FloatToStr(F_(b)-F_(a)));
If F_(b)<>F_(a) then WriteLn(FloatToStr((S-F_(b)+F_(a))/(F_(b)-F_(a)))+'%   (Относительная погрешность)');
WriteLn(FloatToStr(de*dx)+'      (Общее отклонение)');
WriteLn(IntToStr(t)+' мс');
end.