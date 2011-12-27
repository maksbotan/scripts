program jhhgk;
uses GraphABC;
var p: Integer;
    i,j: Integer;
begin
p:=CreatePicture(400,400);
SetDrawingSurface(p);
for i:=0 to 399 do
    for j:=0 to 399 do SetPixel(i,j,clRandom);
SavePicture(p,'111.png');
DestroyPicture(p);
end.