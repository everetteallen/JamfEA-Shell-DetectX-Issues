#!/bin/zsh

# Set the path to the results of a DetectX command line scan
 RESULTFILE='/Library/Application Support/JAMF/Addons/DetectX/results.json'

# Test to see if the results file exists and has length.  If True use osascript to run javascript
# and parse our the results if any. Return the date of the scan and the issues list if any
# or return scan date and the word None. 
if [ -s $RESULTFILE ]; then
	json=$(<$RESULTFILE)
    read -r -d '' JSRUN << EndOfScript
    function run(){   
  		var result=JSON.parse(\`$json\`)     
  		if (result.issues.length > 0){	
  		return(result.searchdate + "\\n" + result.issues.join('\r\n'))  
  		}else{
  		return(result.searchdate + "\\n" + "None")} 
}   
EndOfScript
# run the Javascript we setup
ISSUES=$(osascript -l JavaScript <<< $JSRUN) 
else
# Otherwise return noting
ISSUES=""
fi

echo "<result>$ISSUES</result>"

exit 0
