{ stdenv, lib, fetchurl }:
stdenv.mkDerivation rec {
  pname = "amplify-cli";
  version = "10.5.1";

  src = fetchurl {
    url =
      "https://github.com/aws-amplify/amplify-cli/releases/download/v${version}/amplify-pkg-linux.tgz";
    hash = "sha256-CsGZ6f8GBj3eD5Y2LcOW/mnp5AvRELa5btheDKAKv3M=";
  };

  unpackPhase = ''
    mkdir -p $out/bin
    tar --no-overwrite-dir -xvf $src -C $out/bin/
    mv -v $out/bin/amplify-pkg-linux $out/bin/amplify
  '';


  buildPhase = ":";

  installPhase = ":";

  # Managed to make it work thanks to https://github.com/brendan-hall/nixpkgs/blob/e3b313bb59f49f10970205aafd44878d35da07e7/pkgs/development/web/now-cli/default.nix
  dontStrip = true;
  preFixup =
    let
      libPath = lib.makeLibraryPath [ stdenv.cc.cc ];
    in
    ''
      orig_size=$(stat --printf=%s $out/bin/amplify)
      echo "Original Size: $orig_size"
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/amplify
      patchelf --set-rpath ${libPath} $out/bin/amplify
      chmod +x $out/bin/amplify
      new_size=$(stat --printf=%s $out/bin/amplify)
      echo "New Size: $new_size"

      ###### pkg fixing starts here.
      # we're replacing plaintext js code that looks like
      # PAYLOAD_POSITION = '1234                  ' | 0
      # [...]
      # PRELUDE_POSITION = '1234                  ' | 0
      # ^-----20-chars-----^^------22-chars------^
      # ^-- grep points here
      #
      # var_* are as described above
      # shift_by seems to be safe so long as all patchelf adjustments occur
      # before any locations pointed to by hardcoded offsets
      var_skip=20
      var_select=22
      shift_by=$(expr $new_size - $orig_size)

      function fix_offset {
        # $1 = name of variable to adjust
        location=$(grep -obUam1 "$1" $out/bin/amplify | cut -d: -f1)
        location=$(expr $location + $var_skip)
        value=$(dd if=$out/bin/amplify iflag=count_bytes,skip_bytes skip=$location \
                   bs=1 count=$var_select status=none)
        value=$(expr $shift_by + $value)
        echo -n $value | dd of=$out/bin/amplify bs=1 seek=$location conv=notrunc
      }

      fix_offset PAYLOAD_POSITION
      fix_offset PRELUDE_POSITION
    '';
}
