# Scripts README

This directory will contain a bunch of random scripts for doing various
types of git history exploration.

## MergeDiff.sh

This shell script reads in a repository path and a list of merge commit SHAs
and then goes through those SHAs one by one to diff them against their
parents. It formats the diff information and echos it to stdout in a YAML
format. It is recommended that the output is redirected to a YAML file.

### Sample Input

    ~/path/to/repository
    97e03a769c35a102189b762b7d058d477a25387e
    b01a8b2e5fa444da6733b3ac457e04908871ae3c
    02513d5536743a46864de0d5b2c9e6a2469fd7cc

### How To Run

To run the script on our sample.txt file, we use the following command:

    ./MergeDiff.sh sample.txt

The output for this command will be spit out onto console. To put the output
in a YAML, simply redirect into a YAML file like so:

    ./MergeDiff.sh sample.txt > sample.yaml

### Sample Output

    ---
    diff1: "39898c14da6b6f6385849800c7c5df09855036d8 against 8b0a7c292dce025a4469c5ae22613f187ba863ae"
    count1: 1
    - "this/is/file1.java"
    diff2: "39898c14da6b6f6385849800c7c5df09855036d8 against 20dfa29fd377b3a759a1506bd5af5f2ac6014456"
    count2: 1
    - "this/is/file2.java"
    ...
    ---
    diff1: "81879097b3f07fb16c68b821528b21fbd79dc293 against f23e641f8ea3495cafae6cd46d08610458f72174"
    count1: 1
    - "this/is/anotherfile.java"
    diff2: "81879097b3f07fb16c68b821528b21fbd79dc293 against fbae492ce7e51a21d7a42da0695b17a7a3d32521"
    count2: 0
    ...
    // and so forth...
