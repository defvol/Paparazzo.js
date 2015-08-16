FROM  ubuntu:latest

# Enable EPEL for Node.js
RUN curl -sL https://deb.nodesource.com/setup | bash -
# Install Node.js and npm
RUN apt-get update ; apt-get install -yq nodejs npm coffeescript
RUN ln -s /usr/bin/nodejs /usr/bin/node

# Copy source code
ADD . /paparazzo

RUN cd /paparazzo

# Install app dependencies
RUN cd /paparazzo; make install

EXPOSE  3000
WORKDIR /paparazzo
CMD ["nodejs", "/paparazzo/demo/bootstrap.js"]

