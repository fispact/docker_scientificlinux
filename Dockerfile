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
RUN yum -y update
RUN yum install -y wget which make cmake less doxygen rsync nano tar texi2html texinfo xz
RUN yum install -y libgcc gcc-c++
RUN yum install -y gmp-devel mpfr-devel libmpc-devel openssl-devel

RUN yum install -y python-devel autoconf automake zlib-devel libpng-devel libjpeg-devel bzip2 zip
RUN yum install -y gsl-devel lapack-devel freetype-devel

RUN yum -y install yum-utils
RUN yum -y groupinstall development
RUN yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel expat-devel

# we must compile gcc ourselves since we can only get gcc-4 from yum
RUN wget https://ftp.gnu.org/gnu/gcc/gcc-6.2.0/gcc-6.2.0.tar.gz
RUN tar -xzf gcc-6.2.0.tar.gz
RUN mkdir gcc-6.2.0-build

WORKDIR /gcc-6.2.0-build

RUN ../gcc-6.2.0/configure --enable-languages=c,c++,fortran --disable-multilib
RUN make -j4
RUN make install

RUN ln -s /usr/bin/g++ /usr/local/bin/g++-6.2.0
RUN ln -s /usr/bin/gcc /usr/local/bin/gcc-6.2.0
RUN ln -s /usr/bin/gfortran /usr/local/bin/gfortran-6.2.0

WORKDIR /

RUN wget http://python.org/ftp/python/3.6.3/Python-3.6.3.tar.xz
RUN tar xf Python-3.6.3.tar.xz
WORKDIR /Python-3.6.3
RUN ./configure --prefix=/usr/local --with-ensurepip=install --enable-optimizations --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"
RUN make && make altinstall
RUN make install

# pip3 packages
RUN pip install --upgrade pip
RUN pip install pytest pytest-xdist pypact numpy

CMD /bin/bash $RUN_SCRIPT
