Program Param3D;
uses GraphABC{,Math},Utils;
type Point = record
     x,y: Integer;
     end;
     Point3D = record
     x,y,z: Real;
     end;
     Matrix = array [1..4,1..4] of Real;
     Side  = record
     v: array [1..4] of Point3D;
     zmin: Real;
     N: Real;
     end;
     
const TMax = 2*pi;     // Максимум
      TTMax = 2*pi;  // и минимум параметров
      ST = pi*2/20;       // Шаг T
      STT = pi*2/10;      // Шаг TT
      ColorRange = 24; // Высота по цвету
      Polig = true;  // Полигонами?
      full = true;   // Заполненными?
      px = 500;      // Сдвиг по X
      py = 400;        // Сдвиг по Y
      pz = 0;      // Сдвиг по Z
      a = 50;         // Коэффи-
      b = 15;         // циенты
      c = 50;         // растяжения
      R = 30;
      rr = 10;
      da  = 1*pi/180;       // Изменение
      db  = 2*pi/180;       // углов
      dg  = 4*pi/180;       // (alp,bet,gam)
      num = 2;
var t,tt: Real;
    x,y,z: array [1..4] of Real;
    p: array [1..4] of Point;
    p3D: array [1..4] of Point3D;
    sides: array [0..Round(4*pi*sqr(pi)/ST/STT)] of Side;
    alp,bet,gam: Real;
    tmp: Side;
    i,j,k,l,step,n: Integer;
    smil: Real;
    s: String;
    nnn: Integer;

function fx(t,tt: Real): Real;
begin
case num of
 1: fx:=a*sin(t)*sin(tt)*30;
 2: fx:=a*t*sin(tt);
 3: fx:=(R+rr*cos(tt))*cos(t)*a;
 4: fx:=a*sin(t*2)/2-400;
 end;
end;

function fy(t,tt: Real): Real;
begin
case num of
 1: fy:=b*cos(t)*30;
 2: fy:=-b*t*t*cos(2*tt);
 3: fy:=(R+rr*cos(tt))*sin(t)*b;
 4: fy:=sin(t)*b;
 end;
end;

function fz(t,tt: Real): Real;
begin
case num of
 1: fz:=c*sin(t)*cos(tt)*30;
 2: fz:=c*t*cos(tt);
 3: fz:=rr*sin(tt)*c;
 4: fz:=-tt*cos(t)*c;
 end;
end;

function IPoint(x,y: Real): Point;
const m = 10;
begin
result.x:=Round(x);
result.y:=WindowHeight-Round(y);
end;

function RGBGR(gr: Real): ColorType;
begin
RGBGR:=RGB(Round(gr),Round(gr),Round(gr));
end;

function P3Dto2D(p3D: Point3D): Point;
begin
    Result.X:=Trunc(WindowWidth*(P3D.x)/(WindowWidth));
    Result.Y:=Trunc(WindowHeight*(P3D.y-WindowHeight)/(0-WindowHeight))-pz;

//result:=IPoint(p3D.x+p3D.y/2,p3D.z+p3D.y/2);
end;

function Min(x,y,z,t: Real): Real;
begin
If (x<y) and (x<z) and (x<t) then Min:=x;
If (y<z) and (y<t) and (y<x) then Min:=y;
If (z<t) and (z<x) and (z<y) then Min:=z;
If (t<x) and (t<y) and (t<z) then Min:=t;
end;

function Norm(p1,p2,p3: Point3D): Real;
var A,B: Point3D;
    u,v,w,d: Real;
begin
A.x:=p2.x-p1.x; A.y:=p2.y-p1.y; A.z:=p2.z-p1.z;
B.x:=p3.x-p1.x; B.y:=p3.y-p1.y; B.z:=p3.z-p1.z;
u:=A.y*B.z-A.z*B.y;
v:=-A.x*B.z+A.z*B.x;
w:=A.x*B.y-A.y*B.x;
d:=Sqrt(u*u+v*v+w*w);
If d<>0 then begin
   result:=w/d;
 end else begin
   result:=0;
 end;
