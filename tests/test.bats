setup() {
  set -eu -o pipefail

  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/testdb-init
  mkdir -p $TESTDIR
  export PROJNAME=ddev-db-init
  export DDEV_NON_INTERACTIVE=true

  ddev delete -Oy ${PROJNAME} || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME}
  echo "<html><head></head><body>this is a test</body>" >index.html
  ddev start -y
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME}
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

# Confirm the basics services are running
healthchecks() {
  curl -s "https://${PROJNAME}.ddev.site" | grep "this is a test"
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR}
  ddev restart

  healthchecks
}
