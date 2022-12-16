{
  inputs = { nixpkgs.url = "github:nixos/nixpkgs"; };

  outputs = { self, nixpkgs, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      myWine = pkgs.wineWowPackages.stagingFull;
    in rec {
      packages.x86_64-linux.default = devShells.x86_64-linux.default;
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = with pkgs; [ myWine winetricks samba ];

        shellHook = ''
          alias s="make start"
          alias e="make stop"
        '';
      };
    };
}
