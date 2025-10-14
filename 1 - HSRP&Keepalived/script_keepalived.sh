my_index=`test -f /var/www/html/index.html && echo $?`
my_port=`bash -c "</dev/tcp/localhost/80" && echo $?`

if [ $my_index -eq 0 ] && [ $my_port -eq 0 ]; then
        exit 0
else
        exit 1
fi
