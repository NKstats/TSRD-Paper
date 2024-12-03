FROM rocker/rstudio:4.4.2
ARG linux_user_pwd
ENV DEBIAN_FRONTEND=noninteractive

RUN echo "rstudio:${linux_user_pwd}" | chpasswd && \
    apt-get update && apt-get install -y man-db && \
    rm -rf /var/lib/apt/lists/*

RUN R -e "install.packages(c('tidyverse', 'MatchIt', 'pacman', 'cobalt', \
    'gridExtra', 'geepack', 'tableone', 'broom', 'bcaboot', 'FDRestimation', \
    'quickmatch', 'ggpubr', 'survey', 'marginaleffects', 'patchwork'))"

EXPOSE 8787
WORKDIR /home/rstudio