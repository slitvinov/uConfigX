# env.sh - adds this directory (<gitroot>/uConfigX/utils/ucx) to PATH
# and sets UCX_PREFIX to <gitroot>
#
# refs:
#     http://stackoverflow.com/a/246128
#     http://unix.stackexchange.com/a/124447

THISDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
UCX_PREFIX=$( cd "$THISDIR/../.." && pwd )

# add to the path
case ":${PATH:=$THISDIR}:" in
    *:$THISDIR:*)  ;;
    *) PATH="$THISDIR:$PATH"  ;;
esac

export PATH
export UCX_PREFIX
