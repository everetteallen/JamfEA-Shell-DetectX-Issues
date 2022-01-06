#!/bin/zsh

# Run DetectX Search (re)installing from JAMF if needed

# Full path to DetectX Swift.app
DX="/Applications/DetectX Swift.app"

# Full path to output file for writing results
# RESULTFILE="/Library/Application Support/JAMF/Addons/DetectX/results.json"
RESULTFILE="/Users/ega/Desktop/foo/results.json"

# Minimum version of DetectX Swift
# 1.9+ is required for Apple Silicon and macOS 12
MINIMUM_VERSION=1.0900

# Jamf policy custom trigger to run if DetectX is not found
# JAMF_TRIGGER="install_detectx"
JAMF_TRIGGER="install_detectx"

run_jamf_policy() {
	
    # Runs a jamf policy by id or event name
    cmd="/usr/local/bin/jamf policy "
    re='^[0-9]+$'
	if ! [[ $1 =~ $re ]] ; then
       cmd="$cmd -event $1"
    else
       cmd="$cmd -id $1"
    fi
    ret=$($cmd)
    if [ $ret ]; then
        result_dict=true
    else
        result_dict=false
    fi
    return $result_dict
}

run_detectx_search(){
    # Runs a DetectX Search
    echo "Ensure path and RESULTFILE exist"
    if [ ! -e $RESULTFILE ];then
        FILE="`basename "${RESULTFILE}"`"
        DIR="`dirname "${RESULTFILE}"`"
        # create the dir, then the file
        /bin/mkdir -p "${DIR}" && /usr/bin/touch "${DIR}/${FILE}"
    fi
    
    # Run the DetectX search
        echo "Scanning with DetectX"
        ret=$("$DX/Contents/MacOS/DetectX Swift" search -aj $RESULTFILE >> /dev/null)
        echo "Return Code is $ret"
        return $ret
    }

main(){
    # MAIN

    # Check if DetectX is installed at path 'DX'
    if [ ! -s $DX ];then
        echo "Runing Jamf Policy to install DetectX now"
        # run_jamf_policy $JAMF_TRIGGER
        install_via_policy=$?
        #DX="/Applications/DetectX Swift.app"
        echo "Policy return code is $install_via_policy"
        if [ $install_via_policy=false ] && [ ! -s $DX ]; then
            echo "DetectX was not found at path $DX and could not be installed via Jamf trigger $JAMF_TRIGGER"
            exit 1
        else
            echo "DetectX was installed via Jamf trigger $JAMF_TRIGGER"
        fi
    else
       echo "Found $DX"
    fi
    
    # Check if installed DetectX meets minimum version requirement
    # Get the version from the app as an integer
    DTXV=$( "$DX/Contents/MacOS/DetectX Swift" version |/usr/bin/head -n1 |/usr/bin/cut -d'v' -f2 -s |/usr/bin/bc )
    if [ ! $(( $DTXV >= $MINIMUM_VERSION )) ];then
        echo "Cur $DTXV"
        echo "Min $MINIMUM_VERSION"
        # run_jamf_policy $JAMF_TRIGGER
    fi

    # Run DetectX Search 
    run_detectx_search
    detectx_search=$? 
    if [ -s $RESULTFILE ] && [ $detectx_search = 0 ]; then
        echo "DetectX search complete."
        echo "Results available at $RESULTFILE"
    else
        echo "An error occurred during the DetectX search."
        exit 1 
    fi
    
    }
    
main
exit 0