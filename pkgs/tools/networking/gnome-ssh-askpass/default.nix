{ stdenv, fetchFromGitLab, meson, ninja, gnome3 }:

stdenv.mkDerivation rec {
  name = "gnome-ssh-askpass-${version}";
  version = "0.0.1";

  src = /home/jtojnar/Projects/gnome-ssh-askpass;
  # src = fetchFromGitLab {
  #   domain = "gitlab.gnome.org";
  #   owner = "jtojnar";
  #   repo = "gnome-ssh-askpass";
  #   rev = "v${version}";
  #   sha1 = "78c992951685d4dbffb77536f37b83ae2a6eafc7";
  # };

  nativeBuildInputs = [ meson ninja ];
  buildInputs = [ gcr ];

  meta = with stdenv.lib; {
    homepage = http://www.jmknoble.net/software/x11-ssh-askpass/;
    description = "Passphrase dialog for GNOME for OpenSSH or other open variants of SSH";

    platforms = stdenv.lib.platforms.unix;
    maintainers = maintainers.jtojnar;
  };
}
