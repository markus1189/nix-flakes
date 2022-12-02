{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = { self, nixpkgs, ... }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config = {
          allowUnfreePredicate = pkg:
            builtins.elem (nixpkgs.lib.getName pkg) [ "vscode" "teams" ];
        };
      };
      pyPkgs = pkgs.python39Packages;
    in rec {
      packages.x86_64-linux.default = devShells.x86_64-linux.default;
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nodejs-18_x
          vscode
          teams
          python39
          pyPkgs.pip
          pyPkgs.autopep8
          pipenv
          glab
          nodePackages.serverless
        ];
      };
    };
}
