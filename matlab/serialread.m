function serialRead
% REDES INDUSTRIALES
% Grado en Ing. electrónica, robótica y mecatrónica
% Dpto. Arquitectura de Computadores - Universidad de Málaga
% by *egc, 2016-2021 (c)
% 
% Imprime la configuración de un dispositivo xbee 
% conectado a un puerto serie,
% e imprime las líneas que recibe hasta recibir 'bye'
%

% En linux el nombre del dispositivo es de la forma '/dev/ttyUSB*'
port = '/dev/ttyUSB0';

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

[~, a]=fileattrib(port);
if (~a.UserWrite || ~a.UserRead)
    disp('Este script requiere permisos RW en el puerto serie');
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
u.command_send_at(s, 'ATMY 2')
u.command_send_at(s, 'ATDH 0')
u.command_send_at(s, 'ATDL 1')
u.command_send_at(s, 'ATCH')

u.command_mode_exit(s);

disp('Se recibirán líneas del dispositivo remoto (recibir "bye" para salir)')
s.Timeout = 5 % timeout para el fgets, fgetl, ... (sale sin recibir nada)
while 1
    tic
    [line, count, msg] = fgetl(s); % Lee del puerto, fgetl no incluye el terminador
    if (length(msg)>0)  % Hay algún error
        fprintf('Error message: "%s"', msg);
    else 
        % No error
        fprintf('Recibido %d bytes:\t%s', count, strtrim(line));
        u.mide_distancia(s);
        %u.command_mode_start(s);
        %u.command_send_at(s, 'ATDB');
        %u.command_mode_exit(s);
        
    end
    tel = toc;
    fprintf('\nTranscurrido %d segundos\n\n', floor(tel));
    if strcmp(strtrim(line), 'bye') %línea que comience por vacío o espacios seguido de bye y espacios
        disp('Recibido bye ... adiós');
        break;
    end
end


fclose(s);
delete(s);

end
