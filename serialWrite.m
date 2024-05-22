function serialWrite
% REDES INDUSTRIALES
% Grado en Ing. electrónica, robótica y mecatrónica
% Dpto. Arquitectura de Computadores - Universidad de Málaga
% by *egc, 2016-2021 (c)
% 
% Imprime la configuración de un dispositivo xbee 
% conectado a un puerto serie,
% y envía las líneas que lee de la entrada estándar
% hasta recibir 'bye'
%

% En linux el nombre del dispositivo es de la forma '/dev/ttyUSB*'
port = '/dev/ttyUSB1';

% Este script está pensado para ser ejecutado como
% root en un sistema Linux:
%    sudo matlab
%
% o bien tener permiso de escritura en el dispositivo
% del puerto serie. En linux suele bastar con añadir al
% usuario al grupo dialout que suele ser el grupo propietario
% del puerto
%   sudo adduser usuario dialout
% 

[v,a]=fileattrib(port);
if (~a.UserWrite || ~a.UserRead)
    disp('Este script requiere permisos RW en el puerto serie');
    disp(['Antes de nada compruebe que el puerto ' port ' existe']);
    disp('Hay dos opciones:');
    disp('1) Ejecutar matlab como root: sudo matlab')
    disp('     No olvide realizar sudo chown -R usuario.grupo ~/.matlab');
    disp('     al finalizar, para evitar problemas con los permisos!');
    disp('2) Añadir el usuario actual en el grupo propietario del puerto')
    disp('     Ese grupo suele ser dialout: sudo adduser usuario dialout');
    disp('     O dar permisos globales: sudo chmod a+rw /dev/ttyUSB*');  
    disp(' ');
    disp('Como no tengo permisos,me voy ...');
    return;
end

% Cargar librería de utilidades
u = serialUtil();

%Inicializar puerto e imprimir su configuración
disp(['Configurando puerto: ' port ' ...']);
s = u.init(port);
disp(s)

disp(['* BaudRate: ' num2str(s.BaudRate)])
disp(['* DataBits: ' num2str(s.DataBits)])
disp(['* StopBits: ' num2str(s.StopBits)])
disp(['* FlowControl: ' s.FlowControl])
disp(['* RequestToSend: ' s.RequestToSend])
disp(['* Terminator: ' cell2mat(s.Terminator)])

disp(' ')

u.command_mode_start(s);

u.command_send_at(s, 'AT');
u.command_send_at(s, 'ATID 3210')
u.command_send_at(s, 'ATMY 1')
u.command_send_at(s, 'ATDH 0')
u.command_send_at(s, 'ATDL 2')
u.command_send_at(s, 'ATCH')

u.command_mode_exit(s);

disp('Teclee líneas a enviar (para salir teclee "bye")')
while 1
    line = input('', 's'); % Lee de stdin, sin \n
    fwrite(s, [line sprintf('\r\n') ]); % Enviar la línea por el dispositivo serie
    
    %final: línea que comience por vacío o espacios seguido de "bye" y espacios
    if strcmp(strtrim(line), 'bye')
        break;
    end
end


fclose(s);
delete(s);

end