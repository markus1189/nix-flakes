{
  description = "A very basic flake";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
          myWine = pkgs.wineWowPackages.stagingFull;
      in rec {
        default = devShell;
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            myWine
            winetricks
            samba
          ];

          shellHook = ''
            alias s="make start"
            alias e="make stop"
          '';
        };
      });
}
