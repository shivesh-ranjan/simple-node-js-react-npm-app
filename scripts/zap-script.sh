docker run -d -u root --name zap -v $(pwd)/zap:/zap/wrk:rw --network="host" zaproxy/zap-stable sleep 9999999999999 #zap-full-scan.py -t http://localhost:3000 -r zap-scan-report.html
docker exec zap zap-full-scan.py -t http://localhost:3000 -r zap-scan-report.html
if [ $? == 1 ] || [ $? == 3 ]
then
    docker stop mynodeapp
    docker rm mynodeapp
    exit 1
else
    docker stop mynodeapp
    docker rm mynodeapp
    exit 0
fi
# docker stop mynodeapp
# docker rm mynodeapp
# exit 1
