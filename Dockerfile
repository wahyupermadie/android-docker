FROM gradle:6.1.1-jdk8

LABEL maintainer "wahyu.permadi1725@gmail.com"

WORKDIR /

SHELL ["/bin/bash", "-c"]


ENV ANDROID_COMPILE_SDK=29
ENV ANDROID_BUILD_TOOLS=29.0.2
ENV ANDROID_SDK_TOOLS=4333796

ENV ANDROID_HOME=/usr/local/android-sdk
ENV DEBIAN_FRONTEND noninteractive

# Setup Timezone
ENV TZ=Asia/Jakarta
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get upgrade -y && apt-get --quiet install --yes \ 
    wget \
    tar \
    unzip \
    lib32stdc++6 \
    lib32z1 \
    openjdk-8-jdk

# Setup Ruby and Fastlane
RUN echo y | apt-get install ruby-full build-essential

# Download Bundletool
RUN cd "root" \
    && wget --quiet --output-document=bundletool.jar https://github.com/google/bundletool/releases/download/1.4.0/bundletool-all-1.4.0.jar

# Download Android SDK
RUN mkdir "$ANDROID_HOME" .android \
    && cd "$ANDROID_HOME" \
    && wget --quiet --output-document=sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_TOOLS}.zip \
    && unzip sdk.zip
RUN echo y | $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-${ANDROID_COMPILE_SDK}" >/dev/null
RUN echo y | $ANDROID_HOME/tools/bin/sdkmanager "platform-tools" >/dev/null
RUN echo y | $ANDROID_HOME/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS}" >/dev/null
RUN export ANDROID_HOME="/usr/local/android-sdk/sdk"
RUN export PATH=$PATH:$ANDROID_HOME/platform-tools/
# temporarily disable checking for EPIPE error and use yes to accept all licenses
RUN set +o pipefail
RUN yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses
RUN set -o pipefail
