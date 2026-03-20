{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  # , libxss
  qt6Packages,
  kdePackages,
}:

stdenv.mkDerivation rec {
  pname = "sane-break";
  version = "0.9.5";

  src = fetchFromGitHub {
    owner = "AllanChain";
    repo = "sane-break";
    rev = "v${version}";
    sha256 = "sha256-4TcUi1WoQ28/RU8fBa8TASycLtzP/ryLRW+ey0/+Xd4=";
  };

  nativeBuildInputs = [
    qt6Packages.wrapQtAppsHook
    cmake
  ];

  buildInputs = [
    # libxss
    kdePackages.layer-shell-qt
    qt6Packages.qtbase
    qt6Packages.qtmultimedia
    qt6Packages.qtwayland
  ];

  meta = with lib; {
    homepage = "https://github.com/AllanChain/sane-break";
    description = "A gentle break reminder that helps you avoid mindlessly skipping breaks.";
    license = licenses.gpl3;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "sane-break";
  };
}
