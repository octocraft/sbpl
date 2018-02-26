#!/bin/bash
set -eu

sbpl_name="Simple Bash Package Loader"
export sbpl_version="0.2.0"

export sbpl=$0
export sbpl_pkg="sbpl-pkg.sh"
export sbpl_dir_pkgs="vendor"
export sbpl_dir_bins="$sbpl_dir_pkgs/bin"
export sbpl_dir_tmps="$sbpl_dir_pkgs/tmp"

#######################################

function export_platform_info () {

    if [ -z ${OS+x} ]; then
        case "$OSTYPE" in
            android*)   OS="android";   ;;
            darwin*)    OS="darwin";    ;;
            dragonfly*) OS="dragonfly"; ;;
            freebsd*)   OS="freebsd";   ;;
            linux*)     OS="linux";     ;;
            netbsd*)    OS="netbsd";    ;;
            openbsd*)   OS="openbsd";   ;;
            plan9*)     OS="plan9";     ;;
            solaris*)   OS="solaris";   ;;  
            windows*)   OS="windows";   ;;
            *)          OS="$OSTYPE";   ;;
        esac;

        export OS
    fi

    if [ -z ${ARCH+x} ]; then
        case "$HOSTTYPE" in
            arm64*)     ARCH="arm64"        ;;
            arm*)       ARCH="arm"          ;;
            i386*)      ARCH="368"          ;;
            x86_64*)    ARCH="amd64"        ;;
            ppc64le*)   ARCH="ppc64le"      ;;
            ppc64*)     ARCH="ppc64"        ;;
            mips64le*)  ARCH="mips64le"     ;;
            mips64*)    ARCH="mips64"       ;;
            mipsle*)    ARCH="mipsle"       ;;
            mips*)      ARCH="mips"         ;;
            *)          ARCH="$HOSTTYPE"    ;;
        esac;

        export ARCH
    fi
}

function sbpl_locations () {

    export sbpl_dir_pkg="$sbpl_dir_pkgs/$OS/$ARCH"
    export sbpl_dir_bin="$sbpl_dir_bins/$OS/$ARCH"
    export sbpl_dir_tmp="$sbpl_dir_tmps/$OS/$ARCH"
}

