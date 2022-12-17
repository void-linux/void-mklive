if [ -z "${MKLIVE_REV}" ]; then
	MKLIVE_REV="$(git rev-parse --short HEAD || echo "unknown")"
fi
MKLIVE_VERSION="0.23-$MKLIVE_REV"
