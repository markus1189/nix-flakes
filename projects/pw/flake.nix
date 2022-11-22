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
      pyPkgs = pkgs.python38Packages;
    in {
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nodejs-18_x
          vscode
          teams
          python38
          pyPkgs.pip
          pyPkgs.autopep8
          pipenv
          glab
        ];
      };
    };
}
