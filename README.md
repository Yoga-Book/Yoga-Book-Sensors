# Yoga Book Sensors

Yoga Book Sensors supplies the userspace sensor classification required by the
Lenovo Yoga Book YB1-X91L. The tablet exposes four identically named HID
accelerometers across two sensor hubs. Desktop rotation services need to know
which accelerometers belong to the display and which belong to the base. The
tablet also exposes an SX9310 capacitive proximity sensor whose hardware near
threshold must be supplied to `iio-sensor-proxy` through hwdb.

The project and Debian package are both named `yogabook-sensors`.

## Scope

This package contains only:

- a udev rule that adds the platform instance ID to the sensor hwdb key;
- X91L-scoped display/base accelerometer classifications;
- physically established display and base accelerometer mount matrices;
- the X91L SX9310 proximity near threshold reported by the kernel driver.

It deliberately contains no keyboard, pen, backlight, audio, firmware, kernel,
or display-touchscreen policy. `iio-sensor-proxy` consumes the resulting udev
properties and is recommended rather than bundled.

## Build and test

Install the build dependencies:

```bash
sudo apt install debhelper devscripts systemd udev
```

Run the isolated hwdb and udev tests:

```bash
make test
```

Build the Debian package:

```bash
make deb
```

## Install

```bash
sudo apt install ../yogabook-sensors_1.0.0-4_all.deb
sudo reboot
```

After reboot, `udevadm info` must report `ACCEL_LOCATION=display` and an
identity mount matrix for instances `.10` and `.19`, `ACCEL_LOCATION=base`
with the base mount matrix for `.11` and `.20`, and `monitor-sensor --accel`
must follow physical display rotation. The SX9310 device must report
`PROXIMITY_NEAR_LEVEL=96`, and SensorProxy must expose proximity support.

See [ATTRIBUTION.md](ATTRIBUTION.md) and [LICENSE](LICENSE) for provenance and
licensing.
