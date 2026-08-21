# Attribution and provenance

Yoga Book Sensors is a domain-specific continuation of the sensor integration
originally distributed in Yauhen Kharuzhy's
[`yogabook-support`](https://github.com/jekhor/yogabook-support) project.

The following hardware facts and implementation elements were derived from
`yogabook-support` 1.6.1:

- HID accelerometer instances `.10` and `.19` are in the display;
- HID accelerometer instances `.11` and `.20` are in the base;
- the base mount matrix is `0, 1, 0; -1, 0, 0; 0, 0, 1`;
- the udev hwdb lookup includes the platform-device instance ID because the
  four accelerometers otherwise have the same HID sensor modalias.

That work is copyright 2020-2025 Yauhen Kharuzhy and is retained under
GPL-2.0-or-later. This project narrows the DMI match to the physically verified
Lenovo YB1-X91L, adds the display mount matrix established from real-device
axis and GNOME orientation evidence, separates sensor policy from unrelated
subsystems, and adds deterministic matching and Debian-package tests.
