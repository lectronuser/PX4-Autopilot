# Lectron MFA-01 Flight Controller

Custom PX4 flight controller board based on STM32H753IIK6TR MCU.

## Hardware Specifications

### Main Processor
- **MCU**: STM32H753IIK6TR
  - 480MHz ARM Cortex-M7
  - 2MB Flash
  - 1MB RAM
  - Hardware FPU

### Sensors
- **IMU (3x)**:
  - 2x Invensense ICM-42670-P (SPI1, SPI2) - 6-axis IMU
  - 1x Bosch BMI270 (SPI3) - 6-axis IMU
- **Barometer**: Bosch BMP390 (I2C4) - Pressure sensor
- **Magnetometer**: Bosch BMM350 (I2C4) - 3-axis compass
- **EEPROM**: 24LC64T (I2C4) - 64Kbit

### Interfaces
- **IO Coprocessor**: PX4IO-V2 (STM32F100)
- **Serial Ports**: 
  - UART1 (GPS1)
  - UART2 (GPS2) 
  - UART3 (GPS3)
  - UART6 (Telemetry)
  - UART8 (PX4IO)
- **CAN**: 2x CAN interfaces
- **Ethernet**: 10/100 Mbps
- **USB**: USB-C (Device mode)
- **SWD**: Debug interface

### Power
- Operating voltage: 5V
- Backup power for RTC

## Building Firmware

### Prerequisites

```bash
# Install ARM GCC toolchain
sudo apt-get install gcc-arm-none-eabi

# Install dependencies
sudo apt-get install python3-pip python3-dev
pip3 install --user pyserial empy toml numpy pandas jinja2 pyyaml pyros-genmsg packaging
```

### Clone Repository

```bash
git clone --recursive https://github.com/lectronuser/PX4-Autopilot.git
cd PX4-Autopilot
git checkout lectron-development-v6x
git submodule update --init --recursive
```

### Build FMU Firmware

```bash
# Clean build (recommended)
rm -rf build/lectron_mfa-01_default
make lectron_mfa-01_default

# Build output:
# build/lectron_mfa-01_default/lectron_mfa-01_default.bin  (Application firmware)
# build/lectron_mfa-01_default/lectron_mfa-01_default.px4  (QGroundControl package)
# build/lectron_mfa-01_default/lectron_mfa-01_default.elf  (Debug symbols)
```

**Build Stats:**
- Flash usage: ~92.27% (1814 KB / 1920 KB)
- RAM usage: ~19% (AXI SRAM)

### Build IO Firmware (PX4IO)

```bash
# Build PX4IO firmware
make px4_io-v2_default

# Build output:
# build/px4_io-v2_default/px4_io-v2_default.bin  (40KB)
```

### Build Bootloader (Optional)

```bash
# Build FMU bootloader
make lectron_fmu-v6x_bootloader

# Build output:
# build/lectron_fmu-v6x_bootloader/lectron_fmu-v6x_bootloader.bin
# Pre-built version available at: boards/lectron/fmu-v6x/extras/lectron_fmu-v6x_bootloader.bin
```

## Flashing Firmware

### Method 1: ST-Link (Recommended for initial flash)

#### Install st-flash tool:
```bash
sudo apt-get install stlink-tools
```

#### Flash Bootloader (First time only):
```bash
# Erase flash
st-flash erase

# Flash bootloader at 0x08000000
st-flash write boards/lectron/fmu-v6x/extras/lectron_fmu-v6x_bootloader.bin 0x08000000
```

#### Flash Application Firmware:
```bash
# Flash firmware at 0x08020000 (after bootloader)
st-flash --reset write build/lectron_fmu-v6x_default/lectron_fmu-v6x_default.bin 0x08020000
```

### Method 2: QGroundControl (After bootloader installed)

1. Connect board via USB
2. Open QGroundControl
3. Go to **Vehicle Setup** > **Firmware**
4. Click **Advanced Settings** > **Custom firmware file**
5. Select `lectron_fmu-v6x_default.px4`
6. Click **OK** to flash

### Method 3: PX4 Upload Tool

