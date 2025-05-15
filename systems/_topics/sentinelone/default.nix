{ pkgs, lib, config, ... }:
let
  email = "magnus.bergmark@instabee.com";
  dataDir = "/var/lib/sentinelone";

  sentinelone = pkgs.stdenv.mkDerivation {
    pname = "sentinelone";
    version = "25.1.2.17";

    src = ./SentinelAgent_linux_x86_64_v25_1_2_17.deb;

    nativeBuildInputs = with pkgs; [
      autoPatchelfHook
      zlib
      dpkg
      elfutils
      dmidecode
      jq
      gcc-unwrapped
    ];

    sourceRoot = ".";
    unpackPhase = ''
      runHook preUnpack
      dpkg-deb -x "$src" .
      runHook postUnpack
    '';

    installPhase = ''
      mkdir -p $out/opt/
      mkdir -p $out/cfg/
      mkdir -p $out/bin/

      cp -r ./opt/* $out/opt

      ln -s $out/opt/sentinelone/bin/sentinelctl $out/bin/sentinelctl
      ln -s $out/opt/sentinelone/bin/sentinelone-agent $out/bin/sentinelone-agent
      ln -s $out/opt/sentinelone/bin/sentinelone-watchdog $out/bin/sentinelone-watchdog
      ln -s $out/opt/sentinelone/lib $out/lib
    '';

    preFixup = ''
      patchelf --replace-needed libelf.so.0 libelf.so $out/opt/sentinelone/lib/libbpf.so
    '';
  };
  initScript = pkgs.writeShellScriptBin "sentinelone-init" ''
    set -euo pipefail

    # Create the data directory
    mkdir -p "${dataDir}"

    if [ -z "$(ls -A "${dataDir}" 2>/dev/null)" ]; then
      find "${sentinelone}/opt/sentinelone/" \
        -mindepth 1 -maxdepth 1 \
        ! -name "bin" \
        ! -name "ebpfs" \
        ! -name "lib" \
        ! -name "ranger" \
        -exec cp -r {} "${dataDir}" \;

      cat <<EOF >"${dataDir}/configuration/installation_params.json"
    {
      "PACKAGE_TYPE": "deb",
      "SERVICE_TYPE": "systemd"
    }
    EOF

      serialNumber="$(${pkgs.dmidecode}/bin/dmidecode -s system-serial-number)"

      cat <<EOF >"${dataDir}/configuration/install_config"
    S1_AGENT_MANAGEMENT_TOKEN=$(cat ${config.sops.secrets.sentinelone_token.path})
    S1_AGENT_DEVICE_TYPE=desktop
    S1_AGENT_AUTO_START=true
    S1_AGENT_CUSTOMER_ID=${email}-$serialNumber
    EOF

      token="$(base64 -d <"${config.sops.secrets.sentinelone_token.path}")"
      siteKey="$(echo "$token" | ${lib.getExe pkgs.jq} '.site_key')"
      url="$(echo "$token" | ${lib.getExe pkgs.jq} '.url')"
      cat <<EOF >"${dataDir}/configuration/basic.conf"
    {
      "mgmt_device-type": 1,
      "mgmt_site-key": $siteKey,
      "mgmt_url": $url,
    }
    EOF

      chown -R sentinelone:sentinelone "${dataDir}"
      chmod -R 0755 "${dataDir}"
    fi
  '';
in {
  environment.systemPackages = [ sentinelone ];

  sops.age.keyFile = "/home/mange/.config/sops/age/keys.txt";
  sops.secrets.sentinelone_token = {
    sopsFile = ./secrets/sentinelone.yaml;
    format = "yaml";
    key = "token";
  };

  users = {
    groups.sentinelone = {};
    users.sentinelone = {
      isSystemUser = true;
      createHome = true;
      group = "sentinelone";
      shell = "${pkgs.shadow}/bin/nologin";
    };
  };

  systemd.services = {
    sentinelone-init = {
      description = "Initialize SentinelOne Agent";
      wantedBy = ["sentinelone.service"];
      before = ["sentinelone.service"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe initScript}";
      };
    };

    sentinelone = {
      enable = true;
      path = with pkgs; [
        coreutils-full
        gawk
        zlib
        libelf
        bash
      ];
      unitConfig = {
        Description = "Monitor SentinelOne Agent";
        After = ["uptrack-prefetch.service" "uptrack.service"];
      };

      serviceConfig = {
        Type = "exec";
        ExecStart = "${sentinelone}/bin/sentinelone-agent";
        # ExecStop ="${sentinelone}/bin/sentinelctl control stop";
        WorkingDirectory = "/opt/sentinelone/bin";
        SyslogIdentifier = "${dataDir}/log";
        WatchdogSec = "30s";
        Restart = "on-failure";
        KillMode = "process";
        MemoryMax = "18446744073709543424";

        # NOTICE:
        # 1) prefer StartLimitInterval on StartLimitIntervalSec since the last
        #   is supported from systemd v230 and above.
        # 2) following options are synchronized with similar parameters at sysvinit watchdog
        #   this is to ensure similar behavior of systemd and sysvinit watcgdogs
        # StartLimitInterval=90;
        StartLimitBurst=4;
        RestartSec=4;

        # Enable memory accounting to create the cgroup files
        MemoryAccounting="yes";

        NotifyAccess="all";

        # Dont limit the maximum number of tasks that may be created
        TasksMax="infinity";

        BindPaths = [
          "${dataDir}:/opt/sentinelone"
        ];
        BindReadOnlyPaths = [
          "${sentinelone}/opt/sentinelone/bin:/opt/sentinelone/bin"
          "${sentinelone}/opt/sentinelone/lib:/opt/sentinelone/lib"
          "${sentinelone}/opt/sentinelone/ebpfs:/opt/sentinelone/ebpfs"
          "${sentinelone}/opt/sentinelone/ranger:/opt/sentinelone/ranger"
        ];
      };

      wantedBy = ["multi-user.target"];
    };
  };
}
