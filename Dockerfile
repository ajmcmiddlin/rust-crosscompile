FROM fedora:33
WORKDIR /root
RUN dnf install -y git cmake gcc-c++ boost-devel
RUN git clone https://github.com/gsauthof/pe-util
WORKDIR pe-util
RUN git submodule update --init
RUN mkdir build
WORKDIR build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release
RUN make

FROM fedora:33
COPY --from=0 /root/pe-util/build/peldd /usr/bin/peldd
ADD package.sh /usr/bin/package.sh
RUN dnf install -y mingw64-gcc mingw64-winpthreads-static mingw64-glib2-static gcc boost zip && dnf clean all -y
WORKDIR /home/rust
RUN curl https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init -o rustup-init
RUN chmod u+x ./rustup-init
RUN ./rustup-init --target x86_64-pc-windows-gnu --default-toolchain stable -y
ADD cargo.config /home/rust/.cargo/config
ENV PKG_CONFIG_ALLOW_CROSS=1
ENV PKG_CONFIG_PATH=/usr/x86_64-w64-mingw32/sys-root/mingw/lib/pkgconfig/
VOLUME /home/rust/src
WORKDIR /home/rust/src
CMD ["/usr/bin/package.sh"]
