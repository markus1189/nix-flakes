{
  inputs = { nixpkgs.url = "github:nixos/nixpkgs"; };

  outputs = { self, nixpkgs, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      amplify = pkgs.callPackage ./amplify-cli.nix { };
    in {
      devShells.x86_64-linux.default =
        pkgs.mkShell { buildInputs = with pkgs; [ amplify nodejs-18_x ]; };
    };
}
