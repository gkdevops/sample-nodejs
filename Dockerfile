#This file will create a nodejs image

FROM node:16-alpine

MAINTAINER Goutham Kumar <chgoutam@test.com>

# Default location set on the base image is "/"
# Its a good practise to switch to a different location other than /

LABEL company_name="DLT Labs"

WORKDIR /apps

ENV PORT 3000

EXPOSE 3000

CMD ["node", "./bin/www"]

COPY . .

RUN npm install

# CMD will excluded from execution and just copied
#CMD ["node", "./bin/www"]
