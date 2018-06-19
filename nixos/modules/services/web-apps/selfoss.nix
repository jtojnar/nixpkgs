{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.selfoss;

  poolName = "selfoss_pool";
  phpfpmSocketName = "/var/run/phpfpm/${poolName}.sock";

  dataDir = "/var/lib/selfoss";

  db_type = cfg.database.type;
  default_port = if db_type == "mysql" then 3306 else 5342;

  dbConfiguration =
    if db_type == "sqlite" then {
      SELFOSS_DB_FILE = "${dataDir}/sqlite/selfoss.db";
    } else {
      SELFOSS_DB_TYPE = db_type;
      SELFOSS_DB_HOST = cfg.database.host;
      SELFOSS_DB_DATABASE = cfg.database.name;
      SELFOSS_DB_USERNAME = cfg.database.user;
      SELFOSS_DB_PASSWORD = cfg.database.password;
      SELFOSS_DB_PORT = if cfg.database.port != null then cfg.database.port else default_port;
    };

  configurationEnvVars = {
    SELFOSS_DATADIR = dataDir;
    SELFOSS_BASEDIR = "${dataDir}/public";
    SELFOSS_CACHE = "/tmp";
    SELFOSS_LOGGER_DESTINATION = "error_log";
  } // dbConfiguration // (mapAttrs' (name: value: nameValuePair ("SELFOSS_" + toUpper name) value) cfg.extraConfig);
in {
  options = {
    services.selfoss = {
      enable = mkEnableOption "selfoss";

      user = mkOption {
        type = types.str;
        default = "nginx";
        example = "nginx";
        description = ''
          User account under which both the service and the web-application run.
        '';
      };

      pool = mkOption {
        type = types.str;
        default = "${poolName}";
        description = ''
          Name of existing phpfpm pool that is used to run web-application.
          If not specified a pool will be created automatically with
          default values.
        '';
      };

      virtualHost = mkOption {
        type = types.nullOr types.str;
        default = "selfoss";
        description = ''
          Name of the nginx virtualhost to use and setup. If null, do not setup any virtualhost.
        '';
      };

      database = {
        type = mkOption {
          type = types.enum ["pgsql" "mysql" "sqlite"];
          default = "sqlite";
          description = ''
            Database to store feeds. Supported are sqlite, pgsql and mysql.
          '';
        };

        host = mkOption {
          type = types.str;
          default = "localhost";
          description = ''
            Host of the database (has no effect if type is "sqlite").
          '';
        };

        name = mkOption {
          type = types.str;
          default = "tt_rss";
          description = ''
            Name of the existing database (has no effect if type is "sqlite").
          '';
        };

        user = mkOption {
          type = types.str;
          default = "tt_rss";
          description = ''
            The database user. The user must exist and has access to
            the specified database (has no effect if type is "sqlite").
          '';
        };

        password = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
            The database user's password (has no effect if type is "sqlite").
          '';
        };

        port = mkOption {
          type = types.nullOr types.int;
          default = null;
          description = ''
            The database's port. If not set, the default ports will be
            provided (5432 and 3306 for pgsql and mysql respectively)
            (has no effect if type is "sqlite").
          '';
        };
      };
      extraConfig = mkOption {
        type = types.attrsOf types.str;
        default = {};
        example = { items_perpage = "50"; };
        description = ''
          Extra configuration added to config.ini
        '';
      };
    };
  };

  config = mkIf cfg.enable {

    services.phpfpm.poolConfigs = mkIf (cfg.pool == poolName) {
      "${poolName}" = ''
        listen = "${phpfpmSocketName}";
        listen.owner = nginx
        listen.group = nginx
        listen.mode = 0600
        user = nginx
        pm = dynamic
        pm.max_children = 75
        pm.start_servers = 10
        pm.min_spare_servers = 5
        pm.max_spare_servers = 20
        pm.max_requests = 500
        catch_workers_output = 1

        php_value[variables_order] = EGPCS
        ${concatStringsSep "\n" (mapAttrsToList (name: value: "env[${name}] = \"${value}\"") configurationEnvVars)}
      '';
    };

    # NOTE: No configuration is done if not using virtual host
    services.nginx = mkIf (cfg.virtualHost != null) {
      enable = true;
      virtualHosts = {
        "${cfg.virtualHost}" = {
          root = "${pkgs.selfoss}";

          locations."/" = {
            index = "index.php";
            tryFiles = "$uri /public/$uri /index.php$is_args$args";
          };

          locations."~ \\.php$" = {
            extraConfig = ''
              fastcgi_split_path_info ^(.+\.php)(/.+)$;
              fastcgi_pass unix:${phpfpmSocketName};
              fastcgi_index index.php;
              fastcgi_param SCRIPT_FILENAME $document_root/$fastcgi_script_name;
              include ${pkgs.nginx}/conf/fastcgi_params;
            '';
          };
          locations."~* \\ (gif|jpg|png)" = {
            extraConfig = ''
              expires 30d;
            '';
          };
          locations."~ ^/(favicons|thumbnails)/.*$" = {
            extraConfig = ''
              try_files $uri /data/$uri;
            '';
          };
          locations."~* ^/(data\\/logs|data\\/sqlite|config\\.ini|\\.ht)" = {
            extraConfig = ''
              deny all;
            '';
          };
          extraConfig = ''
            error_log syslog:server=unix:/dev/log debug;
            access_log syslog:server=unix:/dev/log;
            access_log on;
          '';
        };
      };
    };

    systemd.services.selfoss-update = {
      serviceConfig = {
        ExecStart = "${pkgs.php}/bin/php ${pkgs.selfoss}/cliupdate.php";
        User = "${cfg.user}";
      };
      startAt = "hourly";
      after = [ "selfoss-config.service" ];
      wantedBy = [ "multi-user.target" ];
      environment = configurationEnvVars;
    };

    systemd.tmpfiles.rules = [
      "d ${dataDir} 0755 ${cfg.user} nginx -"
    ];
  };
}
