{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Connecting to work VPN
    tailscale

    # HTTP stuff for microservices
    bruno

    # Cloud, k8s, etc.
    terraform
    kubectl
    sops
    (google-cloud-sdk.withExtraComponents ([
      google-cloud-sdk.components.gke-gcloud-auth-plugin
    ]))
    google-cloud-sql-proxy

    # Old cloud env
    awscli2

    # Common DB and misc tooling
    gnumake
    mongodb-compass
    beekeeper-studio
    postgresql
    mariadb
  ];
}
