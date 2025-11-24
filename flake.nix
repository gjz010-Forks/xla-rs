{
  description = "Description for the project";

  inputs = {
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/c9b6fb798541223bbb396d287d16f43520250518";
    devenv.url = "github:cachix/devenv";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs =
    inputs@{ flake-parts, devenv-root, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
      ];
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        {

          packages.xla_extension = builtins.fetchTarball {
            url = "https://github.com/elixir-nx/xla/releases/download/v0.8.0/xla_extension-0.8.0-x86_64-linux-gnu-cpu.tar.gz";
            sha256 = "17jcyvxlvgpw1f7n9lz61mjwb8ildbdldqc0rm2b3cmp8dk1kxcc";
          };

          devenv.shells.default = {
            name = "xla-rs";
            packages = [
              config.packages.xla_extension
              pkgs.rustc
              pkgs.cargo
              pkgs.rust-analyzer
              pkgs.rustfmt
              pkgs.nixfmt-rfc-style
              pkgs.nil
              pkgs.rustPlatform.bindgenHook
              pkgs.clippy
            ];
            git-hooks.hooks = {
              clippy.enable = true;
              rustfmt.enable = true;
              nixfmt-rfc-style.enable = true;
            };
            env = {
              LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (
                let
                  xorg = pkgs.xorg;
                in
                [
                  pkgs.stdenv.cc.cc.lib
                  pkgs.zstd
                  pkgs.zlib
                  pkgs.libGL
                  xorg.libX11
                  xorg.libxcb
                  xorg.libXcomposite
                  xorg.libXext
                  pkgs.libxkbcommon
                  xorg.libXrender
                  pkgs.zlib
                  xorg.xcbutilimage
                  xorg.xcbutilkeysyms
                  xorg.libXfixes
                  xorg.libXtst
                  pkgs.fontconfig
                  pkgs.freetype
                  pkgs.gtk3
                  pkgs.gdk-pixbuf
                  pkgs.glib
                  pkgs.pango
                  pkgs.dbus
                ]
              );
            };

          };

        };
      flake = {

      };
    };
}
