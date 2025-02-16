#!/usr/bin/env nu

const BUS_NAME = "org.kde.kdeconnect";
const PATH_PREFIX = "/modules/kdeconnect";
const DEVICE_INTERFACE = "org.kde.kdeconnect.device";
const DAEMON_INTERFACE = "org.kde.kdeconnect.daemon";

def dev_path [name: string] {
    $"($PATH_PREFIX)/devices/($name)"
}

def get_device_list [] {
    # org.kde.kdeconnect.daemon.devices (bool onlyReachable, bool onlyPaired)
    dbus call --session --dest=$BUS_NAME --no-introspect $PATH_PREFIX $DAEMON_INTERFACE devices false true --signature=bb
}

def device_info [id: string] {
    dbus get-all --session --dest=$BUS_NAME (dev_path $id) $DEVICE_INTERFACE
}

def get_devices [] {
    get_device_list | each {|it| device_info $it | insert "id" $it}
}

def is_reachable [device: record] {
    $device.isReachable? | default false
}

def supports_battery [device: record] {
    let reachable = is_reachable $device;
    let supported = "kdeconnect_battery" in ($device.supportedPlugins? | default []);
    let exists = dbus introspect --session --dest=$BUS_NAME (dev_path $device.id) | get -i children | default [] | any {|it| $it.name == "battery"}

    $reachable and $supported and $exists
}

def get_battery_info [device: record] {
    if not (supports_battery $device) {
        return null
    }

    dbus get-all --session --dest=$BUS_NAME $"(dev_path $device.id)/battery" $"($DEVICE_INTERFACE).battery"
}

# Everything except phone is a guess here, I don't know
# what the other types are and I can't find any documentation
# on it, we'll just assume laptop for now
const icon_ref = {
    phone: [
        "󰄜",
        "󱎗",
        "󰥍",
    ],
    desktop: [
        "󰌢",
        "󰌢󱐋",
        "󰛧",
    ],
    laptop: [
        "󰌢",
        "󰌢󱐋",
        "󰛧",
    ],
};

def main [] {
    let devices = get_devices;

    let status = $devices | each {|it| 
        
        let name = $it.name? | default "Unknown Device";

        let reachable = is_reachable $it;

        let icons = $icon_ref | get -i ($it.type? | default "") | default $icon_ref.phone;

        let battery_info = get_battery_info $it | default { isCharging: false };

        let icon = $icons | get (if (not $reachable) {
            2
        } else {
            if ($battery_info.isCharging? | default false) {
                1
            } else {
                0
            }
        });

        let percent = if $battery_info.charge? != null and $battery_info.charge != -1 {
            $" ($battery_info.charge)󰏰"
        } else { "" };

        {
            chip: $"($icon)($percent)"
            tooltip: $"($icon) ($name) -($percent)"
        }
    };

    let output = {
        text: ($status | get chip | str join "  "),
        tooltip: ($status | get tooltip | str join "\n"),
        class: "kdeconnect",
    };

    print ($output | to json -r);
}

