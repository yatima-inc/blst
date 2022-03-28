{
  inputs = {
    nixpkgs.url = github:nixos/nixpkgs;
    flake-utils = {
      url = github:numtide/flake-utils;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};
      
      name = "blst";
      src = ./.;
      project = pkgs.stdenv.mkDerivation {
        inherit src name;
        buildPhase = ''
          ./build.sh
        '';
        installPhase = ''
          mkdir -p $out/lib
          cp libblst.a $out/lib
        '';
      };
    in
    {
      packages.${name} = project;

      defaultPackage = self.packages.${system}.${name};

      # To run with `nix run`
      apps.${name} = flake-utils.lib.mkApp {
        drv = project;
      };

      # `nix develop`
      devShell = pkgs.mkShell {
        inputsFrom = builtins.attrValues self.packages.${system};
        nativeBuildInputs = [ ];
        buildInputs = with pkgs; [
        ];
      };
    });
}
