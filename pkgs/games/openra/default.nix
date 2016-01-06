{ stdenv, fetchFromGitHub, mono, makeWrapper, lua, dotnetPackages, SDL2,
  freetype, openal, systemd, pkgconfig }:

stdenv.mkDerivation rec {
  name = "openra-${version}";
  version = "20151224";

  src = fetchFromGitHub {
    owner = "OpenRA";
    repo = "OpenRA";
    rev = "release-${version}";
    sha256 = "1kx9h2vv8z33jsqsv3c5vsqjihpxf6bqdakbwaz98mks2sxhkyr7";
  };

  dontStrip = true;

  buildInputs = [
    lua
    dotnetPackages.SharpZipLib
    dotnetPackages.MaxMindDb
    dotnetPackages.MaxMindGeoIP2
    dotnetPackages.FuzzyLogicLibrary
    dotnetPackages.SmartIrc4net
  ];

  nativeBuildInputs = [ mono makeWrapper lua pkgconfig ];

  patchPhase = ''
    sed -i 's/^VERSION.*/VERSION = release-${version}/g' Makefile
  '';

  preConfigure = ''
    makeFlags="prefix=$out"
    make version
  '';

  postInstall = with stdenv.lib; let
    runtime = makeLibraryPath [ SDL2 freetype openal systemd lua ];
  in ''
    wrapProgram $out/lib/openra/launch-game.sh \
      --prefix PATH : "${mono}/bin" \
      --set PWD $out/lib/openra/ \
      --prefix LD_LIBRARY_PATH : "${runtime}"

    mkdir -p $out/bin
    cat > "$out/bin/openra" << EOF
    #!${stdenv.shell}
    cd $out/lib/openra && $out/lib/openra/launch-game.sh
    EOF
    chmod +x $out/bin/openra
  '';

  meta = with stdenv.lib; {
    description = "Real Time Strategy game engine recreates the C&C titles";
    homepage    = "http://www.open-ra.org/";
    license     = licenses.gpl3;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ iyzsong ];
  };
}
