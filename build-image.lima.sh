export result="$(lima ./build-image.sh)"
limactl copy -r "default:$result" ./result
