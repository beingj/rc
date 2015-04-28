function ff () {
    select_and_do locate "$@"
}
function lss () {
    select_and_do find "$@"
}
function pss () {
    while true;do
        local pid=$(ps ax | percol.py)
        pid=$(echo "$pid" | gawk '{print $1}')
        cmd=$(cmd_for_pid $pid| percol.py)
        eval $cmd
    done
}
function cdd()
{
    local path=$(locate "$@" | percol.py)
    ! [ -d $path ] && path=$(dirname $path)
    cd $path
}
function r()
{
    local cmd=$(my_cmd | percol.py)
    echo $cmd
    eval $cmd
}
function h()
{
    local cmd=$(history | percol.py | sed -n 's/^ *[0-9]* *//p')
    echo $cmd
    eval $cmd
}
# help functions
function my_cmd () {
    echo 'read o p && ps $o | grep $p'
    echo 'local a b && read a b && echo $a $b'
    echo 'ls /'
    echo 'top'
    echo 'pushd /tmp'
}
function cmd_for_file() {
    echo vim "$@"
    echo percol.py "$@"
    echo "cat -n "$@" | percol.py"
    echo file "$@"
    echo ls -l "$@"
    echo cpp "$@"
    echo cat -n "$@"
    echo tar zxf "$@"
    echo tar zcf "$1.tgz" "$@"
    echo unzip "$@"
    echo cat "$@"
    echo manual input...
    echo select another file
}
function cmd_for_pid () {
    echo kill "$@"
}
function cpp () {
    local src=$1
    local dst=$(locate '*'| percol.py)
    cp "$src" "$dst"
}
function select_and_do () {
    local list_cmd=$1
    shift
    if [ "$list_cmd" == "locate" ];then
        if [ $# -gt 0 ];then
            list_cmd="locate "$@""
        else
            list_cmd="locate '*'"
        fi
    else
        list_cmd="find \"$(pwd)\" \( -type d -printf '%p/\n' , -type f -print \)"
    fi
    echo $list_cmd
    while true;do
        #also export p to current terminal, so we can use $p out of the function
        p=$(eval $list_cmd | percol.py)
        echo '--------------------------------------------------'
        echo path: $p
        while true;do
            local cmd=$(cmd_for_file $p|percol.py)
            echo '--------------------------------------------------'
            echo cmd : $cmd
            echo '--------------------------------------------------'
            [ "$cmd" == "manual input..." ] && echo "use \$p for selected file" && read -p "cmd: " cmd
            [ "$cmd" == "select another file" ] && break
            eval $cmd
            #[ $? -eq 0 ] && break
            echo
            read -p 'press Enter to continue, Ctrl-C to quit... '
        done
        echo
        [ "$cmd" == "select another file" ] && continue
        read -p 'press Enter to continue, Ctrl-C to quit... '
    done
}
