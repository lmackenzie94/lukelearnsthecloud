FROM node:18-alpine
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# option 1: this works
# EXPOSE 4173
# CMD [ "npm", "run", "preview" ]

# option 2: this works too
RUN npm install -g serve
EXPOSE 3000
CMD [ "serve", "-s", "dist" ]