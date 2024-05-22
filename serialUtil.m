% REDES INDUSTRIALES
% Grado en Ing. electrónica, robótica y mecatrónica
% Dpto. Arquitectura de Computadores - Universidad de Málaga
% by *egc, 2016-2019 (c)
% 
% Imprime la configuración de un dispositivo xbee 
% conectado a un puerto serie,
% y envía las líneas que lee de la entrada estándar
% hasta recibir 'bye'

classdef serialUtil
% Una clase con métodos de utilería
  
    properties
        initialized=0;
        distancia = 1;
    end
    
    methods
        function obj = serialUtil()
            %SERIALUTIL Construct an instance of this class
            %   Detailed explanation goes here
            obj.initialized = 1;
        end
              
        function s = init(obj, port)
        %   Inicializa el puerto serie con unos parámetros
        %   por defecto (9600 8-N-1)
        %   El argumento port es de la forma '/dev/ttyUSB*'
        %   Devuelve s un objeto serie matlab configurado y abierto

            % Por si las moscas cerramos todas las instancias
            % de este puerto
            serialClose(port)

            terminator = {'CR', 'LF'}; % concatenar CR, LF ("\r\n")
            s = serial(port,    ...
                   'BaudRate', 9600,           ...
                   'DataBits', 8,              ...
                   'StopBits', 1,              ...
                   'Parity', 'none',           ...
                   'FlowControl', 'none',      ...
                   'Terminator', terminator);

            fopen(s);
        end

        function command_mode_start(obj, s)
        %   Entrar en modo comando
        %   s = objeto matlab serie
            pause(1.1)
            fwrite(s,'+++')
            pause(1.5)
            bytes = s.BytesAvailable;
            disp(sprintf('Hay %d bytes disponibles', bytes));
            out = fgets(s); % Ojo! Esta lectura incluye el terminador
            disp(['+++: ' out])
        end

        function command_send_at(obj, s, c)
        %   Envia un comando     
        %   s = objeto matlab serie
        %   c = cadena con el comando AT, SIN los caracteres LF, CR
            pause(1)
            fwrite(s, sprintf('%s\r\n', c))
            pause(0.1)
            bytes = s.BytesAvailable;
            disp(sprintf('Hay %d bytes disponibles', bytes));
            out = fgets(s);
            disp([ c ': ' out])
        end

        function command_mode_exit(obj, s) 
        %   Salir del modo comando enviando ATCN
            obj.command_send_at(s, 'ATCN')
        end

        function mide_distancia(obj, s)
            obj.command_mode_start(s);
            
            %obj.command_send_at(s, 'ATDB');            
            obj.distancia = 2;            
            pause(1)
            fwrite(s, 'ATDB\r\n')
            pause(0.1)
            bytes = s.BytesAvailable;
            disp(sprintf('Hay %d bytes disponibles', bytes));
            out = fgets(s);
            disp('----------------------');
            disp([ 'ATDB: ' out])
            
            obj.command_mode_exit(s);
      

        end
    end
end