end;

function Rotate(a,b,g: Real; P: Point3D): Point3D;
var x,y,z,t: Real;
begin
  x:=(P.x-px)*cos(g)-(P.y-py)*sin(g);
  y:=(P.x-px)*sin(g)+(P.y-py)*cos(g);
  z:=P.z-pz;
  t:=x*cos(b)-z*sin(b);
  z:=x*sin(b)+z*cos(b);
  Result.x:=px+t;
  Result.y:=py+y*cos(a)-z*sin(a);
  Result.z:=pz+y*sin(a)+z*cos(a);
end;

begin
MaximizeWindow;
n:=0; nnn:=1;
LockDrawing;
alp:=0; bet:=0; gam:=0;
smil:=milliseconds;
while true do begin
t:=0; j:=1;
while t<=TMax do begin
tt:=0;
 while tt<=TTMax do begin
  p3D[1].x:=fx(t,tt)+px;
  p3D[2].x:=fx(t+ST,tt)+px;
  p3D[3].x:=fx(t+ST,tt+STT)+px;
  p3D[4].x:=fx(t,tt+STT)+px;
  
  p3D[1].y:=fy(t,tt)+py;
  p3D[2].y:=fy(t+ST,tt)+py;
  p3D[3].y:=fy(t+ST,tt+STT)+py;
  p3D[4].y:=fy(t,tt+STT)+py;
  
  p3D[1].z:=fz(t,tt)+pz;
  p3D[2].z:=fz(t+ST,tt)+pz;
  p3D[3].z:=fz(t+ST,tt+STT)+pz;
  p3D[4].z:=fz(t,tt+STT)+pz;
  
  p3D[1]:=Rotate(alp,bet,gam,p3D[1]);
  p3D[2]:=Rotate(alp,bet,gam,p3D[2]);
  p3D[3]:=Rotate(alp,bet,gam,p3D[3]);
  p3D[4]:=Rotate(alp,bet,gam,p3D[4]);
  for i:=1 to 4 do sides[j].v[i]:=p3D[i];
  sides[j].zmin:=(p3D[1].z+p3D[2].z+p3D[3].z+p3D[4].z)/4;
  sides[j].N:=Norm(p3D[1],p3D[2],p3D[3]);
  tt:=tt+STT; Inc(j);
 end;
t:=t+ST;
end;

step:=j div 2;
while step>=1 do begin
  k:=step;
  for i:=k+0 to j-1 do begin
    tmp:=Sides[i]; l:=i-k;
    while (l>0) and (tmp.zmin<Sides[l].zmin) do begin
      Sides[l+k]:=Sides[l]; l:=l-k;
    end;
    Sides[l+k]:=tmp;
  end;
  step:=3*step div 5;
end;

ClearWindow;
for k:=1 to j do begin
  for i:=1 to 4 do p[i]:=P3Dto2D(sides[k].v[i]);
  If sides[k].N>=0 then begin
  If sides[k].N>=0 then SetBrushColor(Trunc(255*sides[k].N)*$010101) else SetBrushColor(Trunc(255*Abs(sides[k].N)/3)*$010101);
  SetPenColor(BrushColor-$010101*ColorRange);
  If not full then SetBrushStyle(bsClear);
  If Polig then Polygon(p,4);
  If not Polig then SetPixel(p[1].x,p[1].y,PenColor);
  //If k mod 40 = 0 then Sleep(1);
  end;
end;
Redraw;
//SaveWindow('Новая папка\'+IntToStr(nnn)+'.bmp');
Inc(nnn);
alp:=alp+da; If alp>=2*pi then alp:=alp-2*pi;
bet:=bet+db; If bet>=2*pi then bet:=bet-2*pi;
gam:=gam+dg; If gam>=2*pi then gam:=gam-2*pi;
If (alp = bet) and (bet = gam) then exit;
n:=n+1;
Str((milliseconds+smil)/n:2:2,s);
SetWindowCaption('Среднее время выполнения: '+s+' n = '+IntToStr(n));
end;
end.