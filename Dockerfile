FROM phatli/pytorch:190cu111_dev

RUN sudo apt-get install -y ffmpeg libsm6 libxext6 ninja-build libglib2.0-0 libxrender-dev\
    && sudo rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir mmcv-full -f https://download.openmmlab.com/mmcv/dist/cu111/torch1.9.0/index.html && \
    pip install --no-cache-dir opencv-python timm pandas
COPY --chown=user . /home/user/mmseg
RUN cd /home/user/mmseg && pip install -e . --user && rm -rf /home/user/mmseg

# Set the default command to zsh
ENTRYPOINT [ "/bin/zsh" ]
CMD ["-l"]