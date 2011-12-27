program Hern;
uses GraphABC;
type Point = record
       x,y: Integer;
     end;
const px = 0;
      py = 0;
      pz = 0;
      ppx = 100;
      ppy = 100;
      m = 100;
var x,y,z,x1,y1,z1: array [1..4] of Real;
    a,b,g: Real;
    i: Integer;

procedure Rotate(var x,y,z: Real; const a,b,g: Real);
var nx,ny,nz,t: Real;
begin
  nx:=(x-px)*cos(g)-(y-py)*sin(g);
  ny:=(x-px)*sin(g)+(y-py)*cos(g);
  nz:=z-pz;
  t:=x*cos(b)-z*sin(b);
  nz:=x*sin(b)+z*cos(b);
  x:=px+t;
  y:=py+ny*cos(a)-nz*sin(a);
  z:=pz+ny*sin(a)+nz*cos(a);
end;

procedure SetPoint(xx,yy,zz: Real; n: Integer);
begin
x[n]:=xx; y[n]:=yy; z[n]:=zz;
end;

function PPoint(x,y: Real): Point;
begin
result.x:=Round(x);
result.y:=Round(y);
end;

procedure PolygonF(n1,n2,n3,n4: Integer);
var a: array [1..4] of Point;
begin
a[1]:=PPoint(x1[n1]*m+ppx,y1[n1]+ppy);
a[2]:=PPoint(x1[n2]*m+ppx,y1[n2]+ppy);
a[3]:=PPoint(x1[n3]*m+ppx,y1[n3]+ppy);
a[4]:=PPoint(x1[n4]*m+ppx,y1[n4]+ppy);
Polygon(a,4);
end;

begin
a:=0; b:=0; g:=0;
SetPoint(0,0,0,1);
SetPoint(1,0,0,2);
SetPoint(1,1,0,3);
SetPoint(0,1,0,4);
LockDrawing;
while true do begin
  ClearWindow;
  for i:=1 to 4 do begin
    x1[i]:=x[i]; y1[i]:=y[i]; z1[i]:=z[i];
    Rotate(x1[i],y1[i],z1[i],a,b,g);
  end;
  PolygonF(1,2,3,4);
  Redraw;
  a:=a+0.01; //b:=b+0.01; g:=g+0.01;
  If a>=2*pi then a:=0;
  //sleep(100);
end;
end.

