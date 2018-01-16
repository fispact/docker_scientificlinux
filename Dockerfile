FROM cern/slc6-base
MAINTAINER UKAEA <admin@fispact.ukaea.uk>

# Build-time metadata as defined at http://label-schema.org
ARG PROJECT_NAME
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="$PROJECT_NAME" \
      org.label-schema.description="Scientific Linux docker image for FISPACT-II" \
      org.label-schema.url="http://fispact.ukaea.uk/" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/fispact/docker_scientificlinux" \
      org.label-schema.vendor="UKAEA" \
      org.label-schema.version=$VERSION \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.schema-version="1.0"

ENV RUN_SCRIPT ~/.bashrc

WORKDIR /

# Install additional packages
RUN yum -y update && \
    yum install -y wget which make cmake gmake less doxygen rsync nano tar texi2html texinfo xz && \
    yum install -y libgcc gcc-c++ && \
    yum install -y gmp-devel mpfr-devel libmpc-devel openssl-devel && \
    yum install -y python-devel autoconf automake zlib-devel libpng-devel libjpeg-devel bzip2 zip && \
    yum install -y gsl-devel lapack-devel freetype-devel && \
    yum -y install yum-utils && \
    yum -y groupinstall development && \
    yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel && \
    yum install -y readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel expat-devel && \
    # we must compile gcc ourselves since we can only get gcc-4 from yum
    wget https://ftp.gnu.org/gnu/gcc/gcc-6.2.0/gcc-6.2.0.tar.gz && \
    tar -xzf gcc-6.2.0.tar.gz && \
    mkdir gcc-6.2.0-build && cd gcc-6.2.0-build && \
    ../gcc-6.2.0/configure --enable-languages=c,c++,fortran --disable-multilib && \
    export NCPUS=$(getconf _NPROCESSORS_ONLN) && \
    make -j${NCPUS} && \
    make install && \
    mv /usr/bin/g++ /usr/bin/g++-4 && \
    mv /usr/bin/gcc /usr/bin/gcc-4 && \
    mv /usr/bin/gfortran /usr/bin/gfortran-4 && \
    ln -sf /usr/local/bin/g++-6.2.0 /usr/bin/g++ && \
    ln -sf /usr/local/bin/gcc-6.2.0 /usr/bin/gcc && \
    ln -sf /usr/local/bin/gfortran-6.2.0 /usr/bin/gfortran && \
    cp /usr/local/lib64/libgfortran.* /usr/lib64/ && \
    cp /usr/local/lib64/libquadmath.* /usr/lib64/ && \
    cd / && \
    wget http://python.org/ftp/python/3.6.3/Python-3.6.3.tar.xz && \
    tar xf Python-3.6.3.tar.xz && cd Python-3.6.3 && \
    ./configure --prefix=/usr/local --with-ensurepip=install --enable-optimizations --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib" && \
    make -j${NCPUS} && \
    make altinstall && \
    make install && \
    ln -sf /usr/local/bin/pip3.6 /usr/local/bin/pip && \
    # pip3 packages
    pip install --upgrade pip && \
    pip install pytest pytest-xdist pypact numpy && \
    # clean up
    cd / && rm -rf gcc-6.2.0.tar.gz gcc-6.2.0-build Python-3.6.3.tar.xz Python-3.6.3

CMD /bin/bash $RUN_SCRIPT
