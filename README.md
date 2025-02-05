# wuwaaan

鳴潮のGoogle日本語入力用の辞書とAPIっぽいものも公開。

## ダウンロード

### 辞書

[こちら](https://github.com/anzfactory/wuwa/releases/latest)から dictionary.zip をダウンロードしてください。
あとは展開して Google日本語入力 へインポートしてお使いください。  
フォーマットさえ問題なければ他のIMEでも利用できるかもしれないけれど未確認。

### API

詳細はこちらで。  
https://anzfactory.github.io/wuwaaan/  

テストで叩いてみる分にはこれを利用してみてもいいですけれど、  
ちゃんと使うときは Fork してから自分でデプロイしたものを使うことをおすすめ。  
（アクセスにLimitあるので）

### 

## ローカルで実行

手元の環境で辞書を生成する場合は、下記のように実行してください。

```
dart pub get
dart run build_runner build
dart run wuwa --build dic
```

`build/` 配下に辞書ファイルが生成されます。

* 辞書もAPIも GitHub Actions で生成、デプロイしているのでそちらを確認したほうが正確かもしれない。