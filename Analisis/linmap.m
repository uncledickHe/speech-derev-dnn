function vout = linmap(vin,range)
% Mapeo lineal entre dos intervalos
% vin: Vector de entrada a mapear
% range: Rango del vector de salida 
% vout: Vector mapeado de salida
% uso:
% >> v1 = linspace(-2,9,100);
% >> v2 = linmap(v1,[-5,5]);
%
a = min(vin);
b = max(vin);
c = range(1);
d = range(2);
vout = ((c+d) + (d-c)*((2*vin - (a+b))/(b-a)))/2;
end