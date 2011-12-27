unit Math;
const gm = 0.5772156649015328606; // \u041f\u043e\u0441\u0442\u043e\u044f\u043d\u043d\u0430\u044f \u042d\u0439\u043b\u0435\u0440\u0430 - \u041c\u0430\u0441\u043a\u0435\u0440\u043e\u043d\u0438

function sh(x: Real): Real; // \u0413\u0438\u043f\u0435\u0440\u0431\u043e\u043b\u0438\u0447\u0435\u0441\u043a\u0438\u0439 \u0441\u0438\u043d\u0443\u0441
begin
sh:=(exp(x)-exp(-x))/2;
end;

function ch(x: Real): Real; // \u0413\u0438\u043f\u0435\u0440\u0431\u043e\u043b\u0438\u0447\u0435\u0441\u043a\u0438\u0439 \u043a\u043e\u0441\u0438\u043d\u0443\u0441
begin
ch:=(exp(x)+exp(-x))/2;
end;

function th(x: Real): Real; // \u0413\u0438\u043f\u0435\u0440\u0431\u043e\u043b\u0438\u0447\u0435\u0441\u043a\u0438\u0439 \u0442\u0430\u043d\u0433\u0435\u043d\u0441
begin
th:=sh(x)/ch(x);
end;

function cth(x: Real): Real; // \u0413\u0438\u043f\u0435\u0440\u0431\u043e\u043b\u0438\u0447\u0435\u0441\u043a\u0438\u0439 \u043a\u043e\u0442\u0430\u043d\u0433\u0435\u043d\u0441
begin
cth:=ch(x)/sh(x);
end;

function sech(x: Real): Real; // \u0413\u0438\u043f\u0435\u0440\u0431\u043e\u043b\u0438\u0447\u0435\u0441\u043a\u0438\u0439 \u0441\u0435\u043a\u0430\u043d\u0441
begin
sech:=1/sh(x);
end;

function csch(x: Real): Real; // \u0413\u0438\u043f\u0435\u0440\u0431\u043e\u043b\u0438\u0447\u0435\u0441\u043a\u0438\u0439 \u043a\u043e\u0441\u0435\u043a\u0430\u043d\u0441
begin
csch:=1/ch(x);
end;

function Fact(c: Integer): Real; // n! (\u0444\u0430\u043a\u0442\u043e\u0440\u0438\u0430\u043b)
var fi: Integer;
begin
result:=1;
for fi:=1 to c do result:=result*fi;
end;

function si(x: Real): Real; // \u0418\u043d\u0442\u0435\u0433\u0440\u0430\u043b\u044c\u043d\u044b\u0439 \u0441\u0438\u043d\u0443\u0441
const inf = 84;
var n,chs: Integer;
begin
result:=0;
for n:=0 to inf do begin
If n mod 2 = 1 then chs:=-1 else chs:=+1;
result:=result+chs/(Fact(2*n+1)*(2*n+1))*Power(x,2*n+1);
end;
end;

function ci(x: Real): Real; // \u0418\u043d\u0442\u0435\u0433\u0440\u0430\u043b\u044c\u043d\u044b\u0439 \u043a\u043e\u0441\u0438\u043d\u0443\u0441
const inf = 84;
var n,chs: Integer;
begin
result:=0;
for n:=1 to inf do begin
If n mod 2 = 1 then chs:=-1 else chs:=+1;
result:=result+chs/(Fact(2*n)*(2*n))*Power(x,2*n);
end;
result:=ln(x)+gm+result;
end;

function ei(x: Real): Real; // \u0418\u043d\u0442\u0435\u0433\u0440\u0430\u043b\u044c\u043d\u0430\u044f \u044d\u043a\u0441\u043f\u043e\u043d\u0435\u043d\u0442\u0430
const inf = 169;
var n: Integer;
begin
result:=gm+ln(x);
for n:=1 to inf do begin
result:=result+power(x,n)/(fact(n)*n);
end;
end;

function li(x: Real): Real; // \u0418\u043d\u0442\u0435\u0433\u0440\u0430\u043b\u044c\u043d\u044b\u0439 \u043b\u043e\u0433\u0430\u0440\u0438\u0444\u043c
begin
result:=ei(ln(x));
end;

end.