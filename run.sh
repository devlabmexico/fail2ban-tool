set -e

INPUT_DIR="${CROSSCOMPUTE_INPUT_FOLDER:-batches/standard/input}"
OUTPUT_DIR="${CROSSCOMPUTE_OUTPUT_FOLDER:-batches/standard/output}"

echo $CROSSCOMPUTE_OUTPUT_FOLDER
echo $OUTPUT_DIR

# mkdir -p $OUTPUT_DIR
cp -r /etc/fail2ban/filter.d .
cd filter.d

fail2ban-regex ../${INPUT_DIR}/access.log  ../nginx-access.conf --print-all-matched | awk '/^\|  [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/ { print $2 }' | sort | uniq -c > ../${OUTPUT_DIR}/bad-ips.txt
#fail2ban-regex ../${INPUT_DIR}/access.log ../nginx-access.conf --print-all-matched > ../${OUTPUT_DIR}/bad-ips.txt
