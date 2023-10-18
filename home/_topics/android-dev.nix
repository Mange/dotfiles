{ config, pkgs, inputs, ... }: let
  sdkPath = "${config.xdg.dataHome}/android";
in {
  imports = [
    inputs.android-nixpkgs.hmModule
  ];

  nixpkgs = {
    overlays = [
      inputs.android-nixpkgs.overlays.default
    ];
  };

  home.packages = [
    pkgs.jdk
  ];

  android-sdk = {
    enable = true;
    path = sdkPath;
    packages = sdkPkgs: with sdkPkgs; [
      build-tools-32-0-0
      emulator
      ndk-bundle
      platform-tools
      platforms-android-32
      tools

      system-images-android-32-google-apis-playstore-x86-64

      # Must be after "tools"
      # https://github.com/tadfisher/android-nixpkgs/issues/58
      cmdline-tools-latest
    ];
  };

  home.sessionVariables = {
    ANDROID_HOME = "${sdkPath}";
    ANDROID_SDK_ROOT = "${sdkPath}";
    ANDROID_JAVA_HOME = "${pkgs.jdk.home}";
    ANDROID_AVD_HOME = "${config.xdg.configHome}/.android/avd";
  };
}
