{ config, lib, pkgs, ... }:
let
  cfg = config.services.virtuoso;
  virtuosoUser = "virtuoso";
  stateDir = "/var/lib/virtuoso";
in
with lib;
{

  ###### interface

  options = {

    services.virtuoso = with types; {

      enable = mkEnableOption "Virtuoso Opensource database server";

      config = mkOption {
        type = lines;
        default = "";
        description = "Extra options to put into Virtuoso configuration file.";
      };

      parameters = mkOption {
        type = lines;
        default = "";
        description = "Extra options to put into [Parameters] section of Virtuoso configuration file.";
      };

      listenAddress = mkOption {
        type = str;
        default = "1111";
        example = "myserver:1323";
        description = "ip:port or port to listen on.";
      };

      httpListenAddress = mkOption {
        type = nullOr str;
        default = null;
        example = "myserver:8080";
        description = "ip:port or port for Virtuoso HTTP server to listen on.";
      };

      dirsAllowed = mkOption {
        type = nullOr str; # XXX Maybe use a list in the future?
        default = null;
        example = "/www, /home/";
        description = "A list of directories Virtuoso is allowed to access";
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    users.users = singleton
      { name = virtuosoUser;
        uid = config.ids.uids.virtuoso;
        description = "virtuoso user";
        home = stateDir;
      };

    systemd.services.virtuoso = {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        mkdir -p ${stateDir}
        chown ${virtuosoUser} ${stateDir}
      '';

      script = ''
        cd ${stateDir}
        ${pkgs.virtuoso}/bin/virtuoso-t +foreground +configfile ${pkgs.writeText "virtuoso.ini" cfg.config}
      '';
    };

    services.virtuoso.config = ''
      [Database]
      DatabaseFile=${stateDir}/x-virtuoso.db
      TransactionFile=${stateDir}/x-virtuoso.trx
      ErrorLogFile=${stateDir}/x-virtuoso.log
      xa_persistent_file=${stateDir}/x-virtuoso.pxa

      [Parameters]
      ServerPort=${cfg.listenAddress}
      RunAs=${virtuosoUser}
      ${optionalString (cfg.dirsAllowed != null) "DirsAllowed=${cfg.dirsAllowed}"}
      ${cfg.parameters}

      [HTTPServer]
      ${optionalString (cfg.httpListenAddress != null) "ServerPort=${cfg.httpListenAddress}"}
    '';

  };

}
