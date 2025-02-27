docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy cis-docker.rego Dockerfile > conftestResult.txt
if [ $? != 0 ]
then
    exit 1
else
    exit 0
fi
