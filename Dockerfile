FROM nvidia/cuda:10.1-devel

RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:THEPASSWORDYOUCREATED' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

ENV NVIDIA_DRIVER_CAPABILITIES compute,video,utility

RUN mkdir -p /usr/local/bin /patched-lib
COPY patch.sh docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/patch.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
