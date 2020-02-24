#!/bin/sh

proto_imports=".:${GOPATH}/src/github.com/gogo/protobuf/protobuf:${GOPATH}/src/github.com/gogo/protobuf:${GOPATH}/src/github.com/google/protobuf/src:${GOPATH}/src:${GOPATH}/src/github.com/onosproject/ran-simulator/"

rm -rf api/trafficsim && mkdir -p api/trafficsim && rm -rf api/types && mkdir -p api/types && rm -rf api/nb && mkdir -p api/nb
wget https://raw.githubusercontent.com/onosproject/ran-simulator/master/api/trafficsim/trafficsim.proto -P api/trafficsim
wget https://raw.githubusercontent.com/onosproject/ran-simulator/master/api/types/types.proto -P api/types
wget https://raw.githubusercontent.com/onosproject/onos-ran/master/api/nb/c1-interface.proto -P api/nb

# Warning this required protoc v3.9.0 or greater
protoc -I=$proto_imports --js_out=import_style=commonjs:. ${GOPATH}/src/github.com/onosproject/ran-simulator/api/types/types.proto
protoc -I=$proto_imports --js_out=import_style=commonjs:. ${GOPATH}/src/github.com/onosproject/ran-simulator/api/trafficsim/trafficsim.proto
protoc -I=$proto_imports --js_out=import_style=commonjs:. ${GOPATH}/src/github.com/onosproject/ran-simulator/api/nb/c1-interface.proto

# Currently a bug in the below command outputs to "Github.com" (uppercase G)
# The below uses grpcwebtext as Google implementation does not fully support server side streaming yet (Aug'19)
# See https://grpc.io/blog/state-of-grpc-web/
protoc -I=$proto_imports --grpc-web_out=import_style=typescript,mode=grpcwebtext:. ${GOPATH}/src/github.com/onosproject/ran-simulator/api/types/types.proto
protoc -I=$proto_imports --grpc-web_out=import_style=typescript,mode=grpcwebtext:. ${GOPATH}/src/github.com/onosproject/ran-simulator/api/trafficsim/trafficsim.proto
protoc -I=$proto_imports --grpc-web_out=import_style=typescript,mode=grpcwebtext:. ${GOPATH}/src/github.com/onosproject/ran-simulator/api/nb/c1-interface.proto

cp -r github.com/onosproject/ran-simulator/* web/sd-ran-gui/src/app/onos-sdran/proto/github.com/onosproject/ran-simulator/
rm -rf github.com
cp -r Github.com/onosproject/ran-simulator/* web/sd-ran-gui/src/app/onos-sdran/proto/github.com/onosproject/ran-simulator/
rm -rf Github.com

# Add the license text to generated files
for f in $(find web/sd-ran-gui/src/app/onos-*/proto/github.com/ -type f -name "*.d.ts"); do
  cat /build-tools/licensing/boilerplate.generatego.txt | sed -e '$a\\' | cat - $f > tempf && mv tempf $f
done

# Remove unused import for gogoproto
for f in $(find web/sd-ran-gui/src/app/onos-* -type f -name "*ts"); do
  sed -i "s/import \* as gogoproto_gogo_pb from '..\/..\/..\/..\/..\/..\/gogoproto\/gogo_pb';//g" $f
done
