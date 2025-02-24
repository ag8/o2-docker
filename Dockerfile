FROM nvcr.io/nvidia/pytorch:24.07-py3

# Install system dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    openssh-server \
    libboost-all-dev \
    swig \
    python3-dev \
    build-essential \
    libopenbabel-dev \
    python3-openbabel \
    && rm -rf /var/lib/apt/lists/* \
    && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config \
    && echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

# Set working directory
WORKDIR /app

# Clone the repository
RUN git clone https://github.com/ag8/orl2 .

# Install and configure Python packages
RUN pip uninstall -y xgboost transformer_engine flash_attn && \
    pip install -e . && \
    pip uninstall -y flash-attn && \
    pip install flash-attn==2.7.0.post2 --no-build-isolation && \
    pip uninstall -y pynvml nvidia-ml-py && \
    pip install nvidia-ml-py>=12.0.0 && \
    pip install protobuf==3.20.2 && \
    pip install vllm && \
    pip uninstall -y flash-attn && \
    pip install flash-attn --no-build-isolation && \
    pip install rdkit cirpy biopython ase vina meeko && \
    pip uninstall -y protobuf && \
    pip install protobuf==3.20.3

# Set environment variables
ENV NCCL_DEBUG=INFO
ENV VLLM_USE_CUDA=1

# Create entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Setup SSH directory
RUN mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
