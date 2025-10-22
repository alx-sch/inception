# Base image for the container.
# Debian 13 ("Trixie") is the latest stable version currenly, but
# Debian 12 ("Bookworm") is the current penultimate stable version.
FROM	debian:bookworm-slim

# Author & Maintainer
LABEL	maintainer="aschenk"

# Set non-interactive mode for apt operations
#ENV DEBIAN_FRONTEND=noninteractive

# Install Redis Server
RUN apt-get update && \
	apt-get install -y --no-install-recommends \
	redis-server \
	&& apt-get clean && rm -rf /var/lib/apt/lists/*

XXX
