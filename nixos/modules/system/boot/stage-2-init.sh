#! @shell@

systemConfig=@systemConfig@

export HOME=/root PATH="@path@"

# Figure out whether we are running as part of
# the systemd-based stage 1
systemdStage1=false
if [ "${IN_NIXOS_SYSTEMD_STAGE1:-}" = 1 ]; then
	systemdStage1=true
fi


if ! "${systemdStage1}"; then
    # Process the kernel command line.
    # We are not doing this with systemd stage 1
    # because we don't have /proc yet.
    for o in $(</proc/cmdline); do
        case $o in
            boot.debugtrace)
                # Show each command.
                set -x
                ;;
            resume=*)
                set -- $(IFS==; echo $o)
                resumeDevice=$2
                ;;
        esac
    done


    # Print a greeting.
    echo
    echo -e "\e[1;32m<<< NixOS Stage 2 >>>\e[0m"
    echo

    # Normally, stage 1 mounts the root filesystem read/writable.
    # However, in some environments, stage 2 is executed directly, and the
    # root is read-only.  So make it writable here.
    if [ -z "$container" ]; then
        mount -n -o remount,rw none /
    fi
fi


# Likewise, stage 1 mounts /proc, /dev and /sys, so if we don't have a
# stage 1, we need to do that here.
if [ ! -e /proc/1 ]; then
    specialMount() {
        local device="$1"
        local mountPoint="$2"
        local options="$3"
        local fsType="$4"

        if "${systemdStage1}"; then
            case "${mountPoint}" in
                # We must not overwrite this mount because it's bind-mounted
                # from stage 1's /run
                /run)
                    return
                    ;;
                /sys|/dev|/proc)
                    return
                    ;;
                *)
                    ;;
            esac
        fi

        install -m 0755 -d "$mountPoint"
        mount -n -t "$fsType" -o "$options" "$device" "$mountPoint"
    }
    source @earlyMountScript@
fi


# Also print to stdout to show it in the test runner
if "${systemdStage1}"; then
    echo "booting system configuration ${systemConfig}"
fi
echo "booting system configuration ${systemConfig}" > /dev/kmsg


# Make /nix/store a read-only bind mount to enforce immutability of
# the Nix store.  Note that we can't use "chown root:nixbld" here
# because users/groups might not exist yet.
# Silence chown/chmod to fail gracefully on a readonly filesystem
# like squashfs.
chown -f 0:30000 /nix/store
chmod -f 1775 /nix/store
if [ -n "@readOnlyStore@" ]; then
    if ! [[ "$(findmnt --noheadings --output OPTIONS /nix/store)" =~ ro(,|$) ]]; then
        if [ -z "$container" ]; then
            mount --bind /nix/store /nix/store
        else
            mount --rbind /nix/store /nix/store
        fi
        mount -o remount,ro,bind /nix/store
    fi
fi


# Provide a /etc/mtab.
install -m 0755 -d /etc
test -e /etc/fstab || touch /etc/fstab # to shut up mount
rm -f /etc/mtab* # not that we care about stale locks
ln -s /proc/mounts /etc/mtab


# More special file systems, initialise required directories.
[ -e /proc/bus/usb ] && mount -t usbfs usbfs /proc/bus/usb # UML doesn't have USB by default
install -m 01777 -d /tmp
install -m 0755 -d /var/{log,lib,db} /nix/var /etc/nixos/ \
    /run/lock /home /bin # for the /bin/sh symlink


# Miscellaneous boot time cleanup.
rm -rf /var/run /var/lock
rm -f /etc/{group,passwd,shadow}.lock


# Also get rid of temporary GC roots.
rm -rf /nix/var/nix/gcroots/tmp /nix/var/nix/temproots


# For backwards compatibility, symlink /var/run to /run, and /var/lock
# to /run/lock.
ln -s /run /var/run
ln -s /run/lock /var/lock


if ! "${systemdStage1}"; then
    # Clear the resume device.
    if test -n "$resumeDevice"; then
        mkswap "$resumeDevice" || echo 'Failed to clear saved image.'
    fi


    # Use /etc/resolv.conf supplied by systemd-nspawn, if applicable.
    if [ -n "@useHostResolvConf@" ] && [ -e /etc/resolv.conf ]; then
        resolvconf -m 1000 -a host </etc/resolv.conf
    fi

    # Log the script output to /dev/kmsg or /run/log/stage-2-init.log.
    # Only at this point are all the necessary prerequisites ready for these commands.
    exec {logOutFd}>&1 {logErrFd}>&2
    if test -w /dev/kmsg; then
        exec > >(tee -i /proc/self/fd/"$logOutFd" | while read -r line; do
            if test -n "$line"; then
                echo "<7>stage-2-init: $line" > /dev/kmsg
            fi
        done) 2>&1
    else
        mkdir -p /run/log
        exec > >(tee -i /run/log/stage-2-init.log) 2>&1
    fi
fi


# Run the script that performs all configuration activation that does
# not have to be done at boot time.
echo "running activation script..."
$systemConfig/activate


# Restore the system time from the hardware clock.  We do this after
# running the activation script to be sure that /etc/localtime points
# at the current time zone.
if ! "${systemdStage1}" && [ -e /dev/rtc ]; then
    hwclock --hctosys
fi


# Record the boot configuration.
ln -sfn "$systemConfig" /run/booted-system

# Prevent the booted system from being garbage-collected. If it weren't
# a gcroot, if we were running a different kernel, switched system,
# and garbage collected all, we could not load kernel modules anymore.
ln -sfn /run/booted-system /nix/var/nix/gcroots/booted-system


# Run any user-specified commands.
@shell@ @postBootCommands@


# Ensure systemd doesn't try to populate /etc, by forcing its first-boot
# heuristic off. It doesn't matter what's in /etc/machine-id for this purpose,
# and systemd will immediately fill in the file when it starts, so just
# creating it is enough. This `: >>` pattern avoids forking and avoids changing
# the mtime if the file already exists.
: >> /etc/machine-id


if ! "${systemdStage1}"; then
    # Reset the logging file descriptors.
    exec 1>&$logOutFd 2>&$logErrFd
    exec {logOutFd}>&- {logErrFd}>&-


    # Start systemd in a clean environment.
    echo "starting systemd..."
    exec env - /run/current-system/systemd/lib/systemd/@systemdExecutable@ "$@"
fi
