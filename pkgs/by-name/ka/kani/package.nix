{ lib
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  pname = "kani";
  version = "0.41.0";

  src = fetchFromGitHub {
    owner = "model-checking";
    repo = "kani";
    rev = "kani-${version}";
    hash = "sha256-egxEh97LXJDI9PtECxls0pok7ElF/bjri+KhCSR9o8c=";
  };

  cargoHash = "sha256-ow/ioCQ4cGFKEzn3WI8Fi4sBXgGchTXA+/Myv5rnZF0=";

  meta = with lib; {
    description = "Kani Rust Verifier";
    homepage = "https://github.com/model-checking/kani";
    changelog = "https://github.com/model-checking/kani/blob/${src.rev}/CHANGELOG.md";
    license = with licenses; [ asl20 mit ];
    maintainers = with maintainers; [ ];
    mainProgram = "kani";
  };
}
