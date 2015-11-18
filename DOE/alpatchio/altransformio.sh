#!/bin/bash
# Transfrom a "parameter line" using configuration file

# TEST: altransformio1
# ur altransformio.sh test_data/transformio1.config a_42_c_10 > transformio.out.config
#
# TEST: altransformio2
# ur altransformio.sh test_data/transformio1.config c_10_a_42 > transformio.out.config
#
# TEST: altransformio3
# ur altransformio.sh test_data/transformio2.config a_2_c_2 > transformio.out.config
#
# TEST: altransformio4
# ur altransformio.sh test_data/transformio3.config a_1_b_2 > transformio.out.config
#
# TEST: altransformio5
# ur altransformio.sh test_data/transformio4.config a_1 > transformio.out.config
#
# TEST: altransformio6
# ur altransformio.sh test_data/transformio5.config a_preved > transformio.out.config

set -u
config_file=$1
parameters_line=$2

slave=`mktemp /tmp/altransf.XXXXXX`
awk -f `us altransformio.generator.awk` "$config_file" "$parameters_line" > "$slave"

echo "(altransformio.sh) slave: $slave" > /dev/stderr
awk -f "$slave"
