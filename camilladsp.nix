{ lib
, fetchFromGitHub
, rustPlatform
, darwin
, stdenv
, pkgs
}:

rustPlatform.buildRustPackage rec {
  pname = "camilladsp";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "phlmn";
    repo = pname;
    rev = "db288c3c86e39d8d1d120c1c82b1ef827bfa7c52";
    hash = "sha256-bOegRh7qxRAQJurtXHqqH++WT719lNZRVT8kE/2sFmM=";
  };

  cargoHash = "sha256-eKIIjf/1UikoC+UQbmUphXbO6WA6+O82CcsULuPppQ4=";

  nativeBuildInputs = [ pkgs.pkg-config rustPlatform.bindgenHook ];
  buildInputs = []
  ++ lib.optionals stdenv.isLinux [
    pkgs.alsaLib
  ]
  ++ lib.optionals stdenv.isDarwin (
    with darwin.apple_sdk.frameworks; [
      AudioUnit
      OpenAL
    ]
  );
}
