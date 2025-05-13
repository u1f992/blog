## woff2.dockerfile

```
FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install --yes \
        cmake \
        g++ \
        git \
        pkg-config \
    && rm -rf /var/lib/apt/lists/* \
    \
    && git init woff2 \
    && cd woff2/ \
    && git remote add origin https://github.com/google/woff2.git \
    && git fetch --depth 1 origin 0f4d304faa1c62994536dc73510305c7357da8d4 \
    && git checkout FETCH_HEAD \
    && git submodule update --init --recursive \
    \
    # https://github.com/google/brotli/tree/533843e3546cd24c8344eaa899c6b0b681c8d222
    && cd brotli \
    && mkdir out \
    && cd out \
    && cmake -DCMAKE_BUILD_TYPE=Release .. \
    && cmake --build . --config Release --target install \
    && cd ../.. \
    \
    # https://github.com/google/woff2/tree/0f4d304faa1c62994536dc73510305c7357da8d4
    && mkdir out-static \
    && cd out-static \
    && cmake -DBUILD_SHARED_LIBS=OFF .. \
    && make \
    && make install
```
