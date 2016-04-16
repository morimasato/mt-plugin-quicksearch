package QuickSearch::L10N::ja;

use strict;
use base 'QuickSearch::L10N::en_us';
use vars qw( %Lexicon );

%Lexicon = (

## plugins/QuickSearch/tmpl/system_config.tmpl
	'Quick Search' => 'Quick Search',
	'Automatically update the search index of QuickSearch.' => 'このプラグインは、ブログ記事やウェブページの追加／変更／削除が実行されると、QuickSearchの検索インデックスを自動更新します。',
	'Content Key' => 'コンテンツキー',
	'Api Secret Key' => 'API秘密鍵',

## ERROR MESSAGE
	'Content key not found' => 'コンテンツキーがありません。',
	'Invalid Api Key' => 'API秘密鍵が不正です。',
	'Invalid email address' => 'メールアドレスが正しくありません。',
	'Api Key is required' => 'API秘密鍵は必須です。',
	'Json is required' => 'JSONデータは必須です。',
	'Document id is required' => '文書IDは必須です',
	'For improved security, please delete `X-FTS-API-Key` header.' => '情報漏洩の危険があるので、ヘッダーにAPI秘密鍵を設定しないでください。',
	'Create Content Error' => 'コンテンツの作成でエラーが発生しました。',
	'Update Content Error' => 'コンテンツの更新でエラーが発生しました。',
);

1;
