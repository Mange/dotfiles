{ ... }: {
  services.ollama = {
    enable = true;
    user = "ollama";
  };

  services.open-webui = {
    enable = true;
    environment.OLLAMA_API_BASE_URL = "http://localhost:11434";
    # Disable authentication
    environment.WEBUI_AUTH = "False";
    # Port 8080 is too often used by dev projects. Pick something else.
    port = 1233;
  };
}
