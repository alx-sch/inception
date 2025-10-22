# Base image for the container.
# Debian 13 ("Trixie") is the latest stable version currenly, but
# Debian 12 ("Bookworm") is the current penultimate stable version.
FROM	debian:bookworm-slim

# Author & Maintainer
LABEL	maintainer="aschenk"

# Copy the local site files into the image
COPY	site-files/ /site-files-temp/

# Copy the deployment script and make it executable
COPY	./tools/deploy_static.sh /usr/local/bin/deploy_static.sh
RUN		chmod +x /usr/local/bin/deploy_static.sh

# Script copies website files to wordpress-files volume
ENTRYPOINT ["/usr/local/bin/deploy_static.sh"]
