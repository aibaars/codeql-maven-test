FROM ubuntu
ARG github_token

RUN apt update && apt install -y curl wget bind9-host unzip

RUN mkdir -p -m 755 /etc/apt/keyrings && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
 && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
 && apt update \
 && apt install gh -y

RUN GH_TOKEN=$github_token gh extension install github/gh-codeql && GH_TOKEN=$github_token gh codeql version

RUN gh codeql pack download codeql/java-queries

RUN apt install -y openjdk-8-jdk openjdk-11-jdk openjdk-19-jdk default-jdk 

RUN apt install -y gradle maven ant

COPY settings.xml /root/.m2/settings.xml

COPY gradle.org.crt /usr/local/share/ca-certificates/gradle.org.crt

RUN update-ca-certificates

COPY init.gradle /root/.gradle/init.d/init.gradle

COPY dep-graph.gradle /root/dep-graph.gradle
COPY github-dependency-graph-gradle-plugin-1.2.2.jar /root/github-dependency-graph-gradle-plugin-1.2.2.jar
COPY maven-settings-plugin-0.8.jar /root/maven-settings-plugin-0.8.jar

RUN for path in /root/.local/share/gh/extensions/gh-codeql/dist/release/*/java/tools; do \
      cp /root/dep-graph.gradle "$path"; \
      cp /root/github-dependency-graph-gradle-plugin-1.2.2.jar "$path"; \
      cp /root/maven-settings-plugin-0.8.jar  "$path"; \
    done
