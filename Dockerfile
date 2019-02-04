FROM ubuntu:16.04
MAINTAINER Barry Warsaw <barry@python.org>

# Enable source repositories so we can use `apt build-dep` to get all the
# build dependencies for Python 2.7 and 3.5.
RUN sed -i -- 's/#deb-src/deb-src/g' /etc/apt/sources.list && \
    sed -i -- 's/# deb-src/deb-src/g' /etc/apt/sources.list

ADD get-pythons.sh /usr/local/bin/get-pythons.sh

# Change these variables to update the version of Python installed.
#
# @@@@@
# Update the README.md!
# @@@@@

ENV PYTHON_27_VER=2.7.15 \
    PYTHON_34_VER=3.4.9 \
    PYTHON_35_VER=3.5.6 \
    PYTHON_36_VER=3.6.8 \
    PYTHON_37_VER=3.7.2 \
    PYTHON_38_VER=3.8.0a1 \
    # Set Debian front-end to non-interactive so that apt doesn't ask for
    # prompts later.
    DEBIAN_FRONTEND=noninteractive

RUN useradd runner --create-home && \
    # Create and change permissions for builds directory.
    mkdir /builds && \
    chown runner /builds && \
    export LC_ALL=C.UTF-8 && export LANG=C.UTF-8

# Use a new layer here so that these static changes are cached from above
# layer.  Update Xenial and install the build-deps.
RUN apt -q update && \
    # We have to use python3.5 build-deps for Ubuntu 16.04.  We can update
    # this to 3.6 or 3.7 depending on what gets released in 18.04.
    apt -q build-dep -y python2.7 && apt -q build-dep -y python3.5 && \
    apt -q install -y python3-pip wget unzip git && \
    # Remove apt's lists to make the image smaller.
    rm -rf /var/lib/apt/lists/*  && \
    # Get and install all versions of Python.
    ./usr/local/bin/get-pythons.sh && \
    # Install some other useful tools for test environments.
    pip3 install mypy \
                 codecov \
                 tox

# Switch to runner user and set the workdir.
USER runner
WORKDIR /home/runner
