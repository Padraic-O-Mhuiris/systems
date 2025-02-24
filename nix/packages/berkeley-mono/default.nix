{
  lib,
  requireFile,
  stdenvNoCC,
  unzip,
  # create your own name to help reference ð style you downloaded
  # variant ? "ligaturesoff-0variant1-7variant0",
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "berkeley-mono";
  version = "1.009";

  src = requireFile {
    name = "${finalAttrs.pname}.zip";
    sha256 = "0w702gjd9v9nq2va9ph072xsvc7qn7nhw7zb6hf8wiikrjiz46a2";
    message = "";
  };

  nativeBuildInputs = [unzip];

  unpackPhase = ''
    unzip $src
  '';

  outputs = [
    "out"
    "web"
    "variable"
    "variableweb"
  ];

  installPhase = ''
    runHook preInstall

    install -D -m444 -t $out/share/fonts/opentype berkeley-mono/OTF/*.otf
    install -D -m444 -t $out/share/fonts/truetype berkeley-mono/TTF/*.ttf
    install -D -m444 -t $web/share/fonts/webfonts berkeley-mono/WEB/*.woff2
    install -D -m444 -t $variable/share/fonts/truetype berkeley-mono-variable/TTF/*.ttf
    install -D -m444 -t $variableweb/share/fonts/webfonts berkeley-mono-variable/WEB/*.woff2

    runHook postInstall
  '';

  meta = {
    description = "Berkeley Mono Typeface";
    longDescription = "…";
    homepage = "https://berkeleygraphics.com/typefaces/berkeley-mono";
    # license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
})
