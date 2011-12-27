program Space;
uses GraphABC;
const MaxDepth = 100;
      MaxWidth = WindowWidth div 2;
      MaxHeight = WindowHeight div 2;
      MaxSpeed = 0;
      MaxWeight = 100;
      Density = 1;
      dt = 0.01;
      N = 20;
      G = 3;
      px = WindowWidth div 2;
      py = WindowHeight div 2;
      n_ = 5;
type Point = record
       x,y,z: Real;
       vx,vy,vz: Real;
       m,r: Real;
       exist: Boolean;
     end;
var a: array [1..N] of Point;
    ax,ay,az: Real;
    fx,fy,fz: Real;
    F_: Real;
    i,j: Integer;
    
function Scale(r0,z: Real): Real;
begin
If (z<MaxDepth) and (z>=0) then result:=r0/(1+z/MaxDepth/n_) else result:=0;
end;
    
function SetPoint(x,y,z,vx,vy,vz,m: Real): Point;
begin
result.x:=x;
result.y:=y;
result.z:=z;
result.vx:=vx;
result.vy:=vy;
result.vz:=vz;
result.m:=m;
result.r:=power(3/4*m/Density,1/3);
result.exist:=true;
end;
    
function F(m1,m2,r: Real): Real;
begin
F:=G*m1*m2/sqr(r);
end;
    
function dst(a,b: Point): Real;
begin
result:=sqrt(sqr(a.x-b.x)+sqr(a.y-b.y)+sqr(a.z-b.z));
end;
    
begin
Randomize;
MaximizeWindow;
LockDrawing;
for i:=1 to N do a[i]:=SetPoint(MaxWidth*(1-random*2),MaxHeight*(1-random*2),MaxDepth*(1-random*2),MaxSpeed*(1-random*2),MaxSpeed*(1-random*2),MaxSpeed*(1-random*2),MaxWeight*(random+10));
while true do begin
ClearWindow;
  for i:=1 to N do
      for j:=1 to N do If (i<>j) and (a[i].exist) then begin
          F_:=F(a[i].m,a[j].m,dst(a[i],a[j]));
          fx:=F_*(a[j].x-a[i].x)/dst(a[i],a[j]);
          fy:=F_*(a[j].y-a[i].y)/dst(a[i],a[j]);
          fz:=F_*(a[j].z-a[i].z)/dst(a[i],a[j]);
          ax:=fx/a[i].m;
          ay:=fy/a[i].m;
          az:=fz/a[i].m;
          a[i].vx:=a[i].vx+dt*ax;
          a[i].vy:=a[i].vy+dt*ay;
          a[i].vz:=a[i].vz+dt*az;
          a[i].x:=a[i].x+dt*a[i].vx;
          a[i].y:=a[i].y+dt*a[i].vy;
          a[i].z:=a[i].z+dt*a[i].vz;
          Circle(Round(a[i].x)+px,Round(a[i].y)+py,Round(Scale(a[i].r,a[i].z)));
          If a[i].x>MaxWidth then a[i].vx:=-a[i].vx;
          If a[i].y>MaxHeight then a[i].vy:=-a[i].vy;
          If a[i].z>MaxDepth then a[i].vz:=-a[i].vz;
          If a[i].x<-MaxWidth then a[i].vx:=-a[i].vx;
          If a[i].y<-MaxHeight then a[i].vy:=-a[i].vy;
          If a[i].z<0 then a[i].vz:=-a[i].vz;
          If dst(a[i],a[j])<=a[i].r+a[j].r then begin
            a[j].exist:=false;
            a[i]:=SetPoint(a[i].x,a[i].y,a[i].z,(a[i].vx*a[i].m+a[j].vx*a[j].m)/(a[i].m+a[j].m),
            (a[i].vy*a[i].m+a[j].vy*a[j].m)/(a[i].m+a[j].m),(a[i].vz*a[i].m+a[j].vz*a[j].m)/(a[i].m+a[j].m),a[i].m+a[j].m);
          end;
  end;
Redraw;
sleep(1);
end;
end.