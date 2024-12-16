{ lib
, stdenv
, fetchFromGitHub
, cmake
# , libxss
, qt6Packages
, kdePackages
}:

stdenv.mkDerivation rec {
  pname = "sane-break";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "AllanChain";
    repo = "sane-break";
    rev = "v${version}";
    sha256 = "sha256-IgbgxSO6f7F4xSjoElR0zkJ0b3XCeGbbIQnK+4yaTJg=";
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
    maintainers = [];
    platforms = platforms.linux;
    mainProgram = "sane-break";
  };
}