```bash
# Upload via USB (bootloader must be installed)
make lectron_fmu-v6x_default upload
```

## Updating PX4IO Firmware

PX4IO firmware is automatically updated by FMU during boot if CRC doesn't match.

**Manual update via NSH console:**

```bash
# Connect to NSH console (USB serial or telemetry)
# Check IO firmware
px4io checkcrc /etc/extras/px4_io-v2_default.bin

# Update if needed
px4io update /etc/extras/px4_io-v2_default.bin

# Start IO manually if not auto-started
px4io start
```

## Memory Map

| Region | Address | Size | Usage |
|--------|---------|------|-------|
| Bootloader | 0x08000000 | 128 KB | FMU Bootloader |
| Application | 0x08020000 | 1792 KB | PX4 Firmware |
| Parameters | Flash MTD | 64 KB | Parameter storage |

## Serial Console Access

### USB Serial (Primary)
```bash
# Linux
screen /dev/ttyACM0 115200

# macOS
screen /dev/tty.usbmodem* 115200
```

### Debug UART (Optional)
Connect FTDI/USB-Serial to UART6:
```bash
screen /dev/ttyUSB0 57600
```

## Initial Setup & Calibration

After flashing, connect to NSH console:

```bash
# Check hardware version
ver hwver

# Check sensors
icm42670p status
bmi270 status
bmm350 status
bmp390 status
px4io status

# Calibrate sensors
commander calibrate accelerometer
commander calibrate gyro
commander calibrate mag
commander calibrate level

# Check system health
commander check
```

## Troubleshooting

### Sensors not detected
```bash
# Check dmesg for errors
dmesg

# Manually start sensor drivers
icm42670p -s -b 1 start
bmi270 -s -b 3 start
bmm350 -I -b 4 start
```

### PX4IO not starting
```bash
# Check IO firmware
px4io checkcrc /etc/extras/px4_io-v2_default.bin

# Manual start
px4io start

# Check status
px4io status
```

### Flash full error
The board uses `CONSTRAINED_FLASH` mode. To reduce flash usage:
- Disable unused modules in `boards/lectron/fmu-v6x/board.cmake`
- Disable unused features in `boards/lectron/fmu-v6x/default.px4board`

### USB not detected
- Check USB cable (must support data)
- Install udev rules (Linux):
```bash
wget https://raw.githubusercontent.com/PX4/PX4-Autopilot/main/Tools/setup/ubuntu.sh -O /tmp/ubuntu.sh
sudo bash /tmp/ubuntu.sh --no-nuttx --no-sim-tools
```

## Pin Mapping

See: `boards/lectron/fmu-v6x/src/board_config.h`

### SPI Buses
- **SPI1**: ICM-42670-P #1 (CS: PI9, INT: PF2)
- **SPI2**: ICM-42670-P #2 (CS: PH5, INT: PA10)
- **SPI3**: BMI270 (CS: PI4, INT: PI6)

### I2C Buses
- **I2C4**: BMP390 (0x77), BMM350 (0x14), 24LC64T (0x50)

## Development

### Adding new features
1. Modify configuration files in `boards/lectron/fmu-v6x/`
2. Rebuild: `make lectron_fmu-v6x_default`
3. Test on hardware
4. Commit changes

### Updating from upstream PX4
```bash
# Add upstream remote (if not already added)
git remote add upstream https://github.com/PX4/PX4-Autopilot.git

# Fetch upstream changes
git fetch upstream

# Merge or rebase
git merge upstream/main
# or
git rebase upstream/main
```

## Support

- **Issues**: https://github.com/lectronuser/PX4-Autopilot/issues
- **PX4 Documentation**: https://docs.px4.io
- **PX4 Forums**: https://discuss.px4.io

## License

PX4 is licensed under BSD-3-Clause. See LICENSE file for details.

## Board Revision History

- **V6X000**: Initial release
  - 3x IMU (2x ICM-42670-P, 1x BMI270)
  - BMM350 magnetometer
  - BMP390 barometer
  - PX4IO support
  - Optimized for multicopter applications
