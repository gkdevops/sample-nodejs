#This file will create a nodejs image

FROM node:16-alpine
 
LABEL company_name="DLT Labs" name="Goutham Kumar" email="goutham@outlook.com"

# Default location set on the base image is "/"
# Its a good practise to switch to a different location other than /

WORKDIR /apps

ENV PORT=3000

EXPOSE 3000

COPY . .

RUN npm install

# CMD will excluded from execution, it will just copied to Docker Image
CMD ["node", "./bin/www"]
