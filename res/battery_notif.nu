#!/usr/bin/env nu

const BUS_NAME = "org.freedesktop.UPower";
const PATH_PREFIX = "/org/freedesktop/UPower";

def list_all_devices [] {
    dbus call --system --dest=$BUS_NAME $PATH_PREFIX org.freedesktop.UPower EnumerateDevices
}

def device_info [name: string] {
    dbus get-all --system --dest=$BUS_NAME $"($PATH_PREFIX)/devices/($name)" $"($BUS_NAME).Device"
}

def should_consider [device: record] {
    match $device.Type {
        2 => $device.PowerSupply, # Battery, we want to make sure PowerSupply is true to ensure it's a laptop battery
        17 => true # Bluetooth Headset
        _ => false # Assume false otherwise, more device types in the future maybe
    }
}


def get_name [device: record] {

    let fallback = "(" + ($device.upower_path | path basename) + ")";

    match $device.Type {
        2 => { 
            # Battery, we want to make sure PowerSupply is true
            # as that signifies it's an internal laptop battery
            if $device.PowerSupply {
                $"Internal Battery \(($device.NativePath)\)"
            } else {
                $"Unknown Battery ($fallback)"
            }
        }
        17 => {
            # Bluetooth Headset
            # Take the Model property (bluez sets this to the name) if available, else fallback
            ($device.Model? | default $"Bluetooth Headset ($fallback)")
        }
        _ => {
            $"Unknown Device ($fallback)"
        }
    }
}

def list_devices [] {
    let devices = list_all_devices;
    $devices | each {|it| device_info ($it | path basename) | insert "upower_path" $it} | each {|it| $it | insert "friendly_name" (get_name $it)} | where {|it| should_consider $it}
}

const WARN_LEVEL = 10.0

def should_display_notif [device: record] {

    let charging = match ($device.State? | default 0) {
        1 | 4 | 5 => true, # Charging or Fully Charged or Pending Charge
        _ => false
    }

    ($device.Percentage? | default 100) < $WARN_LEVEL and not $charging
}

def main [poll_interval: duration = 1min] {

    mut shown_notifs = [{}];

    loop {

        let devices = list_devices;

        print "===========" "Device List" ($devices | select friendly_name upower_path Type) "-----------";

        for dev in $devices {
            if (($shown_notifs | get -i $dev.upower_path | get -i 0) == null) {
                $shown_notifs = ($shown_notifs | insert $dev.upower_path false);
            }

            let has_shown_notif = $shown_notifs | get -i $dev.upower_path | get -i 0;

            if ((should_display_notif $dev) and not $has_shown_notif) {
                #print $"Device ($dev.friendly_name) is below 10% charge, showing notification";
                notify-send --icon="battery-caution-symbolic" --app-name="battery-notif" --urgency="critical" $"Battery Low" $"Device (get_name $dev) is below ($WARN_LEVEL)% charge";
                $shown_notifs = ($shown_notifs | update $dev.upower_path true);
            } else if ($has_shown_notif) {
                #print $"Device ($dev.friendly_name) is now above 10% charge, removing notification shown";
                $shown_notifs = ($shown_notifs | update $dev.upower_path false);
            }
        }

        #print "===========";

        sleep $poll_interval;

    }

}
