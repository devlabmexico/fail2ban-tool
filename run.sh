set -e

INPUT_DIR="${CROSSCOMPUTE_INPUT_FOLDER:-batches/standard/input}"
OUTPUT_DIR="${CROSSCOMPUTE_OUTPUT_FOLDER:-batches/standard/output}"

mkdir -p $OUTPUT_DIR

dnf install -y fail2ban

cat <<EOF  > /etc/fail2ban/filter.d/nginx-access.conf
[INCLUDES]

# Load regexes for filtering
before = botsearch-common.conf

[Definition]

failregex = ^<HOST> - (-|[^ ]+) \[[(\d\w\/: \+\-]*\] "(?!GET|POST|HEAD|PATCH|PUT|DELETE|OPTIONS|CONNECT|TRACE).*$
            ^<HOST> - (-|[^ ]+) \[[(\d\w\/: \+\-]*\] "(GET|POST|HEAD|PATCH|PUT|DELETE|OPTIONS|CONNECT|TRACE) ([^/]|\\).*$
            ^<HOST> - (-|[^ ]+) \[[(\d\w\/: \+\-]*\] "(GET|POST|HEAD|PATCH|PUT|DELETE|OPTIONS|CONNECT|TRACE) /[$'%%:].*$
            ^<HOST> - (-|[^ ]+) \[[(\d\w\/: \+\-]*\] "(GET|POST|HEAD|PATCH|PUT|DELETE|OPTIONS|CONNECT|TRACE) /.*(/home/|/etc/|/bin/|/lib/).*$
            ^<HOST> - (-|[^ ]+) \[[(\d\w\/: \+\-]*\] "(GET|POST|HEAD|PATCH|PUT|DELETE|OPTIONS|CONNECT|TRACE) /.*[.](sh|ini|env|zip|dll|pem|git|aspx?|jsa|jsp).*$
            ^<HOST> - (-|[^ ]+) \[[(\d\w\/: \+\-]*\] "(GET|POST|HEAD|PATCH|PUT|DELETE|OPTIONS|CONNECT|TRACE) /.*(php|pma|laravel|drupal|magento).*$
            ^<HOST> - (-|[^ ]+) \[[(\d\w\/: \+\-]*\] "(GET|POST|HEAD|PATCH|PUT|DELETE|OPTIONS|CONNECT|TRACE) /.*(curl|wget|cmd|bash|cron|eval|export).*$
            ^<HOST> - (-|[^ ]+) \[[(\d\w\/: \+\-]*\] "(GET|POST|HEAD|PATCH|PUT|DELETE|OPTIONS|CONNECT|TRACE) /.*(/flu|nmap|[.]aws|credentials|cgi).*$
            ^<HOST> - (-|[^ ]+) \[[(\d\w\/: \+\-]*\] "(GET|POST|HEAD|PATCH|PUT|DELETE|OPTIONS|CONNECT|TRACE) /.*/../.*$

ignoreregex =

datepattern = {^LN-BEG}%%ExY(?P<_sep>[-/.])%%m(?P=_sep)%%d[T ]%%H:%%M:%%S(?:[.,]%%f)?(?:\s*%%z)?
              ^[^\[]*\[({DATE})
              {^LN-BEG}
EOF

fail2ban-regex ${INPUT_DIR}/access.txt  /etc/fail2ban/filter.d/nginx-access.conf --print-all-matched | awk '/^\|  [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/ { print $2 }' | sort | uniq -c > ${OUTPUT_DIR}/bad-ips.txt

