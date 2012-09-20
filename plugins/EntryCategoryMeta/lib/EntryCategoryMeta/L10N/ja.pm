package EntryCategoryMeta::L10N::ja;

use strict;
use utf8;

use base 'EntryCategoryMeta::L10N';

use vars qw( %Lexicon );

%Lexicon = (
    '_PLUGIN_DESCRIPTION' => 'ブログ記事とカテゴリの間に任意のデータを設定できるようになります。',

    'Form Template' => 'フォームテンプレート',
    'Template.js format' => 'Template.jsテンプレートです。&#91;#= item.meta.変数名 #&#93;で値を取得できます。',
    'Form Fields' => 'フォームフィールド',
    'Fill in a comma-separated.' => 'name属性値をカンマ区切りで入力',
);

1;
