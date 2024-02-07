{
  description = "radio-schedule-api";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-23.11;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    flake-utils.lib.eachDefaultSystem
      (system:
        let pkgs = import nixpkgs { inherit system; };
        in rec {
          devShells.default = pkgs.mkShell {
            buildInputs = [
              pkgs.nodePackages.prettier
              pkgs.nodePackages.vercel
              pkgs.nodejs
              pkgs.yarn
            ];
          };

          formatter = pkgs.nixpkgs-fmt;

          packages = let
            radio-schedule-api = pkgs.buildNpmPackage rec {
              pname = "kchungradio.org";
              version = "0.1.0.0";
              buildInputs = [
                pkgs.nodejs
              ];
              src = ./.;
              npmDepsHash = "sha256-TtBU/f2VDOV/lplB2YRCy489cnRt4+TPcY/tBM1naOc=";
              npmBuild = "npm run build";

              installPhase = ''
                cp -r .next/standalone $out
                cp -r .next/static $out/.next/static
                cp -r public $out/public
                '';
            };
            in {
            default = radio-schedule-api;
            container = pkgs.dockerTools.buildLayeredImage
              {
                name = "kchungradio.org";
                contents = [ pkgs.nodejs radio-schedule-api ];
                config = {
                  Cmd = [
                    "${pkgs.nodejs}/bin/node"
                    "server.js"
                  ];
                  ExposedPorts = {
                    "3000/tcp" = { };
                  };
                };
              };
          };
        });
}
