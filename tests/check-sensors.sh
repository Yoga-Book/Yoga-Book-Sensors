#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later

set -Eeuo pipefail

root=${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}
temporary_root=$(mktemp -d /tmp/yogabook-sensors-hwdb.XXXXXX)

required_files=(
	ATTRIBUTION.md
	LICENSE
	README.md
	debian/control
	debian/rules
	debian/yogabook-sensors.docs
	debian/yogabook-sensors.install
	debian/yogabook-sensors.postinst
	debian/yogabook-sensors.postrm
	libexec/generate-thermald-config.sh
	systemd/thermald.service.d/10-yogabook-policy.conf
	udev/61-yogabook-sensors.hwdb
	udev/61-yogabook-sensors.rules
)

for required_file in "${required_files[@]}"; do
	test -f "$root/$required_file"
done

for executable_file in \
	debian/rules \
	debian/yogabook-sensors.postinst \
	debian/yogabook-sensors.postrm \
	debian/tests/smoke \
	libexec/generate-thermald-config.sh \
	tests/check-sensors.sh \
	tests/check-thermald.sh; do
	test -x "$root/$executable_file"
done

grep -Fq 'GNU GENERAL PUBLIC LICENSE' "$root/LICENSE"
grep -Fxq 'Package: yogabook-sensors' "$root/debian/control"
grep -Fxq 'ATTRIBUTION.md' "$root/debian/yogabook-sensors.docs"
grep -Fxq 'README.md' "$root/debian/yogabook-sensors.docs"
grep -Fq '61-yogabook-sensors.rules usr/lib/udev/rules.d' \
	"$root/debian/yogabook-sensors.install"
grep -Fq '61-yogabook-sensors.hwdb usr/lib/udev/hwdb.d' \
	"$root/debian/yogabook-sensors.install"
grep -Fq 'generate-thermald-config.sh usr/libexec/yogabook-sensors' \
	"$root/debian/yogabook-sensors.install"

cleanup() {
	rm -rf -- "$temporary_root"
}
trap cleanup EXIT

install -D -m 0644 "$root/udev/61-yogabook-sensors.hwdb" \
	"$temporary_root/etc/udev/hwdb.d/61-yogabook-sensors.hwdb"

systemd-hwdb --root="$temporary_root" --strict update
udevadm verify --no-style --no-summary \
	"$root/udev/61-yogabook-sensors.rules"

query_sensor() {
	local instance=$1
	local product=${2:-LenovoYB1-X91L}

	systemd-hwdb --root="$temporary_root" query \
		"sensor:modalias:platform:HID-SENSOR-200073:id:HID-SENSOR-200073.${instance}.auto:dmi:bvnLENOVO:pn${product}:" || true
}

require_location() {
	local instance=$1
	local expected_location=$2
	local expected_matrix=${3:-}
	local result

	result=$(query_sensor "$instance")
	grep -Fqx "ACCEL_LOCATION=$expected_location" <<<"$result"
	if [[ -n $expected_matrix ]]; then
		grep -Fqx "ACCEL_MOUNT_MATRIX=$expected_matrix" <<<"$result"
	elif grep -Fq 'ACCEL_MOUNT_MATRIX=' <<<"$result"; then
		echo "display sensor $instance unexpectedly has a mount matrix" >&2
		exit 1
	fi
}

require_location 10 display '1, 0, 0; 0, 1, 0; 0, 0, 1'
require_location 11 base '0, 1, 0; -1, 0, 0; 0, 0, 1'
require_location 19 display '1, 0, 0; 0, 1, 0; 0, 0, 1'
require_location 20 base '0, 1, 0; -1, 0, 0; 0, 0, 1'

proximity=$(systemd-hwdb --root="$temporary_root" query \
	'sensor:modalias:acpi:STH9310::dmi:bvnLENOVO:pnLenovoYB1-X91L:' || true)
grep -Fqx 'PROXIMITY_NEAR_LEVEL=96' <<<"$proximity"

if query_sensor 10 LenovoYB1-X90L | grep -Fq 'ACCEL_LOCATION='; then
	echo 'sensor configuration unexpectedly matches YB1-X90L' >&2
	exit 1
fi

if query_sensor 12 | grep -Fq 'ACCEL_LOCATION='; then
	echo 'sensor configuration unexpectedly matches an unknown instance' >&2
	exit 1
fi

if systemd-hwdb --root="$temporary_root" query \
	'sensor:modalias:acpi:STH9310::dmi:bvnLENOVO:pnLenovoYB1-X90L:' |
	grep -Fq 'PROXIMITY_NEAR_LEVEL='; then
	echo 'proximity configuration unexpectedly matches YB1-X90L' >&2
	exit 1
fi

# The udev rule must contain the literal runtime attribute name.
# shellcheck disable=SC2016
grep -Fq ':id:$id:' "$root/udev/61-yogabook-sensors.rules"

echo 'Yoga Book sensor database: PASS'
