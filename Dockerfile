# nodeイメージに対してasでエイリアスをつけます。エイリアスはCOPYコマンド等で使用することが可能となります
# このDockerfileではrubyのイメージに対して命令を記載しているため、FROM の定義順番もnode,rubyである必要があります
# 下記のnode全体は最終的なイメージには保存されません
FROM node:16.20.0-bullseye as node



FROM ruby:3.1.2
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
# apt-getで必要なパッケージをインストールします
# -y オプションはyes/noのダイアログに対してyesと答えますという意味です、
RUN apt-get update && apt-get install -y \
  build-essential \
  libpq-dev \
  postgresql-client

# WORKDIR 以降の命令は、/myappで実行されます　myapp$
WORKDIR /myapp

# build contextの中のファイルをdockerイメージに組み込んでコンテナが起動した際にコンテナのファイルシステムの/myapp/Gemfileに配置をしている
# ADDもCOPYもbuild contextファイルをdockerイメージに組み込んでコンテナのファイルシステムに配置している
# tarの圧縮ファイルをコピーして解凍したい時はADD、単純にファイルやフォルダをコピーする場合はCOPY
ADD Gemfile /myapp/Gemfile
ADD Gemfile.lock /myapp/Gemfile.lock
COPY package.json /myapp/package.json
COPY yarn.lock /myapp/yarn.lock

# bundle install -> Gemfile.lockの内容をもとにインストール
# yarn install -> yarn.lockの内容をもとにインストール
RUN bundle install && yarn install

# build contextに渡してディレクトリをコンテナファイルシステムの/myappに配置する
ADD . /myapp
