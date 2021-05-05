FROM node:14-alpine

WORKDIR /opt/apps

COPY . .

EXPOSE 3000

CMD ["node", "./bin/www"]
