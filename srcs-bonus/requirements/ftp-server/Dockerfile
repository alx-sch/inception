# Base image for the container.
# Debian 13 ("Trixie") is the latest stable version currenly, but
# Debian 12 ("Bookworm") is the current penultimate stable version.
FROM		debian:bookworm-slim

# Author & Maintainer
LABEL		maintainer="aschenk"

# TBD
RUN			apt-get update && apt-get install -y --no-install-recommends \
			vsftpd \
			passwd \
			&& rm -rf /var/lib/apt/lists/*

# Create the empty directory that vsftpd requires.
RUN			mkdir -p /var/run/vsftpd/empty

# Copy the configuration and the entrypoint script
COPY		./conf/vsftpd.conf /etc/vsftpd.conf
COPY		./tools/init_ftp.sh /etc/pure-ftpd.conf

COPY		./tools/init_ftp.sh /usr/local/bin/init_ftp.sh
RUN			chmod +x /usr/local/bin/init_ftp.sh

# Expose FTP ports; 21 for commands, 21000-21009 for passive data connections
EXPOSE		21
EXPOSE		21000-21009

ENTRYPOINT	["/usr/local/bin/init_ftp.sh"]
