FROM node:16-alpine

MAINTAINER goutham kumar <example@gmail.com>

EXPOSE 3000

LABEL company_name="DLT Labs"

WORKDIR /opt

COPY . .

RUN npm install

CMD ["node", "./bin/www"]