function sbpl_get () {

    function check_dependency () {

        if ! command -v "$1" > /dev/null; then
            printf "Dependency '$1' not found\n" 1>&2
            exit 2
        fi
    }

    function display_progress () {

        max=72
        total=$(if [ "$1" -le 0 ]; then echo 1; else echo "$1"; fi)
        current=0
           
        # get local dependet deciaml separator
        num=$(printf "%.1f")
        dcs=${num:1:1}

        while read line; do
        
            current=$((current + 1))
            steps=$((current * max / total))
            (("$steps" > $max)) && steps=$max
            left=$((max - steps))
            percent=$((steps * 100 / max))
            promille=$(($((steps * 1000 / max)) % 10))
    
            # dots
            printf -v f '%*s' $steps ''
            printf '%s' ${f// /.}
            
            # spaces
            printf '%*s' $left ''        
    
            # percent
            printf " %3d$dcs%1d%%\r" $percent $promille 
        done
    
        printf "\n"
    }
    
    function sbpl_usage () {

        printf "Usage: sbpl_get 'target'\n" 1>&2
        printf "file    'name' 'version'    'url'\n" 1>&2
        printf "archive 'name' 'version'    'url' 'bin_dir'\n" 1>&2
        printf "git     'name' 'branch/tag' 'url' 'bin_dir'\n" 1>&2
    }

    # Check arguments
    if [ "$#" -lt 4 ]; then sbpl_usage; return 2; fi

    target=$1

    # Check dependencies
    check_dependency curl
    case "$target" in
        file)                                           ;;
        archive)    check_dependency bsdtar;            ;;
        git)        check_dependency git                ;;
        *)          printf "Unknown option $target\n"
                    sbpl_usage; return 2;               ;;
    esac

    # Get Arguments and eval vars
    name=$2
    version=$3
    url=$(eval "printf $4")

    if [ "$#" -ge 5 ]; then
        src_bin_dir=$(eval "printf $5")
    else
        src_bin_dir=""
    fi

    # Update Locations
    sbpl_locations

    package="${name}-${version}"
    destination="$sbpl_dir_pkg/$package"

    result=0

    # Check if package is present
    if [ ! -d "$destination" ] ; then

        printf "Get package: $package\n"

        mkdir -p "$destination"

        pkg_bin_dir=$(pwd)/$destination/$src_bin_dir
        pkg_bin_file=$pkg_bin_dir/$name
        
        if [ "$target" = "file" ] || [ "$target" = "archive" ]; then

            tmpfile="$sbpl_dir_tmp/$package"
           
            mkdir -p "$sbpl_dir_tmp"
            curl -fSL# "$url" -o "$tmpfile" 2>&1 | tee && result=${PIPESTATUS[0]} || result=$?
            
            echo "HELLO $result" 1>&2

            if [ "$result" -ne 0 ]; then
                printf "Error while downloading '%s'\n" "$url" 1>&2
            else
            
                if [ "$target" = "archive" ]; then
                
                    numfiles=$(bsdtar tf $tmpfile | wc -l)
                
                    bsdtar xvf "$tmpfile" -C "$destination" 2>&1 | display_progress $numfiles

                    if [ "${PIPESTATUS[0]}" -ne 0 ]; then
                        printf "Error while extracting '%s'\n" "$tmpfile" 1>&2
                        result=${PIPESTATUS[0]}
                    fi
                else
                    mkdir -p "$pkg_bin_dir" && mv "$tmpfile" "$pkg_bin_file"
                    
                    if [ "$?" -ne 0 ]; then
                        printf "Error while moving file '%s' to '%s'\n" "$tmpfile" "$pkg_bin_file" 1>&2
                        result=1
                    fi
                fi
            fi
        elif [ "$target" = "git" ]; then
       
            git clone "$url" "$destination" && result=$? || result=$?

            if [ "$result" -ne 0 ]; then
                printf "Error while cloning repo '%s'\n" "$url" 1>&2
            else

                pushd "$destination" > /dev/null
                git checkout "$version" && result=$? || result=$?
                popd  > /dev/null
    
                if [ "$result" -ne 0 ]; then
                    printf "Error while checking out branch/tag\n" 1>&2
                fi
            fi
        else 
            printf "Unknown option $1\n"
            sbpl_usage
            result=2
        fi

        if [ "$result" -eq 0 ] && [ ! -f "$pkg_bin_file" ]; then
            printf "Error while processing package: $pkg_bin_file not found\n" 1>&2
            result=1
        fi

        destionation_bin="$sbpl_dir_bin/$name"

        if [ "$result" -eq 0 ]; then

            # Make executable and create link in bin dir
            chmod u+x "$pkg_bin_file" && mkdir -p "$sbpl_dir_bin" && ln -sf "$pkg_bin_file" "$destionation_bin"

            if [ "$?" -ne 0 ]; then
                printf "Error while creating symlink for target file in bin folder\n" 1>&2
                result=1
            fi
        fi

        if [ $result -ne 0 ]; then
            rm -rf $destination
            rm -f $destionation_bin
        fi
    fi

    return $result
}

function get_packages () {

    # Check pkg file
    if [ -f "$PWD/$sbpl_pkg" ]; then

        if ! command -v diff > /dev/null; then
            function diff () {
                if [ "$(cat $1)" = "$(cat $2)" ]; then
                    return 0
                else
                    return 1
                fi
            }
        fi

        # Check lock file & skip update if no changes
        if [ -f "$PWD/$sbpl_pkg.lock" ] && diff "$PWD/$sbpl_pkg" "$PWD/$sbpl_pkg.lock" > /dev/null; then
            return 0
        fi

        # Run pkg script
        command "$PWD/$sbpl_pkg" && result=$? || result=$?

        # Clear tmp
        rm -rf "$PWD/$sbpl_dir_tmps/*"

        # Update lock file
        if [ $result -eq 0 ]; then
            cp -p "$PWD/$sbpl_pkg" "$PWD/$sbpl_pkg.lock"
        else 
            rm -f "$PWD/$sbpl_pkg.lock"
            echo "'sbpl-pkg.sh' failed with status $result"
            return $result
        fi
    else
        printf "'$sbpl_pkg' not found\n" 1>&2
        return 1
    fi

    return 0
}

function show_version () {

    printf "$sbpl_name - $sbpl_version\n"
    return 0
}

function usage () {

    printf "help    - print usage information\n"
    printf "update  - download packages\n"
    printf "upgrade - upgrade to latest sbpl version\n"
    printf "clean   - clear vendor dir\n"
    printf "version - print sbpl version information\n"
    printf "envvars - print vars used by sbpl. Pass a var name to filter the list\n"

    return 0
}

