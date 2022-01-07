FROM phatli/base:2004

WORKDIR /home/user/
COPY --chown=user TensorRT-8.2.1.8.Linux.x86_64-gnu.cuda-11.4.cudnn8.2.tar.gz /home/user/
RUN tar -xvzf TensorRT-8.2.1.8.Linux.x86_64-gnu.cuda-11.4.cudnn8.2.tar.gz

FROM phatli/pytorch:190cu111cudnn_dev

RUN sudo apt-get install -y ffmpeg libsm6 libxext6 ninja-build libglib2.0-0 \
    libxrender-dev build-essential libssl-dev cmake gcc-7 g++-7 \
    && sudo rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir opencv-python timm pandas onnx onnxruntime-gpu \
    mmcv-full -f https://download.openmmlab.com/mmcv/dist/cu111/torch1.9.0/index.html
COPY --chown=user --from=0 /home/user/TensorRT-8.2.1.8 /home/user/TensorRT-8.2.1.8
WORKDIR /home/user/
RUN export TENSORRT_DIR=/home/user/TensorRT-8.2.1.8 \
    && export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TENSORRT_DIR/lib \
    && pip install $TENSORRT_DIR/python/tensorrt-8.2.1.8-cp38-none-linux_x86_64.whl \
    && pip install $TENSORRT_DIR/onnx_graphsurgeon/onnx_graphsurgeon-0.3.12-py2.py3-none-any.whl \
    && pip install $TENSORRT_DIR/graphsurgeon/graphsurgeon-0.4.5-py2.py3-none-any.whl \
    && echo "export TENSORRT_DIR=/home/user/TensorRT-8.2.1.8" >> /home/user/.zshrc \
    && echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$TENSORRT_DIR/lib" >> /home/user/.zshrc
RUN git clone https://github.com/open-mmlab/mmdeploy.git \
    && cd mmdeploy && git submodule update --init --recursive \
    && pip install -e . \
    && export TENSORRT_DIR=/home/user/TensorRT-8.2.1.8 \
    && export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TENSORRT_DIR/lib \
    && mkdir -p build && cd build && cmake -DMMDEPLOY_TARGET_BACKENDS=trt .. \
    && make -j$(nproc)
RUN git clone https://github.com/open-mmlab/mmsegmentation.git \
    && cd ./mmsegmentation && pip install -e . --user \
    && rm -rf ../mmsegmentation
# Set the default command to zsh
ENTRYPOINT [ "/bin/zsh" ]
CMD ["-l"]