{
  description = "diagrams-builder nix flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    let
      mkApp = pkgs: extraArgs:
        let
          args = {
            root = ./.;
            name = "diagrams-builder";
            returnShellEnv = false;
            cabal2nixOptions =
              "--flag=svg --flag=cairo --flag=-rasterific --flag=-postscript --flag=-ps";
          } // extraArgs;
          pkg = pkgs.haskellPackages.developPackage args;
          withCabal = pkg:
            pkg.overrideAttrs (attrs: {
              buildInputs = attrs.buildInputs ++ [ pkgs.cabal-install ];
            });
        in if args.returnShellEnv then withCabal pkg else pkg;
    in flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages.diagrams-builder = mkApp pkgs { };
        packages.default = packages.diagrams-builder;
        devShells.default = mkApp pkgs { returnShellEnv = true; };
      }) // {
        overlays.default = final: prev: { diagrams-builder = mkApp final { }; };
      };
}
