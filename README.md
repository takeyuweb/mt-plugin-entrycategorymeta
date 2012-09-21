EntryCategoryMeta
===========

* Author:: Yuichi Takeuchi <uzuki05@takeyu-web.com>
* Website:: http://takeyu-web.com/
* Copyright:: Copyright 2012 Yuichi Takeuchi
* License:: MIT-LICENSE

ブログ記事とカテゴリの間にメタデータを追加できるようになります。
入力フォームのテンプレートを自分で設定でき、追加するメタデータの自由度が高いのが特徴です。

動作要件
-----------

MT(MTOS) 5.1

他のバージョンは不明。

インストール
-----------

plugins/EntryCategoryMeta を MT_DIR/plugins/ にコピーして下さい。

設定
-----------

メタデータを追加させたいブログのプラグイン設定から有効にし、フォームテンプレートを編集します。

フォームテンプレートは、編集画面のカテゴリウィジェットで使用される、Template.jsテンプレートに埋め込まれます。

  <select name="select1">
  <option value=""]></option>
  [# selected='' #][# if ( item.meta.select1 == "Apple" ) selected='selected' #]
  <option value="Apple" [#= selected #]>Apple</option>
  [# selected='' #][# if ( item.meta.select1 == "Orange" ) selected='selected' #]
  <option value="Orange" [#= selected #]>Orange</option>
  [# selected='' #][# if ( item.meta.select1 == "Banana" ) selected='selected' #]
  <option value="Banana" [#= selected #]>Banana</option>
  </select>
  <input type="text" name="text1" value="[#= item.meta.text1 #]" />


利用方法
-----------

ブログ記事の編集画面のカテゴリウィジェットで、カテゴリ毎にフォームが表示され、入力ができるようになります。
プレビューにも対応しています。


メタデータの表示
-----------

以下のテンプレートタグが提供されます。
共に、「ブログ記事のカテゴリ」のコンテキストで利用できます。

### MTIfEntryCategoryMetaコンディショナルタグ

コンテキストのブログ記事のカテゴリとの間にメタデータが設定されていればブロックを処理。

### MTEntryCategoryMetaファンクションタグ

nameモディファイアで指定した名前のメタデータの値を取得

### サンプル

  <mt:EntryCategories>
    <a href="<$mt:CategoryArchiveLink$>" rel="tag" title="<$mt:CategoryDescription escape="html"$>"><$mt:CategoryLabel$></a>
    <mt:IfEntryCategoryMeta>
      <br />
      <$MTEntryCategoryMeta name="select1" escape="html"$><br />
      <$MTEntryCategoryMeta name="hour1" zero_pad="2"$>:<$MTEntryCategoryMeta name="min1" zero_pad="2"$>
      ～
      <$MTEntryCategoryMeta name="hour2" zero_pad="2"$>:<$MTEntryCategoryMeta name="min2" zero_pad="2"$>
    </mt:IfEntryCategoryMeta>
  </mt:EntryCategories>


お約束
-----------

ご利用は自己責任で。
