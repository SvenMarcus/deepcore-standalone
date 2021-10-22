FROM nickblah/lua:5.1-luarocks-buster

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes build-essential git && \
    luarocks install busted

CMD [ "/bin/bash" ]