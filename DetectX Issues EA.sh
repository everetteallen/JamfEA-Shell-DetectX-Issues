#!/bin/zsh

# Set the path to the results of a DetectX command line scan
 RESULTFILE='/Library/Application Support/JAMF/Addons/DetectX/results.json'

# Test to see if the results file exists and has length.  If True use osascript to run javascript
# and parse our the results if any. Return the date of the scan and the issues list if any
# or return scan date and the word None. 

if [ -s $RESULTFILE ]; then
	json=$(<$RESULTFILE)
    # run the Javascript
    SDATE=$(/usr/bin/osascript -l JavaScript -e "JSON.parse(\`$json\`).searchdate") 
    ISSUES=$(/usr/bin/osascript -l JavaScript -e "JSON.parse(\`$json\`).issues")
    ISSUES=$SDATE',\n'$ISSUES
else
# Otherwise return nothing
ISSUES=""
fi

echo "<result>$ISSUES</result>"

exit 0