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
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disable deafault nodejs" | tee -a $LOG_FILE
dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enable nodejs:20"
dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "install nodejs" | tee -a $LOG_FILE
id expense &>>$LOG_FILE
 if [ $? -ne 0 ]
 then
  echo -e "expense user not exsists...$G creating it"
useradd expense &>>$LOG_FILE
VALIDATE $? "create user xpense"  | tee -a $LOG_FILE
else 
echo -e "expense user already exist...$Y SKIPPING $N"
fi
mkdir -p /app #here -p is used for check the app direcory create or not if it creates goes next step else create a app directory
VALIDATE $? "creating /app folder"
curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip  &>>$LOG_FILE
VALIDATE $? "downloading backend appilication code"
cd /app
unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE $? "extracting backend application code"



