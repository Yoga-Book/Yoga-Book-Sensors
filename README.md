# Yoga Book Sensors

Yoga Book Sensors supplies the userspace sensor classification required by the
Lenovo Yoga Book YB1-X91L. The tablet exposes four identically named HID
accelerometers across two sensor hubs. Desktop rotation services need to know
which accelerometers belong to the display and which belong to the base.

The project and Debian package are both named `yogabook-sensors`.

## Scope

This package contains only:

- a udev rule that adds the platform instance ID to the sensor hwdb key;
- X91L-scoped display/base accelerometer classifications;
- the physically established base accelerometer mount matrix.

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
sudo apt install ../yogabook-sensors_1.0.0-1_all.deb
sudo reboot
```

After reboot, `udevadm info` must report `ACCEL_LOCATION=display` for instances
`.10` and `.19`, `ACCEL_LOCATION=base` plus the mount matrix for `.11` and
`.20`, and `monitor-sensor --accel` must follow physical display rotation.

See [ATTRIBUTION.md](ATTRIBUTION.md) and [LICENSE](LICENSE) for provenance and
licensing.
