# build the libpostal-server binary separately
FROM pelias/libpostal_baseimage as builder

RUN apt-get update && apt-get install -y make pkg-config

# install go
RUN curl https://dl.google.com/go/go1.11.linux-amd64.tar.gz | tar -C /usr/local -xz
ENV PATH="$PATH:/usr/local/go/bin"

# bring in and build project go code
WORKDIR /code/go-whosonfirst-libpostal
RUN git clone https://github.com/whosonfirst/go-whosonfirst-libpostal.git .
RUN make bin

# start of main image
FROM pelias/libpostal_baseimage

COPY --from=builder /code/go-whosonfirst-libpostal/bin/wof-libpostal-server /bin/

RUN ldconfig

USER pelias

ENV PORT 4400

# set entrypoint to executable, ensuring the host is set so network requests will work
# additional parameters can be passed on the command line
ENTRYPOINT [ "/bin/wof-libpostal-server", "-host", "0.0.0.0", "-port", "4400" ]
