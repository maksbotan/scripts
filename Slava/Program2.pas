program ChangeColor;
uses GraphABC;
var p: Integer;
    i,j: Integer;
    m: Real;
    w,h: Integer;
    
function f1(c: Integer): Real;
begin
f1:=c/$FFFFFF;
end;

function f2(c: Real): Integer;
begin
f2:=Round(c*$FF8000);
end;
    
begin
p:=LoadPicture('1.bmp');
SetDrawingSurface(p);
for i:=0 to PictureWidth(p)-1 do begin
    for j:=0 to PictureHeight(p)-1 do SetPixel(i,j,f2(f1(GetPixel(i,j))));
    If i mod 50 = 0 then SetWindowCaption(IntToStr(i));
    end;
SavePicture(p,'4.bmp');
DestroyPicture(p);
end.

