set -e

INPUT_DIR="${CROSSCOMPUTE_INPUT_FOLDER:-batches/standard/input}"
OUTPUT_DIR="${CROSSCOMPUTE_OUTPUT_FOLDER:-batches/standard/output}"

echo $CROSSCOMPUTE_OUTPUT_FOLDER
echo $OUTPUT_DIR

REGEX_FILTER=`cat ${INPUT_DIR}/regex.txt`
REGEX_FILTER=`echo "${REGEX_FILTER}" | sed 's/^/  /'`
# REGEX_FILTER=`echo "${REGEX_FILTER}" | tr '\n' '\\n\\t'`
# REGEX_FILTER=`echo ${REGEX_FILTER} | sed ':a;N;$!ba;s/\n/\\n/g' | sed 's/\$/\\$/g'`
# sed "s/REGEX_FILTER/${REGEX_FILTER}/" nginx-access.conf
# awk -v r=$REGEX_FILTER '{gsub(/REGEX_FILTER/,r)}1' nginx-access.conf

echo "
[INCLUDES]

# Load regexes for filtering
before = botsearch-common.conf

[Definition]

failregex = ${REGEX_FILTER}

ignoreregex =

datepattern = {^LN-BEG}%%ExY(?P<_sep>[-/.])%%m(?P=_sep)%%d[T ]%%H:%%M:%%S(?:[.,]%%f)?(?:\s*%%z)?
              ^[^\[]*\[({DATE})
              {^LN-BEG}
" > nginx-access.conf

cat nginx-access.conf

# mkdir -p $OUTPUT_DIR
cp -r /etc/fail2ban/filter.d .
cd filter.d
#sleep 600
fail2ban-regex ../${INPUT_DIR}/access.log  ../nginx-access.conf --print-all-matched | awk '/^\|  [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/ { print $2 }' | sort | uniq -c > ../${OUTPUT_DIR}/bad-ips.txt
#fail2ban-regex ../${INPUT_DIR}/access.log ../nginx-access.conf --print-all-matched > ../${OUTPUT_DIR}/bad-ips.txt
