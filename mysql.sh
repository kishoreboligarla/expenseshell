
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
      echo "$Y run the script with root priviliges $N" | tee -a $LOG_FILE
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
   dnf install mysql-server -y &>>$LOG_FILE
   VALIDATE $? "installing MYSQL server"
   systemctl enable mysqld &>>$LOG_FILE
   VALIDATE $? "Enabled MYSQL server"  
   systemctl start mysqld &>>$LOG_FILE
   VALIDATE $? "started MYSQL server" 
   mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE
    VALIDATE $? "settingup root password"  
    mysql -h mysql.kishoreboligarla.shop -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE
    if [ $? -ne 0 ]
    then 
    echo " Mysql root password is not setup; setting now"  &>>$LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1
      VALIDATE $? "setting root password"
      else
      echo -e " Mysql root password is already setup; $Y SKIPPING $N" | tee -a $LOG_FILE
      fi