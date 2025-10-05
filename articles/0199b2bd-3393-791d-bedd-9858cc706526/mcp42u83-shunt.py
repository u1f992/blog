import time
import spidev

spi = spidev.SpiDev()
spi.open(1, 0)

def corrected_value(d):
    Vcc = 3.3
    Vf = 2.0
    R_led = 120
    Rpot_max = 5000.0
    I_max = (Vcc - Vf) / R_led
    I_min = (Vcc - Vf) / (R_led + Rpot_max)
    I_target = I_min + (d / 1023.0) * (I_max - I_min)
    R_pot = (Vcc - Vf) / I_target - R_led
    return int(round(R_pot / Rpot_max * 1023))

def set_pot(value):
    spi.writebytes([0b00001000, (value >> 8) & 0x03, value & 0xff])

while True:
    for d in range(0, 1024):
        set_pot(corrected_value(d))
        time.sleep(0.001)
    for d in range(1023, -1, -1):
        set_pot(corrected_value(d))
        time.sleep(0.001)
