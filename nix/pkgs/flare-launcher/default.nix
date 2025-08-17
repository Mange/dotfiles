{ pkgs }:
pkgs.appimageTools.wrapType2 {
  pname = "flare";
  version = "0.1.0";
  src = pkgs.fetchurl {
    url = "https://github.com/ByteAtATime/flare/releases/download/v0.1.0/flare_0.1.0_amd64.AppImage";
    sha256 = "sha256-uASP1JoHD+gUFUxfsEYUd1EdpDfBUO458ict6MRdyDw=";
  };
}
