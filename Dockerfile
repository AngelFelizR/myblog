FROM ubuntu:24.04

# Update and install ALL packages in one layer, including locales
RUN apt update -y && \
    apt install -y locales curl openssh-server xz-utils git ca-certificates && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# Set locale environment variables
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# The next line installs Nix inside Docker
RUN bash -c 'sh <(curl --proto "=https" --tlsv1.2 -L https://nixos.org/nix/install) --daemon'

# Adds Nix to the path
ENV PATH="${PATH}:/nix/var/nix/profiles/default/bin"
ENV user=root

# Install direnv and nix-direnv for Positron integration
RUN nix-env -f '<nixpkgs>' -iA direnv nix-direnv

# Set up rstats-on-nix cache
# Thanks to the rstats-on-nix cache, precompiled binary packages will
# be downloaded instead of being compiled from source
RUN mkdir -p /root/.config/nix && \
    echo "substituters = https://cache.nixos.org https://rstats-on-nix.cachix.org" > /root/.config/nix/nix.conf && \
    echo "trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= rstats-on-nix.cachix.org-1:vdiiVgocg6WeJrODIqdprZRUrhi1JzhBnXv7aWI6+F0=" >> /root/.config/nix/nix.conf

# Starting nix-shell
RUN echo '. /nix/var/nix/profiles/default/etc/profile.d/nix.sh' >> /root/.bashrc

# Defining environment with Nix
COPY default.nix .

# We now build the environment (~5000s, heavily cached)
RUN nix-build
RUN nix-collect-garbage -d

# Defining ports to share SSH
EXPOSE 22

# Defining SSH configuration
RUN mkdir -p /var/run/sshd && \
    mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "AuthorizedKeysFile .ssh/authorized_keys" >> /etc/ssh/sshd_config

# Start SSH server
CMD ["/usr/sbin/sshd", "-D"]
