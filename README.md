# wuwaaan

鳴潮のGoogle日本語入力用の辞書
今は実装済みのプレイアブルキャラのみ。

## ダウンロード

[こちら](https://github.com/anzfactory/wuwa/releases/latest)から dictionary.zip をダウンロードしてください。
あとは展開して Google日本語入力 へインポートしてお使いください。

## ローカルで実行

手元の環境で辞書を生成する場合は、下記のように実行してください。

```
dart pub get
dart run build_runner build
dart run wuwa --build dic
```

`build/` 配下に辞書ファイルが生成されます。