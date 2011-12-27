program Mandelbrot;
uses GraphABC;
const NN = {power(10,75);}2;
var x,y: Integer;
    p: Integer;
    Width,Height: Integer;
    prec: Integer;
    v: Real;
    x1,x2,y1,y2: Real;
    n,x0,y0,i,j: Integer;
    xxx,yyy,step,zz,dzz,max: Real;

function atn2(x,y: Real): Real;
begin
result:=2*arctan(y/(sqrt(x*x+y*y)+x));
end;

function f(x,y: Real; n: Integer): Integer;
var m: Integer;
    x0,y0,x_,y_: Real;
    q: Real;
    //dz,dd: Complex;
    z,z0,c: Complex;
begin
c:=(10,2);
q:=sqr(x+1/4)+sqr(y); //dz:=1;
{If (sqr(x-1)+y*y < 1/16) or (sqr(x-1-5/16)+y*y < 1/256) or (q*(q-(x+1/4))<y*y/4)
   {or (sqr(x+x1)+sqr(y-y1) < 1/121)}{ then f:=n else
begin }
x0:=x; y0:=y; m:=0; z:=(x,y);
while (m<=n) and (sqr(x)+sqr(y)<=sqr(1+sqrt(1+4*sqrt(sqr(z.Im)+sqr(z.Re))))/4) do begin
 x_:=x*x-y*y+x;
 y_:=2*x*y+y0;
 x:=x_; y:=y_;
 //z:=z*z+c;
 Inc(m);
 //dd.Re:=x;
 //dd.Im:=y;
 //dz:=2*dd*dz+1;
end;
result:=m-1;
//end;
//zz:=sqrt(sqr(x)+sqr(y));
//dzz:=sqrt(sqr(dz.Re)+sqr(dz.Im));
end;

function ChangeColor(c: Integer): Integer;
var r,g,b: Byte;
begin
r:=c mod 256;
g:=(c shr 8) mod 256;
b:=(c shr 16) mod 256;
c:=b+g shl 8+r shl 16;
end;

function xx(x: Real): Integer;
begin
xx:=Round((x+2)*Width/3);
end;

function yy(x: Real): Integer;
begin
yy:=Round((x+1)*Height/2);
end;

function IntToStrF(v: Integer): String;
begin
result:=IntToStr(v);
while Length(result)<4 do result:='0'+result;
end;

function shift(x,s: Integer): Integer;
var t1,t2: Integer;
begin
t1:=x shr s;
t2:=x shl (24-s);
result:=t1+t2;
end;

function log(b,a: Real): Real;
begin
try log:=ln(a)/ln(b) except log:=MaxInt; end;
end;

function vv(n,N_: Real; z: Real): Real;
begin
vv:=n-log(2,log(2,z)/log(2,N_));
If result>max then max:=result;
//WriteLn(result);
end;

function high(c: Integer): Integer;
var r: Integer;
begin
r:=c and 255;
{r:=Round(r*4);
If r>255 then r:=255;}
r:=Round((power(r/255+1,10)-1)*255);
If r<128 then r:=Round(sqrt(r));
If r>=256 then r:=255;
result:=r shl 16+r shl 8+r;
end;

function ff(it,q,n: Integer): Integer;
var c_r: Integer;
    coeff: Real;
begin
//ff:=Round(zz*ln(zz)/dzz);
//If it<>q then ff:=shift(Round(vv(it,NN,zz)),6) else ff:=0;
//ff:=Round(it/q*$FFFFFF);
ff:=shift(Round(it),0);
//ff:=high(RGB(Round(it/q*256),Round(it/q*256),Round(it/q*256)));
//c_r:=16777216;
//coeff:=(c_r-1)/q;
//ff:=Round(it*coeff);
end;

begin
{v:=-2*pi*1/3;
x1:=0.5*cos(v)-0.25*cos(2*v);
y1:=0.5*sin(v)-0.25*sin(2*v)-1/11;
v:=2*pi*1/3;
x2:=0.5*cos(v)-0.25*cos(2*v);
y2:=0.5*sin(v)-0.25*sin(2*v)+1/9;    }

//MaximizeWindow;
max:=0;
Sleep(100);
Width:=600;
Height:=400;
SetWindowSize(Width,Height);
prec:=4096; n:=1;
{xxx:=0.001643721971153-0.000047;
yyy:=0.822467633298876+0.000426;
step:=0.00001;
for x:=0 to WindowWidth do
    for y:=0 to WindowHeight do begin
        SetPixel(x,y,Round(ff(f(step/Height*(x-Width/2)/2+xxx,step/Width*(y-Height/2)+yyy,prec),prec,8)));
end;}
for j:=0 to (n-1) div 2 do
    for i:=0 to n-1 do begin
    //p:=CreatePicture(Width,Height);
    x0:=i*Width; y0:=j*Height;
    //SetDrawingSurface(p);
    for x:=x0 to x0+Width-1 do begin
        for y:=y0 to y0+Height-1 do
         SetPixel(x-x0,y-y0,Round(ff(f(-x/Width/n*3+2,y/Height/n*2-1,prec),prec,6)));
          If x mod 50 = 0 then SetWindowCaption(IntToStr(x)+'  '+IntToStr(j*n+i+1));
        end;
        SetPenColor(clRed);
        //TextOut(10,10,IntToStr(j*n+i+1));
    //SavePicture(p,'_'+IntToStrF(j*n+i+1)+'__.png');
    //DestroyPicture(p);
end;
//SetWindowCaption(FloatToStr(max));
end.
