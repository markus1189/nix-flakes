{
  inputs = { nixpkgs.url = "github:nixos/nixpkgs"; };

  outputs = { self, nixpkgs, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      amplify = pkgs.callPackage ./amplify-cli.nix { };
    in rec {
      packages.x86_64-linux.default = amplify;
      devShells.x86_64-linux.default =
        pkgs.mkShell { buildInputs = [ packages.x86_64-linux.default ]; };
    };
}
