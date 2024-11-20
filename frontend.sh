#!/bin/bash
  USERID=$(id -u)

  R="\e[31m"
  G="\e[32m"
  Y="\e[33m"
  N="\e[0m"

  LOGS_FOLDER="/var/log/shell-script"
  SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
  TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
  LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
  mkdir -p $LOGS_FOLDER

  CHECK_ROOT(){
      if [ $USERID -ne 0 ]
      then
      echo -e "$Y run the script with root priviliges $N" | tee -a $LOG_FILE
      exit 1
      fi
  }

  VALIDATE(){
      if [ $1 -ne 0 ]
      then
      echo -e "$2 is $R failure $N"   | tee -a $LOG_FILE
      exit 1
      else 
      echo -e  "$2 is $G  sucess $N"  | tee -a $LOG_FILE
      fi
  }

   echo "script started at : $(date)"  | tee -a $LOG_FILE

   CHECK_ROOT 
dnf install nginx -y  &>>LOG_FILE
VALIDATE $? "Installing nginx"

systemctl enable nginx  &>>LOG_FILE
VALIDATE $? "Enabled nginx"

systemctl start nginx  # &>>LOG_FILE
VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/*  &>>LOG_FILE
VALIDATE $? "removing default webpage"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip # &>>LOG_FILE
VALIDATE $? "downloading frontend code"

cd /usr/share/nginx/html  #&>>LOG_FILE
unzip /tmp/frontend.zip  #&>>LOG_FILE
VALIDATE $? "unzipping the front end code"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "Copied expense conf"
#systemctl restart nginx 
#VALIDATE $? "Restarted Nginx"





