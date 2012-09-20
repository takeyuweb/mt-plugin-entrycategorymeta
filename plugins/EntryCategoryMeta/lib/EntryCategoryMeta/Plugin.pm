package EntryCategoryMeta::Plugin;

use strict;
use utf8;

our $plugin = MT->component( 'EntryCategoryMeta' );

sub hdlr_ts_category_selector {
    my ( $cb, $app, $tmpl_ref ) = @_;

    my $blog_id = $app->blog ? $app->blog->id : undef;

    return 1 unless $blog_id && $plugin->get_config_value( 'enable', "blog:$blog_id" );

    my $template = $plugin->get_config_value( 'template', "blog:$blog_id" );

    my $jq_include = <<'EOF';
<mt:setvarblock name="jq_js_include" preppend="1">
(function($){
    // フォーム送信前にデータを整形
    // entry_category_meta[category_id][name]
    $(":submit.action").filter(".publish, .preview").click(function(){
        $('.category-selector .entry-category-meta').each(function(){
            var obj = $(this);
            var id = obj.data('category_id');
            obj.find(':input').each(function(){
                var input = $(this);
                if(input.data('entry-category-meta') == 1) return;
                var name = input.attr('name');
                input.attr('name', 'entry_category_meta['+id+']['+name+']')
                input.data('entry-category-meta', 1);
            });
        });
    });
})(jQuery);
</mt:setvarblock>
EOF

    my $orig = '<input type="<mt:if name="object_type" eq="page">radio<mt:else>checkbox</mt:if>" name="<mt:if name="object_type" eq="entry">add_</mt:if>category_id<mt:if name="object_type" eq="entry">_[#= item.id #]</mt:if>" class="add-category-checkbox" <mt:if name="category_is_selected">checked="checked"</mt:if> /> [#|h item.label #]';
    my $to = '<input type="<mt:if name="object_type" eq="page">radio<mt:else>checkbox</mt:if>" name="<mt:if name="object_type" eq="entry">add_</mt:if>category_id<mt:if name="object_type" eq="entry">_[#= item.id #]</mt:if>" class="add-category-checkbox" <mt:if name="category_is_selected">checked="checked"</mt:if> /> [#|h item.label #]' . '<div class="entry-category-meta" data-category_id="[#= item.id #]" onclick="event.stopPropagation(); return false;">' . $template . '</div>';

    $$tmpl_ref =~ s!@{[ quotemeta($orig) ]}!$to!;
    $$tmpl_ref .= $jq_include;

    1;
}

# プレビューから戻りならその値
# 編集開始ならDBのデータを
# テンプレート変数に埋め込む
# テンプレート中 [#= item.meta.変数名 #] で値を取得
sub hdlr_tp_edit_entry {
    my ( $cb, $app, $param, $tmpl ) = @_;
    
    my $set = 0;
    my %meta_params = ();
    
    unless ( $app->param( 'reedit' ) ) {
        my $type = $app->param( '_type' ) || 'entry';
        my $id = $app->param( 'id' ) || -1;
        if ( $type && $id ) {
            my $entry = MT->model( $type )->load( {id => $id}, { limit => 1 } );
            if ( $entry ) {
                $set = 1;
                %meta_params = _entry_category_meta( $entry );
            }
        }
    }
    
    %meta_params = _parse_entry_category_meta( $app ) unless $set;
    
    foreach my $category ( @{ $param->{ 'category_tree' } } ) {
        my $meta_param = $meta_params{ $category->{ id } };
        $category->{ meta } = $meta_param || {};
    }
    
    1;
}

# プレビュー画面に埋め込み
sub hdlr_tp_preview_entry {
    my ( $cb, $app, $param, $tmpl ) = @_;
    my %meta_params = _parse_entry_category_meta( $app );
    foreach my $cat_id ( keys %meta_params ) {
        my $meta_param = $meta_params{ $cat_id };
        foreach my $key ( keys %$meta_param ) {
            push @{ $param->{ 'entry_loop' } }, {
                data_name => "entry_category_meta[$cat_id][$key]",
                data_value => $meta_param->{ $key }
            };
        }
    }
}

# 保存
sub hdlr_cms_post_save_entry {
    my ( $cb, $app, $obj, $original ) = @_;
    
    my %meta_params = _parse_entry_category_meta( $app );
    # エンコードして保存
    require MT::Serialize;
    foreach my $cat_id ( keys %meta_params ) {
        my $placement = MT->model( 'placement' )->load( { entry_id => $obj->id, category_id => $cat_id }, { limit => 1 } );
        next unless $placement;
        my $meta_param = $meta_params{ $cat_id } || {};
        my $data = MT::Serialize->serialize( \$meta_param );
        $placement->entry_category_meta( $data );
        $placement->save or die $placement->errstr;
    }
    
    1;
}

# パラメータ取り出し
# entry_category_meta[category_id][name]
# ( <cat_id1> => { name1 => value1 }, { name2 => value2 },
#   <cat_id2> => { name1 => value1 }, { name2 => value2 } )
sub _parse_entry_category_meta {
    my ( $app ) = @_;
    my %meta_params = ();
    
    my %param_hash = $app->param_hash();
    foreach my $key ( keys( %param_hash ) ) {
        next unless $key =~ /^entry_category_meta\[(\d+)\]\[(.+)\]$/;
        my $cat_id = $1;
        my $name = $2;
        $meta_params{$cat_id} ||= {};
        $meta_params{$cat_id}->{ $name } = $param_hash{ $key };
    }
    
    return %meta_params;
}

# レコードからメタデータ取り出し
sub _entry_category_meta {
    my ( $entry ) = @_;
    
    my %meta_params = ();
    return %meta_params unless $entry && $entry->id;
    
    require MT::Serialize;
    my $iter = MT->model( 'placement' )->load_iter( { entry_id => $entry->id } );
    while ( my $placement= $iter->() ) {
        my $data = $placement->entry_category_meta();
        my $meta_param = $data ? ${ MT::Serialize->unserialize( $data ) } : {};
        $meta_params{ $placement->category_id } = $meta_param;
    }
    
    return %meta_params;
}

1;
