"C:\Program Files\Raspberry Pi\Pico SDK v1.5.1\gcc-arm-none-eabi\bin\arm-none-eabi-as.exe" main.S -o main.o
"C:\Program Files\Raspberry Pi\Pico SDK v1.5.1\gcc-arm-none-eabi\bin\arm-none-eabi-ld.exe" -T linker.ld
"C:\Program Files\Raspberry Pi\Pico SDK v1.5.1\pico-sdk-tools\elf2uf2.exe" main.elf main.uf2