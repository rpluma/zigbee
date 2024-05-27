#!/usr/bin/env python
# coding=utf-8

# REDES INDUSTRIALES
# Grado en Ing. electrónica, robótica y mecatrónica
# Dpto. Arquitectura de Computadores - Universidad de Málaga
# Mayo 2016

# Imprime la configuración de un dispositivo xbee 
# conectado a un puerto serie,
# y envía las líneas que lee de la entrada estándar
# hasta recibir 'bye'

# Ejecutar:
#   - desde shell: chmod +x serialWrite.py
#                  sudo ./serialWrite.py 
#
#   - con python:  sudo python serialWrite.py
#
#   - dentro del interprete python: sudo python
#                                   >>> execfile('serialWrite.py')


import sys
import time
import serial

def init(dev):
    """
        Inicializa el puerto serie con unos parámetros
        por defecto (9600 8-N-1)
        El argumento dev es de la forma '/dev/ttyUSB*'
    """
    serial_port = serial.Serial(dev, 9600, 
                            parity=serial.PARITY_NONE,
                            bytesize=serial.EIGHTBITS,
                            stopbits=serial.STOPBITS_ONE,
                            rtscts=False)
    return serial_port
                                
def command_mode_start():
    """
        Entrar en modo comando
    """
    time.sleep(1)   # guarda de 1 segundo
    serial_port.write(b'+++')
    time.sleep(1)   # guarda 1 segundo, 
    print serial_port.read(3) #ademas hay que esperar el OK
    return 
    
def command_send_at(c): 
    """
        c = comando AT sin caracteres LF, CR
    """
    time.sleep(1)
    serial_port.write(c + '\r\n') # concatenar LF, CR
    serial_port.flush()
    time.sleep(.1)
    bytesToRead = serial_port.inWaiting() # imprimir respuesta
    print c + ":", serial_port.read(bytesToRead)
    return
    
def command_mode_exit():
    """
        Salir del modo comando enviando ATCN
    """    
    command_send_at('ATCN')
    return
    
serial_port = init('/dev/ttyUSB1')
command_mode_start()
command_send_at('AT')

command_send_at('ATID')
command_send_at('ATMY')
command_send_at('ATDH')
command_send_at('ATDL')
command_send_at('ATCH')
command_mode_exit()


print 'Teclee (salir tecleando "bye"):'
while True:
    try:
        line = sys.stdin.readline()
        sys.stdout.write('line=' + line) #debug        
        serial_port.write(line)
        if (line.strip() == 'bye'): #comparar sin \n
            break
    except KeyboardInterrupt:
        break

serial_port.close()

