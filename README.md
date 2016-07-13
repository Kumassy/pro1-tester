# pro1-tester
BDD for Pro1

# Overview
プロ1のテストを自動化するためのスクリプトです。
テストを実行するには`testcase.yml`を書く必要がありますが、 https://github.com/Kumassy/pro1-tester-testcases で共有しています。

# Usage
`testcase.default.yml` または `testcase.yml` をソースコード `*.c` と同じディレクトリに置いてください：
```
.
├── assignment_09-a-01.c
├── assignment_09-a-02.c
├── assignment_09-a-03.c
├── assignment_09-a-04.c
├── assignment_09-a-05.c
├── assignment_09-b-01.c
├── assignment_09-b-02.c
├── assignment_09-b-03.c
├── assignment_09-b-04.c
├── assignment_09-c-01.c
├── assignment_09-c-02.c
├── assignment_09-d-01.c
├── testcase.yml
└── testcase.default.yml
```
そして
```
pro1-tester
```
を実行するとテスト結果がでます。


|オプション|説明|
|--:|:--|
|`-d`|デフォルトでは`testcase.yml`がある場合はそちらを実行しますが、このオプションをつけると`testcase.default.yml`を使うようになります|
|`-s`| **ストリクトモード** で実行します。デフォルトでは標準出力と`expect`はスペースと改行を無視して比較されますが、ストリクトモードでは厳密に比較します|

# Setup (KO Unix)
KO の Unix で使う場合、Rubyはインストールされているので gem のインストールだけすれば OK です。  
`--user-install`オプションをつけてユーザー領域に gem をインストールするようにします：
```
gem install pro1-tester --user-install
gem install rspec --user-install
```

`pro1-tester`コマンドを使えるようにパスを通します。

```
vim ~/.bash_profile
```

`PATH=$PATH:$HOME/bin`という行があると思うので、次のように`$HOME/.gem/ruby/2.3.0/bin`を追記します：

```
# 追記
PATH=$PATH:$HOME/.gem/ruby/2.3.0/bin
```

`.bash_profile`を再読み込みします
```
source ~/.bash_profile
```

これでパスが通りました
```
which pro1-tester
~/.gem/ruby/2.3.0/bin/pro1-tester
```

# Setup (Basic)
**Vagrant** でも使って **CentOS** 環境で動かしましょう。
Ruby のインストールをしましょう。

そして、次のコマンドで gem をインストールしてください：
```
gem install pro1-tester
```

# Setup (docker)
## Docker イメージのビルド
```
git clone https://github.com/Kumassy/pro1-tester
cd pro1-tester
docker build -t my-ruby-image .
```

## Docker コンテナの実行
```
cd /path/to/source/and/testcase.yml/
docker run -it --rm -v "$PWD":/app/ -w /app/ my-ruby-image pro1-tester
```

# Writing `testcase.yml`
**YAML** の記法で書いていきます。
基本的に雰囲気で書けばOKです。


- 出力だけ見るプログラムの場合、`input`は省略可能です。
- `label`は`it`に渡すアレです。省略した場合はデフォルトのラベルが使われます。
- `input`に特定の文字（`"`とか`\`とか）が含まれるときはエスケープが必要です。
- `input`の最後に改行が必要で`input`を1行で書くときは、`input`を`""`で囲って最後に`\n`をつけてください。
- 複数行の文字列を書くときには注意しましょう。

```
- expect: |
    A(65)  # ここでインデントつける
    B(66)
    C(67)
    D(68)
    E(69)

```
```
- expect: |
  A(65)  # これはシンタックスエラー
  B(66)
  C(67)
  D(68)
  E(69)

```

# 注意
- 無限ループ内で標準入力を読んでいて、`C-d`をスルーするプログラムの場合はこのスクリプトも無限ループに陥ります（OS がプロセスを強制終了する場合もあります）。
- 仕様上、標準入力に書き込んでその標準出力を見て、その結果に応じてさらに標準入力にデータを流すことはできません。標準入力にガーッと書き込んでダーッと結果を検証する感じでお願いします。
- 標準エラー出力は無視されます。
- このテストケースをパスすればあなたのプログラムが確実に正しい動作をする、ということは完全には保証できません。提出前には手動で最終確認をすることを推奨します。

# 仕様
- 標準入力には`input`のパース結果がそのまま渡されます
    - `input` を1行で書いたときは明示的に`\n`を指定しない限り改行コードは渡されません（Enter キー押さないのと同じ）。
    - `input` を`|`を使って複数行で書いたときは、最終行も含めそれぞれの行末に`\n`がつきます。

# My Environment (on Vagrant)
```
cat /etc/redhat-release
CentOS release 6.7 (Final)
```
```
ruby -v
ruby 2.3.1p112 (2016-04-26 revision 54768) [x86_64-linux]
```
```
rspec -v
3.4.4
```
```
gcc -v
Using built-in specs.
Target: x86_64-redhat-linux
コンフィグオプション: ../configure --prefix=/usr --mandir=/usr/share/man --infodir=/usr/share/info --with-bugurl=http://bugzilla.redhat.com/bugzilla --enable-bootstrap --enable-shared --enable-threads=posix --enable-checking=release --with-system-zlib --enable-__cxa_atexit --disable-libunwind-exceptions --enable-gnu-unique-object --enable-languages=c,c++,objc,obj-c++,java,fortran,ada --enable-java-awt=gtk --disable-dssi --with-java-home=/usr/lib/jvm/java-1.5.0-gcj-1.5.0.0/jre --enable-libgcj-multifile --enable-java-maintainer-mode --with-ecj-jar=/usr/share/java/eclipse-ecj.jar --disable-libjava-multilib --with-ppl --with-cloog --with-tune=generic --with-arch_32=i686 --build=x86_64-redhat-linux
スレッドモデル: posix
gcc version 4.4.7 20120313 (Red Hat 4.4.7-16) (GCC)
```
```
docker -v
Docker version 1.7.1, build 786b29d
```

# TODO
- 無限ループするプログラムに対してのタイムアウト処理
