{ pkgs, ... }: let
  ollamaUrl = "http://localhost:11434";
in {
  services.ollama = {
    enable = true;
    user = "ollama";
  };

  services.open-webui = {
    # TODO: Required until https://nixpk.gs/pr-tracker.html?pr=438551
    package = pkgs.nixpkgs-master.open-webui;

    enable = true;
    environment.OLLAMA_API_BASE_URL = ollamaUrl;
    # Disable authentication
    environment.WEBUI_AUTH = "False";
    # Port 8080 is too often used by dev projects. Pick something else.
    port = 1233;
  };

  environment.sessionVariables = {
    OLLAMA_API_BASE_URL = ollamaUrl;
    OLLAMA_WEB_URL = "http://localhost:1233";
  };
}
