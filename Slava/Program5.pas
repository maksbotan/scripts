program compare;
uses GraphABC,Utils;
var i,j,N,t: Integer;
    c: Real;
    
function sst(v: Integer): Real;
begin
If v<0 then v:=-v;
sst:=v;
end;
    
function f(n: Integer): Integer;
begin
If n <= 1 then f:=1 else f:=n*f(n-1);
end;
    
begin
N:=600;
for i:=1 to N do begin
    t:=Milliseconds;
    for j:=1 to i*50 do begin
      c:=f(Round(i/300));
    end;
    t:=Milliseconds-t;
    SetPixel(i,t,clRed);
    t:=Milliseconds;
    for j:=1 to i*50 do begin
      c:=sqrt(j);
    end;
    t:=Milliseconds-t;
    SetPixel(i,t,clBlue);
end;
end.