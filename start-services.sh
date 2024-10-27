service mysql start

for f in /docker-entrypoint-initdb.d/*; do
    case "$f" in
        *.sh)     echo "$0: running $f"; . "$f" ;;
        *)        echo "$0: ignoring $f" ;;
    esac
done

apache2ctl -D FOREGROUND