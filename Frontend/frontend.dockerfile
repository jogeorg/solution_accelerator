# pull the base image
FROM node:alpine

# set the working direction
WORKDIR /dev-space/

# add `/app/node_modules/.bin` to $PATH
ENV PATH /dev-space/node_modules/.bin:$PATH

# install app dependencies
COPY /dev-space/package.json /dev-space/package.json
COPY /dev-space/public/ /dev-space/public
COPY /dev-space/src/ /dev-space/src

RUN npm install

# start app
CMD ["npm", "start"]