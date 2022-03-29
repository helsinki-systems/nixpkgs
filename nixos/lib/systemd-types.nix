{ lib, systemdUtils }:

with systemdUtils.lib;
with systemdUtils.unitOptions;
with lib;

rec {
  units = with types;
    attrsOf (submodule ({ name, config, ... }: {
      options = concreteUnitOptions;
      config = { unit = mkDefault (systemdUtils.lib.makeUnit name config); };
    }));

  services = with types; attrsOf (submodule [ { options = serviceOptions false; } unitConfig serviceConfig ]);
  initrdServices = with types; attrsOf (submodule [ { options = serviceOptions true; } unitConfig initrdServiceConfig ]);

  targets = with types; attrsOf (submodule [ { options = targetOptions false; } unitConfig ]);
  initrdTargets = with types; attrsOf (submodule [ { options = targetOptions true; } unitConfig ]);

  sockets = with types; attrsOf (submodule [ { options = socketOptions false; } unitConfig ]);
  initrdSockets = with types; attrsOf (submodule [ { options = socketOptions true; } unitConfig ]);

  timers = with types; attrsOf (submodule [ { options = timerOptions false; } unitConfig ]);
  initrdTimers = with types; attrsOf (submodule [ { options = timerOptions true; } unitConfig ]);

  paths = with types; attrsOf (submodule [ { options = pathOptions false; } unitConfig ]);
  initrdPaths = with types; attrsOf (submodule [ { options = pathOptions true; } unitConfig ]);

  slices = with types; attrsOf (submodule [ { options = sliceOptions false; } unitConfig ]);
  initrdSlices = with types; attrsOf (submodule [ { options = sliceOptions true; } unitConfig ]);

  mounts = with types; listOf (submodule [ { options = mountOptions false; } unitConfig mountConfig ]);
  initrdMounts = with types; listOf (submodule [ { options = mountOptions true; } unitConfig mountConfig ]);

  automounts = with types; listOf (submodule [ { options = automountOptions false; } unitConfig automountConfig ]);
  initrdAutomounts = with types; listOf (submodule [ { options = automountOptions true; } unitConfig automountConfig ]);
}
