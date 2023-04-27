FROM node:16.20.0-bullseye as node
# 上記のnodeは最終的なイメージには保存されない


FROM ruby:3.0
# Install Node.js and Yarn、nodeイメージがcreateされstartしてbashで入った際に以下のフォルダーが確認できた
# /opt/yarn-* , /usr/local/bin/node , /usr/local/lib/node_modules/
# 以下の記述はnodeコンテナで生成されたフォルダーをrubyコンテナにコピーしている
# ln -fs では左のソースを右のターゲット名で呼び出せるようにシンボリックリンクを作成している
COPY --from=node /opt/yarn-* /opt/yarn
COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules/ /usr/local/lib/node_modules/
RUN ln -fs /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -fs /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npx \
  && ln -fs /opt/yarn/bin/yarn /usr/local/bin/yarn \
  && ln -fs /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg
RUN apt-get update && apt-get install -y \
  build-essential \
  libpq-dev \
  postgresql-client
WORKDIR /myapp
ADD Gemfile /myapp/Gemfile
ADD Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
ADD . /myapp