function unknown_option () {

    printf "$sbpl: Unknown option $1\n"
    printf "Use $sbpl help for help with command-line options,\n"
    printf "or see the online docs at https://github.com/octocraft/sbpl\n"
    return 2
}

function clean () {

    rm -rf "$PWD/$sbpl_pkg.lock" "$PWD/$sbpl_dir_pkgs" && mkdir -p "$PWD/$sbpl_dir_pkgs"
    return $?
}

function upgrade () {

    # Update Locations
    sbpl_locations

    sbpl_get 'file' 'sbpl' 'master' 'https://raw.githubusercontent.com/octocraft/${name}/${version}/sbpl.sh'

    mkdir -p "$sbpl_dir_tmp"
    cp "$sbpl_dir_bin/sbpl" "$sbpl_dir_tmp/sbpl.sh"
    mv "$sbpl_dir_tmp/sbpl.sh" "$sbpl"    

    return $?
}

function init () {

    if [ -f "$sbpl_pkg" ]; then
        printf "$sbpl_pkg already exists\n"
        return 1
    fi

    printf "#!/bin/bash\n\n" > $sbpl_pkg
    printf "%s\n" '# Call sbpl_get to add dependencies, e.g:' >> $sbpl_pkg
    printf "%s\n" '#   sbpl_get '"'"'archive'"'"' '"'"'sbpl'"'"' '"'"'master'"'"' '"'"'https://github.com/octocraft/${name}/archive/${version}.zip'"'"'                '"'"'./${name}-${version}/bin/'"'" >> $sbpl_pkg
    printf "%s\n" '#   sbpl_get '"'"'file'"'"'    '"'"'sbpl'"'"' '"'"'master'"'"' '"'"'https://raw.githubusercontent.com/octocraft/${name}/${version}/${name}.sh'"'" >> $sbpl_pkg
    printf "%s\n" '#   sbpl_get '"'"'git'"'"'     '"'"'sbpl'"'"' '"'"'master'"'"' '"'"'https://github.com/octocraft/${name}.git'"'"'                                   '"'"'./bin/'"'" >> $sbpl_pkg
    printf "\n\n" >> $sbpl_pkg 

    chmod u+x $sbpl_pkg

    return 0
}

function envvars () {

    function print_var () {
        var_name="$1"
        var_data="$(eval 'echo $'"$var_name")"

        if [ "$var_filter" = "$var_name" ]; then
            printf "%s\n" "$var_data"
        elif [ "$var_filter" = "*" ]; then
            printf "%s=\"%s\"\n" "$var_name" "$var_data"
        fi
    }

    # Update Locations
    sbpl_locations

    if ! [ -z ${1+x} ]; then
        export var_filter="$1"
    else
        export var_filter="*"
    fi

    print_var "OS" 
    print_var "ARCH" 
    print_var "sbpl_version"
 
    print_var "sbpl_dir_pkgs"
    print_var "sbpl_dir_bins" 
    print_var "sbpl_dir_tmps"

    print_var "sbpl_dir_pkg"
    print_var "sbpl_dir_bin"
    print_var "sbpl_dir_tmp"

    export sbpl_path_pkg="$PWD/$sbpl_dir_pkg"
    export sbpl_path_bin="$PWD/$sbpl_dir_bin"
    export sbpl_path_tmp="$PWD/$sbpl_dir_tmp"

    print_var "sbpl_path_pkg"
    print_var "sbpl_path_bin"
    print_var "sbpl_path_tmp"

    return 0
}

######################################

# Setup environment
export_platform_info
export -f sbpl_get
export -f sbpl_locations

# Parse command line arguments
if ! [ -z ${1+x} ]; then

    cmd=$1
    shift;

    case "$cmd" in
        help*)      usage $@;           result=$?; ;;
        update*)    get_packages $@;    result=$?; ;;
        upgrade*)   upgrade $@;         result=$?; ;;
        clean*)     clean $@;           result=$?; ;;
        version*)   show_version $@;    result=$?; ;;
        init*)      init $@;            result=$?; ;;
        envvars*)   envvars $@;         result=$?; ;;
        *)   unknown_option $cmd $@;    result=$?; ;;
    esac;
else
                    get_packages $@;    result=$?;
fi

# Return
exit $result

