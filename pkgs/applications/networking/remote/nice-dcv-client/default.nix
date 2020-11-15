{ stdenv, fetchurl, patchelf, bash,  glib
  , libX11, gst_all_1, sqlite, epoxy, pango, cairo, gdk-pixbuf, e2fsprogs, libkrb5, libva, openssl
  , pcsclite, gtk3, libselinux, libxml2
  , python3Packages
  , cpio
}:

stdenv.mkDerivation rec {
  name = "nice-dcv-client-${version}";
  version = "2020.2.1737-1";

  src =
    fetchurl {
      url = "https://d1uj6qtbmh3dt5.cloudfront.net/2020.2/Clients/nice-dcv-viewer-${version}.el8.x86_64.rpm";
      sha256 = "sha256-SUpfHd/Btc07cfjc3zx5I5BiNatr/c4E2/mfJuU4R1E=";
    };

  nativeBuildInputs = [ patchelf python3Packages.rpm];
  buildCommand = ''
    mkdir -p $out/bin/
    libexecdir=usr/libexec/dcvviewer/

    cd $out
    rpm2cpio $src | ${cpio}/bin/cpio -idm

    patchelf \
      --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      $libexecdir/dcvviewer

    libdir=usr/lib64
    ln -s ${stdenv.lib.makeLibraryPath [libselinux]}/libselinux.so.1 $libdir/
    ln -s ${stdenv.lib.makeLibraryPath [libkrb5]}/libgssapi_krb5.so.2 $libdir/
    ln -s ${stdenv.lib.makeLibraryPath [libkrb5]}/libkrb5.so.3 $libdir/
    ln -s ${stdenv.lib.makeLibraryPath [libkrb5]}/libk5crypto.so.3 $libdir/
    ln -s ${stdenv.lib.makeLibraryPath [libxml2]}/libxml2.so.2 $libdir/
    ln -s ${stdenv.lib.makeLibraryPath [sqlite]}/libsqlite3.so.0 $libdir/
    ln -s ${stdenv.lib.makeLibraryPath [gst_all_1.gstreamer]}/libgstreamer-1.0.so.0 $libdir/
    ln -s ${stdenv.lib.makeLibraryPath [gst_all_1.gst-plugins-base]}/libgstapp-1.0.so.0 $libdir/
    ln -s ${stdenv.lib.makeLibraryPath [gst_all_1.gst-plugins-base]}/libgstaudio-1.0.so.0 $libdir/
    ln -s ${stdenv.lib.makeLibraryPath [e2fsprogs]}/libcom_err.so.2 $libdir/
    ln -s ${stdenv.lib.makeLibraryPath [libX11]}/libX11.so.6 $libdir/
    ln -s ${stdenv.lib.makeLibraryPath [libva]}/libva.so.2 $libdir/
    ln -s ${stdenv.lib.makeLibraryPath [libva]}/libva-drm.so.2 $libdir/
    ln -s ${stdenv.lib.makeLibraryPath [libva]}/libva-x11.so.2 $libdir/
    ln -s ${stdenv.lib.makeLibraryPath [openssl]}/libcrypto.so.1.1 $libdir/
    ln -s ${stdenv.lib.makeLibraryPath [openssl]}/libssl.so.1.1 $libdir/
    ln -s ${stdenv.lib.makeLibraryPath [pcsclite]}/libpcsclite.so.1 $libdir/
    ln -s ${stdenv.lib.makeLibraryPath [gtk3]}/libgtk-3.so.0 $libdir/
    ln -s ${stdenv.lib.makeLibraryPath [gtk3]}/libgdk-3.so.0 $libdir/
    ln -s ${stdenv.lib.makeLibraryPath [cairo]}/libcairo.so.2 $libdir/
    ln -s ${stdenv.lib.makeLibraryPath [epoxy]}/libepoxy.so.0 $libdir/
    ln -s ${stdenv.lib.makeLibraryPath [pango]}/libpango-1.0.so.0 $libdir/
    ln -s ${stdenv.lib.makeLibraryPath [pango]}/libpangocairo-1.0.so.0 $libdir/
    ln -s ${stdenv.lib.makeLibraryPath [gdk-pixbuf]}/libgdk_pixbuf-2.0.so.0 $libdir/

    mv $out/usr/bin/dcvviewer $out/bin/dcvviewer
    sed -i "s#basedir=/usr#basedir=$out/usr#" $out/bin/dcvviewer
    ln -s $out/usr/share $out/share
    ${glib.dev}/bin/glib-compile-schemas $out/share/glib-2.0/schemas
    patchShebangs $out
  '';

  meta = with stdenv.lib; {
    description = "NICE DCV is a high-performance remote display protocol that provides customers with a secure way to deliver remote desktops and application streaming from any cloud or data center to any device, over varying network conditions";
    homepage = "https://aws.amazon.com/hpc/dcv/";
    license = licenses.unfree;
    platforms = stdenv.lib.platforms.linux;
    maintainers = [ maintainers.rmcgibbo ];
  };
}
