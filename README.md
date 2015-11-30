# EC-CUBE3 on さくら

EC-CUBE 3系を、さくらインターネットVPS上に展開するためのプロダクト一式です。

* さくらインターネットVPS（CentOS）の基本的な構成
  * ログイン用ユーザー（≠root）の作成
  * ログイン用ユーザーのsudo権限付与
  * ログイン用ユーザーの公開鍵作成
  * SSHのパスワード認証無効化
  * ファイアーウォール（iptables）設定
  * ウィルス対策（ClamAV）

* LAMP環境構築
  * Apache、PHP、MySQL、phpMyAdminインストール

* EC-CUBE3 インストール

## 環境準備

### さくらVPSの申し込み

さくらインターネット サイト上にてVPSの申し込みを行います。

申し込み後「仮登録完了」のメールが届いたら、書かれている下記の情報を控えておきます。

* 管理用ユーザ(root)の初期パスワード

* [コントロールパネル]([https://secure.sakura.ad.jp/vps/)にログインし、ホスト名を調べる。（◯◯◯◯.vs.sakura.ne.jp）

### ターミナル

* Macの場合

  既にインストールされているターミナルを使います。

  * アプリケーション－「ユーティリティ」－「ターミナル」で起動

  ※お好みでiTerm2等のターミナルツールをインストールしてご利用ください。

* Windowsの場合

  1. msysGit(Git for Windows)のインストール

    1. [https://msysgit.github.io/](https://msysgit.github.io/) よりGit for Windowsをダウンロード
    2. exeファイルを実行し指示に従いインストールする。
    3. インストール中「Use Git from Git Bash Only」「Use Git from the Windows Command Prompt」を選択する画面では、「Use Git from Git Bash Only」を選択する。（説明の都合上）
    4. インストール中「Checkout Windows-style, commit Unix-style line endings」「Checkout as-is, commit Unix-style line endings」「Checkout as-is, commit as-is」を選択する画面では、 **「Checkout as-is, commit as-is」を選択する。** （絶対！）
    5. デスクトップのGitBashを実行しターミナル画面が起動することを確認。

  2. LF→CRLFへの自動変換を無効化

    * GitBashターミナルを起動し、下記コマンドを実行

    ```bash
    $ git config --global core.autocrlf false
    ```

### Chef Development Kit（ChefDK）のインストール

（Mac、Windows共通）

1. [https://downloads.chef.io/chef-dk/](https://downloads.chef.io/chef-dk/)より、環境に合致するChef Development Kitをダウンロード、インストールする。

2. Chefインストール確認

```bash
$ chef -v
Chef Development Kit Version: 0.10.0
chef-client version: 12.5.1
berks version: 4.0.1
kitchen version: 1.4.2
```
※ バージョンは環境により異なります。

3. khife-soloインストール

```bash
$ sudo chef gem install knife-zero --no-document
Password:  <-聞かれた場合はユーザーのパスワードを入力

WARNING:  You don’t have /Users/user/.chefdk/gem/ruby/2.1.0/bin in your PATH, <-無視

Successfully installed knife-zero-1.10.1
1 gem installed
```

## サーバ構築の実行

### ダウンロード

ターミナル上で下記を実行します。

```bash
$ pwd
（現在のディレクトリ）
$ cd <適当なディレクトリ>
$ git clone https://github.com/logicheart/eccube3_sakuravps.git
$ ls
 :
eccube3_sakuravps
 :
```

### 環境初期化

1. Chef環境初期化（bootstrap）

```bash
$ knife zero bootstrap XXXXXX.vs.sakura.ne.jp -x root
                       ~~~~~~~~~~~~~~~~~~~~~~
Are you sure you want to continue connecting (yes/no)? <- 聞かれたらyesと入力

Connecting to XXXXXX.vs.sakura.ne.jp
root@XXXXXX.vs.sakura.ne.jp’s password:  <- さくらVPSのrootパスワードを入力
  :
XXXXXX.vs.sakura.ne.jp Chef Client finished, 0/0 resources updated in 04 seconds
```

2. node追加の確認

```bash
$ knife node list
XXXXXX.vs.sakura.ne.jp  <-このように表示されることを確認
```

3. パラメータの設定

chef-repo/nodes/XXXXXX.vs.sakura.ne.jp.json

```json



```

## 環境構築

```bash
$ knife zero converge 'name:*' -x root
root@XXXXXXX.vs.sakura.ne.jp’s password: <- さくらVPSのrootパスワードを入力
```

## 注意

既にRuby環境がインストールされている場合、Chefの実行に失敗する可能性があります。

その場合は[さくらのナレッジ](http://knowledge.sakura.ad.jp/tech/2825/)を参照してください。
