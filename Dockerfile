# Start from the code-server Debian base image
FROM codercom/code-server:4.9.0

USER coder

# Apply VS Code settings
COPY deploy-container/settings.json .local/share/code-server/User/settings.json

# Use bash shell
ENV SHELL=/bin/bash

# Install unzip + rclone (support for remote filesystem)
RUN sudo apt update && sudo apt install unzip -y
RUN sudo apt install -y build-essential wget
RUN curl https://rclone.org/install.sh | sudo bash

# Copy rclone tasks to /tmp, to potentially be used
COPY deploy-container/rclone-tasks.json /tmp/rclone-tasks.json

# Fix permissions for code-server
RUN sudo chown -R coder:coder /home/coder/.local

# You can add custom software and dependencies for your environment below
# -----------

# Install a VS Code extension:
# Note: we use a different marketplace than VS Code. See https://github.com/cdr/code-server/blob/main/docs/FAQ.md#differences-compared-to-vs-code
# RUN code-server --install-extension esbenp.prettier-vscode

# Install apt packages:
# RUN sudo apt-get install -y ubuntu-make
RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.3.326/quarto-1.3.326-linux-amd64.tar.gz && \
mkdir -p ~/opt && tar -C ~/opt -xzf quarto-1.3.326-linux-amd64.tar.gz && \
mkdir -p ~/bin && \
ln -s ~/opt/quarto-1.3.326/bin/quarto ~/bin/quarto && \
rm quarto-1.3.326-linux-amd64.tar.gz
ENV PATH=$PATH:~/bin

# Copy files:
# COPY deploy-container/myTool /home/coder/myTool

RUN code-server --install-extension quarto.quarto

RUN curl -fsSL https://d2lang.com/install.sh | sh -s --

# -----------

# Port
ENV PORT=8080

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]
